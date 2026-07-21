extends SceneTree

const GAME_STATE_SCRIPT := preload("res://scripts/GameState.gd")
const QUEST_REGISTRY := preload("res://scripts/QuestRegistry.gd")
const DIALOGUE_POOL := preload("res://scripts/DialoguePool.gd")

const REQUIRED_REGISTRY_ORDER := [
	"lost_token",
	"broken_high_score",
	"truth_filter",
	"circuit_soda",
	"prize_counter_secret",
	"lost_shift_file",
	"static_service_run",
	"maintenance_sync",
	"staff_corridor",
	"security_tape_assembly",
	"memory_echo",
]

const EXPECTED_PREREQUISITES := {
	"lost_token": "story_started",
	"broken_high_score": "lost_token_quest_completed",
	"truth_filter": "broken_high_score_completed",
	"circuit_soda": "gus_hub_checkin_truth_filter_done",
	"prize_counter_secret": "vendo_unknown_clue_seen",
	"lost_shift_file": "gus_hub_checkin_prize_sort_done",
	"static_service_run": "lost_shift_file_completed",
	"maintenance_sync": "static_service_run_completed",
	"staff_corridor": "maintenance_sync_completed",
	"security_tape_assembly": "maintenance_sync_completed",
	"memory_echo": "security_tape_assembly_completed",
}

var state: Node
var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	state = GAME_STATE_SCRIPT.new()
	root.add_child(state)
	state.reset_for_new_game()
	_check_registry_chain()
	_check_required_route_handoffs()
	_check_optional_route_isolation()
	_check_player_knowledge_pacing()
	_check_access_and_dialogue_gates()
	print("StorylineSanitySmoke: %s" % ("PASS" if failures == 0 else "FAIL (%d)" % failures))
	quit(0 if failures == 0 else 1)


func _check_registry_chain() -> void:
	var file := FileAccess.open("res://data/quests.json", FileAccess.READ)
	_expect(file != null, "quest registry file opens")
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	_expect(parsed is Dictionary, "quest registry JSON parses")
	if not parsed is Dictionary:
		return
	var quests: Dictionary = (parsed as Dictionary).get("quests", {})
	var actual_required: Array[String] = []
	for quest_id in quests.keys():
		var quest: Dictionary = quests[quest_id]
		if bool(quest.get("required", false)) and quest_id != "post_reveal_witness_route":
			actual_required.append(str(quest_id))
	_expect(actual_required == REQUIRED_REGISTRY_ORDER, "required quests are stored in playable order")
	for quest_id in EXPECTED_PREREQUISITES:
		var quest := QUEST_REGISTRY.get_quest(quest_id)
		_expect(not quest.is_empty(), "registry contains %s" % quest_id)
		_expect(str(quest.get("starts_after", "")) == EXPECTED_PREREQUISITES[quest_id], "%s has the correct prerequisite" % quest_id)
		_expect(not str(quest.get("title", "")).contains("Lost Shift File"), "%s has no retired player-facing quest title" % quest_id)


