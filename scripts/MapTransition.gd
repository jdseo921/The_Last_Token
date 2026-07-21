extends Area2D

const DEBUG := preload("res://scripts/Debug.gd")

@export var target_scene_path: String = ""
@export var target_spawn_id: String = "Spawn_Default"
@export var required_flag: String = ""
@export var locked_message: Array[String] = []
@export var locked_dialogue: Array[String] = []
@export var auto_transition_on_body_entered := true
@export var destination_name := ""
@export var arrow_direction := "auto"
@export var label_offset_override := Vector2.ZERO

const ARM_DELAY_SECONDS := 0.35
const PROXIMITY_RADIUS := 96.0
const ARROW_COLOR := Color(0.45, 0.95, 1.0, 1.0)
const ARROW_LOCKED_COLOR := Color(1.0, 0.4, 0.45, 1.0)

var transition_started := false
var armed := false
var arrow: Polygon2D = null
var name_label: Label = null
var proximity_area: Area2D = null
var pulse_tween: Tween = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_build_marker_visuals()
	# Do not auto-transition on the frame the player spawns in. If the spawn point
	# overlaps this trigger (common when a room's exit sits next to its spawn), the
	# player would be bounced straight back. Arm only after a short delay, and if
	# they spawn already inside, require them to step out first.
	call_deferred("_arm_after_spawn")

func _build_marker_visuals() -> void:
	# Replace the old always-on EXIT label/hexagon with a pulsing arrow whose
	# destination name only appears when the player is near.
	var old_visual := get_node_or_null("Visual")
	if old_visual is CanvasItem:
		(old_visual as CanvasItem).visible = false
	var dir := _resolve_direction()
	arrow = Polygon2D.new()
	arrow.name = "ExitArrow"
	arrow.polygon = _arrow_points(dir)
	arrow.color = ARROW_LOCKED_COLOR if not _required_flag_is_met() else ARROW_COLOR
	add_child(arrow)
	pulse_tween = create_tween()
	pulse_tween.set_loops()
	pulse_tween.tween_property(arrow, "modulate:a", 0.22, 0.55)
	pulse_tween.tween_property(arrow, "modulate:a", 1.0, 0.55)
	name_label = get_node_or_null("Label")
	if name_label == null:
		name_label = Label.new()
		add_child(name_label)
	name_label.text = _get_destination_name()
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_override("font", preload("res://assets/fonts/m6x11.ttf"))
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.add_theme_color_override("font_outline_color", Color(0.01, 0.02, 0.03, 1.0))
	name_label.add_theme_constant_override("outline_size", 2)
	var label_offset := label_offset_override if label_offset_override != Vector2.ZERO else _label_offset(dir)
	name_label.position = label_offset
	name_label.size = Vector2(150, 16)
	name_label.visible = false
	proximity_area = Area2D.new()
	proximity_area.name = "ProximityArea"
	var shape_node := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = PROXIMITY_RADIUS
	shape_node.shape = circle
	proximity_area.add_child(shape_node)
	add_child(proximity_area)
	proximity_area.body_entered.connect(_on_proximity_entered)
	proximity_area.body_exited.connect(_on_proximity_exited)

func _resolve_direction() -> String:
	if arrow_direction != "auto" and not arrow_direction.is_empty():
		return arrow_direction
	var pos := global_position
	if pos.x <= 90.0:
		return "left"
	if pos.x >= 550.0:
		return "right"
	if pos.y >= 350.0:
		return "down"
	if pos.y <= 90.0:
		return "up"
	return "down"

func _arrow_points(dir: String) -> PackedVector2Array:
	match dir:
		"left":
			return PackedVector2Array([Vector2(6, -9), Vector2(6, 9), Vector2(-10, 0)])
		"right":
			return PackedVector2Array([Vector2(-6, -9), Vector2(-6, 9), Vector2(10, 0)])
		"up":
			return PackedVector2Array([Vector2(-9, 6), Vector2(9, 6), Vector2(0, -10)])
		_:
			return PackedVector2Array([Vector2(-9, -6), Vector2(9, -6), Vector2(0, 10)])

