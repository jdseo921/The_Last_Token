extends Area2D

@export var interactable_kind: String = "npc"
@export var label_text: String = ""

var broken_interaction_count := 0

@onready var visual: Polygon2D = $Visual
@onready var label: Label = $Label

func _ready() -> void:
	label.text = label_text
	_apply_placeholder_style()

func interact(player: Node = null) -> void:
	var hub := _find_interaction_handler()
	if hub and hub.has_method("handle_hub_interaction"):
		hub.handle_hub_interaction(self, player)
		return
	if hub and hub.has_method("handle_interactable_interaction"):
		hub.handle_interactable_interaction(self, player)

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

func _apply_placeholder_style() -> void:
	match interactable_kind:
		"mira":
			visual.color = Color(0.82, 0.42, 0.58, 1)
		"gus":
			visual.color = Color(0.42, 0.62, 0.48, 1)
		"vendo":
			visual.color = Color(0.26, 0.72, 0.5, 1)
		"mr_byte":
			visual.color = Color(0.32, 0.58, 0.92, 1)
		"cabinet07":
			visual.color = Color(0.24, 0.32, 0.86, 1)
		"staff_door":
			visual.color = Color(0.72, 0.18, 0.22, 1)
		"owner_portrait":
			visual.color = Color(0.72, 0.56, 0.24, 1)
		"broken_cabinet":
			visual.color = Color(0.36, 0.36, 0.42, 1)
		"employee_04_file":
			visual.color = Color(0.62, 0.48, 0.28, 1)
		"reveal_terminal":
			visual.color = Color(0.18, 0.74, 0.66, 1)
		_:
			visual.color = Color(0.18, 0.32, 0.42, 1)
