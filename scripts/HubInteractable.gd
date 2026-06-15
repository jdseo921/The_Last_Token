extends Area2D

@export var interactable_kind: String = "npc"
@export var label_text: String = ""

var broken_interaction_count := 0

@onready var label: Label = $Label

func _ready() -> void:
	label.text = label_text

func interact(player: Node = null) -> void:
	var hub = get_tree().current_scene
	if hub and hub.has_method("handle_hub_interaction"):
		hub.handle_hub_interaction(self, player)
		return
	if hub and hub.has_method("handle_interactable_interaction"):
		hub.handle_interactable_interaction(self, player)
