extends SceneTree

const GAME_STATE_SCRIPT := preload("res://scripts/GameState.gd")

var failure_count := 0
var game_state: Node = null

func _init() -> void:
	print("RequiredRouteStateSmoke: simulating expanded required route flags")
	game_state = GAME_STATE_SCRIPT.new()
	root.add_child(game_state)
	game_state.reset_for_new_game()
	_check_state("01 New Memory", "opening_talk_to_mira", "New Memory", "Grounded", 0)

	game_state.start_lost_token_quest()
	game_state.rockbyte_duel_completed = true
	game_state.collect_lost_token()
	_check_state("02 Rockbyte complete", "return_lost_token", "Lost Token Found", "Grounded", 1)

	game_state.complete_lost_token_quest()
	_check_state("03 Lost Token returned", "truth_filter", "Truth Filter", "Uneasy", 1)

	game_state.complete_truth_filter()
	_check_state("04 Truth Filter complete", "circuit_soda", "Truth Filter Cleared", "Fractured", 2)

	game_state.complete_circuit_soda()
	_check_state("05 Circuit Soda complete", "lost_shift_file", "Lost Shift File", "Fractured", 3)

	game_state.read_closing_checklist()
	game_state.read_maintenance_note()
	game_state.read_staff_schedule()
	_check_state("06 Lost Shift File complete", "static_service_run", "Static Service Run", "Fractured", 4)

	game_state.complete_static_service_run()
	_check_state("07 Static Service Run complete", "maintenance_sync", "Maintenance Sync", "Fractured", 5)

	game_state.complete_maintenance_sync()
	_check_state("08 Maintenance Sync complete", "security_tape_assembly", "Security Tape Assembly", "Overloaded", 6)

	game_state.complete_security_tape_assembly()
	_check_state("09 Security Tape complete", "final_night_walk", "Final Night Walk", "Overloaded", 7)

	game_state.complete_final_night_walk()
	_check_state("10 Final Night Walk complete", "stabilize_memory_echo", "Memory Echo", "Overloaded", 8)

	game_state.complete_memory_echo()
	_check_state("11 Memory Echo complete", "enter_staff_room", "Staff Room", "Overloaded", 9)

	game_state.mark_twist_reveal_seen()
	_check_state("12 Reveal complete", "finish_memory", "Truth Revealed", "Overloaded", 10)

	if failure_count == 0:
		print("RequiredRouteStateSmoke: PASS")
		quit(0)
		return
	print("RequiredRouteStateSmoke: FAIL failures=%d" % failure_count)
	quit(1)

func _check_state(label: String, expected_quest_id: String, expected_phase: String, expected_signal: String, expected_progress: int) -> void:
	var quest_id: String = game_state.get_current_quest_id()
	var phase: String = game_state.get_story_phase_label()
	var memory_signal: String = game_state.get_memory_signal_label()
	var progress: int = game_state.get_required_progress_count()
	print("%s | quest=%s | phase=%s | signal=%s | main=%d/%d" % [
		label,
		quest_id,
		phase,
		memory_signal,
		progress,
		game_state.get_total_required_progress_count(),
	])
	_expect(label, "quest", quest_id, expected_quest_id)
	_expect(label, "phase", phase, expected_phase)
	_expect(label, "signal", memory_signal, expected_signal)
	_expect(label, "required_progress", progress, expected_progress)

func _expect(label: String, field: String, actual: Variant, expected: Variant) -> void:
	if actual == expected:
		return
	failure_count += 1
	push_error("%s expected %s=%s but got %s" % [label, field, str(expected), str(actual)])
