extends Node

const DEBUG := preload("res://scripts/Debug.gd")

const SAVE_DIR := "user://saves"

var active_slot_id := 0
var save_dir_override := ""

func ensure_save_directory() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(_get_save_dir()))

func save_game(slot_id: int) -> bool:
	if slot_id <= 0:
		DEBUG.warning(self, "save", "save_rejected", {"slot": slot_id, "reason": "invalid_slot"})
		_play_audio("play_error")
		return false
	ensure_save_directory()
	var timestamp := Time.get_datetime_string_from_system()
	GameState.save_slot_index = slot_id
	GameState.save_timestamp = timestamp
	GameState.save_progress_stage = GameState.get_story_phase_label()
	var file_path := _get_slot_path(slot_id)
	var save_file := FileAccess.open(file_path, FileAccess.WRITE)
	if save_file == null:
		DEBUG.failure(self, "save", "save_open_failed", {"slot": slot_id, "path": file_path})
		_play_audio("play_error")
		return false
	var save_data := collect_save_data()
	save_data["slot_id"] = slot_id
	save_data["save_exists"] = true
	save_data["last_saved_at"] = timestamp
	save_file.store_string(JSON.stringify(save_data, "\t"))
	active_slot_id = slot_id
	DEBUG.info(self, "save", "save_completed", {
		"slot": slot_id,
		"path": file_path,
		"scene": save_data.get("current_scene", ""),
		"quest": GameState.get_current_quest_id(),
	})
	_play_audio("play_save")
	return true

