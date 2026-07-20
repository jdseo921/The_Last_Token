extends Node2D

const ROUTE_CUE_SCRIPT := preload("res://scripts/RouteCue.gd")
const AMBIENT_EFFECTS := preload("res://scripts/AmbientSpriteEffects.gd")
const DIALOGUE_POOL := preload("res://scripts/DialoguePool.gd")
const BACKGROUND_ART_PATH := "res://assets/art/maps/staff_corridor/staff_corridor_background_640x440.png"
const BACKGROUND_PLACEHOLDERS := ["Background", "CorridorPath", "MemoryEchoPlaceholder", "SecurityTapePlaceholder", "FinalNightWalkPlaceholder", "StaffRoomDoorPlaceholder"]

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
	_apply_background_art()
	player.interaction_prompt_changed.connect(_on_prompt_changed)
	dialogue_box.dialogue_finished.connect(_on_dialogue_finished)
	_setup_ambient_sprite_effects()
	_setup_route_cue()
	_apply_spawn_position()
	_on_prompt_changed("")
	call_deferred("_maybe_play_completion_anecdote")

func can_open_pause_menu() -> bool:
	return not _dialogue_is_active() and not ConscienceEncounterDirector.is_encounter_active()

func _apply_background_art() -> void:
	if not ResourceLoader.exists(BACKGROUND_ART_PATH):
		return
	var tex := load(BACKGROUND_ART_PATH)
	if not tex is Texture2D:
		return
	var spr := Sprite2D.new()
	spr.name = "BackgroundArt"
	spr.texture = tex
	spr.centered = false
	spr.position = Vector2.ZERO
	add_child(spr)
	move_child(spr, 0)
	for placeholder_name in BACKGROUND_PLACEHOLDERS:
		var node := get_node_or_null(NodePath(placeholder_name))
		if node is CanvasItem:
			(node as CanvasItem).visible = false

func _apply_spawn_position() -> void:
	var spawn_id := GameState.consume_pending_spawn_id()
	# Coming back from a minigame in this room: stand exactly where we left.
	var back: Variant = GameState.consume_return_point(scene_file_path)
	if back != null:
		player.global_position = back
		return
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
	if GameState.post_reveal_roam_unlocked and GameState.memory_echo_completed and GameState.get_npc_dialogue_count("reel_witness") > 0:
		start_dialogue(DIALOGUE_POOL.get_lines("reel", "memory_echo_replay_offer", [
			{"speaker": "Reel", "text": "The last set plays clean now, pal."},
			{"speaker": "Reel", "text": "Want to hear it again? Encores are the only reruns worth keeping."},
		]), Callable(self, "_offer_memory_echo_replay"))
		return
	if not GameState.memory_echo_completed:
		if not GameState.memory_echo_started:
			GameState.start_memory_echo()
			var echo_intro: Array = []
			if GameState.get_npc_dialogue_count("reel_first_meeting") == 0:
				GameState.increment_npc_dialogue_count("reel_first_meeting")
				echo_intro = DIALOGUE_POOL.get_lines("reel", "first_meeting", [])
			echo_intro.append_array(DIALOGUE_POOL.get_lines("reel", "memory_echo_intro", []))
			echo_intro.append_array(_get_environment_lines("memory_echo_object_overloaded", [
				{"speaker": "Memory System", "text": "FINAL NIGHT ROUTE STABLE."},
				{"speaker": "Memory System", "text": "MEMORY ECHO AVAILABLE."},
				{"speaker": "Memory System", "text": "IDENTITY CONFLICT APPROACHING READABLE RANGE."},
			]))
			start_dialogue(echo_intro, Callable(self, "_go_to_memory_echo"))
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
	var echo_lines := _get_environment_state_lines("memory_echo_object", [
		{"speaker": "Memory Echo", "text": "Echo stable."},
		{"speaker": "Memory Echo", "text": "Quiet is not always better."},
	])
	if _is_post_reveal() and GameState.get_npc_dialogue_count("reel_witness") == 0:
		GameState.increment_npc_dialogue_count("reel_witness")
		echo_lines.append_array(DIALOGUE_POOL.get_lines("reel", "post_reveal_witness", []))
	start_dialogue(echo_lines)

