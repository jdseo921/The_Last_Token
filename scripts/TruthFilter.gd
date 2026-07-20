extends Control

const BACKGROUND_ART_PATH := "res://assets/art/minigames/truth_filter/backgrounds/truth_filter_verdict_chamber.png"
const CABINET_SHEET_PATH := "res://assets/art/minigames/truth_filter/truth_filter_deluxe_cabinet_states.png"
const CABINET_ART_NORMAL := "normal"
const CABINET_ART_ACTIVE := "active"
const CABINET_ART_CORRECT := "correct"
const CABINET_ART_WRONG := "wrong"
const ARCADE_JUICE := preload("res://scripts/ArcadeJuice.gd")

const ROUND_DATA: Array[Dictionary] = [
	{
		"rule": "Only one cabinet matches the shift log. Choose it.",
		"transition": "The filter checks the final night's shift log.",
		"statements": [
			"Mira signed the register before close.",
			"Gus stayed mopping past midnight.",
			"Every machine was powered down that night.",
		],
		"correct": 0,
		"explanation": "23:41 - Mira signed the register and left. The log does not lie.",
	},
	{
		"rule": "Only one cabinet is lying. The log knows.",
		"transition": "The filter checks the return tray records.",
		"statements": [
			"The closing checklist was run alone.",
			"Cabinet 07 kept a token in its tray.",
			"The return tray was emptied before close.",
		],
		"correct": 2,
		"explanation": "00:19 - the tray kept one token. Flagged: do not empty.",
	},
	{
		"rule": "Two cabinets copied the log. One wrote its own ending. Choose it.",
		"transition": "The filter checks the backup records.",
		"statements": [
			"The backup finished clean.",
			"The backup started after midnight.",
			"The backup did not finish.",
		],
		"correct": 0,
		"explanation": "00:33 - backup started, never finished. Someone wanted a cleaner ending.",
	},
	{
		"rule": "Choose the line the arcade does not want you to read.",
		"transition": "The filter checks how the log ends.",
		"statements": [
			"The last shift signed out on time.",
			"No sign-out was recorded for the last shift.",
			"The register page was archived complete.",
		],
		"correct": 1,
		"explanation": "Entry ends. No sign-out recorded. The page is still waiting.",
	},
	{
		"rule": "Two records confuse outcome with motive. Choose the lucid motive.",
		"transition": "The arcade tests what it still believes about you.",
		"statements": [
			"This place was built to be somewhere kinder to go.",
			"You were only ever a visitor here.",
			"The arcade closed because its owner stopped caring.",
		],
		"correct": 0,
		"explanation": "Debt ended the arcade. It did not make the care that built it false.",
	},
]

const CABINET_NORMAL_COLOR := Color(0.03, 0.05, 0.1, 0.54)
const CABINET_CORRECT_COLOR := Color(0.05, 0.3, 0.22, 0.62)
const CABINET_WRONG_COLOR := Color(0.32, 0.04, 0.13, 0.65)
const CABINET_ACTIVE_COLOR := Color(0.14, 0.06, 0.26, 0.62)
const SCREEN_NORMAL_COLOR := Color(0.08, 0.44, 0.53, 0.42)
const SCREEN_CORRECT_COLOR := Color(0.16, 0.72, 0.48, 0.58)
const SCREEN_WRONG_COLOR := Color(0.76, 0.05, 0.3, 0.62)
const ROUND_EMPTY_COLOR := Color(0.1, 0.16, 0.24, 1.0)
const ROUND_ACTIVE_COLOR := Color(0.62, 0.22, 0.88, 1.0)
const ROUND_VERIFIED_COLOR := Color(0.18, 0.95, 0.68, 1.0)
const ROUND_WRONG_COLOR := Color(1.0, 0.16, 0.46, 1.0)

const LIE_DRIFT_BASE := 5.0
const LIE_DRIFT_PER_ROUND := 2.5
const LIE_WRONG_PENALTY := 22.0
const LIE_CORRECT_RELIEF := 34.0
const LIE_START := 16.0
const LIE_MAX := 100.0

const CORRUPT_GLYPHS := "#%&@?!/\\+="
const FLICKER_LUCID_BASE := 1.15
const FLICKER_LUCID_PER_ROUND := 0.14
const FLICKER_LUCID_MIN := 0.38
const FLICKER_CORRUPT_BASE := 0.3
const FLICKER_CORRUPT_PER_ROUND := 0.06