func load_game(slot_id: int) -> bool:
	if slot_id <= 0:
		DEBUG.warning(self, "save", "load_rejected", {"slot": slot_id, "reason": "invalid_slot"})
		_play_audio("play_error")
		return false
	var file_path := _get_slot_path(slot_id)
	if not FileAccess.file_exists(file_path):
		DEBUG.warning(self, "save", "load_rejected", {"slot": slot_id, "reason": "missing_file", "path": file_path})
		_play_audio("play_error")
		return false
	var save_file := FileAccess.open(file_path, FileAccess.READ)
	if save_file == null:
		DEBUG.failure(self, "save", "load_open_failed", {"slot": slot_id, "path": file_path})
		_play_audio("play_error")
		return false
	var parsed: Variant = _parse_json(save_file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		DEBUG.warning(self, "save", "load_rejected", {"slot": slot_id, "reason": "invalid_json"})
		_play_audio("play_error")
		return false
	if not parsed.has("game_state") or typeof(parsed["game_state"]) != TYPE_DICTIONARY:
		DEBUG.warning(self, "save", "load_rejected", {"slot": slot_id, "reason": "missing_game_state"})
		_play_audio("play_error")
		return false
	apply_save_data(parsed)
	active_slot_id = slot_id
	GameState.save_slot_index = slot_id
	GameState.save_progress_stage = GameState.get_story_phase_label()
	DEBUG.info(self, "save", "load_completed", {
		"slot": slot_id,
		"saved_scene": parsed.get("current_scene", ""),
		"quest": GameState.get_current_quest_id(),
	})
	load_saved_scene_or_default(parsed)
	_play_audio("play_ui_confirm")
	return true

func start_new_memory(slot_id: int) -> bool:
	if slot_id <= 0:
		_play_audio("play_error")
		return false
	GameState.reset_for_new_game()
	active_slot_id = slot_id
	GameState.save_slot_index = slot_id
	var saved := save_game(slot_id)
	if not saved:
		active_slot_id = 0
	return saved

func get_slot_summary(slot_id: int) -> Dictionary:
	var file_path := _get_slot_path(slot_id)
	if not FileAccess.file_exists(file_path):
		return {"slot_id": slot_id, "save_exists": false}
	var save_file := FileAccess.open(file_path, FileAccess.READ)
	if save_file == null:
		return {"slot_id": slot_id, "save_exists": false}
	var parsed: Variant = _parse_json(save_file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return {"slot_id": slot_id, "save_exists": false}
	if not _is_valid_save_data(parsed):
		return {"slot_id": slot_id, "save_exists": false}
	return _normalize_slot_summary(parsed, slot_id)

func delete_save(slot_id: int) -> void:
	if slot_id <= 0:
		return
	var file_path := _get_slot_path(slot_id)
	if FileAccess.file_exists(file_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(file_path))

func has_save(slot_id: int) -> bool:
	if slot_id <= 0:
		return false
	var file_path := _get_slot_path(slot_id)
	if not FileAccess.file_exists(file_path):
		return false
	var save_file := FileAccess.open(file_path, FileAccess.READ)
	if save_file == null:
		return false
	var parsed: Variant = _parse_json(save_file.get_as_text())
	return _is_valid_save_data(parsed)

func _parse_json(contents: String) -> Variant:
	# JSON.parse_string() reports malformed player files as engine errors. The
	# instance parser lets the save UI reject them quietly and log useful context.
	var parser := JSON.new()
	if parser.parse(contents) != OK:
		return null
	return parser.data

func collect_save_data() -> Dictionary:
	GameState.save_progress_stage = GameState.get_story_phase_label()
	var current_scene_path := _get_current_save_scene_path()
	GameState.save_scene_name = current_scene_path
	var safe_spawn_marker := _get_safe_spawn_marker_for_scene(current_scene_path)
	var game_state_data := GameState.to_save_data()
	game_state_data["has_arcade_return_position"] = false
	game_state_data["arcade_return_position_x"] = 0.0
	game_state_data["arcade_return_position_y"] = 0.0
	game_state_data["save_player_position_x"] = 0.0
	game_state_data["save_player_position_y"] = 0.0
	return {
		"slot_id": GameState.save_slot_index,
		"save_exists": true,
		"current_scene": current_scene_path,
		"spawn_marker": safe_spawn_marker,
		"story_phase": GameState.save_progress_stage,
		"games_completed_count": GameState.get_games_completed_count(),
		"total_games_count": GameState.get_total_games_count(),
		"required_progress_count": GameState.get_required_progress_count(),
		"total_required_progress_count": GameState.get_total_required_progress_count(),
		"optional_games_completed_count": GameState.get_optional_games_completed_count(),
		"total_optional_games_count": GameState.get_total_optional_games_count(),
		"secrets_found_count": GameState.get_secrets_found_count(),
		"total_secrets_count": GameState.get_total_secrets_count(),
		"post_reveal_roam_unlocked": GameState.post_reveal_roam_unlocked,
		"ending_seen": GameState.ending_seen,
		"twist_reveal_seen": GameState.twist_reveal_seen,
		"memory_signal_label": GameState.get_memory_signal_label(),
		"play_time_seconds": Time.get_ticks_msec() / 1000.0,
		"last_saved_at": GameState.save_timestamp,
		"game_state": game_state_data,
	}

func apply_save_data(data: Dictionary) -> void:
	if data.has("game_state") and typeof(data["game_state"]) == TYPE_DICTIONARY:
		GameState.reset_for_new_game()
		var compatible_state := GameState.get_compatible_save_data_for_summary(data["game_state"])
		GameState.apply_save_data(compatible_state)
		GameState.clear_arcade_return_position()

func load_saved_scene_or_default(data: Dictionary) -> void:
	var scene_path := str(data.get("current_scene", ""))
	var resume_scene := _get_safe_resume_scene(scene_path)
	DEBUG.info(self, "save", "resume_scene_resolved", {"saved": scene_path, "resume": resume_scene})
	_load_scene_at_safe_spawn(resume_scene)

func _get_current_save_scene_path() -> String:
	var current_scene := get_tree().current_scene
	if current_scene == null:
		return SceneChanger.ARCADE_HUB_SCENE
	return _get_safe_resume_scene(current_scene.scene_file_path)


func _get_safe_resume_scene(scene_path: String) -> String:
	if GameState.post_reveal_roam_unlocked:
		return SceneChanger.ARCADE_HUB_SCENE
	match scene_path:
		"", SceneChanger.TITLE_OR_MAIN_SCENE:
			return SceneChanger.ARCADE_HUB_SCENE
		SceneChanger.ROCKBYTE_DUEL_SCENE:
			return SceneChanger.ARCADE_HUB_SCENE
		SceneChanger.BROKEN_HIGH_SCORE_SCENE, SceneChanger.TRUTH_FILTER_SCENE:
			return SceneChanger.CABINET_ROW_SCENE
		SceneChanger.CIRCUIT_SODA_SCENE, SceneChanger.SNACK_SERVICE_DASH_SCENE:
			return SceneChanger.SNACK_ALCOVE_SCENE
		SceneChanger.PRIZE_SHELF_RUN_SCENE:
			return SceneChanger.PRIZE_CORNER_SCENE
		SceneChanger.NIGHT_LEDGER_RUN_SCENE:
			return SceneChanger.SNACK_HALLWAY_SCENE
		SceneChanger.STATIC_SERVICE_RUN_SCENE, SceneChanger.SYNC_DOOR_PUZZLE_SCENE:
			return SceneChanger.MAINTENANCE_HALL_SCENE
		SceneChanger.SECURITY_TAPE_ASSEMBLY_SCENE, SceneChanger.FINAL_NIGHT_WALK_SCENE, SceneChanger.MEMORY_ECHO_SCENE:
			return SceneChanger.STAFF_CORRIDOR_SCENE
		SceneChanger.STAFF_ROOM_SCENE:
			return scene_path if GameState.memory_echo_completed and not GameState.twist_reveal_seen else SceneChanger.ARCADE_HUB_SCENE
	if scene_path.begins_with("res://scenes/cutscenes/"):
		return SceneChanger.ARCADE_HUB_SCENE
	return scene_path if ResourceLoader.exists(scene_path) else SceneChanger.ARCADE_HUB_SCENE

func _load_scene_at_safe_spawn(scene_path: String) -> void:
	GameState.clear_arcade_return_position()
	GameState.set_pending_spawn_id(_get_safe_spawn_marker_for_scene(scene_path))
	DEBUG.info(self, "save", "loading_safe_spawn", {
		"scene": scene_path,
		"spawn": GameState.pending_spawn_id,
	})
	SceneChanger.change_scene(scene_path)

func _get_safe_spawn_marker_for_scene(scene_path: String) -> String:
	match scene_path:
		SceneChanger.ARCADE_HUB_SCENE:
			return "Spawn_Default"
		SceneChanger.CABINET_ROW_SCENE:
			return "Spawn_Default"
		SceneChanger.SNACK_ALCOVE_SCENE:
			return "Spawn_Default"
		SceneChanger.PRIZE_CORNER_SCENE:
			return "Spawn_Default"
		SceneChanger.MAINTENANCE_HALL_SCENE:
			return "Spawn_Default"
		SceneChanger.STAFF_CORRIDOR_SCENE:
			return "Spawn_Default"
		SceneChanger.STAFF_ROOM_SCENE:
			return "Spawn_Default"
	return "Spawn_Default"

func _get_slot_path(slot_id: int) -> String:
	return "%s/slot_%d.json" % [_get_save_dir(), slot_id]

func _get_save_dir() -> String:
	return save_dir_override if not save_dir_override.is_empty() else SAVE_DIR

func _normalize_slot_summary(data: Dictionary, slot_id: int) -> Dictionary:
	data["slot_id"] = slot_id
	data["save_exists"] = true
	if not data.has("game_state") or typeof(data["game_state"]) != TYPE_DICTIONARY:
		return data
	var game_state: Dictionary = GameState.get_compatible_save_data_for_summary(data["game_state"])
	data["story_phase"] = GameState.get_story_phase_label_from_data(game_state)
	data["games_completed_count"] = GameState.get_games_completed_count_from_data(game_state)
	data["total_games_count"] = GameState.get_total_games_count()
	data["required_progress_count"] = GameState.get_required_progress_count_from_data(game_state)
	data["total_required_progress_count"] = GameState.get_total_required_progress_count()
	data["optional_games_completed_count"] = GameState.get_optional_games_completed_count_from_data(game_state)
	data["total_optional_games_count"] = GameState.get_total_optional_games_count()
	data["secrets_found_count"] = GameState.get_secrets_found_count_from_data(game_state)
	data["total_secrets_count"] = GameState.get_total_secrets_count()
	data["post_reveal_roam_unlocked"] = bool(game_state.get("post_reveal_roam_unlocked", false))
	data["ending_seen"] = bool(game_state.get("ending_seen", false))
	data["twist_reveal_seen"] = bool(game_state.get("twist_reveal_seen", false))
	var signal_level := GameState.get_memory_signal_level_from_data(game_state)
	data["memory_signal_label"] = GameState.get_memory_signal_label_from_level(signal_level)
	if not data.has("last_saved_at") or str(data["last_saved_at"]).is_empty():
		data["last_saved_at"] = str(game_state.get("save_timestamp", "Unknown"))
	return data

func _is_valid_save_data(data) -> bool:
	if typeof(data) != TYPE_DICTIONARY:
		return false
	if not data.has("game_state") or typeof(data["game_state"]) != TYPE_DICTIONARY:
		return false
	return true

func _play_audio(method_name: String) -> void:
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager and audio_manager.has_method(method_name):
		audio_manager.call(method_name)
