extends CanvasLayer

signal choice_selected(index: int)
signal choice_cancelled

@onready var question_label: Label = $Panel/QuestionLabel
@onready var choice_buttons: Array[Button] = [
	$Panel/ChoicesVBox/Choice1Button,
	$Panel/ChoicesVBox/Choice2Button,
	$Panel/ChoicesVBox/Choice3Button,
	$Panel/ChoicesVBox/Choice4Button,
]

func _ready() -> void:
	visible = false
	for index in range(choice_buttons.size()):
		choice_buttons[index].pressed.connect(_on_choice_pressed.bind(index))

func open_choice(question: String, choices: Array) -> void:
	question_label.text = question
	for index in range(choice_buttons.size()):
		var button := choice_buttons[index]
		button.visible = index < choices.size()
		button.text = str(choices[index]) if index < choices.size() else ""
	visible = true
	_focus_first_visible_choice()

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("cancel"):
		get_viewport().set_input_as_handled()
		_play_audio("play_ui_cancel")
		visible = false
		choice_cancelled.emit()

func _on_choice_pressed(index: int) -> void:
	_play_audio("play_ui_confirm")
	visible = false
	choice_selected.emit(index)

func _focus_first_visible_choice() -> void:
	for button in choice_buttons:
		if button.visible:
			button.grab_focus()
			return

func _play_audio(method_name: String) -> void:
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager and audio_manager.has_method(method_name):
		audio_manager.call(method_name)
