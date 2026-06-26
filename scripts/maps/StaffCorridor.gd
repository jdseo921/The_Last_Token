extends Node2D

const ROUTE_CUE_SCRIPT := preload("res://scripts/RouteCue.gd")
const AMBIENT_EFFECTS := preload("res://scripts/AmbientSpriteEffects.gd")
const DIALOGUE_POOL := preload("res://scripts/DialoguePool.gd")

@onready var player: CharacterBody2D = $Player
@onready var ui_layer: Node2D = $UILayer
@onready var dialogue_box: CanvasLayer = $UILayer/DialogueBox
@onready var prompt_label: Label = $UILayer/InteractionPrompt
@onready var prompt_background: ColorRect = $UILayer/InteractionPromptBackground
@onready var quest_notice: CanvasLayer = $QuestNotice

var pending_after_dialogue: Callable = Callable()
var route_cue: Control = null

func _ready() -> void:
	AudioManager.play_music_for_context("staff_corridor")
	player.interaction_prompt_changed.connect(_on_prompt_changed)
	dialogue_box.dialogue_finished.connect(_on_dialogue_finished)
	_setup_ambient_sprite_effects()
	_setup_route_cue()
	_apply_spawn_position()
	_on_prompt_changed("")
	call_deferred("_maybe_start_conscience_encounter")

func can_open_pause_menu() -> bool:
	return not _dialogue_is_active() and not ConscienceEncounterDirector.is_encounter_active()

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
	route_cue.call("setup", "staff_corridor", Vector2(24, 86), 430.0)

func _refresh_route_cue() -> void:
	if route_cue != null and is_instance_valid(route_cue) and route_cue.has_method("refresh"):
		route_cue.call("refresh")

func start_dialogue(lines: Array, after_dialogue: Callable = Callable()) -> void:
	pending_after_dialogue = after_dialogue
	if player and player.has_method("set_control_enabled"):
		player.set_control_enabled(false)
	dialogue_box.start_dialogue(lines)

func _on_dialogue_finished() -> void:
	if pending_after_dialogue.is_valid():
		pending_after_dialogue.call()
		pending_after_dialogue = Callable()
	if player and player.has_method("set_control_enabled"):
		player.set_control_enabled(true)
	_refresh_route_cue()

func _dialogue_is_active() -> bool:
	if dialogue_box == null:
		return false
	return dialogue_box.get("active") == true

func _get_mr_byte_lines(key: String, fallback: Array) -> Array:
	return DIALOGUE_POOL.get_lines("mr_byte", key, fallback)

func _get_staff_door_lines(key: String, fallback: Array) -> Array:
	return DIALOGUE_POOL.get_lines("staff_door", key, fallback)

func _get_staff_door_sequential_lines(key: String, fallback: Array) -> Array:
	return DIALOGUE_POOL.get_sequential_set("staff_door", key, key, fallback)

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
	return fallback

func _get_environment_state_key() -> String:
	GameState.update_memory_signal_from_progress()
	if _is_post_reveal():
		return "restored"
	return GameState.get_memory_signal_label().to_lower()

func handle_hub_interaction(interactable: Node, _player_node: Node = null) -> void:
	match str(interactable.interactable_kind):
		"security_tape":
			_handle_security_tape()
		"final_night_walk":
			_handle_final_night_walk()
		"memory_echo":
			_handle_memory_echo()
		"staff_room_door":
			_handle_staff_room_door()
		"staff_record_03":
			_handle_staff_record_03()
		_:
			start_dialogue([{"speaker": "System", "text": "Nothing happens."}])

