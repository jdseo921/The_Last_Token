extends Node2D

const ROUTE_CUE_SCRIPT := preload("res://scripts/RouteCue.gd")
const AMBIENT_EFFECTS := preload("res://scripts/AmbientSpriteEffects.gd")
const BACKGROUND_ART_PATH := "res://assets/art/maps/prize_corner/prize_corner_background_640x440.png"
const DIALOGUE_POOL := preload("res://scripts/DialoguePool.gd")

const PRIZE_SORT_ORDER := [
	"Ticket Stub",
	"Lost Token",
	"Blank Employee Badge",
]

@onready var player: CharacterBody2D = $Player
@onready var background_art: Sprite2D = $BackgroundArt
@onready var ui_layer: Node2D = $UILayer
@onready var dialogue_box: CanvasLayer = $UILayer/DialogueBox
@onready var prompt_label: Label = $UILayer/InteractionPrompt
@onready var prompt_background: ColorRect = $UILayer/InteractionPromptBackground
@onready var quest_notice: CanvasLayer = $QuestNotice

var pending_after_dialogue: Callable = Callable()
var choice_box: CanvasLayer = null
var prize_sort_selected: Array = []
var prize_sort_remaining: Array = []
var route_cue: Control = null

func _ready() -> void:
	player.interaction_prompt_changed.connect(_on_prompt_changed)
	dialogue_box.dialogue_finished.connect(_on_dialogue_finished)
	_apply_background_art()
	_setup_ambient_sprite_effects()
	_setup_route_cue()
	_apply_spawn_position()
	_on_prompt_changed("")

func can_open_pause_menu() -> bool:
	return not _dialogue_is_active() and not _choice_box_is_open()

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
	if player and player.has_method("set_control_enabled") and not _choice_box_is_open():
		player.set_control_enabled(true)
	_refresh_route_cue()

func _dialogue_is_active() -> bool:
	if dialogue_box == null:
		return false
	return dialogue_box.get("active") == true

func _choice_box_is_open() -> bool:
	return choice_box != null and is_instance_valid(choice_box) and choice_box.visible

func _get_pip_lines(key: String, fallback: Array) -> Array:
	return DIALOGUE_POOL.get_lines("pip", key, fallback)

func _get_pip_sequential_lines(key: String, fallback: Array) -> Array:
	return DIALOGUE_POOL.get_sequential_set("pip", key, key, fallback)

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
			{"speaker": "Pip", "text": "Yep. Still not the original."},
			{"speaker": "Pip", "text": "But you wave nicer now."},
		]), _get_witness_completion_callback(was_completed))
		return
	if not _is_prize_sort_completed() and _prize_sort_unlocked():
		var lines := _get_optional_first_meeting_lines(was_pip_met)
		lines.append_array(_get_pip_lines("prize_sort_intro", [
			{"speaker": "Pip", "text": "Prize Sort is ready."},
			{"speaker": "Pip", "text": "The labels remember an order."},
			{"speaker": "Pip", "text": "Ticket Stub. Lost Token. Blank Employee Badge."},
		]))
		start_dialogue(lines, Callable(self, "_start_prize_sort"))
		return
	if _is_prize_sort_completed():
		_show_pip_prize_completion_dialogue()
		return
	if GameState.lost_token_quest_completed:
		var lines := _get_optional_first_meeting_lines(was_pip_met)
		lines.append_array(_get_pip_lines("after_lost_token", [
			{"speaker": "Pip", "text": "You brought the Lost Token back."},
			{"speaker": "Pip", "text": "You used to want the blue one."},
			{"speaker": "Pip", "text": "You never had enough tickets."},
		]))
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
		start_dialogue(_get_environment_lines("prize_counter_restored", [
			{"speaker": "Prize Counter", "text": "The prize labels are neatly sorted."},
			{"speaker": "Prize Counter", "text": "Ticket Stub. Lost Token. Blank Employee Badge."},
		]))
		return
	if _prize_sort_unlocked():
		var lines := _get_environment_state_lines("prize_counter", [
			{"speaker": "Prize Counter", "text": "Three labels sit loose under the glass."},
			{"speaker": "Prize Counter", "text": "Pip seems very proud of not explaining why."},
		])
		lines.append_array(_get_pip_lines("prize_sort_intro", [
			{"speaker": "Pip", "text": "Prize Sort is ready."},
			{"speaker": "Pip", "text": "The labels remember an order."},
		]))
		start_dialogue(lines, Callable(self, "_start_prize_sort"))
		return
	start_dialogue(_get_environment_state_lines("prize_counter", [
		{"speaker": "Prize Counter", "text": "Cheap prizes watch from behind dusty glass."},
	]))

