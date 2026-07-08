extends Node2D

const ROUTE_CUE_SCRIPT := preload("res://scripts/RouteCue.gd")
const AMBIENT_EFFECTS := preload("res://scripts/AmbientSpriteEffects.gd")
const DIALOGUE_POOL := preload("res://scripts/DialoguePool.gd")
const BACKGROUND_ART_PATH := "res://assets/art/maps/maintenance_hall/maintenance_hall_background_640x440.png"

@onready var player: CharacterBody2D = $Player
@onready var background_art: Sprite2D = $BackgroundArt
@onready var ui_layer: Node2D = $UILayer
@onready var dialogue_box: CanvasLayer = $UILayer/DialogueBox
@onready var prompt_label: Label = $UILayer/InteractionPrompt
@onready var prompt_background: ColorRect = $UILayer/InteractionPromptBackground
@onready var sync_door_glow: Polygon2D = $SyncDoorGlow
@onready var quest_notice: CanvasLayer = $QuestNotice

var pending_after_dialogue: Callable = Callable()
var route_cue: Control = null

func _ready() -> void:
	AudioManager.play_music_for_context("maintenance_hall")
	player.interaction_prompt_changed.connect(_on_prompt_changed)
	dialogue_box.dialogue_finished.connect(_on_dialogue_finished)
	_apply_background_art()
	_setup_ambient_sprite_effects()
	_setup_route_cue()
	_apply_spawn_position()
	_on_prompt_changed("")
	_refresh_sync_state()
	call_deferred("_maybe_start_conscience_encounter")
	call_deferred("_maybe_play_completion_anecdote")

func can_open_pause_menu() -> bool:
	return not _dialogue_is_active() and not ConscienceEncounterDirector.is_encounter_active()

func _maybe_start_conscience_encounter() -> void:
	ConscienceEncounterDirector.maybe_start_encounter(self, "after_lost_shift_file")

func _apply_spawn_position() -> void:
	var spawn_id := GameState.consume_pending_spawn_id()
	var marker := get_node_or_null(spawn_id)
	if marker is Marker2D:
		player.global_position = marker.global_position

func _on_prompt_changed(text: String) -> void:
	prompt_label.text = text
	prompt_label.visible = not text.is_empty()
	prompt_background.visible = prompt_label.visible

func _setup_route_cue() -> void:
	route_cue = ROUTE_CUE_SCRIPT.new()
	ui_layer.add_child(route_cue)
	route_cue.call("setup", "maintenance_hall", Vector2(24, 86), 430.0)

func _refresh_route_cue() -> void:
	if route_cue != null and is_instance_valid(route_cue) and route_cue.has_method("refresh"):
		route_cue.call("refresh")

func start_dialogue(lines: Array, after_dialogue: Callable = Callable()) -> void:
	pending_after_dialogue = after_dialogue
	if player and player.has_method("set_control_enabled"):
		player.set_control_enabled(false)
	dialogue_box.start_dialogue(lines)

func _get_gus_lines(key: String, fallback: Array) -> Array:
	return DIALOGUE_POOL.get_lines("gus", key, fallback)

func _get_environment_lines(key: String, fallback: Array) -> Array:
	return DIALOGUE_POOL.get_lines("environment_objects", key, fallback)

func _get_environment_state_lines(object_key: String, fallback: Array) -> Array:
	var state_key := "%s_%s" % [object_key, _get_environment_state_key()]
	var lines := _get_environment_lines(state_key, [])
	if not lines.is_empty():
		return lines
	lines = _get_environment_lines("%s_locked" % object_key, fallback)
	if not lines.is_empty():
		return lines
	lines = _get_environment_lines("%s_grounded" % object_key, fallback)
	if not lines.is_empty():
		return lines
	return fallback

func _get_environment_state_key() -> String:
	GameState.update_memory_signal_from_progress()
	if GameState.twist_reveal_seen or GameState.post_reveal_roam_unlocked:
		return "restored"
	return GameState.get_memory_signal_label().to_lower()

func _combine_dialogue_lines(first_lines: Array, second_lines: Array) -> Array:
	var combined := first_lines.duplicate(true)
	combined.append_array(second_lines.duplicate(true))
	return combined

func _on_dialogue_finished() -> void:
	if pending_after_dialogue.is_valid():
		pending_after_dialogue.call()
		pending_after_dialogue = Callable()
	if player and player.has_method("set_control_enabled"):
		player.set_control_enabled(true)
	_refresh_sync_state()
	_refresh_route_cue()

func _dialogue_is_active() -> bool:
	if dialogue_box == null:
		return false
	return dialogue_box.get("active") == true

