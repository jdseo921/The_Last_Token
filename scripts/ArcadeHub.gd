extends Node2D

const ASSET_PATHS := preload("res://scripts/AssetPaths.gd")
const ROUTE_CUE_SCRIPT := preload("res://scripts/RouteCue.gd")
const AMBIENT_EFFECTS := preload("res://scripts/AmbientSpriteEffects.gd")
const DIALOGUE_POOL := preload("res://scripts/DialoguePool.gd")
const MIRA_IDLE_SHEET_PATH := "res://assets/art/characters/mira/mira_idle_sheet.png"
const GUS_IDLE_SHEET_PATH := "res://assets/art/characters/gus/gus_idle_sheet.png"
const VENDO_IDLE_SHEET_PATH := "res://assets/art/characters/vendo/vendo_idle_sheet.png"
const MR_BYTE_IDLE_SHEET_PATH := "res://assets/art/characters/mr_byte/mr_byte_idle_sheet.png"
const PORTRAIT_MIRA_WORRIED := "res://assets/art/portraits/mira/mira_worried.png"
const PORTRAIT_GUS_ANNOYED := "res://assets/art/portraits/gus/gus_annoyed.png"
const PORTRAIT_CABINET_07_SCREEN := "res://assets/art/portraits/mr_byte/cabinet_07_screen.png"

@onready var player: CharacterBody2D = $Player
@onready var background_sprite: Sprite2D = $BackgroundLayer/BackgroundSprite
@onready var floor_layer: Node2D = $FloorLayer
@onready var wall_layer: Node2D = $WallLayer
@onready var ticket_counter_sprite: Sprite2D = $PropLayer/TicketCounterSprite
@onready var owner_portrait_sprite: Sprite2D = $PropLayer/OwnerPortraitSprite
@onready var staff_door_visual: Polygon2D = $PropLayer/StaffDoorVisual
@onready var cabinet_07_screen: Polygon2D = $PropLayer/Cabinet07Screen
@onready var truth_filter_screen: Polygon2D = $PropLayer/TruthFilterScreen
@onready var cabinet_07_sprite: Sprite2D = $PropLayer/Cabinet07Sprite
@onready var cabinet_07_flicker_sprite: AnimatedSprite2D = $PropLayer/Cabinet07FlickerSprite
@onready var broken_cabinet_sprite: Sprite2D = $PropLayer/BrokenCabinetSprite
@onready var staff_door_sprite: Sprite2D = $PropLayer/StaffDoorSprite
@onready var ui_layer: Node2D = $UILayer

var route_cue: Control = null
@onready var dialogue_box: CanvasLayer = $UILayer/DialogueBox
@onready var prompt_label: Label = $UILayer/InteractionPrompt
@onready var prompt_background: ColorRect = $UILayer/InteractionPromptBackground
@onready var hint_label: Label = $UILayer/HintLabel
@onready var post_reveal_hint_label: Label = $UILayer/PostRevealHintLabel
@onready var objective_hint_background: ColorRect = $UILayer/ObjectiveHintBackground
@onready var objective_hint_label: Label = $UILayer/ObjectiveHintLabel
@onready var quest_notice: CanvasLayer = $QuestNotice
@onready var intro_fade_overlay: ColorRect = $IntroFadeLayer/IntroFadeOverlay
@onready var pause_menu: CanvasLayer = $PauseMenu
@onready var effects_layer: Node2D = $EffectsLayer
@onready var truth_filter_glow: Polygon2D = $EffectsLayer/TruthFilterGlow

var save_slot_menu: Control = null
var choice_box: CanvasLayer = null
var pending_after_dialogue: Callable = Callable()
var cabinet_glow_tween: Tween = null
var intro_active := false
var intro_fade_tween: Tween = null
var last_dialogue_repeat_count := 0
var aftermath_pulse_tween: Tween = null

func _ready() -> void:
	AudioManager.play_music_for_context("arcade_hub")
	_apply_hub_art()
	_setup_ambient_sprite_effects()
	player.interaction_prompt_changed.connect(_on_prompt_changed)
	dialogue_box.dialogue_finished.connect(_on_dialogue_finished)
	_apply_spawn_position()
	_on_prompt_changed("")
	_setup_route_cue()
	_refresh_hint()
	_refresh_objective_hint()
	_refresh_hub_art_states()
	if _should_play_opening_intro():
		call_deferred("_play_opening_intro")
	else:
		call_deferred("_maybe_show_quest_notification")
	_maybe_show_controls_hint()
	call_deferred("_maybe_play_rockbyte_anecdote")

func _maybe_play_rockbyte_anecdote() -> void:
	# Auto cast reaction on returning from a won Rockbyte Duel (same pattern as
	# the other rooms' completion anecdotes). One-shot; the walk-up interaction
	# then serves the second sequential set.
	if intro_active or _dialogue_is_active() or ConscienceEncounterDirector.is_encounter_active():
		return
	if GameState.consume_postgame_replay_return("rockbyte"):
		start_dialogue(_get_cabinet07_lines("post_game_replay_return", [
			{"speaker": "Cabinet 07", "text": "SESSION COMPLETE. NO TOKEN DISPENSED.", "portrait": PORTRAIT_CABINET_07_SCREEN},
			{"speaker": "Cabinet 07", "text": "YOU PLAYED FOR NO REASON. LOG ENTRY: HEALTHY.", "portrait": PORTRAIT_CABINET_07_SCREEN},
		]))
		return
	if not GameState.rockbyte_duel_completed or GameState.lost_token_quest_completed:
		return
	if GameState.get_npc_dialogue_count("cabinet07_rockbyte_auto") > 0:
		return
	GameState.increment_npc_dialogue_count("cabinet07_rockbyte_auto")
	start_dialogue(_get_cabinet07_sequential_lines("rockbyte_completion", [
		{"speaker": "Cabinet 07", "text": "TOKEN RECOVERED."},
		{"speaker": "Cabinet 07", "text": "RETURN TO MIRA."},
	]))

func _maybe_show_controls_hint() -> void:
	if GameState.story_started:
		return
	var layer := CanvasLayer.new()
	layer.name = "ControlsHintLayer"
	layer.layer = 60
	add_child(layer)
	var backing := ColorRect.new()
	backing.mouse_filter = Control.MOUSE_FILTER_IGNORE
	backing.position = Vector2(10, 370)
	backing.size = Vector2(324, 22)
	backing.color = Color(0.01, 0.014, 0.02, 0.72)
	layer.add_child(backing)
	var hint := Label.new()
	hint.position = Vector2(16, 373)
	hint.size = Vector2(320, 16)
	hint.add_theme_font_override("font", preload("res://assets/fonts/m3x6.ttf"))
	hint.add_theme_font_size_override("font_size", 16)
	hint.text = "MOVE: WASD / Arrows    INTERACT: E    MENU: Esc"
	layer.add_child(hint)
	var tween := create_tween()
	tween.tween_interval(9.0)
	tween.tween_property(backing, "modulate:a", 0.0, 1.2)
	tween.parallel().tween_property(hint, "modulate:a", 0.0, 1.2)
	tween.tween_callback(layer.queue_free)

func _process(_delta: float) -> void:
	_refresh_objective_hint_visibility()

func _apply_spawn_position() -> void:
	var spawn_id := GameState.consume_pending_spawn_id("")
	# A stored spot from a minigame in this room wins over the door marker.
	var back_first: Variant = GameState.consume_return_point(scene_file_path)
	if back_first != null:
		player.global_position = back_first
		return
	if not spawn_id.is_empty():
		var marker := get_node_or_null(spawn_id)
		if marker is Marker2D:
			player.global_position = marker.global_position
			return
	var back: Variant = GameState.consume_return_point(scene_file_path)
	if back != null:
		player.global_position = back
		return
	if GameState.post_reveal_roam_unlocked:
		player.global_position = Vector2(178, 246)
		return
	if GameState.rockbyte_duel_completed and not GameState.twist_reveal_seen:
		player.global_position = Vector2(430, 204)