func _label_offset(dir: String) -> Vector2:
	match dir:
		"left":
			return Vector2(14, -8)
		"right":
			return Vector2(-164, -8)
		"up":
			return Vector2(-75, 14)
		_:
			return Vector2(-75, -30)

func _get_destination_name() -> String:
	if not destination_name.is_empty():
		return destination_name.to_upper()
	var base := target_scene_path.get_file().get_basename()
	var out := ""
	for i in range(base.length()):
		var ch := base[i]
		if i > 0 and ch == ch.to_upper() and ch != ch.to_lower():
			out += " "
		out += ch
	return out.to_upper()

func _on_proximity_entered(body: Node) -> void:
	if body is CharacterBody2D and name_label != null:
		name_label.visible = true

func _on_proximity_exited(body: Node) -> void:
	if body is CharacterBody2D and name_label != null:
		name_label.visible = false

func _arm_after_spawn() -> void:
	await get_tree().create_timer(ARM_DELAY_SECONDS).timeout
	if is_instance_valid(self) and not _player_overlapping():
		armed = true

func _player_overlapping() -> bool:
	for body in get_overlapping_bodies():
		if body is CharacterBody2D:
			return true
	return false

func interact(_player: Node = null) -> void:
	_try_transition()

func _on_body_exited(body: Node) -> void:
	if body is CharacterBody2D and not _player_overlapping():
		armed = true

func _on_body_entered(body: Node) -> void:
	if not auto_transition_on_body_entered:
		return
	if not armed:
		return
	if body is CharacterBody2D:
		_try_transition()

func _try_transition() -> void:
	if transition_started:
		return
	var scene := get_tree().current_scene
	if scene != null and scene.has_method("try_block_exit") and bool(scene.call("try_block_exit", self)):
		DEBUG.info(self, "navigation", "exit_blocked_by_scene", _debug_transition_data())
		return
	if not _required_flag_is_met():
		DEBUG.info(self, "navigation", "exit_blocked_by_flag", _debug_transition_data())
		_show_locked_dialogue()
		return
	if target_scene_path.is_empty():
		DEBUG.failure(self, "navigation", "exit_missing_target", _debug_transition_data())
		push_error("MapTransition: target_scene_path is empty.")
		return
	if not ResourceLoader.exists(target_scene_path):
		DEBUG.failure(self, "navigation", "exit_target_not_found", _debug_transition_data())
		push_error("MapTransition: target scene does not exist: %s" % target_scene_path)
		return
	transition_started = true
	DEBUG.info(self, "navigation", "exit_transition_started", _debug_transition_data())
	GameState.set_pending_spawn_id(target_spawn_id)
	SceneChanger.change_scene(target_scene_path)

func _required_flag_is_met() -> bool:
	if required_flag.is_empty():
		return true
	return bool(GameState.get(required_flag))

func _show_locked_dialogue() -> void:
	var lines: Array = []
	var message_lines := locked_dialogue if not locked_dialogue.is_empty() else locked_message
	if message_lines.is_empty():
		lines.append({"speaker": "Player", "text": "Not this way. Not yet."})
	else:
		for text in message_lines:
			lines.append({"speaker": "Player", "text": text})
	var host := _find_dialogue_host()
	if host != null and host.has_method("start_dialogue"):
		host.call("start_dialogue", lines)
	else:
		push_warning("MapTransition locked: %s" % str(message_lines))

func _find_dialogue_host() -> Node:
	var cursor: Node = self
	while cursor != null:
		if cursor.has_method("start_dialogue"):
			return cursor
		cursor = cursor.get_parent()
	var scene := get_tree().current_scene
	if scene != null and scene.has_method("start_dialogue"):
		return scene
	return null

func _debug_transition_data() -> Dictionary:
	return {
		"exit": str(get_path()),
		"target": target_scene_path,
		"spawn": target_spawn_id,
		"required_flag": required_flag,
		"required_flag_met": _required_flag_is_met(),
		"armed": armed,
	}