func handle_hub_interaction(interactable: Node, _player_node: Node = null) -> void:
	match str(interactable.interactable_kind):
		"gus":
			_handle_gus()
		"maintenance_sync":
			_handle_maintenance_sync()
		"maintenance_note":
			_handle_maintenance_note()
		"staff_record_02":
			_handle_staff_record_02()
		_:
			start_dialogue([{"speaker": "System", "text": "Nothing happens."}])

func _handle_gus() -> void:
	if GameState.post_reveal_roam_unlocked and GameState.witness_gus_heard:
		start_dialogue(_get_gus_lines("static_run_replay_offer", [
			{"speaker": "Gus", "text": "The route is alive and humming, thanks to you."},
			{"speaker": "Gus", "text": "Want to run it again anyway? For fun."},
		]), Callable(self, "_offer_static_run_replay"))
		return
	GameState.gus_intro_seen = true
	if GameState.twist_reveal_seen or GameState.post_reveal_roam_unlocked:
		GameState.gus_post_reveal_seen = true
		var was_completed := _was_witness_route_completed()
		GameState.mark_witness_gus_heard()
		start_dialogue(_get_gus_lines("post_reveal_witness", [
			{"speaker": "Gus", "text": "Employee 04."},
			{"speaker": "Gus", "text": "Yeah. I know."},
			{"speaker": "Gus", "text": "Keep breathing."},
		]), _get_witness_completion_callback(was_completed))
		return
	if not GameState.circuit_soda_completed:
		start_dialogue([
			{"speaker": "Gus", "text": "Maintenance Hall is not ready for you yet."},
			{"speaker": "Gus", "text": "Go let Vendo route whatever counts as your signal first."},
		])
		return
	if not GameState.lost_shift_file_completed and not GameState.maintenance_sync_completed and not GameState.story_puzzle_completed:
		GameState.start_lost_shift_file()
		start_dialogue([
			{"speaker": "Gus", "text": "I can help with the door."},
			{"speaker": "Gus", "text": "But not until you know what shift you are standing in."},
			{"speaker": "Gus", "text": "Find the Lost Shift File first."},
		])
		return
	if GameState.lost_shift_file_completed and not GameState.static_service_run_completed and not GameState.maintenance_sync_completed and not GameState.story_puzzle_completed:
		GameState.gus_lost_shift_comment_seen = true
		var lost_shift_lines := _get_gus_lines("lost_shift_file_phase", [
			{"speaker": "Gus", "text": "The maintenance note is ugly."},
			{"speaker": "Gus", "text": "I saw the Staff Door log the last night wrong. Read it three times."},
			{"speaker": "Gus", "text": "I pretended that was routine work."},
		])
		var static_intro_lines := _get_gus_lines("static_service_run_intro", [
			{"speaker": "Gus", "text": "The file gives me enough to work with."},
			{"speaker": "Gus", "text": "But the maintenance route is dead."},
			{"speaker": "Gus", "text": "Go wake the service power before I ask the door anything important."},
		])
		start_dialogue(_combine_dialogue_lines(lost_shift_lines, static_intro_lines), Callable(self, "_go_to_static_service_run"))
		return
	if GameState.static_service_run_completed and not GameState.gus_static_run_anecdote_seen:
		GameState.gus_static_run_anecdote_seen = true
		start_dialogue(_get_gus_lines("static_service_run_anecdote", [
			{"speaker": "Gus", "text": "Power's back."},
			{"speaker": "Gus", "text": "Door's awake."},
			{"speaker": "Gus", "text": "Now the hard part: making it listen without letting it answer too much."},
		]))
		return
	if not GameState.maintenance_sync_completed and not GameState.story_puzzle_completed:
		GameState.increment_npc_dialogue_count("gus_sync_explained")
		start_dialogue(_get_gus_lines("maintenance_sync_intro", [
			{"speaker": "Gus", "text": "Power's back. Door's listening."},
			{"speaker": "Gus", "text": "I still hate that sentence."},
			{"speaker": "Gus", "text": "The door is arguing with its own lock."},
		]), Callable(self, "_go_to_maintenance_sync"))
		return
	if not GameState.gus_sync_anecdote_seen:
		GameState.gus_sync_anecdote_seen = true
		start_dialogue(_get_gus_lines("maintenance_sync_completion_anecdote", [
			{"speaker": "Gus", "text": "Door's listening now."},
			{"speaker": "Gus", "text": "I do not like doors that listen."},
			{"speaker": "Gus", "text": "But if it opens, it matched you against something in its log."},
			{"speaker": "Gus", "text": "I did not read the log. On purpose."},
		]))
		return
	if GameState.memory_echo_completed and not GameState.twist_reveal_seen:
		start_dialogue([
			{"speaker": "Gus", "text": "Hallway stopped buzzing."},
			{"speaker": "Gus", "text": "That means it is either fixed or waiting."},
			{"speaker": "Gus", "text": "I hate both options."},
		])
		return
	start_dialogue([
		{"speaker": "Gus", "text": "Door still listens."},
		{"speaker": "Gus", "text": "Still hate that."},
	])

