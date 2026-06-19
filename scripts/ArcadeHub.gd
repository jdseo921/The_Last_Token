extends Node2D

const ASSET_PATHS := preload("res://scripts/AssetPaths.gd")
const MIRA_IDLE_SHEET_PATH := "res://assets/art/characters/mira/mira_idle_sheet.png"
const GUS_IDLE_SHEET_PATH := "res://assets/art/characters/gus/gus_idle_sheet.png"
const VENDO_IDLE_SHEET_PATH := "res://assets/art/characters/vendo/vendo_idle_sheet.png"
const MR_BYTE_IDLE_SHEET_PATH := "res://assets/art/characters/mr_byte/mr_byte_idle_sheet.png"
const PORTRAIT_MIRA_WORRIED := "res://assets/art/portraits/mira/mira_worried.png"
const PORTRAIT_GUS_ANNOYED := "res://assets/art/portraits/gus/gus_annoyed.png"
const PORTRAIT_CABINET_07_SCREEN := "res://assets/art/portraits/mr_byte/cabinet_07_screen.png"
const PORTRAIT_PLAYER_NEUTRAL := "res://assets/art/portraits/player/player_neutral.png"

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
@onready var dialogue_box: CanvasLayer = $UILayer/DialogueBox
@onready var prompt_label: Label = $UILayer/InteractionPrompt
@onready var prompt_background: ColorRect = $UILayer/InteractionPromptBackground
@onready var hint_label: Label = $UILayer/HintLabel
@onready var post_reveal_hint_label: Label = $UILayer/PostRevealHintLabel
@onready var objective_hint_background: ColorRect = $UILayer/ObjectiveHintBackground
@onready var objective_hint_label: Label = $UILayer/ObjectiveHintLabel
@onready var memory_signal_background: ColorRect = $UILayer/MemorySignalBackground
@onready var memory_signal_label: Label = $UILayer/MemorySignalLabel
@onready var quest_notice: CanvasLayer = $QuestNotice
@onready var intro_fade_overlay: ColorRect = $IntroFadeLayer/IntroFadeOverlay
@onready var pause_menu: CanvasLayer = $PauseMenu
@onready var truth_filter_glow: Polygon2D = $EffectsLayer/TruthFilterGlow

var save_slot_menu: Control = null
var choice_box: CanvasLayer = null
var pending_after_dialogue: Callable = Callable()
var cabinet_glow_tween: Tween = null
var intro_active := false
var intro_fade_tween: Tween = null
var last_dialogue_repeat_count := 0
var memory_signal_tween: Tween = null
var aftermath_pulse_tween: Tween = null

func _ready() -> void:
	_apply_hub_art()
	player.interaction_prompt_changed.connect(_on_prompt_changed)
	dialogue_box.dialogue_finished.connect(_on_dialogue_finished)
	_apply_spawn_position()
	_on_prompt_changed("")
	_refresh_hint()
	_refresh_objective_hint()
	_refresh_hub_art_states()
	if _should_play_opening_intro():
		call_deferred("_play_opening_intro")
	else:
		call_deferred("_maybe_show_quest_notification")

func _process(_delta: float) -> void:
	_refresh_objective_hint_visibility()

func _apply_spawn_position() -> void:
	var spawn_id := GameState.consume_pending_spawn_id("")
	if not spawn_id.is_empty():
		var marker := get_node_or_null(spawn_id)
		if marker is Marker2D:
			player.global_position = marker.global_position
			return
	if GameState.has_arcade_return_position:
		player.global_position = GameState.arcade_return_position
		GameState.clear_arcade_return_position()
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

func _choice_box_is_open() -> bool:
	return choice_box != null and is_instance_valid(choice_box) and choice_box.visible

func _refresh_hint() -> void:
	hint_label.visible = false
	post_reveal_hint_label.visible = GameState.post_reveal_roam_unlocked and not _dialogue_is_active() and not _choice_box_is_open() and not _save_slot_menu_is_open()

func _refresh_objective_hint() -> void:
	objective_hint_label.text = _get_objective_hint_text()
	_refresh_memory_signal_label()
	_refresh_objective_hint_visibility()
	_refresh_hub_art_states()

func _refresh_objective_hint_visibility() -> void:
	if objective_hint_label == null or objective_hint_background == null:
		return
	var should_show := _objective_hint_should_be_visible()
	objective_hint_label.visible = should_show
	objective_hint_background.visible = should_show
	if memory_signal_label != null and memory_signal_background != null:
		memory_signal_label.visible = should_show
		memory_signal_background.visible = should_show

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
	if not GameState.story_started:
		return "Objective: Talk to Mira."
	if GameState.lost_token_quest_started and not GameState.rockbyte_duel_completed:
		return "Objective: Play Cabinet 07."
	if GameState.rockbyte_duel_completed and not GameState.lost_token_quest_completed:
		return "Objective: Return the Lost Token to Mira."
	if GameState.lost_token_quest_completed and not GameState.lying_cabinets_completed:
		return "Objective: Find Mr. Byte in Cabinet Row."
	if GameState.lying_cabinets_completed and not GameState.circuit_soda_completed:
		return "Objective: Find Vendo in the Snack Alcove."
	if GameState.circuit_soda_completed and not GameState.lost_shift_file_completed and not GameState.story_puzzle_completed:
		return "Objective: Find the Lost Shift File."
	if GameState.lost_shift_file_completed and not GameState.static_service_run_completed and not GameState.story_puzzle_completed:
		return "Objective: Restore service power with Gus."
	if GameState.static_service_run_completed and not GameState.story_puzzle_completed:
		return "Objective: Complete Maintenance Sync."
	if GameState.lying_cabinets_completed and not GameState.story_puzzle_completed:
		return "Objective: Find Gus in Maintenance Hall."
	if GameState.security_tape_assembly_completed and not GameState.final_night_walk_completed:
		return "Objective: Walk the Final Night route."
	if GameState.final_night_walk_completed and not GameState.memory_echo_completed:
		return "Objective: Stabilize the Memory Echo."
	if GameState.maintenance_sync_completed and not GameState.memory_echo_completed:
		return "Objective: Enter the Staff Corridor."
	if GameState.memory_echo_completed and not GameState.twist_reveal_seen:
		return "Objective: Enter the Staff Room."
	if GameState.twist_reveal_seen and not GameState.post_reveal_roam_unlocked:
		return "Objective: Finish the memory."
	if GameState.post_reveal_roam_unlocked:
		return "Objective: Talk to those who remembered you."
	return ""