func _on_prompt_changed(text: String) -> void:
	prompt_label.text = text
	prompt_label.visible = not text.is_empty()
	if prompt_background:
		prompt_background.visible = prompt_label.visible

func start_dialogue(lines: Array, after_dialogue: Callable = Callable()) -> void:
	pending_after_dialogue = after_dialogue
	if player and player.has_method("set_control_enabled"):
		player.set_control_enabled(false)
	dialogue_box.start_dialogue(lines)
	_refresh_hint()
	_refresh_objective_hint()
	_refresh_hub_art_states()

func _select_repeat_dialogue(npc_id: String, early_sets: Array, redirect_sets: Array) -> Array:
	var phase := _get_npc_dialogue_phase()
	var key := "%s:%s" % [npc_id, phase]
	var talk_count := GameState.increment_npc_dialogue_count(key)
	last_dialogue_repeat_count = talk_count
	var pool: Array = early_sets if talk_count <= 2 else redirect_sets
	if pool.is_empty():
		return []
	var selected_value: Variant = pool[randi() % pool.size()]
	if selected_value is Array:
		return selected_value
	return []

func _get_mira_lines(key: String, fallback: Array) -> Array:
	return DIALOGUE_POOL.get_lines("mira", key, fallback)

func _get_mira_sequential_lines(key: String, fallback: Array) -> Array:
	return DIALOGUE_POOL.get_sequential_set("mira", key, key, fallback)

func _get_gus_lines(key: String, fallback: Array) -> Array:
	return DIALOGUE_POOL.get_lines("gus", key, fallback)

func _get_gus_sequential_lines(key: String, fallback: Array) -> Array:
	return DIALOGUE_POOL.get_sequential_set("gus", key, key, fallback)

func _get_vendo_lines(key: String, fallback: Array) -> Array:
	return DIALOGUE_POOL.get_lines("vendo", key, fallback)

func _get_vendo_sequential_lines(key: String, fallback: Array) -> Array:
	return DIALOGUE_POOL.get_sequential_set("vendo", key, key, fallback)

func _get_mr_byte_lines(key: String, fallback: Array) -> Array:
	return DIALOGUE_POOL.get_lines("mr_byte", key, fallback)

func _get_mr_byte_sequential_lines(key: String, fallback: Array) -> Array:
	return DIALOGUE_POOL.get_sequential_set("mr_byte", key, key, fallback)

func _get_cabinet07_lines(key: String, fallback: Array) -> Array:
	return DIALOGUE_POOL.get_lines("cabinet_07", key, fallback)

func _get_cabinet07_sequential_lines(key: String, fallback: Array) -> Array:
	return DIALOGUE_POOL.get_sequential_set("cabinet_07", key, key, fallback)

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
	lines = _get_environment_lines("%s_grounded" % object_key, fallback)
	if not lines.is_empty():
		return lines
	return fallback

func _get_environment_state_key() -> String:
	GameState.update_memory_signal_from_progress()
	if _is_post_reveal():
		return "restored"
	return GameState.get_memory_signal_label().to_lower()

func _combine_dialogue_lines(first_lines: Array, second_lines: Array) -> Array:
	var combined := first_lines.duplicate(true)
	combined.append_array(second_lines.duplicate(true))
	return combined

func _get_npc_dialogue_phase() -> String:
	if _is_post_reveal():
		return "post_reveal"
	if GameState.lying_cabinets_completed:
		return "truth_filter_cleared"
	if GameState.lost_token_quest_completed and not GameState.lying_cabinets_completed:
		return "truth_filter_active"
	if GameState.lost_token_collected:
		return "lost_token_collected"
	if GameState.lost_token_quest_started:
		return "lost_token_started"
	return "opening"

func _on_dialogue_finished() -> void:
	if pending_after_dialogue.is_valid():
		pending_after_dialogue.call()
		pending_after_dialogue = Callable()
	if player and player.has_method("set_control_enabled") and not _choice_box_is_open() and not intro_active:
		player.set_control_enabled(true)
	_refresh_hint()
	_refresh_objective_hint()
	_refresh_hub_art_states()
	_maybe_show_quest_notification()
	_maybe_play_opening_monologue()

func _maybe_play_opening_monologue() -> void:
	# After the player has poked around and talked to a few NPCs, the protagonist
	# reflects and points himself at Mira, which is what starts the first quest.
	if not GameState.opening_monologue_due():
		return
	GameState.opening_hint_monologue_seen = true
	start_dialogue([
		{"speaker": "Player", "text": "Everyone here talks like they knew me before I walked in."},
		{"speaker": "Player", "text": "And the woman at the counter keeps glancing over. Mira."},
		{"speaker": "Player", "text": "Like she has been waiting for me to walk up. I should go see what she wants."},
	])

func _choice_box_is_open() -> bool:
	return choice_box != null and is_instance_valid(choice_box) and choice_box.visible

func _refresh_hint() -> void:
	hint_label.visible = false
	post_reveal_hint_label.visible = GameState.post_reveal_roam_unlocked and not _dialogue_is_active() and not _choice_box_is_open() and not _save_slot_menu_is_open()

func _setup_route_cue() -> void:
	if route_cue != null and is_instance_valid(route_cue):
		return
	route_cue = ROUTE_CUE_SCRIPT.new()
	ui_layer.add_child(route_cue)
	route_cue.call("setup", "arcade_hub", Vector2(24, 86), 430.0)

func _refresh_route_cue() -> void:
	if route_cue == null or not is_instance_valid(route_cue) or not route_cue.has_method("refresh"):
		return
	route_cue.call("refresh")
	# The cold open owns the screen: no routing bar over the intro monologue.
	if intro_active or _should_play_opening_intro():
		route_cue.visible = false

func _refresh_objective_hint() -> void:
	objective_hint_label.text = _get_objective_hint_text()
	_refresh_objective_hint_visibility()
	_refresh_route_cue()
	_refresh_hub_art_states()

func _refresh_objective_hint_visibility() -> void:
	if objective_hint_label == null or objective_hint_background == null:
		return
	# objective text now lives in the shared top-right HUD (QuestNotice)
	objective_hint_label.visible = false
	objective_hint_background.visible = false

func _objective_hint_should_be_visible() -> bool:
	if _get_objective_hint_text().is_empty():
		return false
	if _should_play_opening_intro() or intro_active:
		return false
	if _dialogue_is_active() or _choice_box_is_open() or _save_slot_menu_is_open():
		return false
	if pause_menu != null and pause_menu.visible:
		return false
	if quest_notice != null and quest_notice.visible:
		return false
	return true

func _get_objective_hint_text() -> String:
	match GameState.get_current_quest_id():
		"opening_look_around":
			return "Objective: Look around. Talk to whoever is still here."
		"opening_talk_to_mira":
			return "Objective: Talk to Mira at the ArcadeHub ticket counter."
		"recover_lost_token":
			return "Objective: Play Cabinet 07 on the ArcadeHub main floor."
		"return_lost_token":
			return "Objective: Return the Lost Token to Mira at the counter."
		"truth_filter":
			return "Objective: Cabinet Row -> Mr. Byte and Truth Filter."
		"circuit_soda":
			return "Objective: Snack Alcove -> Vendo and Circuit Soda."
		"lost_shift_file":
			if not GameState.closing_checklist_read:
				return "Objective: ArcadeHub -> read the Closing Checklist."
			if not GameState.staff_schedule_read:
				return "Objective: Cabinet Row -> read the Staff Schedule by Mr. Byte."
			if not GameState.maintenance_note_read:
				return "Objective: Maintenance Hall -> read Gus's Maintenance Note."
			return "Objective: Maintenance Hall -> tell Gus the Lost Shift File is complete."
		"static_service_run":
			return "Objective: Maintenance Hall -> Gus and Static Service Run."
		"maintenance_sync":
			return "Objective: Maintenance Hall -> Gus and Maintenance Sync."
		"staff_corridor":
			return "Objective: Maintenance Hall -> use the Staff Corridor exit."
		"security_tape_assembly":
			return "Objective: Staff Corridor -> assemble the Security Tape."
		"final_night_walk":
			return "Objective: Staff Corridor -> walk the Final Night route."
		"stabilize_memory_echo":
			return "Objective: Staff Corridor -> stabilize the Memory Echo."
		"enter_staff_room":
			return "Objective: Staff Corridor -> enter the Staff Room."
		"finish_memory":
			return "Objective: Staff Room -> finish the memory."
		"talk_to_witnesses":
			return "Objective: Talk to witnesses. Start with Mira and Cabinet 07."
	return ""

