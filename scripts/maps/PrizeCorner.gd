extends Node2D

const ROUTE_CUE_SCRIPT := preload("res://scripts/RouteCue.gd")
const AMBIENT_EFFECTS := preload("res://scripts/AmbientSpriteEffects.gd")
const BACKGROUND_ART_PATH := "res://assets/art/maps/prize_corner/prize_corner_background_640x440.png"
const DIALOGUE_POOL := preload("res://scripts/DialoguePool.gd")

@onready var player: CharacterBody2D = $Player
@onready var background_art: Sprite2D = $BackgroundArt
@onready var ui_layer: Node2D = $UILayer
@onready var dialogue_box: CanvasLayer = $UILayer/DialogueBox
@onready var prompt_label: Label = $UILayer/InteractionPrompt
@onready var prompt_background: ColorRect = $UILayer/InteractionPromptBackground
@onready var quest_notice: CanvasLayer = $QuestNotice

var pending_after_dialogue: Callable = Callable()
var route_cue: Control = null

func _ready() -> void:
	AudioManager.play_music_for_context("prize_corner")
	player.interaction_prompt_changed.connect(_on_prompt_changed)
	dialogue_box.dialogue_finished.connect(_on_dialogue_finished)
	_apply_background_art()
	_setup_ambient_sprite_effects()
	_setup_route_cue()
	_apply_spawn_position()
	_on_prompt_changed("")
	call_deferred("_maybe_show_pip_minigame_return")

func can_open_pause_menu() -> bool:
	return not _dialogue_is_active() and not _choice_box_is_open()

func _choice_box_is_open() -> bool:
	if ui_layer == null:
		return false
	for child in ui_layer.get_children():
		if child.has_method("open_choice") and child is CanvasItem and (child as CanvasItem).visible:
			return true
	return false

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
	route_cue.call("setup", "prize_corner", Vector2(24, 86), 390.0)

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

func _get_pip_lines(key: String, fallback: Array) -> Array:
	return DIALOGUE_POOL.get_lines("pip", key, fallback)

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

func handle_hub_interaction(interactable: Node, _player_node: Node = null) -> void:
	match str(interactable.interactable_kind):
		"pip":
			_handle_pip()
		"prize_counter":
			_handle_prize_counter()
		"prize_shelf_adventure":
			_handle_prize_shelf_adventure()
		_:
			start_dialogue([{"speaker": "System", "text": "Nothing happens."}])

func _handle_pip() -> void:
	var was_pip_met := GameState.pip_met
	GameState.pip_met = true
	if _is_post_reveal():
		var was_completed := _was_witness_route_completed()
		GameState.pip_post_reveal_secret_seen = true
		GameState.mark_witness_pip_heard()
		start_dialogue(_get_pip_lines("post_reveal", [
			{"speaker": "Pip", "text": "There you are."},
			{"speaker": "Pip", "text": "Yep. Same person. Different seams."},
			{"speaker": "Pip", "text": "But you wave nicer now."},
		]), _get_witness_completion_callback(was_completed))
		return
	if GameState.prize_echo_unlocked and not _is_prize_sort_completed():
		var ready_lines := _get_optional_first_meeting_lines(was_pip_met)
		ready_lines.append_array([
			{"speaker": "Pip", "text": "The shelf beside me is holding Prize Echo Ascent."},
			{"speaker": "Pip", "text": "Start it from the shelf when you are ready."},
		])
		start_dialogue(ready_lines)
		return
	if not _is_prize_sort_completed() and _prize_sort_unlocked():
		GameState.pip_secret_started = true
		GameState.prize_echo_unlocked = true
		var lines := _get_pip_lines("prize_sort_intro", [
			{"speaker": "Pip", "text": "Prize Echo Ascent is awake. Use the shelf beside me to begin."},
		])
		if not was_pip_met:
			lines = _get_pip_lines("prize_sort_first_meeting", lines)
		start_dialogue(lines)
		return
	if _is_prize_sort_completed():
		_show_pip_prize_completion_dialogue()
		return
	if GameState.lost_token_quest_completed:
		var lines := _get_pip_lines("after_lost_token", [
			{"speaker": "Pip", "text": "You brought the Lost Token back."},
			{"speaker": "Pip", "text": "You used to want the blue one."},
			{"speaker": "Pip", "text": "You never had enough tickets."},
		])
		if not was_pip_met:
			lines = _get_pip_lines("first_meeting_after_lost_token", lines)
		start_dialogue(lines)
		return
	start_dialogue(_get_first_meeting_lines())

func _get_first_meeting_lines() -> Array:
	return _get_pip_lines("first_meeting", [
		{"speaker": "Pip", "text": "Hi! I am a legally distinct prize animal."},
		{"speaker": "Pip", "text": "I am filled with cotton and confidential information."},
	])

func _get_optional_first_meeting_lines(was_pip_met: bool) -> Array:
	if was_pip_met:
		return []
	return _get_first_meeting_lines()

