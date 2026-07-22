extends SceneTree
# Walks every quest sub-stage in order and asserts the EXACT navigation hint
# shown in the room that matters, so each hint appears at its flag and hands
# off the moment the next flag flips.
# Run: godot --headless --script res://scripts/qa/NavigationPrecisionSmoke.gd --path <project>

const ROUTE_CUE := preload("res://scripts/RouteCue.gd")

var fails := 0
var started := false
var gs: Node = null

func _process(_delta: float) -> bool:
	if started:
		return true
	started = true
	_run()
	return true

func _run() -> void:
	print("NavigationPrecisionSmoke: exact hint per quest sub-stage")
	gs = root.get_node("GameState")
	gs.reset_for_new_game()

	_expect_hint("opening look", "arcade_hub", "LOCAL: Look around. Talk to whoever is still here.")
	gs.opening_hint_monologue_seen = true
	_expect_hint("opening go to Mira", "arcade_hub", "LOCAL: Talk to Mira at the ticket counter.")
	gs.start_lost_token_quest()
	_expect_hint("recover token", "arcade_hub", "LOCAL: Play Cabinet 07 on the main floor.")
	gs.rockbyte_duel_completed = true
	gs.collect_lost_token()
	_expect_hint("return token", "arcade_hub", "LOCAL: Return the Lost Token to Mira at the counter.")

	gs.complete_lost_token_quest()
	_expect_hint("meet Roxy first", "cabinet_row", "LOCAL: Talk to Roxy by the score cabinet.")
	gs.increment_npc_dialogue_count("roxy:broken_high_score_intro")
	_expect_hint("Roxy briefed -> board", "cabinet_row", "LOCAL: Use BROKEN SCORE, the top right cabinet.")

	gs.complete_broken_high_score()
	_expect_hint("meet Mr. Byte first", "cabinet_row", "LOCAL: Talk to Mr. Byte about the Truth Filter.")
	gs.increment_npc_dialogue_count("mr_byte_tf_explained")
	_expect_hint("Byte briefed -> filter", "cabinet_row", "LOCAL: Use the Truth Filter cabinet.")

	gs.complete_truth_filter()
	_expect_hint("debrief Mr. Byte", "cabinet_row", "LOCAL: Tell Mr. Byte what the Filter found.")
	gs.mr_byte_truth_filter_debriefed = true
	_expect_hint("Gus check-in one", "arcade_hub", "LOCAL: Talk to Gus on the arcade floor.")

	gs.gus_hub_checkin_truth_filter_done = true
	_expect_hint("meet Vendo first", "snack_alcove", "LOCAL: Talk to Vendo about Circuit Soda.")
	gs.increment_npc_dialogue_count("vendo_circuit_explained")
	_expect_hint("Vendo briefed -> machine", "snack_alcove", "LOCAL: Use the Circuit Soda machine.")

	gs.complete_circuit_soda()
	_expect_hint("Vendo debrief", "snack_alcove", "LOCAL: Talk to Vendo after Circuit Soda.")
	gs.vendo_circuit_anecdote_seen = true
	gs.mark_conscience_encounter_seen("after_circuit_soda")
	_expect_hint("ask about the voice", "snack_alcove", "LOCAL: Ask Vendo about the unknown voice.")

	gs.vendo_unknown_clue_seen = true
	_expect_hint("prize passage from alcove", "snack_alcove", "LOCAL: Take PRIZE SERVICE HALL, right wall past Circuit Soda.")
	_expect_hint("meet Pip first", "prize_corner", "LOCAL: Talk to Pip by the prize counter.")
	gs.pip_met = true
	_expect_hint("Pip briefed -> shelf", "prize_corner", "LOCAL: Use the shelf beside Pip.")
	gs.complete_pip_secret()
	_expect_hint("deliver Echo Token", "prize_corner", "LOCAL: Take the Echo Token to Pip.")

	gs.pip_prize_anecdote_seen = true
	_expect_hint("Gus check-in two", "arcade_hub", "LOCAL: Talk to Gus on the arcade floor.")

	gs.gus_hub_checkin_prize_sort_done = true
	gs.start_lost_shift_file()
	_expect_hint("shift clue one: Mira", "arcade_hub", "LOCAL: Ask Mira at the counter, top left.")
	gs.find_closing_shift_mira_clue()
	_expect_hint("shift clue two: score", "cabinet_row", "LOCAL: Read BROKEN SCORE, the top right cabinet.")
	gs.find_closing_shift_score_clue()
	_expect_hint("shift clue three: service", "snack_alcove", "LOCAL: Check SERVICE DASH, left of Vendo.")
	gs.find_closing_shift_service_clue()
	_expect_hint("report the echoes", "arcade_hub", "LOCAL: Report the echoes to Gus.")

	gs.complete_closing_shift_echoes()
	_expect_hint("meet Gus at workbench", "maintenance_hall", "LOCAL: Talk to Gus by the workbench, left side.")
	gs.increment_npc_dialogue_count("gus_static_intro")
	_expect_hint("Gus briefed -> sync machine", "maintenance_hall", "LOCAL: Run MAINTENANCE SYNC by the staff door.")

	gs.complete_static_service_run()
	_expect_hint("report after the descent", "maintenance_hall", "LOCAL: Report to Gus by the workbench.")

	gs.complete_maintenance_sync()
	_expect_hint("archive desk local", "staff_room", "LOCAL: Inspect the ARCHIVE DESK, left wall.")
	_expect_hint("staff route goes north", "maintenance_hall", "ROUTE: Take the STAFF ACCESS HALL to the north.")

	gs.complete_security_tape_assembly()
	_expect_hint("terminal local", "staff_room", "LOCAL: Use the TERMINAL at the back wall.")

	gs.mark_twist_reveal_seen()
	_expect_hint("finale is nav-free", "staff_room", "")
	gs.mark_conscience_final_room_seen()
	gs.unlock_post_reveal_roam()
	_expect_hint("post-game is nav-free (hub)", "arcade_hub", "")
	_expect_hint("post-game is nav-free (row)", "cabinet_row", "")

	if fails == 0:
		print("NavigationPrecisionSmoke: PASS")
		quit(0)
	else:
		print("NavigationPrecisionSmoke: FAIL (%d)" % fails)
		quit(1)

func _expect_hint(label: String, room: String, expected: String) -> void:
	var actual: String = ROUTE_CUE.get_current_hint(room)
	if actual == expected:
		print("  OK [%s]" % label)
		return
	fails += 1
	print("  FAIL [%s] in %s\n       expected: \"%s\"\n       actual:   \"%s\"" % [label, room, expected, actual])
