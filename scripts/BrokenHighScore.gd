extends Control

# Broken High Score (optional) — reflex score-matching race against Roxy's ghost.
# The six-digit board lies. Match the hidden record four times while the full signal
# holds steady, before Roxy's ghost fills its pressure meter.

const SCREEN_ART_PATH := "res://assets/art/minigames/broken_high_score/broken_high_score_deluxe.png"

const TARGET_MATCHES := 4
const DIGIT_COUNT := 6
const FALSE_SCORE := "999999"
const RESTORED_SCORE_TEXT := "0 0 0 0 9 9"
const GHOST_TARGET := 36.0
const GHOST_RATE := 3.2          # ghost points gained per second
const MISS_PENALTY := 3.0
const MATCH_REWARD := 1.5        # a clean match nudges the ghost back
const FLICKER_INTERVAL := 0.08
const STABLE_WINDOW_BASE := 0.55
const STABLE_WINDOW_MIN := 0.29
const STABLE_WINDOW_PER_MATCH := 0.048
const MATCH_TIMING_MULTIPLIER := 1.10
const GLYPHS := ["9", "?", "4", "#", "0", "8", "%", "6"]
const ROXY_BASE_POSITION := Vector2(62, 226)
const CABINET_BASE_POSITION := Vector2(578, 226)
const COLOR_SIGNAL_STABLE := Color(0.2, 1.0, 0.82, 1.0)
const COLOR_SIGNAL_GLITCH := Color(1.0, 0.25, 0.72, 1.0)
const COLOR_MATCH_LOCKED := Color(0.18, 0.94, 1.0, 1.0)
const COLOR_MATCH_EMPTY := Color(0.12, 0.2, 0.27, 1.0)

@onready var background: ColorRect = $Background
@onready var background_art: TextureRect = $BackgroundArt
@onready var fake_target_label: Label = $MainPanel/DisplayPanel/FakeTargetLabel
@onready var ghost_bar: ProgressBar = $MainPanel/DisplayPanel/GhostBar
@onready var score_label: Label = $MainPanel/DisplayPanel/ScoreLabel
@onready var corrupted_digit_label: Label = $MainPanel/DisplayPanel/CorruptedDigitLabel
@onready var signal_label: Label = $MainPanel/DisplayPanel/SignalLabel
@onready var instruction_label: Label = $MainPanel/InstructionPanel/InstructionLabel
@onready var status_label: Label = $MainPanel/StatusPanel/StatusLabel
@onready var score_button: Button = $MainPanel/ButtonRow/ScoreButton
@onready var reset_button: Button = $MainPanel/ButtonRow/ResetButton
@onready var exit_button: Button = $MainPanel/ButtonRow/ExitButton
@onready var display_panel: Panel = $MainPanel/DisplayPanel
@onready var roxy_sprite: Sprite2D = $RoxySprite
@onready var cabinet_sprite: Sprite2D = $CabinetSprite
@onready var glitch_stripe_a: ColorRect = $MainPanel/DisplayPanel/GlitchStripeA
@onready var glitch_stripe_b: ColorRect = $MainPanel/DisplayPanel/GlitchStripeB
@onready var match_lights: Array[ColorRect] = [
	$MainPanel/DisplayPanel/MatchLights/Match1,
	$MainPanel/DisplayPanel/MatchLights/Match2,
	$MainPanel/DisplayPanel/MatchLights/Match3,
	$MainPanel/DisplayPanel/MatchLights/Match4,
]

var matches := 0
var ghost := 0.0
var completed := false
var running := false
var flicker_accum := 0.0
var cycle_accum := 0.0
var cycle_len := 1.3
var stable_window := STABLE_WINDOW_BASE * MATCH_TIMING_MULTIPLIER
var stable := false
var visual_time := 0.0
var feedback_tween: Tween = null