func _dialogue_is_active() -> bool:
	if dialogue_box == null:
		return false
	return dialogue_box.get("active") == true

func _save_slot_menu_is_open() -> bool:
	return save_slot_menu != null and is_instance_valid(save_slot_menu) and save_slot_menu.visible

func can_open_pause_menu() -> bool:
	return not intro_active and not _dialogue_is_active() and not _choice_box_is_open() and not _save_slot_menu_is_open()

func _should_play_opening_intro() -> bool:
	return not GameState.opening_intro_seen and not GameState.story_started

func _play_opening_intro() -> void:
	intro_active = true
	if player and player.has_method("set_control_enabled"):
		player.set_control_enabled(false)
	intro_fade_overlay.visible = true
	intro_fade_overlay.modulate.a = 1.0
	await _fade_intro_to_dialogue()
	dialogue_box.start_dialogue([
		{"speaker": "Player", "text": "Pixel Haven. The name is already in my head. My own name is not."},
		{"speaker": "Player", "text": "I remember carpet patterns, machine hum, and the smell of old tickets. I do not remember walking in."},
		{"speaker": "Player", "text": "I think I used to like it here after everyone left. The quiet always felt earned."},
		{"speaker": "Player", "text": "Something is missing from my pocket. A token, maybe. Or the reason I came back."},
	])
	await dialogue_box.dialogue_finished
	GameState.mark_opening_intro_seen()
	await _fade_intro_from_black()
	intro_active = false
	if player and player.has_method("set_control_enabled"):
		player.set_control_enabled(true)
	_maybe_show_quest_notification()

func _fade_intro_to_dialogue() -> void:
	if intro_fade_tween and intro_fade_tween.is_valid():
		intro_fade_tween.kill()
	await get_tree().create_timer(0.2).timeout
	intro_fade_tween = create_tween()
	intro_fade_tween.tween_property(intro_fade_overlay, "modulate:a", 0.72, 1.15)
	await intro_fade_tween.finished

func _fade_intro_from_black() -> void:
	if intro_fade_tween and intro_fade_tween.is_valid():
		intro_fade_tween.kill()
	intro_fade_overlay.visible = true
	intro_fade_overlay.modulate.a = maxf(intro_fade_overlay.modulate.a, 0.72)
	intro_fade_tween = create_tween()
	intro_fade_tween.tween_property(intro_fade_overlay, "modulate:a", 0.0, 0.9)
	intro_fade_tween.tween_callback(_hide_intro_fade_overlay)
	await intro_fade_tween.finished

func _hide_intro_fade_overlay() -> void:
	intro_fade_overlay.visible = false

func _maybe_show_quest_notification() -> void:
	# Quest guidance now lives in the persistent top-right HUD (QuestNotice
	# announces changes there); the center popup is retired for quest changes.
	pass

func handle_hub_interaction(interactable: Node, player_node: Node = null) -> void:
	var kind := str(interactable.interactable_kind)
	if GameState.opening_look_around_active() and kind in ["mira", "gus", "vendo", "hub_directory", "test_cabinet", "cabinet07", "owner_portrait", "broken_cabinet", "closing_checklist", "staff_door"]:
		GameState.register_opening_talk()
	match kind:
		"mira":
			_handle_mira()
		"ticket_counter":
			_handle_ticket_counter()
		"closing_checklist":
			_handle_closing_checklist()
		"gus":
			_handle_gus()
		"vendo":
			_handle_vendo()
		"hub_directory":
			_handle_hub_directory()
		"cabinet07":
			_handle_cabinet_07()
		"test_cabinet":
			_handle_test_cabinet()
		"staff_door":
			_handle_staff_door()
		"owner_portrait":
			_handle_owner_portrait()
		"broken_cabinet":
			_handle_broken_cabinet(interactable)
		_:
			start_dialogue([{"speaker": "System", "text": "Nothing happens."}])

func try_block_exit(transition: Node) -> bool:
	# During the Lost Token errand the player has decided to stay put: every hub
	# exit is refused with a reason, and the player is turned and nudged back so
	# the trigger does not immediately re-fire.
	if not GameState.lost_token_quest_started or GameState.lost_token_quest_completed:
		return false
	if _dialogue_is_active():
		return true
	_push_player_back_from(transition)
	if not GameState.rockbyte_duel_completed:
		start_dialogue([
			{"speaker": "Player", "text": "The exit can wait."},
			{"speaker": "Player", "text": "This place recognized me before I recognized it. I want to know why."},
			{"speaker": "Player", "text": "First: win my token back from Cabinet 07."},
		])
	else:
		start_dialogue([
			{"speaker": "Player", "text": "Not yet. Mira is waiting for this token."},
			{"speaker": "Player", "text": "If I walk out now, I will never learn what this place remembers."},
		])
	return true

func _push_player_back_from(transition: Node) -> void:
	if player == null or not (transition is Node2D):
		return
	var away: Vector2 = player.global_position - (transition as Node2D).global_position
	if away.length() < 0.01:
		away = Vector2(0, -1)
	away = away.normalized()
	player.global_position += away * 26.0
	if player.has_method("_get_direction_name"):
		player.set("facing_direction", str(player.call("_get_direction_name", away)))

func _can_show_act2_echo() -> bool:
	return GameState.lying_cabinets_completed and not GameState.twist_reveal_seen

func _get_ticket_counter_echo_lines() -> Array:
	GameState.echo_ticket_counter_seen = true
	return _get_environment_lines("ticket_counter_fractured", [
		{"speaker": "Narrator", "text": "The ticket counter glass catches your reflection half a beat late."},
		{"speaker": "Narrator", "text": "For a moment it does not move when you move."},
		{"speaker": "Narrator", "text": "Then it catches up, like nothing happened."},
	])

func _get_cabinet07_echo_lines() -> Array:
	GameState.echo_cabinet07_seen = true
	return [
		{"speaker": "Cabinet 07", "text": "PREVIOUS PLAYER PROFILE FOUND.", "portrait": PORTRAIT_CABINET_07_SCREEN},
		{"speaker": "Cabinet 07", "text": "STATUS: DAMAGED.", "portrait": PORTRAIT_CABINET_07_SCREEN},
		{"speaker": "Cabinet 07", "text": "RESTORE ATTEMPT: CONTINUING.", "portrait": PORTRAIT_CABINET_07_SCREEN},
	]

func _on_first_meeting_finished() -> void:
	GameState.memory_signal_explainer_seen = true
	GameState.start_lost_token_quest()

func _get_memory_signal_explainer_lines() -> Array:
	if GameState.memory_signal_explainer_seen:
		return []
	return [
		{"speaker": "Mira", "text": "Before you go - you deserve to know what this place is asking of you."},
		{"speaker": "Mira", "text": "The machines still hold pieces of the last night. Locked scores. Jammed reels. Dead circuits."},
		{"speaker": "Mira", "text": "Every game you win back and every thing you fix, the arcade remembers a little more."},
		{"speaker": "Mira", "text": "Remember enough, and the Staff Room at the back will finally open."},
		{"speaker": "Mira", "text": "That is where the last of it is waiting."},
		{"speaker": "Mira", "text": "Start with Cabinet 07 and your token. I will point you onward from there."},
	]

