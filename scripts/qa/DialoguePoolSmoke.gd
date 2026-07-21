extends SceneTree

const DIALOGUE_POOL := preload("res://scripts/DialoguePool.gd")

var failure_count := 0

func _init() -> void:
	print("DialoguePoolSmoke: checking reusable dialogue pool")
	_expect_first_text("mira first set", DIALOGUE_POOL.get_lines("mira", "opening_first_meeting"), "You came in. It really is you.")
	_expect_first_text("mira quest instruction", DIALOGUE_POOL.get_lines("mira", "lost_token_quest_instruction"), "Cabinet 07 has been holding your Lost Token. It keeps things the way this place keeps everything: a little too long, and a little too tightly.")
	_expect_player_text("mira quest comedy", DIALOGUE_POOL.get_lines("mira", "lost_token_quest_instruction"), "(I walk into a closed arcade, get recognized by someone I have never met, and immediately receive an errand. Curiosity has consequences.)")
	_expect_first_text("mira token anecdote", DIALOGUE_POOL.get_lines("mira", "lost_token_return_anecdote"), "You brought it back.")
	_expect_first_text("mira truth filter transition", DIALOGUE_POOL.get_lines("mira", "truth_filter_transition"), "The token woke something.")
	_expect_first_text("mira circuit soda transition", DIALOGUE_POOL.get_lines("mira", "circuit_soda_transition"), "The arcade is remembering louder now.")
	_expect_first_text("mira closing shift clue", DIALOGUE_POOL.get_lines("mira", "closing_shift_echoes_clue"), "The final shift? I locked this counter before midnight.")
	_expect_first_text("mira pre staff room", DIALOGUE_POOL.get_lines("mira", "overloaded_pre_staff_room"), "The signal is loud now.")
	_expect_first_text("mira post reveal witness", DIALOGUE_POOL.get_lines("mira", "post_reveal_witness"), "Employee 04.")
	_expect_contains_text("mira post reveal witness", DIALOGUE_POOL.get_lines("mira", "post_reveal_witness"), "I felt guilty for waiting.")
	_expect_first_text("gus early flavor", DIALOGUE_POOL.get_lines("gus", "pre_lost_token_flavor"), "You again. Great. Except you are looking at me like a stranger.")
	_expect_first_text("gus truth filter", DIALOGUE_POOL.get_lines("gus", "truth_filter_active"), "Careful now.")
	_expect_first_text("gus circuit soda", DIALOGUE_POOL.get_lines("gus", "circuit_soda_active"), "Signal's fractured.")
	_expect_first_text("gus closing shift followup", DIALOGUE_POOL.get_lines("gus", "closing_shift_maintenance_followup"), "You made it. I pulled the closing sequence apart again.")
	_expect_first_text("gus static intro", DIALOGUE_POOL.get_lines("gus", "static_service_run_intro"), "You read the file. I can tell.")
	_expect_first_text("gus static anecdote", DIALOGUE_POOL.get_lines("gus", "static_service_run_anecdote"), "Power's back.")
	_expect_first_text("gus sync intro", DIALOGUE_POOL.get_lines("gus", "maintenance_sync_intro"), "Power's back. Door's listening.")
	_expect_player_text("gus sync comedy", DIALOGUE_POOL.get_lines("gus", "maintenance_sync_intro"), "(A vending machine missed me. Now a door is listening. I am still deciding how I feel about being noticed.)")
	_expect_first_text("gus sync anecdote", DIALOGUE_POOL.get_lines("gus", "maintenance_sync_completion_anecdote"), "Door's listening now.")
	_expect_contains_text("gus sync anecdote", DIALOGUE_POOL.get_lines("gus", "maintenance_sync_completion_anecdote"), "It matched you against something in its log.")
	_expect_contains_text("gus sync anecdote", DIALOGUE_POOL.get_lines("gus", "maintenance_sync_completion_anecdote"), "Some doors grieve. This one files it under access control.")
	_expect_first_text("gus hub checkin 1", DIALOGUE_POOL.get_lines("gus", "hub_checkin_truth_filter"), "Gus. Has anything been talking in the hallways tonight?")
	_expect_contains_text("gus hub checkin 1 clueless", DIALOGUE_POOL.get_lines("gus", "hub_checkin_truth_filter"), "It is a loose ground wire and forty years of nobody caring.")
	_expect_first_text("roxy tf nudge", DIALOGUE_POOL.get_lines("roxy", "truth_filter_completion_nudge"), "Huh. The Filter actually shut up for once.")
	_expect_first_text("mr byte voice debrief", DIALOGUE_POOL.get_lines("mr_byte", "truth_filter_voice_debrief"), "Additional finding: the hallway broadcast had no registered speaker.")
	var byte_completion := DIALOGUE_POOL.get_lines("mr_byte", "truth_filter_completion_anecdote")
	var byte_voice := DIALOGUE_POOL.get_lines("mr_byte", "truth_filter_voice_debrief")
	if byte_completion.size() + byte_voice.size() > 5:
		_fail("mr byte truth-filter debrief should stay at five lines or fewer")
	_expect_first_text("gus hub checkin 2", DIALOGUE_POOL.get_lines("gus", "hub_checkin_prize_sort"), "Pip found a closing-shift code beneath the prize paint. They thought you might recognize it.")
	_expect_line_contains("gus uncertain witness route", DIALOGUE_POOL.get_lines("gus", "hub_checkin_prize_sort"), "not certain who saw which part")
	_expect_line_contains("gus recommends Mira first", DIALOGUE_POOL.get_lines("gus", "hub_checkin_prize_sort"), "Start with Mira")
	_expect_line_contains("gus notices subconscious route memory", DIALOGUE_POOL.get_lines("gus", "closing_shift_echoes_debrief"), "remembering how to move through this place")
	_expect_line_contains("gus surprised by recovered chain", DIALOGUE_POOL.get_lines("gus", "closing_shift_echoes_debrief"), "I only knew to send you to Mira")
	_expect_line_contains("pip explains identity evidence", DIALOGUE_POOL.get_lines("pip", "prize_sort_completion"), "connects their hopeful memories to you")
	_expect_line_contains("pip explains Gus lead", DIALOGUE_POOL.get_lines("pip", "prize_sort_completion"), "shift code gives Gus something real to trace")
	_expect_first_text("gus post reveal", DIALOGUE_POOL.get_lines("gus", "post_reveal_witness"), "Employee 04.")
	_expect_contains_text("gus post reveal", DIALOGUE_POOL.get_lines("gus", "post_reveal_witness"), "I recognized pieces of the old you.")
	_expect_first_text("vendo early flavor", DIALOGUE_POOL.get_lines("vendo", "early_flavor"), "Welcome, valued almost-customer.")
	_expect_first_text("vendo riddle setup", DIALOGUE_POOL.get_lines("vendo", "memory_cola_riddle_setup"), "Initiating beverage-based psychological evaluation.")
	_expect_first_text("vendo wrong answer", DIALOGUE_POOL.get_lines("vendo", "memory_cola_wrong_answers"), "Incorrect.")
	_expect_first_text("vendo correct answer", DIALOGUE_POOL.get_lines("vendo", "memory_cola_correct"), "Correct.")
	_expect_first_text("vendo truth filter", DIALOGUE_POOL.get_lines("vendo", "truth_filter_active"), "Scanner mood: uneasy.")
	_expect_first_text("vendo circuit intro", DIALOGUE_POOL.get_lines("vendo", "circuit_soda_intro"), "Welcome back to the only machine that missed you.")
	_expect_player_text("vendo circuit comedy", DIALOGUE_POOL.get_lines("vendo", "circuit_soda_intro"), "(A vending machine missed me. I am filing that under things to panic about later.)")
	_expect_first_text("vendo circuit hint", DIALOGUE_POOL.get_lines("vendo", "circuit_soda_repeat_hint"), "Circuit Soda remains available.")
	_expect_first_text("vendo circuit debrief", DIALOGUE_POOL.get_lines("vendo", "circuit_soda_completion_anecdote"), "Signal routed. Receipt says: identity recognized, label unavailable.")
	_expect_first_text("vendo unknown voice clue", DIALOGUE_POOL.get_lines("vendo", "unknown_voice_clue"), "Something spoke through the static after Circuit Soda. Any idea what it was?")
	_expect_contains_text("vendo prize service directions", DIALOGUE_POOL.get_lines("vendo", "unknown_voice_clue"), "Prize Service Hall is the passage in the right wall, just past Circuit Soda.")
	_expect_first_text("vendo overloaded", DIALOGUE_POOL.get_lines("vendo", "overloaded_phase"), "The Staff Room is close enough that my display is trying not to flicker.")
	_expect_first_text("vendo post reveal", DIALOGUE_POOL.get_lines("vendo", "post_reveal_witness"), "Employee 04.")
	_expect_contains_text("vendo post reveal", DIALOGUE_POOL.get_lines("vendo", "post_reveal_witness"), "The room recognized you because you were here, not because it rebuilt you.")
	_expect_contains_text("vendo post reveal", DIALOGUE_POOL.get_lines("vendo", "post_reveal_witness"), "Status note: warranty voided by existential damage.")
	_expect_first_text("mr byte locked", DIALOGUE_POOL.get_lines("mr_byte", "pre_truth_filter_locked"), "TRUTH FILTER LOCKED.")
	_expect_first_text("mr byte intro", DIALOGUE_POOL.get_lines("mr_byte", "truth_filter_intro"), "Contradiction threshold reached.")
	_expect_first_text("mr byte completion", DIALOGUE_POOL.get_lines("mr_byte", "truth_filter_completion_anecdote"), "Truth Filter passed.")
	_expect_first_text("mr byte closing shift", DIALOGUE_POOL.get_lines("mr_byte", "closing_shift_echoes_support"), "Closing-shift evidence route detected.")
	_expect_first_text("mr byte security tape", DIALOGUE_POOL.get_lines("mr_byte", "security_tape_support"), "Security tape fragments detected.")
	_expect_first_text("mr byte records", DIALOGUE_POOL.get_lines("mr_byte", "staff_records_chain"), "Staff record chain active.")
	_expect_first_text("mr byte post reveal", DIALOGUE_POOL.get_lines("mr_byte", "post_reveal_witness"), "Employee 04.")
	_expect_contains_text("mr byte post reveal", DIALOGUE_POOL.get_lines("mr_byte", "post_reveal_witness"), "Conflict thread archived.")
	_expect_first_text("cabinet 07 pre rockbyte", DIALOGUE_POOL.get_lines("cabinet_07", "pre_rockbyte"), "CUSTOMER SIGNAL: UNKNOWN.")
	_expect_first_text("cabinet 07 rockbyte player handoff", DIALOGUE_POOL.get_lines("cabinet_07", "rockbyte_completion"), "The cabinet knew my timing. I still do not remember touching it before.")
	_expect_first_text("cabinet 07 truth phase", DIALOGUE_POOL.get_lines("cabinet_07", "truth_filter_phase_echo"), "TOKEN RETURNED.")
	_expect_first_text("cabinet 07 overloaded", DIALOGUE_POOL.get_lines("cabinet_07", "overloaded_echo"), "CABINET STATUS: LOUD.")
	_expect_first_text("cabinet 07 post reveal", DIALOGUE_POOL.get_lines("cabinet_07", "post_reveal_status"), "EMPLOYEE 04 IDENTITY STATUS: INTEGRATED.")
	_expect_contains_text("cabinet 07 post reveal", DIALOGUE_POOL.get_lines("cabinet_07", "post_reveal_status"), "CURRENT SESSION: YOURS.")
	_expect_first_text("roxy locked", DIALOGUE_POOL.get_lines("roxy", "first_meeting_locked"), "Whoa. You look exactly like the person in half the staff photos.")
	_expect_first_text("roxy intro", DIALOGUE_POOL.get_lines("roxy", "broken_high_score_intro"), "Finally. Player Two showed up.")
	_expect_first_text("roxy hint", DIALOGUE_POOL.get_lines("roxy", "broken_high_score_hint"), "Hint one: 999999 is nonsense.")
	_expect_contains_text("roxy completion", DIALOGUE_POOL.get_lines("roxy", "broken_high_score_completion"), "The name stayed blank.")
	_expect_first_text("roxy repeat", DIALOGUE_POOL.get_lines("roxy", "repeat_after_completion"), "Your score is back.")
	_expect_first_text("roxy post reveal", DIALOGUE_POOL.get_lines("roxy", "post_reveal"), "So you were Employee 04.")
	_expect_first_text("pip first meeting", DIALOGUE_POOL.get_lines("pip", "first_meeting"), "Hi! I am a legally distinct prize animal.")
	_expect_first_text("pip after token", DIALOGUE_POOL.get_lines("pip", "after_lost_token"), "You brought the Lost Token back.")
	_expect_first_text("pip continuous routed first meeting", DIALOGUE_POOL.get_lines("pip", "prize_sort_first_meeting"), "Hi. I am a legally distinct prize animal with a small amount of confidential information.")
	_expect(DIALOGUE_POOL.get_lines("pip", "prize_sort_first_meeting").size() <= 10, "Pip's first routed meeting is one concise conversation")
	_expect_first_text("pip prize intro", DIALOGUE_POOL.get_lines("pip", "prize_sort_intro"), "If you want something practical to hold onto, Prize Echo Ascent is awake.")
	_expect_first_text("Gus continuous service intro", DIALOGUE_POOL.get_lines("gus", "static_service_full_intro"), "You made it. Panel is already open, so we can skip the part where I repeat myself.")
	_expect(DIALOGUE_POOL.get_lines("gus", "static_service_full_intro").size() <= 8, "Gus's service handoff is one concise conversation")
	_expect_first_text("Night Ledger intro", DIALOGUE_POOL.get_lines("night_ledger", "quest_intro"), "EVERYTHING IN THIS ROOM IS OPERATIONAL. THE ARCHIVE RUN IS READY WHEN YOU ARE.")
	_expect_contains_text("Night Ledger papers", DIALOGUE_POOL.get_lines("night_ledger", "archive_bills"), "Rent past due. Payroll delayed. Three repair invoices... every total is circled twice. The smeared signature feels familiar.")
	_expect_contains_text("Night Ledger television", DIALOGUE_POOL.get_lines("night_ledger", "archive_tv"), "A note says the replacement was denied because the old one still worked. Whoever owned this place kept repairing yesterday because tomorrow cost too much.")
	_expect_contains_text("Night Ledger movement intro", DIALOGUE_POOL.get_lines("night_ledger", "quest_intro"), "Hold jump for height. Three extra jumps remain available in the air.")
	_expect_line_contains("Night Ledger Duplex debrief", DIALOGUE_POOL.get_lines("night_ledger", "token_debrief"), "One owner signature. Two authorization traces.")
	_expect_contains_text("pip completion", DIALOGUE_POOL.get_lines("pip", "prize_sort_completion"), "Under it is an old service mark: closing inventory, a shift code, and a maintenance copy.")
	_expect_contains_text("pip post reveal", DIALOGUE_POOL.get_lines("pip", "post_reveal"), "Yep. Same person. Different seams.")
	_expect_first_text("test cabinet memories", DIALOGUE_POOL.get_lines("environment_objects", "test_cabinet_memories"), "TEST LOG 114: difficulty lowered again.")
	_expect_first_text("hub directory notes", DIALOGUE_POOL.get_lines("environment_objects", "hub_directory_notes"), "PIXEL HAVEN FLOOR GUIDE.")
	_expect_first_text("environment portrait grounded", DIALOGUE_POOL.get_lines("environment_objects", "owner_portrait_grounded"), "A dusty portrait hangs above the arcade floor, angled like it used to watch the door.")
	_expect_contains_text("environment portrait fractured", DIALOGUE_POOL.get_lines("environment_objects", "owner_portrait_fractured"), "Two marks seem to repeat: 0 and 4.")
	_expect_contains_text("environment portrait restored", DIALOGUE_POOL.get_lines("environment_objects", "owner_portrait_restored"), "It says: EMPLOYEE 04.")
	_expect_first_text("environment broken cabinet", DIALOGUE_POOL.get_lines("environment_objects", "broken_cabinet_grounded"), "The cabinet is dark.")
	_expect_first_text("environment maintenance note", DIALOGUE_POOL.get_lines("environment_objects", "maintenance_note_fractured"), "MAINTENANCE NOTE")
	_expect_first_text("environment staff records", DIALOGUE_POOL.get_lines("environment_objects", "staff_records_fractured"), "RESTORE SYSTEM NOTE")
	_expect_first_text("environment truth logs", DIALOGUE_POOL.get_lines("environment_objects", "staff_record_01_shift_log"), "FINAL SHIFT EXCERPT")
	_expect_first_text("environment truth filter", DIALOGUE_POOL.get_lines("environment_objects", "truth_filter_machine_uneasy"), "CONTRADICTION THRESHOLD REACHED.")
	_expect_first_text("environment circuit soda", DIALOGUE_POOL.get_lines("environment_objects", "circuit_soda_machine_fractured"), "MEMORY FLOW UNROUTED.")
	_expect_contains_text("environment sync circuit lock", DIALOGUE_POOL.get_lines("environment_objects", "maintenance_sync_machine_circuit_required"), "CIRCUIT SODA REQUIRED.")
	_expect_contains_text("environment sync launch prompt", DIALOGUE_POOL.get_lines("environment_objects", "maintenance_sync_machine_static_service_required"), "STATIC SERVICE ROUTE READY.")
	_expect_first_text("environment staff room terminal", DIALOGUE_POOL.get_lines("environment_objects", "staff_room_terminal_available"), "RESTORED TAPE ACCEPTED.")
	_expect_first_text("environment prize counter", DIALOGUE_POOL.get_lines("environment_objects", "prize_counter_fractured"), "Three labels sit loose under the glass.")
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

func _expect_line_contains(label: String, lines: Array, expected_fragment: String) -> void:
	for line_value: Variant in lines:
		if line_value is Dictionary and str((line_value as Dictionary).get("text", "")).contains(expected_fragment):
			return
	_fail("%s expected a line containing %s" % [label, expected_fragment])

func _expect_player_text(label: String, lines: Array, expected_text: String) -> void:
	for line_value: Variant in lines:
		if not line_value is Dictionary:
			continue
		var line := line_value as Dictionary
		if str(line.get("speaker", "")) == "Player" and str(line.get("text", "")) == expected_text:
			return
	_fail("%s expected Player aside %s" % [label, expected_text])

func _expect(condition: bool, label: String) -> void:
	if not condition:
		_fail(label)

func _fail(message: String) -> void:
	failure_count += 1
	push_error(message)
