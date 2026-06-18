extends Node2D

signal prop_animation_finished(prop_id: String)

@export var prop_id: String = ""
@export var display_name: String = "Prop"
@export var prop_type: String = "generic"
@export var texture_path: String = ""
@export var use_placeholder_visual: bool = true

@onready var visual_root: Node2D = $VisualRoot
@onready var placeholder_visual: Polygon2D = $VisualRoot/PlaceholderVisual
@onready var sprite: Sprite2D = $VisualRoot/Sprite
@onready var name_label: Label = $VisualRoot/NameLabel

var base_position := Vector2.ZERO
var base_scale := Vector2.ONE
var base_modulate := Color.WHITE
var action_tween: Tween = null

func _ready() -> void:
	base_position = visual_root.position
	base_scale = visual_root.scale
	base_modulate = visual_root.modulate
	_refresh_visuals()

func setup_prop(data: Dictionary) -> void:
	prop_id = str(data.get("prop_id", prop_id))
	display_name = str(data.get("display_name", display_name))
	prop_type = str(data.get("prop_type", prop_type))
	texture_path = str(data.get("texture_path", texture_path))
	use_placeholder_visual = bool(data.get("use_placeholder_visual", use_placeholder_visual))
	_refresh_visuals()

func set_active(active: bool) -> void:
	visual_root.modulate = base_modulate if active else Color(base_modulate.r, base_modulate.g, base_modulate.b, 0.42)

func play_flash() -> void:
	_start_action()
	action_tween = create_tween()
	action_tween.tween_property(visual_root, "modulate", Color(1.0, 1.0, 0.65, 1.0), 0.08)
	action_tween.tween_property(visual_root, "modulate", base_modulate, 0.14)
	action_tween.finished.connect(_on_animation_finished, CONNECT_ONE_SHOT)

func play_shake() -> void:
	_start_action()
	action_tween = create_tween()
	action_tween.tween_property(visual_root, "position", base_position + Vector2(-3, 0), 0.04)
	action_tween.tween_property(visual_root, "position", base_position + Vector2(3, 0), 0.04)
	action_tween.tween_property(visual_root, "position", base_position, 0.05)
	action_tween.finished.connect(_on_animation_finished, CONNECT_ONE_SHOT)

func play_crumble() -> void:
	_start_action()
	action_tween = create_tween()
	action_tween.tween_property(visual_root, "scale", base_scale * 0.82, 0.08)
	action_tween.tween_property(visual_root, "modulate", Color(base_modulate.r, base_modulate.g, base_modulate.b, 0.25), 0.12)
	action_tween.tween_property(visual_root, "scale", base_scale, 0.08)
	action_tween.tween_property(visual_root, "modulate", base_modulate, 0.08)
	action_tween.finished.connect(_on_animation_finished, CONNECT_ONE_SHOT)

func reset_visual() -> void:
	_stop_action_tween()
	_restore_visual()
	prop_animation_finished.emit(prop_id)

func _refresh_visuals() -> void:
	name_label.text = display_name
	_apply_texture()
	placeholder_visual.visible = use_placeholder_visual or sprite.texture == null

func _apply_texture() -> void:
	sprite.visible = false
	sprite.texture = null
	if texture_path.is_empty():
		return
	if not ResourceLoader.exists(texture_path):
		return
	var resource := load(texture_path)
	if resource is Texture2D:
		sprite.texture = resource
		sprite.visible = true

func _start_action() -> void:
	_stop_action_tween()
	_restore_visual()

func _on_animation_finished() -> void:
	_restore_visual()
	prop_animation_finished.emit(prop_id)

func _restore_visual() -> void:
	visual_root.position = base_position
	visual_root.scale = base_scale
	visual_root.modulate = base_modulate

func _stop_action_tween() -> void:
	if action_tween and action_tween.is_valid():
		action_tween.kill()
	action_tween = null