func _handle_mira() -> void:
	if _is_post_reveal():
		GameState.mira_post_reveal_seen = true
		var was_completed := _was_witness_route_completed()
		GameState.mark_witness_mira_heard()
		var post_reveal_lines := _get_mira_lines("post_reveal_witness", [
			{"speaker": "Mira", "text": "You finally remembered."},
			{"speaker": "Mira", "text": "I was worried you would choose to disappear again.", "portrait": PORTRAIT_MIRA_WORRIED},
			{"speaker": "Mira", "text": "But you are still here.", "portrait": PORTRAIT_MIRA_WORRIED},
			{"speaker": "Mira", "text": "That counts for something."},
		])
		if GameState.midpoint_told_mira:
			post_reveal_lines.append({"speaker": "Mira", "text": "You told me about the hidden shift before the door showed you the rest. That mattered more than you know."})
		else:
			post_reveal_lines.append({"speaker": "Mira", "text": "You carried the shift file to the door alone. Let it be the last thing you ever carry that way."})
		start_dialogue(post_reveal_lines, _get_witness_completion_callback(was_completed))
		return
	if _can_show_act2_echo() and not GameState.echo_ticket_counter_seen:
		start_dialogue(_get_ticket_counter_echo_lines())
		return
	if GameState.midpoint_turn_seen and not GameState.midpoint_told_mira and GameState.lost_shift_file_completed and not GameState.staff_corridor_unlocked:
		GameState.midpoint_told_mira = true
		start_dialogue([
			{"speaker": "Player", "text": "The schedule. The checklist. The maintenance note."},
			{"speaker": "Player", "text": "There was a hidden shift on the last night. Whoever worked it never clocked out."},
			{"speaker": "Mira", "text": "...I know. I have known without letting myself know.", "portrait": PORTRAIT_MIRA_WORRIED},
			{"speaker": "Mira", "text": "Thank you for walking back here to say it out loud."},
			{"speaker": "Mira", "text": "Whatever the back rooms show you next, you did not find it alone. Remember that."},
		])
		return
	if GameState.opening_look_around_active():
		# Going straight to Mira skips the look-around gate: the story starts now.
		GameState.opening_intro_seen = true
		GameState.opening_hint_monologue_seen = true
	if not GameState.lost_token_quest_started:
		GameState.mira_intro_seen = true
		var opening_lines := _get_mira_lines("opening_first_meeting", [
			{"speaker": "Mira", "text": "You made it back."},
			{"speaker": "Mira", "text": "I was starting to think the door had forgotten how to let you in."},
			{"speaker": "Player", "text": "I know this place, but I do not know why. Do you know me?"},
			{"speaker": "Mira", "text": "A little. More than you do right now, I think."},
		])
		var quest_instruction_lines := _get_mira_lines("lost_token_quest_instruction", [
			{"speaker": "Mira", "text": "Cabinet 07 has your Lost Token."},
			{"speaker": "Mira", "text": "Please bring it back to me."},
		])
		var first_meeting_lines := _combine_dialogue_lines(opening_lines, _get_memory_signal_explainer_lines())
		first_meeting_lines = _combine_dialogue_lines(first_meeting_lines, quest_instruction_lines)
		start_dialogue(first_meeting_lines, Callable(self, "_on_first_meeting_finished"))
		return
	if GameState.lost_token_quest_started and not GameState.lost_token_collected:
		start_dialogue(_get_mira_sequential_lines("lost_token_active_repeat", [
			{"speaker": "Mira", "text": "Cabinet 07 is waiting."},
			{"speaker": "Mira", "text": "It only opens for signals it almost remembers."},
			{"speaker": "Player", "text": "That sounds like a terrible way to recognize someone."},
			{"speaker": "Mira", "text": "Around here, it counts as friendly."},
		]))
		return
	if GameState.lost_token_collected and not GameState.lost_token_quest_completed:
		start_dialogue(_get_mira_lines("lost_token_return_anecdote", [
			{"speaker": "Player", "text": "I found the Lost Token. It felt like it already belonged to me."},
			{"speaker": "Mira", "text": "You brought it back.", "portrait": PORTRAIT_MIRA_WORRIED},
			{"speaker": "Mira", "text": "That token used to be just a prize."},
			{"speaker": "Mira", "text": "Then it became proof that part of you could still return."},
			{"speaker": "Mira", "text": "The token woke something."},
			{"speaker": "Mira", "text": "Start in Cabinet Row. Roxy guards a score cabinet that is still lying about a record."},
			{"speaker": "Mira", "text": "Help her set it straight."},
		]), Callable(self, "_complete_lost_token_with_mira_anecdote"))
		return
	if GameState.lost_token_quest_completed and not GameState.broken_high_score_completed and not GameState.lying_cabinets_completed:
		start_dialogue(_get_mira_lines("broken_high_score_transition", [
			{"speaker": "Mira", "text": "Cabinet Row first. Roxy's score cabinet is still lying about a record."},
			{"speaker": "Mira", "text": "Set the board straight with her. Then Mr. Byte will want a word about truth."},
		]))
		return
	if GameState.lost_token_quest_completed and not GameState.lying_cabinets_completed:
		start_dialogue(_get_mira_lines("truth_filter_transition", [
			{"speaker": "Mira", "text": "The token woke something."},
			{"speaker": "Mira", "text": "Now the arcade has to decide which memories are true."},
			{"speaker": "Mira", "text": "Mr. Byte can open the Truth Filter."},
		]))
		return
	if GameState.lying_cabinets_completed and not GameState.circuit_soda_completed:
		start_dialogue(_get_mira_lines("circuit_soda_transition", [
			{"speaker": "Mira", "text": "The arcade is remembering louder now."},
			{"speaker": "Mira", "text": "Vendo says fractured things still need somewhere to flow.", "portrait": PORTRAIT_MIRA_WORRIED},
			{"speaker": "Mira", "text": "Snack Alcove is the next stop."},
		]))
		return
	if GameState.circuit_soda_completed and not GameState.lost_shift_file_completed:
		start_dialogue(_get_mira_lines("lost_shift_file_dialogue", [
			{"speaker": "Mira", "text": "The records are waking up now."},
			{"speaker": "Mira", "text": "I remember locking the counter."},
			{"speaker": "Mira", "text": "But the last part is still missing.", "portrait": PORTRAIT_MIRA_WORRIED},
			{"speaker": "Mira", "text": "Gus and Mr. Byte may remember the edges."},
		]))
		return
	if GameState.lying_cabinets_completed and not GameState.story_puzzle_completed:
		start_dialogue(_select_repeat_dialogue("mira", [
			[
				{"speaker": "Mira", "text": "You heard the contradictions and came back anyway.", "portrait": PORTRAIT_MIRA_WORRIED},
				{"speaker": "Mira", "text": "That is good."},
				{"speaker": "Mira", "text": "That is also worrying."},
			],
			[
				{"speaker": "Mira", "text": "The arcade is remembering louder now."},
				{"speaker": "Mira", "text": "That means the Staff Door may finally listen."},
			],
		], [
			[
				{"speaker": "Mira", "text": "Go check the Staff Door."},
				{"speaker": "Mira", "text": "I will try not to look dramatically worried.", "portrait": PORTRAIT_MIRA_WORRIED},
			],
		]))
		return
	var pre_staff_lines := _get_mira_lines("overloaded_pre_staff_room", [
		{"speaker": "Mira", "text": "The Staff Door used to stick even when it liked you."},
		{"speaker": "Mira", "text": "If it opens cleanly, that is probably a good sign."},
		{"speaker": "Mira", "text": "Go check the Staff Door."},
	])
	if GameState.midpoint_told_mira:
		pre_staff_lines.append({"speaker": "Mira", "text": "And thank you for telling me what the records said. You are not walking in there carrying it alone.", "portrait": PORTRAIT_MIRA_WORRIED})
	elif GameState.midpoint_turn_seen:
		pre_staff_lines.append({"speaker": "Mira", "text": "You never did tell me what those records said. Carry it however you can. But come back.", "portrait": PORTRAIT_MIRA_WORRIED})
	start_dialogue(pre_staff_lines)