func _handle_memory_echo() -> void:
	if not GameState.maintenance_sync_completed:
		start_dialogue(_get_environment_lines("memory_echo_object_maintenance_required", [
			{"speaker": "Memory Echo", "text": "SIGNAL TOO QUIET."},
			{"speaker": "Memory Echo", "text": "MAINTENANCE SYNC REQUIRED."},
		]))
		return
	if not GameState.security_tape_assembly_completed:
		start_dialogue(_get_environment_lines("memory_echo_object_security_tape_required", [
			{"speaker": "Memory Echo", "text": "MEMORY ECHO LOCKED."},
			{"speaker": "Memory Echo", "text": "SECURITY TAPE REQUIRED."},
		]))
		return
	if not GameState.final_night_walk_completed:
		start_dialogue(_get_environment_lines("memory_echo_object_final_night_required", [
			{"speaker": "Memory Echo", "text": "MEMORY ECHO LOCKED."},
			{"speaker": "Memory Echo", "text": "FINAL NIGHT WALK REQUIRED."},
		]))
		return
	if not GameState.memory_echo_completed:
		if not GameState.memory_echo_started:
			GameState.start_memory_echo()
			start_dialogue(_get_environment_lines("memory_echo_object_overloaded", [
				{"speaker": "Memory System", "text": "FINAL NIGHT ROUTE STABLE."},
				{"speaker": "Memory System", "text": "MEMORY ECHO AVAILABLE."},
				{"speaker": "Memory System", "text": "IDENTITY CONFLICT APPROACHING READABLE RANGE."},
			]), Callable(self, "_go_to_memory_echo"))
			return
		_go_to_memory_echo()
		return
	if not GameState.memory_echo_anecdote_seen:
		GameState.memory_echo_anecdote_seen = true
		start_dialogue(_get_environment_lines("memory_echo_object_restored", [
			{"speaker": "Memory Echo", "text": "Echo stabilized."},
			{"speaker": "Memory Echo", "text": "The arcade stops arguing with itself."},
			{"speaker": "Memory Echo", "text": "That might be worse."},
		]))
		return
	start_dialogue(_get_environment_state_lines("memory_echo_object", [
		{"speaker": "Memory Echo", "text": "Echo stable."},
		{"speaker": "Memory Echo", "text": "Quiet is not always better."},
	]))

func _handle_security_tape() -> void:
	if not GameState.maintenance_sync_completed:
		start_dialogue(_get_environment_lines("security_tape_terminal_locked", [
			{"speaker": "Staff Door", "text": "SECURITY TAPE LOCKED."},
			{"speaker": "Staff Door", "text": "MAINTENANCE SYNC REQUIRED."},
		]))
		return
	if GameState.security_tape_assembly_completed:
		var completed_lines := _get_environment_lines("security_tape_terminal_restored", [
			{"speaker": "Security Tape", "text": "TAPE ORDER RESTORED."},
			{"speaker": "Security Tape", "text": "FRAMES NOW FORM A STAFF ROUTE."},
			{"speaker": "Security Tape", "text": "FINAL NIGHT WALK REQUIRED."},
		])
		completed_lines.append_array(_get_mr_byte_lines("security_tape_completion_anecdote", [
			{"speaker": "Mr. Byte", "text": "Tape order restored."},
			{"speaker": "Mr. Byte", "text": "Sequence now describes a route."},
			{"speaker": "Mr. Byte", "text": "It does not yet describe the cause."},
		]))
		completed_lines.append_array(_get_staff_door_lines("final_night_walk_required", [
			{"speaker": "Staff Door", "text": "FINAL NIGHT WALK REQUIRED."},
		]))
		start_dialogue(completed_lines)
		return
	if not GameState.security_tape_assembly_started:
		GameState.start_security_tape_assembly()
		var start_lines := _get_environment_lines("security_tape_terminal_overloaded", [
			{"speaker": "Security Tape", "text": "SECURITY TAPE DAMAGED."},
			{"speaker": "Security Tape", "text": "RESTORE SEQUENCE."},
		])
		start_lines.append_array(_get_mr_byte_lines("security_tape_support", [
			{"speaker": "Mr. Byte", "text": "Security tape fragments detected."},
			{"speaker": "Mr. Byte", "text": "Recommended action: restore order before restoring identity."},
		]))
		start_dialogue(start_lines, Callable(self, "_go_to_security_tape_assembly"))
		return
	_go_to_security_tape_assembly()

