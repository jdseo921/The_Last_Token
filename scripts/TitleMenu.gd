extends Control

signal new_memory_requested
signal restore_memory_requested

@onready var new_memory_button: Button = $Panel/VBox/NewMemoryButton
@onready var restore_memory_button: Button = $Panel/VBox/RestoreMemoryButton
@onready var quit_button: Button = $Panel/VBox/QuitButton

func _ready() -> void:
	new_memory_button.pressed.connect(request_new_memory)
	restore_memory_button.pressed.connect(request_restore_memory)
	quit_button.pressed.connect(_on_quit_pressed)

func request_new_memory() -> void:
	new_memory_requested.emit()

func request_restore_memory() -> void:
	restore_memory_requested.emit()

func _on_quit_pressed() -> void:
	get_tree().quit()
