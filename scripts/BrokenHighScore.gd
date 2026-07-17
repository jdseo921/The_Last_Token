extends Control

# Broken High Score (optional) — reflex "score repair" race against Roxy's ghost.
# The board lies (9999). The real record's digits flicker; LOCK them only while they
# hold still. Repair TARGET_REPAIRS digits before Roxy's ghost runs the score to GHOST_TARGET.

const SCREEN_ART_PATH := "res://assets/art/minigames/broken_high_score/broken_high_score_screen.png"

const TARGET_REPAIRS := 3
const GHOST_TARGET := 30.0
const GHOST_RATE := 3.2          # ghost points gained per second
const MISS_PENALTY := 3.0
const LOCK_REWARD := 1.5         # locking a digit nudges the ghost back
const FLICKER_INTERVAL := 0.08
# Reaction window the player must hit (~20% more generous than the first pass).
const STABLE_WINDOW_BASE := 0.55
const STABLE_WINDOW_MIN := 0.29
const STABLE_WINDOW_PER_REPAIR := 0.048
const GLYPHS := ["9", "?", "4", "#", "0", "8", "%", "6"]

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

var repairs := 0
var ghost := 0.0
var completed := false
var running := false
var flicker_accum := 0.0
var cycle_accum := 0.0
var cycle_len := 1.3
var stable_window := 0.55
var stable := false

func _ready() -> void:
	score_button.pressed.connect(_on_score_pressed)
	reset_button.pressed.connect(_on_reset_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	randomize()
	_apply_screen_art()
	ArcadeScreen.apply(self)
	_start_game()

func _start_game() -> void:
	repairs = 0
	ghost = 0.0
	completed = false
	running = true
	cycle_accum = 0.0
	cycle_len = 1.3
	stable_window = STABLE_WINDOW_BASE
	stable = false
	instruction_label.text = "BROKEN HIGH SCORE\nThe board screams 9999. It is lying.\nLOCK the record only when the digits hold still.\nBeat Roxy's ghost to the real score."
	score_button.text = "LOCK"
	score_button.visible = true
	reset_button.visible = true
	exit_button.visible = false
	status_label.text = "Roxy: \"Bet you cannot even read a real score.\""
	_refresh()
	score_button.grab_focus()

func _process(delta: float) -> void:
	if not running or completed:
		return
	ghost += GHOST_RATE * delta
	if ghost >= GHOST_TARGET:
		_lose_round()
		return
	cycle_accum += delta
	if cycle_accum >= cycle_len:
		cycle_accum = 0.0
		cycle_len = max(randf_range(1.0, 1.5) - 0.05 * repairs, 0.7)
		stable_window = clamp(STABLE_WINDOW_BASE - STABLE_WINDOW_PER_REPAIR * repairs, STABLE_WINDOW_MIN, STABLE_WINDOW_BASE)
	stable = cycle_accum >= (cycle_len - stable_window)
	flicker_accum += delta
	if stable:
		corrupted_digit_label.text = "0 0 0 0"
	elif flicker_accum >= FLICKER_INTERVAL:
		flicker_accum = 0.0
		corrupted_digit_label.text = "%s %s %s %s" % [_rand_glyph(), _rand_glyph(), _rand_glyph(), _rand_glyph()]
	_refresh()

func _rand_glyph() -> String:
	return GLYPHS[randi() % GLYPHS.size()]

func _on_score_pressed() -> void:
	if completed or not running:
		return
	if stable:
		repairs += 1
		ghost = max(0.0, ghost - LOCK_REWARD)
		_play_audio("play_score_blip")
		status_label.text = "Digit locked. %d of %d restored." % [repairs, TARGET_REPAIRS]
		if repairs >= TARGET_REPAIRS:
			_complete_game()
			return
	else:
		ghost = min(GHOST_TARGET - 0.01, ghost + MISS_PENALTY)
		_play_audio("play_error_buzz")
		status_label.text = "Locked static. Roxy's ghost gains."
	_refresh()

func _on_reset_pressed() -> void:
	if completed:
		return
	_start_game()

func _lose_round() -> void:
	repairs = 0
	ghost = 0.0
	cycle_accum = 0.0
	_play_audio("play_error_buzz")
	status_label.text = "Roxy: \"Ghost wins. Again.\"\nThe board resets. Try actually watching this time."
	_refresh()

func _complete_game() -> void:
	completed = true
	running = false
	GameState.complete_broken_high_score()
	score_button.visible = false
	reset_button.visible = false
	exit_button.visible = true
	corrupted_digit_label.text = "0 0 9 9"
	fake_target_label.text = "ROXY GHOST: BEATEN"
	score_label.text = "RECORD RESTORED"
	status_label.text = "PREVIOUS SCORE FOUND.\nThe points came back clean. The name stayed blank.\nRoxy: \"...Fine. That was almost impressive.\""
	_play_audio("play_success_jingle")
	exit_button.grab_focus()

func _refresh() -> void:
	fake_target_label.text = "ROXY GHOST: %02d / %02d" % [int(ghost), int(GHOST_TARGET)]
	score_label.text = "REPAIRED: %d / %d" % [repairs, TARGET_REPAIRS]

func _on_exit_pressed() -> void:
	_play_audio("play_ui_confirm")
	GameState.set_pending_spawn_id("Spawn_FromBrokenHighScore")
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