@onready var rule_label: Label = $RulePanel/RuleLabel
@onready var memory_signal_label: Label = $SignalPanel/SignalVBox/MemorySignalLabel
@onready var signal_integrity_label: Label = $SignalPanel/SignalVBox/SignalIntegrityLabel
@onready var density_bar: ProgressBar = $SignalPanel/SignalVBox/DensityBar
@onready var status_label: Label = $StatusPanel/StatusLabel
@onready var cabinet_panels: Array[Panel] = [
	$StageArea/CabinetA,
	$StageArea/CabinetB,
	$StageArea/CabinetC,
]
@onready var cabinet_screen_rects: Array[ColorRect] = [
	$StageArea/CabinetA/ScreenGlow,
	$StageArea/CabinetB/ScreenGlow,
	$StageArea/CabinetC/ScreenGlow,
]
@onready var cabinet_art_rects: Array[TextureRect] = [
	$StageArea/CabinetA/CabinetArt,
	$StageArea/CabinetB/CabinetArt,
	$StageArea/CabinetC/CabinetArt,
]
@onready var statement_labels: Array[Label] = [
	$StageArea/CabinetA/StatementLabel,
	$StageArea/CabinetB/StatementLabel,
	$StageArea/CabinetC/StatementLabel,
]
@onready var choose_buttons: Array[Button] = [
	$ButtonArea/ChooseAButton,
	$ButtonArea/ChooseBButton,
	$ButtonArea/ChooseCButton,
]
@onready var exit_button: Button = $ButtonArea/ExitButton
@onready var glitch_overlay: ColorRect = $GlitchOverlay
@onready var scanner_beam: ColorRect = $StageArea/ScannerBeam
@onready var round_lights: Array[ColorRect] = [
	$RulePanel/RoundLights/Round1,
	$RulePanel/RoundLights/Round2,
	$RulePanel/RoundLights/Round3,
	$RulePanel/RoundLights/Round4,
	$RulePanel/RoundLights/Round5,
]

var current_round := 0
var completed := false
var feedback_tween: Tween = null
var round_transition_running := false
var cabinet_sheet_texture: Texture2D = null
var lie_density := 0.0
var round_active := false
var cabinet_home_positions: Array[Vector2] = []
var corrupted_statements: Array[String] = []
var flicker_timers: Array[float] = []
var flicker_lucid: Array[bool] = []
var visual_time := 0.0

func _ready() -> void:
	AudioManager.play_music_for_context("truth_filter")
	ArcadeScreen.apply(self, BACKGROUND_ART_PATH)
	for index in range(choose_buttons.size()):
		choose_buttons[index].pressed.connect(_on_choice_pressed.bind(index))
	exit_button.pressed.connect(_on_exit_pressed)
	_apply_cabinet_art_sheet()
	_start_puzzle()

func _start_puzzle() -> void:
	if cabinet_home_positions.is_empty():
		for panel in cabinet_panels:
			cabinet_home_positions.append(panel.position)
	current_round = 0
	completed = false
	round_transition_running = false
	exit_button.visible = false
	memory_signal_label.text = "SOURCE: STAFF SHIFT LOG"
	density_bar.max_value = LIE_MAX
	density_bar.value = 0.0
	scanner_beam.visible = true
	_update_round_lights()
	_set_signal_integrity("Stable")
	for button in choose_buttons:
		button.visible = true
		button.disabled = false
	_begin_round()

func _begin_round() -> void:
	round_transition_running = true
	round_active = false
	_set_choice_buttons_enabled(false)
	var round_data := ROUND_DATA[current_round]
	_update_round_lights()
	rule_label.text = "Round %d / %d" % [current_round + 1, ROUND_DATA.size()]
	status_label.text = str(round_data["transition"])
	for index in range(statement_labels.size()):
		statement_labels[index].text = "..."
		_set_panel_state(index, CABINET_ACTIVE_COLOR, SCREEN_NORMAL_COLOR, CABINET_ART_ACTIVE)
	await get_tree().create_timer(0.95).timeout
	if completed:
		return
	round_transition_running = false
	_show_round()

