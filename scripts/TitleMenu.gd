extends Control

signal new_memory_requested
signal restore_memory_requested

@onready var new_memory_button: Button = $Panel/VBox/NewMemoryButton
@onready var restore_memory_button: Button = $Panel/VBox/RestoreMemoryButton
@onready var window_size_button: Button = $Panel/VBox/WindowSizeButton
@onready var quit_button: Button = $Panel/VBox/QuitButton

func _ready() -> void:
	new_memory_button.pressed.connect(request_new_memory)
	restore_memory_button.pressed.connect(request_restore_memory)
	window_size_button.pressed.connect(_on_window_size_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	_refresh_window_size_button()
	focus_default()

func focus_default() -> void:
	new_memory_button.grab_focus()

func request_new_memory() -> void:
	_play_audio("play_ui_confirm")
	new_memory_requested.emit()

func request_restore_memory() -> void:
	_play_audio("play_ui_confirm")
	restore_memory_requested.emit()

func _on_window_size_pressed() -> void:
	_play_audio("play_ui_confirm")
	DisplayOptions.cycle_window_size()
	_refresh_window_size_button()

func _on_quit_pressed() -> void:
	_play_audio("play_ui_cancel")
	get_tree().quit()

func _refresh_window_size_button() -> void:
	if DisplayOptions and DisplayOptions.has_method("get_window_size_label"):
		window_size_button.text = DisplayOptions.get_window_size_label()

func _play_audio(method_name: String) -> void:
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager and audio_manager.has_method(method_name):
		audio_manager.call(method_name)
