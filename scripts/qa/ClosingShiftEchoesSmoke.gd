extends SceneTree

const GAME_STATE_SCRIPT := preload("res://scripts/GameState.gd")
const CABINET_ROW_PATH := "res://scenes/maps/CabinetRow.tscn"
const ARCADE_HUB_PATH := "res://scenes/arcade/ArcadeHub.tscn"

var failures := 0

func _initialize() -> void:
	print("ClosingShiftEchoesSmoke: checking gated handoff and ordered evidence")
	var game_state := GAME_STATE_SCRIPT.new()
	root.add_child(game_state)
	game_state.reset_for_new_game()
	game_state.story_started = true
	game_state.circuit_soda_completed = true
	game_state.conscience_encounter_2_seen = true
	game_state.vendo_unknown_clue_seen = true
	game_state.complete_pip_secret()

	_expect(game_state.get_current_quest_id() == "prize_sort", "clearing Prize Echo still routes the token back to Pip")
	game_state.pip_prize_anecdote_seen = true
	_expect(game_state.get_current_quest_id() == "gus_checkin_prize_sort", "Pip's examination unlocks Gus Has a Lead")
	game_state.gus_hub_checkin_prize_sort_done = true
	game_state.start_lost_shift_file()
	_expect(game_state.get_current_quest_id() == "lost_shift_file", "Gus starts Closing Shift Echoes after explaining the lead")
	_expect(str(game_state.get_current_quest_data().get("title", "")) == "Closing Shift Echoes", "the investigation uses its new story-facing name")

	_expect(not game_state.find_closing_shift_score_clue(), "Broken Score cannot advance before Mira")
	_expect(not game_state.find_closing_shift_service_clue(), "Service Dash cannot advance before Broken Score")
	_expect(game_state.find_closing_shift_mira_clue(), "Mira supplies the first clue")
	_expect(game_state.find_closing_shift_score_clue(), "Broken Score supplies the second clue")
	_expect(game_state.find_closing_shift_service_clue(), "Service Dash supplies the third clue")
	_expect(not game_state.lost_shift_file_completed, "the third clue waits for a Gus debrief")
	_expect(game_state.complete_closing_shift_echoes(), "Gus can close the investigation after all clues")
	_expect(game_state.get_current_quest_id() == "static_service_run", "Gus sends the player to Static Service next")

	var cabinet_row := (load(CABINET_ROW_PATH) as PackedScene).instantiate()
	root.add_child(cabinet_row)
	var logs := cabinet_row.get_node_or_null("InteractableLayer/Logs")
	_expect(logs != null, "Cabinet Row contains the generated Logs interactable")
	_expect(cabinet_row.get_node_or_null("InteractableLayer/StaffSchedule") == null, "Staff Schedule overworld note is removed")
	_expect(cabinet_row.get_node_or_null("InteractableLayer/StaffRecord01") == null, "Record 01 overworld note is removed")
	if logs != null:
		var logs_label_offset: Vector2 = logs.get("label_offset")
		_expect(str(logs.get("label_text")) == "LOGS", "Logs has the requested label")
		_expect(int(logs.get("label_font_size")) == 12, "Logs label matches Mr. Byte's font size")
		_expect(absf(logs_label_offset.x) <= 2.0 and logs_label_offset.y >= 0.0, "Logs label is centered directly below the stack")
		_expect(str(logs.get("sprite_texture_path")) == "res://assets/art/props/logs_stack.png", "Logs uses the generated document art")
	cabinet_row.queue_free()

	var arcade_hub := (load(ARCADE_HUB_PATH) as PackedScene).instantiate()
	root.add_child(arcade_hub)
	_expect(arcade_hub.get_node_or_null("InteractableLayer/ClosingChecklist") == null, "Closing Checklist overworld note is removed")
	arcade_hub.queue_free()

	var prize_source := FileAccess.get_file_as_string("res://scripts/maps/PrizeCorner.gd")
	_expect(not prize_source.contains("GUS HAS A LEAD"), "Pip handoff no longer opens the large Gus quest window")
	_expect(not prize_source.contains("_show_gus_navigation_notice"), "retired quest-popup callback is removed")
	_expect(ResourceLoader.exists("res://assets/art/props/logs_stack.png"), "generated Logs texture imports successfully")

	print("ClosingShiftEchoesSmoke: %s" % ("PASS" if failures == 0 else "FAIL (%d)" % failures))
	quit(0 if failures == 0 else 1)

func _expect(condition: bool, label: String) -> void:
	if condition:
		print("PASS: %s" % label)
		return
	failures += 1
	push_error("FAIL: %s" % label)
