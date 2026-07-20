extends SceneTree

var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var debug_log := root.get_node_or_null("DebugLog")
	var state := root.get_node_or_null("GameState")
	var save_manager := root.get_node_or_null("SaveManager")
	_expect(debug_log != null, "DebugLog autoload is available")
	_expect(state != null, "GameState is available for diagnostics")
	_expect(save_manager != null, "SaveManager is available for resume diagnostics")
	if debug_log == null or state == null or save_manager == null:
		_finish()
		return

	state.call("reset_for_new_game")
	var snapshot: Dictionary = state.call("get_debug_snapshot")
	_expect(str(snapshot.get("quest", "")) == "opening_look_around", "route snapshot exposes the active quest")
	_expect(snapshot.has("phase") and snapshot.has("required_progress"), "route snapshot exposes phase and progress")
	_expect((state.call("validate_debug_state") as PackedStringArray).is_empty(), "fresh state passes route invariants")

	state.set("maintenance_sync_completed", true)
	var invalid_issues: PackedStringArray = state.call("validate_debug_state")
	_expect(_contains_fragment(invalid_issues, "before Static Service Run"), "invalid route ordering produces an actionable diagnostic")
	state.call("reset_for_new_game")

	var resume_cases := {
		SceneChanger.ROCKBYTE_DUEL_SCENE: SceneChanger.ARCADE_HUB_SCENE,
		SceneChanger.BROKEN_HIGH_SCORE_SCENE: SceneChanger.CABINET_ROW_SCENE,
		SceneChanger.TRUTH_FILTER_SCENE: SceneChanger.CABINET_ROW_SCENE,
		SceneChanger.CIRCUIT_SODA_SCENE: SceneChanger.SNACK_ALCOVE_SCENE,
		SceneChanger.SNACK_SERVICE_DASH_SCENE: SceneChanger.SNACK_ALCOVE_SCENE,
		SceneChanger.PRIZE_SHELF_RUN_SCENE: SceneChanger.PRIZE_CORNER_SCENE,
		SceneChanger.NIGHT_LEDGER_RUN_SCENE: SceneChanger.SNACK_HALLWAY_SCENE,
		SceneChanger.STATIC_SERVICE_RUN_SCENE: SceneChanger.MAINTENANCE_HALL_SCENE,
		SceneChanger.SYNC_DOOR_PUZZLE_SCENE: SceneChanger.MAINTENANCE_HALL_SCENE,
		SceneChanger.SECURITY_TAPE_ASSEMBLY_SCENE: SceneChanger.STAFF_CORRIDOR_SCENE,
		SceneChanger.FINAL_NIGHT_WALK_SCENE: SceneChanger.STAFF_CORRIDOR_SCENE,
		SceneChanger.MEMORY_ECHO_SCENE: SceneChanger.STAFF_CORRIDOR_SCENE,
	}
	for minigame_path in resume_cases:
		var actual := str(save_manager.call("_get_safe_resume_scene", minigame_path))
		_expect(actual == str(resume_cases[minigame_path]), "%s resumes in its owning room" % minigame_path.get_file())

	var save_source := FileAccess.get_file_as_string("res://scripts/SaveManager.gd")
	_expect(not save_source.contains("HUB_TICKET_SWEEP_SCENE"), "save code has no removed Ticket Sweep constant")
	_expect(not save_source.contains("CABINET_TRACE_RUN_SCENE"), "save code has no removed Cabinet Trace constant")

	var event_count := (debug_log.call("get_recent_events") as Array).size()
	debug_log.call("info", "qa", "diagnostic_smoke_event", {"quest": state.call("get_current_quest_id")})
	var new_event_count := (debug_log.call("get_recent_events") as Array).size()
	_expect(not bool(debug_log.get("enabled")) or new_event_count == event_count + 1, "debug event buffer records structured events when enabled")
	_expect(not bool(debug_log.get("enabled")) or not str(debug_log.get("log_path")).is_empty(), "debug session exposes its log path")

	_finish()


func _contains_fragment(values: PackedStringArray, fragment: String) -> bool:
	for value in values:
		if value.contains(fragment):
			return true
	return false


func _expect(condition: bool, label: String) -> void:
	if condition:
		print("PASS: %s" % label)
		return
	failures += 1
	push_error("FAIL: %s" % label)


func _finish() -> void:
	print("DebugDiagnosticsSmoke: %s" % ("PASS" if failures == 0 else "FAIL (%d)" % failures))
	quit(0 if failures == 0 else 1)