func _handle_maintenance_sync() -> void:
	if not GameState.circuit_soda_completed:
		start_dialogue(_get_environment_lines("maintenance_sync_machine_circuit_required", [
			{"speaker": "Maintenance Sync", "text": "SIGNAL ROUTE MISSING."},
			{"speaker": "Maintenance Sync", "text": "CIRCUIT SODA REQUIRED."},
		]))
		return
	if not GameState.lost_shift_file_completed and not GameState.maintenance_sync_completed and not GameState.story_puzzle_completed:
		start_dialogue(_get_environment_lines("maintenance_sync_machine_lost_shift_required", [
			{"speaker": "Maintenance Sync", "text": "MAINTENANCE SYNC LOCKED."},
			{"speaker": "Maintenance Sync", "text": "LOST SHIFT FILE REQUIRED."},
		]))
		return
	if not GameState.static_service_run_completed and not GameState.maintenance_sync_completed and not GameState.story_puzzle_completed:
		start_dialogue(_get_environment_lines("maintenance_sync_machine_static_service_required", [
			{"speaker": "Maintenance Sync", "text": "MAINTENANCE SYNC LOCKED."},
			{"speaker": "Maintenance Sync", "text": "STATIC SERVICE REQUIRED."},
		]))
		return
	if GameState.post_reveal_roam_unlocked and GameState.maintenance_sync_completed:
		start_dialogue(_get_environment_lines("maintenance_sync_machine_replay_offer", [
			{"speaker": "Maintenance Sync", "text": "DOOR AND LOCK IN AGREEMENT."},
			{"speaker": "Maintenance Sync", "text": "RECREATIONAL SYNC AVAILABLE."},
		]), Callable(self, "_offer_maintenance_sync_replay"))
		return
	if GameState.maintenance_sync_completed or GameState.story_puzzle_completed:
		start_dialogue(_get_environment_state_lines("maintenance_sync_machine", [
			{"speaker": "Maintenance Sync", "text": "ACCESS GRANTED."},
			{"speaker": "Maintenance Sync", "text": "EMPLOYEE SIGNAL ACCEPTED."},
		]))
		return
	if GameState.get_npc_dialogue_count("gus_sync_explained") == 0:
		start_dialogue([
			{"speaker": "Player", "text": "This panel is basically Gus's whole personality."},
			{"speaker": "Player", "text": "He would want to run me through it first."},
		])
		return
	start_dialogue(_get_environment_lines("maintenance_sync_machine_fractured", [
		{"speaker": "Maintenance Sync", "text": "TWO SIGNALS DETECTED."},
		{"speaker": "Maintenance Sync", "text": "SYNC REQUIRED."},
	]), Callable(self, "_go_to_maintenance_sync"))

func _go_to_static_service_run() -> void:
	GameState.start_static_service_run()
	GameState.set_pending_spawn_id("Spawn_FromMaintenanceSync")
	SceneChanger.go_to_static_service_run()

func _go_to_maintenance_sync() -> void:
	GameState.start_maintenance_sync()
	GameState.set_pending_spawn_id("Spawn_FromMaintenanceSync")
	SceneChanger.go_to_maintenance_sync()

func _handle_maintenance_note() -> void:
	if not GameState.circuit_soda_completed:
		start_dialogue(_get_environment_lines("maintenance_note_grounded", [
			{"speaker": "Maintenance Note", "text": "Most of the note is routine cleaning nonsense."},
		]))
		return
	var was_completed := GameState.lost_shift_file_completed
	GameState.read_maintenance_note()
	var lines := _get_environment_state_lines("maintenance_note", [
		{"speaker": "Maintenance Note", "text": "MAINTENANCE NOTE"},
		{"speaker": "Maintenance Note", "text": "Staff Door reported two signals after closing."},
		{"speaker": "Maintenance Note", "text": "One signal entered."},
		{"speaker": "Maintenance Note", "text": "One signal remained."},
		{"speaker": "Maintenance Note", "text": "Gus note: I do not get paid enough for doors with opinions."},
	])
	lines.append_array(_get_lost_shift_completion_lines())
	var after_dialogue := Callable(self, "_after_lost_shift_file_completed") if not was_completed and GameState.lost_shift_file_completed else Callable()
	start_dialogue(lines, after_dialogue)

