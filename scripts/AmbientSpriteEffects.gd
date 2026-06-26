extends RefCounted
class_name AmbientSpriteEffects

const PROP_SCENE := preload("res://scenes/common/AnimatedAmbientProp.tscn")

const EFFECT_DIR := "res://assets/art/effects/ambient/"
const STATIC_SPARK := EFFECT_DIR + "static_spark_sheet.png"
const BLINK_DOT := EFFECT_DIR + "blink_dot_sheet.png"
const SCANLINE_BAR := EFFECT_DIR + "scanline_bar_sheet.png"
const WARNING_LIGHT := EFFECT_DIR + "warning_light_sheet.png"
const SODA_BUBBLE := EFFECT_DIR + "soda_bubble_sheet.png"
const PRIZE_TWINKLE := EFFECT_DIR + "prize_twinkle_sheet.png"
const MEMORY_WISP := EFFECT_DIR + "memory_wisp_sheet.png"
const NEON_ARROW := EFFECT_DIR + "neon_arrow_sheet.png"
const TICKET_GLINT := EFFECT_DIR + "ticket_glint_sheet.png"
const STAFF_LOCK_BLINK := EFFECT_DIR + "staff_lock_blink_sheet.png"

static func create_layer(parent: Node, before_node: Node, entries: Array[Dictionary], layer_name := "AmbientSpriteLayer") -> Node2D:
	var layer := Node2D.new()
	layer.name = layer_name
	if parent == null:
		return layer
	parent.add_child(layer)
	if before_node != null and before_node.get_parent() == parent:
		parent.move_child(layer, before_node.get_index())
	add(layer, entries)
	return layer

static func add(parent: Node, entries: Array[Dictionary]) -> void:
	if parent == null:
		return
	for data in entries:
		var prop := PROP_SCENE.instantiate()
		prop.name = str(data.get("name", "AmbientSprite"))
		prop.position = data.get("position", Vector2.ZERO)
		prop.rotation = float(data.get("rotation", 0.0))
		prop.scale = data.get("scale", Vector2.ONE)
		prop.z_index = int(data.get("z_index", 0))
		prop.set("effect_type", str(data.get("effect_type", "flicker")))
		prop.set("intensity", float(data.get("intensity", 0.08)))
		prop.set("speed", float(data.get("speed", 0.8)))
		prop.set("random_offset", bool(data.get("random_offset", true)))
		prop.set("only_when_memory_signal_at_least", int(data.get("only_when_memory_signal_at_least", -1)))
		prop.set("active_flag_optional", str(data.get("active_flag_optional", "")))
		prop.set("sprite_sheet_path", str(data.get("sprite_sheet_path", "")))
		prop.set("sprite_frame_count", int(data.get("sprite_frame_count", 4)))
		prop.set("sprite_frame_size", data.get("sprite_frame_size", Vector2i(16, 16)))
		prop.set("sprite_fps", float(data.get("sprite_fps", 6.0)))
		prop.set("sprite_alpha", float(data.get("sprite_alpha", 0.82)))
		prop.set("sprite_modulate", data.get("sprite_modulate", Color.WHITE))
		parent.add_child(prop)
