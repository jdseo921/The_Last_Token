extends Node

const SFX_DIR := "res://assets/audio/sfx/"
const MUSIC_DIR := "res://assets/audio/music/"
const AUDIO_EXTENSIONS := [".wav", ".ogg", ".mp3"]
const SFX_NAMES := {
	"ui_confirm": "ui_confirm",
	"ui_cancel": "ui_cancel",
	"interact": "interact",
	"dialogue_advance": "dialogue_advance",
	"token_get": "token_get",
	"glitch": "glitch",
	"save": "save",
	"error": "error",
	"quest_update": "quest_update",
	"memory_panel": "memory_panel",
	"memory_accept": "memory_accept",
	"door_unlock": "door_unlock",
	"button_pulse": "button_pulse",
	"score_blip": "score_blip",
	"error_buzz": "error_buzz",
	"success_jingle": "success_jingle",
}
const MUSIC_TRACKS := {
	"title_attract_loop": "title_attract_loop",
	"arcade_hub_grounded": "arcade_hub_grounded",
	"arcade_hub_uneasy_fractured": "arcade_hub_uneasy_fractured",
	"cabinet_row_records": "cabinet_row_records",
	"snack_alcove_vendo": "snack_alcove_vendo",
	"maintenance_hall_static": "maintenance_hall_static",
	"staff_corridor_overloaded": "staff_corridor_overloaded",
	"staff_room_reveal_bed": "staff_room_reveal_bed",
	"post_reveal_roam": "post_reveal_roam",
	"rockbyte_duel_game": "rockbyte_duel_game",
	"truth_filter_game": "truth_filter_game",
	"circuit_soda_game": "circuit_soda_game",
	"static_service_run_game": "static_service_run_game",
	"maintenance_sync_game": "maintenance_sync_game",
	"security_tape_final_night_game": "security_tape_final_night_game",
	"memory_echo_conscience": "memory_echo_conscience",
}

var sfx_players: Array[AudioStreamPlayer] = []
var next_player_index := 0
var music_player_a: AudioStreamPlayer = null
var music_player_b: AudioStreamPlayer = null
var active_music_player: AudioStreamPlayer = null
var inactive_music_player: AudioStreamPlayer = null
var current_music_id := ""
var current_music_stream: AudioStream = null
var music_loop_enabled := true
var music_fade_tween: Tween = null
var pending_fade_stop_player: AudioStreamPlayer = null

func _ready() -> void:
	for index in range(4):
		var player := AudioStreamPlayer.new()
		add_child(player)
		sfx_players.append(player)
	music_player_a = AudioStreamPlayer.new()
	music_player_b = AudioStreamPlayer.new()
	add_child(music_player_a)
	add_child(music_player_b)
	music_player_a.finished.connect(_on_music_player_a_finished)
	music_player_b.finished.connect(_on_music_player_b_finished)
	music_player_a.volume_db = _silent_volume_db()
	music_player_b.volume_db = _silent_volume_db()
	active_music_player = music_player_a
	inactive_music_player = music_player_b
	var settings := get_node_or_null("/root/GameSettings")
	if settings and settings.has_signal("settings_changed"):
		settings.settings_changed.connect(_on_settings_changed)

func _exit_tree() -> void:
	_stop_music_fade_tween()
	_stop_all_music_players()
	for player in sfx_players:
		if player == null:
			continue
		player.stop()
		player.stream = null

func play_ui_confirm() -> void:
	_play_sfx("ui_confirm")

func play_ui_cancel() -> void:
	_play_sfx("ui_cancel")

func play_interact() -> void:
	_play_sfx("interact")

func play_dialogue_advance() -> void:
	_play_sfx("dialogue_advance")

func play_token_get() -> void:
	_play_sfx("token_get")

func play_glitch() -> void:
	_play_sfx("glitch")

func play_save() -> void:
	_play_sfx("save")

func play_error() -> void:
	_play_sfx("error")

func play_quest_update() -> void:
	_play_sfx("quest_update")

func play_memory_panel() -> void:
	_play_sfx("memory_panel")

func play_memory_accept() -> void:
	_play_sfx("memory_accept")

func play_door_unlock() -> void:
	_play_sfx("door_unlock")

func play_button_pulse() -> void:
	_play_sfx("button_pulse")

func play_score_blip() -> void:
	_play_sfx("score_blip")

func play_error_buzz() -> void:
	_play_sfx("error_buzz")

func play_success_jingle() -> void:
	_play_sfx("success_jingle")

func play_arcade_ambience() -> void:
	play_music("arcade_hub_grounded")

func stop_arcade_ambience() -> void:
	stop_music()

func play_music(track_id: String, fade_seconds: float = 0.75) -> void:
	if track_id.is_empty():
		stop_music(fade_seconds)
		return
	var base_name := str(MUSIC_TRACKS.get(track_id, track_id))
	if track_id == current_music_id and active_music_player != null and active_music_player.playing:
		return
	var stream := _load_audio(MUSIC_DIR, base_name)
	if stream == null:
		print("AudioManager: missing music track '%s'." % track_id)
		return
	if active_music_player == null or inactive_music_player == null:
		return
	_stop_music_fade_tween()
	current_music_id = track_id
	current_music_stream = stream
	var fade_out_player := active_music_player
	var fade_in_player := inactive_music_player
	fade_in_player.stop()
	fade_in_player.stream = stream
	fade_in_player.volume_db = _silent_volume_db()
	fade_in_player.play()
	active_music_player = fade_in_player
	inactive_music_player = fade_out_player
	if fade_seconds <= 0.0 or not fade_out_player.playing:
		fade_in_player.volume_db = _get_music_volume_db()
		fade_out_player.stop()
		fade_out_player.volume_db = _silent_volume_db()
	else:
		pending_fade_stop_player = fade_out_player
		music_fade_tween = create_tween()
		music_fade_tween.set_parallel(true)
		music_fade_tween.tween_property(fade_in_player, "volume_db", _get_music_volume_db(), fade_seconds)
		music_fade_tween.tween_property(fade_out_player, "volume_db", _silent_volume_db(), fade_seconds)
		music_fade_tween.finished.connect(_on_music_fade_finished)
	print("AudioManager: playing music '%s'." % track_id)

