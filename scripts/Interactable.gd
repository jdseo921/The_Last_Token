extends Area2D

func interact(player: Node = null) -> void:
	var handler := _find_interaction_handler()
	if handler == null:
		return
	if handler.has_method("handle_hub_interaction"):
		handler.handle_hub_interaction(self, player)
		return
	handler.handle_interactable_interaction(self, player)

func _find_interaction_handler() -> Node:
	var cursor: Node = self
	while cursor:
		if cursor.has_method("handle_hub_interaction") or cursor.has_method("handle_interactable_interaction"):
			return cursor
		cursor = cursor.get_parent()
	var scene := get_tree().current_scene
	if scene and (scene.has_method("handle_hub_interaction") or scene.has_method("handle_interactable_interaction")):
		return scene
	return null