func _handle_staff_record_02() -> void:
	if not GameState.lying_cabinets_completed:
		start_dialogue(_get_environment_lines("staff_records_locked", [
			{"speaker": "Staff Record", "text": "The maintenance record is still sealed."},
		]))
		return
	var was_completed := GameState.staff_records_chain_completed
	GameState.read_staff_record_02()
	var lines := _get_environment_state_lines("staff_records", [
		{"speaker": "Staff Record", "text": "MAINTENANCE WARNING"},
		{"speaker": "Staff Record", "text": "Door responds to two signatures."},
		{"speaker": "Staff Record", "text": "One physical. One stored."},
	])
	lines.append_array(_get_staff_records_completion_lines())
	var after_dialogue := Callable(self, "_show_staff_records_complete_notice") if not was_completed and GameState.staff_records_chain_completed else Callable()
	start_dialogue(lines, after_dialogue)

func _get_lost_shift_completion_lines() -> Array:
	if not GameState.lost_shift_file_completed:
		return []
	return [
		{"speaker": "Quest", "text": "LOST SHIFT FILE COMPLETE"},
		{"speaker": "Quest", "text": "A redacted staff number was assigned to Cabinet shutdown."},
	]

func _show_lost_shift_complete_notice() -> void:
	if quest_notice and quest_notice.has_method("show_custom_notification"):
		quest_notice.call(
			"show_custom_notification",
			"QUEST COMPLETE",
			"LOST SHIFT FILE COMPLETE",
			"A redacted staff number was assigned to Cabinet shutdown."
		)

func _after_lost_shift_file_completed() -> void:
	_show_lost_shift_complete_notice()
	call_deferred("_maybe_play_midpoint_turn")

func _maybe_play_midpoint_turn() -> void:
	if not GameState.lost_shift_file_completed or GameState.midpoint_turn_seen:
		return
	GameState.midpoint_turn_seen = true
	start_dialogue([
		{"speaker": "Player", "text": "Three records. One shift folded shut and never filed."},
		{"speaker": "Player", "text": "I keep telling myself I am looking for the way out of here."},
		{"speaker": "Player", "text": "But the front door was never the locked one."},
		{"speaker": "Player", "text": "Whatever stayed behind on the last night is waiting past the Staff Door."},
		{"speaker": "Player", "text": "I am done trying to leave. I want to look at it."},
		{"speaker": "Player", "text": "Mira is still at her counter. She deserves to hear what I found... or I can carry it alone and keep working."},
	])

func _get_staff_records_completion_lines() -> Array:
	if not GameState.staff_records_chain_completed:
		return []
	return [
		{"speaker": "Quest", "text": "STAFF RECORDS CHAIN COMPLETE"},
		{"speaker": "Quest", "text": "The arcade knew the number before it knew the name."},
	]

func _show_staff_records_complete_notice() -> void:
	if quest_notice and quest_notice.has_method("show_custom_notification"):
		quest_notice.call(
			"show_custom_notification",
			"QUEST COMPLETE",
			"STAFF RECORDS CHAIN COMPLETE",
			"The arcade knew the number before it knew the name."
		)

func _was_witness_route_completed() -> bool:
	return GameState.witness_route_completed or GameState.post_reveal_witness_route_completed

func _get_witness_completion_callback(was_completed: bool) -> Callable:
	if not was_completed and _was_witness_route_completed():
		return Callable(self, "_show_witness_route_complete_notice")
	return Callable()

func _show_witness_route_complete_notice() -> void:
	if quest_notice and quest_notice.has_method("show_custom_notification"):
		quest_notice.call(
			"show_custom_notification",
			"QUEST COMPLETE",
			"POST-REVEAL WITNESSES COMPLETE",
			"Pixel Haven remembers you in pieces.\nTogether, they almost make a person."
		)

func _apply_background_art() -> void:
	var loaded := _apply_sprite_texture(background_art, BACKGROUND_ART_PATH)
	for placeholder in [$Background, $UtilityWall, $GusPlaceholder, $SyncDoorPlaceholder]:
		if placeholder is CanvasItem:
			placeholder.visible = not loaded

