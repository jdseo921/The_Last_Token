class_name HybridExplorerController
extends CharacterBody2D

## Reusable platform-exploration controller for the scrolling adventure stages.
## The controller owns movement only; stage objectives, portals and story state
## remain in the parent stage.

signal state_changed(previous_state: MovementState, current_state: MovementState)
signal jump_energy_changed(current: float, maximum: float)
signal master_scene_event(payload: Dictionary)

enum MovementState {
	IDLE,
	RUN,
	JUMP,
	WALL_CLING,
	CROUCH,
}

@export_category("Movement")
@export var run_speed := 172.0
@export var crouch_speed := 72.0
@export var ground_acceleration := 1150.0
@export var air_acceleration := 760.0
@export var ground_friction := 1450.0
@export var gravity := 980.0
@export var terminal_velocity := 620.0

@export_category("Jumping")
@export var jump_speed := 344.0
@export var max_midair_jumps := 3
@export var variable_jump_cut := 0.42
@export var coyote_seconds := 0.12
@export var jump_buffer_seconds := 0.14

@export_category("Wall movement")
@export var wall_slide_speed := 54.0
@export var wall_kick_horizontal_speed := 236.0
@export var wall_kick_vertical_speed := 310.0
@export var wall_up_jump_speed := 286.0
@export var max_jump_energy := 100.0
@export var jump_energy_recharge_per_second := 48.0

@export_category("Collision")
@export_range(0.35, 0.8, 0.05) var crouch_height_ratio := 0.55

@export_category("Input")
@export var move_left_action := &"move_left"
@export var move_right_action := &"move_right"
@export var move_up_action := &"move_up"
@export var crouch_action := &"crouch"
@export var jump_action := &"jump"

@export_category("Optional 3D bridge")
@export var master_3d_bridge_path: NodePath

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var visual_root: Node2D = $VisualRoot

var movement_state: MovementState = MovementState.IDLE
var jump_energy := 100.0
var midair_jumps_used := 0
var facing_direction := 1.0

var _normal_shape_height := 28.0
var _normal_shape_position := Vector2.ZERO
var _jump_was_pressed := false
var _jump_cut_applied := false
var _coyote_timer := 0.0
var _jump_buffer_timer := 0.0
var _crouched := false
var _movement_enabled := true


func _ready() -> void:
	up_direction = Vector2.UP
	jump_energy = max_jump_energy
	var rectangle := collision_shape.shape as RectangleShape2D
	if rectangle != null:
		# Scene shapes can be shared resources. Duplicate before changing height.
		collision_shape.shape = rectangle.duplicate()
		rectangle = collision_shape.shape as RectangleShape2D
		_normal_shape_height = rectangle.size.y
	_normal_shape_position = collision_shape.position
	_emit_energy()


func _physics_process(delta: float) -> void:
	if not _movement_enabled:
		velocity = Vector2.ZERO
		return

	var move_axis := _read_horizontal_axis()
	var jump_held := Input.is_action_pressed(jump_action)
	var jump_pressed := jump_held and not _jump_was_pressed
	_jump_was_pressed = jump_held
	if jump_pressed:
		_jump_buffer_timer = jump_buffer_seconds
	else:
		_jump_buffer_timer = maxf(0.0, _jump_buffer_timer - delta)

	if is_on_floor():
		_coyote_timer = coyote_seconds
		midair_jumps_used = 0
		_recharge_jump_energy(delta)
	else:
		_coyote_timer = maxf(0.0, _coyote_timer - delta)

	_update_state_before_motion(move_axis)
	_apply_horizontal_motion(move_axis, delta)
	_apply_vertical_motion(delta, jump_held)
	if _jump_buffer_timer > 0.0:
		_try_jump()

	move_and_slide()
	_update_state_after_motion(move_axis)


func _read_horizontal_axis() -> float:
	var axis := 0.0
	if Input.is_action_pressed(move_left_action):
		axis -= 1.0
	if Input.is_action_pressed(move_right_action):
		axis += 1.0
	return axis


func _update_state_before_motion(move_axis: float) -> void:
	if is_on_floor() and Input.is_action_pressed(crouch_action):
		_set_crouched(true)
		_set_state(MovementState.CROUCH)
		return
	if _crouched:
		_set_crouched(false)
		if _crouched:
			# Stay compressed until the full-height shape has clear headroom.
			_set_state(MovementState.CROUCH)
			return
	if not is_on_floor():
		_set_state(MovementState.WALL_CLING if is_on_wall() else MovementState.JUMP)
	elif absf(move_axis) > 0.01:
		_set_state(MovementState.RUN)
	else:
		_set_state(MovementState.IDLE)


func _update_state_after_motion(move_axis: float) -> void:
	if not is_on_floor() and is_on_wall():
		_set_state(MovementState.WALL_CLING)
		return
	if not is_on_floor():
		_set_state(MovementState.JUMP)
		return
	if _crouched or Input.is_action_pressed(crouch_action):
		_set_state(MovementState.CROUCH)
	elif absf(move_axis) > 0.01:
		_set_state(MovementState.RUN)
	else:
		_set_state(MovementState.IDLE)


func _apply_horizontal_motion(move_axis: float, delta: float) -> void:
	if absf(move_axis) > 0.01:
		facing_direction = signf(move_axis)
		visual_root.scale.x = facing_direction
	var target_speed := crouch_speed if movement_state == MovementState.CROUCH else run_speed
	if movement_state == MovementState.WALL_CLING:
		var wall_normal := get_wall_normal()
		velocity.x = -wall_normal.x * 6.0
		return
	var acceleration := ground_acceleration if is_on_floor() else air_acceleration
	if is_on_floor() and is_zero_approx(move_axis):
		velocity.x = move_toward(velocity.x, 0.0, ground_friction * delta)
	else:
		velocity.x = move_toward(velocity.x, move_axis * target_speed, acceleration * delta)