func _handle_final_night_walk() -> void:
	if not GameState.security_tape_assembly_completed:
		start_dialogue(_get_environment_lines("final_night_walk_terminal_locked", [
			{"speaker": "Memory System", "text": "FINAL NIGHT WALK LOCKED."},
			{"speaker": "Memory System", "text": "SECURITY TAPE REQUIRED."},
		]))
		return
	if GameState.final_night_walk_completed:
		if not GameState.staff_door_final_walk_anecdote_seen:
			GameState.staff_door_final_walk_anecdote_seen = true
			start_dialogue(_get_environment_lines("final_night_walk_terminal_restored", [
				{"speaker": "Staff Door", "text": "ROUTE ACCEPTED."},
				{"speaker": "Staff Door", "text": "FINAL NIGHT SEQUENCE STABILIZED."},
				{"speaker": "Staff Door", "text": "ONE WALKED IN."},
				{"speaker": "Staff Door", "text": "TWO SIGNALS ANSWERED."},
			]))
			return
		start_dialogue(_get_environment_lines("final_night_walk_terminal_restored", [
			{"speaker": "Staff Door", "text": "FINAL NIGHT ROUTE STABLE."},
			{"speaker": "Staff Door", "text": "MEMORY ECHO READY."},
		]))
		return
	if not GameState.final_night_walk_started:
		GameState.start_final_night_walk()
		start_dialogue(_get_environment_lines("final_night_walk_terminal_overloaded", [
			{"speaker": "Staff Door", "text": "TAPE ORDER RESTORED."},
			{"speaker": "Staff Door", "text": "ROUTE MEMORY UNSTABLE."},
			{"speaker": "Staff Door", "text": "WALK THE FINAL NIGHT."},
		]), Callable(self, "_go_to_final_night_walk"))
		return
	_go_to_final_night_walk()

func _go_to_security_tape_assembly() -> void:
	GameState.set_pending_spawn_id("Spawn_FromSecurityTape")
	SceneChanger.go_to_security_tape_assembly()

func _go_to_final_night_walk() -> void:
	GameState.set_pending_spawn_id("Spawn_FromFinalNightWalk")
	SceneChanger.go_to_final_night_walk()

func _go_to_memory_echo() -> void:
	GameState.set_pending_spawn_id("Spawn_FromMemoryEcho")
	SceneChanger.go_to_memory_echo()

func _handle_staff_room_door() -> void:
	if _is_post_reveal():
		start_dialogue(_get_staff_door_lines("post_reveal_stable", [
			{"speaker": "Staff Room Door", "text": "RESTORE PLAYBACK COMPLETE."},
			{"speaker": "Staff Room Door", "text": "RETURN NOT REQUIRED."},
		]))
		return
	if not GameState.memory_echo_completed:
		start_dialogue(_get_staff_door_sequential_lines("memory_echo_required", [
			{"speaker": "Staff Room Door", "text": "RESTORE PLAYBACK LOCKED."},
			{"speaker": "Staff Room Door", "text": "MEMORY ECHO REQUIRED."},
		]))
		return
	start_dialogue(_get_staff_door_lines("staff_room_available", [
		{"speaker": "Staff Room Door", "text": "RESTORE PLAYBACK AVAILABLE."},
		{"speaker": "Staff Room Door", "text": "ENTER STAFF ROOM?"},
	]), Callable(SceneChanger, "go_to_staff_room"))

func _handle_staff_record_03() -> void:
	if not GameState.lying_cabinets_completed:
		start_dialogue(_get_environment_lines("staff_records_locked", [
			{"speaker": "Staff Record", "text": "The corridor log has not finished restoring."},
		]))
		return
	var was_completed := GameState.staff_records_chain_completed
	GameState.read_staff_record_03()
	var lines := _get_environment_state_lines("staff_records", [
		{"speaker": "Staff Record", "text": "STAFF CORRIDOR LOG"},
		{"speaker": "Staff Record", "text": "Employee number sealed until Staff Room playback."},
		{"speaker": "Staff Record", "text": "Name field unavailable."},
	])
	lines.append_array(_get_mr_byte_lines("staff_records_chain", [
		{"speaker": "Mr. Byte", "text": "Record fragment accepted."},
		{"speaker": "Mr. Byte", "text": "Identity checksum incomplete."},
		{"speaker": "Mr. Byte", "text": "Additional staff records required."},
	]))
	lines.append_array(_get_staff_records_completion_lines())
	var after_dialogue := Callable(self, "_show_staff_records_complete_notice") if not was_completed and GameState.staff_records_chain_completed else Callable()
	start_dialogue(lines, after_dialogue)

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