func _show_round() -> void:
	var round_data := ROUND_DATA[current_round]
	rule_label.text = "Round %d / %d\n%s" % [current_round + 1, ROUND_DATA.size(), str(round_data["rule"])]
	var statements: Array = round_data["statements"]
	corrupted_statements.clear()
	flicker_timers.clear()
	flicker_lucid.clear()
	for index in range(statement_labels.size()):
		statement_labels[index].text = str(statements[index])
		corrupted_statements.append(_corrupt_text(str(statements[index]), current_round))
		flicker_timers.append(-0.55 * index)
		flicker_lucid.append(true)
		_set_panel_state(index, CABINET_NORMAL_COLOR, SCREEN_NORMAL_COLOR, CABINET_ART_NORMAL)
		cabinet_panels[index].position = cabinet_home_positions[index] if index < cabinet_home_positions.size() else cabinet_panels[index].position
	status_label.text = "Records flicker between truth and static.\nRead them while lucid. Choose the matching record."
	_set_signal_integrity("Stable")
	_set_choice_buttons_enabled(true)
	lie_density = LIE_START
	round_active = true
	_update_round_lights()
	_update_density()
	choose_buttons[0].grab_focus()

func _on_choice_pressed(index: int) -> void:
	if completed or round_transition_running:
		return
	round_active = false
	_show_true_statements()
	ARCADE_JUICE.pulse_control(self, choose_buttons[index])
	_set_choice_buttons_enabled(false)
	var correct_index := int(ROUND_DATA[current_round]["correct"])
	if index != correct_index:
		lie_density = min(LIE_MAX - 1.0, lie_density + LIE_WRONG_PENALTY)
		status_label.text = "FALSE RECORD SORTED.\nStatic spikes. Try again."
		_set_signal_integrity("Wobbling")
		_set_panel_state(index, CABINET_WRONG_COLOR, SCREEN_WRONG_COLOR, CABINET_ART_WRONG)
		_set_round_light(current_round, ROUND_WRONG_COLOR)
		_play_audio("play_error_buzz")
		await _play_wrong_feedback(index)
		_set_panel_state(index, CABINET_NORMAL_COLOR, SCREEN_NORMAL_COLOR, CABINET_ART_NORMAL)
		_update_round_lights()
		_set_choice_buttons_enabled(true)
		round_active = true
		choose_buttons[index].grab_focus()
		return
	lie_density = max(0.0, lie_density - LIE_CORRECT_RELIEF)
	_set_panel_state(index, CABINET_CORRECT_COLOR, SCREEN_CORRECT_COLOR, CABINET_ART_CORRECT)
	_set_round_light(current_round, ROUND_VERIFIED_COLOR)
	_set_signal_integrity("Recovered")
	status_label.text = "Statement accepted."
	_play_audio("play_score_blip")
	await _play_correct_feedback(index)
	status_label.text = str(ROUND_DATA[current_round]["explanation"])
	await get_tree().create_timer(1.35).timeout
	current_round += 1
	if current_round >= ROUND_DATA.size():
		_complete_puzzle()
		return
	_begin_round()

func _complete_puzzle() -> void:
	completed = true
	round_active = false
	round_transition_running = false
	GameState.complete_truth_filter()
	memory_signal_label.text = "SOURCE: STAFF SHIFT LOG"
	_set_signal_integrity("Recovered")
	density_bar.value = 0.0
	density_bar.modulate = ROUND_VERIFIED_COLOR
	scanner_beam.visible = false
	for round_index in round_lights.size():
		_set_round_light(round_index, ROUND_VERIFIED_COLOR)
	rule_label.text = "TRUTH FILTER COMPLETE"
	status_label.text = "SECOND TOKEN RECOVERED. RECORD TRUE; IDENTITY UNSETTLED."
	for index in range(cabinet_panels.size()):
		_set_panel_state(index, CABINET_CORRECT_COLOR, SCREEN_CORRECT_COLOR, CABINET_ART_CORRECT)
	for button in choose_buttons:
		button.visible = false
	exit_button.visible = true
	exit_button.text = "Return to Cabinet Row"
	_play_audio("play_success_jingle")
	exit_button.grab_focus()

func _on_exit_pressed() -> void:
	ARCADE_JUICE.pulse_control(self, exit_button)
	_play_audio("play_button_pulse")
	GameState.set_pending_spawn_id("Spawn_FromTruthFilter")
	SceneChanger.go_to_cabinet_row()

func _set_choice_buttons_enabled(enabled: bool) -> void:
	for button in choose_buttons:
		button.disabled = not enabled