func _check_required_route_handoffs() -> void:
	_expect_quest("opening_look_around", "arrival begins with curiosity, not prior arcade knowledge")
	state.start_lost_token_quest()
	_expect_quest("recover_lost_token", "Mira sends the player to Cabinet 07")
	state.rockbyte_duel_completed = true
	state.collect_lost_token()
	_expect_quest("return_lost_token", "Rockbyte returns the player to Mira")
	state.complete_lost_token_quest()
	_expect_quest("broken_high_score", "Mira's return leads to Roxy and Broken Score")
	state.complete_broken_high_score()
	_expect_quest("truth_filter", "Broken Score leads to Mr. Byte and Truth Filter")
	state.complete_truth_filter()
	_expect_quest("mr_byte_debrief", "Truth Filter returns to Mr. Byte")
	state.mr_byte_truth_filter_debriefed = true
	_expect_quest("gus_checkin_truth_filter", "Mr. Byte's debrief leads to Gus")
	state.gus_hub_checkin_truth_filter_done = true
	_expect_quest("circuit_soda", "Gus sends the player to Vendo")
	state.complete_circuit_soda()
	_expect_quest("vendo_circuit_debrief", "Circuit Soda returns to Vendo")
	state.mark_conscience_encounter_seen("after_circuit_soda")
	_expect_quest("ask_vendo_about_unknown", "the unknown voice creates a Vendo follow-up")
	state.vendo_unknown_clue_seen = true
	_expect_quest("prize_sort", "Vendo points to Prize Corner")
	state.complete_pip_secret()
	_expect_quest("prize_sort", "Prize Echo returns to Pip before Gus")
	_expect(str(state.get_current_quest_data().get("summary", "")).contains("Pip"), "post-ascent objective explicitly names Pip")
	state.pip_prize_anecdote_seen = true
	_expect_quest("gus_checkin_prize_sort", "Pip's examination creates Gus Has a Lead")
	_expect(state.get_story_phase_label() == "Gus Has a Lead", "story phase distinguishes the Pip-to-Gus handoff")
	state.gus_hub_checkin_prize_sort_done = true
	state.start_lost_shift_file()
	_expect_quest("lost_shift_file", "Gus starts Closing Shift Echoes only after explaining the lead")
	_expect(not state.find_closing_shift_score_clue(), "Broken Score cannot be taken before Mira's clue")
	_expect(state.find_closing_shift_mira_clue(), "Mira supplies clue one")
	_expect(not state.find_closing_shift_service_clue(), "Service Dash cannot be taken before Broken Score")
	_expect(state.find_closing_shift_score_clue(), "Broken Score supplies clue two")
	_expect(state.find_closing_shift_service_clue(), "Service Dash supplies clue three")
	_expect_quest("lost_shift_file", "the evidence sequence still waits for Gus's debrief")
	_expect(state.complete_closing_shift_echoes(), "Gus can close the reconstructed sequence")
	_expect_quest("static_service_run", "Gus directs the player to restore service power")
	_expect(state.staff_corridor_unlocked, "Static Service Run opens the Staff Access Hall immediately")
	state.start_static_service_run()
	_expect(state.staff_corridor_unlocked, "starting Static Service Run releases the Staff Access Hall latch")
	var legacy_state := GAME_STATE_SCRIPT.new()
	legacy_state.reset_for_new_game()
	legacy_state.apply_save_data({"lost_shift_file_completed": true})
	_expect(legacy_state.staff_corridor_unlocked, "older Static Service saves restore the Staff Access Hall latch")
	legacy_state.free()
	state.complete_static_service_run()
	_expect_quest("maintenance_sync", "restored power leads to Maintenance Sync")
	state.complete_maintenance_sync()
	_expect_quest("security_tape_assembly", "the Staff Door opens onto Security Tape")
	state.complete_security_tape_assembly()
	_expect_quest("enter_staff_room", "the assembled tape hands directly to the Staff Room terminal")
	# The Staff Room owns the direct tape-to-terminal handoff. These flags remain
	# for compatibility with pre-handoff saves and archival replay scenes.
	state.complete_memory_echo()
	_expect_quest("enter_staff_room", "Memory Echo opens the Staff Room reveal")
	state.mark_twist_reveal_seen()
	_expect_quest("finish_memory", "the reveal waits for the final self-conflict")
	state.mark_conscience_final_room_seen()
	state.unlock_post_reveal_roam()
	_expect_quest("talk_to_witnesses", "integration opens the optional post-reveal witness route")