func _handle_prize_counter() -> void:
	if _is_prize_sort_completed():
		if _is_post_reveal():
			start_dialogue(_get_environment_lines("prize_counter_restored", [
				{"speaker": "Prize Counter", "text": "The loose labels rest under the glass."},
				{"speaker": "Prize Counter", "text": "The shelf route beside Pip is stable."},
			]))
			return
		start_dialogue([
			{"speaker": "Prize Counter", "text": "The loose labels rest under the glass."},
			{"speaker": "Prize Counter", "text": "The shelf route beside Pip is stable."},
		])
		return
	if _prize_sort_unlocked() and not GameState.pip_met:
		start_dialogue([
			{"speaker": "Player", "text": "Three loose labels under glass, and one very alert plush."},
			{"speaker": "Player", "text": "I should ask Pip before touching anything."},
		])
		return
	if _prize_sort_unlocked():
		start_dialogue(_get_environment_state_lines("prize_counter", [
			{"speaker": "Prize Counter", "text": "Three labels sit loose under the glass."},
			{"speaker": "Player", "text": "Pip pointed me to the shelf, not this counter."},
		]))
		return
	start_dialogue(_get_environment_state_lines("prize_counter", [
		{"speaker": "Prize Counter", "text": "Cheap prizes watch from behind dusty glass."},
	]))

func _handle_prize_shelf_adventure() -> void:
	if GameState.post_reveal_roam_unlocked and _is_prize_sort_completed():
		start_dialogue([
			{"speaker": "Prize Shelf", "text": "PRIZE ECHO ROUTE READY FOR REPLAY."},
		], Callable(self, "_offer_prize_echo_replay"))
		return
	if GameState.prize_echo_unlocked and not _is_prize_sort_completed():
		start_dialogue([
			{"speaker": "Prize Shelf", "text": "EIGHTEEN ECHO TAGS LOADED ACROSS TWO RAILS."},
			{"speaker": "Prize Shelf", "text": "HOOK CONTACT RESETS THE CURRENT ROUTE."},
		], Callable(self, "_go_to_prize_shelf_run"))
		return
	if _is_prize_sort_completed():
		start_dialogue([
			{"speaker": "Prize Shelf", "text": "RAIL STABLE. EIGHTEEN ECHOES SEATED."},
			{"speaker": "Prize Shelf", "text": "THREE LOCKS HOLDING."},
		])
		return
	start_dialogue([
		{"speaker": "Prize Shelf", "text": "RAIL UNPLUGGED. LOOSE TAGS UNSORTED."},
		{"speaker": "Player", "text": "Pip says the good prizes were never on the rail anyway."},
	])

func _go_to_prize_shelf_run() -> void:
	GameState.set_pending_spawn_id("Spawn_FromPrizeAdventure")
	SceneChanger.go_to_prize_shelf_run()

func _offer_prize_echo_replay() -> void:
	PostGameReplay.open_offer(
		ui_layer,
		player,
		"Run Prize Echo Ascent again?",
		"prize_sort",
		Callable(self, "_go_to_prize_shelf_run")
	)

func _maybe_show_pip_minigame_return() -> void:
	if _dialogue_is_active() or not _is_prize_sort_completed():
		return
	# Story completion waits for an explicit Pip interaction so the player
	# actually delivers the Echo Token. Replay acknowledgements may stay eager.
	var replay_return := GameState.postgame_replay_pending == "prize_sort" and GameState.postgame_replay_won
	if replay_return:
		_show_pip_prize_completion_dialogue()

func _show_pip_prize_completion_dialogue() -> void:
	if GameState.consume_postgame_replay_return("prize_sort"):
		start_dialogue(_get_pip_lines("prize_sort_replay_return", [
			{"speaker": "Pip", "text": "All eighteen echoes. Again. You did not have to."},
			{"speaker": "Pip", "text": "Which is exactly why it counts."},
		]))
		return
	if not GameState.pip_prize_anecdote_seen:
		start_dialogue(_get_pip_lines("prize_sort_completion", [
			{"speaker": "Pip", "text": "You brought the Echo Token back. Let me see the rim."},
			{"speaker": "Pip", "text": "The prize paint connects its hopeful memories to you. The service mark gives Gus a closing shift he can trace."},
			{"speaker": "Player", "text": "Then it may help with both questions: who I was, and what happened that night."},
			{"speaker": "Pip", "text": "Exactly. Take it to Gus and let both sides of the token speak."},
		]), Callable(self, "_finish_pip_echo_token_handoff"))
		return
	start_dialogue([
		{"speaker": "Pip", "text": "Prize Echo Ascent is stable."},
		{"speaker": "Pip", "text": "Eighteen echoes. Three locks. No loose seams."},
	])

func _finish_pip_echo_token_handoff() -> void:
	GameState.pip_prize_anecdote_seen = true
	_refresh_route_cue()
	if quest_notice and quest_notice.has_method("refresh_objective_hud"):
		quest_notice.call("refresh_objective_hud", true)

func _prize_sort_unlocked() -> bool:
	return (GameState.circuit_soda_completed and GameState.vendo_unknown_clue_seen) or _is_post_reveal()

