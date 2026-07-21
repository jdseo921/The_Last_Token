extends SceneTree

const ROUTE_CUE := preload("res://scripts/RouteCue.gd")
const DIALOGUE_BOX := preload("res://scenes/ui/DialogueBox.tscn")

var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var game_state := root.get_node_or_null("GameState")
	_expect(game_state != null, "GameState autoload is available")
	if game_state == null:
		quit(1)
		return
	game_state.set("route_cue_close_tip_seen", false)

	var host := Control.new()
	host.name = "NavigationUiSmokeHost"
	root.add_child(host)
	current_scene = host

	var dialogue_box := DIALOGUE_BOX.instantiate()
	host.add_child(dialogue_box)
	await process_frame

	var automatic_cue := ROUTE_CUE.new()
	host.add_child(automatic_cue)
	automatic_cue.setup("cabinet_row", Vector2(24, 86), 390.0)
	await process_frame
	automatic_cue.set("dismissed", false)
	automatic_cue.visible = true
	automatic_cue.get_node("RouteCueLabel").text = "LOCAL: Talk to Roxy by the score cabinet."
	dialogue_box.call("start_dialogue", [{"speaker": "Roxy", "text": "Finally."}])
	_expect(not automatic_cue.visible, "target NPC dialogue closes the navigation cue")
	_expect(bool(automatic_cue.get("dismissed")), "target NPC closure remains dismissed in the room")
	dialogue_box.call("_accept_current_line")
	_expect(bool(automatic_cue.call("_dialogue_matches_displayed_target", "LOCAL: Talk to Mr.\nByte about the Truth Filter.", [{"speaker": "Mr. Byte", "text": "Ready."}])), "balanced route-cue line breaks do not prevent destination matching")
	var object_cue := ROUTE_CUE.new()
	host.add_child(object_cue)
	object_cue.setup("staff_room", Vector2(24, 86), 390.0)
	await process_frame
	object_cue.set("dismissed", false)
	object_cue.visible = true
	object_cue.get_node("RouteCueLabel").text = "LOCAL: Inspect the restore terminal."
	var late_dialogue_box := DIALOGUE_BOX.instantiate()
	host.add_child(late_dialogue_box)
	await process_frame
	late_dialogue_box.call("start_dialogue", [{"speaker": "Terminal", "text": "RESTORED TAPE ACCEPTED."}])
	_expect(not object_cue.visible, "destination dialogue closes navigation for a dynamically added terminal box")
	_expect(bool(object_cue.get("dismissed")), "terminal destination navigation remains expired")
	late_dialogue_box.call("_accept_current_line")
	game_state.set("story_started", true)
	game_state.set("lost_token_quest_completed", true)
	game_state.set("broken_high_score_completed", true)
	game_state.set("lying_cabinets_completed", true)
	game_state.set("mr_byte_truth_filter_debriefed", true)
	game_state.set("gus_hub_checkin_truth_filter_done", false)
	game_state.set("circuit_soda_completed", false)
	automatic_cue.call("refresh")
	_expect(automatic_cue.visible, "new quest reopens navigation after target dialogue dismissal")
	_expect(automatic_cue.get_node("RouteCueLabel").text.contains("CABINET HALLWAY"), "Catch Up With Gus gets the refreshed route back to the hub")

	var manual_cue := ROUTE_CUE.new()
	host.add_child(manual_cue)
	manual_cue.setup("cabinet_row", Vector2(24, 86), 390.0)
	await process_frame
	manual_cue.set("dismissed", false)
	manual_cue.visible = true
	manual_cue.get_node("RouteCueLabel").text = "ROUTE: Take CABINET ROW exit."
	manual_cue.call("_on_close_pressed")
	_expect(bool(game_state.get("route_cue_close_tip_seen")), "first X close records the tutorial tip")
	_expect(bool(manual_cue.get("showing_dismiss_tip")), "first X close briefly shows the Esc menu reminder")
	_expect(manual_cue.get_node("RouteCueLabel").text.contains("Esc > Quest"), "dismiss reminder names the Quest entry")
	manual_cue.call("_finish_dismiss_tip")

	var repeat_cue := ROUTE_CUE.new()
	host.add_child(repeat_cue)
	repeat_cue.setup("cabinet_row", Vector2(24, 86), 390.0)
	await process_frame
	repeat_cue.set("dismissed", false)
	repeat_cue.visible = true
	repeat_cue.call("_on_close_pressed")
	_expect(not repeat_cue.visible, "later X closes do not repeat the tutorial tip")
	_expect(not bool(repeat_cue.get("showing_dismiss_tip")), "tutorial reminder is first-close only")

	var quest_notice_scene := load("res://scenes/ui/QuestNotice.tscn") as PackedScene
	_expect(quest_notice_scene != null, "QuestNotice scene loads")
	if quest_notice_scene == null:
		quit(1)
		return
	var quest_notice := quest_notice_scene.instantiate()
	host.add_child(quest_notice)
	await process_frame
	await process_frame
	quest_notice.call("show_custom_notification", "QUEST UPDATE", "TEST", "This must remain in the corner HUD.")
	_expect(not quest_notice.visible and not bool(game_state.get("ui_notice_blocking")), "automatic custom quest notices never open a blocking window")
	quest_notice.call("show_notification", {"title": "Test", "summary": "No popup"})
	_expect(not quest_notice.visible and not bool(game_state.get("ui_notice_blocking")), "automatic quest notices never open a blocking window")
	var backing := host.get_node_or_null("ObjectiveHudLayer/ObjectiveHud/ObjectiveBacking") as Control
	_expect(backing != null, "top-right quest HUD builds")
	if backing != null:
		_expect(is_zero_approx(backing.position.y), "quest HUD touches the top edge")
		_expect(backing.size.y <= 60.0, "quest HUD stays compact")
		var action_label := host.get_node("ObjectiveHudLayer/ObjectiveHud/ObjectiveAction") as Label
		_expect(action_label.size.y >= 16.0, "quest HUD keeps a full action line")
		_expect(backing.size.y + 0.5 >= action_label.position.y + action_label.size.y, "quest HUD backing ends at its content, without clipping it")

	game_state.set("circuit_soda_completed", true)
	game_state.set("prize_sort_completed", true)
	game_state.set("pip_prize_anecdote_seen", true)
	game_state.set("gus_hub_checkin_prize_sort_done", true)
	game_state.set("lost_shift_file_started", true)
	game_state.set("closing_shift_mira_clue_found", true)
	game_state.set("closing_shift_score_clue_found", true)
	game_state.set("closing_shift_service_clue_found", true)
	var gus_return_hint := ROUTE_CUE.get_current_hint("snack_alcove")
	_expect(gus_return_hint.contains("CABINET HALLWAY") and not gus_return_hint.contains("AFTER-HOURS"), "Service Dash routes back to Gus instead of the optional archive")

	game_state.set("lost_shift_file_completed", true)
	game_state.set("static_service_run_completed", true)
	game_state.set("maintenance_sync_completed", true)
	game_state.set("story_puzzle_completed", true)
	game_state.set("security_tape_assembly_completed", false)
	game_state.set("memory_echo_completed", false)
	quest_notice.call("set_location_context", "staff_corridor")
	quest_notice.call("refresh_objective_hud")
	var hud_action := host.get_node("ObjectiveHudLayer/ObjectiveHud/ObjectiveAction") as Label
	_expect(hud_action.text.replace("\n", " ") == "Take the NORTH exit to STAFF ROOM.", "Staff Corridor quest HUD routes north before mentioning the archive desk")
	var staff_corridor := (load("res://scenes/maps/StaffCorridor.tscn") as PackedScene).instantiate()
	var north_exit := staff_corridor.get_node("StaffRouteExit")
	_expect(str(north_exit.get("destination_name")) == "STAFF ROOM", "Staff Corridor north exit is labeled Staff Room")
	staff_corridor.free()

	var save_data: Dictionary = game_state.call("to_save_data")
	_expect(bool(save_data.get("route_cue_close_tip_seen", false)), "first-close tutorial state is saved")

	host.queue_free()
	await process_frame
	print("NavigationUiSmoke: %s" % ("PASS" if failures == 0 else "FAIL (%d)" % failures))
	quit(0 if failures == 0 else 1)


func _expect(condition: bool, label: String) -> void:
	if condition:
		print("PASS: %s" % label)
		return
	failures += 1
	push_error("FAIL: %s" % label)