func _set_panel_state(index: int, panel_color: Color, screen_color: Color, art_state: String = CABINET_ART_NORMAL) -> void:
	if index < 0 or index >= cabinet_panels.size():
		return
	_set_panel_color(cabinet_panels[index], panel_color)
	cabinet_screen_rects[index].color = screen_color
	_set_cabinet_art_state(index, art_state)

func _set_signal_integrity(value: String) -> void:
	signal_integrity_label.text = "FIND THE LUCID RECORD"
	match value:
		"Wobbling":
			signal_integrity_label.modulate = Color(1.0, 0.58, 0.82, 1.0)
		"Recovered":
			signal_integrity_label.modulate = Color(0.62, 1.0, 0.88, 1.0)
		_:
			signal_integrity_label.modulate = Color.WHITE

func _set_panel_color(panel: Panel, color: Color) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = Color(0.38, 0.88, 0.96, 0.68)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	panel.add_theme_stylebox_override("panel", style)

func _apply_cabinet_art_sheet() -> void:
	cabinet_sheet_texture = _load_texture(CABINET_SHEET_PATH)
	for rect in cabinet_art_rects:
		rect.visible = cabinet_sheet_texture != null
		rect.texture = null
	if cabinet_sheet_texture != null:
		for index in range(cabinet_art_rects.size()):
			_set_cabinet_art_state(index, CABINET_ART_NORMAL)

func _set_cabinet_art_state(index: int, art_state: String) -> void:
	if cabinet_sheet_texture == null or index < 0 or index >= cabinet_art_rects.size():
		return
	var rect := cabinet_art_rects[index]
	rect.texture = _get_cabinet_atlas(art_state)
	rect.visible = true

func _get_cabinet_atlas(art_state: String) -> AtlasTexture:
	var frame_index := 0
	match art_state:
		CABINET_ART_ACTIVE:
			frame_index = 1
		CABINET_ART_CORRECT:
			frame_index = 2
		CABINET_ART_WRONG:
			frame_index = 3
		_:
			frame_index = 0
	var frame_width := maxi(int(cabinet_sheet_texture.get_width() / 4), 1)
	var atlas := AtlasTexture.new()
	atlas.atlas = cabinet_sheet_texture
	atlas.region = Rect2(frame_index * frame_width, 0, frame_width, cabinet_sheet_texture.get_height())
	return atlas

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

func _play_wrong_feedback(index: int) -> void:
	if feedback_tween and feedback_tween.is_valid():
		feedback_tween.kill()
	glitch_overlay.visible = true
	glitch_overlay.modulate.a = 0.0
	var panel := cabinet_panels[index]
	var home: Vector2 = cabinet_home_positions[index] if index < cabinet_home_positions.size() else panel.position
	panel.position = home
	feedback_tween = create_tween()
	feedback_tween.tween_property(glitch_overlay, "modulate:a", 0.35, 0.06)
	feedback_tween.tween_property(panel, "position", home + Vector2(-4, 0), 0.04)
	feedback_tween.tween_property(panel, "position", home + Vector2(4, 0), 0.04)
	feedback_tween.tween_property(panel, "position", home, 0.05)
	feedback_tween.tween_property(glitch_overlay, "modulate:a", 0.0, 0.12)
	feedback_tween.tween_callback(_hide_glitch_overlay)
	await feedback_tween.finished

func _play_correct_feedback(index: int) -> void:
	if feedback_tween and feedback_tween.is_valid():
		feedback_tween.kill()
	var screen := cabinet_screen_rects[index]
	var panel := cabinet_panels[index]
	feedback_tween = create_tween()
	ARCADE_JUICE.flash_overlay(self, glitch_overlay, ARCADE_JUICE.FLASH_CYAN, 0.16)
	feedback_tween.tween_property(panel, "scale", Vector2(1.035, 1.035), 0.08)
	feedback_tween.tween_property(screen, "modulate:a", 0.35, 0.08)
	feedback_tween.tween_property(screen, "modulate:a", 1.0, 0.1)
	feedback_tween.tween_property(panel, "scale", Vector2.ONE, 0.1)
	await feedback_tween.finished

func _hide_glitch_overlay() -> void:
	glitch_overlay.visible = false
	for index in range(cabinet_panels.size()):
		cabinet_panels[index].position = cabinet_home_positions[index] if index < cabinet_home_positions.size() else cabinet_panels[index].position

