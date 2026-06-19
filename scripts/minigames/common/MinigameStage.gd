extends Control

signal stage_action_finished(action_id: String)
signal stage_ready

const MINIGAME_ACTOR_SCENE := preload("res://scenes/minigames/common/MinigameActor.tscn")

@export var background_texture_path: String = ""
@export var left_actor_position := Vector2(120, 250)
@export var right_actor_position := Vector2(520, 250)
@export var center_prop_position := Vector2(320, 240)

@onready var background_texture: TextureRect = $BackgroundLayer/BackgroundTexture
@onready var background_placeholder: ColorRect = $BackgroundLayer/BackgroundPlaceholder
@onready var prop_layer: Node2D = $PropLayer
@onready var actor_layer: Node2D = $ActorLayer
@onready var effects_layer: Node2D = $EffectsLayer
@onready var ui_layer: CanvasLayer = $UILayer

var actors: Dictionary = {}
var props: Dictionary = {}
var pending_actions: Dictionary = {}

func _ready() -> void:
	_apply_background()
	stage_ready.emit()

func setup_stage(config: Dictionary) -> void:
	background_texture_path = str(config.get("background_texture_path", background_texture_path))
	left_actor_position = _get_vector2(config, "left_actor_position", left_actor_position)
	right_actor_position = _get_vector2(config, "right_actor_position", right_actor_position)
	center_prop_position = _get_vector2(config, "center_prop_position", center_prop_position)
	_apply_background()
	stage_ready.emit()

func add_actor(actor_data: Dictionary) -> Node:
	var actor := MINIGAME_ACTOR_SCENE.instantiate()
	actor_layer.add_child(actor)
	if actor.has_method("setup_actor"):
		actor.setup_actor(actor_data)
	var actor_id := str(actor_data.get("actor_id", actor.get("actor_id")))
	if actor_id.is_empty():
		actor_id = "actor_%d" % actors.size()
		actor.set("actor_id", actor_id)
	actor.position = _get_position_for_side(str(actor_data.get("side", actor.get("side"))))
	if actor.has_signal("action_finished"):
		actor.action_finished.connect(_on_actor_action_finished)
	actors[actor_id] = actor
	return actor

func add_prop(prop_scene: PackedScene, prop_data: Dictionary) -> Node:
	if prop_scene == null:
		return null
	var prop := prop_scene.instantiate()
	prop_layer.add_child(prop)
	if prop.has_method("setup_prop"):
		prop.setup_prop(prop_data)
	elif prop.has_method("setup_actor"):
		prop.setup_actor(prop_data)
	var prop_id := _get_prop_id(prop, prop_data)
	prop.position = _get_vector2(prop_data, "position", center_prop_position)
	if prop.has_signal("prop_animation_finished"):
		prop.prop_animation_finished.connect(_on_prop_animation_finished)
	props[prop_id] = prop
	return prop

func get_actor(actor_id: String) -> Node:
	return actors.get(actor_id, null)

func get_prop(prop_id: String) -> Node:
	return props.get(prop_id, null)

func get_removal_style_for_actor(actor_id: String) -> String:
	var actor := get_actor(actor_id)
	if actor == null:
		push_warning("MinigameStage using fallback removal style for missing actor: %s" % actor_id)
		return "vanish"
	if actor.has_method("get_removal_style_for_actor"):
		return str(actor.call("get_removal_style_for_actor"))
	var actor_type := str(actor.get("actor_type"))
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

func play_actor_action(actor_id: String, action_name: String, target_position: Vector2) -> void:
	var actor := get_actor(actor_id)
	var action_id := "%s:%s" % [actor_id, action_name]
	if actor == null:
		stage_action_finished.emit(action_id)
		return
	pending_actions[actor_id] = action_id
	match action_name:
		"reach":
			actor.play_reach(target_position)
		"carry":
			actor.play_carry(target_position)
		"remove":
			actor.play_remove_action(target_position)
		"machine":
			actor.play_machine_action(target_position)
		"success":
			actor.play_success()
		"failure":
			actor.play_failure()
		"reset":
			actor.reset_pose()
		_:
			actor.play_idle()

func play_prop_action(prop_id: String, action_name: String) -> void:
	var prop := get_prop(prop_id)
	var action_id := "%s:%s" % [prop_id, action_name]
	if prop == null:
		stage_action_finished.emit(action_id)
		return
	pending_actions[prop_id] = action_id
	match action_name:
		"flash":
			prop.play_flash()
		"shake":
			prop.play_shake()
		"crumble":
			prop.play_crumble()
		"active":
			prop.set_active(true)
			stage_action_finished.emit(action_id)
		"inactive":
			prop.set_active(false)
			stage_action_finished.emit(action_id)
		"reset":
			prop.reset_visual()
		_:
			stage_action_finished.emit(action_id)

func clear_stage() -> void:
	for actor in actors.values():
		if actor and is_instance_valid(actor):
			if actor is CanvasItem:
				actor.visible = false
			actor.queue_free()
	for prop in props.values():
		if prop and is_instance_valid(prop):
			if prop is CanvasItem:
				prop.visible = false
			prop.queue_free()
	actors.clear()
	props.clear()
	pending_actions.clear()

func _apply_background() -> void:
	background_texture.visible = false
	background_texture.texture = null
	background_placeholder.visible = true
	if background_texture_path.is_empty():
		return
	if not ResourceLoader.exists(background_texture_path):
		return
	var resource := load(background_texture_path)
	if resource is Texture2D:
		background_texture.texture = resource
		background_texture.visible = true
		background_placeholder.visible = false

func _get_position_for_side(side: String) -> Vector2:
	match side:
		"left":
			return left_actor_position
		"right":
			return right_actor_position
		_:
			return center_prop_position

func _get_prop_id(prop: Node, prop_data: Dictionary) -> String:
	var prop_id := str(prop_data.get("prop_id", ""))
	if prop_id.is_empty():
		prop_id = str(prop_data.get("pile_id", ""))
	if prop_id.is_empty():
		prop_id = "prop_%d" % props.size()
	return prop_id

func _get_vector2(data: Dictionary, key: String, fallback: Vector2) -> Vector2:
	var value: Variant = data.get(key, fallback)
	if value is Vector2:
		return value
	if value is Dictionary:
		return Vector2(float(value.get("x", fallback.x)), float(value.get("y", fallback.y)))
	return fallback

func _on_actor_action_finished(actor_id: String, action_name: String) -> void:
	var action_id := str(pending_actions.get(actor_id, "%s:%s" % [actor_id, action_name]))
	pending_actions.erase(actor_id)
	stage_action_finished.emit(action_id)

func _on_prop_animation_finished(prop_id: String) -> void:
	var action_id := str(pending_actions.get(prop_id, prop_id))
	pending_actions.erase(prop_id)
	stage_action_finished.emit(action_id)