func _setup_ambient_sprite_effects() -> void:
	AMBIENT_EFFECTS.create_layer(self, ui_layer, [
		{
			"name": "WarningLightLeft",
			"position": Vector2(230, 78),
			"scale": Vector2(1.4, 1.4),
			"effect_type": "blink",
			"speed": 0.45,
			"intensity": 0.08,
			"sprite_sheet_path": AMBIENT_EFFECTS.WARNING_LIGHT,
			"sprite_alpha": 0.76,
		},
		{
			"name": "WarningLightRight",
			"position": Vector2(404, 78),
			"scale": Vector2(1.4, 1.4),
			"effect_type": "blink",
			"speed": 0.52,
			"intensity": 0.08,
			"sprite_sheet_path": AMBIENT_EFFECTS.WARNING_LIGHT,
			"sprite_alpha": 0.74,
		},
		{
			"name": "SyncDoorLockBlink",
			"position": Vector2(496, 136),
			"scale": Vector2(1.55, 1.55),
			"effect_type": "blink",
			"speed": 0.62,
			"only_when_memory_signal_at_least": 2,
			"sprite_sheet_path": AMBIENT_EFFECTS.STAFF_LOCK_BLINK,
			"sprite_alpha": 0.8,
		},
		{
			"name": "SyncDoorScanline",
			"position": Vector2(478, 124),
			"scale": Vector2(1.7, 1.7),
			"effect_type": "scanline_pulse",
			"speed": 0.68,
			"sprite_sheet_path": AMBIENT_EFFECTS.SCANLINE_BAR,
			"sprite_frame_size": Vector2i(32, 8),
			"sprite_alpha": 0.72,
			"sprite_modulate": Color(0.7, 1.0, 0.82, 1.0),
		},
		{
			"name": "MaintenanceSparkA",
			"position": Vector2(254, 146),
			"scale": Vector2(1.25, 1.25),
			"effect_type": "random_screen_flash",
			"speed": 0.82,
			"sprite_sheet_path": AMBIENT_EFFECTS.STATIC_SPARK,
			"sprite_alpha": 0.64,
		},
	])

func _refresh_sync_state() -> void:
	if sync_door_glow == null:
		return
	sync_door_glow.visible = GameState.circuit_soda_completed and GameState.lost_shift_file_completed and GameState.static_service_run_completed and not GameState.story_puzzle_completed

func _apply_sprite_texture(sprite_node: Sprite2D, path: String) -> bool:
	if sprite_node == null:
		return false
	sprite_node.visible = false
	sprite_node.texture = null
	if path.is_empty() or not ResourceLoader.exists(path):
		return false
	var resource := load(path)
	if not resource is Texture2D:
		return false
	sprite_node.texture = resource
	sprite_node.visible = true
	return true

func _maybe_play_completion_anecdote() -> void:
	if _dialogue_is_active() or ConscienceEncounterDirector.is_encounter_active():
		return
	if GameState.consume_postgame_replay_return("maintenance_sync"):
		start_dialogue(_get_environment_lines("maintenance_sync_machine_replay_return", [
			{"speaker": "Maintenance Sync", "text": "SYNC COMPLETE. AGREEMENT MAINTAINED."},
			{"speaker": "Maintenance Sync", "text": "THE DOOR SAYS THANK YOU. IN DOOR."},
		]))
		return
	if GameState.consume_postgame_replay_return("static_service_run"):
		start_dialogue(_get_gus_lines("static_run_replay_return", [
			{"speaker": "Gus", "text": "Power held the whole way down."},
			{"speaker": "Gus", "text": "That is not forgetting. That is the good version of remembering."},
		]))
		return
	if GameState.maintenance_sync_completed and not GameState.gus_sync_anecdote_seen:
		GameState.gus_sync_anecdote_seen = true
		start_dialogue(_get_gus_lines("maintenance_sync_completion_anecdote", [
			{"speaker": "Gus", "text": "Door's listening now."},
			{"speaker": "Gus", "text": "It matched you against something in its log. I did not read it. On purpose."},
		]))
		return
	if GameState.static_service_run_completed and not GameState.gus_static_run_anecdote_seen:
		GameState.gus_static_run_anecdote_seen = true
		start_dialogue(_get_gus_lines("static_service_run_anecdote", [
			{"speaker": "Gus", "text": "Power's back. Door's awake."},
			{"speaker": "Gus", "text": "Still, you did good. The hum is cleaner now."},
		]))

func _offer_maintenance_sync_replay() -> void:
	PostGameReplay.open_offer(ui_layer, player, "Sync the door again?", "maintenance_sync", Callable(self, "_go_to_maintenance_sync"))

func _offer_static_run_replay() -> void:
	PostGameReplay.open_offer(ui_layer, player, "Run the service route again?", "static_service_run", Callable(self, "_go_to_static_service_run"))