func _handle_security_tape() -> void:
	if not GameState.maintenance_sync_completed:
		start_dialogue(_get_environment_lines("security_tape_terminal_locked", [
			{"speaker": "Staff Door", "text": "SECURITY TAPE LOCKED."},
			{"speaker": "Staff Door", "text": "MAINTENANCE SYNC REQUIRED."},
		]))
		return
	if GameState.post_reveal_roam_unlocked and GameState.security_tape_assembly_completed and GameState.get_npc_dialogue_count("coily_witness") > 0:
		start_dialogue(DIALOGUE_POOL.get_lines("coily", "security_tape_replay_offer", [
			{"speaker": "Coily", "text": "Movie night, pal? Every frame belongs now."},
			{"speaker": "Coily", "text": "I like this cut better. Everybody walks out of it."},
		]), Callable(self, "_offer_security_tape_replay"))
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
		if GameState.get_npc_dialogue_count("coily_tape_completion") == 0:
			GameState.increment_npc_dialogue_count("coily_tape_completion")
			completed_lines.append_array(DIALOGUE_POOL.get_lines("coily", "security_tape_completion", []))
		if _is_post_reveal() and GameState.get_npc_dialogue_count("coily_witness") == 0:
			GameState.increment_npc_dialogue_count("coily_witness")
			completed_lines.append_array(DIALOGUE_POOL.get_lines("coily", "post_reveal_witness", []))
		start_dialogue(completed_lines)
		return
	if not GameState.security_tape_assembly_started:
		GameState.start_security_tape_assembly()
		var start_lines: Array = []
		if GameState.get_npc_dialogue_count("coily_first_meeting") == 0:
			GameState.increment_npc_dialogue_count("coily_first_meeting")
			start_lines = DIALOGUE_POOL.get_lines("coily", "first_meeting", [])
		start_lines.append_array(DIALOGUE_POOL.get_lines("coily", "security_tape_intro", []))
		start_lines.append_array(_get_environment_lines("security_tape_terminal_overloaded", [
			{"speaker": "Security Tape", "text": "SECURITY TAPE DAMAGED."},
			{"speaker": "Security Tape", "text": "RESTORE SEQUENCE."},
		]))
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
	if GameState.post_reveal_roam_unlocked and GameState.final_night_walk_completed:
		start_dialogue(_get_staff_door_lines("final_night_walk_replay_offer", [
			{"speaker": "Staff Door", "text": "FINAL NIGHT ROUTE: ARCHIVED."},
			{"speaker": "Staff Door", "text": "WALK AVAILABLE AS MEMORIAL."},
		]), Callable(self, "_offer_final_night_walk_replay"))
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
		var fnw_lines := _get_environment_lines("final_night_walk_terminal_overloaded", [
			{"speaker": "Staff Door", "text": "TAPE ORDER RESTORED."},
			{"speaker": "Staff Door", "text": "ROUTE MEMORY UNSTABLE."},
			{"speaker": "Staff Door", "text": "WALK THE FINAL NIGHT."},
		])
		if GameState.get_npc_dialogue_count("coily_fnw_accent") == 0:
			GameState.increment_npc_dialogue_count("coily_fnw_accent")
			fnw_lines.append_array(DIALOGUE_POOL.get_lines("coily", "final_night_walk_accent", []))
		start_dialogue(fnw_lines, Callable(self, "_go_to_final_night_walk"))
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
	if not GameState.security_tape_assembly_completed:
		start_dialogue(_get_staff_door_sequential_lines("security_tape_required", [
			{"speaker": "Staff Room Door", "text": "STAFF ACCESS LOCKED."},
			{"speaker": "Staff Room Door", "text": "REQUIRED: SECURITY TAPE ASSEMBLY."},
		]))
		return
	if not GameState.final_night_walk_completed:
		start_dialogue(_get_staff_door_sequential_lines("final_night_walk_required", [
			{"speaker": "Staff Room Door", "text": "RESTORE PLAYBACK LOCKED."},
			{"speaker": "Staff Room Door", "text": "REQUIRED: FINAL NIGHT WALK."},
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
			"name": "MemoryEchoBeacon",
			"position": Vector2(320, 228),
			"scale": Vector2(1.9, 1.9),
			"effect_type": "glow_pulse",
			"speed": 0.5,
			"sprite_sheet_path": AMBIENT_EFFECTS.MEMORY_WISP,
			"sprite_frame_size": Vector2i(24, 16),
			"sprite_alpha": 0.85,
			"sprite_modulate": Color(0.6, 0.98, 1.0, 1.0),
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
			"name": "MemoryEchoReadyDot",
			"position": Vector2(320, 260),
			"scale": Vector2(1.25, 1.25),
			"effect_type": "glow_pulse",
			"speed": 0.76,
			"active_flag_optional": "final_night_walk_completed",
			"sprite_sheet_path": AMBIENT_EFFECTS.BLINK_DOT,
			"sprite_alpha": 0.72,
		},
	])