func _handle_prize_shelf_adventure() -> void:
	start_dialogue([
		{"speaker": "Prize Shelf", "text": "PRIZE SHELF RUN READY."},
		{"speaker": "Prize Shelf", "text": "Collect loose tags without snagging the hooks."},
		{"speaker": "Prize Shelf", "text": "Optional shelf route. Pip is pretending not to judge."},
	], Callable(self, "_go_to_prize_shelf_run"))

func _go_to_prize_shelf_run() -> void:
	GameState.set_pending_spawn_id("Spawn_FromPrizeAdventure")
	SceneChanger.go_to_prize_shelf_run()

func _start_prize_sort() -> void:
	GameState.pip_secret_started = true
	prize_sort_selected = []
	prize_sort_remaining = PRIZE_SORT_ORDER.duplicate()
	_open_prize_sort_choice()

func _open_prize_sort_choice() -> void:
	if choice_box and is_instance_valid(choice_box):
		choice_box.queue_free()
	choice_box = load("res://scenes/ui/ChoiceBox.tscn").instantiate()
	ui_layer.add_child(choice_box)
	if player and player.has_method("set_control_enabled"):
		player.set_control_enabled(false)
	if choice_box.has_signal("choice_selected"):
		choice_box.connect("choice_selected", _on_prize_sort_choice_selected, CONNECT_ONE_SHOT)
	if choice_box.has_signal("choice_cancelled"):
		choice_box.connect("choice_cancelled", _on_prize_sort_choice_cancelled, CONNECT_ONE_SHOT)
	var slot := prize_sort_selected.size() + 1
	var question := "PRIZE SORT\nArrange the prizes from oldest memory to newest memory.\nChoose item %d." % slot
	choice_box.open_choice(question, prize_sort_remaining)

func _on_prize_sort_choice_selected(index: int) -> void:
	if choice_box and is_instance_valid(choice_box):
		choice_box.queue_free()
	choice_box = null
	if index < 0 or index >= prize_sort_remaining.size():
		_finish_failed_prize_sort()
		return
	var selected_item: String = str(prize_sort_remaining[index])
	prize_sort_selected.append(selected_item)
	prize_sort_remaining.remove_at(index)
	if prize_sort_selected.size() < PRIZE_SORT_ORDER.size():
		_open_prize_sort_choice()
		return
	if prize_sort_selected == PRIZE_SORT_ORDER:
		GameState.complete_pip_secret()
		_show_pip_prize_completion_dialogue()
		return
	_finish_failed_prize_sort()

func _show_pip_prize_completion_dialogue() -> void:
	if not GameState.pip_prize_anecdote_seen:
		GameState.pip_prize_anecdote_seen = true
		start_dialogue(_get_pip_lines("prize_sort_completion", [
			{"speaker": "Pip", "text": "Prizes sorted."},
			{"speaker": "Pip", "text": "Some rewards remember their owner before the owner remembers them."},
		]))
		return
	start_dialogue([
		{"speaker": "Pip", "text": "Prizes sorted."},
		{"speaker": "Pip", "text": "Ticket Stub. Lost Token. Blank Employee Badge."},
	])

func _finish_failed_prize_sort() -> void:
	start_dialogue(_get_pip_sequential_lines("prize_sort_wrong", [
		{"speaker": "Pip", "text": "Those memories are wearing each other's hats."},
		{"speaker": "Pip", "text": "Try oldest to newest."},
	]), Callable(self, "_start_prize_sort"))

func _on_prize_sort_choice_cancelled() -> void:
	if choice_box and is_instance_valid(choice_box):
		choice_box.queue_free()
	choice_box = null
	if player and player.has_method("set_control_enabled"):
		player.set_control_enabled(true)

func _prize_sort_unlocked() -> bool:
	return GameState.lying_cabinets_completed or _is_post_reveal()

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
			"name": "SnackRouteArrow",
			"position": Vector2(34, 260),
			"rotation": PI,
			"scale": Vector2(1.35, 1.35),
			"effect_type": "blink",
			"speed": 0.66,
			"sprite_sheet_path": AMBIENT_EFFECTS.NEON_ARROW,
			"sprite_alpha": 0.64,
		},
	])

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
