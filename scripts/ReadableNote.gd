extends Area2D

@export var interactable_kind: String = "readable_note"
@export var label_text: String = "NOTE"

@onready var label: Label = $Label

func _ready() -> void:
	label.text = label_text

func interact(player: Node = null) -> void:
	var handler := _find_interaction_handler()
	if handler == null:
		return
	if handler.has_method("handle_hub_interaction"):
		handler.handle_hub_interaction(self, player)
		return
	if handler.has_method("handle_interactable_interaction"):
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
