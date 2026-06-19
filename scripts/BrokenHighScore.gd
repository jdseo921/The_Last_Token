extends Control

const SCREEN_ART_PATH := "res://assets/art/minigames/broken_high_score/broken_high_score_screen.png"
const REAL_TARGET := 99
const SCORE_STEP := 10

@onready var background: ColorRect = $Background
@onready var background_art: TextureRect = $BackgroundArt
@onready var fake_target_label: Label = $MainPanel/DisplayPanel/FakeTargetLabel
@onready var score_label: Label = $MainPanel/DisplayPanel/ScoreLabel
@onready var corrupted_digit_label: Label = $MainPanel/DisplayPanel/CorruptedDigitLabel
@onready var instruction_label: Label = $MainPanel/InstructionLabel
@onready var status_label: Label = $MainPanel/StatusLabel
@onready var score_button: Button = $MainPanel/ButtonRow/ScoreButton
@onready var reset_button: Button = $MainPanel/ButtonRow/ResetButton
@onready var exit_button: Button = $MainPanel/ButtonRow/ExitButton

var score := 0
var completed := false

func _ready() -> void:
	score_button.pressed.connect(_on_score_pressed)
	reset_button.pressed.connect(_on_reset_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	_apply_screen_art()
	_start_game()

func _start_game() -> void:
	score = 0
	completed = false
	instruction_label.text = "BROKEN HIGH SCORE\nThe target says 9999.\nSome digits are broken.\nReach the real score."
	fake_target_label.text = "TARGET: 9999"
	corrupted_digit_label.text = "9?9?"
	status_label.text = "The cabinet insists the target is 9999. It is not convincing."
	score_button.visible = true
	reset_button.visible = true
	exit_button.visible = false
	_refresh_score()
	score_button.grab_focus()

func _on_score_pressed() -> void:
	if completed:
		return
	score += SCORE_STEP
	_play_audio("play_ui_confirm")
	_refresh_score()
	if score >= REAL_TARGET:
		_complete_game()
		return
	status_label.text = "Score accepted. The last two digits keep flickering."

func _on_reset_pressed() -> void:
	if completed:
		return
	score = 0
	status_label.text = "Score reset. Previous record still smells like static."
	_refresh_score()

func _complete_game() -> void:
	completed = true
	GameState.complete_broken_high_score()
	score_button.visible = false
	reset_button.visible = false
	exit_button.visible = true
	fake_target_label.text = "TARGET: 9999"
	corrupted_digit_label.text = "0099"
	status_label.text = "PREVIOUS SCORE FOUND.\nEMPLOYEE 04 — 000000.\nRECORD RESTORED."
	_play_audio("play_token_get")
	exit_button.grab_focus()

func _refresh_score() -> void:
	score_label.text = "SCORE: %04d" % score
	if score >= 90:
		corrupted_digit_label.text = "00??"
	elif score >= 50:
		corrupted_digit_label.text = "0?9?"
	else:
		corrupted_digit_label.text = "9?9?"

func _on_exit_pressed() -> void:
	_play_audio("play_ui_confirm")
	SceneChanger.go_to_cabinet_row()

func _play_audio(method_name: String) -> void:
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager and audio_manager.has_method(method_name):
		audio_manager.call(method_name)

func _apply_screen_art() -> void:
	background_art.visible = false
	background_art.texture = null
	background.visible = true
	if not ResourceLoader.exists(SCREEN_ART_PATH):
		return
	var resource := load(SCREEN_ART_PATH)
	if not resource is Texture2D:
		return
	background_art.texture = resource
	background_art.visible = true
	background.visible = false
