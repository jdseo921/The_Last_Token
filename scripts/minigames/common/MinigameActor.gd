extends Node2D

signal action_finished(actor_id: String, action_name: String)

const VALID_ACTOR_TYPES := [
	"player",
	"human_npc",
	"machine",
	"terminal",
	"ghost",
	"object_npc",
]
const VALID_SIDES := [
	"left",
	"right",
	"center",
]
const DEFAULT_PLACEHOLDER_COLORS := {
	"player": Color(0.45, 0.82, 0.95, 1.0),
	"human_npc": Color(0.82, 0.58, 0.72, 1.0),
	"machine": Color(0.26, 0.58, 0.95, 1.0),
	"terminal": Color(0.18, 0.78, 0.66, 1.0),
	"ghost": Color(0.72, 0.82, 0.95, 0.78),
	"object_npc": Color(0.72, 0.64, 0.42, 1.0),
}

@export var actor_id: String = ""
@export var display_name: String = "Actor"
@export var actor_type: String = "object_npc"
@export var side: String = "center"
@export var sprite_texture_path: String = ""
@export var show_name_label: bool = true
@export var use_placeholder_visual: bool = true
@export var idle_bob_enabled: bool = true
@export var idle_flicker_enabled: bool = false

@onready var visual_root: Node2D = $VisualRoot
@onready var placeholder_body: Polygon2D = $VisualRoot/PlaceholderBody
@onready var sprite: Sprite2D = $VisualRoot/Sprite
@onready var name_label: Label = $VisualRoot/NameLabel
@onready var effect_root: Node2D = $EffectRoot

var base_visual_position := Vector2.ZERO
var base_modulate := Color.WHITE
var base_scale := Vector2.ONE
var idle_bob_tween: Tween = null
var idle_flicker_tween: Tween = null
var action_tween: Tween = null

func _ready() -> void:
	base_visual_position = visual_root.position
	base_modulate = visual_root.modulate
	base_scale = visual_root.scale
	_normalize_exports()
	_refresh_visuals()
	play_idle()

func setup_actor(data: Dictionary) -> void:
	actor_id = str(data.get("actor_id", actor_id))
	display_name = str(data.get("display_name", display_name))
	actor_type = str(data.get("actor_type", actor_type))
	side = str(data.get("side", side))
	sprite_texture_path = str(data.get("sprite_texture_path", sprite_texture_path))
	show_name_label = bool(data.get("show_name_label", show_name_label))
	use_placeholder_visual = bool(data.get("use_placeholder_visual", use_placeholder_visual))
	idle_bob_enabled = bool(data.get("idle_bob_enabled", idle_bob_enabled))
	idle_flicker_enabled = bool(data.get("idle_flicker_enabled", idle_flicker_enabled))
	_normalize_exports()
	_refresh_visuals()
	play_idle()