func _check_optional_route_isolation() -> void:
	state.reset_for_new_game()
	state.start_lost_token_quest()
	state.rockbyte_duel_completed = true
	state.complete_lost_token_quest()
	state.complete_broken_high_score()
	state.complete_truth_filter()
	state.mr_byte_truth_filter_debriefed = true
	state.gus_hub_checkin_truth_filter_done = true
	state.complete_circuit_soda()
	var quest_before: String = str(state.get_current_quest_id())
	state.complete_night_ledger_run()
	_expect(state.get_current_quest_id() == quest_before, "Night Ledger never advances or replaces the required route")
	_expect(state.get_optional_games_completed_count() == 1, "Night Ledger records optional completion separately")


func _check_player_knowledge_pacing() -> void:
	var opening := _dialogue_text("mira", "opening_first_meeting")
	_expect(opening.contains("I do not recognize this place"), "opening establishes the player's missing knowledge")
	var early_vendo := _dialogue_text("vendo", "early_flavor").to_lower()
	_expect(early_vendo.contains("returning staff") and early_vendo.contains("first visit"), "Vendo contrasts recognition with the player's first-visit belief")
	var gus_lead := _dialogue_text("gus", "hub_checkin_prize_sort")
	_expect(gus_lead.contains("not certain who saw which part") and gus_lead.contains("Start with Mira"), "Gus avoids overclaiming and recommends only the first witness")
	var pip_handoff := _dialogue_text("pip", "prize_sort_completion")
	_expect(pip_handoff.contains("Neither remembers a whole owner alone") and pip_handoff.contains("shift code gives Gus something real to trace"), "Pip joins identity evidence to Gus's concrete lead without resolving the twist")


func _check_access_and_dialogue_gates() -> void:
	var hub := (load("res://scenes/arcade/ArcadeHub.tscn") as PackedScene).instantiate()
	var maintenance_exit := hub.get_node("InteractableLayer/ToMaintenanceHall")
	_expect(str(maintenance_exit.get("required_flag")) == "lost_shift_file_completed", "Maintenance Hallway opens exactly when Closing Shift Echoes is debriefed")
	_expect("COMPLETE THE REQUIRED TASKS FIRST." in maintenance_exit.get("locked_dialogue"), "locked Maintenance Hallway avoids premature requirement spoilers")
	_expect(not hub.has_node("InteractableLayer/TicketCounter"), "Mira has no overlapping invisible ticket-counter interaction")
	hub.free()
	var gus_debrief := _dialogue_text("gus", "closing_shift_echoes_debrief")
	_expect(gus_debrief.contains("unlocked the Maintenance Hallway"), "Gus explicitly confirms that Maintenance access is open")
	var hub_source := FileAccess.get_file_as_string("res://scripts/ArcadeHub.gd")
	var staff_start := hub_source.find("func _handle_staff_door()")
	var staff_end := hub_source.find("func _handle_owner_portrait()", staff_start)
	var staff_handler := hub_source.substr(staff_start, staff_end - staff_start)
	_expect(staff_handler.contains("EMPLOYEE SIGNAL TOO WEAK TO READ") and not staff_handler.contains("CIRCUIT SODA ROUTE REQUIRED"), "early Staff Door dialogue stays generic until prerequisites are complete")
	_expect(not hub_source.contains("if GameState.lying_cabinets_completed and not GameState.story_puzzle_completed"), "NPC repeats cannot jump from Truth Filter directly to Staff Door guidance")
	_expect(not hub_source.contains("_get_ticket_counter_echo_lines"), "Mira dialogue cannot be diverted into the removed narrator echo")


func _dialogue_text(character_id: String, set_id: String) -> String:
	var pieces: Array[String] = []
	for line_value in DIALOGUE_POOL.get_lines(character_id, set_id):
		if line_value is Dictionary:
			pieces.append(str((line_value as Dictionary).get("text", "")))
	return "\n".join(pieces)


func _expect_quest(expected: String, label: String) -> void:
	_expect(state.get_current_quest_id() == expected, "%s (%s)" % [label, expected])


func _expect(condition: bool, label: String) -> void:
	if condition:
		print("PASS: %s" % label)
		return
	failures += 1
	push_error("FAIL: %s" % label)
