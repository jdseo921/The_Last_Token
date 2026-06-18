extends Area2D

@export var interactable_kind: String = "npc"
@export var label_text: String = ""
@export var sprite_texture_path: String = ""
@export var idle_animation_name: String = "idle"
@export var show_label := true
@export var use_placeholder_visual := true
@export var idle_bob_enabled := false
@export var flicker_enabled := false

var broken_interaction_count := 0
var base_visual_position := Vector2.ZERO
var idle_time := 0.0

@onready var visual_root: Node2D = $VisualRoot
@onready var sprite: Sprite2D = $VisualRoot/Sprite
@onready var placeholder_visual: Polygon2D = $VisualRoot/PlaceholderVisual
@onready var label: Label = $Label

func _ready() -> void:
	base_visual_position = visual_root.position
	label.text = label_text
	_apply_placeholder_style()
	_apply_sprite_texture()
	_refresh_visual_visibility()

func _process(delta: float) -> void:
	if not idle_bob_enabled and not flicker_enabled:
		return
	idle_time += delta
	if idle_bob_enabled:
		visual_root.position = base_visual_position + Vector2(0, sin(idle_time * 2.2) * 1.5)
	if flicker_enabled:
		var flicker_alpha := 0.78 + (sin(idle_time * 11.0) + 1.0) * 0.11
		visual_root.modulate.a = flicker_alpha

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
			placeholder_visual.color = Color(0.82, 0.42, 0.58, 1)
		"gus":
			placeholder_visual.color = Color(0.42, 0.62, 0.48, 1)
		"vendo":
			placeholder_visual.color = Color(0.26, 0.72, 0.5, 1)
		"mr_byte":
			placeholder_visual.color = Color(0.32, 0.58, 0.92, 1)
		"cabinet07":
			placeholder_visual.color = Color(0.24, 0.32, 0.86, 1)
		"staff_door":
			placeholder_visual.color = Color(0.72, 0.18, 0.22, 1)
		"owner_portrait":
			placeholder_visual.color = Color(0.72, 0.56, 0.24, 1)
		"broken_cabinet":
			placeholder_visual.color = Color(0.36, 0.36, 0.42, 1)
		"employee_04_file":
			placeholder_visual.color = Color(0.62, 0.48, 0.28, 1)
		"reveal_terminal":
			placeholder_visual.color = Color(0.18, 0.74, 0.66, 1)
		_:
			placeholder_visual.color = Color(0.18, 0.32, 0.42, 1)

func _apply_sprite_texture() -> void:
	sprite.visible = false
	sprite.texture = null
	if sprite_texture_path.is_empty():
		return
	if not ResourceLoader.exists(sprite_texture_path):
		return
	var resource := load(sprite_texture_path)
	if resource is Texture2D:
		sprite.texture = resource
		sprite.visible = true

func _refresh_visual_visibility() -> void:
	label.visible = show_label
	placeholder_visual.visible = use_placeholder_visual or sprite.texture == null
