extends RefCounted
class_name ArcadeJuice

const PULSE_CYAN := Color(0.52, 0.96, 1.0, 1.0)
const PULSE_GREEN := Color(0.64, 1.0, 0.76, 1.0)
const PULSE_RED := Color(1.0, 0.28, 0.42, 1.0)
const FLASH_CYAN := Color(0.38, 0.95, 1.0, 1.0)
const FLASH_RED := Color(1.0, 0.12, 0.28, 1.0)

static func pulse_control(owner: Node, item: CanvasItem, accent: Color = PULSE_CYAN, duration: float = 0.12) -> void:
	if owner == null or item == null:
		return
	var original_modulate := item.modulate
	item.modulate = accent
	var tween := owner.create_tween()
	tween.tween_property(item, "modulate", original_modulate, duration)

static func flash_overlay(owner: Node, overlay: CanvasItem, color: Color = FLASH_CYAN, peak_alpha: float = 0.34) -> void:
	if owner == null or overlay == null:
		return
	overlay.visible = true
	overlay.modulate = Color(color.r, color.g, color.b, 0.0)
	var tween := owner.create_tween()
	tween.tween_property(overlay, "modulate:a", peak_alpha, 0.04)
	tween.tween_property(overlay, "modulate:a", 0.0, 0.12)

static func shake_control(owner: Node, item: Control, pixels: int = 4) -> void:
	if owner == null or item == null:
		return
	var start_position := item.position
	var tween := owner.create_tween()
	tween.tween_property(item, "position", start_position + Vector2(-pixels, 0), 0.035)
	tween.tween_property(item, "position", start_position + Vector2(pixels, 0), 0.035)
	tween.tween_property(item, "position", start_position, 0.045)

static func _hide_canvas_item(item: Object) -> void:
	if item != null and is_instance_valid(item) and item is CanvasItem:
		(item as CanvasItem).visible = false
