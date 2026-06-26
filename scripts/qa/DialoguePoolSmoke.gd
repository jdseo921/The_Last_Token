extends SceneTree

const DIALOGUE_POOL := preload("res://scripts/DialoguePool.gd")

var failure_count := 0

func _init() -> void:
	print("DialoguePoolSmoke: checking reusable dialogue pool")
	_expect_first_text("mira first set", DIALOGUE_POOL.get_lines("mira", "opening_first_meeting"), "You made it back.")
	_expect_first_text("mira quest instruction", DIALOGUE_POOL.get_lines("mira", "lost_token_quest_instruction"), "Cabinet 07 has your Lost Token.")
	_expect_first_text("mira token anecdote", DIALOGUE_POOL.get_lines("mira", "lost_token_return_anecdote"), "You brought it back.")
	_expect_first_text("mira truth filter transition", DIALOGUE_POOL.get_lines("mira", "truth_filter_transition"), "The token woke something.")
	_expect_first_text("mira circuit soda transition", DIALOGUE_POOL.get_lines("mira", "circuit_soda_transition"), "Your Memory Signal is Fractured now.")
	_expect_first_text("mira lost shift dialogue", DIALOGUE_POOL.get_lines("mira", "lost_shift_file_dialogue"), "The records are waking up now.")
	_expect_first_text("mira pre staff room", DIALOGUE_POOL.get_lines("mira", "overloaded_pre_staff_room"), "The signal is loud now.")
	_expect_first_text("mira post reveal witness", DIALOGUE_POOL.get_lines("mira", "post_reveal_witness"), "Employee 04.")
	_expect_contains_text("mira post reveal witness", DIALOGUE_POOL.get_lines("mira", "post_reveal_witness"), "I felt guilty for waiting.")
	_expect_first_text("gus early flavor", DIALOGUE_POOL.get_lines("gus", "pre_lost_token_flavor"), "You again. Great.")
	_expect_first_text("gus truth filter", DIALOGUE_POOL.get_lines("gus", "truth_filter_active"), "Careful now.")
	_expect_first_text("gus circuit soda", DIALOGUE_POOL.get_lines("gus", "circuit_soda_active"), "Signal's fractured.")
	_expect_first_text("gus lost shift", DIALOGUE_POOL.get_lines("gus", "lost_shift_file_phase"), "The maintenance note is ugly.")
	_expect_first_text("gus static intro", DIALOGUE_POOL.get_lines("gus", "static_service_run_intro"), "The file gives me enough to work with.")
	_expect_first_text("gus static anecdote", DIALOGUE_POOL.get_lines("gus", "static_service_run_anecdote"), "Power's back.")
	_expect_first_text("gus sync intro", DIALOGUE_POOL.get_lines("gus", "maintenance_sync_intro"), "Power's back. Door's listening.")
	_expect_first_text("gus sync anecdote", DIALOGUE_POOL.get_lines("gus", "maintenance_sync_completion_anecdote"), "Door's listening now.")
	_expect_contains_text("gus sync anecdote", DIALOGUE_POOL.get_lines("gus", "maintenance_sync_completion_anecdote"), "Door heard both knocks.")
	_expect_contains_text("gus sync anecdote", DIALOGUE_POOL.get_lines("gus", "maintenance_sync_completion_anecdote"), "Yours, and the one you forgot making.")
	_expect_first_text("gus post reveal", DIALOGUE_POOL.get_lines("gus", "post_reveal_witness"), "Employee 04.")
	_expect_contains_text("gus post reveal", DIALOGUE_POOL.get_lines("gus", "post_reveal_witness"), "I recognized pieces of the old you.")
	_expect_first_text("vendo early flavor", DIALOGUE_POOL.get_lines("vendo", "early_flavor"), "Welcome, valued almost-customer.")
	_expect_first_text("vendo riddle setup", DIALOGUE_POOL.get_lines("vendo", "memory_cola_riddle_setup"), "Initiating beverage-based psychological evaluation.")
	_expect_first_text("vendo wrong answer", DIALOGUE_POOL.get_lines("vendo", "memory_cola_wrong_answers"), "Incorrect.")
	_expect_first_text("vendo correct answer", DIALOGUE_POOL.get_lines("vendo", "memory_cola_correct"), "Correct.")
	_expect_first_text("vendo truth filter", DIALOGUE_POOL.get_lines("vendo", "truth_filter_active"), "Memory Signal: Uneasy.")
	_expect_first_text("vendo circuit intro", DIALOGUE_POOL.get_lines("vendo", "circuit_soda_intro"), "Memory Signal: Fractured.")
	_expect_first_text("vendo circuit hint", DIALOGUE_POOL.get_lines("vendo", "circuit_soda_repeat_hint"), "Circuit Soda remains available.")
	_expect_contains_text("vendo circuit anecdote", DIALOGUE_POOL.get_lines("vendo", "circuit_soda_completion_anecdote"), "Receipt says: identity routed successfully.")
	_expect_first_text("vendo overloaded", DIALOGUE_POOL.get_lines("vendo", "overloaded_phase"), "The Staff Room is close enough that my display is trying not to flicker.")
	_expect_first_text("vendo post reveal", DIALOGUE_POOL.get_lines("vendo", "post_reveal_witness"), "Employee 04.")
	_expect_contains_text("vendo post reveal", DIALOGUE_POOL.get_lines("vendo", "post_reveal_witness"), "System note: not just a stored file.")
	_expect_contains_text("vendo post reveal", DIALOGUE_POOL.get_lines("vendo", "post_reveal_witness"), "Status note: warranty voided by existential damage.")
	_expect_first_text("mr byte locked", DIALOGUE_POOL.get_lines("mr_byte", "pre_truth_filter_locked"), "TRUTH FILTER LOCKED.")
	_expect_first_text("mr byte intro", DIALOGUE_POOL.get_lines("mr_byte", "truth_filter_intro"), "Contradiction threshold reached.")
	_expect_first_text("mr byte completion", DIALOGUE_POOL.get_lines("mr_byte", "truth_filter_completion_anecdote"), "Truth Filter passed.")
	_expect_first_text("mr byte lost shift", DIALOGUE_POOL.get_lines("mr_byte", "lost_shift_file_support"), "Lost Shift File access opened.")
	_expect_first_text("mr byte security tape", DIALOGUE_POOL.get_lines("mr_byte", "security_tape_support"), "Security tape fragments detected.")
	_expect_first_text("mr byte records", DIALOGUE_POOL.get_lines("mr_byte", "staff_records_chain"), "Staff record chain active.")
	_expect_first_text("mr byte post reveal", DIALOGUE_POOL.get_lines("mr_byte", "post_reveal_witness"), "Employee 04.")
	_expect_contains_text("mr byte post reveal", DIALOGUE_POOL.get_lines("mr_byte", "post_reveal_witness"), "Conflict thread archived.")
	_expect_first_text("cabinet 07 pre rockbyte", DIALOGUE_POOL.get_lines("cabinet_07", "pre_rockbyte"), "CUSTOMER SIGNAL: UNKNOWN.")
	_expect_first_text("cabinet 07 rockbyte complete", DIALOGUE_POOL.get_lines("cabinet_07", "rockbyte_completion"), "TOKEN RECOVERED.")
	_expect_first_text("cabinet 07 truth phase", DIALOGUE_POOL.get_lines("cabinet_07", "truth_filter_phase_echo"), "TOKEN RETURNED.")
	_expect_first_text("cabinet 07 fractured", DIALOGUE_POOL.get_lines("cabinet_07", "fractured_echo"), "MEMORY SIGNAL: FRACTURED.")
	_expect_first_text("cabinet 07 overloaded", DIALOGUE_POOL.get_lines("cabinet_07", "overloaded_echo"), "MEMORY SIGNAL: OVERLOADED.")
	_expect_first_text("cabinet 07 post reveal", DIALOGUE_POOL.get_lines("cabinet_07", "post_reveal_status"), "EMPLOYEE 04 RESTORE STATUS: STABLE.")
	_expect_contains_text("cabinet 07 post reveal", DIALOGUE_POOL.get_lines("cabinet_07", "post_reveal_status"), "CURRENT SESSION: YOURS.")
	_expect_first_text("roxy locked", DIALOGUE_POOL.get_lines("roxy", "first_meeting_locked"), "Whoa. New challenger detected.")
	_expect_first_text("roxy intro", DIALOGUE_POOL.get_lines("roxy", "broken_high_score_intro"), "Finally. Player Two showed up.")
	_expect_first_text("roxy hint", DIALOGUE_POOL.get_lines("roxy", "broken_high_score_hint"), "Hint one: 9999 is nonsense.")
	_expect_contains_text("roxy completion", DIALOGUE_POOL.get_lines("roxy", "broken_high_score_completion"), "The name stayed blank.")
	_expect_first_text("roxy repeat", DIALOGUE_POOL.get_lines("roxy", "repeat_after_completion"), "Your score is back.")
	_expect_first_text("roxy post reveal", DIALOGUE_POOL.get_lines("roxy", "post_reveal"), "So you were Employee 04.")
	_expect_first_text("pip first meeting", DIALOGUE_POOL.get_lines("pip", "first_meeting"), "Hi! I am a legally distinct prize animal.")
	_expect_first_text("pip after token", DIALOGUE_POOL.get_lines("pip", "after_lost_token"), "You brought the Lost Token back.")
	_expect_first_text("pip prize intro", DIALOGUE_POOL.get_lines("pip", "prize_sort_intro"), "Prize Sort is ready.")
	_expect_first_text("pip wrong", DIALOGUE_POOL.get_lines("pip", "prize_sort_wrong"), "Those memories are wearing each other's hats.")
	_expect_contains_text("pip completion", DIALOGUE_POOL.get_lines("pip", "prize_sort_completion"), "Some rewards remember their owners before the owners remember them.")
	_expect_contains_text("pip post reveal", DIALOGUE_POOL.get_lines("pip", "post_reveal"), "Yep. Still not the original.")
	_expect_first_text("environment first set", DIALOGUE_POOL.get_lines("environment_objects", "ticket_counter"), "The ticket counter glass reflects old prize lights.")
	_expect_first_text("environment ticket grounded", DIALOGUE_POOL.get_lines("environment_objects", "ticket_counter_grounded"), "The ticket counter glass reflects old prize lights.")
	_expect_contains_text("environment ticket fractured", DIALOGUE_POOL.get_lines("environment_objects", "ticket_counter_fractured"), "It mouths: not the first.")
	_expect_first_text("environment portrait grounded", DIALOGUE_POOL.get_lines("environment_objects", "owner_portrait_grounded"), "A dusty portrait hangs above the arcade floor.")
	_expect_contains_text("environment portrait fractured", DIALOGUE_POOL.get_lines("environment_objects", "owner_portrait_fractured"), "Two marks seem to repeat: 0 and 4.")
	_expect_contains_text("environment portrait restored", DIALOGUE_POOL.get_lines("environment_objects", "owner_portrait_restored"), "It says: EMPLOYEE 04.")
	_expect_first_text("environment broken cabinet", DIALOGUE_POOL.get_lines("environment_objects", "broken_cabinet_grounded"), "The cabinet is dark.")
	_expect_first_text("environment checklist", DIALOGUE_POOL.get_lines("environment_objects", "closing_checklist_fractured"), "CLOSING CHECKLIST")
	_expect_first_text("environment maintenance note", DIALOGUE_POOL.get_lines("environment_objects", "maintenance_note_fractured"), "MAINTENANCE NOTE")
	_expect_first_text("environment staff schedule", DIALOGUE_POOL.get_lines("environment_objects", "staff_schedule_fractured"), "STAFF SCHEDULE")
	_expect_first_text("environment staff records", DIALOGUE_POOL.get_lines("environment_objects", "staff_records_fractured"), "RESTORE SYSTEM NOTE")
	_expect_first_text("environment truth filter", DIALOGUE_POOL.get_lines("environment_objects", "truth_filter_machine_uneasy"), "CONTRADICTION THRESHOLD REACHED.")
	_expect_first_text("environment circuit soda", DIALOGUE_POOL.get_lines("environment_objects", "circuit_soda_machine_fractured"), "MEMORY FLOW UNROUTED.")
	_expect_contains_text("environment sync circuit lock", DIALOGUE_POOL.get_lines("environment_objects", "maintenance_sync_machine_circuit_required"), "CIRCUIT SODA REQUIRED.")
	_expect_contains_text("environment sync static lock", DIALOGUE_POOL.get_lines("environment_objects", "maintenance_sync_machine_static_service_required"), "STATIC SERVICE REQUIRED.")
	_expect_first_text("environment security tape", DIALOGUE_POOL.get_lines("environment_objects", "security_tape_terminal_overloaded"), "SECURITY TAPE DAMAGED.")
	_expect_first_text("environment final walk", DIALOGUE_POOL.get_lines("environment_objects", "final_night_walk_terminal_overloaded"), "TAPE ORDER RESTORED.")
	_expect_contains_text("environment echo maintenance lock", DIALOGUE_POOL.get_lines("environment_objects", "memory_echo_object_maintenance_required"), "MAINTENANCE SYNC REQUIRED.")
	_expect_contains_text("environment echo security lock", DIALOGUE_POOL.get_lines("environment_objects", "memory_echo_object_security_tape_required"), "SECURITY TAPE REQUIRED.")
	_expect_contains_text("environment echo final lock", DIALOGUE_POOL.get_lines("environment_objects", "memory_echo_object_final_night_required"), "FINAL NIGHT WALK REQUIRED.")
	_expect_first_text("environment staff room terminal", DIALOGUE_POOL.get_lines("environment_objects", "staff_room_terminal_available"), "Employee file recovered.")
	_expect_first_text("environment employee file", DIALOGUE_POOL.get_lines("environment_objects", "employee_04_file_archived"), "EMPLOYEE 04 // STATUS: ARCHIVED RESTORE PROFILE.")
	_expect_first_text("environment prize counter", DIALOGUE_POOL.get_lines("environment_objects", "prize_counter_fractured"), "Three labels sit loose under the glass.")
	_expect_first_text("staff door grounded", DIALOGUE_POOL.get_lines("staff_door", "locked_grounded"), "ACCESS DENIED.")
	_expect_contains_text("staff door grounded", DIALOGUE_POOL.get_lines("staff_door", "locked_grounded"), "REQUIRED: SPEAK TO MIRA.")
	_expect_contains_text("staff door truth", DIALOGUE_POOL.get_lines("staff_door", "truth_filter_required"), "REQUIRED: TRUTH FILTER.")
	_expect_contains_text("staff door maintenance", DIALOGUE_POOL.get_lines("staff_door", "maintenance_required"), "REQUIRED: CIRCUIT SODA.")
	_expect_contains_text("staff door security", DIALOGUE_POOL.get_lines("staff_door", "security_tape_required"), "REQUIRED: SECURITY TAPE ASSEMBLY.")
	_expect_contains_text("staff door final night", DIALOGUE_POOL.get_lines("staff_door", "final_night_walk_required"), "REQUIRED: FINAL NIGHT WALK.")
	_expect_contains_text("staff door echo", DIALOGUE_POOL.get_lines("staff_door", "memory_echo_required"), "REQUIRED: MEMORY ECHO.")
	_expect_first_text("staff door available", DIALOGUE_POOL.get_lines("staff_door", "staff_room_available"), "ACCESS GRANTED.")
	_expect_first_text("staff door post reveal", DIALOGUE_POOL.get_lines("staff_door", "post_reveal_stable"), "RESTORE PLAYBACK COMPLETE.")
	_expect_first_text("missing key fallback", DIALOGUE_POOL.get_lines("mira", "missing_key", _fallback_lines()), "Fallback line.")
	_expect_first_text("missing file fallback", DIALOGUE_POOL.get_random_set("missing_character", "missing_key", _fallback_lines()), "Fallback line.")
	if failure_count == 0:
		print("DialoguePoolSmoke: PASS")
		quit(0)
		return
	print("DialoguePoolSmoke: FAIL failures=%d" % failure_count)
	quit(1)

func _fallback_lines() -> Array:
	return [{"speaker": "Fallback", "text": "Fallback line."}]

func _expect_non_empty(label: String, lines: Array) -> void:
	if not lines.is_empty():
		return
	_fail("%s expected non-empty dialogue lines" % label)

func _expect_first_text(label: String, lines: Array, expected_text: String) -> void:
	if lines.is_empty():
		_fail("%s expected first text %s but got empty lines" % [label, expected_text])
		return
	var first_line_value: Variant = lines[0]
	if not first_line_value is Dictionary:
		_fail("%s expected first line to be Dictionary" % label)
		return
	var first_line := first_line_value as Dictionary
	var actual_text := str(first_line.get("text", ""))
	if actual_text == expected_text:
		return
	_fail("%s expected first text %s but got %s" % [label, expected_text, actual_text])

func _expect_contains_text(label: String, lines: Array, expected_text: String) -> void:
	for line_value: Variant in lines:
		if not line_value is Dictionary:
			continue
		var line := line_value as Dictionary
		if str(line.get("text", "")) == expected_text:
			return
	_fail("%s expected to contain text %s" % [label, expected_text])

func _fail(message: String) -> void:
	failure_count += 1
	push_error(message)
