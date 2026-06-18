extends Control

@onready var title_label: Label = $Panel/VBox/TitleLabel
@onready var instruction_label: Label = $Panel/VBox/InstructionLabel
@onready var door_label: Label = $Panel/VBox/DoorLabel
@onready var status_label: Label = $Panel/VBox/StatusLabel
@onready var switch_a_button: Button = $Panel/VBox/SwitchesHBox/SwitchAButton
@onready var switch_b_button: Button = $Panel/VBox/SwitchesHBox/SwitchBButton
@onready var exit_button: Button = $Panel/VBox/ExitButton
@onready var switch_a_timer: Timer = $SwitchATimer
@onready var switch_b_timer: Timer = $SwitchBTimer

var switch_a_active := false
var switch_b_active := false
var puzzle_solved := false

func _ready() -> void:
	switch_a_button.pressed.connect(_on_switch_a_pressed)
	switch_b_button.pressed.connect(_on_switch_b_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	switch_a_timer.timeout.connect(_on_switch_a_timeout)
	switch_b_timer.timeout.connect(_on_switch_b_timeout)
	_refresh_ui()

func _on_switch_a_pressed() -> void:
	if puzzle_solved:
		return
	switch_a_active = true
	switch_a_timer.start()
	_refresh_ui()
	_check_success()

func _on_switch_b_pressed() -> void:
	if puzzle_solved:
		return
	switch_b_active = true
	switch_b_timer.start()
	_refresh_ui()
	_check_success()

func _on_switch_a_timeout() -> void:
	if puzzle_solved:
		return
	switch_a_active = false
	_refresh_ui()

func _on_switch_b_timeout() -> void:
	if puzzle_solved:
		return
	switch_b_active = false
	_refresh_ui()

func _check_success() -> void:
	if switch_a_active and switch_b_active and not puzzle_solved:
		puzzle_solved = true
		switch_a_timer.stop()
		switch_b_timer.stop()
		GameState.story_puzzle_completed = true
		GameState.unlock_staff_room()
		_play_audio("play_ui_confirm")
		door_label.text = "Staff Door: OPEN"
		status_label.text = "Staff Door: \"TWO SIGNALS DETECTED.\"\nStaff Door: \"ORIGINAL: ABSENT.\"\nStaff Door: \"RESTORED: PRESENT.\"\nStaff Door: \"ACCESS GRANTED.\""
		switch_a_button.visible = false
		switch_b_button.visible = false
		exit_button.visible = true

func _on_exit_pressed() -> void:
	SceneChanger.go_to_arcade_hub()

func _refresh_ui() -> void:
	if puzzle_solved:
		return
	door_label.text = "Staff Door: LOCKED"
	status_label.text = "Switch A: %s\nSwitch B: %s" % ["ON" if switch_a_active else "OFF", "ON" if switch_b_active else "OFF"]

func _play_audio(method_name: String) -> void:
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager and audio_manager.has_method(method_name):
		audio_manager.call(method_name)
