extends Node2D

signal prop_animation_finished(prop_id: String)

const REMOVAL_CARRY := "carry"
const REMOVAL_REACH := "reach"
const REMOVAL_DIGITAL_CRUMBLE := "digital_crumble"
const REMOVAL_VANISH := "vanish"
const REMOVAL_SHAKE := "shake"
const ACTIVE_ROCK_COLOR := Color(0.68, 0.72, 0.78, 1.0)
const EMPTY_ROCK_COLOR := Color(0.13, 0.13, 0.16, 0.45)
const ACTION_SPEED_MULTIPLIER := 1.5
const ROCK_SPACING := 4.0

@export var pile_id: String = "rock_pile"
@export var max_rocks: int = 5
@export var current_rocks: int = 5
@export var rock_texture_path: String = ""
@export var use_placeholder_rocks: bool = true

@onready var title_label: Label = $TitleLabel
@onready var count_label: Label = $CountLabel
@onready var rocks_container: HBoxContainer = $RocksContainer

var rock_nodes: Array[Control] = []
var rock_texture: Texture2D = null
var action_tween: Tween = null

func _ready() -> void:
	_load_rock_texture()
	rebuild_visuals()

func setup_prop(data: Dictionary) -> void:
	pile_id = str(data.get("pile_id", data.get("prop_id", pile_id)))
	max_rocks = int(data.get("max_rocks", max_rocks))
	current_rocks = int(data.get("current_rocks", current_rocks))
	rock_texture_path = str(data.get("rock_texture_path", rock_texture_path))
	use_placeholder_rocks = bool(data.get("use_placeholder_rocks", use_placeholder_rocks))
	_load_rock_texture()
	rebuild_visuals()

func set_count(value: int) -> void:
	current_rocks = clampi(value, 0, max_rocks)
	_refresh_visual_count()

func get_count() -> int:
	return current_rocks

func remove_one_with_player_animation() -> void:
	remove_amount(1, REMOVAL_REACH)

func remove_one_with_machine_animation() -> void:
	remove_amount(1, REMOVAL_DIGITAL_CRUMBLE)

func remove_amount(amount: int, removal_style: String) -> void:
	if amount <= 0 or current_rocks <= 0:
		prop_animation_finished.emit(pile_id)
		return
	var remove_count := mini(amount, current_rocks)
	var old_count := current_rocks
	current_rocks -= remove_count
	var removed_indices: Array[int] = []
	for index in range(current_rocks, old_count):
		removed_indices.append(index)
	_play_removal_animation(removed_indices, removal_style)

func rebuild_visuals() -> void:
	_clear_rocks()
	max_rocks = maxi(max_rocks, 1)
	current_rocks = clampi(current_rocks, 0, max_rocks)
	title_label.text = pile_id.replace("_", " ").to_upper()
	rocks_container.visible = false
	for index in range(max_rocks):
		rock_nodes.append(_create_rock_node(index))
	_layout_rocks()
	_refresh_visual_count()

func _layout_rocks() -> void:
	# Rocks are placed by hand, symmetric around the prop origin, so the row
	# always shares a centerline with the title and count labels regardless of
	# theme container spacing.
	var rock_size := 20.0 if max_rocks <= 5 else 16.0
	var row_width := max_rocks * rock_size + (max_rocks - 1) * ROCK_SPACING
	for index in range(rock_nodes.size()):
		var rock := rock_nodes[index]
		rock.size = Vector2(rock_size, rock_size)
		var base_position := Vector2(-row_width * 0.5 + index * (rock_size + ROCK_SPACING), 6.0 - rock_size * 0.5)
		rock.position = base_position
		rock.set_meta("base_position", base_position)

func _create_rock_node(index: int) -> Control:
	var rock: Control
	if rock_texture != null:
		var texture_rect := TextureRect.new()
		texture_rect.texture = rock_texture
		texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		rock = texture_rect
	else:
		var color_rect := ColorRect.new()
		color_rect.color = ACTIVE_ROCK_COLOR
		rock = color_rect
	rock.name = "Rock%d" % [index + 1]
	add_child(rock)
	return rock

func _refresh_visual_count() -> void:
	count_label.text = "%d / %d" % [current_rocks, max_rocks]
	for index in range(rock_nodes.size()):
		var rock := rock_nodes[index]
		rock.visible = use_placeholder_rocks or rock_texture != null
		rock.modulate = Color.WHITE if index < current_rocks else EMPTY_ROCK_COLOR
		if rock is ColorRect:
			rock.color = ACTIVE_ROCK_COLOR if index < current_rocks else EMPTY_ROCK_COLOR

func _play_removal_animation(removed_indices: Array[int], removal_style: String) -> void:
	_stop_action_tween()
	action_tween = create_tween()
	action_tween.set_parallel(true)
	for index in removed_indices:
		if index < 0 or index >= rock_nodes.size():
			continue
		var rock := rock_nodes[index]
		match removal_style:
			REMOVAL_CARRY:
				action_tween.tween_property(rock, "position", rock.position + Vector2(18, -10), _scaled_action_time(0.18))
				action_tween.tween_property(rock, "modulate:a", 0.0, _scaled_action_time(0.18))
			REMOVAL_REACH:
				action_tween.tween_property(rock, "scale", Vector2(1.18, 1.18), _scaled_action_time(0.08))
				action_tween.tween_property(rock, "modulate:a", 0.0, _scaled_action_time(0.16))
			REMOVAL_DIGITAL_CRUMBLE:
				action_tween.tween_property(rock, "modulate", Color(0.45, 1.0, 1.0, 0.35), _scaled_action_time(0.07))
				action_tween.tween_property(rock, "modulate:a", 0.0, _scaled_action_time(0.14))
			REMOVAL_SHAKE:
				action_tween.tween_property(rock, "position", rock.position + Vector2(-3, 0), _scaled_action_time(0.04))
				action_tween.tween_property(rock, "position", rock.position + Vector2(3, 0), _scaled_action_time(0.04))
				action_tween.tween_property(rock, "modulate:a", 0.0, _scaled_action_time(0.14))
			_:
				action_tween.tween_property(rock, "modulate:a", 0.0, _scaled_action_time(0.12))
	action_tween.finished.connect(_on_removal_animation_finished.bind(removed_indices), CONNECT_ONE_SHOT)

func _on_removal_animation_finished(removed_indices: Array[int]) -> void:
	for index in removed_indices:
		if index >= 0 and index < rock_nodes.size():
			var rock := rock_nodes[index]
			rock.position = rock.get_meta("base_position", rock.position)
			rock.scale = Vector2.ONE
			rock.modulate = Color.WHITE
	_refresh_visual_count()
	prop_animation_finished.emit(pile_id)

func _load_rock_texture() -> void:
	rock_texture = null
	if rock_texture_path.is_empty():
		return
	if not ResourceLoader.exists(rock_texture_path):
		return
	var resource := load(rock_texture_path)
	if resource is Texture2D:
		rock_texture = resource

func _scaled_action_time(seconds: float) -> float:
	return seconds / ACTION_SPEED_MULTIPLIER

func _clear_rocks() -> void:
	for rock in rock_nodes:
		if rock and is_instance_valid(rock):
			rock.queue_free()
	rock_nodes.clear()

func _stop_action_tween() -> void:
	if action_tween and action_tween.is_valid():
		action_tween.kill()
	action_tween = null
