extends Node

const SAVE_DIR := "user://saves"

func ensure_save_directory() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SAVE_DIR))

func save_game(slot_id: int) -> void:
	ensure_save_directory()
	GameState.save_slot_index = slot_id
	GameState.save_timestamp = Time.get_datetime_string_from_system()
	GameState.save_progress_stage = GameState.get_story_phase_label()
	var file_path := _get_slot_path(slot_id)
	var save_file := FileAccess.open(file_path, FileAccess.WRITE)
	if save_file == null:
		return
	var save_data := collect_save_data()
	save_data["slot_id"] = slot_id
	save_data["save_exists"] = true
	save_data["last_saved_at"] = Time.get_datetime_string_from_system()
	save_file.store_string(JSON.stringify(save_data, "\t"))

func load_game(slot_id: int) -> void:
	var file_path := _get_slot_path(slot_id)
	if not FileAccess.file_exists(file_path):
		return
	var save_file := FileAccess.open(file_path, FileAccess.READ)
	if save_file == null:
		return
	var parsed := JSON.parse_string(save_file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	apply_save_data(parsed)

func get_slot_summary(slot_id: int) -> Dictionary:
	var file_path := _get_slot_path(slot_id)
	if not FileAccess.file_exists(file_path):
		return {"slot_id": slot_id, "save_exists": false}
	var save_file := FileAccess.open(file_path, FileAccess.READ)
	if save_file == null:
		return {"slot_id": slot_id, "save_exists": false}
	var parsed := JSON.parse_string(save_file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return {"slot_id": slot_id, "save_exists": false}
	return parsed

func delete_save(slot_id: int) -> void:
	var file_path := _get_slot_path(slot_id)
	if FileAccess.file_exists(file_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(file_path))

func has_save(slot_id: int) -> bool:
	return FileAccess.file_exists(_get_slot_path(slot_id))

func collect_save_data() -> Dictionary:
	GameState.save_progress_stage = GameState.get_story_phase_label()
	return {
		"slot_id": GameState.save_slot_index,
		"save_exists": true,
		"current_scene": get_tree().current_scene.scene_file_path if get_tree().current_scene else "",
		"spawn_marker": "",
		"story_phase": GameState.save_progress_stage,
		"games_completed_count": GameState.get_games_completed_count(),
		"total_games_count": GameState.get_total_games_count(),
		"secrets_found_count": GameState.get_secrets_found_count(),
		"total_secrets_count": GameState.get_total_secrets_count(),
		"post_reveal_roam_unlocked": GameState.post_reveal_roam_unlocked,
		"ending_seen": GameState.ending_seen,
		"twist_reveal_seen": GameState.twist_reveal_seen,
		"play_time_seconds": Time.get_ticks_msec() / 1000.0,
		"last_saved_at": GameState.save_timestamp,
		"game_state": GameState.to_save_data(),
	}

func apply_save_data(data: Dictionary) -> void:
	if data.has("game_state") and typeof(data["game_state"]) == TYPE_DICTIONARY:
		GameState.apply_save_data(data["game_state"])

func _get_slot_path(slot_id: int) -> String:
	return "%s/slot_%d.json" % [SAVE_DIR, slot_id]
