extends CanvasLayer

signal dialogue_finished

@onready var panel: Panel = $Panel
@onready var speaker_name_label: Label = $Panel/SpeakerName
@onready var dialogue_text_label: Label = $Panel/DialogueText
@onready var continue_prompt_label: Label = $Panel/ContinuePrompt

var dialogue_lines: Array = []
var current_index := 0
var active := false

func _ready() -> void:
	visible = false
	continue_prompt_label.text = "Press E / Space to continue"

func start_dialogue(lines: Array) -> void:
	dialogue_lines = lines
	current_index = 0
	active = not dialogue_lines.is_empty()
	visible = active
	_refresh_line()

func _input(event: InputEvent) -> void:
	if not active:
		return
	if event.is_action_pressed("interact"):
		_accept_current_line()

func _accept_current_line() -> void:
	current_index += 1
	if current_index >= dialogue_lines.size():
		active = false
		visible = false
		dialogue_finished.emit()
		return
	_refresh_line()

func _refresh_line() -> void:
	if not active or current_index >= dialogue_lines.size():
		speaker_name_label.text = ""
		dialogue_text_label.text = ""
		return
	var line: Dictionary = dialogue_lines[current_index]
	speaker_name_label.text = str(line.get("speaker", ""))
	dialogue_text_label.text = str(line.get("text", ""))
