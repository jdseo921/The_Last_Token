extends Control

@onready var continue_button: Button = $Panel/VBox/ContinueButton

func _ready() -> void:
	continue_button.pressed.connect(_on_continue_pressed)

func _on_continue_pressed() -> void:
	_play_audio("play_save")
	GameState.ending_seen = true
	GameState.unlock_post_reveal_roam()
	SceneChanger.go_to_arcade_hub()

func _play_audio(method_name: String) -> void:
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager and audio_manager.has_method(method_name):
		audio_manager.call(method_name)