func play_idle() -> void:
	_stop_idle_tween()
	_stop_action_tween()
	_restore_pose()
	if actor_type == "ghost":
		visual_root.modulate = Color(base_modulate.r, base_modulate.g, base_modulate.b, 0.72)
	if not idle_bob_enabled and not idle_flicker_enabled:
		action_finished.emit(actor_id, "idle")
		return
	if idle_bob_enabled:
		idle_bob_tween = create_tween()
		idle_bob_tween.set_loops()
		idle_bob_tween.tween_property(visual_root, "position", base_visual_position + Vector2(0, -2), 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		idle_bob_tween.tween_property(visual_root, "position", base_visual_position + Vector2(0, 2), 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	if idle_flicker_enabled:
		idle_flicker_tween = create_tween()
		idle_flicker_tween.set_loops()
		idle_flicker_tween.tween_property(visual_root, "modulate:a", 0.72, 0.16)
		idle_flicker_tween.tween_property(visual_root, "modulate:a", base_modulate.a, 0.28)
	action_finished.emit(actor_id, "idle")

func play_reach(target_position: Vector2) -> void:
	if actor_type == "machine" or actor_type == "terminal":
		play_machine_action(target_position)
		return
	if actor_type == "object_npc":
		_start_object_action("reach")
		return
	var reach_offset := _get_target_offset(target_position, 14.0)
	if actor_type == "ghost":
		_start_ghost_action("reach", reach_offset)
		return
	_start_motion_action("reach", reach_offset, 0.16, 0.18)

func play_carry(target_position: Vector2) -> void:
	if actor_type == "machine" or actor_type == "terminal":
		play_machine_action(target_position)
		return
	if actor_type == "object_npc":
		_start_object_action("carry")
		return
	var carry_offset := _get_target_offset(target_position, 22.0)
	if actor_type == "ghost":
		_start_ghost_action("carry", carry_offset)
		return
	_start_motion_action("carry", carry_offset, 0.22, 0.24)

func play_remove_action(target_position: Vector2) -> void:
	if actor_type == "machine" or actor_type == "terminal":
		play_machine_action(target_position)
		return
	if actor_type == "object_npc":
		_start_object_action("remove_action")
		return
	var remove_offset := _get_target_offset(target_position, 18.0)
	if actor_type == "ghost":
		_start_ghost_action("remove_action", remove_offset)
		return
	_start_action("remove_action")
	action_tween = create_tween()
	action_tween.tween_property(visual_root, "position", base_visual_position + remove_offset, 0.16)
	action_tween.tween_property(visual_root, "scale", base_scale * 1.08, 0.08)
	action_tween.tween_property(visual_root, "scale", base_scale, 0.08)
	action_tween.tween_property(visual_root, "position", base_visual_position, 0.16)
	action_tween.finished.connect(_on_action_tween_finished.bind("remove_action"), CONNECT_ONE_SHOT)

func play_machine_action(target_position: Vector2) -> void:
	var target_offset := _get_target_offset(target_position, 4.0)
	_start_action("machine_action")
	action_tween = create_tween()
	if actor_type == "terminal":
		action_tween.tween_property(visual_root, "modulate", Color(0.65, 1.0, 0.82, 1.0), 0.08)
		action_tween.tween_property(visual_root, "scale", base_scale * 1.06, 0.08)
		action_tween.tween_property(visual_root, "modulate", base_modulate, 0.12)
		action_tween.tween_property(visual_root, "scale", base_scale, 0.12)
	else:
		action_tween.tween_property(visual_root, "position", base_visual_position + target_offset, 0.05)
		action_tween.tween_property(visual_root, "modulate", Color(0.65, 0.95, 1.0, 0.45), 0.07)
		action_tween.tween_property(visual_root, "modulate", Color(1.0, 0.65, 0.85, 1.0), 0.07)
		action_tween.tween_property(visual_root, "scale", base_scale * 1.08, 0.08)
		action_tween.tween_property(visual_root, "modulate", base_modulate, 0.12)
		action_tween.tween_property(visual_root, "scale", base_scale, 0.08)
		action_tween.tween_property(visual_root, "position", base_visual_position, 0.08)
	action_tween.finished.connect(_on_action_tween_finished.bind("machine_action"), CONNECT_ONE_SHOT)

func play_success() -> void:
	_start_action("success")
	action_tween = create_tween()
	match actor_type:
		"machine", "terminal":
			action_tween.tween_property(visual_root, "modulate", Color(0.72, 1.0, 0.95, 1.0), 0.08)
			action_tween.tween_property(visual_root, "scale", base_scale * 1.08, 0.1)
		"object_npc":
			action_tween.tween_property(visual_root, "position", base_visual_position + Vector2(0, -4), 0.1)
			action_tween.tween_property(visual_root, "position", base_visual_position, 0.12)
		_:
			action_tween.tween_property(visual_root, "scale", base_scale * 1.12, 0.12)
			action_tween.tween_property(visual_root, "modulate", Color(0.78, 1.0, 0.78, 1.0), 0.12)
	action_tween.tween_property(visual_root, "scale", base_scale, 0.16)
	action_tween.tween_property(visual_root, "modulate", base_modulate, 0.16)
	action_tween.finished.connect(_on_action_tween_finished.bind("success"), CONNECT_ONE_SHOT)

func play_failure() -> void:
	_start_action("failure")
	action_tween = create_tween()
	action_tween.tween_property(visual_root, "position", base_visual_position + Vector2(-3, 0), 0.05)
	action_tween.tween_property(visual_root, "position", base_visual_position + Vector2(3, 0), 0.05)
	action_tween.tween_property(visual_root, "modulate", Color(0.75, 0.75, 0.75, 0.62), 0.12)
	action_tween.tween_property(visual_root, "position", base_visual_position, 0.05)
	action_tween.tween_property(visual_root, "modulate", base_modulate, 0.18)
	action_tween.finished.connect(_on_action_tween_finished.bind("failure"), CONNECT_ONE_SHOT)

func reset_pose() -> void:
	_stop_idle_tween()
	_stop_action_tween()
	_restore_pose()
	action_finished.emit(actor_id, "reset_pose")

func get_removal_style_for_actor() -> String:
	match actor_type:
		"player", "human_npc":
			return "carry"
		"ghost":
			return "vanish"
		"machine", "terminal":
			return "digital_crumble"
		"object_npc":
			return "shake"
		_:
			return "vanish"

func _start_motion_action(action_name: String, offset: Vector2, out_time: float, back_time: float) -> void:
	_start_action(action_name)
	action_tween = create_tween()
	action_tween.tween_property(visual_root, "position", base_visual_position + offset, out_time)
	action_tween.tween_property(visual_root, "position", base_visual_position, back_time)
	action_tween.finished.connect(_on_action_tween_finished.bind(action_name), CONNECT_ONE_SHOT)

func _start_ghost_action(action_name: String, offset: Vector2) -> void:
	_start_action(action_name)
	action_tween = create_tween()
	action_tween.tween_property(visual_root, "position", base_visual_position + offset.limit_length(12.0), 0.14)
	action_tween.tween_property(visual_root, "modulate", Color(base_modulate.r, base_modulate.g, base_modulate.b, 0.35), 0.08)
	action_tween.tween_property(visual_root, "modulate", Color(base_modulate.r, base_modulate.g, base_modulate.b, 0.78), 0.12)
	action_tween.tween_property(visual_root, "position", base_visual_position, 0.16)
	action_tween.finished.connect(_on_action_tween_finished.bind(action_name), CONNECT_ONE_SHOT)

func _start_object_action(action_name: String) -> void:
	_start_action(action_name)
	action_tween = create_tween()
	action_tween.tween_property(visual_root, "scale", base_scale * 1.08, 0.08)
	action_tween.tween_property(visual_root, "position", base_visual_position + Vector2(3, 0), 0.06)
	action_tween.tween_property(visual_root, "position", base_visual_position + Vector2(-3, 0), 0.06)
	action_tween.tween_property(visual_root, "scale", base_scale, 0.1)
	action_tween.tween_property(visual_root, "position", base_visual_position, 0.08)
	action_tween.finished.connect(_on_action_tween_finished.bind(action_name), CONNECT_ONE_SHOT)

func _start_action(_action_name: String) -> void:
	_stop_idle_tween()
	_stop_action_tween()
	_restore_pose()

func _on_action_tween_finished(action_name: String) -> void:
	_restore_pose()
	action_finished.emit(actor_id, action_name)
	play_idle()

func _get_target_offset(target_position: Vector2, max_distance: float) -> Vector2:
	var target_local := to_local(target_position)
	var direction := target_local - visual_root.position
	if direction.length() <= 0.01:
		return Vector2.ZERO
	return direction.normalized() * max_distance

func _refresh_visuals() -> void:
	name_label.text = display_name
	name_label.visible = show_name_label
	placeholder_body.color = Color(DEFAULT_PLACEHOLDER_COLORS.get(actor_type, DEFAULT_PLACEHOLDER_COLORS["object_npc"]))
	_apply_sprite_texture()
	placeholder_body.visible = use_placeholder_visual or sprite.texture == null

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

func _normalize_exports() -> void:
	if actor_type not in VALID_ACTOR_TYPES:
		actor_type = "object_npc"
	if side not in VALID_SIDES:
		side = "center"

func _restore_pose() -> void:
	visual_root.position = base_visual_position
	visual_root.modulate = base_modulate
	visual_root.scale = base_scale

func _stop_idle_tween() -> void:
	if idle_bob_tween and idle_bob_tween.is_valid():
		idle_bob_tween.kill()
	if idle_flicker_tween and idle_flicker_tween.is_valid():
		idle_flicker_tween.kill()
	idle_bob_tween = null
	idle_flicker_tween = null

func _stop_action_tween() -> void:
	if action_tween and action_tween.is_valid():
		action_tween.kill()
	action_tween = null