func _refresh_memory_signal_label() -> void:
	GameState.update_memory_signal_from_progress()
	if memory_signal_label == null:
		return
	memory_signal_label.text = "Memory Signal: %s" % GameState.get_memory_signal_label()
	match GameState.memory_signal_level:
		GameState.MEMORY_SIGNAL_FRACTURED:
			memory_signal_label.modulate = Color(1.0, 0.78, 1.0, 1.0)
		GameState.MEMORY_SIGNAL_UNEASY:
			memory_signal_label.modulate = Color(0.82, 0.95, 1.0, 1.0)
		_:
			memory_signal_label.modulate = Color.WHITE

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
		{"speaker": "Player", "text": "Pixel Haven. The name is already in my head. My own name is not.", "portrait": PORTRAIT_PLAYER_NEUTRAL},
		{"speaker": "Player", "text": "I remember carpet patterns, machine hum, and the smell of old tickets. I do not remember walking in.", "portrait": PORTRAIT_PLAYER_NEUTRAL},
		{"speaker": "Player", "text": "Something is missing from my pocket. A token, maybe. Or the reason I came back.", "portrait": PORTRAIT_PLAYER_NEUTRAL},
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
	if intro_active or _dialogue_is_active() or _choice_box_is_open() or _save_slot_menu_is_open():
		return
	var quest_id := GameState.get_current_quest_id()
	if quest_id.is_empty() or quest_id == GameState.last_announced_quest_id:
		return
	if quest_notice and quest_notice.has_method("show_notification"):
		quest_notice.call("show_notification", GameState.get_current_quest_data())
	GameState.mark_current_quest_announced()

func handle_hub_interaction(interactable: Node, player_node: Node = null) -> void:
	match str(interactable.interactable_kind):
		"mira":
			_handle_mira()
		"ticket_counter":
			_handle_ticket_counter()
		"gus":
			_handle_gus()
		"vendo":
			_handle_vendo()
		"mr_byte":
			_handle_mr_byte()
		"cabinet07":
			_handle_cabinet_07()
		"truth_filter":
			_handle_truth_filter()
		"staff_door":
			_handle_staff_door()
		"owner_portrait":
			_handle_owner_portrait()
		"broken_cabinet":
			_handle_broken_cabinet(interactable)
		"closing_checklist":
			_handle_closing_checklist()
		_:
			start_dialogue([{"speaker": "System", "text": "Nothing happens."}])

func _can_show_act2_echo() -> bool:
	return GameState.lying_cabinets_completed and not GameState.twist_reveal_seen

func _get_ticket_counter_echo_lines() -> Array:
	GameState.echo_ticket_counter_seen = true
	return [
		{"speaker": "Narrator", "text": "The ticket counter glass reflects someone standing beside you."},
		{"speaker": "Narrator", "text": "For a moment, the reflection wears your shape."},
		{"speaker": "Narrator", "text": "It mouths: 'not the first.'"},
	]

func _get_cabinet07_echo_lines() -> Array:
	GameState.echo_cabinet07_seen = true
	return [
		{"speaker": "Cabinet 07", "text": "PREVIOUS PLAYER PROFILE FOUND.", "portrait": PORTRAIT_CABINET_07_SCREEN},
		{"speaker": "Cabinet 07", "text": "STATUS: DAMAGED.", "portrait": PORTRAIT_CABINET_07_SCREEN},
		{"speaker": "Cabinet 07", "text": "RESTORE ATTEMPT: CONTINUING.", "portrait": PORTRAIT_CABINET_07_SCREEN},
	]

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
			"Pixel Haven remembers you in pieces. Together, they almost make a person."
		)