func _play_audio(method_name: String) -> void:
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager and audio_manager.has_method(method_name):
		audio_manager.call(method_name)

func _process(delta: float) -> void:
	visual_time += delta
	_update_scanner_beam()
	if completed or not round_active:
		return
	lie_density += (LIE_DRIFT_BASE + LIE_DRIFT_PER_ROUND * current_round) * delta
	if lie_density >= LIE_MAX:
		_destabilize()
		return
	_update_density()
	_update_flicker(delta)

func _update_flicker(delta: float) -> void:
	if flicker_timers.size() != statement_labels.size():
		return
	var lucid_time: float = maxf(
		FLICKER_LUCID_BASE - FLICKER_LUCID_PER_ROUND * current_round - lie_density * 0.004,
		FLICKER_LUCID_MIN
	)
	var corrupt_time: float = FLICKER_CORRUPT_BASE + FLICKER_CORRUPT_PER_ROUND * current_round
	var statements: Array = ROUND_DATA[current_round]["statements"]
	for index in range(statement_labels.size()):
		flicker_timers[index] += delta
		var limit := lucid_time if flicker_lucid[index] else corrupt_time
		if flicker_timers[index] >= limit:
			flicker_timers[index] = 0.0
			flicker_lucid[index] = not flicker_lucid[index]
			if flicker_lucid[index]:
				statement_labels[index].text = str(statements[index])
			else:
				statement_labels[index].text = corrupted_statements[index]

func _show_true_statements() -> void:
	var statements: Array = ROUND_DATA[current_round]["statements"]
	for index in range(statement_labels.size()):
		statement_labels[index].text = str(statements[index])

func _corrupt_text(text: String, seed_round: int) -> String:
	var out := ""
	for i in range(text.length()):
		var ch := text[i]
		if ch == " ":
			out += " "
		elif (i * 31 + seed_round * 17 + text.length()) % 100 < 52:
			out += CORRUPT_GLYPHS[(i * 7 + seed_round * 3) % CORRUPT_GLYPHS.length()]
		else:
			out += ch
	return out

func _update_density() -> void:
	density_bar.value = lie_density
	if lie_density >= 70.0:
		signal_integrity_label.modulate = Color(1.0, 0.42, 0.6, 1.0)
		density_bar.modulate = ROUND_WRONG_COLOR
		scanner_beam.color = Color(1.0, 0.12, 0.48, 0.16)
	elif lie_density >= 40.0:
		signal_integrity_label.modulate = Color(1.0, 0.86, 0.5, 1.0)
		density_bar.modulate = Color(1.0, 0.76, 0.28, 1.0)
		scanner_beam.color = Color(0.76, 0.28, 1.0, 0.14)
	else:
		signal_integrity_label.modulate = Color(0.62, 1.0, 0.88, 1.0)
		density_bar.modulate = Color(0.28, 1.0, 0.86, 1.0)
		scanner_beam.color = Color(0.2, 0.98, 1.0, 0.12)
	var legibility: float = clampf(1.2 - lie_density / 100.0, 0.4, 1.0)
	for label in statement_labels:
		label.modulate.a = legibility

func _destabilize() -> void:
	lie_density = 55.0
	_play_audio("play_error_buzz")
	ARCADE_JUICE.flash_overlay(self, glitch_overlay, ARCADE_JUICE.FLASH_RED, 0.3)
	status_label.text = "STATIC CRITICAL.\nThe filter purges the records and re-lists. Read faster."
	_set_round_light(current_round, ROUND_WRONG_COLOR)
	_update_density()

func _update_round_lights() -> void:
	for index in round_lights.size():
		var color := ROUND_EMPTY_COLOR
		if completed or index < current_round:
			color = ROUND_VERIFIED_COLOR
		elif index == current_round:
			color = ROUND_ACTIVE_COLOR
		_set_round_light(index, color)

func _set_round_light(index: int, color: Color) -> void:
	if index < 0 or index >= round_lights.size():
		return
	round_lights[index].color = color

func _update_scanner_beam() -> void:
	if completed:
		scanner_beam.visible = false
		return
	scanner_beam.visible = round_active or round_transition_running
	var travel_width := 628.0
	scanner_beam.position = Vector2(fmod(visual_time * 92.0, travel_width) - 32.0, 4.0)
