extends Control

const MODE_QUESTION := "question"
const MODE_RETRY_QUESTION := "retry_question"
const MODE_NEXT_QUESTION := "next_question"
const MODE_COMPLETE := "complete"

const QUESTIONS := [
	{
		"prompt": "You came here before.",
		"choices": [
			"No. I just arrived.",
			"Maybe. I do not remember.",
			"The arcade is lying.",
		],
		"preferred_index": 1,
		"accepted": [
			"ACCEPTED.",
			"ABSENCE OF MEMORY IS NOT PROOF OF ABSENCE.",
		],
	},
	{
		"prompt": "The others remembered you.",
		"choices": [
			"Then why did they hide it?",
			"Because I was dangerous.",
			"Because I was not ready.",
		],
		"preferred_index": 2,
		"accepted": [
			"ACCEPTED.",
			"READINESS DELAYED RESTORE FAILURE.",
		],
	},
	{
		"prompt": "One signal entered. One signal remained.",
		"choices": [
			"The original.",
			"The restored.",
			"Both, somehow.",
		],
		"preferred_index": 2,
		"accepted": [
			"ACCEPTED.",
			"IDENTITY CONFLICT STABILIZING.",
		],
	},
]

@onready var speaker_label: Label = $Panel/SpeakerLabel
@onready var echo_label: Label = $Panel/EchoLabel
@onready var response_label: Label = $Panel/ResponseLabel
@onready var continue_button: Button = $Panel/ContinueButton
@onready var choice_box: CanvasLayer = $ChoiceBox
@onready var glitch_bar_a: ColorRect = $GlitchBarA
@onready var glitch_bar_b: ColorRect = $GlitchBarB

var current_question_index := 0
var continue_mode := MODE_QUESTION
var finished := false
var glitch_tween: Tween = null

func _ready() -> void:
	AudioManager.play_music_for_context("memory_echo")
	speaker_label.text = "Memory Echo"
	continue_button.pressed.connect(_on_continue_pressed)
	if choice_box.has_signal("choice_selected"):
		choice_box.connect("choice_selected", _on_choice_selected)
	if choice_box.has_signal("choice_cancelled"):
		choice_box.connect("choice_cancelled", _on_choice_cancelled)
	GameState.start_memory_echo()
	_start_glitch_effect()
	if GameState.memory_echo_completed:
		_show_repeat_complete()
		return
	_show_question()

func _show_question() -> void:
	continue_button.visible = false
	response_label.text = ""
	continue_mode = MODE_QUESTION
	var question: Dictionary = QUESTIONS[current_question_index]
	echo_label.text = str(question.get("prompt", ""))
	var choices_value: Variant = question.get("choices", [])
	var choices: Array = []
	if choices_value is Array:
		choices = choices_value
	if choice_box.has_method("open_choice"):
		choice_box.open_choice(echo_label.text, choices)

func _on_choice_selected(index: int) -> void:
	if finished:
		return
	var question: Dictionary = QUESTIONS[current_question_index]
	if index == int(question.get("preferred_index", -1)):
		_show_accepted(question)
		return
	_show_retry()

func _on_choice_cancelled() -> void:
	if finished:
		return
	_show_retry()

func _show_accepted(question: Dictionary) -> void:
	var accepted_value: Variant = question.get("accepted", [])
	var accepted_lines: Array = []
	if accepted_value is Array:
		accepted_lines = accepted_value
	response_label.text = _join_lines(accepted_lines)
	continue_mode = MODE_NEXT_QUESTION
	continue_button.text = "Continue"
	continue_button.visible = true
	continue_button.grab_focus()

func _show_retry() -> void:
	response_label.text = "MEMORY SIGNAL SPIKED.\nTRY AGAIN."
	continue_mode = MODE_RETRY_QUESTION
	continue_button.text = "Retry"
	continue_button.visible = true
	continue_button.grab_focus()

func _on_continue_pressed() -> void:
	if finished:
		return
	match continue_mode:
		MODE_RETRY_QUESTION:
			_show_question()
		MODE_NEXT_QUESTION:
			current_question_index += 1
			if current_question_index >= QUESTIONS.size():
				_show_completion()
				return
			_show_question()
		MODE_COMPLETE:
			_return_to_staff_corridor()
		_:
			_show_question()

func _show_completion() -> void:
	GameState.complete_memory_echo()
	echo_label.text = "MEMORY ECHO STABILIZED."
	response_label.text = "RESTORE PLAYBACK AVAILABLE."
	continue_mode = MODE_COMPLETE
	continue_button.text = "Return"
	continue_button.visible = true
	continue_button.grab_focus()

func _show_repeat_complete() -> void:
	echo_label.text = "MEMORY ECHO STABILIZED."
	response_label.text = "RESTORE PLAYBACK AVAILABLE."
	continue_mode = MODE_COMPLETE
	continue_button.text = "Return"
	continue_button.visible = true
	continue_button.grab_focus()

func _return_to_staff_corridor() -> void:
	finished = true
	GameState.set_pending_spawn_id("Spawn_FromMemoryEcho")
	SceneChanger.go_to_staff_corridor()

func _start_glitch_effect() -> void:
	if glitch_tween and glitch_tween.is_valid():
		glitch_tween.kill()
	glitch_tween = create_tween()
	glitch_tween.set_loops()
	glitch_tween.set_parallel(true)
	glitch_tween.tween_property(glitch_bar_a, "modulate:a", 0.28, 0.18)
	glitch_tween.tween_property(glitch_bar_b, "modulate:a", 0.16, 0.24)
	glitch_tween.chain().set_parallel(true)
	glitch_tween.tween_property(glitch_bar_a, "modulate:a", 0.05, 0.32)
	glitch_tween.tween_property(glitch_bar_b, "modulate:a", 0.04, 0.26)

func _join_lines(lines: Array) -> String:
	var text := ""
	for index in range(lines.size()):
		if index > 0:
			text += "\n"
		text += str(lines[index])
	return text
