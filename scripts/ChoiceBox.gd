extends CanvasLayer

signal choice_selected(index: int)

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

func open_choice(question: String, choices: Array[String]) -> void:
	question_label.text = question
	for index in range(choice_buttons.size()):
		var button := choice_buttons[index]
		button.visible = index < choices.size()
		button.text = choices[index] if index < choices.size() else ""
	visible = true

func _on_choice_pressed(index: int) -> void:
	visible = false
	choice_selected.emit(index)
