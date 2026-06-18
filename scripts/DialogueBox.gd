extends CanvasLayer

signal dialogue_finished

const ADVANCE_COOLDOWN_MSEC := 180

@onready var panel: Panel = $Panel
@onready var speaker_name_label: Label = $Panel/SpeakerName
@onready var dialogue_text_label: Label = $Panel/DialogueText
@onready var continue_prompt_label: Label = $Panel/ContinuePrompt

var dialogue_lines: Array = []
var current_index := 0
var active := false
var last_advance_msec := 0

func _ready() -> void:
	visible = false
	continue_prompt_label.text = "Press E / Space to continue"

func start_dialogue(lines: Array) -> void:
	dialogue_lines = lines
	current_index = 0
	active = not dialogue_lines.is_empty()
	visible = active
	last_advance_msec = Time.get_ticks_msec()
	_refresh_line()

func _input(event: InputEvent) -> void:
	if not active:
		return
	if event.is_action_pressed("interact"):
		if event is InputEventKey and event.echo:
			get_viewport().set_input_as_handled()
			return
		var now := Time.get_ticks_msec()
		if now - last_advance_msec < ADVANCE_COOLDOWN_MSEC:
			get_viewport().set_input_as_handled()
			return
		last_advance_msec = now
		get_viewport().set_input_as_handled()
		_accept_current_line()

func _accept_current_line() -> void:
	_play_audio("play_dialogue_advance")
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

func _play_audio(method_name: String) -> void:
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager and audio_manager.has_method(method_name):
		audio_manager.call(method_name)