func stop_music(fade_seconds: float = 0.5) -> void:
	_stop_music_fade_tween()
	current_music_id = ""
	current_music_stream = null
	if active_music_player == null:
		return
	if fade_seconds <= 0.0 or not active_music_player.playing:
		_stop_all_music_players()
		return
	pending_fade_stop_player = active_music_player
	music_fade_tween = create_tween()
	music_fade_tween.tween_property(active_music_player, "volume_db", _silent_volume_db(), fade_seconds)
	music_fade_tween.finished.connect(_on_music_fade_finished)

func get_current_music_id() -> String:
	return current_music_id

func play_music_for_context(context_id: String) -> void:
	var track_id := _get_track_id_for_context(context_id)
	if track_id.is_empty():
		return
	play_music(track_id)

func _get_track_id_for_context(context_id: String) -> String:
	match context_id:
		"title":
			return "title_attract_loop"
		"arcade_hub":
			return _get_arcade_hub_music_id()
		"cabinet_row":
			return "cabinet_row_records"
		"snack_alcove":
			return "snack_alcove_vendo"
		"maintenance_hall":
			return "maintenance_hall_static"
		"staff_corridor":
			return "staff_corridor_overloaded"
		"staff_room":
			return "staff_room_reveal_bed"
		"rockbyte_duel":
			return "rockbyte_duel_game"
		"truth_filter":
			return "truth_filter_game"
		"circuit_soda":
			return "circuit_soda_game"
		"static_service_run":
			return "static_service_run_game"
		"maintenance_sync":
			return "maintenance_sync_game"
		"security_tape_assembly":
			return "security_tape_final_night_game"
		"final_night_walk":
			return "security_tape_final_night_game"
		"memory_echo":
			return "memory_echo_conscience"
		"ending":
			return "staff_room_reveal_bed"
		"post_reveal":
			return "post_reveal_roam"
	return ""

func _get_arcade_hub_music_id() -> String:
	if not has_node("/root/GameState"):
		return "arcade_hub_grounded"
	if GameState.post_reveal_roam_unlocked or GameState.twist_reveal_seen:
		return "post_reveal_roam"
	if GameState.memory_signal_level == GameState.MEMORY_SIGNAL_GROUNDED:
		return "arcade_hub_grounded"
	return "arcade_hub_uneasy_fractured"

func _play_sfx(key: String) -> void:
	if sfx_players.is_empty():
		return
	var base_name := str(SFX_NAMES.get(key, key))
	var stream := _load_audio(SFX_DIR, base_name)
	if stream == null:
		return
	var player := sfx_players[next_player_index]
	next_player_index = (next_player_index + 1) % sfx_players.size()
	player.stop()
	player.stream = stream
	player.volume_db = _get_sfx_volume_db()
	player.play()

func _load_audio(folder_path: String, base_name: String) -> AudioStream:
	for extension in AUDIO_EXTENSIONS:
		var file_path := "%s%s%s" % [folder_path, base_name, extension]
		if ResourceLoader.exists(file_path):
			var stream := load(file_path)
			if stream is AudioStream:
				return stream
			print("AudioManager: failed to load audio '%s'." % file_path)
	return null

func _on_music_player_a_finished() -> void:
	_on_music_finished(music_player_a)

func _on_music_player_b_finished() -> void:
	_on_music_finished(music_player_b)

func _on_music_finished(player: AudioStreamPlayer) -> void:
	if not music_loop_enabled:
		return
	if current_music_id.is_empty():
		return
	if player != active_music_player:
		return
	if current_music_stream == null:
		return
	player.play()

func _on_music_fade_finished() -> void:
	if pending_fade_stop_player != null and pending_fade_stop_player != active_music_player:
		pending_fade_stop_player.stop()
		pending_fade_stop_player.volume_db = _silent_volume_db()
	pending_fade_stop_player = null
	music_fade_tween = null

func _on_settings_changed() -> void:
	for player in [music_player_a, music_player_b]:
		if player == null:
			continue
		if player == active_music_player and not current_music_id.is_empty():
			player.volume_db = _get_music_volume_db()
		else:
			player.volume_db = _silent_volume_db()

func _stop_music_fade_tween() -> void:
	if music_fade_tween != null and music_fade_tween.is_valid():
		music_fade_tween.kill()
	music_fade_tween = null
	if pending_fade_stop_player != null and pending_fade_stop_player != active_music_player:
		pending_fade_stop_player.stop()
		pending_fade_stop_player.volume_db = _silent_volume_db()
	pending_fade_stop_player = null

func _stop_all_music_players() -> void:
	for player in [music_player_a, music_player_b]:
		if player == null:
			continue
		player.stop()
		player.stream = null
		player.volume_db = _silent_volume_db()

func _get_sfx_volume_db() -> float:
	var volume := 1.0
	if has_node("/root/GameSettings"):
		volume = float(get_node("/root/GameSettings").get("sfx_volume"))
	return linear_to_db(maxf(volume, 0.001))

func _get_music_volume_db() -> float:
	var volume := 0.75
	if has_node("/root/GameSettings"):
		volume = float(get_node("/root/GameSettings").get("music_volume"))
	return linear_to_db(maxf(volume, 0.001))

func _silent_volume_db() -> float:
	return -80.0