func _apply_vertical_motion(delta: float, jump_held: bool) -> void:
	if movement_state == MovementState.WALL_CLING:
		velocity.y = minf(velocity.y + gravity * 0.18 * delta, wall_slide_speed)
		return
	if not is_on_floor():
		velocity.y = minf(velocity.y + gravity * delta, terminal_velocity)
	if not jump_held and velocity.y < 0.0 and not _jump_cut_applied:
		velocity.y *= variable_jump_cut
		_jump_cut_applied = true


func _try_jump() -> void:
	if movement_state == MovementState.WALL_CLING or (not is_on_floor() and is_on_wall()):
		_perform_wall_jump()
		return
	if is_on_floor() or _coyote_timer > 0.0:
		_launch_jump(false)
		return
	if midair_jumps_used < max_midair_jumps:
		midair_jumps_used += 1
		_launch_jump(true)


func _perform_wall_jump() -> void:
	var wall_normal := get_wall_normal()
	if is_zero_approx(wall_normal.x):
		wall_normal.x = -facing_direction
	if Input.is_action_pressed(move_up_action) and jump_energy >= 25.0:
		# Upward wall jumps are the only movement that spends JumpEnergy.
		jump_energy -= 25.0
		velocity = Vector2(0.0, -wall_up_jump_speed)
		_emit_energy()
	else:
		# A diagonal wall kick never consumes JumpEnergy and does not count as a
		# mid-air jump, so it remains a reliable recovery option.
		velocity = Vector2(wall_normal.x * wall_kick_horizontal_speed, -wall_kick_vertical_speed)
		facing_direction = wall_normal.x
	_jump_buffer_timer = 0.0
	_jump_cut_applied = false
	_set_state(MovementState.JUMP)


func _launch_jump(_is_midair_jump: bool) -> void:
	velocity.y = -jump_speed
	_jump_buffer_timer = 0.0
	_coyote_timer = 0.0
	_jump_cut_applied = false
	_set_crouched(false)
	_set_state(MovementState.JUMP)


func _recharge_jump_energy(delta: float) -> void:
	var previous := jump_energy
	jump_energy = minf(max_jump_energy, jump_energy + jump_energy_recharge_per_second * delta)
	if not is_equal_approx(previous, jump_energy):
		_emit_energy()


func _set_crouched(enabled: bool) -> void:
	if _crouched == enabled:
		return
	var rectangle := collision_shape.shape as RectangleShape2D
	if rectangle == null:
		return
	if not enabled and not _can_stand():
		return
	_crouched = enabled
	if enabled:
		var crouch_height := _normal_shape_height * crouch_height_ratio
		rectangle.size.y = crouch_height
		collision_shape.position.y = _normal_shape_position.y + (_normal_shape_height - crouch_height) * 0.5
		visual_root.scale.y = crouch_height_ratio
	else:
		rectangle.size.y = _normal_shape_height
		collision_shape.position = _normal_shape_position
		visual_root.scale.y = 1.0


func _can_stand() -> bool:
	if not is_inside_tree() or collision_shape == null:
		return true
	var current_rectangle := collision_shape.shape as RectangleShape2D
	if current_rectangle == null:
		return true
	var standing_shape := RectangleShape2D.new()
	standing_shape.size = Vector2(current_rectangle.size.x, _normal_shape_height)
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = standing_shape
	query.transform = Transform2D(global_rotation, global_position + _normal_shape_position.rotated(global_rotation))
	query.collision_mask = collision_mask
	query.exclude = [get_rid()]
	query.collide_with_areas = false
	query.collide_with_bodies = true
	return get_world_2d().direct_space_state.intersect_shape(query, 1).is_empty()


func _set_state(next_state: MovementState) -> void:
	if movement_state == next_state:
		return
	var previous := movement_state
	movement_state = next_state
	state_changed.emit(previous, movement_state)


func _emit_energy() -> void:
	jump_energy_changed.emit(jump_energy, max_jump_energy)


func set_movement_enabled(enabled: bool) -> void:
	_movement_enabled = enabled
	if not enabled:
		velocity = Vector2.ZERO


func respawn_at(world_position: Vector2) -> void:
	global_position = world_position
	velocity = Vector2.ZERO
	midair_jumps_used = 0
	_set_crouched(false)
	_set_state(MovementState.JUMP)


func get_state_name() -> String:
	return MovementState.keys()[movement_state].capitalize()


func report_to_master_3d(event_name: StringName, data: Dictionary = {}) -> void:
	# A master 3D scene can connect to `master_scene_event` and translate this
	# compact packet into a 3D camera move, world-streaming request, or story
	# transition. Keeping only plain data here avoids coupling this 2D controller
	# to a particular 3D node hierarchy.
	var packet := {
		"event": event_name,
		"position_2d": global_position,
		"state": get_state_name(),
		"jump_energy": jump_energy,
		"data": data.duplicate(true),
	}
	master_scene_event.emit(packet)
	# If a bridge path is assigned, the 3D master can implement
	# `receive_2d_exploration_data(packet)` and receive the same payload directly.
	if not master_3d_bridge_path.is_empty():
		var bridge := get_node_or_null(master_3d_bridge_path)
		if bridge != null and bridge.has_method("receive_2d_exploration_data"):
			bridge.call_deferred("receive_2d_exploration_data", packet)
