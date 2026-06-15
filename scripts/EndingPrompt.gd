extends Control

@onready var continue_button: Button = $Panel/VBox/ContinueButton

func _ready() -> void:
	continue_button.pressed.connect(_on_continue_pressed)

func _on_continue_pressed() -> void:
	GameState.ending_seen = true
	GameState.unlock_post_reveal_roam()
	SceneChanger.change_scene("res://scenes/arcade/ArcadeHub.tscn")
