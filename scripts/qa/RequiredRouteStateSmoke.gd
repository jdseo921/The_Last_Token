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
	game_state.mark_conscience_encounter_seen("after_truth_filter")
	_expect("04b Conscience 1", "conscience_encounter_1_seen", game_state.conscience_encounter_1_seen, true)

	game_state.complete_circuit_soda()
	_check_state("05 Circuit Soda complete", "lost_shift_file", "Lost Shift File", "Fractured", 3)
	game_state.mark_conscience_encounter_seen("after_circuit_soda")
	_expect("05b Conscience 2", "conscience_encounter_2_seen", game_state.conscience_encounter_2_seen, true)

	game_state.read_closing_checklist()
	game_state.read_maintenance_note()
	game_state.read_staff_schedule()
	_check_state("06 Lost Shift File complete", "static_service_run", "Static Service Run", "Fractured", 4)
	game_state.mark_conscience_encounter_seen("after_lost_shift_file")
	_expect("06b Conscience 3", "conscience_encounter_3_seen", game_state.conscience_encounter_3_seen, true)

	game_state.complete_static_service_run()
	_check_state("07 Static Service Run complete", "maintenance_sync", "Maintenance Sync", "Fractured", 5)

	game_state.complete_maintenance_sync()
	_check_state("08 Maintenance Sync complete", "security_tape_assembly", "Security Tape Assembly", "Overloaded", 6)

	game_state.complete_security_tape_assembly()
	_check_state("09 Security Tape complete", "final_night_walk", "Final Night Walk", "Overloaded", 7)

	game_state.complete_final_night_walk()
	_check_state("10 Final Night Walk complete", "stabilize_memory_echo", "Memory Echo", "Overloaded", 8)
	game_state.mark_conscience_encounter_seen("after_final_night_walk")
	_expect("10b Conscience 4", "conscience_encounter_4_seen", game_state.conscience_encounter_4_seen, true)

	game_state.complete_memory_echo()
	_check_state("11 Memory Echo complete", "enter_staff_room", "Staff Room", "Overloaded", 9)

	game_state.mark_twist_reveal_seen()
	_check_state("12 Reveal slideshow complete", "finish_memory", "Truth Revealed", "Overloaded", 10)
	game_state.mark_conscience_final_room_seen()
	_check_state("12b Final Room Conscience complete", "finish_memory", "Truth Revealed", "Overloaded", 10)
	_expect("12b Final Room Conscience complete", "conscience_final_room_seen", game_state.conscience_final_room_seen, true)
	_expect("12b Final Room Conscience complete", "conscience_name_revealed", game_state.conscience_name_revealed, true)
	_expect("12b Final Room Conscience complete", "player_creator_monologue_seen", game_state.player_creator_monologue_seen, true)
	_expect("12b Final Room Conscience complete", "player_glitched_form_unlocked", game_state.player_glitched_form_unlocked, true)
	_expect("12b Final Room Conscience complete", "should_use_glitched_player_sprite", game_state.should_use_glitched_player_sprite(), true)

	game_state.unlock_post_reveal_roam()
	_check_state("13 Post-Reveal Roam", "talk_to_witnesses", "Post-Reveal Roam", "Restored", 10)
	_expect("13 Post-Reveal Roam", "quest_required", bool(game_state.get_current_quest_data().get("required", true)), false)
	_expect("13 Post-Reveal Roam", "witness_route_completed", game_state.witness_route_completed, false)
	_mark_core_witnesses()
	_expect("14 Core witnesses complete", "witness_route_completed", game_state.witness_route_completed, true)
	_expect("14 Core witnesses complete", "post_reveal_witness_route_completed", game_state.post_reveal_witness_route_completed, true)
	_expect("14 Core witnesses complete", "quest", game_state.get_current_quest_id(), "")
	_check_optional_witness_gate()

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

func _mark_core_witnesses() -> void:
	game_state.mark_witness_mira_heard()
	game_state.mark_witness_gus_heard()
	game_state.mark_witness_vendo_heard()
	game_state.mark_witness_mr_byte_heard()
	game_state.mark_witness_cabinet07_heard()

func _check_optional_witness_gate() -> void:
	game_state.reset_for_new_game()
	game_state.roxy_met = true
	game_state.pip_met = true
	_mark_core_witnesses()
	_expect("15 Optional witnesses met", "witness_route_completed", game_state.witness_route_completed, false)
	game_state.mark_witness_roxy_heard()
	_expect("15 Optional Roxy heard", "witness_route_completed", game_state.witness_route_completed, false)
	game_state.mark_witness_pip_heard()
	_expect("15 Optional Pip heard", "witness_route_completed", game_state.witness_route_completed, true)
