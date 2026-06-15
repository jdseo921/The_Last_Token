extends Area2D

func interact(player: Node = null) -> void:
	var current_scene := get_tree().current_scene
	if current_scene and current_scene.has_method("handle_interactable_interaction"):
		current_scene.handle_interactable_interaction(self, player)
