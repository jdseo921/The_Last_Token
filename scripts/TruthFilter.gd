extends Control

const ROUND_DATA: Array[Dictionary] = [
	{
		"rule": "Only one cabinet is telling the truth.",
		"statements": [
			"Mira said you were late again.",
			"Gus has never seen you before.",
			"Cabinet 07 only recognizes customers.",
		],
		"correct": 0,
	},
	{
		"rule": "Only one cabinet is lying.",
		"statements": [
			"The Lost Token woke a memory.",
			"The Staff Door already trusts you.",
			"Cabinet 07 remembers employees.",
		],
		"correct": 1,
	},
	{
		"rule": "The broken screen reverses its meaning.",
		"statements": [
			"You are the original.",
			"You are only a customer.",
			"You were restored.",
		],
		"correct": 0,
	},
	{
		"rule": "Choose the statement the arcade does not want you to read.",
		"statements": [
			"Employee 04 left safely.",
			"The backup was incomplete.",
			"The owner closed the arcade normally.",
		],
		"correct": 1,
	},
]

const CABINET_NORMAL_COLOR := Color(0.08, 0.09, 0.14, 1.0)
const CABINET_CORRECT_COLOR := Color(0.12, 0.34, 0.28, 1.0)
const CABINET_WRONG_COLOR := Color(0.34, 0.08, 0.14, 1.0)

@onready var rule_label: Label = $RulePanel/RuleLabel
@onready var status_label: Label = $StatusPanel/StatusLabel
@onready var cabinet_panels: Array[Panel] = [
	$StageArea/CabinetA,
	$StageArea/CabinetB,
	$StageArea/CabinetC,
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

var current_round := 0
var completed := false
var feedback_tween: Tween = null

func _ready() -> void:
	for index in range(choose_buttons.size()):
		choose_buttons[index].pressed.connect(_on_choice_pressed.bind(index))
	exit_button.pressed.connect(_on_exit_pressed)
	_start_puzzle()

func _start_puzzle() -> void:
	current_round = 0
	completed = false
	exit_button.visible = false
	for button in choose_buttons:
		button.visible = true
		button.disabled = false
	_show_round()

func _show_round() -> void:
	var round_data := ROUND_DATA[current_round]
	rule_label.text = "Round %d / %d\n%s" % [current_round + 1, ROUND_DATA.size(), str(round_data["rule"])]
	var statements: Array = round_data["statements"]
	for index in range(statement_labels.size()):
		statement_labels[index].text = str(statements[index])
		_set_panel_color(cabinet_panels[index], CABINET_NORMAL_COLOR)
	status_label.text = "Read the rule. Choose the matching cabinet."
	_set_choice_buttons_enabled(true)
	choose_buttons[0].grab_focus()

func _on_choice_pressed(index: int) -> void:
	if completed:
		return
	_set_choice_buttons_enabled(false)
	var correct_index := int(ROUND_DATA[current_round]["correct"])
	if index != correct_index:
		status_label.text = "MEMORY SIGNAL WOBBLED.\nTry again."
		_set_panel_color(cabinet_panels[index], CABINET_WRONG_COLOR)
		_play_audio("play_error")
		await _play_glitch_feedback()
		_set_panel_color(cabinet_panels[index], CABINET_NORMAL_COLOR)
		_set_choice_buttons_enabled(true)
		choose_buttons[index].grab_focus()
		return
	_set_panel_color(cabinet_panels[index], CABINET_CORRECT_COLOR)
	status_label.text = "Statement accepted."
	_play_audio("play_ui_confirm")
	await get_tree().create_timer(0.35).timeout
	current_round += 1
	if current_round >= ROUND_DATA.size():
		_complete_puzzle()
		return
	_show_round()

func _complete_puzzle() -> void:
	completed = true
	GameState.complete_truth_filter()
	rule_label.text = "TRUTH FILTER COMPLETE"
	status_label.text = "TRUTH FILTER PASSED.\nSECOND MEMORY FRAGMENT RECOVERED.\nYOUR MEMORY IS NO LONGER THE ONLY WITNESS."
	for index in range(cabinet_panels.size()):
		_set_panel_color(cabinet_panels[index], CABINET_CORRECT_COLOR)
	for button in choose_buttons:
		button.visible = false
	exit_button.visible = true
	exit_button.text = "Return to Arcade"
	_play_audio("play_token_get")
	exit_button.grab_focus()

func _on_exit_pressed() -> void:
	_play_audio("play_ui_confirm")
	SceneChanger.go_to_arcade_hub()

func _set_choice_buttons_enabled(enabled: bool) -> void:
	for button in choose_buttons:
		button.disabled = not enabled

func _set_panel_color(panel: Panel, color: Color) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = Color(0.46, 0.85, 0.95, 0.72)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	panel.add_theme_stylebox_override("panel", style)

func _play_glitch_feedback() -> void:
	if feedback_tween and feedback_tween.is_valid():
		feedback_tween.kill()
	glitch_overlay.visible = true
	glitch_overlay.modulate.a = 0.0
	feedback_tween = create_tween()
	feedback_tween.tween_property(glitch_overlay, "modulate:a", 0.35, 0.06)
	feedback_tween.tween_property(glitch_overlay, "modulate:a", 0.0, 0.16)
	feedback_tween.tween_callback(_hide_glitch_overlay)
	await feedback_tween.finished

func _hide_glitch_overlay() -> void:
	glitch_overlay.visible = false

func _play_audio(method_name: String) -> void:
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager and audio_manager.has_method(method_name):
		audio_manager.call(method_name)
