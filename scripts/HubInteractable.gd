extends Area2D

const DEBUG := preload("res://scripts/Debug.gd")

@export var interactable_kind: String = "npc"
@export var label_text: String = ""
@export var sprite_texture_path: String = ""
@export var idle_sheet_path: String = ""
@export var facing_sheet_path: String = ""
@export var idle_animation_enabled := true
@export var idle_animation_name: String = "idle"
@export var idle_frame_count: int = 2
@export var idle_frame_duration: float = 0.45
@export var visual_scale: float = 1.0
@export var show_label := true
@export var label_font_size := 14
@export var label_offset := Vector2.ZERO
@export var use_placeholder_visual := true
@export var idle_bob_enabled := false
@export var flicker_enabled := false
@export var interact_extents := Vector2(64, 64)

var broken_interaction_count := 0
var base_visual_position := Vector2.ZERO
var idle_time := 0.0

@onready var visual_root: Node2D = $VisualRoot
@onready var sprite: Sprite2D = $VisualRoot/Sprite
@onready var animated_sprite: AnimatedSprite2D = $VisualRoot/AnimatedSprite
@onready var placeholder_visual: Polygon2D = $VisualRoot/PlaceholderVisual
@onready var label: Label = $Label

func _ready() -> void:
	if interact_extents != Vector2(64, 64):
		# Fit the interaction area to the machine footprint so the player can
		# interact from any adjacent side instead of a single edge hotspot.
		var fitted := RectangleShape2D.new()
		fitted.size = interact_extents
		$CollisionShape2D.shape = fitted
	visual_root.scale = Vector2(visual_scale, visual_scale)
	base_visual_position = visual_root.position
	label.text = label_text
	label.add_theme_font_size_override("font_size", label_font_size)
	label.position += label_offset
	_apply_placeholder_style()
	_apply_optional_sprite_art()
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
	if player is Node2D:
		face_target((player as Node2D).global_position)
	var hub := _find_interaction_handler()
	DEBUG.info(self, "interaction", "interactable_used", {
		"kind": interactable_kind,
		"label": label_text,
		"node": str(get_path()),
		"handler": str(hub.get_path()) if hub != null else "<none>",
		"player": str(player.get_path()) if player != null else "<none>",
	})
	if hub and hub.has_method("handle_hub_interaction"):
		hub.handle_hub_interaction(self, player)
		return
	if hub and hub.has_method("handle_interactable_interaction"):
		hub.handle_interactable_interaction(self, player)
		return
	DEBUG.warning(self, "interaction", "interactable_has_no_handler", {
		"kind": interactable_kind,
		"node": str(get_path()),
	})

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
		"roxy":
			placeholder_visual.color = Color(0.68, 0.24, 0.5, 1)
		"pip":
			placeholder_visual.color = Color(0.78, 0.64, 0.26, 1)
		"mr_byte":
			placeholder_visual.color = Color(0.32, 0.58, 0.92, 1)
		"cabinet07":
			placeholder_visual.color = Color(0.24, 0.32, 0.86, 1)
		"truth_filter":
			placeholder_visual.color = Color(0.38, 0.16, 0.58, 1)
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

func _apply_idle_sheet() -> void:
	animated_sprite.visible = false
	animated_sprite.sprite_frames = null
	if idle_sheet_path.is_empty():
		return
	if not ResourceLoader.exists(idle_sheet_path):
		return
	var resource := load(idle_sheet_path)
	if not resource is Texture2D:
		return
	var texture := resource as Texture2D
	var frame_total := maxi(idle_frame_count, 1)
	var frame_width := maxi(int(texture.get_width() / frame_total), 1)
	var frame_height := maxi(texture.get_height(), 1)
	if not idle_animation_enabled:
		var atlas := AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = Rect2(0, 0, frame_width, frame_height)
		sprite.texture = atlas
		sprite.visible = true
		return
	var frames := SpriteFrames.new()
	frames.add_animation(idle_animation_name)
	frames.set_animation_loop(idle_animation_name, true)
	frames.set_animation_speed(idle_animation_name, 1.0 / maxf(idle_frame_duration, 0.05))
	for index in range(frame_total):
		var atlas := AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = Rect2(index * frame_width, 0, frame_width, frame_height)
		frames.add_frame(idle_animation_name, atlas)
	animated_sprite.sprite_frames = frames
	animated_sprite.animation = idle_animation_name
	animated_sprite.visible = true
	animated_sprite.play(idle_animation_name)

func _apply_optional_sprite_art() -> void:
	_apply_idle_sheet()
	if animated_sprite.visible:
		sprite.visible = false
		sprite.texture = null
		return
	if sprite.visible:
		return
	_apply_sprite_texture()

func _refresh_visual_visibility() -> void:
	var has_sprite_art := sprite.texture != null or animated_sprite.visible
	label.visible = show_label
	label.modulate.a = 0.72 if has_sprite_art else 1.0
	placeholder_visual.visible = use_placeholder_visual and not has_sprite_art

func face_target(target_position: Vector2) -> void:
	if facing_sheet_path.is_empty() or not ResourceLoader.exists(facing_sheet_path):
		return
	var resource := load(facing_sheet_path)
	if not resource is Texture2D:
		return
	var texture := resource as Texture2D
	var frame_width := maxi(int(texture.get_width() / 4), 1)
	var frame_height := maxi(texture.get_height(), 1)
	var direction_index := _get_diagonal_facing_index(target_position - global_position)
	var atlas := AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = Rect2(direction_index * frame_width, 0, frame_width, frame_height)
	animated_sprite.visible = false
	animated_sprite.stop()
	sprite.texture = atlas
	sprite.visible = true
	_refresh_visual_visibility()

func _get_diagonal_facing_index(direction: Vector2) -> int:
	if direction.y < 0.0:
		return 0 if direction.x >= 0.0 else 1
	return 2 if direction.x >= 0.0 else 3
