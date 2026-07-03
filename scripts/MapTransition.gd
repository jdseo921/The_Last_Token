extends Area2D

@export var target_scene_path: String = ""
@export var target_spawn_id: String = "Spawn_Default"
@export var required_flag: String = ""
@export var locked_message: Array[String] = []
@export var locked_dialogue: Array[String] = []
@export var auto_transition_on_body_entered := true

const ARM_DELAY_SECONDS := 0.35

var transition_started := false
var armed := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	# Do not auto-transition on the frame the player spawns in. If the spawn point
	# overlaps this trigger (common when a room's exit sits next to its spawn), the
	# player would be bounced straight back. Arm only after a short delay, and if
	# they spawn already inside, require them to step out first.
	call_deferred("_arm_after_spawn")

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
	if not _required_flag_is_met():
		_show_locked_dialogue()
		return
	if target_scene_path.is_empty():
		push_error("MapTransition: target_scene_path is empty.")
		return
	if not ResourceLoader.exists(target_scene_path):
		push_error("MapTransition: target scene does not exist: %s" % target_scene_path)
		return
	transition_started = true
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
		lines.append({"speaker": "System", "text": "The path is locked."})
	else:
		for text in message_lines:
			lines.append({"speaker": "System", "text": text})
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
