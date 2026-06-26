extends Control

const PHASE_BASIC := 0
const PHASE_REVERSED := 1
const PHASE_STABLE_PULSE := 2
const SWITCH_ACTIVE_SECONDS := 5.0

const SWITCH_INACTIVE_COLOR := Color(0.12, 0.13, 0.17, 1.0)
const SWITCH_ACTIVE_COLOR := Color(0.1, 0.34, 0.28, 1.0)
const SWITCH_WARNING_COLOR := Color(0.34, 0.16, 0.3, 1.0)
const DOOR_LOCKED_COLOR := Color(0.22, 0.08, 0.1, 1.0)
const DOOR_UNLOCKED_COLOR := Color(0.1, 0.36, 0.24, 1.0)

@onready var title_label: Label = $Panel/VBox/TitleLabel
@onready var instruction_label: Label = $Panel/VBox/InstructionLabel
@onready var phase_label: Label = $Panel/VBox/PhaseLabel
@onready var warning_label: Label = $Panel/VBox/WarningLabel
@onready var door_label: Label = $Panel/VBox/DoorLabel
@onready var status_label: Label = $Panel/VBox/StatusLabel
@onready var signal_bar: ColorRect = $Panel/VBox/SignalBar
@onready var switch_a_button: Button = $Panel/VBox/SwitchesHBox/SwitchAButton
@onready var switch_b_button: Button = $Panel/VBox/SwitchesHBox/SwitchBButton
@onready var confirm_sync_button: Button = $Panel/VBox/ConfirmSyncButton
@onready var exit_button: Button = $Panel/VBox/ExitButton
@onready var switch_a_timer: Timer = $SwitchATimer
@onready var switch_b_timer: Timer = $SwitchBTimer

var current_phase := PHASE_BASIC
var switch_a_active := false
var switch_b_active := false
var puzzle_solved := false
var pulse_tween: Tween = null