func _ready() -> void:
	score_button.pressed.connect(_on_score_pressed)
	reset_button.pressed.connect(_on_reset_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	randomize()
	_apply_screen_art()
	ArcadeScreen.apply(self)
	_start_game()

func _start_game() -> void:
	matches = 0
	ghost = 0.0
	completed = false
	running = true
	cycle_accum = 0.0
	cycle_len = 1.3
	stable_window = _get_stable_window()
	stable = false
	instruction_label.text = "FALSE BOARD // %s\nWait for 000099, then press MATCH.\nLock four before the ghost meter fills." % FALSE_SCORE
	score_button.text = "MATCH"
	score_button.visible = true
	reset_button.visible = true
	exit_button.visible = false
	status_label.text = "Roxy: \"Six digits. Four matches. Try to keep up.\""
	display_panel.modulate = Color.WHITE
	_refresh()
	score_button.grab_focus()

func _process(delta: float) -> void:
	visual_time += delta
	_update_side_motion()
	if not running or completed:
		return
	ghost += GHOST_RATE * delta
	if ghost >= GHOST_TARGET:
		_lose_round()
		return
	cycle_accum += delta
	if cycle_accum >= cycle_len:
		cycle_accum = 0.0
		cycle_len = max(randf_range(1.0, 1.5) - 0.05 * matches, 0.7)
		stable_window = _get_stable_window()
	stable = cycle_accum >= (cycle_len - stable_window)
	flicker_accum += delta
	if stable:
		corrupted_digit_label.text = RESTORED_SCORE_TEXT
	elif flicker_accum >= FLICKER_INTERVAL:
		flicker_accum = 0.0
		corrupted_digit_label.text = _build_glitch_score()
		_update_glitch_stripes()
	_refresh()

func _rand_glyph() -> String:
	return GLYPHS[randi() % GLYPHS.size()]

func _build_glitch_score() -> String:
	var digits: Array[String] = []
	for _index in DIGIT_COUNT:
		digits.append(_rand_glyph())
	return " ".join(digits)

func _on_score_pressed() -> void:
	if completed or not running:
		return
	if stable:
		matches += 1
		ghost = max(0.0, ghost - MATCH_REWARD)
		_play_audio("play_score_blip")
		_play_display_flash(COLOR_SIGNAL_STABLE)
		status_label.text = "Clean match. %d of %d signals verified." % [matches, TARGET_MATCHES]
		if matches >= TARGET_MATCHES:
			_complete_game()
			return
	else:
		ghost = min(GHOST_TARGET - 0.01, ghost + MISS_PENALTY)
		_play_audio("play_error_buzz")
		_play_display_flash(COLOR_SIGNAL_GLITCH)
		status_label.text = "Static mismatch. Roxy's ghost surges ahead."
	_refresh()

func _on_reset_pressed() -> void:
	if completed:
		return
	_start_game()

func _lose_round() -> void:
	matches = 0
	ghost = 0.0
	cycle_accum = 0.0
	_play_audio("play_error_buzz")
	status_label.text = "Roxy: \"Ghost wins. Again.\"\nAll four match lights reset. Watch the whole score."
	_play_display_flash(COLOR_SIGNAL_GLITCH)
	_refresh()

func _complete_game() -> void:
	completed = true
	running = false
	GameState.complete_broken_high_score()
	score_button.visible = false
	reset_button.visible = false
	exit_button.visible = true
	corrupted_digit_label.text = RESTORED_SCORE_TEXT
	fake_target_label.text = "ROXY GHOST // DEFEATED"
	ghost_bar.value = 0.0
	signal_label.text = "RECORD VERIFIED"
	signal_label.add_theme_color_override("font_color", COLOR_SIGNAL_STABLE)
	score_label.text = "RECORD 000099 RESTORED"
	for light in match_lights:
		light.color = COLOR_SIGNAL_STABLE
	glitch_stripe_a.visible = false
	glitch_stripe_b.visible = false
	status_label.text = "RECORD RESTORED // NAME STILL BLANK.\nOne win returned a clue, not the whole player."
	_play_display_flash(COLOR_SIGNAL_STABLE)
	_play_audio("play_success_jingle")
	exit_button.grab_focus()

func _refresh() -> void:
	fake_target_label.text = "ROXY GHOST: %02d / %02d" % [int(ghost), int(GHOST_TARGET)]
	ghost_bar.value = ghost
	score_label.text = "MATCHES: %d / %d" % [matches, TARGET_MATCHES]
	signal_label.text = "MATCH WINDOW" if stable else "SIGNAL SCRAMBLING"
	signal_label.add_theme_color_override("font_color", COLOR_SIGNAL_STABLE if stable else Color(0.43, 0.73, 0.82, 1.0))
	corrupted_digit_label.add_theme_color_override("font_color", COLOR_SIGNAL_STABLE if stable else COLOR_SIGNAL_GLITCH)
	glitch_stripe_a.visible = not stable
	glitch_stripe_b.visible = not stable
	for index in match_lights.size():
		match_lights[index].color = COLOR_MATCH_LOCKED if index < matches else COLOR_MATCH_EMPTY
	cabinet_sprite.modulate = Color(0.8, 1.0, 1.0, 1.0) if stable else Color.WHITE

func _get_stable_window() -> float:
	var base_window := STABLE_WINDOW_BASE - STABLE_WINDOW_PER_MATCH * matches
	return clamp(
		base_window * MATCH_TIMING_MULTIPLIER,
		STABLE_WINDOW_MIN * MATCH_TIMING_MULTIPLIER,
		STABLE_WINDOW_BASE * MATCH_TIMING_MULTIPLIER
	)

func _update_side_motion() -> void:
	roxy_sprite.position = ROXY_BASE_POSITION + Vector2(0.0, sin(visual_time * 2.2) * 1.5)
	cabinet_sprite.position = CABINET_BASE_POSITION + Vector2(0.0, sin(visual_time * 1.6 + 1.0) * 0.8)

func _update_glitch_stripes() -> void:
	glitch_stripe_a.position = Vector2(randf_range(18.0, 192.0), randf_range(50.0, 104.0))
	glitch_stripe_b.position = Vector2(randf_range(198.0, 246.0), randf_range(54.0, 106.0))

func _play_display_flash(color: Color) -> void:
	if feedback_tween and feedback_tween.is_valid():
		feedback_tween.kill()
	display_panel.modulate = Color(color.r, color.g, color.b, 0.78)
	feedback_tween = create_tween()
	feedback_tween.tween_property(display_panel, "modulate", Color.WHITE, 0.2)

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
	var texture := _load_texture(SCREEN_ART_PATH)
	if texture == null:
		return
	background_art.texture = texture
	background_art.visible = true
	background.visible = false

func _load_texture(path: String) -> Texture2D:
	if path.is_empty():
		return null
	if ResourceLoader.exists(path):
		var resource := load(path)
		if resource is Texture2D:
			return resource
	return _load_raw_png_texture(path)

func _load_raw_png_texture(path: String) -> Texture2D:
	if not path.ends_with(".png"):
		return null
	var image := Image.new()
	var error := image.load(path)
	if error != OK and path.begins_with("res://"):
		error = image.load(ProjectSettings.globalize_path(path))
	if error != OK:
		return null
	return ImageTexture.create_from_image(image)