func _setup_ambient_sprite_effects() -> void:
	AMBIENT_EFFECTS.create_layer(self, ui_layer, [
		{
			"name": "StaffDoorLockBlink",
			"position": Vector2(338, 86),
			"scale": Vector2(1.55, 1.55),
			"effect_type": "blink",
			"speed": 0.6,
			"sprite_sheet_path": AMBIENT_EFFECTS.STAFF_LOCK_BLINK,
			"sprite_alpha": 0.8,
		},
		{
			"name": "MemoryEchoWispA",
			"position": Vector2(292, 190),
			"scale": Vector2(1.55, 1.55),
			"effect_type": "dust_mote_drift",
			"speed": 0.44,
			"intensity": 0.18,
			"sprite_sheet_path": AMBIENT_EFFECTS.MEMORY_WISP,
			"sprite_frame_size": Vector2i(24, 16),
			"sprite_alpha": 0.76,
		},
		{
			"name": "MemoryEchoWispB",
			"position": Vector2(360, 238),
			"scale": Vector2(1.35, 1.35),
			"effect_type": "dust_mote_drift",
			"speed": 0.58,
			"intensity": 0.14,
			"sprite_sheet_path": AMBIENT_EFFECTS.MEMORY_WISP,
			"sprite_frame_size": Vector2i(24, 16),
			"sprite_alpha": 0.62,
			"sprite_modulate": Color(1.0, 0.76, 1.0, 1.0),
		},
		{
			"name": "SecurityTapeScanline",
			"position": Vector2(320, 309),
			"scale": Vector2(2.25, 1.7),
			"effect_type": "scanline_pulse",
			"speed": 0.74,
			"active_flag_optional": "maintenance_sync_completed",
			"sprite_sheet_path": AMBIENT_EFFECTS.SCANLINE_BAR,
			"sprite_frame_size": Vector2i(32, 8),
			"sprite_alpha": 0.72,
		},
		{
			"name": "FinalNightArrow",
			"position": Vector2(444, 310),
			"scale": Vector2(1.35, 1.35),
			"effect_type": "blink",
			"speed": 0.68,
			"active_flag_optional": "security_tape_assembly_completed",
			"sprite_sheet_path": AMBIENT_EFFECTS.NEON_ARROW,
			"sprite_alpha": 0.7,
			"sprite_modulate": Color(0.98, 0.78, 1.0, 1.0),
		},
		{
			"name": "MemoryEchoReadyDot",
			"position": Vector2(320, 260),
			"scale": Vector2(1.25, 1.25),
			"effect_type": "glow_pulse",
			"speed": 0.76,
			"active_flag_optional": "final_night_walk_completed",
			"sprite_sheet_path": AMBIENT_EFFECTS.BLINK_DOT,
			"sprite_alpha": 0.72,
		},
		{
			"name": "HubReturnArrow",
			"position": Vector2(34, 360),
			"rotation": PI,
			"scale": Vector2(1.35, 1.35),
			"effect_type": "blink",
			"speed": 0.62,
			"sprite_sheet_path": AMBIENT_EFFECTS.NEON_ARROW,
			"sprite_alpha": 0.62,
		},
	])

func _is_post_reveal() -> bool:
	return GameState.post_reveal_roam_unlocked or GameState.twist_reveal_seen

func _maybe_start_conscience_encounter() -> void:
	ConscienceEncounterDirector.maybe_start_encounter(self, "after_final_night_walk")