func _complete_lost_token_with_mira_anecdote() -> void:
	GameState.mira_rockbyte_anecdote_seen = true
	GameState.complete_lost_token_quest()

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

func _handle_ticket_counter() -> void:
	if _can_show_act2_echo() and not GameState.echo_ticket_counter_seen:
		start_dialogue(_get_ticket_counter_echo_lines())
		return
	start_dialogue(_get_environment_state_lines("ticket_counter", [
		{"speaker": "Narrator", "text": "The ticket counter glass is dark and dusty."},
	]))

func _handle_closing_checklist() -> void:
	if not GameState.circuit_soda_completed:
		start_dialogue(_get_environment_state_lines("closing_checklist", [
			{"speaker": "Closing Checklist", "text": "Sweep floors."},
			{"speaker": "Closing Checklist", "text": "Count tickets."},
			{"speaker": "Closing Checklist", "text": "Lock Staff Room."},
		]))
		return
	var was_completed := GameState.lost_shift_file_completed
	GameState.read_closing_checklist()
	var lines := _get_environment_state_lines("closing_checklist", [
		{"speaker": "Closing Checklist", "text": "CLOSING CHECKLIST"},
		{"speaker": "Closing Checklist", "text": "Staff Door checked twice."},
		{"speaker": "Closing Checklist", "text": "Final item scratched out."},
	])
	lines.append_array(_get_lost_shift_completion_lines())
	var after_dialogue := Callable(self, "_show_lost_shift_complete_notice") if not was_completed and GameState.lost_shift_file_completed else Callable()
	start_dialogue(lines, after_dialogue)

func _handle_gus() -> void:
	if _is_post_reveal():
		GameState.gus_post_reveal_seen = true
		var was_completed := _was_witness_route_completed()
		GameState.mark_witness_gus_heard()
		var post_reveal_lines := _get_gus_lines("post_reveal_witness", [
			{"speaker": "Gus", "text": "About time.", "portrait": PORTRAIT_GUS_ANNOYED},
			{"speaker": "Gus", "text": "I was almost out of practical hints.", "portrait": PORTRAIT_GUS_ANNOYED},
			{"speaker": "Gus", "text": "You came back anyway. Good."},
		])
		start_dialogue(post_reveal_lines, _get_witness_completion_callback(was_completed))
		return
	if GameState.lying_cabinets_completed and GameState.mr_byte_truth_filter_debriefed and not GameState.circuit_soda_completed and not GameState.gus_hub_checkin_truth_filter_done:
		GameState.gus_hub_checkin_truth_filter_done = true
		start_dialogue(_get_gus_lines("hub_checkin_truth_filter", [
			{"speaker": "Gus", "text": "Heard the Truth Filter howl. It only does that when it loses.", "portrait": PORTRAIT_GUS_ANNOYED},
			{"speaker": "Gus", "text": "Vendo is next. Snack Alcove. Do not tip the machine."},
		]))
		return
	if GameState.circuit_soda_completed and GameState.prize_sort_completed and not GameState.lost_shift_file_completed and not GameState.gus_hub_checkin_prize_sort_done:
		GameState.gus_hub_checkin_prize_sort_done = true
		start_dialogue(_get_gus_lines("hub_checkin_prize_sort", [
			{"speaker": "Gus", "text": "Pip talked. Now we do this my way: paperwork.", "portrait": PORTRAIT_GUS_ANNOYED},
			{"speaker": "Gus", "text": "Checklist by the counter. Schedule in Cabinet Row. My note in the hall."},
		]))
		return
	if GameState.lost_token_quest_completed and not GameState.lying_cabinets_completed:
		start_dialogue(_get_gus_sequential_lines("truth_filter_active", [
			{"speaker": "Gus", "text": "Careful now."},
			{"speaker": "Gus", "text": "Once the machines start correcting memories, they get picky."},
			{"speaker": "Gus", "text": "Truth Filter cabinet is over in Cabinet Row."},
			{"speaker": "Gus", "text": "Mr. Byte is the one acting like he grades homework."},
		]))
		return
	if GameState.lying_cabinets_completed and not GameState.circuit_soda_completed:
		start_dialogue(_get_gus_sequential_lines("circuit_soda_active", [
			{"speaker": "Gus", "text": "Signal's fractured."},
			{"speaker": "Gus", "text": "Vendo has a machine for that, because of course he does.", "portrait": PORTRAIT_GUS_ANNOYED},
			{"speaker": "Gus", "text": "Snack Alcove first."},
		]))
		return
	if GameState.lying_cabinets_completed and not GameState.story_puzzle_completed:
		start_dialogue(_select_repeat_dialogue("gus", [
			[
				{"speaker": "Gus", "text": "If your memories start arguing, do not pick the loudest one."},
			],
			[
				{"speaker": "Gus", "text": "Fractured, huh?"},
				{"speaker": "Gus", "text": "That sounds expensive to clean up."},
			],
		], [
			[
				{"speaker": "Gus", "text": "Staff Door time."},
				{"speaker": "Gus", "text": "Go before the hallway develops opinions.", "portrait": PORTRAIT_GUS_ANNOYED},
			],
		]))
		return
	if GameState.lost_token_quest_completed:
		start_dialogue(_select_repeat_dialogue("gus", [
			[
				{"speaker": "Gus", "text": "Staff Door is humming again."},
				{"speaker": "Gus", "text": "Practical advice: do not ignore humming doors.", "portrait": PORTRAIT_GUS_ANNOYED},
			],
			[
				{"speaker": "Gus", "text": "Mira looks less sad. That usually means trouble upgraded to specific trouble."},
				{"speaker": "Gus", "text": "Staff Door is your specific trouble."},
			],
		], [
			[
				{"speaker": "Gus", "text": "Door. Staff. Go."},
				{"speaker": "Gus", "text": "I would draw arrows, but then I would have to mop around them.", "portrait": PORTRAIT_GUS_ANNOYED},
			],
		]))
		return
	GameState.gus_intro_seen = true
	start_dialogue(_get_gus_sequential_lines("pre_lost_token_flavor", [
		{"speaker": "Gus", "text": "You again. Great.", "portrait": PORTRAIT_GUS_ANNOYED},
		{"speaker": "Gus", "text": "I just finished cleaning up the previous session."},
		{"speaker": "Player", "text": "Previous session?"},
		{"speaker": "Gus", "text": "Arcade talk. Means I found tickets in places tickets should fear."},
	]))

func _handle_vendo() -> void:
	# Second Vendo unit: the hub soda machine. Flavor and the Memory Cola
	# riddle only - guidance and the witness beat belong to the Snack Alcove unit.
	if not GameState.vendo_memory_riddle_secret_found and GameState.lost_token_quest_completed and not _is_post_reveal():
		start_dialogue(_get_vendo_lines("memory_cola_riddle_setup", [
			{"speaker": "Vendo", "text": "Limited offer: one Memory Cola. Payment accepted in answers."},
			{"speaker": "Vendo", "text": "Answer the house riddle and the can is yours."},
		]), Callable(self, "_open_vendo_memory_riddle"))
		return
	start_dialogue(DIALOGUE_POOL.get_random_set("vendo", "early_flavor", [
		{"speaker": "Vendo", "text": "Second unit status: humming."},
		{"speaker": "Vendo", "text": "The alcove unit gets the customers. I get the acoustics."},
	]))

func _open_vendo_memory_riddle() -> void:
	if GameState.vendo_memory_riddle_secret_found:
		return
	if choice_box and is_instance_valid(choice_box):
		choice_box.queue_free()
	choice_box = load("res://scenes/ui/ChoiceBox.tscn").instantiate()
	ui_layer.add_child(choice_box)
	if player and player.has_method("set_control_enabled"):
		player.set_control_enabled(false)
	if choice_box.has_signal("choice_selected"):
		choice_box.connect("choice_selected", _on_vendo_riddle_choice_selected, CONNECT_ONE_SHOT)
	if choice_box.has_signal("choice_cancelled"):
		choice_box.connect("choice_cancelled", _on_vendo_riddle_choice_cancelled, CONNECT_ONE_SHOT)
	if choice_box.has_method("open_choice"):
		choice_box.open_choice("What do you lose every time you return?", [
			"STATIC SODA",
			"MEMORY COLA",
			"TOKEN TEA",
			"REGRET JUICE",
		])
	_refresh_hint()
	_refresh_objective_hint()

