extends Control

# Memory Echo — anchor the memory that is truly yours while the fragments drift.
# Distinct verb from Truth Filter (static sort under a rising meter): here the
# fragments MOVE, and you catch the true one. A quiet recognition beat before the reveal.

const MODE_NEXT_QUESTION := "next_question"
const MODE_COMPLETE := "complete"

const PLAY_MIN := Vector2(84, 152)
const PLAY_MAX := Vector2(398, 290)
const FRAGMENT_SIZE := Vector2(156, 38)
const DRIFT_MIN := 20.0
const DRIFT_MAX := 38.0

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
			"ANCHORED.",
			"Absence of memory is not proof of absence.",
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
			"ANCHORED.",
			"They waited until you could hold it.",
		],
	},
	{
		"prompt": "One signal entered. One signal remained.",
		"choices": [
			"The original.",
			"The restored.",
			"Both. I carry both now.",
		],
		"preferred_index": 2,
		"accepted": [
			"ANCHORED.",
			"Identity conflict stabilizing.",
		],
	},
]

@onready var speaker_label: Label = $Panel/SpeakerLabel
@onready var echo_label: Label = $Panel/EchoLabel
@onready var response_label: Label = $Panel/ResponseLabel
@onready var continue_button: Button = $Panel/ContinueButton
@onready var glitch_bar_a: ColorRect = $GlitchBarA
@onready var glitch_bar_b: ColorRect = $GlitchBarB

const DECOY_INDEX := -2
const DECOY_TEXT := "Only me. There was never a both."
const QUESTION_SOFT_WINDOW := 15.0
const QUESTION_TIME_LIMIT := 26.0

var current_question_index := 0
var continue_mode := MODE_NEXT_QUESTION
var finished := false
var glitch_tween: Tween = null
var fragments: Array[Button] = []
var velocities: Array[Vector2] = []
var fragment_indices: Array[int] = []
var catching := false
var question_timer := 0.0
var drift_accelerated := false
var hijack_done := false

func _ready() -> void:
	AudioManager.play_music_for_context("memory_echo")
	ArcadeScreen.apply(self, "res://assets/art/minigames/memory_echo/backgrounds/memory_echo_screen.svg")
	speaker_label.text = "Memory Echo"
	continue_button.pressed.connect(_on_continue_pressed)
	randomize()
	GameState.start_memory_echo()
	_start_glitch_effect()
	if GameState.memory_echo_completed:
		_show_repeat_complete()
		return
	_show_question()

func _show_question() -> void:
	continue_button.visible = false
	response_label.text = ""
	question_timer = 0.0
	drift_accelerated = false
	var question: Dictionary = QUESTIONS[current_question_index]
	if current_question_index == 0:
		speaker_label.text = "Reel"
		echo_label.text = "REEL: Last set, pal. Some of these tracks are yours.\nSome got recorded over. Catch the real ones.\n\n%s" % str(question.get("prompt", ""))
	elif current_question_index == 2 and not hijack_done:
		hijack_done = true
		speaker_label.text = "???"
		echo_label.text = "The playback seizes. Something else holds the reel.\n\n%s" % str(question.get("prompt", ""))
		_play_audio("play_error_buzz")
	else:
		speaker_label.text = "Memory Echo"
		echo_label.text = "%s\nAnchor the memory that is truly yours." % str(question.get("prompt", ""))
	_spawn_fragments(question)

func _spawn_fragments(question: Dictionary) -> void:
	_clear_fragments()
	var choices_value: Variant = question.get("choices", [])
	var choices: Array = choices_value if choices_value is Array else []
	for index in range(choices.size()):
		_spawn_fragment(str(choices[index]), index)
	if current_question_index == 2:
		# The seized reel plays a memory that was never recorded.
		_spawn_fragment(DECOY_TEXT, DECOY_INDEX)
	catching = true