func _is_post_reveal() -> bool:
	return GameState.post_reveal_roam_unlocked or GameState.twist_reveal_seen

func _maybe_start_conscience_encounter() -> void:
	if not ConscienceEncounterDirector.maybe_start_encounter(self, "after_final_night_walk", Callable(self, "_maybe_play_completion_anecdote")):
		_maybe_play_completion_anecdote()

func _maybe_play_completion_anecdote() -> void:
	if _dialogue_is_active() or ConscienceEncounterDirector.is_encounter_active():
		return
	if GameState.consume_postgame_replay_return("security_tape"):
		start_dialogue(DIALOGUE_POOL.get_lines("coily", "security_tape_replay_return", [
			{"speaker": "Coily", "text": "And it still ends okay! I checked every frame twice."},
			{"speaker": "Coily", "text": "Come back any time. I will keep the reel warm for you, 04."},
		]))
		return
	if GameState.consume_postgame_replay_return("final_night_walk"):
		start_dialogue(_get_staff_door_lines("final_night_walk_replay_return", [
			{"speaker": "Staff Door", "text": "WALK COMPLETE. ROUTE UNCHANGED."},
			{"speaker": "Staff Door", "text": "SOME DOORS STAY OPEN. THIS IS ONE."},
		]))
		return
	if GameState.consume_postgame_replay_return("memory_echo"):
		start_dialogue(DIALOGUE_POOL.get_lines("reel", "memory_echo_replay_return", [
			{"speaker": "Reel", "text": "Same songs. Lighter key."},
			{"speaker": "Reel", "text": "That is what healing sounds like on tape."},
		]))
		return
	if GameState.memory_echo_completed and not GameState.twist_reveal_seen and GameState.get_npc_dialogue_count("reel_echo_completion") == 0:
		GameState.increment_npc_dialogue_count("reel_echo_completion")
		start_dialogue(DIALOGUE_POOL.get_lines("reel", "memory_echo_completion", [
			{"speaker": "Reel", "text": "That is your setlist. Rough, honest, yours."},
			{"speaker": "Reel", "text": "The next room is going to try to make you forget the tune."},
		]))
		return
	if GameState.security_tape_assembly_completed and not GameState.final_night_walk_completed and GameState.get_npc_dialogue_count("coily_tape_completion") == 0:
		GameState.increment_npc_dialogue_count("coily_tape_completion")
		start_dialogue(DIALOGUE_POOL.get_lines("coily", "security_tape_completion", [
			{"speaker": "Coily", "text": "You put the night back in order, pal."},
			{"speaker": "Coily", "text": "One frame still does not belong. Keep noticing it."},
		]))

func _offer_security_tape_replay() -> void:
	PostGameReplay.open_offer(ui_layer, player, "Restore the tape again?", "security_tape", Callable(self, "_go_to_security_tape_assembly"))

func _offer_final_night_walk_replay() -> void:
	PostGameReplay.open_offer(ui_layer, player, "Walk the final night again?", "final_night_walk", Callable(self, "_go_to_final_night_walk"))

func _offer_memory_echo_replay() -> void:
	PostGameReplay.open_offer(ui_layer, player, "Play the last set again?", "memory_echo", Callable(self, "_go_to_memory_echo"))