func _is_prize_sort_completed() -> bool:
	return GameState.prize_sort_completed or GameState.pip_secret_completed

func _is_post_reveal() -> bool:
	return GameState.post_reveal_roam_unlocked or GameState.twist_reveal_seen

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
	for placeholder in [$Background, $PrizeCounterPlaceholder, $PipPlaceholder, $PrizeShelfAdventurePlaceholder]:
		if placeholder is CanvasItem:
			placeholder.visible = not loaded

func _setup_ambient_sprite_effects() -> void:
	AMBIENT_EFFECTS.create_layer(self, ui_layer, [
		{
			"name": "PrizeCounterGlintA",
			"position": Vector2(180, 130),
			"scale": Vector2(1.25, 1.25),
			"effect_type": "random_screen_flash",
			"speed": 0.52,
			"intensity": 0.05,
			"sprite_sheet_path": AMBIENT_EFFECTS.TICKET_GLINT,
			"sprite_alpha": 0.64,
		},
		{
			"name": "PrizeCounterGlintB",
			"position": Vector2(442, 142),
			"scale": Vector2(1.1, 1.1),
			"effect_type": "random_screen_flash",
			"speed": 0.68,
			"intensity": 0.05,
			"sprite_sheet_path": AMBIENT_EFFECTS.TICKET_GLINT,
			"sprite_alpha": 0.58,
		},
		{
			"name": "PrizeTwinkleA",
			"position": Vector2(246, 116),
			"scale": Vector2(1.35, 1.35),
			"effect_type": "blink",
			"speed": 0.55,
			"sprite_sheet_path": AMBIENT_EFFECTS.PRIZE_TWINKLE,
			"sprite_alpha": 0.68,
		},
		{
			"name": "PrizeTwinkleB",
			"position": Vector2(384, 118),
			"scale": Vector2(1.25, 1.25),
			"effect_type": "blink",
			"speed": 0.72,
			"sprite_sheet_path": AMBIENT_EFFECTS.PRIZE_TWINKLE,
			"sprite_alpha": 0.62,
			"sprite_modulate": Color(1.0, 0.78, 0.96, 1.0),
		},
		{
			"name": "PipBlinkDot",
			"position": Vector2(320, 210),
			"scale": Vector2(1.05, 1.05),
			"effect_type": "bob",
			"speed": 0.58,
			"intensity": 0.08,
			"sprite_sheet_path": AMBIENT_EFFECTS.BLINK_DOT,
			"sprite_alpha": 0.56,
			"sprite_modulate": Color(1.0, 0.9, 0.52, 1.0),
		},
		{
			"name": "PrizeTwinkleC",
			"position": Vector2(318, 108),
			"scale": Vector2(1.2, 1.2),
			"effect_type": "blink",
			"speed": 0.62,
			"sprite_sheet_path": AMBIENT_EFFECTS.PRIZE_TWINKLE,
			"sprite_alpha": 0.6,
			"sprite_modulate": Color(1.0, 0.86, 0.42, 1.0),
		},
		{
			"name": "ShelfRunGlint",
			"position": Vector2(466, 204),
			"scale": Vector2(1.15, 1.15),
			"effect_type": "random_screen_flash",
			"speed": 0.58,
			"intensity": 0.05,
			"sprite_sheet_path": AMBIENT_EFFECTS.TICKET_GLINT,
			"sprite_alpha": 0.6,
		},
		{
			"name": "CounterTicketGlintC",
			"position": Vector2(206, 156),
			"scale": Vector2(1.05, 1.05),
			"effect_type": "random_screen_flash",
			"speed": 0.62,
			"intensity": 0.05,
			"sprite_sheet_path": AMBIENT_EFFECTS.TICKET_GLINT,
			"sprite_alpha": 0.55,
		},
		{
			"name": "PrizeFloorDustDrift",
			"position": Vector2(280, 300),
			"scale": Vector2(0.9, 0.9),
			"effect_type": "dust_mote_drift",
			"speed": 0.42,
			"intensity": 0.15,
			"sprite_sheet_path": AMBIENT_EFFECTS.BLINK_DOT,
			"sprite_alpha": 0.28,
			"sprite_modulate": Color(1.0, 0.9, 0.6, 1.0),
		},
	])

func _apply_sprite_texture(sprite_node: Sprite2D, path: String) -> bool:
	if sprite_node == null:
		return false
	sprite_node.visible = false
	sprite_node.texture = null
	if path.is_empty():
		return false
	var texture := _load_texture(path)
	if texture == null:
		return false
	sprite_node.texture = texture
	sprite_node.visible = true
	return true

func _load_texture(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		var resource := load(path)
		if resource is Texture2D:
			return resource
	return _load_raw_png_texture(path)

func _load_raw_png_texture(path: String) -> Texture2D:
	if not path.ends_with(".png"):
		return null
	var image := Image.new()
	var error := image.load(path)
	if error != OK and path.begins_with("res://"):
		error = image.load(ProjectSettings.globalize_path(path))
	if error != OK:
		return null
	return ImageTexture.create_from_image(image)