func _ready() -> void:
	AudioManager.play_music_for_context("maintenance_sync")
	switch_a_button.pressed.connect(_on_switch_a_pressed)
	switch_b_button.pressed.connect(_on_switch_b_pressed)
	confirm_sync_button.pressed.connect(_on_confirm_sync_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	switch_a_timer.timeout.connect(_on_switch_a_timeout)
	switch_b_timer.timeout.connect(_on_switch_b_timeout)
	switch_a_timer.wait_time = SWITCH_ACTIVE_SECONDS
	switch_b_timer.wait_time = SWITCH_ACTIVE_SECONDS
	title_label.text = "MAINTENANCE SYNC"
	instruction_label.text = "Two signals must be active together.\nOne signal remembers.\nOne signal returns."
	_start_phase(PHASE_BASIC)
	switch_a_button.grab_focus()

func _process(_delta: float) -> void:
	if puzzle_solved:
		return
	_refresh_ui()

func _start_phase(phase: int) -> void:
	current_phase = phase
	_reset_switches()
	confirm_sync_button.visible = false
	confirm_sync_button.disabled = true
	switch_a_button.visible = true
	switch_b_button.visible = true
	switch_a_button.disabled = false
	switch_b_button.disabled = false
	exit_button.visible = false
	match current_phase:
		PHASE_REVERSED:
			phase_label.text = "Phase 2 / 3 - Reversed Signal"
			warning_label.text = "WARNING: ONE LABEL IS REVERSED."
			status_label.text = "Switch A label lies. Activate both real switches."
		PHASE_STABLE_PULSE:
			phase_label.text = "Phase 3 / 3 - Stable Pulse"
			warning_label.text = "CONFIRM REQUIRED WHILE BOTH SIGNALS HOLD."
			status_label.text = "Activate A, then B, then confirm sync before either expires."
		_:
			phase_label.text = "Phase 1 / 3 - Basic Sync"
			warning_label.text = ""
			status_label.text = "Activate both switches before either timer expires."
	_refresh_ui()

func _on_switch_a_pressed() -> void:
	if puzzle_solved:
		return
	_play_audio("play_ui_confirm")
	switch_a_active = true
	switch_a_timer.start(SWITCH_ACTIVE_SECONDS)
	_refresh_ui()
	_check_phase_progress()

func _on_switch_b_pressed() -> void:
	if puzzle_solved:
		return
	_play_audio("play_ui_confirm")
	switch_b_active = true
	switch_b_timer.start(SWITCH_ACTIVE_SECONDS)
	_refresh_ui()
	_check_phase_progress()

func _on_confirm_sync_pressed() -> void:
	if puzzle_solved or current_phase != PHASE_STABLE_PULSE:
		return
	if switch_a_active and switch_b_active:
		_complete_puzzle()
		return
	_signal_lost()

func _on_switch_a_timeout() -> void:
	if puzzle_solved:
		return
	switch_a_active = false
	_handle_timeout()

func _on_switch_b_timeout() -> void:
	if puzzle_solved:
		return
	switch_b_active = false
	_handle_timeout()

func _handle_timeout() -> void:
	if current_phase == PHASE_STABLE_PULSE:
		_signal_lost()
		return
	_refresh_ui()

func _check_phase_progress() -> void:
	if not switch_a_active or not switch_b_active:
		return
	match current_phase:
		PHASE_BASIC:
			status_label.text = "BASIC SYNC ACCEPTED."
			_play_phase_accept()
			await get_tree().create_timer(0.55).timeout
			_start_phase(PHASE_REVERSED)
		PHASE_REVERSED:
			status_label.text = "REVERSED SIGNAL ACCEPTED."
			_play_phase_accept()
			await get_tree().create_timer(0.55).timeout
			_start_phase(PHASE_STABLE_PULSE)
		PHASE_STABLE_PULSE:
			status_label.text = "Both signals detected. Confirm sync now."
			confirm_sync_button.visible = true
			confirm_sync_button.disabled = false
			confirm_sync_button.grab_focus()

func _complete_puzzle() -> void:
	puzzle_solved = true
	switch_a_timer.stop()
	switch_b_timer.stop()
	GameState.complete_maintenance_sync()
	_play_audio("play_ui_confirm")
	door_label.text = "Staff Door: OPEN"
	status_label.text = "TWO SIGNALS DETECTED.\nRESTORED SIGNAL PRESENT.\nMEMORY SIGNAL: OVERLOADED.\nACCESS GRANTED."
	warning_label.text = ""
	signal_bar.color = Color(0.22, 0.95, 0.68, 1.0)
	switch_a_button.visible = false
	switch_b_button.visible = false
	confirm_sync_button.visible = false
	exit_button.visible = true
	_set_button_panel_color(switch_a_button, SWITCH_ACTIVE_COLOR)
	_set_button_panel_color(switch_b_button, SWITCH_ACTIVE_COLOR)
	_set_door_color(DOOR_UNLOCKED_COLOR)
	exit_button.grab_focus()

func _signal_lost() -> void:
	_play_audio("play_error")
	status_label.text = "Signal lost.\nTry again."
	_reset_switches()
	confirm_sync_button.visible = false
	confirm_sync_button.disabled = true
	_refresh_ui()
	switch_a_button.grab_focus()

func _reset_switches() -> void:
	switch_a_active = false
	switch_b_active = false
	switch_a_timer.stop()
	switch_b_timer.stop()

func _on_exit_pressed() -> void:
	_play_audio("play_ui_confirm")
	SceneChanger.go_to_maintenance_hall()

func _refresh_ui() -> void:
	if puzzle_solved:
		return
	door_label.text = "Staff Door: LOCKED"
	_set_door_color(DOOR_LOCKED_COLOR)
	switch_a_button.text = "Switch A: %s" % _get_switch_a_display_label()
	switch_b_button.text = "Switch B: %s" % ["ON" if switch_b_active else "OFF"]
	_set_button_panel_color(switch_a_button, SWITCH_ACTIVE_COLOR if switch_a_active else SWITCH_INACTIVE_COLOR)
	_set_button_panel_color(switch_b_button, SWITCH_ACTIVE_COLOR if switch_b_active else SWITCH_INACTIVE_COLOR)
	_refresh_signal_bar()
	if current_phase == PHASE_STABLE_PULSE and switch_a_active and switch_b_active:
		confirm_sync_button.visible = true
		confirm_sync_button.disabled = false

func _get_switch_a_display_label() -> String:
	if current_phase == PHASE_REVERSED:
		return "OFF" if switch_a_active else "ON"
	return "ON" if switch_a_active else "OFF"

func _refresh_signal_bar() -> void:
	var active_count := (1 if switch_a_active else 0) + (1 if switch_b_active else 0)
	match active_count:
		2:
			signal_bar.color = Color(0.22, 0.95, 0.68, 0.85)
		1:
			signal_bar.color = Color(0.75, 0.58, 0.25, 0.8)
		_:
			signal_bar.color = Color(0.18, 0.22, 0.34, 0.8)

func _play_phase_accept() -> void:
	_play_audio("play_ui_confirm")
	if pulse_tween and pulse_tween.is_valid():
		pulse_tween.kill()
	pulse_tween = create_tween()
	pulse_tween.tween_property(signal_bar, "modulate:a", 0.35, 0.08)
	pulse_tween.tween_property(signal_bar, "modulate:a", 1.0, 0.16)

func _set_button_panel_color(button: Button, color: Color) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = Color(0.48, 0.86, 0.95, 0.82)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", style)
	button.add_theme_stylebox_override("pressed", style)

func _set_door_color(color: Color) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = Color(0.8, 0.85, 0.95, 0.65)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	door_label.add_theme_stylebox_override("normal", style)

func _play_audio(method_name: String) -> void:
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager and audio_manager.has_method(method_name):
		audio_manager.call(method_name)
