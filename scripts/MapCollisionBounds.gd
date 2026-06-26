extends Node2D

@export var rectangles: Array[Vector4] = []
@export var visual_node_paths: Array[NodePath] = []
@export var visible_visual_node_paths: Array[NodePath] = []

func _ready() -> void:
	call_deferred("_rebuild_collision")

func _rebuild_collision() -> void:
	for child in get_children():
		child.queue_free()
	for index in range(rectangles.size()):
		var rect := rectangles[index]
		_add_rect_collision("CollisionBox%02d" % index, Rect2(Vector2(rect.x, rect.y), Vector2(rect.z, rect.w)))
	for path in visual_node_paths:
		_add_visual_collision(path, false)
	for path in visible_visual_node_paths:
		_add_visual_collision(path, true)

func _add_rect_collision(node_name: String, rect: Rect2) -> void:
	if rect.size.x <= 0.0 or rect.size.y <= 0.0:
		return
	var points := PackedVector2Array([
		rect.position,
		rect.position + Vector2(rect.size.x, 0.0),
		rect.position + rect.size,
		rect.position + Vector2(0.0, rect.size.y),
	])
	_add_polygon_collision(node_name, points)

func _add_visual_collision(path: NodePath, require_visible: bool) -> void:
	var source := get_node_or_null(path)
	if source == null:
		push_warning("MapCollisionBounds missing visual source: %s" % str(path))
		return
	if require_visible and source is CanvasItem and not (source as CanvasItem).is_visible_in_tree():
		return
	if source is Polygon2D:
		_add_polygon_source_collision(source as Polygon2D)
		return
	if source is Sprite2D:
		_add_sprite_source_collision(source as Sprite2D)
		return
	if source is AnimatedSprite2D:
		_add_animated_sprite_source_collision(source as AnimatedSprite2D)
		return
	push_warning("MapCollisionBounds unsupported visual source: %s" % str(path))

func _add_polygon_source_collision(source: Polygon2D) -> void:
	if source.polygon.size() < 3:
		return
	var points := PackedVector2Array()
	for point in source.polygon:
		points.append(to_local(source.to_global(point)))
	_add_polygon_collision("%sCollision" % source.name, points)

func _add_sprite_source_collision(source: Sprite2D) -> void:
	if source.texture == null:
		return
	var rect := source.get_rect()
	_add_local_rect_source_collision(source, rect)

func _add_animated_sprite_source_collision(source: AnimatedSprite2D) -> void:
	var frames := source.sprite_frames
	if frames == null:
		return
	var animation_name := source.animation
	if animation_name.is_empty():
		var names := frames.get_animation_names()
		if names.is_empty():
			return
		animation_name = str(names[0])
	if frames.get_frame_count(animation_name) <= 0:
		return
	var texture := frames.get_frame_texture(animation_name, clampi(source.frame, 0, frames.get_frame_count(animation_name) - 1))
	if texture == null:
		return
	var size := Vector2(texture.get_width(), texture.get_height())
	var top_left := source.offset
	if source.centered:
		top_left -= size * 0.5
	_add_local_rect_source_collision(source, Rect2(top_left, size))

func _add_local_rect_source_collision(source: Node2D, rect: Rect2) -> void:
	if rect.size.x <= 0.0 or rect.size.y <= 0.0:
		return
	var local_points := PackedVector2Array([
		rect.position,
		rect.position + Vector2(rect.size.x, 0.0),
		rect.position + rect.size,
		rect.position + Vector2(0.0, rect.size.y),
	])
	var points := PackedVector2Array()
	for point in local_points:
		points.append(to_local(source.to_global(point)))
	_add_polygon_collision("%sCollision" % source.name, points)

func _add_polygon_collision(node_name: String, points: PackedVector2Array) -> void:
	if points.size() < 3:
		return
	var body := StaticBody2D.new()
	body.name = node_name
	add_child(body)

	var collision := CollisionPolygon2D.new()
	collision.name = "Shape"
	collision.polygon = points
	body.add_child(collision)