func _handle_mira() -> void:
	if _is_post_reveal():
		var was_completed := _was_witness_route_completed()
		GameState.mira_post_reveal_seen = true
		GameState.mark_witness_mira_heard()
		start_dialogue([
			{"speaker": "Mira", "text": "You finally remembered."},
			{"speaker": "Mira", "text": "I was worried you would choose to disappear again.", "portrait": PORTRAIT_MIRA_WORRIED},
			{"speaker": "Mira", "text": "But you are still here.", "portrait": PORTRAIT_MIRA_WORRIED},
			{"speaker": "Mira", "text": "That counts for something."},
		], _get_witness_completion_callback(was_completed))
		return
	if GameState.lost_token_quest_completed and not GameState.mira_rockbyte_anecdote_seen:
		GameState.mira_rockbyte_anecdote_seen = true
		start_dialogue([
			{"speaker": "Mira", "text": "You brought it back.", "portrait": PORTRAIT_MIRA_WORRIED},
			{"speaker": "Mira", "text": "That token used to be just a prize."},
			{"speaker": "Mira", "text": "Then it became proof that part of you could still return."},
			{"speaker": "Mira", "text": "It remembered you before you did."},
		])
		return
	if GameState.memory_echo_completed and not GameState.twist_reveal_seen:
		start_dialogue([
			{"speaker": "Mira", "text": "If the Staff Room opens, do not rush past what it shows you.", "portrait": PORTRAIT_MIRA_WORRIED},
			{"speaker": "Mira", "text": "You have already survived not knowing."},
			{"speaker": "Mira", "text": "Now you have to survive remembering."},
		])
		return
	if _can_show_act2_echo() and not GameState.echo_ticket_counter_seen:
		start_dialogue(_get_ticket_counter_echo_lines())
		return
	if not GameState.lost_token_quest_started:
		GameState.mira_intro_seen = true
		start_dialogue([
			{"speaker": "Mira", "text": "You made it back."},
			{"speaker": "Mira", "text": "I was starting to think the door had forgotten how to let you in."},
			{"speaker": "Player", "text": "I know this place, but I do not know why. Do you know me?", "portrait": PORTRAIT_PLAYER_NEUTRAL},
			{"speaker": "Mira", "text": "A little. More than you do right now, I think."},
			{"speaker": "Mira", "text": "Cabinet 07 has your Lost Token."},
			{"speaker": "Mira", "text": "Please bring it back to me."},
		], Callable(GameState, "start_lost_token_quest"))
		return
	if GameState.lost_token_quest_started and not GameState.lost_token_collected:
		start_dialogue(_select_repeat_dialogue("mira", [
			[
				{"speaker": "Mira", "text": "Cabinet 07 is waiting."},
				{"speaker": "Mira", "text": "It only opens for signals it almost remembers."},
				{"speaker": "Player", "text": "That sounds like a terrible way to recognize someone.", "portrait": PORTRAIT_PLAYER_NEUTRAL},
				{"speaker": "Mira", "text": "Around here, it counts as friendly."},
			],
			[
				{"speaker": "Mira", "text": "If Cabinet 07 gets strange, stay calm."},
				{"speaker": "Mira", "text": "It was strange before all of this too."},
				{"speaker": "Player", "text": "All of what?", "portrait": PORTRAIT_PLAYER_NEUTRAL},
				{"speaker": "Mira", "text": "Start with the token. The rest will catch up."},
			],
		], [
			[
				{"speaker": "Mira", "text": "I promise I am not brushing you off."},
				{"speaker": "Mira", "text": "But Cabinet 07 is the next step."},
			],
			[
				{"speaker": "Mira", "text": "Go on. I will be right here."},
				{"speaker": "Mira", "text": "I have had a lot of practice waiting."},
			],
		]))
		return
	if GameState.lost_token_collected and not GameState.lost_token_quest_completed:
		start_dialogue([
			{"speaker": "Player", "text": "I found the Lost Token. It felt like it already belonged to me.", "portrait": PORTRAIT_PLAYER_NEUTRAL},
			{"speaker": "Mira", "text": "The token woke something.", "portrait": PORTRAIT_MIRA_WORRIED},
			{"speaker": "Mira", "text": "Now the arcade has to decide which memories are true."},
			{"speaker": "Mira", "text": "Mr. Byte can open the Truth Filter in Cabinet Row."},
		], Callable(self, "_complete_lost_token_with_mira_anecdote"))
		return
	if GameState.lost_token_quest_completed and not GameState.lying_cabinets_completed:
		start_dialogue(_select_repeat_dialogue("mira", [
			[
				{"speaker": "Mira", "text": "The token woke something."},
				{"speaker": "Mira", "text": "Now the arcade has to decide which memories are true."},
				{"speaker": "Mira", "text": "Mr. Byte can open the Truth Filter in Cabinet Row."},
			],
			[
				{"speaker": "Mira", "text": "Memory Signal feels different now.", "portrait": PORTRAIT_MIRA_WORRIED},
				{"speaker": "Mira", "text": "Uneasy, but not broken."},
				{"speaker": "Mira", "text": "Mr. Byte is waiting in Cabinet Row."},
			],
		], [
			[
				{"speaker": "Mira", "text": "Cabinet Row first. Staff Door after."},
				{"speaker": "Mira", "text": "I know. The arcade makes terrible queues."},
			],
		]))
		return
	if GameState.lying_cabinets_completed and not GameState.circuit_soda_completed:
		start_dialogue(_select_repeat_dialogue("mira", [
			[
				{"speaker": "Mira", "text": "Your Memory Signal is Fractured now."},
				{"speaker": "Mira", "text": "Vendo says fractured things still need somewhere to flow.", "portrait": PORTRAIT_MIRA_WORRIED},
			],
			[
				{"speaker": "Mira", "text": "Snack Alcove is the next stop."},
				{"speaker": "Mira", "text": "Try not to let Vendo make this sound more normal than it is."},
			],
		], [
			[
				{"speaker": "Mira", "text": "Talk to Vendo in Snack Alcove."},
				{"speaker": "Mira", "text": "Then we can see whether the Staff Door listens."},
			],
		]))
		return
	if GameState.circuit_soda_completed and not GameState.lost_shift_file_completed and not GameState.story_puzzle_completed:
		GameState.start_lost_shift_file()
		if not GameState.mira_lost_shift_intro_seen:
			GameState.mira_lost_shift_intro_seen = true
			start_dialogue([
				{"speaker": "Mira", "text": "Vendo routed the signal, but something is still missing.", "portrait": PORTRAIT_MIRA_WORRIED},
				{"speaker": "Mira", "text": "Gus keeps old maintenance notes."},
				{"speaker": "Mira", "text": "Mr. Byte can read staff records the machines refuse to say out loud."},
				{"speaker": "Mira", "text": "Find the Lost Shift File before you ask the door to listen."},
			])
			return
		start_dialogue(_select_repeat_dialogue("mira_lost_shift", [
			[
				{"speaker": "Mira", "text": "The Lost Shift File will not be in one place."},
				{"speaker": "Mira", "text": "Start with the closing checklist near the counter."},
			],
			[
				{"speaker": "Mira", "text": "Gus has the repair note. Mr. Byte has the staff schedule."},
				{"speaker": "Mira", "text": "I wish those sounded less connected.", "portrait": PORTRAIT_MIRA_WORRIED},
			],
		], [
			[
				{"speaker": "Mira", "text": "Read the checklist, the maintenance note, and the staff schedule."},
			],
		]))
		return
	if GameState.lost_shift_file_completed and not GameState.story_puzzle_completed:
		start_dialogue([
			{"speaker": "Mira", "text": "That was the shift we stopped talking about.", "portrait": PORTRAIT_MIRA_WORRIED},
			{"speaker": "Mira", "text": "I am sorry you had to read it before you remembered it."},
		])
		return
	if GameState.lying_cabinets_completed and not GameState.story_puzzle_completed:
		start_dialogue(_select_repeat_dialogue("mira", [
			[
				{"speaker": "Mira", "text": "You heard the contradictions and came back anyway.", "portrait": PORTRAIT_MIRA_WORRIED},
				{"speaker": "Mira", "text": "That is good."},
				{"speaker": "Mira", "text": "That is also worrying."},
			],
			[
				{"speaker": "Mira", "text": "Your Memory Signal is Fractured now."},
				{"speaker": "Mira", "text": "That means the Staff Door may finally listen."},
			],
		], [
			[
				{"speaker": "Mira", "text": "Go check the Staff Door."},
				{"speaker": "Mira", "text": "I will try not to look dramatically worried.", "portrait": PORTRAIT_MIRA_WORRIED},
			],
		]))
		return
	start_dialogue(_select_repeat_dialogue("mira", [
		[
			{"speaker": "Mira", "text": "The Staff Door used to stick even when it liked you."},
			{"speaker": "Mira", "text": "If it opens cleanly, that is probably a good sign."},
		],
		[
			{"speaker": "Mira", "text": "You brought back more than a token."},
			{"speaker": "Mira", "text": "I wish I knew whether to be relieved or afraid.", "portrait": PORTRAIT_MIRA_WORRIED},
		],
	], [
		[
			{"speaker": "Mira", "text": "Go check the Staff Door."},
			{"speaker": "Mira", "text": "I will try not to look dramatically worried.", "portrait": PORTRAIT_MIRA_WORRIED},
		],
	]))

