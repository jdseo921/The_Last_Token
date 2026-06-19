extends Node2D

const BACKGROUND_ART_PATH := "res://assets/art/maps/prize_corner/prize_corner_background_640x440.png"

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

var pending_after_dialogue: Callable = Callable()
var choice_box: CanvasLayer = null
var prize_sort_selected: Array = []
var prize_sort_remaining: Array = []

func _ready() -> void:
	player.interaction_prompt_changed.connect(_on_prompt_changed)
	dialogue_box.dialogue_finished.connect(_on_dialogue_finished)
	_apply_background_art()
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

func _dialogue_is_active() -> bool:
	if dialogue_box == null:
		return false
	return dialogue_box.get("active") == true

func _choice_box_is_open() -> bool:
	return choice_box != null and is_instance_valid(choice_box) and choice_box.visible

func handle_hub_interaction(interactable: Node, _player_node: Node = null) -> void:
	match str(interactable.interactable_kind):
		"pip":
			_handle_pip()
		"prize_counter":
			_handle_prize_counter()
		_:
			start_dialogue([{"speaker": "System", "text": "Nothing happens."}])

func _handle_pip() -> void:
	var was_pip_met := GameState.pip_met
	GameState.pip_met = true
	if _is_post_reveal():
		GameState.pip_post_reveal_secret_seen = true
		start_dialogue([
			{"speaker": "Pip", "text": "There you are."},
			{"speaker": "Pip", "text": "Yep. Still not the original."},
			{"speaker": "Pip", "text": "But you wave nicer now."},
		])
		return
	if not _is_prize_sort_completed() and _prize_sort_unlocked():
		var lines: Array = []
		if not was_pip_met:
			lines.append_array([
				{"speaker": "Pip", "text": "Hi! I am a legally distinct prize animal."},
				{"speaker": "Pip", "text": "I am filled with cotton and confidential information."},
			])
		lines.append_array([
			{"speaker": "Pip", "text": "You are softer this time."},
			{"speaker": "Pip", "text": "Less screaming."},
		])
		start_dialogue(lines, Callable(self, "_start_prize_sort"))
		return
	if _is_prize_sort_completed():
		_show_pip_prize_completion_dialogue()
		return
	if GameState.lost_token_quest_completed:
		var lost_token_lines: Array = []
		if not was_pip_met:
			lost_token_lines.append_array([
				{"speaker": "Pip", "text": "Hi! I am a legally distinct prize animal."},
				{"speaker": "Pip", "text": "I am filled with cotton and confidential information."},
			])
		lost_token_lines.append_array([
			{"speaker": "Pip", "text": "You used to want the blue one."},
			{"speaker": "Pip", "text": "You never had enough tickets."},
		])
		start_dialogue(lost_token_lines)
		return
	start_dialogue([
		{"speaker": "Pip", "text": "Hi! I am a legally distinct prize animal."},
		{"speaker": "Pip", "text": "I am filled with cotton and confidential information."},
	])

func _handle_prize_counter() -> void:
	if _is_prize_sort_completed():
		start_dialogue([
			{"speaker": "Prize Counter", "text": "The prize labels are neatly sorted."},
			{"speaker": "Prize Counter", "text": "Ticket Stub. Lost Token. Blank Employee Badge."},
		])
		return
	if _prize_sort_unlocked():
		start_dialogue([
			{"speaker": "Prize Counter", "text": "Three labels sit loose under the glass."},
			{"speaker": "Prize Counter", "text": "Pip seems very proud of not explaining why."},
		], Callable(self, "_start_prize_sort"))
		return
	start_dialogue([
		{"speaker": "Prize Counter", "text": "Cheap prizes watch from behind dusty glass."},
	])

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
		start_dialogue([
			{"speaker": "Pip", "text": "Prizes sorted."},
			{"speaker": "Pip", "text": "Some rewards remember their owner before the owner remembers them."},
		])
		return
	start_dialogue([
		{"speaker": "Pip", "text": "Prizes sorted."},
		{"speaker": "Pip", "text": "Ticket Stub. Lost Token. Blank Employee Badge."},
	])

func _finish_failed_prize_sort() -> void:
	start_dialogue([
		{"speaker": "Pip", "text": "Those memories are wearing each other's hats."},
		{"speaker": "Pip", "text": "Try oldest to newest."},
	], Callable(self, "_start_prize_sort"))

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

func _apply_background_art() -> void:
	var loaded := _apply_sprite_texture(background_art, BACKGROUND_ART_PATH)
	for placeholder in [$Background, $PrizeCounterPlaceholder, $PipPlaceholder]:
		if placeholder is CanvasItem:
			placeholder.visible = not loaded

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