func _on_vendo_riddle_choice_selected(index: int) -> void:
	if choice_box and is_instance_valid(choice_box):
		choice_box.queue_free()
	choice_box = null
	if index == 1:
		GameState.vendo_memory_riddle_secret_found = true
		start_dialogue(_get_vendo_lines("memory_cola_correct", [
			{"speaker": "Vendo", "text": "Correct."},
			{"speaker": "Vendo", "text": "You lose memory."},
			{"speaker": "Vendo", "text": "I lose coins."},
			{"speaker": "Vendo", "text": "We all suffer in our own branded containers."},
		]))
		return
	start_dialogue(_get_vendo_sequential_lines("memory_cola_wrong_answers", [
		{"speaker": "Vendo", "text": "Incorrect."},
		{"speaker": "Vendo", "text": "But emotionally marketable."},
		{"speaker": "Vendo", "text": "Try again after your next identity crisis."},
	]))

func _on_vendo_riddle_choice_cancelled() -> void:
	if choice_box and is_instance_valid(choice_box):
		choice_box.queue_free()
	choice_box = null
	if player and player.has_method("set_control_enabled"):
		player.set_control_enabled(true)
	_refresh_hint()
	_refresh_objective_hint()

func _handle_hub_directory() -> void:
	# Floor directory kiosk. Random bulletins, pure flavor - Mr. Byte proper
	# lives in Cabinet Row and owns everything quest-critical.
	start_dialogue(DIALOGUE_POOL.get_random_set("environment_objects", "hub_directory_notes", [
		{"speaker": "Directory", "text": "PIXEL HAVEN FLOOR GUIDE."},
		{"speaker": "Directory", "text": "CABINET ROW: games. SNACK ALCOVE: sugar. PRIZE CORNER: negotiation."},
	]))

func _handle_cabinet_07() -> void:
	if _is_post_reveal() and GameState.witness_cabinet07_heard:
		start_dialogue(_get_cabinet07_lines("post_game_replay_offer", [
			{"speaker": "Cabinet 07", "text": "EMPLOYEE 04 DETECTED AT CABINET.", "portrait": PORTRAIT_CABINET_07_SCREEN},
			{"speaker": "Cabinet 07", "text": "REMATCH AVAILABLE. STAKES: NONE.", "portrait": PORTRAIT_CABINET_07_SCREEN},
		]), Callable(self, "_offer_rockbyte_replay"))
		return
	if _is_post_reveal():
		var was_completed := _was_witness_route_completed()
		GameState.mark_witness_cabinet07_heard()
		var post_reveal_lines := _get_cabinet07_lines("post_reveal_status", [
			{"speaker": "Cabinet 07", "text": "EMPLOYEE 04 RESTORE STATUS: STABLE.", "portrait": PORTRAIT_CABINET_07_SCREEN},
			{"speaker": "Cabinet 07", "text": "WELCOME BACK, EMPLOYEE 04.", "portrait": PORTRAIT_CABINET_07_SCREEN},
			{"speaker": "Cabinet 07", "text": "PREVIOUS SESSION: CLOSED.", "portrait": PORTRAIT_CABINET_07_SCREEN},
			{"speaker": "Cabinet 07", "text": "CURRENT SESSION: YOURS.", "portrait": PORTRAIT_CABINET_07_SCREEN},
		])
		if GameState.conscience_final_room_seen:
			post_reveal_lines.append_array([
				{"speaker": "Cabinet 07", "text": "PLAYER SIGNAL ACCEPTED.", "portrait": PORTRAIT_CABINET_07_SCREEN},
				{"speaker": "Cabinet 07", "text": "REGRET COMPONENT: STABLE.", "portrait": PORTRAIT_CABINET_07_SCREEN},
			])
		start_dialogue(post_reveal_lines, _get_witness_completion_callback(was_completed))
		return
	if not GameState.lost_token_quest_started:
		GameState.cabinet07_employee_hint_seen = true
		var cabinet_lines := _get_cabinet07_sequential_lines("pre_rockbyte", [
			{"speaker": "Cabinet 07", "text": "CUSTOMER SIGNAL: UNKNOWN."},
			{"speaker": "Cabinet 07", "text": "EMPLOYEE SIGNAL: PARTIAL."},
			{"speaker": "Cabinet 07", "text": "LOST TOKEN REQUIRED."},
		])
		cabinet_lines.append({"speaker": "Player", "text": "It wants a token I do not have. The attendant at the counter keeps glancing over. She might know why."})
		start_dialogue(cabinet_lines)
		return
	if not GameState.rockbyte_duel_completed:
		_store_arcade_return_position()
		SceneChanger.go_to_rockbyte_duel()
		return
	if GameState.rockbyte_duel_completed and not GameState.lost_token_quest_completed:
		start_dialogue(_get_cabinet07_sequential_lines("rockbyte_completion", [
			{"speaker": "Cabinet 07", "text": "TOKEN RECOVERED."},
			{"speaker": "Cabinet 07", "text": "RETURN TO MIRA."},
		]))
		return
	if GameState.lost_token_quest_completed and not GameState.lying_cabinets_completed:
		start_dialogue(_get_cabinet07_sequential_lines("truth_filter_phase_echo", [
			{"speaker": "Cabinet 07", "text": "TOKEN RETURNED."},
			{"speaker": "Cabinet 07", "text": "SIGNAL STATUS: UNEASY."},
			{"speaker": "Cabinet 07", "text": "TRUTH FILTER REQUIRED."},
		]))
		return
	var cabinet_key := "overloaded_echo" if GameState.maintenance_sync_completed or GameState.security_tape_assembly_completed or GameState.final_night_walk_completed or GameState.memory_echo_completed or GameState.story_puzzle_completed else "fractured_echo"
	var cabinet_lines := _get_cabinet07_sequential_lines(cabinet_key, [
		{"speaker": "Cabinet 07", "text": "CABINET STATUS: RESTLESS."},
		{"speaker": "Cabinet 07", "text": "STAFF DOOR TARGET READY."},
		{"speaker": "Cabinet 07", "text": "CHECK STAFF DOOR."},
	])
	if _can_show_act2_echo() and not GameState.echo_cabinet07_seen:
		cabinet_lines.append_array(_get_cabinet07_echo_lines())
	start_dialogue(cabinet_lines)

func _handle_test_cabinet() -> void:
	# The old tuning cabinet. Random archive fragments about the staffer who
	# calibrated every game in the building - the past Mira only gestures at.
	start_dialogue(DIALOGUE_POOL.get_random_set("environment_objects", "test_cabinet_memories", [
		{"speaker": "Test Cabinet", "text": "TEST LOG 114: difficulty lowered again."},
		{"speaker": "Test Cabinet", "text": "Note attached: 'kids should win on allowance money.'"},
	]))

func _on_save_slot_menu_closed() -> void:
	if player and player.has_method("set_control_enabled"):
		player.set_control_enabled(true)
	save_slot_menu = null
	_refresh_hint()
	_refresh_objective_hint()

