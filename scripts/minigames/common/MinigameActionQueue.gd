extends Node

signal sequence_started
signal sequence_finished
signal action_started(action_data: Dictionary)
signal action_finished(action_data: Dictionary)

@export var stage_path: NodePath

var stage: Node = null
var actions: Array[Dictionary] = []
var current_index: int = 0
var playing: bool = false

func _ready() -> void:
	if not stage_path.is_empty():
		stage = get_node_or_null(stage_path)

func set_stage(value: Node) -> void:
	stage = value

func clear() -> void:
	actions.clear()
	current_index = 0
	playing = false

func add_action(action_data: Dictionary) -> void:
	actions.append(action_data.duplicate(true))

func play() -> void:
	if playing:
		return
	_play_sequence()

func is_playing() -> bool:
	return playing

func _play_sequence() -> void:
	playing = true
	current_index = 0
	sequence_started.emit()
	while current_index < actions.size():
		var action_data: Dictionary = actions[current_index]
		action_started.emit(action_data)
		await _run_action(action_data)
		action_finished.emit(action_data)
		current_index += 1
	playing = false
	sequence_finished.emit()

func _run_action(action_data: Dictionary) -> void:
	var action_type := str(action_data.get("type", ""))
	match action_type:
		"actor_action":
			await _run_actor_action(action_data)
		"prop_action":
			await _run_prop_action(action_data)
		"wait":
			await _run_wait(action_data)
		"status_text":
			_run_status_text(action_data)
		_:
			push_warning("MinigameActionQueue skipped unknown action type: %s" % action_type)

func _run_actor_action(action_data: Dictionary) -> void:
	if not _stage_is_ready():
		return
	var actor_id := str(action_data.get("actor_id", ""))
	var action_name := str(action_data.get("action", "idle"))
	if actor_id.is_empty():
		push_warning("MinigameActionQueue skipped actor action with no actor_id.")
		return
	if stage.has_method("get_actor") and stage.call("get_actor", actor_id) == null:
		push_warning("MinigameActionQueue skipped missing actor: %s" % actor_id)
		return
	var target_position := _get_target_position(action_data)
	if not stage.has_method("play_actor_action"):
		push_warning("MinigameActionQueue stage has no play_actor_action method.")
		return
	stage.call("play_actor_action", actor_id, action_name, target_position)
	await _wait_for_stage_action()

func _run_prop_action(action_data: Dictionary) -> void:
	if not _stage_is_ready():
		return
	var prop_id := str(action_data.get("prop_id", ""))
	var action_name := str(action_data.get("action", ""))
	if prop_id.is_empty():
		push_warning("MinigameActionQueue skipped prop action with no prop_id.")
		return
	if not stage.has_method("get_prop"):
		push_warning("MinigameActionQueue stage has no get_prop method.")
		return
	var prop: Node = stage.call("get_prop", prop_id) as Node
	if prop == null:
		push_warning("MinigameActionQueue skipped missing prop: %s" % prop_id)
		return
	if _run_direct_prop_action(prop, action_data):
		await _wait_for_prop_animation(prop)
		return
	if not stage.has_method("play_prop_action"):
		push_warning("MinigameActionQueue stage has no play_prop_action method.")
		return
	stage.call("play_prop_action", prop_id, action_name)
	await _wait_for_stage_action()

func _run_direct_prop_action(prop: Node, action_data: Dictionary) -> bool:
	var action_name := str(action_data.get("action", ""))
	match action_name:
		"remove_one":
			var style := str(action_data.get("style", "vanish"))
			if prop.has_method("remove_amount") and _prop_has_removable_items(prop, 1):
				prop.call("remove_amount", 1, style)
				return true
		"remove_amount":
			var amount := int(action_data.get("amount", 1))
			var style := str(action_data.get("style", "vanish"))
			if prop.has_method("remove_amount") and _prop_has_removable_items(prop, amount):
				prop.call("remove_amount", amount, style)
				return true
	return false

func _prop_has_removable_items(prop: Node, amount: int) -> bool:
	if amount <= 0:
		return false
	if not prop.has_method("get_count"):
		return true
	var current_count := int(prop.call("get_count"))
	if current_count <= 0:
		push_warning("MinigameActionQueue skipped remove action on empty prop.")
		return false
	return true

func _run_wait(action_data: Dictionary) -> void:
	var duration := maxf(float(action_data.get("duration", 0.0)), 0.0)
	if duration <= 0.0:
		return
	await get_tree().create_timer(duration).timeout

func _run_status_text(action_data: Dictionary) -> void:
	var text := str(action_data.get("text", ""))
	if text.is_empty():
		return
	if stage != null and stage.has_method("set_status_text"):
		stage.call("set_status_text", text)
	else:
		print(text)

func _get_target_position(action_data: Dictionary) -> Vector2:
	var target_position_value: Variant = action_data.get("target_position", null)
	if target_position_value is Vector2:
		return target_position_value
	if target_position_value is Dictionary:
		return Vector2(
			float(target_position_value.get("x", 0.0)),
			float(target_position_value.get("y", 0.0))
		)
	var target_prop_id := str(action_data.get("target_prop_id", ""))
	if not target_prop_id.is_empty() and stage != null and stage.has_method("get_prop"):
		var prop: Node = stage.call("get_prop", target_prop_id) as Node
		if prop != null and prop is Node2D:
			var prop_node_2d := prop as Node2D
			return prop_node_2d.global_position
	if stage != null:
		var center_position: Variant = stage.get("center_prop_position")
		if center_position is Vector2:
			return center_position
	return Vector2.ZERO

func _stage_is_ready() -> bool:
	if stage != null:
		return true
	push_warning("MinigameActionQueue has no stage reference.")
	return false

func _wait_for_stage_action() -> void:
	if stage != null and stage.has_signal("stage_action_finished"):
		var signal_ref: Signal = Signal(stage, "stage_action_finished")
		await signal_ref

func _wait_for_prop_animation(prop: Node) -> void:
	if prop.has_signal("prop_animation_finished"):
		var signal_ref: Signal = Signal(prop, "prop_animation_finished")
		await signal_ref