func _spawn_fragment(text: String, index: int) -> void:
	var frag := Button.new()
	frag.text = text
	frag.custom_minimum_size = FRAGMENT_SIZE
	frag.size = FRAGMENT_SIZE
	frag.clip_text = true
	frag.add_theme_font_size_override("font_size", 11)
	frag.position = Vector2(randf_range(PLAY_MIN.x, PLAY_MAX.x), randf_range(PLAY_MIN.y, PLAY_MAX.y))
	frag.pressed.connect(_on_fragment_clicked.bind(index))
	add_child(frag)
	fragments.append(frag)
	fragment_indices.append(index)
	var ang := randf_range(0.0, TAU)
	var spd := randf_range(DRIFT_MIN, DRIFT_MAX)
	velocities.append(Vector2(cos(ang), sin(ang)) * spd)

func _process(delta: float) -> void:
	if not catching:
		return
	question_timer += delta
	if question_timer >= QUESTION_TIME_LIMIT:
		_slip_question()
		return
	if question_timer >= QUESTION_SOFT_WINDOW and not drift_accelerated:
		drift_accelerated = true
		speaker_label.text = "The memory is drifting..."
		for i in range(velocities.size()):
			velocities[i] *= 1.55
		for frag in fragments:
			if is_instance_valid(frag):
				frag.modulate.a = 0.6
	for i in range(fragments.size()):
		var frag: Button = fragments[i]
		if not is_instance_valid(frag):
			continue
		var pos := frag.position + velocities[i] * delta
		if pos.x <= PLAY_MIN.x or pos.x >= PLAY_MAX.x:
			velocities[i].x = -velocities[i].x
			pos.x = clampf(pos.x, PLAY_MIN.x, PLAY_MAX.x)
		if pos.y <= PLAY_MIN.y or pos.y >= PLAY_MAX.y:
			velocities[i].y = -velocities[i].y
			pos.y = clampf(pos.y, PLAY_MIN.y, PLAY_MAX.y)
		frag.position = pos

func _on_fragment_clicked(index: int) -> void:
	if finished or not catching:
		return
	var question: Dictionary = QUESTIONS[current_question_index]
	if index == int(question.get("preferred_index", -1)):
		catching = false
		_clear_fragments()
		_show_accepted(question)
		return
	_play_audio("play_error")
	if index == DECOY_INDEX:
		speaker_label.text = "???: That one is mine. Put it down."
	else:
		speaker_label.text = "That memory is not yours. It drifts away."
	_scatter()

func _slip_question() -> void:
	catching = false
	_play_audio("play_error")
	_clear_fragments()
	speaker_label.text = "Memory Echo"
	echo_label.text = "The fragments sink back into static.\nBreathe. The song starts over."
	response_label.text = ""
	await get_tree().create_timer(1.4).timeout
	if finished or GameState.memory_echo_completed:
		return
	_show_question()

func _scatter() -> void:
	for i in range(velocities.size()):
		var ang := randf_range(0.0, TAU)
		var spd := randf_range(DRIFT_MIN, DRIFT_MAX) + 6.0
		velocities[i] = Vector2(cos(ang), sin(ang)) * spd

func _clear_fragments() -> void:
	for frag in fragments:
		if is_instance_valid(frag):
			frag.queue_free()
	fragments.clear()
	velocities.clear()
	fragment_indices.clear()

func _show_accepted(question: Dictionary) -> void:
	_play_audio("play_memory_accept")
	speaker_label.text = "Memory Echo"
	var accepted_value: Variant = question.get("accepted", [])
	var accepted_lines: Array = accepted_value if accepted_value is Array else []
	response_label.text = _join_lines(accepted_lines)
	continue_mode = MODE_NEXT_QUESTION
	continue_button.text = "Continue"
	continue_button.visible = true
	continue_button.grab_focus()

func _on_continue_pressed() -> void:
	if finished:
		return
	_play_audio("play_ui_cancel" if continue_mode == MODE_COMPLETE else "play_ui_confirm")
	match continue_mode:
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
	_play_audio("play_quest_update")
	speaker_label.text = "Reel"
	echo_label.text = "MEMORY ECHO STABILIZED."
	response_label.text = "REEL: That is your setlist. Rough, honest, yours.\nHold onto it. The next room will test the tune.\nRESTORE PLAYBACK AVAILABLE."
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
	catching = false
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

func _play_audio(method_name: String) -> void:
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager and audio_manager.has_method(method_name):
		audio_manager.call(method_name)