func _handle_staff_door() -> void:
	if _is_post_reveal():
		start_dialogue(_get_staff_door_lines("post_reveal_stable", [
			{"speaker": "Staff Door", "text": "RESTORE PLAYBACK COMPLETE."},
			{"speaker": "Staff Door", "text": "RETURN NOT REQUIRED."},
		]))
		return
	if GameState.staff_room_unlocked:
		start_dialogue(_get_staff_door_lines("staff_room_available", [
			{"speaker": "Staff Door", "text": "ACCESS GRANTED."},
			{"speaker": "Staff Door", "text": "EMPLOYEE SIGNAL ACCEPTED."},
			{"speaker": "Staff Door", "text": "ENTER STAFF ROOM?"},
		]), Callable(SceneChanger, "go_to_staff_room"))
		return
	if GameState.lying_cabinets_completed and not GameState.circuit_soda_completed:
		start_dialogue(_get_staff_door_lines("maintenance_required", [
			{"speaker": "Staff Door", "text": "STAFF ACCESS LOCKED."},
			{"speaker": "Staff Door", "text": "CIRCUIT SODA ROUTE REQUIRED."},
			{"speaker": "Staff Door", "text": "FRACTURED SIGNAL UNSTABILIZED."},
		]))
		return
	if GameState.lost_token_quest_completed and not GameState.lying_cabinets_completed:
		start_dialogue(_get_staff_door_sequential_lines("truth_filter_required", [
			{"speaker": "Staff Door", "text": "STAFF ACCESS LOCKED."},
			{"speaker": "Staff Door", "text": "TRUTH FILTER REQUIRED."},
			{"speaker": "Staff Door", "text": "EMPLOYEE SIGNAL UNSTABLE."},
		]))
		return
	if GameState.lost_token_quest_completed and GameState.rockbyte_duel_completed and GameState.lying_cabinets_completed and GameState.circuit_soda_completed:
		start_dialogue(_get_staff_door_sequential_lines("maintenance_required", [
			{"speaker": "Staff Door", "text": "FRACTURED SIGNAL ACCEPTED."},
			{"speaker": "Staff Door", "text": "MAINTENANCE SYNC REQUIRED."},
			{"speaker": "Staff Door", "text": "GUS AUTHORIZATION REQUIRED."},
		]))
		return
	start_dialogue(_get_staff_door_sequential_lines("locked_grounded", [
		{"speaker": "Staff Door", "text": "STAFF ACCESS LOCKED."},
		{"speaker": "Staff Door", "text": "MEMORY TOKEN SIGNAL MISSING."},
	]))

func _handle_owner_portrait() -> void:
	if _is_post_reveal():
		GameState.owner_portrait_secret_found = true
		start_dialogue(_get_environment_lines("owner_portrait_restored", [
			{"speaker": "Owner Portrait", "text": "The scratched nameplate is readable now."},
			{"speaker": "Owner Portrait", "text": "It does not name the owner."},
			{"speaker": "Owner Portrait", "text": "It says: EMPLOYEE 04."},
		]))
		return
	if _can_show_act2_echo():
		GameState.echo_owner_portrait_04_seen = true
		start_dialogue(_get_environment_lines("owner_portrait_fractured", [
			{"speaker": "Owner Portrait", "text": "The scratches on the nameplate have shifted."},
			{"speaker": "Owner Portrait", "text": "Only two marks are readable."},
			{"speaker": "Owner Portrait", "text": "0 4"},
		]))
		return
	start_dialogue(_get_environment_state_lines("owner_portrait", [
		{"speaker": "Owner Portrait", "text": "The frame is cracked and the nameplate is scratched blank."},
	]))

func _handle_broken_cabinet(interactable: Node) -> void:
	if _is_post_reveal():
		start_dialogue(_get_environment_lines("broken_cabinet_restored", [
			{"speaker": "Broken Cabinet", "text": "I remember your first quarter."},
			{"speaker": "Broken Cabinet", "text": "You looked happier then."},
			{"speaker": "Broken Cabinet", "text": "Not better. Just earlier."},
		]))
		return
	interactable.broken_interaction_count += 1
	if interactable.broken_interaction_count >= 5:
		GameState.broken_cabinet_secret_found = true
		start_dialogue(_get_environment_lines("broken_cabinet_overloaded", [
			{"speaker": "Broken Cabinet", "text": "STOP PRESSING E. I AM TRYING TO REMEMBER."},
		]))
		return
	if interactable.broken_interaction_count == 3:
		start_dialogue(_get_environment_lines("broken_cabinet_fractured", [
			{"speaker": "Broken Cabinet", "text": "STILL OUT OF ORDER."},
		]))
		return
	start_dialogue(_get_environment_state_lines("broken_cabinet", [
		{"speaker": "Broken Cabinet", "text": "OUT OF ORDER."},
	]))

func _is_post_reveal() -> bool:
	return GameState.post_reveal_roam_unlocked or GameState.twist_reveal_seen

func _store_arcade_return_position() -> void:
	# SceneChanger captures this centrally now; kept for explicit call sites.
	if player:
		GameState.set_return_point(scene_file_path, player.global_position)

func _setup_ambient_sprite_effects() -> void:
	AMBIENT_EFFECTS.add(effects_layer, [
		{
			"name": "Cabinet07StaticSprite",
			"position": Vector2(490, 124),
			"scale": Vector2(1.6, 1.6),
			"effect_type": "random_screen_flash",
			"speed": 0.9,
			"intensity": 0.08,
			"sprite_sheet_path": AMBIENT_EFFECTS.STATIC_SPARK,
			"sprite_alpha": 0.86,
		},
		{
			"name": "BrokenCabinetStaticSprite",
			"position": Vector2(402, 356),
			"scale": Vector2(1.35, 1.35),
			"effect_type": "jitter",
			"speed": 1.15,
			"intensity": 0.1,
			"sprite_sheet_path": AMBIENT_EFFECTS.STATIC_SPARK,
			"sprite_alpha": 0.72,
		},
		{
			"name": "TruthFilterMemoryWisp",
			"position": Vector2(378, 244),
			"scale": Vector2(1.4, 1.4),
			"effect_type": "dust_mote_drift",
			"speed": 0.42,
			"intensity": 0.22,
			"only_when_memory_signal_at_least": 1,
			"active_flag_optional": "lost_token_quest_completed",
			"sprite_sheet_path": AMBIENT_EFFECTS.MEMORY_WISP,
			"sprite_frame_size": Vector2i(24, 16),
			"sprite_alpha": 0.78,
			"sprite_modulate": Color(1.0, 0.72, 1.0, 1.0),
		},
		{
			"name": "StaffDoorLockBlink",
			"position": Vector2(565, 284),
			"scale": Vector2(1.65, 1.65),
			"effect_type": "blink",
			"speed": 0.7,
			"intensity": 0.08,
			"only_when_memory_signal_at_least": 2,
			"sprite_sheet_path": AMBIENT_EFFECTS.STAFF_LOCK_BLINK,
			"sprite_alpha": 0.82,
		},
		{
			"name": "StaffDoorOpenPing",
			"position": Vector2(548, 250),
			"scale": Vector2(1.1, 1.1),
			"effect_type": "glow_pulse",
			"speed": 0.9,
			"intensity": 0.08,
			"active_flag_optional": "staff_room_unlocked",
			"sprite_sheet_path": AMBIENT_EFFECTS.BLINK_DOT,
			"sprite_alpha": 0.8,
			"sprite_modulate": Color(0.62, 1.0, 0.72, 1.0),
		},
		{
			"name": "VendoBubbleSprite",
			"position": Vector2(306, 281),
			"scale": Vector2(1.45, 1.45),
			"effect_type": "bob",
			"speed": 0.55,
			"intensity": 0.18,
			"sprite_sheet_path": AMBIENT_EFFECTS.SODA_BUBBLE,
			"sprite_alpha": 0.72,
		},
		{
			"name": "MrByteScanlineSprite",
			"position": Vector2(300, 202),
			"scale": Vector2(1.65, 1.65),
			"effect_type": "scanline_pulse",
			"speed": 0.7,
			"intensity": 0.07,
			"sprite_sheet_path": AMBIENT_EFFECTS.SCANLINE_BAR,
			"sprite_frame_size": Vector2i(32, 8),
			"sprite_alpha": 0.7,
		},
		{
			"name": "TicketCounterGlintA",
			"position": Vector2(96, 138),
			"scale": Vector2(1.25, 1.25),
			"effect_type": "random_screen_flash",
			"speed": 0.65,
			"intensity": 0.05,
			"sprite_sheet_path": AMBIENT_EFFECTS.TICKET_GLINT,
			"sprite_alpha": 0.62,
		},
		{
			"name": "TicketCounterGlintB",
			"position": Vector2(188, 148),
			"scale": Vector2(1.15, 1.15),
			"effect_type": "random_screen_flash",
			"speed": 0.52,
			"intensity": 0.04,
			"sprite_sheet_path": AMBIENT_EFFECTS.TICKET_GLINT,
			"sprite_alpha": 0.58,
		},
		{
			"name": "OwnerPortraitTwinkle",
			"position": Vector2(90, 78),
			"scale": Vector2(1.15, 1.15),
			"effect_type": "random_screen_flash",
			"speed": 0.48,
			"intensity": 0.04,
			"sprite_sheet_path": AMBIENT_EFFECTS.PRIZE_TWINKLE,
			"sprite_alpha": 0.56,
		},
	])

