extends Area2D

const DIALOGUE_BOX_SCENE := preload("res://scenes/ui/DialogueBox.tscn")

var active_dialogue_box: CanvasLayer = null

func interact(player: Node = null) -> void:
	if active_dialogue_box and is_instance_valid(active_dialogue_box):
		active_dialogue_box.queue_free()
	active_dialogue_box = DIALOGUE_BOX_SCENE.instantiate()
	get_tree().current_scene.add_child(active_dialogue_box)
	if active_dialogue_box.has_method("start_dialogue"):
		active_dialogue_box.start_dialogue([
			{"speaker": "Mira", "text": "Welcome to Pixel Haven."},
			{"speaker": "Mira", "text": "This is only a test object for the scaffold."},
		])
	if active_dialogue_box.has_signal("dialogue_finished"):
		active_dialogue_box.dialogue_finished.connect(_on_dialogue_finished.bind(player), CONNECT_ONE_SHOT)
	if player and player.has_method("set_control_enabled"):
		player.set_control_enabled(false)

func _on_dialogue_finished(player: Node = null) -> void:
	if player and player.has_method("set_control_enabled"):
		player.set_control_enabled(true)