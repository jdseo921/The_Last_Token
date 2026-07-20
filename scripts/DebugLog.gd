extends Node

## Lightweight runtime trace for editor/debug builds.
##
## F9 prints the current route snapshot. F8 prints the recent event buffer.
## Logs are written to user://logs only in debug builds or when
## THE_LAST_TOKEN_DEBUG=1 is set.

signal event_recorded(entry: Dictionary)

const MAX_RECENT_EVENTS := 250
const DEBUG_ENVIRONMENT_VARIABLE := "THE_LAST_TOKEN_DEBUG"

var enabled := false
var log_path := ""
var recent_events: Array[Dictionary] = []
var _log_file: FileAccess = null
var _last_route_fingerprint := ""
var _last_scene_path := ""


func _ready() -> void:
	enabled = OS.has_feature("debug") or OS.get_environment(DEBUG_ENVIRONMENT_VARIABLE) == "1"
	if not enabled:
		set_process(false)
		return
	_open_session_log()
	info("debug", "session_started", {
		"godot": Engine.get_version_info().get("string", "unknown"),
		"log": log_path,
	})
	call_deferred("_capture_initial_state")


func _exit_tree() -> void:
	if _log_file != null:
		_log_file.flush()
		_log_file = null


func _process(_delta: float) -> void:
	if not enabled:
		return
	# Command-line QA scripts intentionally mutate isolated flags and do not own a
	# gameplay scene. Validate route invariants only while an actual scene runs.
	if get_tree().current_scene == null:
		return
	var scene_path := _current_scene_path()
	if scene_path != _last_scene_path:
		info("scene", "current_scene_changed", {"from": _last_scene_path, "to": scene_path})
		_last_scene_path = scene_path
	var state := get_node_or_null("/root/GameState")
	if state == null or not state.has_method("get_debug_snapshot"):
		return
	var snapshot: Dictionary = state.call("get_debug_snapshot")
	var fingerprint := "%s|%s|%s|%s|%s" % [
		snapshot.get("quest", ""),
		snapshot.get("phase", ""),
		snapshot.get("required_progress", 0),
		snapshot.get("memory_signal", ""),
		snapshot.get("pending_spawn", ""),
	]
	if fingerprint == _last_route_fingerprint:
		return
	_last_route_fingerprint = fingerprint
	info("story", "route_state_changed", snapshot)
	_validate_state(state)


func _unhandled_key_input(input_event: InputEvent) -> void:
	if not enabled or not input_event is InputEventKey:
		return
	var key_event := input_event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return
	if key_event.keycode == KEY_F9:
		dump_state("manual_f9")
		get_viewport().set_input_as_handled()
	elif key_event.keycode == KEY_F8:
		print_recent_events(30)
		get_viewport().set_input_as_handled()


func info(category: String, message: String, data: Dictionary = {}) -> void:
	record("INFO", category, message, data)


func warning(category: String, message: String, data: Dictionary = {}) -> void:
	record("WARN", category, message, data)
	if enabled:
		push_warning("[%s] %s %s" % [category, message, _format_data(data)])


func failure(category: String, message: String, data: Dictionary = {}) -> void:
	record("ERROR", category, message, data)
	if enabled:
		push_error("[%s] %s %s" % [category, message, _format_data(data)])


func record(level: String, category: String, message: String, data: Dictionary = {}) -> void:
	if not enabled:
		return
	var entry := {
		"elapsed_ms": Time.get_ticks_msec(),
		"level": level,
		"category": category,
		"message": message,
		"scene": _current_scene_path(),
		"data": data.duplicate(true),
	}
	recent_events.append(entry)
	if recent_events.size() > MAX_RECENT_EVENTS:
		recent_events.pop_front()
	var line := _format_entry(entry)
	print(line)
	if _log_file != null:
		_log_file.store_line(line)
		_log_file.flush()
	event_recorded.emit(entry)


func dump_state(reason := "manual") -> Dictionary:
	var snapshot: Dictionary = {"scene": _current_scene_path()}
	var state := get_node_or_null("/root/GameState")
	if state != null and state.has_method("get_debug_snapshot"):
		snapshot.merge(state.call("get_debug_snapshot"), true)
	info("debug", "state_snapshot", {"reason": reason, "snapshot": snapshot})
	return snapshot


func print_recent_events(limit := 30) -> void:
	if not enabled:
		return
	var start := maxi(0, recent_events.size() - maxi(limit, 1))
	print("--- The Last Token recent debug events ---")
	for index in range(start, recent_events.size()):
		print(_format_entry(recent_events[index]))
	print("--- log: %s ---" % log_path)


func get_recent_events() -> Array[Dictionary]:
	return recent_events.duplicate(true)


func describe_node(node: Node) -> Dictionary:
	if node == null:
		return {"node": "<null>"}
	return {
		"node": str(node.get_path()),
		"class": node.get_class(),
		"scene_file": node.scene_file_path,
	}


func _capture_initial_state() -> void:
	_last_scene_path = _current_scene_path()
	dump_state("startup")


func _validate_state(state: Node) -> void:
	if _is_qa_run():
		return
	if not state.has_method("validate_debug_state"):
		return
	var issues: PackedStringArray = state.call("validate_debug_state")
	for issue in issues:
		failure("story", "invalid_route_state", {"issue": issue})


func _is_qa_run() -> bool:
	var tree_script: Variant = get_tree().get_script()
	return tree_script is Script and (tree_script as Script).resource_path.begins_with("res://scripts/qa/")


func _open_session_log() -> void:
	var directory := "user://logs"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
	var stamp := Time.get_datetime_string_from_system().replace(":", "-")
	log_path = "%s/debug_%s_%d.log" % [directory, stamp, OS.get_process_id()]
	_log_file = FileAccess.open(log_path, FileAccess.WRITE)
	if _log_file == null:
		push_warning("DebugLog could not open %s" % log_path)


func _current_scene_path() -> String:
	var tree := get_tree()
	if tree == null or tree.current_scene == null:
		return "<none>"
	var path := tree.current_scene.scene_file_path
	return path if not path.is_empty() else str(tree.current_scene.get_path())


func _format_entry(entry: Dictionary) -> String:
	return "%08d | %-5s | %-12s | %s | %s | %s" % [
		int(entry.get("elapsed_ms", 0)),
		str(entry.get("level", "INFO")),
		str(entry.get("category", "general")),
		str(entry.get("scene", "<none>")),
		str(entry.get("message", "")),
		_format_data(entry.get("data", {})),
	]


func _format_data(data: Variant) -> String:
	if data is Dictionary and (data as Dictionary).is_empty():
		return "{}"
	return str(data)