func _complete_lost_token_with_mira_anecdote() -> void:
	GameState.complete_lost_token_quest()

func _handle_ticket_counter() -> void:
	if _can_show_act2_echo() and not GameState.echo_ticket_counter_seen:
		start_dialogue(_get_ticket_counter_echo_lines())
		return
	start_dialogue([
		{"speaker": "Narrator", "text": "The ticket counter glass is dark and dusty."},
	])

func _handle_gus() -> void:
	if _is_post_reveal():
		var was_completed := _was_witness_route_completed()
		GameState.gus_post_reveal_seen = true
		GameState.mark_witness_gus_heard()
		start_dialogue([
			{"speaker": "Gus", "text": "About time.", "portrait": PORTRAIT_GUS_ANNOYED},
			{"speaker": "Gus", "text": "I was almost out of practical hints.", "portrait": PORTRAIT_GUS_ANNOYED},
			{"speaker": "Gus", "text": "You came back anyway. Good."},
		], _get_witness_completion_callback(was_completed))
		return
	if GameState.lost_token_quest_completed and not GameState.lying_cabinets_completed:
		start_dialogue(_select_repeat_dialogue("gus", [
			[
				{"speaker": "Gus", "text": "Careful now."},
				{"speaker": "Gus", "text": "Once the machines start correcting memories, they get picky."},
			],
			[
				{"speaker": "Gus", "text": "Truth Filter cabinet is over in Cabinet Row."},
				{"speaker": "Gus", "text": "Mr. Byte is the one acting like he grades homework."},
			],
		], [
			[
				{"speaker": "Gus", "text": "Cabinet Row. Then Staff Door."},
				{"speaker": "Gus", "text": "One weird chore at a time.", "portrait": PORTRAIT_GUS_ANNOYED},
			],
		]))
		return
	if GameState.lying_cabinets_completed and not GameState.circuit_soda_completed:
		start_dialogue(_select_repeat_dialogue("gus", [
			[
				{"speaker": "Gus", "text": "Signal's fractured."},
				{"speaker": "Gus", "text": "Vendo has a machine for that, because of course he does.", "portrait": PORTRAIT_GUS_ANNOYED},
			],
			[
				{"speaker": "Gus", "text": "Snack Alcove first."},
				{"speaker": "Gus", "text": "Then bring that stabilized weirdness back toward maintenance."},
			],
		], [
			[
				{"speaker": "Gus", "text": "Vendo. Snack Alcove. Circuit Soda."},
				{"speaker": "Gus", "text": "I do not name these things.", "portrait": PORTRAIT_GUS_ANNOYED},
			],
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
	start_dialogue(_select_repeat_dialogue("gus", [
		[
			{"speaker": "Gus", "text": "You again. Great.", "portrait": PORTRAIT_GUS_ANNOYED},
			{"speaker": "Gus", "text": "I just finished cleaning up the previous session."},
			{"speaker": "Player", "text": "Previous session?", "portrait": PORTRAIT_PLAYER_NEUTRAL},
			{"speaker": "Gus", "text": "Arcade talk. Means I found tickets in places tickets should fear."},
		],
		[
			{"speaker": "Gus", "text": "Pixel Haven used to have more staff."},
			{"speaker": "Gus", "text": "Then one disappeared, and management solved it by pretending schedules are optional."},
			{"speaker": "Gus", "text": "Classic management."},
		],
	], [
		[
			{"speaker": "Gus", "text": "Mira first. Existential panic after.", "portrait": PORTRAIT_GUS_ANNOYED},
		],
		[
			{"speaker": "Gus", "text": "I am very busy holding this place together with a mop and resentment."},
			{"speaker": "Gus", "text": "Go talk to the person with actual emotional range.", "portrait": PORTRAIT_GUS_ANNOYED},
		],
	]))

func _handle_vendo() -> void:
	if GameState.post_reveal_roam_unlocked and GameState.vendo_memory_riddle_secret_found:
		var was_completed := _was_witness_route_completed()
		GameState.vendo_post_reveal_seen = true
		GameState.mark_witness_vendo_heard()
		start_dialogue([
			{"speaker": "Vendo", "text": "Turns out MEMORY COLA was not a metaphor."},
			{"speaker": "Vendo", "text": "Legally, that should have been on the label."},
		], _get_witness_completion_callback(was_completed))
		return
	if _is_post_reveal():
		var was_completed_default := _was_witness_route_completed()
		GameState.vendo_post_reveal_seen = true
		GameState.mark_witness_vendo_heard()
		start_dialogue([
			{"speaker": "Vendo", "text": "Congratulations, valued stored file."},
			{"speaker": "Vendo", "text": "Your memory has been partially restored."},
			{"speaker": "Vendo", "text": "Refunds remain impossible."},
		], _get_witness_completion_callback(was_completed_default))
		return
	if GameState.lost_token_quest_completed and not GameState.lying_cabinets_completed:
		GameState.vendo_intro_seen = true
		start_dialogue(_select_repeat_dialogue("vendo", [
			[
				{"speaker": "Vendo", "text": "Memory Signal: Uneasy."},
				{"speaker": "Vendo", "text": "Please enjoy a refreshing sense of doubt."},
			],
			[
				{"speaker": "Vendo", "text": "Truth Filter is now available in Cabinet Row."},
				{"speaker": "Vendo", "text": "Warning: contains truths. May be bitter."},
			],
		], [
			[
				{"speaker": "Vendo", "text": "Please proceed to Mr. Byte."},
				{"speaker": "Vendo", "text": "Lingering near vending units does not count as therapy."},
			],
		]))
		return
	if GameState.lying_cabinets_completed and not GameState.circuit_soda_completed:
		GameState.vendo_intro_seen = true
		start_dialogue(_select_repeat_dialogue("vendo", [
			[
				{"speaker": "Vendo", "text": "Memory Signal: Fractured."},
				{"speaker": "Vendo", "text": "Suggested treatment: visit my legally distinct signal-routing beverage machine."},
			],
			[
				{"speaker": "Vendo", "text": "Please report to Snack Alcove."},
				{"speaker": "Vendo", "text": "Circuit Soda accepts unstable identities and exact change."},
			],
		], [
			[
				{"speaker": "Vendo", "text": "Snack Alcove is open."},
				{"speaker": "Vendo", "text": "Try not to spill identity on the carpet."},
			],
		]))
		return
	if GameState.lying_cabinets_completed and not GameState.story_puzzle_completed:
		GameState.vendo_intro_seen = true
		start_dialogue(_select_repeat_dialogue("vendo", [
			[
				{"speaker": "Vendo", "text": "Memory Signal: Fractured."},
				{"speaker": "Vendo", "text": "Would you like that in a can?"},
			],
			[
				{"speaker": "Vendo", "text": "The Truth Filter says you passed."},
				{"speaker": "Vendo", "text": "I say you look worse. Both may be true."},
			],
		], [
			[
				{"speaker": "Vendo", "text": "Next recommendation: Staff Door."},
				{"speaker": "Vendo", "text": "Hydration status: emotionally irrelevant."},
			],
		]))
		return
	if GameState.vendo_memory_riddle_secret_found:
		GameState.vendo_intro_seen = true
		start_dialogue(_select_repeat_dialogue("vendo", [
			[
				{"speaker": "Vendo", "text": "Memory Cola is sold out."},
				{"speaker": "Vendo", "text": "Mostly because you keep losing it."},
			],
			[
				{"speaker": "Vendo", "text": "Mira smiles like someone reading the last page first."},
				{"speaker": "Vendo", "text": "Terrible habit. Excellent customer retention."},
			],
		], [
			[
				{"speaker": "Vendo", "text": "Please proceed to the glowing machine with boundary issues."},
			],
		]))
		return
	if GameState.lost_token_quest_started:
		GameState.vendo_intro_seen = true
		var quest_lines: Array = _select_repeat_dialogue("vendo", [
			[
				{"speaker": "Vendo", "text": "Cabinet 07 does not recognize customers."},
				{"speaker": "Vendo", "text": "Only employees."},
				{"speaker": "Vendo", "text": "Care for a beverage-based psychological evaluation?"},
			],
			[
				{"speaker": "Vendo", "text": "The missing staff member used to stand near that cabinet."},
				{"speaker": "Vendo", "text": "Or maybe I made that up for atmosphere."},
				{"speaker": "Vendo", "text": "Care for a beverage-based psychological evaluation?"},
			],
		], [
			[
				{"speaker": "Vendo", "text": "You have selected: delay."},
				{"speaker": "Vendo", "text": "Suggested pairing: go play Cabinet 07."},
			],
			[
				{"speaker": "Vendo", "text": "Cabinet 07 is still waiting."},
				{"speaker": "Vendo", "text": "Its patience is artificial. Mine is not."},
			],
		])
		var after_vendo: Callable = Callable(self, "_open_vendo_memory_riddle") if last_dialogue_repeat_count <= 2 else Callable()
		start_dialogue(quest_lines, after_vendo)
		return
	GameState.vendo_intro_seen = true
	var opening_lines: Array = _select_repeat_dialogue("vendo", [
		[
			{"speaker": "Vendo", "text": "Welcome, valued almost-customer."},
			{"speaker": "Vendo", "text": "Please select a beverage or a coping mechanism."},
			{"speaker": "Vendo", "text": "Care for a beverage-based psychological evaluation?"},
		],
		[
			{"speaker": "Vendo", "text": "Pixel Haven arcade: closed to the public, open to consequences."},
			{"speaker": "Vendo", "text": "Mira knows more. She always does. Very unfair brand positioning."},
			{"speaker": "Vendo", "text": "Care for a beverage-based psychological evaluation?"},
		],
	], [
		[
			{"speaker": "Vendo", "text": "Talk to Mira before staring into vending enlightenment again."},
		],
	])
	var after_opening_vendo: Callable = Callable(self, "_open_vendo_memory_riddle") if last_dialogue_repeat_count <= 2 else Callable()
	start_dialogue(opening_lines, after_opening_vendo)

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
		start_dialogue([
			{"speaker": "Vendo", "text": "Correct."},
			{"speaker": "Vendo", "text": "You lose memory."},
			{"speaker": "Vendo", "text": "I lose coins."},
			{"speaker": "Vendo", "text": "We all suffer in our own branded containers."},
		])
		return
	start_dialogue([
		{"speaker": "Vendo", "text": "Incorrect."},
		{"speaker": "Vendo", "text": "But emotionally marketable."},
		{"speaker": "Vendo", "text": "Try again after your next identity crisis."},
	])

func _on_vendo_riddle_choice_cancelled() -> void:
	if choice_box and is_instance_valid(choice_box):
		choice_box.queue_free()
	choice_box = null
	if player and player.has_method("set_control_enabled"):
		player.set_control_enabled(true)
	_refresh_hint()
	_refresh_objective_hint()

func _handle_mr_byte() -> void:
	if _is_post_reveal():
		var was_completed := _was_witness_route_completed()
		GameState.mr_byte_post_reveal_seen = true
		GameState.employee_04_file_found = true
		GameState.mark_witness_mr_byte_heard()
		start_dialogue(_select_repeat_dialogue("mr_byte", [
			[
				{"speaker": "Mr. Byte", "text": "Identity conflict resolved."},
				{"speaker": "Mr. Byte", "text": "Emotional cache remains unstable."},
				{"speaker": "Mr. Byte", "text": "Recommended action: talk to those who remembered you."},
			],
			[
				{"speaker": "Mr. Byte", "text": "Employee file no longer missing."},
				{"speaker": "Mr. Byte", "text": "Employee comfort level: not detected."},
			],
		], [
			[
				{"speaker": "Mr. Byte", "text": "Repeated query detected."},
				{"speaker": "Mr. Byte", "text": "Recommendation unchanged: proceed."},
			],
		]), _get_witness_completion_callback(was_completed))
		return
	if GameState.lost_token_quest_completed and not GameState.lying_cabinets_completed:
		GameState.mr_byte_intro_seen = true
		start_dialogue(_select_repeat_dialogue("mr_byte", [
			[
				{"speaker": "Mr. Byte", "text": "Remote kiosk limited."},
				{"speaker": "Mr. Byte", "text": "Primary Truth Filter access is in Cabinet Row."},
			],
			[
				{"speaker": "Mr. Byte", "text": "Memory Signal: Uneasy."},
				{"speaker": "Mr. Byte", "text": "Recommended action: proceed to Cabinet Row."},
			],
		], [
			[
				{"speaker": "Mr. Byte", "text": "Repeated help request logged."},
				{"speaker": "Mr. Byte", "text": "Proceed to Cabinet Row."},
			],
		]))
		return
	if GameState.lying_cabinets_completed and not GameState.circuit_soda_completed:
		GameState.mr_byte_intro_seen = true
		start_dialogue(_select_repeat_dialogue("mr_byte", [
			[
				{"speaker": "Mr. Byte", "text": "Truth Filter passed."},
				{"speaker": "Mr. Byte", "text": "Fractured signal requires route stabilization."},
			],
			[
				{"speaker": "Mr. Byte", "text": "Next owner: Vendo."},
				{"speaker": "Mr. Byte", "text": "Location: Snack Alcove."},
			],
		], [
			[
				{"speaker": "Mr. Byte", "text": "Current objective unchanged."},
				{"speaker": "Mr. Byte", "text": "Proceed to Snack Alcove."},
			],
		]))
		return
	if GameState.lying_cabinets_completed and not GameState.story_puzzle_completed:
		GameState.mr_byte_intro_seen = true
		start_dialogue(_select_repeat_dialogue("mr_byte", [
			[
				{"speaker": "Mr. Byte", "text": "Truth Filter passed."},
				{"speaker": "Mr. Byte", "text": "Contradictions remain stable."},
			],
			[
				{"speaker": "Mr. Byte", "text": "Second memory fragment detected."},
				{"speaker": "Mr. Byte", "text": "Staff Door access test recommended."},
			],
		], [
			[
				{"speaker": "Mr. Byte", "text": "Current objective unchanged."},
				{"speaker": "Mr. Byte", "text": "Check Staff Door."},
			],
		]))
		return
	GameState.mr_byte_intro_seen = true
	start_dialogue(_select_repeat_dialogue("mr_byte", [
		[
			{"speaker": "Mr. Byte", "text": "Help menu loaded."},
			{"speaker": "Mr. Byte", "text": "Tip: Mira has your first objective."},
			{"speaker": "Mr. Byte", "text": "Warning: machines remember things."},
		],
		[
			{"speaker": "Mr. Byte", "text": "Staff directory status: incomplete."},
			{"speaker": "Mr. Byte", "text": "Missing staff record detected near current user."},
			{"speaker": "Player", "text": "Near me, or about me?", "portrait": PORTRAIT_PLAYER_NEUTRAL},
			{"speaker": "Mr. Byte", "text": "Clarification unavailable."},
		],
	], [
		[
			{"speaker": "Mr. Byte", "text": "Help loop exhausted."},
			{"speaker": "Mr. Byte", "text": "Please complete active objective."},
		],
		[
			{"speaker": "Mr. Byte", "text": "Additional hesitation detected."},
			{"speaker": "Mr. Byte", "text": "Please consult Mira or Cabinet 07."},
		],
	]))

func _handle_cabinet_07() -> void:
	if _is_post_reveal():
		var was_completed := _was_witness_route_completed()
		GameState.mark_witness_cabinet07_heard()
		start_dialogue([
			{"speaker": "Cabinet 07", "text": "EMPLOYEE 04 RESTORE STATUS: STABLE.", "portrait": PORTRAIT_CABINET_07_SCREEN},
			{"speaker": "Cabinet 07", "text": "WELCOME BACK, EMPLOYEE 04.", "portrait": PORTRAIT_CABINET_07_SCREEN},
			{"speaker": "Cabinet 07", "text": "PREVIOUS SESSION: CLOSED.", "portrait": PORTRAIT_CABINET_07_SCREEN},
			{"speaker": "Cabinet 07", "text": "CURRENT SESSION: YOURS.", "portrait": PORTRAIT_CABINET_07_SCREEN},
		], _get_witness_completion_callback(was_completed))
		return
	if GameState.memory_echo_completed and not GameState.twist_reveal_seen:
		start_dialogue([
			{"speaker": "Cabinet 07", "text": "ECHO STABILIZED.", "portrait": PORTRAIT_CABINET_07_SCREEN},
			{"speaker": "Cabinet 07", "text": "RESTORE PLAYBACK READY.", "portrait": PORTRAIT_CABINET_07_SCREEN},
			{"speaker": "Cabinet 07", "text": "EMPLOYEE SIGNAL: NEAR-COMPLETE.", "portrait": PORTRAIT_CABINET_07_SCREEN},
		])
		return
	if not GameState.lost_token_quest_started:
		GameState.cabinet07_employee_hint_seen = true
		start_dialogue([
			{"speaker": "Cabinet 07", "text": "CUSTOMER SIGNAL: UNKNOWN."},
			{"speaker": "Cabinet 07", "text": "EMPLOYEE SIGNAL: PARTIAL."},
			{"speaker": "Player", "text": "Why would an arcade cabinet think I work here?", "portrait": PORTRAIT_PLAYER_NEUTRAL},
			{"speaker": "Cabinet 07", "text": "LOST TOKEN REQUIRED."},
		])
		return
	if not GameState.rockbyte_duel_completed:
		_store_arcade_return_position()
		SceneChanger.go_to_rockbyte_duel()
		return
	if GameState.rockbyte_duel_completed and not GameState.lost_token_quest_completed:
		start_dialogue([
			{"speaker": "Cabinet 07", "text": "TOKEN RECOVERED."},
			{"speaker": "Cabinet 07", "text": "RETURN TO MIRA."},
		])
		return
	if GameState.lost_token_quest_completed and not GameState.lying_cabinets_completed:
		start_dialogue(_select_repeat_dialogue("cabinet07", [
			[
				{"speaker": "Cabinet 07", "text": "TOKEN RETURNED."},
				{"speaker": "Cabinet 07", "text": "EMPLOYEE SIGNAL PARTIAL."},
				{"speaker": "Cabinet 07", "text": "TRUTH FILTER RECOMMENDED."},
			],
			[
				{"speaker": "Cabinet 07", "text": "TWO RECORDS DETECTED."},
				{"speaker": "Cabinet 07", "text": "ONE RECORD CONTRADICTS."},
				{"speaker": "Cabinet 07", "text": "TRUTH FILTER REQUIRED."},
			],
		], [
			[
				{"speaker": "Cabinet 07", "text": "NEXT VALID TARGET: TRUTH FILTER."},
			],
		]))
		return
	var cabinet_lines: Array = _select_repeat_dialogue("cabinet07", [
		[
			{"speaker": "Cabinet 07", "text": "SECOND FRAGMENT ACCEPTED."},
			{"speaker": "Cabinet 07", "text": "EMPLOYEE SIGNAL LESS WRONG."},
			{"speaker": "Cabinet 07", "text": "STAFF DOOR TARGET READY."},
		],
		[
			{"speaker": "Cabinet 07", "text": "PREVIOUS SCORE: DAMAGED."},
			{"speaker": "Cabinet 07", "text": "PREVIOUS STAFF FILE: DAMAGED."},
			{"speaker": "Player", "text": "That is starting to feel less like coincidence.", "portrait": PORTRAIT_PLAYER_NEUTRAL},
			{"speaker": "Cabinet 07", "text": "CHECK STAFF DOOR."},
		],
	], [
		[
			{"speaker": "Cabinet 07", "text": "REPEATED INPUT DETECTED."},
			{"speaker": "Cabinet 07", "text": "NEXT VALID TARGET: STAFF DOOR."},
		],
	])
	if _can_show_act2_echo() and not GameState.echo_cabinet07_seen:
		cabinet_lines.append_array(_get_cabinet07_echo_lines())
	start_dialogue(cabinet_lines)

func _handle_truth_filter() -> void:
	if not GameState.lost_token_quest_completed:
		start_dialogue([
			{"speaker": "Truth Filter", "text": "SIGNAL TOO QUIET."},
			{"speaker": "Truth Filter", "text": "LOST TOKEN REQUIRED."},
		])
		return
	if GameState.lying_cabinets_completed:
		start_dialogue([
			{"speaker": "Truth Filter", "text": "TRUTH FILTER PASSED."},
			{"speaker": "Truth Filter", "text": "MEMORY SIGNAL: FRACTURED."},
		])
		return
	GameState.truth_filter_quest_started = true
	GameState.update_memory_signal_from_progress()
	GameState.set_pending_spawn_id("Spawn_FromArcadeHub")
	SceneChanger.go_to_cabinet_row()

func _on_save_slot_menu_closed() -> void:
	if player and player.has_method("set_control_enabled"):
		player.set_control_enabled(true)
	save_slot_menu = null
	_refresh_hint()
	_refresh_objective_hint()

func _handle_staff_door() -> void:
	if GameState.staff_room_unlocked:
		start_dialogue([
			{"speaker": "Staff Door", "text": "ACCESS GRANTED."},
			{"speaker": "Staff Door", "text": "EMPLOYEE SIGNAL ACCEPTED."},
		], Callable(SceneChanger, "go_to_staff_corridor"))
		return
	if GameState.lying_cabinets_completed and not GameState.circuit_soda_completed:
		start_dialogue([
			{"speaker": "Staff Door", "text": "STAFF ACCESS LOCKED."},
			{"speaker": "Staff Door", "text": "CIRCUIT SODA ROUTE REQUIRED."},
			{"speaker": "Staff Door", "text": "FRACTURED SIGNAL UNSTABILIZED."},
		])
		return
	if GameState.circuit_soda_completed and not GameState.lost_shift_file_completed and not GameState.story_puzzle_completed:
		start_dialogue([
			{"speaker": "Staff Door", "text": "STAFF ACCESS LOCKED."},
			{"speaker": "Staff Door", "text": "LOST SHIFT FILE REQUIRED."},
			{"speaker": "Staff Door", "text": "READ CLOSING RECORDS BEFORE SYNC."},
		])
		return
	if GameState.lost_token_quest_completed and not GameState.lying_cabinets_completed:
		start_dialogue([
			{"speaker": "Staff Door", "text": "STAFF ACCESS LOCKED."},
			{"speaker": "Staff Door", "text": "TRUTH FILTER REQUIRED."},
			{"speaker": "Staff Door", "text": "MEMORY SIGNAL UNSTABLE."},
		])
		return
	if GameState.lost_token_quest_completed and GameState.rockbyte_duel_completed and GameState.lying_cabinets_completed and GameState.circuit_soda_completed:
		start_dialogue([
			{"speaker": "Staff Door", "text": "FRACTURED SIGNAL ACCEPTED."},
			{"speaker": "Staff Door", "text": "MAINTENANCE SYNC REQUIRED."},
			{"speaker": "Staff Door", "text": "GUS AUTHORIZATION REQUIRED."},
		])
		return
	start_dialogue([
		{"speaker": "Staff Door", "text": "STAFF ACCESS LOCKED."},
		{"speaker": "Staff Door", "text": "MEMORY TOKEN SIGNAL MISSING."},
	])

func _handle_owner_portrait() -> void:
	if _is_post_reveal():
		GameState.owner_portrait_secret_found = true
		start_dialogue([
			{"speaker": "Owner Portrait", "text": "The scratched nameplate is readable now."},
			{"speaker": "Owner Portrait", "text": "It does not name the owner."},
			{"speaker": "Owner Portrait", "text": "It says: EMPLOYEE 04."},
		])
		return
	if _can_show_act2_echo():
		GameState.echo_owner_portrait_04_seen = true
		start_dialogue([
			{"speaker": "Owner Portrait", "text": "The scratches on the nameplate have shifted."},
			{"speaker": "Owner Portrait", "text": "Only two marks are readable."},
			{"speaker": "Owner Portrait", "text": "0 4"},
		])
		return
	start_dialogue([
		{"speaker": "Owner Portrait", "text": "The frame is cracked and the nameplate is scratched blank."},
	])

func _handle_broken_cabinet(interactable: Node) -> void:
	if _is_post_reveal():
		start_dialogue([
			{"speaker": "Broken Cabinet", "text": "I remember your first quarter."},
			{"speaker": "Broken Cabinet", "text": "You looked happier then."},
			{"speaker": "Broken Cabinet", "text": "Not better. Just earlier."},
		])
		return
	interactable.broken_interaction_count += 1
	if interactable.broken_interaction_count >= 5:
		GameState.broken_cabinet_secret_found = true
		start_dialogue([{"speaker": "Broken Cabinet", "text": "STOP PRESSING E. I AM TRYING TO REMEMBER."}])
		return
	if interactable.broken_interaction_count == 3:
		start_dialogue([{"speaker": "Broken Cabinet", "text": "STILL OUT OF ORDER."}])
		return
	start_dialogue([{"speaker": "Broken Cabinet", "text": "OUT OF ORDER."}])

func _handle_closing_checklist() -> void:
	if not GameState.circuit_soda_completed:
		start_dialogue([
			{"speaker": "Closing Checklist", "text": "The clipboard is blank except for old token totals."},
		])
		return
	var was_completed := GameState.lost_shift_file_completed
	GameState.read_closing_checklist()
	var lines: Array = [
		{"speaker": "Closing Checklist", "text": "CLOSING CHECKLIST"},
		{"speaker": "Closing Checklist", "text": "Final Night"},
		{"speaker": "Closing Checklist", "text": "- Count tokens"},
		{"speaker": "Closing Checklist", "text": "- Lock Cabinet Row"},
		{"speaker": "Closing Checklist", "text": "- Check Staff Door"},
		{"speaker": "Closing Checklist", "text": "- Employee 04: signature missing"},
	]
	lines.append_array(_get_lost_shift_completion_lines())
	var after_dialogue := Callable(self, "_show_lost_shift_complete_notice") if not was_completed and GameState.lost_shift_file_completed else Callable()
	start_dialogue(lines, after_dialogue)

func _get_lost_shift_completion_lines() -> Array:
	if not GameState.lost_shift_file_completed:
		return []
	return [
		{"speaker": "Quest", "text": "LOST SHIFT FILE COMPLETE"},
		{"speaker": "Quest", "text": "Employee 04 was assigned to Cabinet shutdown."},
	]

func _show_lost_shift_complete_notice() -> void:
	if quest_notice and quest_notice.has_method("show_custom_notification"):
		quest_notice.call(
			"show_custom_notification",
			"QUEST COMPLETE",
			"LOST SHIFT FILE COMPLETE",
			"Employee 04 was assigned to Cabinet shutdown."
		)

func _is_post_reveal() -> bool:
	return GameState.post_reveal_roam_unlocked or GameState.twist_reveal_seen

func _store_arcade_return_position() -> void:
	if player:
		GameState.set_arcade_return_position(player.global_position)

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
	_update_memory_signal_pulse()
	_update_act2_aftermath_pulse()

func _update_memory_signal_pulse() -> void:
	if memory_signal_tween and memory_signal_tween.is_valid():
		memory_signal_tween.kill()
	if memory_signal_background == null:
		return
	memory_signal_background.modulate.a = 1.0
	if GameState.memory_signal_level <= GameState.MEMORY_SIGNAL_GROUNDED:
		return
	var low_alpha := 0.72 if GameState.memory_signal_level == GameState.MEMORY_SIGNAL_UNEASY else 0.58
	memory_signal_tween = create_tween()
	memory_signal_tween.set_loops()
	memory_signal_tween.tween_property(memory_signal_background, "modulate:a", low_alpha, 0.9)
	memory_signal_tween.tween_property(memory_signal_background, "modulate:a", 1.0, 0.9)

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