func _apply_hub_art() -> void:
	var has_background := _apply_sprite_texture(background_sprite, ASSET_PATHS.HUB_BACKGROUND_ARCADE)
	_set_children_visible(floor_layer, not has_background)
	_set_children_visible(wall_layer, not has_background)
	_apply_prop_sprite(
		ticket_counter_sprite,
		ASSET_PATHS.HUB_TICKET_COUNTER,
		[$PropLayer/TicketCounterVisual]
	)
	_apply_prop_sprite(
		cabinet_07_sprite,
		ASSET_PATHS.HUB_CABINET_07_IDLE,
		[$PropLayer/Cabinet07Visual, $PropLayer/Cabinet07Screen]
	)
	cabinet_07_flicker_sprite.visible = false
	cabinet_07_flicker_sprite.sprite_frames = null
	if _apply_animated_sprite_sheet(cabinet_07_flicker_sprite, ASSET_PATHS.HUB_CABINET_07_FLICKER_SHEET, 4, 0.24):
		cabinet_07_sprite.visible = false
	elif _apply_animated_sprite_sheet(cabinet_07_flicker_sprite, ASSET_PATHS.HUB_CABINET_07_FLICKER, 2, 0.32):
		cabinet_07_sprite.visible = false
	_apply_prop_sprite(
		broken_cabinet_sprite,
		ASSET_PATHS.HUB_BROKEN_CABINET,
		[$PropLayer/BrokenCabinetVisual, $PropLayer/BrokenCabinetScreen]
	)
	_refresh_hub_art_states()
	_start_cabinet_glow_pulse()

func _refresh_hub_art_states() -> void:
	if not is_node_ready():
		return
	var staff_door_path := ASSET_PATHS.HUB_STAFF_DOOR_OPEN if GameState.staff_room_unlocked else ASSET_PATHS.HUB_STAFF_DOOR_CLOSED
	_apply_prop_sprite(
		staff_door_sprite,
		staff_door_path,
		[$PropLayer/StaffDoorVisual, $PropLayer/StaffDoorHandle]
	)
	var owner_portrait_path := ASSET_PATHS.HUB_OWNER_PORTRAIT_EMPLOYEE04 if _is_post_reveal() else ASSET_PATHS.HUB_OWNER_PORTRAIT_BLANK
	_apply_prop_sprite(
		owner_portrait_sprite,
		owner_portrait_path,
		[$PropLayer/OwnerPortraitVisual, $PropLayer/OwnerPortraitInner]
	)
	if truth_filter_glow != null:
		truth_filter_glow.visible = false
		var glow_alpha := 0.2 if GameState.memory_signal_level >= GameState.MEMORY_SIGNAL_FRACTURED else 0.12
		truth_filter_glow.color = Color(0.8, 0.2, 1.0, glow_alpha)
	_update_act2_aftermath_pulse()

func _update_act2_aftermath_pulse() -> void:
	if aftermath_pulse_tween and aftermath_pulse_tween.is_valid():
		aftermath_pulse_tween.kill()
	aftermath_pulse_tween = null
	for item in [staff_door_visual, cabinet_07_screen, truth_filter_screen]:
		if item is CanvasItem:
			item.modulate = Color.WHITE
	if not GameState.lying_cabinets_completed or GameState.story_puzzle_completed:
		return
	aftermath_pulse_tween = create_tween()
	aftermath_pulse_tween.set_loops()
	aftermath_pulse_tween.set_parallel(true)
	aftermath_pulse_tween.tween_property(staff_door_visual, "modulate:a", 0.58, 0.72)
	aftermath_pulse_tween.tween_property(cabinet_07_screen, "modulate:a", 0.5, 0.58)
	aftermath_pulse_tween.tween_property(truth_filter_screen, "modulate:a", 0.48, 0.5)
	aftermath_pulse_tween.chain().set_parallel(true)
	aftermath_pulse_tween.tween_property(staff_door_visual, "modulate:a", 1.0, 0.72)
	aftermath_pulse_tween.tween_property(cabinet_07_screen, "modulate:a", 1.0, 0.58)
	aftermath_pulse_tween.tween_property(truth_filter_screen, "modulate:a", 1.0, 0.5)

func _apply_prop_sprite(sprite_node: Sprite2D, path: String, placeholders: Array) -> void:
	var loaded := _apply_sprite_texture(sprite_node, path)
	for placeholder in placeholders:
		if placeholder is CanvasItem:
			placeholder.visible = not loaded

func _apply_sprite_texture(sprite_node: Sprite2D, path: String) -> bool:
	sprite_node.visible = false
	sprite_node.texture = null
	var texture: Texture2D = ASSET_PATHS.load_texture_or_null(path)
	if texture == null:
		return false
	sprite_node.texture = texture
	sprite_node.visible = true
	return true

func _apply_animated_sprite_sheet(animated_sprite: AnimatedSprite2D, path: String, frame_count: int, frame_duration: float) -> bool:
	animated_sprite.visible = false
	animated_sprite.sprite_frames = null
	var texture: Texture2D = ASSET_PATHS.load_texture_or_null(path)
	if texture == null:
		return false
	var frame_total := maxi(frame_count, 1)
	var frame_width := maxi(int(texture.get_width() / frame_total), 1)
	var frame_height := maxi(texture.get_height(), 1)
	var frames := SpriteFrames.new()
	frames.add_animation("flicker")
	frames.set_animation_loop("flicker", true)
	frames.set_animation_speed("flicker", 1.0 / maxf(frame_duration, 0.05))
	for index in range(frame_total):
		var atlas := AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = Rect2(index * frame_width, 0, frame_width, frame_height)
		frames.add_frame("flicker", atlas)
	animated_sprite.sprite_frames = frames
	animated_sprite.animation = "flicker"
	animated_sprite.visible = true
	animated_sprite.play("flicker")
	return true

func _set_children_visible(parent_node: Node, visible: bool) -> void:
	for child in parent_node.get_children():
		if child is CanvasItem:
			child.visible = visible

func _start_cabinet_glow_pulse() -> void:
	if cabinet_glow_tween and cabinet_glow_tween.is_valid():
		cabinet_glow_tween.kill()
	if not cabinet_07_flicker_sprite.visible and not cabinet_07_sprite.visible:
		return
	var glow_target: CanvasItem = cabinet_07_flicker_sprite if cabinet_07_flicker_sprite.visible else cabinet_07_sprite
	glow_target.modulate = Color(1, 1, 1, 0.75)
	cabinet_glow_tween = create_tween()
	cabinet_glow_tween.set_loops()
	cabinet_glow_tween.tween_property(glow_target, "modulate:a", 1.0, 0.42)
	cabinet_glow_tween.tween_property(glow_target, "modulate:a", 0.45, 0.28)
	cabinet_glow_tween.tween_property(glow_target, "modulate:a", 0.8, 0.55)

func _offer_rockbyte_replay() -> void:
	PostGameReplay.open_offer(ui_layer, player, "Play the duel again?", "rockbyte", Callable(self, "_launch_rockbyte_replay"))

func _launch_rockbyte_replay() -> void:
	_store_arcade_return_position()
	SceneChanger.go_to_rockbyte_duel()
