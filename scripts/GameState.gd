extends Node

const QUEST_REGISTRY := preload("res://scripts/QuestRegistry.gd")

const ACTION_BINDINGS := {
	"move_up": [KEY_W, KEY_UP],
	"move_down": [KEY_S, KEY_DOWN],
	"move_left": [KEY_A, KEY_LEFT],
	"move_right": [KEY_D, KEY_RIGHT],
	"interact": [KEY_E, KEY_SPACE],
	"jump": [KEY_E, KEY_SPACE],
	"crouch": [KEY_S, KEY_DOWN],
	"cancel": [KEY_ESCAPE, KEY_BACKSPACE],
}

const TOTAL_GAMES_COUNT := 4
const TOTAL_REQUIRED_PROGRESS_COUNT := 12
const TOTAL_OPTIONAL_GAMES_COUNT := 1
const TOTAL_SECRETS_COUNT := 7
const MEMORY_SIGNAL_GROUNDED := 0
const MEMORY_SIGNAL_UNEASY := 1
const MEMORY_SIGNAL_FRACTURED := 2
const MEMORY_SIGNAL_OVERLOADED := 3
const MEMORY_SIGNAL_RESTORED := 4

var story_started := false
var lost_token_quest_started := false
var lost_token_collected := false
var lost_token_quest_completed := false
var rockbyte_duel_completed := false
var rockbyte_duel_loss_count := 0
var rockbyte_attempt_count := 0
var truth_filter_quest_started := false
var lying_cabinets_completed := false
var circuit_soda_started := false
var circuit_soda_completed := false
var lost_shift_file_started := false
var lost_shift_file_completed := false
# The internal lost_shift_file id is retained for save compatibility. The
# current player-facing quest is Closing Shift Echoes and uses ordered clues.
var closing_shift_mira_clue_found := false
var closing_shift_score_clue_found := false
var closing_shift_service_clue_found := false
var static_service_run_started := false
var static_service_run_completed := false
var gus_static_run_anecdote_seen := false
var maintenance_sync_started := false
var maintenance_sync_completed := false
var story_puzzle_completed := false
var staff_room_unlocked := false
var staff_corridor_unlocked := false
var security_tape_assembly_started := false
var security_tape_assembly_completed := false
var security_tape_wrong_order_count := 0
var final_night_walk_started := false
var final_night_walk_completed := false
var staff_door_final_walk_anecdote_seen := false
var memory_echo_started := false
var memory_echo_completed := false
var conscience_encounter_1_seen := false
var conscience_encounter_2_seen := false
var conscience_encounter_3_seen := false
var conscience_encounter_4_seen := false
var conscience_final_encounter_seen := false
var conscience_final_room_seen := false
var conscience_name_revealed := false
var player_glitched_form_unlocked := false
var player_creator_monologue_seen := false
var twist_reveal_seen := false
var ending_seen := false
var post_reveal_roam_unlocked := false
var memory_signal_level := MEMORY_SIGNAL_GROUNDED

var mira_intro_seen := false
var mira_post_reveal_seen := false
var gus_intro_seen := false
var gus_post_reveal_seen := false
var vendo_intro_seen := false
var vendo_post_reveal_seen := false
var roxy_met := false
var pip_met := false
var pip_secret_started := false
var prize_echo_unlocked := false
var pip_secret_completed := false
var prize_sort_completed := false
var pip_post_reveal_secret_seen := false
var night_ledger_started := false
var night_ledger_completed := false
var night_ledger_token_collected := false
var night_ledger_debrief_seen := false
var mira_rockbyte_anecdote_seen := false
var mr_byte_truth_filter_anecdote_seen := false
var vendo_circuit_anecdote_seen := false
var vendo_unknown_clue_seen := false
var gus_sync_anecdote_seen := false
var memory_echo_anecdote_seen := false
var roxy_high_score_anecdote_seen := false
var pip_prize_anecdote_seen := false
var cabinet07_employee_hint_seen := false
var mr_byte_intro_seen := false
var mr_byte_post_reveal_seen := false

var broken_cabinet_secret_found := false
var broken_high_score_completed := false
var owner_portrait_secret_found := false
var employee_04_file_found := false
var vendo_memory_riddle_secret_found := false
var ssr_secret_cache_found := false
var tape_anomaly_frame_seen := false
var post_reveal_witness_route_completed := false
var staff_record_01_read := false
var staff_record_02_read := false
var staff_record_03_read := false
var staff_records_chain_completed := false
var witness_mira_heard := false
var witness_gus_heard := false
var witness_vendo_heard := false
var witness_mr_byte_heard := false
var witness_cabinet07_heard := false
var witness_roxy_heard := false
var witness_pip_heard := false
var witness_route_completed := false
var echo_cabinet07_seen := false
var echo_owner_portrait_04_seen := false

var save_slot_index := 0
var save_slot_name := ""
var save_timestamp := ""
var save_version := 1
var save_scene_name := ""
var save_player_position_x := 0.0
var save_player_position_y := 0.0
var save_player_facing := "down"
var save_progress_stage := "New Game"
var has_arcade_return_position := false
var arcade_return_position := Vector2.ZERO
# Which map the return position belongs to, so a stored spot can never be
# applied to a different room.
var return_scene_path := ""
var opening_intro_seen := false
var opening_npc_talks := 0
var opening_hint_monologue_seen := false
var memory_signal_explainer_seen := false
var midpoint_turn_seen := false
var midpoint_told_mira := false
# Hub check-ins with Gus between beats (story stops that justify the walk back).
var gus_hub_checkin_truth_filter_done := false
var gus_hub_checkin_prize_sort_done := false
# Cabinet Row debrief beat: Roxy points at Mr. Byte, he files the hallway voice
# as clerical noise, the protagonist decides to ask Gus.
var roxy_truth_filter_nudge_seen := false
var mr_byte_truth_filter_debriefed := false
# Post-game replay tracking (runtime only, never saved): which stage was
# relaunched from a machine's replay offer, and whether it was won.
var postgame_replay_pending := ""
var postgame_replay_won := false
var route_cue_close_tip_seen := false
var npc_dialogue_counts: Dictionary = {}
var pending_spawn_id := ""
var ui_notice_blocking := false

func _ready() -> void:
	_ensure_input_actions()

func _ensure_input_actions() -> void:
	for action_name in ACTION_BINDINGS.keys():
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)
		for key_code in ACTION_BINDINGS[action_name]:
			var key_event := InputEventKey.new()
			key_event.physical_keycode = key_code
			if not InputMap.action_has_event(action_name, key_event):
				InputMap.action_add_event(action_name, key_event)


func get_debug_snapshot() -> Dictionary:
	var quest_data := get_current_quest_data()
	return {
		"quest": get_current_quest_id(),
		"quest_title": str(quest_data.get("title", "")),
		"objective": str(quest_data.get("summary", "")),
		"phase": get_story_phase_label(),
		"required_progress": get_required_progress_count(),
		"required_total": get_total_required_progress_count(),
		"optional_progress": get_optional_games_completed_count(),
		"memory_signal": get_memory_signal_label(),
		"pending_spawn": pending_spawn_id,
		"return_scene": return_scene_path if has_arcade_return_position else "",
		"return_position": arcade_return_position if has_arcade_return_position else Vector2.ZERO,
		"ui_notice_blocking": ui_notice_blocking,
		"postgame_replay": postgame_replay_pending,
		"save_slot": save_slot_index,
	}


func validate_debug_state() -> PackedStringArray:
	var issues := PackedStringArray()
	if lost_token_quest_completed and (not rockbyte_duel_completed or not lost_token_collected):
		issues.append("Lost Token is complete without both the Rockbyte win and recovered token.")
	if lying_cabinets_completed and not broken_high_score_completed:
		issues.append("Truth Filter is complete before Broken High Score.")
	if circuit_soda_completed and not lying_cabinets_completed:
		issues.append("Circuit Soda is complete before Truth Filter.")
	if prize_sort_completed and not circuit_soda_completed:
		issues.append("Prize Echo is complete before Circuit Soda.")
	if closing_shift_score_clue_found and not closing_shift_mira_clue_found:
		issues.append("Closing Shift score clue exists before Mira's clue.")
	if closing_shift_service_clue_found and not closing_shift_score_clue_found:
		issues.append("Closing Shift service clue exists before Broken Score's clue.")
	if lost_shift_file_completed and not (
		closing_shift_mira_clue_found
		and closing_shift_score_clue_found
		and closing_shift_service_clue_found
	):
		issues.append("Closing Shift Echoes is complete without all three ordered clues.")
	if static_service_run_completed and not lost_shift_file_completed:
		issues.append("Static Service Run is complete before Closing Shift Echoes.")
	if maintenance_sync_completed and not static_service_run_completed:
		issues.append("Maintenance Sync is complete before Static Service Run.")
	if security_tape_assembly_completed and not maintenance_sync_completed:
		issues.append("Security Tape is complete before Maintenance Sync.")
	if final_night_walk_completed and not security_tape_assembly_completed:
		issues.append("Final Night Walk is complete before Security Tape.")
	if memory_echo_completed and not final_night_walk_completed:
		issues.append("Memory Echo is complete before Final Night Walk.")
	if twist_reveal_seen and not memory_echo_completed:
		issues.append("The identity reveal is marked seen before Memory Echo.")
	if post_reveal_roam_unlocked and not twist_reveal_seen:
		issues.append("Post-Reveal Roam is unlocked before the identity reveal.")
	if has_arcade_return_position and return_scene_path.is_empty():
		issues.append("A minigame return position exists without its owning scene.")
	return issues

func get_games_completed_count() -> int:
	return get_games_completed_count_from_data(to_save_data())

func get_games_completed_count_from_data(data: Dictionary) -> int:
	var completed := 0
	if bool(data.get("rockbyte_duel_completed", false)):
		completed += 1
	if bool(data.get("circuit_soda_completed", false)):
		completed += 1
	if bool(data.get("maintenance_sync_completed", false)) or bool(data.get("story_puzzle_completed", false)):
		completed += 1
	if bool(data.get("twist_reveal_seen", false)):
		completed += 1
	return completed

func get_total_games_count() -> int:
	return TOTAL_GAMES_COUNT

func get_required_progress_count() -> int:
	return get_required_progress_count_from_data(to_save_data())

func get_required_progress_count_from_data(data: Dictionary) -> int:
	var completed := 0
	if bool(data.get("rockbyte_duel_completed", false)):
		completed += 1
	if bool(data.get("broken_high_score_completed", false)):
		completed += 1
	if bool(data.get("lying_cabinets_completed", false)):
		completed += 1
	if bool(data.get("circuit_soda_completed", false)):
		completed += 1
	if bool(data.get("prize_sort_completed", false)):
		completed += 1
	if _is_lost_shift_file_complete_in_data(data):
		completed += 1
	if bool(data.get("static_service_run_completed", false)):
		completed += 1
	if bool(data.get("maintenance_sync_completed", false)):
		completed += 1
	if bool(data.get("security_tape_assembly_completed", false)):
		completed += 1
	if bool(data.get("final_night_walk_completed", false)):
		completed += 1
	if bool(data.get("memory_echo_completed", false)):
		completed += 1
	if bool(data.get("twist_reveal_seen", false)):
		completed += 1
	return completed

func _is_lost_shift_file_complete_in_data(data: Dictionary) -> bool:
	return bool(data.get("lost_shift_file_completed", false)) or (
		bool(data.get("closing_checklist_read", false))
		and bool(data.get("maintenance_note_read", false))
		and bool(data.get("staff_schedule_read", false))
	)

func get_total_required_progress_count() -> int:
	return TOTAL_REQUIRED_PROGRESS_COUNT

func get_optional_games_completed_count() -> int:
	return get_optional_games_completed_count_from_data(to_save_data())

func get_optional_games_completed_count_from_data(data: Dictionary) -> int:
	return 1 if bool(data.get("night_ledger_completed", data.get("archive_recall_completed", false))) else 0

func get_compatible_save_data_for_summary(data: Dictionary) -> Dictionary:
	var compatible := data.duplicate(true)
	_apply_route_compatibility_to_data(compatible)
	return compatible

func _apply_route_compatibility_to_data(data: Dictionary) -> void:
	# Compatibility for saves made before the expanded route had separate flags.
	# Current counters stay exact; this only repairs loaded/previewed legacy data.
	if bool(data.get("second_memory_fragment_collected", false)):
		data["lying_cabinets_completed"] = true
	if bool(data.get("pip_secret_completed", false)):
		data["prize_sort_completed"] = true
	if bool(data.get("twist_reveal_seen", false)):
		data["memory_echo_completed"] = true
		data["staff_room_unlocked"] = true
	if bool(data.get("memory_echo_completed", false)):
		data["final_night_walk_completed"] = true
		data["staff_room_unlocked"] = true
	if bool(data.get("final_night_walk_completed", false)):
		data["security_tape_assembly_completed"] = true
	if bool(data.get("security_tape_assembly_completed", false)):
		data["maintenance_sync_completed"] = true
		data["story_puzzle_completed"] = true
		data["staff_corridor_unlocked"] = true
	if bool(data.get("story_puzzle_completed", false)):
		data["maintenance_sync_completed"] = true
	if bool(data.get("maintenance_sync_completed", false)):
		data["story_puzzle_completed"] = true
		data["static_service_run_completed"] = true
		data["staff_corridor_unlocked"] = true
	if bool(data.get("static_service_run_completed", false)):
		data["lost_shift_file_completed"] = true
	if _is_lost_shift_file_complete_in_data(data):
		data["lost_shift_file_completed"] = true
	if bool(data.get("lost_shift_file_completed", false)):
		# Static Service is the next active quest after the reconstructed closing
		# sequence. Older saves did not record the new access latch separately.
		data["staff_corridor_unlocked"] = true

func get_total_optional_games_count() -> int:
	return TOTAL_OPTIONAL_GAMES_COUNT

func get_secrets_found_count() -> int:
	return get_secrets_found_count_from_data(to_save_data())

func get_secrets_found_count_from_data(data: Dictionary) -> int:
	var found := 0
	if bool(data.get("broken_cabinet_secret_found", false)):
		found += 1
	if bool(data.get("owner_portrait_secret_found", false)):
		found += 1
	if bool(data.get("employee_04_file_found", false)):
		found += 1
	if bool(data.get("vendo_memory_riddle_secret_found", false)):
		found += 1
	if bool(data.get("ssr_secret_cache_found", false)):
		found += 1
	if bool(data.get("tape_anomaly_frame_seen", data.get("fnw_secret_echo_found", false))):
		found += 1
	if bool(data.get("witness_route_completed", false)) or bool(data.get("post_reveal_witness_route_completed", false)):
		found += 1
	return found

func get_total_secrets_count() -> int:
	return TOTAL_SECRETS_COUNT

func get_story_phase_label() -> String:
	update_memory_signal_from_progress()
	return get_story_phase_label_from_data(to_save_data())

func get_story_phase_label_from_data(data: Dictionary) -> String:
	if bool(data.get("post_reveal_roam_unlocked", false)):
		return "Post-Reveal Roam"
	if bool(data.get("ending_seen", false)):
		return "Ending"
	if bool(data.get("twist_reveal_seen", false)):
		return "Truth Revealed"
	if bool(data.get("memory_echo_completed", false)):
		return "Staff Room"
	if bool(data.get("final_night_walk_completed", false)):
		return "Memory Echo"
	if bool(data.get("security_tape_assembly_completed", false)):
		return "Staff Room Terminal"
	# The Staff Access latch opens early so players are not blocked after Gus's
	# briefing. It is a route permission, not a story-phase advance.
	if bool(data.get("maintenance_sync_completed", false)) or bool(data.get("story_puzzle_completed", false)):
		return "Security Tape Assembly"
	if bool(data.get("static_service_run_completed", false)):
		return "Maintenance Sync"
	if _is_lost_shift_file_complete_in_data(data):
		return "Static Service Run"
	if bool(data.get("staff_corridor_unlocked", false)):
		return "Staff Corridor"
	if bool(data.get("circuit_soda_completed", false)) and not bool(data.get("prize_sort_completed", false)) and not _is_lost_shift_file_complete_in_data(data):
		if not bool(data.get("conscience_encounter_2_seen", false)):
			return "Circuit Soda Debrief"
		if not bool(data.get("vendo_unknown_clue_seen", false)):
			return "Ask About the Voice"
		return "Prize Echo Ascent"
	if bool(data.get("prize_sort_completed", false)) and not bool(data.get("pip_prize_anecdote_seen", false)) and not _is_lost_shift_file_complete_in_data(data):
		return "Prize Echo Ascent"
	if bool(data.get("pip_prize_anecdote_seen", false)) and not bool(data.get("gus_hub_checkin_prize_sort_done", false)) and not _is_lost_shift_file_complete_in_data(data):
		return "Gus Has a Lead"
	if bool(data.get("circuit_soda_completed", false)) and not _is_lost_shift_file_complete_in_data(data):
		return "Closing Shift Echoes"
	if bool(data.get("circuit_soda_completed", false)):
		return "Closing Shift Echoes"
	if bool(data.get("lying_cabinets_completed", false)) or bool(data.get("second_memory_fragment_collected", false)):
		return "Truth Filter Cleared"
	if bool(data.get("lost_token_quest_completed", false)) and not bool(data.get("broken_high_score_completed", false)) and not bool(data.get("lying_cabinets_completed", false)):
		return "Broken High Score"
	if bool(data.get("truth_filter_quest_started", false)) and not bool(data.get("lying_cabinets_completed", false)):
		return "Truth Filter"
	if bool(data.get("lost_token_quest_completed", false)):
		return "Lost Token Returned"
	if bool(data.get("rockbyte_duel_completed", false)) or bool(data.get("lost_token_collected", false)):
		return "Lost Token Found"
	if bool(data.get("lost_token_quest_started", false)):
		return "Cabinet 07"
	if bool(data.get("story_started", false)):
		return "Opening Night"
	return "New Memory"

func get_memory_signal_label_from_level(level: int) -> String:
	match clampi(level, MEMORY_SIGNAL_GROUNDED, MEMORY_SIGNAL_RESTORED):
		MEMORY_SIGNAL_UNEASY:
			return "Uneasy"
		MEMORY_SIGNAL_FRACTURED:
			return "Fractured"
		MEMORY_SIGNAL_OVERLOADED:
			return "Overloaded"
		MEMORY_SIGNAL_RESTORED:
			return "Restored"
		_:
			return "Grounded"

func get_memory_signal_level_from_data(data: Dictionary) -> int:
	if bool(data.get("post_reveal_roam_unlocked", false)):
		return MEMORY_SIGNAL_RESTORED
	if bool(data.get("story_puzzle_completed", false)) or bool(data.get("maintenance_sync_completed", false)):
		return MEMORY_SIGNAL_OVERLOADED
	if bool(data.get("lying_cabinets_completed", false)) or bool(data.get("second_memory_fragment_collected", false)):
		return MEMORY_SIGNAL_FRACTURED
	if bool(data.get("lost_token_quest_completed", false)):
		return MEMORY_SIGNAL_UNEASY
	return MEMORY_SIGNAL_GROUNDED

func reset_for_new_game() -> void:
	story_started = false
	lost_token_quest_started = false
	lost_token_collected = false
	lost_token_quest_completed = false
	rockbyte_duel_completed = false
	rockbyte_duel_loss_count = 0
	rockbyte_attempt_count = 0
	truth_filter_quest_started = false
	lying_cabinets_completed = false
	circuit_soda_started = false
	circuit_soda_completed = false
	lost_shift_file_started = false
	lost_shift_file_completed = false
	closing_shift_mira_clue_found = false
	closing_shift_score_clue_found = false
	closing_shift_service_clue_found = false
	static_service_run_started = false
	static_service_run_completed = false
	gus_static_run_anecdote_seen = false
	maintenance_sync_started = false
	maintenance_sync_completed = false
	story_puzzle_completed = false
	staff_room_unlocked = false
	staff_corridor_unlocked = false
	security_tape_assembly_started = false
	security_tape_assembly_completed = false
	security_tape_wrong_order_count = 0
	final_night_walk_started = false
	final_night_walk_completed = false
	staff_door_final_walk_anecdote_seen = false
	memory_echo_started = false
	memory_echo_completed = false
	conscience_encounter_1_seen = false
	conscience_encounter_2_seen = false
	conscience_encounter_3_seen = false
	conscience_encounter_4_seen = false
	conscience_final_encounter_seen = false
	conscience_final_room_seen = false
	conscience_name_revealed = false
	player_glitched_form_unlocked = false
	player_creator_monologue_seen = false
	twist_reveal_seen = false
	ending_seen = false
	post_reveal_roam_unlocked = false
	memory_signal_level = MEMORY_SIGNAL_GROUNDED
	mira_intro_seen = false
	mira_post_reveal_seen = false
	gus_intro_seen = false
	gus_post_reveal_seen = false
	vendo_intro_seen = false
	vendo_post_reveal_seen = false
	roxy_met = false
	pip_met = false
	pip_secret_started = false
	prize_echo_unlocked = false
	pip_secret_completed = false
	prize_sort_completed = false
	pip_post_reveal_secret_seen = false
	night_ledger_started = false
	night_ledger_completed = false
	night_ledger_token_collected = false
	night_ledger_debrief_seen = false
	mira_rockbyte_anecdote_seen = false
	mr_byte_truth_filter_anecdote_seen = false
	vendo_circuit_anecdote_seen = false
	vendo_unknown_clue_seen = false
	gus_sync_anecdote_seen = false
	memory_echo_anecdote_seen = false
	roxy_high_score_anecdote_seen = false
	pip_prize_anecdote_seen = false
	cabinet07_employee_hint_seen = false
	mr_byte_intro_seen = false
	mr_byte_post_reveal_seen = false
	broken_cabinet_secret_found = false
	broken_high_score_completed = false
	owner_portrait_secret_found = false
	employee_04_file_found = false
	vendo_memory_riddle_secret_found = false
	ssr_secret_cache_found = false
	tape_anomaly_frame_seen = false
	post_reveal_witness_route_completed = false
	staff_record_01_read = false
	staff_record_02_read = false
	staff_record_03_read = false
	staff_records_chain_completed = false
	witness_mira_heard = false
	witness_gus_heard = false
	witness_vendo_heard = false
	witness_mr_byte_heard = false
	witness_cabinet07_heard = false
	witness_roxy_heard = false
	witness_pip_heard = false
	witness_route_completed = false
	echo_cabinet07_seen = false
	echo_owner_portrait_04_seen = false
	save_slot_index = 0
	save_slot_name = ""
	save_timestamp = ""
	save_version = 1
	save_scene_name = ""
	save_player_position_x = 0.0
	save_player_position_y = 0.0
	save_player_facing = "down"
	save_progress_stage = "New Memory"
	opening_intro_seen = false
	opening_npc_talks = 0
	opening_hint_monologue_seen = false
	memory_signal_explainer_seen = false
	midpoint_turn_seen = false
	midpoint_told_mira = false
	gus_hub_checkin_truth_filter_done = false
	gus_hub_checkin_prize_sort_done = false
	roxy_truth_filter_nudge_seen = false
	mr_byte_truth_filter_debriefed = false
	postgame_replay_pending = ""
	postgame_replay_won = false
	route_cue_close_tip_seen = false
	npc_dialogue_counts.clear()
	pending_spawn_id = ""
	clear_arcade_return_position()

func set_pending_spawn_id(spawn_id: String) -> void:
	pending_spawn_id = spawn_id

func consume_pending_spawn_id(default_spawn_id: String = "Spawn_Default") -> String:
	var spawn_id := pending_spawn_id
	pending_spawn_id = ""
	if spawn_id.is_empty():
		return default_spawn_id
	return spawn_id

func clear_arcade_return_position() -> void:
	arcade_return_position = Vector2.ZERO
	has_arcade_return_position = false
	return_scene_path = ""

func start_lost_token_quest() -> void:
	story_started = true
	lost_token_quest_started = true

func collect_lost_token() -> void:
	flag_postgame_replay_win()
	lost_token_collected = true

func complete_lost_token_quest() -> void:
	lost_token_quest_started = true
	lost_token_collected = true
	lost_token_quest_completed = true
	truth_filter_quest_started = true
	update_memory_signal_from_progress()

func complete_truth_filter() -> void:
	flag_postgame_replay_win()
	truth_filter_quest_started = true
	lying_cabinets_completed = true
	update_memory_signal_from_progress()

func start_circuit_soda() -> void:
	circuit_soda_started = true
	update_memory_signal_from_progress()

func complete_circuit_soda() -> void:
	flag_postgame_replay_win()
	circuit_soda_started = true
	circuit_soda_completed = true
	update_memory_signal_from_progress()

func start_lost_shift_file() -> void:
	lost_shift_file_started = true

func find_closing_shift_mira_clue() -> bool:
	if not lost_shift_file_started:
		return false
	closing_shift_mira_clue_found = true
	return true

func find_closing_shift_score_clue() -> bool:
	if not lost_shift_file_started or not closing_shift_mira_clue_found:
		return false
	closing_shift_score_clue_found = true
	return true

func find_closing_shift_service_clue() -> bool:
	if not lost_shift_file_started or not closing_shift_score_clue_found:
		return false
	closing_shift_service_clue_found = true
	return true

func closing_shift_clues_complete() -> bool:
	return (
		closing_shift_mira_clue_found
		and closing_shift_score_clue_found
		and closing_shift_service_clue_found
	)

func complete_closing_shift_echoes() -> bool:
	if not closing_shift_clues_complete():
		return false
	lost_shift_file_completed = true
	# The Maintenance Hall now leads directly into the Staff Access route once
	# the closing sequence has been reconstructed. Static Service still gates
	# the machinery beyond it, but the hallway is no longer falsely locked.
	staff_corridor_unlocked = true
	update_memory_signal_from_progress()
	return true

func start_static_service_run() -> void:
	static_service_run_started = true
	# The restored current releases the Staff Access Hall latch. The later sync
	# still gates its machinery, but the player is no longer told the door is
	# locked after Gus has already sent them into the service route.
	staff_corridor_unlocked = true
	update_memory_signal_from_progress()

func complete_static_service_run() -> void:
	flag_postgame_replay_win()
	static_service_run_started = true
	static_service_run_completed = true
	update_memory_signal_from_progress()

func start_maintenance_sync() -> void:
	maintenance_sync_started = true
	update_memory_signal_from_progress()

func complete_maintenance_sync() -> void:
	flag_postgame_replay_win()
	maintenance_sync_started = true
	maintenance_sync_completed = true
	story_puzzle_completed = true
	staff_corridor_unlocked = true
	update_memory_signal_from_progress()

func start_security_tape_assembly() -> void:
	security_tape_assembly_started = true
	update_memory_signal_from_progress()

func record_security_tape_wrong_order() -> void:
	security_tape_assembly_started = true
	security_tape_wrong_order_count += 1

func complete_security_tape_assembly() -> void:
	flag_postgame_replay_win()
	security_tape_assembly_started = true
	security_tape_assembly_completed = true
	update_memory_signal_from_progress()

# The Final Night Walk stage was cut. These flags stay only so existing saves
# keep loading and the late-game progression checks read the same as before;
# nothing in the shipped route launches a stage for them.
func complete_final_night_walk() -> void:
	flag_postgame_replay_win()
	final_night_walk_started = true
	final_night_walk_completed = true
	update_memory_signal_from_progress()

func start_memory_echo() -> void:
	memory_echo_started = true
	update_memory_signal_from_progress()

func complete_memory_echo() -> void:
	flag_postgame_replay_win()
	memory_echo_started = true
	memory_echo_completed = true
	staff_room_unlocked = true
	final_night_walk_started = true
	final_night_walk_completed = true
	update_memory_signal_from_progress()

func mark_conscience_encounter_seen(encounter_id: String) -> void:
	match encounter_id:
		"after_truth_filter":
			conscience_encounter_1_seen = true
		"after_circuit_soda":
			conscience_encounter_2_seen = true
		"after_lost_shift_file":
			conscience_encounter_3_seen = true
		"staff_corridor_approach":
			conscience_encounter_4_seen = true
		"final_conscience":
			conscience_final_encounter_seen = true
			conscience_name_revealed = true

func mark_conscience_final_room_seen() -> void:
	conscience_final_room_seen = true
	conscience_final_encounter_seen = true
	conscience_name_revealed = true
	player_creator_monologue_seen = true
	unlock_player_glitched_form()

func is_conscience_encounter_seen(encounter_id: String) -> bool:
	match encounter_id:
		"after_truth_filter":
			return conscience_encounter_1_seen
		"after_circuit_soda":
			return conscience_encounter_2_seen
		"after_lost_shift_file":
			return conscience_encounter_3_seen
		"staff_corridor_approach":
			return conscience_encounter_4_seen
		"final_conscience":
			return conscience_final_encounter_seen or conscience_final_room_seen
		_:
			return false

func begin_postgame_replay(stage_id: String) -> void:
	postgame_replay_pending = stage_id
	postgame_replay_won = false

func flag_postgame_replay_win() -> void:
	if not postgame_replay_pending.is_empty():
		postgame_replay_won = true

func consume_postgame_replay_return(stage_id: String) -> bool:
	if postgame_replay_pending != stage_id:
		return false
	var won := postgame_replay_won
	postgame_replay_pending = ""
	postgame_replay_won = false
	return won

func set_return_point(scene_path: String, position: Vector2) -> void:
	# Remember exactly where the player stood before a minigame took over.
	return_scene_path = scene_path
	arcade_return_position = position
	has_arcade_return_position = true

func has_return_point() -> bool:
	return has_arcade_return_position and not return_scene_path.is_empty()

func get_return_scene_path() -> String:
	return return_scene_path

func consume_return_point(scene_path: String) -> Variant:
	# Hand the spot back only to the room it was taken from; arriving anywhere
	# else means the stored spot is stale, so drop it.
	if not has_arcade_return_position:
		return null
	var matched := return_scene_path == scene_path
	var position := arcade_return_position
	clear_arcade_return_position()
	return position if matched else null

func unlock_player_glitched_form() -> void:
	player_glitched_form_unlocked = true

func get_conscience_reveal_factor() -> float:
	# How recognizable ??? is: pure black at the first encounter, progressively
	# lighter with each one, fully visible in the Staff Room.
	if twist_reveal_seen or conscience_final_room_seen or post_reveal_roam_unlocked:
		return 1.0
	var seen := 0
	if conscience_encounter_1_seen: seen += 1
	if conscience_encounter_2_seen: seen += 1
	if conscience_encounter_3_seen: seen += 1
	if conscience_encounter_4_seen: seen += 1
	match seen:
		0: return 0.0
		1: return 0.28
		2: return 0.52
		3: return 0.74
		_: return 0.85

func should_use_glitched_player_sprite() -> bool:
	return player_glitched_form_unlocked or post_reveal_roam_unlocked or twist_reveal_seen

func complete_broken_high_score() -> void:
	flag_postgame_replay_win()
	broken_high_score_completed = true

func complete_pip_secret() -> void:
	flag_postgame_replay_win()
	pip_secret_started = true
	prize_echo_unlocked = true
	pip_secret_completed = true
	prize_sort_completed = true

func complete_night_ledger_run() -> void:
	flag_postgame_replay_win()
	night_ledger_started = true
	night_ledger_completed = true
	night_ledger_token_collected = true

func read_staff_record_01() -> void:
	staff_record_01_read = true
	_complete_staff_records_chain_if_ready()

func read_staff_record_02() -> void:
	staff_record_02_read = true
	_complete_staff_records_chain_if_ready()

func read_staff_record_03() -> void:
	staff_record_03_read = true
	_complete_staff_records_chain_if_ready()

func _complete_staff_records_chain_if_ready() -> void:
	if staff_record_01_read and staff_record_02_read and staff_record_03_read:
		staff_records_chain_completed = true

func mark_witness_mira_heard() -> void:
	witness_mira_heard = true
	_complete_witness_route_if_ready()

func mark_witness_gus_heard() -> void:
	witness_gus_heard = true
	_complete_witness_route_if_ready()

func mark_witness_vendo_heard() -> void:
	witness_vendo_heard = true
	_complete_witness_route_if_ready()

func mark_witness_mr_byte_heard() -> void:
	witness_mr_byte_heard = true
	_complete_witness_route_if_ready()

func mark_witness_cabinet07_heard() -> void:
	witness_cabinet07_heard = true
	_complete_witness_route_if_ready()

func mark_witness_roxy_heard() -> void:
	witness_roxy_heard = true
	_complete_witness_route_if_ready()

func mark_witness_pip_heard() -> void:
	witness_pip_heard = true
	_complete_witness_route_if_ready()

func _complete_witness_route_if_ready() -> void:
	if _post_reveal_witnesses_complete():
		witness_route_completed = true
		post_reveal_witness_route_completed = true

func _post_reveal_witnesses_complete() -> bool:
	var required_heard: bool = witness_mira_heard and witness_gus_heard and witness_vendo_heard and witness_mr_byte_heard and witness_cabinet07_heard
	if not required_heard:
		return false
	if roxy_met and not witness_roxy_heard:
		return false
	if pip_met and not witness_pip_heard:
		return false
	return true

func mark_twist_reveal_seen() -> void:
	staff_room_unlocked = true
	staff_corridor_unlocked = true
	memory_echo_started = true
	memory_echo_completed = true
	final_night_walk_started = true
	final_night_walk_completed = true
	twist_reveal_seen = true
	update_memory_signal_from_progress()

func unlock_post_reveal_roam() -> void:
	post_reveal_roam_unlocked = true
	update_memory_signal_from_progress()

func mark_opening_intro_seen() -> void:
	opening_intro_seen = true

func register_opening_talk() -> void:
	if story_started or opening_hint_monologue_seen:
		return
	opening_npc_talks += 1

func opening_look_around_active() -> bool:
	return not story_started and not opening_hint_monologue_seen

func opening_monologue_due() -> bool:
	return opening_look_around_active() and opening_npc_talks >= 3

func get_current_quest_id() -> String:
	if not story_started:
		return "opening_talk_to_mira" if opening_hint_monologue_seen else "opening_look_around"
	if lost_token_quest_started and not rockbyte_duel_completed:
		return "recover_lost_token"
	if rockbyte_duel_completed and not lost_token_quest_completed:
		return "return_lost_token"
	if lost_token_quest_completed and not lying_cabinets_completed and not broken_high_score_completed:
		return "broken_high_score"
	if lost_token_quest_completed and not lying_cabinets_completed:
		return "truth_filter"
	if lying_cabinets_completed and not mr_byte_truth_filter_debriefed and not circuit_soda_completed:
		return "mr_byte_debrief"
	if lying_cabinets_completed and not gus_hub_checkin_truth_filter_done and not circuit_soda_completed:
		return "gus_checkin_truth_filter"
	if lying_cabinets_completed and not circuit_soda_completed:
		return "circuit_soda"
	if circuit_soda_completed and not prize_sort_completed and not lost_shift_file_completed and not maintenance_sync_completed and not story_puzzle_completed:
		if not conscience_encounter_2_seen:
			return "vendo_circuit_debrief"
		if not vendo_unknown_clue_seen:
			return "ask_vendo_about_unknown"
		return "prize_sort"
	if circuit_soda_completed and prize_sort_completed and not pip_prize_anecdote_seen and not lost_shift_file_completed and not maintenance_sync_completed and not story_puzzle_completed:
		return "prize_sort"
	if circuit_soda_completed and pip_prize_anecdote_seen and not gus_hub_checkin_prize_sort_done and not lost_shift_file_completed and not maintenance_sync_completed and not story_puzzle_completed:
		return "gus_checkin_prize_sort"
	if circuit_soda_completed and not lost_shift_file_completed and not maintenance_sync_completed and not story_puzzle_completed:
		return "lost_shift_file"
	if lost_shift_file_completed and not static_service_run_completed and not maintenance_sync_completed and not story_puzzle_completed:
		return "static_service_run"
	if static_service_run_completed and not maintenance_sync_completed and not story_puzzle_completed:
		return "maintenance_sync"
	if maintenance_sync_completed and not security_tape_assembly_completed and not memory_echo_completed:
		return "security_tape_assembly"
	# Restoring the tape now hands directly into the Staff Room terminal reveal.
	# Keep the old completion flags for save compatibility, but do not surface
	# retired Final Night / Memory Echo objectives to the player.
	if security_tape_assembly_completed and not twist_reveal_seen:
		return "enter_staff_room"
	if maintenance_sync_completed and not memory_echo_completed:
		return "staff_corridor"
	if memory_echo_completed and not twist_reveal_seen:
		return "enter_staff_room"
	if twist_reveal_seen and not post_reveal_roam_unlocked:
		return "finish_memory"
	if post_reveal_roam_unlocked and not post_reveal_witness_route_completed:
		return "talk_to_witnesses"
	return ""

func get_current_quest_data() -> Dictionary:
	match get_current_quest_id():
		"vendo_circuit_debrief":
			return {
				"id": "vendo_circuit_debrief",
				"title": "Circuit Soda Debrief",
				"summary": "Talk to Vendo after Circuit Soda.",
				"details": "Circuit Soda accepted the route. Vendo in Snack Alcove may be able to explain what the machine recognized.",
				"owner": "Vendo",
				"location": "SnackAlcove",
				"required": true,
			}
		"ask_vendo_about_unknown":
			return {
				"id": "ask_vendo_about_unknown",
				"title": "Ask About the Voice",
				"summary": "Ask Vendo about the unknown voice.",
				"details": "Something spoke through the static after Circuit Soda. I still do not know what it is. Vendo may have a clue.",
				"owner": "Vendo",
				"location": "SnackAlcove",
				"required": true,
			}
		"broken_high_score":
			if get_npc_dialogue_count("roxy:broken_high_score_intro") == 0:
				return _with_registry_quest_data({
					"id": "broken_high_score",
					"title": "Broken High Score",
					"summary": "Talk to Roxy in Cabinet Row.",
					"details": "Mira says a regular named Roxy guards a score cabinet that is still lying about a record. Hear her out before touching the board.",
				}, "broken_high_score")
			return _with_registry_quest_data({
				"id": "broken_high_score",
				"title": "Broken High Score",
				"summary": "Use the BROKEN SCORE cabinet in Cabinet Row.",
				"details": "Roxy guards the Broken High Score cabinet in Cabinet Row. The board lies that the target is 999999. Restore the real record before the Truth Filter.",
			}, "broken_high_score")
		"prize_sort":
			if prize_sort_completed and not pip_prize_anecdote_seen:
				return _with_registry_quest_data({
					"id": "prize_sort",
					"title": "Prize Echo Ascent",
					"summary": "Take the Echo Token to Pip.",
					"details": "The shelf route released an Echo Token. Bring it to Pip in Prize Corner so they can examine its markings before you leave.",
				}, "prize_counter_secret")
			if not pip_met:
				return _with_registry_quest_data({
					"id": "prize_sort",
					"title": "Prize Echo Ascent",
					"summary": "Head through Prize Service Hall.",
					"details": "Vendo says Prize Service Hall is the passage on the right between the two machines. Follow it to Prize Corner and ask Pip about the shelf route.",
				}, "prize_counter_secret")
			return _with_registry_quest_data({
				"id": "prize_sort",
				"title": "Prize Echo Ascent",
				"summary": "Use the shelf beside Pip.",
				"details": "Complete Prize Echo Ascent: follow all eighteen echo tags in order, open the three rail locks, then bring what the shelf releases back to Pip.",
			}, "prize_counter_secret")
		"gus_checkin_truth_filter":
			return {
				"id": "gus_checkin_truth_filter",
				"title": "Catch Up With Gus",
				"summary": "Find Gus on the Arcade Hub floor.",
				"details": "Gus heard the Truth Filter lose its argument and wants a word before the next machine. Find him on the Arcade Hub floor.",
				"owner": "Gus",
				"location": "ArcadeHub",
				"required": true,
			}
		"gus_checkin_prize_sort":
			return {
				"id": "gus_checkin_prize_sort",
				"title": "Gus Has a Lead",
				"summary": "Talk to Gus in the Arcade Hub.",
				"details": "Pip found an old service mark on the Echo Token and thinks Gus can trace it. Take the token to Gus on the Arcade Hub floor.",
				"owner": "Gus",
				"location": "ArcadeHub",
				"required": true,
			}
		"opening_look_around":
			return _with_registry_quest_data({
				"id": "opening_look_around",
				"title": "Get Your Bearings",
				"summary": "Look around. Talk to whoever is still here.",
				"details": "I only stepped inside because the lights were on. I do not recognize this closed arcade or the people still here, but curiosity is pulling me farther in. I should look around before I decide anything.",
			}, "lost_token")
		"opening_talk_to_mira":
			return _with_registry_quest_data({
				"id": "opening_talk_to_mira",
				"title": "Find Mira",
				"summary": "Talk to Mira at the ticket counter.",
				"details": "Pixel Haven is closed, but Mira seems to know me. I should talk to her at the ticket counter.",
			}, "lost_token")
		"recover_lost_token":
			return _with_registry_quest_data({
				"id": "recover_lost_token",
				"title": "Recover the Lost Token",
				"summary": "Win your token back from Cabinet 07.",
				"details": "Mira says Cabinet 07 has my Lost Token. I need to play Cabinet 07 on the ArcadeHub main floor, then bring the token back to Mira at the ticket counter.",
			}, "lost_token")
		"return_lost_token":
			return _with_registry_quest_data({
				"id": "return_lost_token",
				"title": "Return the Lost Token",
				"summary": "Bring the Lost Token back to Mira.",
				"details": "Cabinet 07 released the Lost Token. Mira is waiting for it by the ticket counter.",
			}, "lost_token")
		"maintenance_sync":
			return _with_registry_quest_data({
				"id": "maintenance_sync",
				"title": "Maintenance Sync",
				"summary": "Run Maintenance Sync with Gus in Maintenance.",
				"details": "Service power is restored. Meet Gus at the Staff Door in Maintenance Hall - he runs the sync with you on the spot.",
			}, "maintenance_sync")
		"static_service_run":
			return _with_registry_quest_data({
				"id": "static_service_run",
				"title": "Static Service Run",
				"summary": "See Gus in Maintenance Hall about the power.",
				"details": "The closing-shift echoes gave Gus enough context to work with the Staff Door, but Maintenance Hall still needs service power. Talk to Gus, then run Static Service Run.",
			}, "static_service_run")
		"lost_shift_file":
			var clue_summary := "Talk to Mira at the ticket counter."
			var clue_location := "ArcadeHub"
			if closing_shift_mira_clue_found and not closing_shift_score_clue_found:
				clue_summary = "Follow the familiar thread in Cabinet Row."
				clue_location = "Cabinet Row"
			elif closing_shift_score_clue_found and not closing_shift_service_clue_found:
				clue_summary = "Follow the next thread in Snack Alcove."
				clue_location = "SnackAlcove"
			elif closing_shift_clues_complete():
				clue_summary = "Return to Gus in the Arcade Hub."
				clue_location = "ArcadeHub"
			return {
				"id": "lost_shift_file",
				"title": "Closing Shift Echoes",
				"owner": "Gus",
				"location": clue_location,
				"summary": clue_summary,
				"details": "Gus is sorting the accessible shift files. Begin with Mira, then follow the threads that feel familiar before reporting what surfaced.",
				"required": true,
				"starts_after": "pip_prize_anecdote_seen",
				"minigame": "None",
				"memory_signal_after": "Fractured",
			}
		"staff_corridor":
			return _with_registry_quest_data({
				"id": "staff_corridor",
				"title": "Enter the Staff Corridor",
				"summary": "Take the north exit to the Staff Room.",
				"details": "Gus stabilized the Staff Door. Follow the north exit through Staff Corridor to the archive in the Staff Room.",
			}, "staff_corridor")
		"security_tape_assembly":
			return {
				"id": "security_tape_assembly",
				"title": "Assemble the Security Tape",
				"owner": "Archive Desk",
				"location": "Staff Room",
				"summary": "Inspect the archive desk in Staff Room.",
				"details": "The archive holds the damaged security tape. Inspect the desk in the Staff Room to restore its four recorded frames.",
				"required": true,
				"starts_after": "maintenance_sync_completed",
				"minigame": "Security Tape Assembly",
				"memory_signal_after": "Overloaded",
			}
		"circuit_soda":
			if get_npc_dialogue_count("vendo_circuit_explained") == 0:
				return _with_registry_quest_data({
					"id": "circuit_soda",
					"title": "Route the Signal",
					"summary": "Talk to Vendo in Snack Alcove.",
					"details": "Gus says Vendo has been rerouting power to itself again. Hear the machine out before touching Circuit Soda.",
				}, "circuit_soda")
			return _with_registry_quest_data({
				"id": "circuit_soda",
				"title": "Route the Signal",
				"summary": "Route Circuit Soda in Snack Alcove.",
				"details": "Vendo walked you through it. Rotate the pipes until the memory input reaches the restore output.",
			}, "circuit_soda")
		"truth_filter":
			if get_npc_dialogue_count("mr_byte_tf_explained") == 0:
				return _with_registry_quest_data({
					"id": "truth_filter",
					"title": "Open the Truth Filter",
					"summary": "Talk to Mr. Byte in Cabinet Row.",
					"details": "Roxy says Mr. Byte runs the Truth Filter and will not let anyone near it without an orientation. Find him in Cabinet Row first.",
				}, "truth_filter")
			return _with_registry_quest_data({
				"id": "truth_filter",
				"title": "Open the Truth Filter",
				"summary": "Run the Truth Filter in Cabinet Row.",
				"details": "Mr. Byte opened the Truth Filter. Sort the lying cabinets. Roxy says the LOGS stack across the row holds the shift record the filter quizzes you on.",
			}, "truth_filter")
		"mr_byte_debrief":
			return {
				"id": "mr_byte_debrief",
				"title": "Report to Mr. Byte",
				"summary": "Tell Mr. Byte what the Filter found.",
				"details": "Roxy says Mr. Byte files everything the Truth Filter turns up. He is still in Cabinet Row, and he will have opinions.",
				"owner": "Mr. Byte",
				"location": "Cabinet Row",
				"required": true,
			}
		"enter_staff_room":
			return {
				"id": "enter_staff_room",
				"title": "Take the Tape to the Terminal",
				"owner": "Terminal",
				"location": "Staff Room",
				"summary": "Take the restored tape to the Staff Room terminal.",
				"details": "The tape order is restored. Carry it across the Staff Room and interact with the terminal to begin playback.",
				"required": true,
				"minigame": "Memory Echo",
				"memory_signal_after": "Overloaded",
			}
		"finish_memory":
			return {
				"id": "finish_memory",
				"title": "Finish the Memory",
				"summary": "Face the restored memory at the terminal.",
				"details": "The terminal has recovered the truth. Stay with the memory long enough to hear what the other voice has been protecting.",
			}
		"talk_to_witnesses":
			return _with_registry_quest_data({
				"id": "talk_to_witnesses",
				"title": "Talk to Those Who Remembered",
				"summary": "Speak with the remaining witnesses.",
				"details": "Pixel Haven remembers me differently now. Mira, Gus, Vendo, Mr. Byte, and Cabinet 07 may have changed things to say. Roxy and Pip may add their own pieces if I met them.",
			}, "post_reveal_witness_route")
		_:
			return {
				"id": "",
				"title": "No Active Quest",
				"summary": "There is no current objective.",
				"details": "There is no active quest right now.",
			}

func _with_registry_quest_data(base_data: Dictionary, registry_id: String) -> Dictionary:
	var merged := base_data.duplicate(true)
	var registry_data: Dictionary = QUEST_REGISTRY.get_quest(registry_id)
	merged["registry_id"] = registry_id
	merged["owner"] = str(registry_data.get("owner", ""))
	merged["location"] = str(registry_data.get("location", ""))
	merged["minigame"] = str(registry_data.get("minigame", ""))
	merged["required"] = bool(registry_data.get("required", true))
	merged["starts_after"] = str(registry_data.get("starts_after", ""))
	merged["completion_dialogue"] = registry_data.get("completion_dialogue", [])
	merged["memory_signal_after"] = str(registry_data.get("memory_signal_after", ""))
	return merged

func get_npc_dialogue_count(key: String) -> int:
	return int(npc_dialogue_counts.get(key, 0))

func increment_npc_dialogue_count(key: String) -> int:
	var next_count := get_npc_dialogue_count(key) + 1
	npc_dialogue_counts[key] = next_count
	return next_count

func get_memory_signal_label() -> String:
	return get_memory_signal_label_from_level(memory_signal_level)

func set_memory_signal_level(value: int) -> void:
	memory_signal_level = clampi(value, MEMORY_SIGNAL_GROUNDED, MEMORY_SIGNAL_RESTORED)

func update_memory_signal_from_progress() -> void:
	if post_reveal_roam_unlocked:
		set_memory_signal_level(MEMORY_SIGNAL_RESTORED)
		return
	if maintenance_sync_completed or story_puzzle_completed:
		set_memory_signal_level(MEMORY_SIGNAL_OVERLOADED)
		return
	if lying_cabinets_completed:
		set_memory_signal_level(MEMORY_SIGNAL_FRACTURED)
		return
	if lost_token_quest_completed:
		set_memory_signal_level(MEMORY_SIGNAL_UNEASY)
		return
	set_memory_signal_level(MEMORY_SIGNAL_GROUNDED)

func to_save_data() -> Dictionary:
	update_memory_signal_from_progress()
	return {
		"save_slot_index": save_slot_index,
		"save_slot_name": save_slot_name,
		"save_timestamp": save_timestamp,
		"save_version": save_version,
		"save_scene_name": save_scene_name,
		"save_player_position_x": save_player_position_x,
		"save_player_position_y": save_player_position_y,
		"save_player_facing": save_player_facing,
		"save_progress_stage": save_progress_stage,
		"has_arcade_return_position": has_arcade_return_position,
		"arcade_return_position_x": arcade_return_position.x,
		"arcade_return_position_y": arcade_return_position.y,
		"story_started": story_started,
		"lost_token_quest_started": lost_token_quest_started,
		"lost_token_collected": lost_token_collected,
		"lost_token_quest_completed": lost_token_quest_completed,
		"rockbyte_duel_completed": rockbyte_duel_completed,
		"rockbyte_duel_loss_count": rockbyte_duel_loss_count,
		"rockbyte_attempt_count": rockbyte_attempt_count,
		"truth_filter_quest_started": truth_filter_quest_started,
		"lying_cabinets_completed": lying_cabinets_completed,
		"circuit_soda_started": circuit_soda_started,
		"circuit_soda_completed": circuit_soda_completed,
		"lost_shift_file_started": lost_shift_file_started,
		"lost_shift_file_completed": lost_shift_file_completed,
		"closing_shift_mira_clue_found": closing_shift_mira_clue_found,
		"closing_shift_score_clue_found": closing_shift_score_clue_found,
		"closing_shift_service_clue_found": closing_shift_service_clue_found,
		"static_service_run_started": static_service_run_started,
		"static_service_run_completed": static_service_run_completed,
		"gus_static_run_anecdote_seen": gus_static_run_anecdote_seen,
		"maintenance_sync_started": maintenance_sync_started,
		"maintenance_sync_completed": maintenance_sync_completed,
		"story_puzzle_completed": story_puzzle_completed,
		"staff_room_unlocked": staff_room_unlocked,
		"staff_corridor_unlocked": staff_corridor_unlocked,
		"security_tape_assembly_started": security_tape_assembly_started,
		"security_tape_assembly_completed": security_tape_assembly_completed,
		"security_tape_wrong_order_count": security_tape_wrong_order_count,
		"final_night_walk_started": final_night_walk_started,
		"final_night_walk_completed": final_night_walk_completed,
		"staff_door_final_walk_anecdote_seen": staff_door_final_walk_anecdote_seen,
		"memory_echo_started": memory_echo_started,
		"memory_echo_completed": memory_echo_completed,
		"conscience_encounter_1_seen": conscience_encounter_1_seen,
		"conscience_encounter_2_seen": conscience_encounter_2_seen,
		"conscience_encounter_3_seen": conscience_encounter_3_seen,
		"conscience_encounter_4_seen": conscience_encounter_4_seen,
		"conscience_final_encounter_seen": conscience_final_encounter_seen,
		"conscience_final_room_seen": conscience_final_room_seen,
		"conscience_name_revealed": conscience_name_revealed,
		"player_glitched_form_unlocked": player_glitched_form_unlocked,
		"player_creator_monologue_seen": player_creator_monologue_seen,
		"twist_reveal_seen": twist_reveal_seen,
		"ending_seen": ending_seen,
		"post_reveal_roam_unlocked": post_reveal_roam_unlocked,
		"memory_signal_level": memory_signal_level,
		"mira_intro_seen": mira_intro_seen,
		"mira_post_reveal_seen": mira_post_reveal_seen,
		"gus_intro_seen": gus_intro_seen,
		"gus_post_reveal_seen": gus_post_reveal_seen,
		"vendo_intro_seen": vendo_intro_seen,
		"vendo_post_reveal_seen": vendo_post_reveal_seen,
		"roxy_met": roxy_met,
		"pip_met": pip_met,
		"pip_secret_started": pip_secret_started,
		"prize_echo_unlocked": prize_echo_unlocked,
		"pip_secret_completed": pip_secret_completed,
		"prize_sort_completed": prize_sort_completed,
		"pip_post_reveal_secret_seen": pip_post_reveal_secret_seen,
		"night_ledger_started": night_ledger_started,
		"night_ledger_completed": night_ledger_completed,
		"night_ledger_token_collected": night_ledger_token_collected,
		"night_ledger_debrief_seen": night_ledger_debrief_seen,
		"mira_rockbyte_anecdote_seen": mira_rockbyte_anecdote_seen,
		"mr_byte_truth_filter_anecdote_seen": mr_byte_truth_filter_anecdote_seen,
		"vendo_circuit_anecdote_seen": vendo_circuit_anecdote_seen,
		"vendo_unknown_clue_seen": vendo_unknown_clue_seen,
		"gus_sync_anecdote_seen": gus_sync_anecdote_seen,
		"memory_echo_anecdote_seen": memory_echo_anecdote_seen,
		"roxy_high_score_anecdote_seen": roxy_high_score_anecdote_seen,
		"pip_prize_anecdote_seen": pip_prize_anecdote_seen,
		"cabinet07_employee_hint_seen": cabinet07_employee_hint_seen,
		"mr_byte_intro_seen": mr_byte_intro_seen,
		"mr_byte_post_reveal_seen": mr_byte_post_reveal_seen,
		"broken_cabinet_secret_found": broken_cabinet_secret_found,
		"broken_high_score_completed": broken_high_score_completed,
		"owner_portrait_secret_found": owner_portrait_secret_found,
		"employee_04_file_found": employee_04_file_found,
		"vendo_memory_riddle_secret_found": vendo_memory_riddle_secret_found,
		"ssr_secret_cache_found": ssr_secret_cache_found,
		"tape_anomaly_frame_seen": tape_anomaly_frame_seen,
		"post_reveal_witness_route_completed": post_reveal_witness_route_completed,
		"staff_record_01_read": staff_record_01_read,
		"staff_record_02_read": staff_record_02_read,
		"staff_record_03_read": staff_record_03_read,
		"staff_records_chain_completed": staff_records_chain_completed,
		"witness_mira_heard": witness_mira_heard,
		"witness_gus_heard": witness_gus_heard,
		"witness_vendo_heard": witness_vendo_heard,
		"witness_mr_byte_heard": witness_mr_byte_heard,
		"witness_cabinet07_heard": witness_cabinet07_heard,
		"witness_roxy_heard": witness_roxy_heard,
		"witness_pip_heard": witness_pip_heard,
		"witness_route_completed": witness_route_completed,
		"echo_cabinet07_seen": echo_cabinet07_seen,
		"echo_owner_portrait_04_seen": echo_owner_portrait_04_seen,
		"opening_intro_seen": opening_intro_seen,
		"opening_npc_talks": opening_npc_talks,
		"opening_hint_monologue_seen": opening_hint_monologue_seen,
		"memory_signal_explainer_seen": memory_signal_explainer_seen,
		"midpoint_turn_seen": midpoint_turn_seen,
		"midpoint_told_mira": midpoint_told_mira,
		"gus_hub_checkin_truth_filter_done": gus_hub_checkin_truth_filter_done,
		"gus_hub_checkin_prize_sort_done": gus_hub_checkin_prize_sort_done,
		"roxy_truth_filter_nudge_seen": roxy_truth_filter_nudge_seen,
		"mr_byte_truth_filter_debriefed": mr_byte_truth_filter_debriefed,
		"route_cue_close_tip_seen": route_cue_close_tip_seen,
		"npc_dialogue_counts": npc_dialogue_counts.duplicate(true),
	}

func apply_save_data(data: Dictionary) -> void:
	save_slot_index = data.get("save_slot_index", save_slot_index)
	save_slot_name = data.get("save_slot_name", save_slot_name)
	save_timestamp = data.get("save_timestamp", save_timestamp)
	save_version = data.get("save_version", save_version)
	save_scene_name = data.get("save_scene_name", save_scene_name)
	save_player_position_x = data.get("save_player_position_x", save_player_position_x)
	save_player_position_y = data.get("save_player_position_y", save_player_position_y)
	save_player_facing = data.get("save_player_facing", save_player_facing)
	save_progress_stage = data.get("save_progress_stage", save_progress_stage)
	has_arcade_return_position = bool(data.get("has_arcade_return_position", has_arcade_return_position))
	arcade_return_position = Vector2(
		float(data.get("arcade_return_position_x", arcade_return_position.x)),
		float(data.get("arcade_return_position_y", arcade_return_position.y))
	)
	story_started = data.get("story_started", story_started)
	lost_token_quest_started = data.get("lost_token_quest_started", lost_token_quest_started)
	lost_token_collected = data.get("lost_token_collected", lost_token_collected)
	lost_token_quest_completed = data.get("lost_token_quest_completed", lost_token_quest_completed)
	rockbyte_duel_completed = data.get("rockbyte_duel_completed", rockbyte_duel_completed)
	rockbyte_duel_loss_count = int(data.get("rockbyte_duel_loss_count", rockbyte_duel_loss_count))
	rockbyte_attempt_count = int(data.get("rockbyte_attempt_count", rockbyte_attempt_count))
	truth_filter_quest_started = bool(data.get("truth_filter_quest_started", truth_filter_quest_started))
	lying_cabinets_completed = bool(data.get("lying_cabinets_completed", data.get("second_memory_fragment_collected", lying_cabinets_completed)))
	circuit_soda_started = bool(data.get("circuit_soda_started", circuit_soda_started))
	circuit_soda_completed = bool(data.get("circuit_soda_completed", circuit_soda_completed))
	lost_shift_file_started = bool(data.get("lost_shift_file_started", false))
	lost_shift_file_completed = bool(data.get("lost_shift_file_completed", false))
	var legacy_checklist_read := bool(data.get("closing_checklist_read", false))
	var legacy_maintenance_note_read := bool(data.get("maintenance_note_read", false))
	var legacy_staff_schedule_read := bool(data.get("staff_schedule_read", false))
	var has_ordered_clue_state := (
		data.has("closing_shift_mira_clue_found")
		or data.has("closing_shift_score_clue_found")
		or data.has("closing_shift_service_clue_found")
	)
	closing_shift_mira_clue_found = bool(data.get("closing_shift_mira_clue_found", false))
	closing_shift_score_clue_found = bool(data.get("closing_shift_score_clue_found", false))
	closing_shift_service_clue_found = bool(data.get("closing_shift_service_clue_found", false))
	if not has_ordered_clue_state:
		# Migrate the three retired document interactions into the equivalent
		# ordered evidence steps without discarding old player progress.
		closing_shift_mira_clue_found = legacy_checklist_read
		closing_shift_score_clue_found = legacy_staff_schedule_read
		closing_shift_service_clue_found = legacy_maintenance_note_read
	if legacy_checklist_read or legacy_maintenance_note_read or legacy_staff_schedule_read:
		lost_shift_file_started = true
	if legacy_checklist_read and legacy_maintenance_note_read and legacy_staff_schedule_read:
		lost_shift_file_completed = true
	if closing_shift_mira_clue_found or closing_shift_score_clue_found or closing_shift_service_clue_found:
		lost_shift_file_started = true
	static_service_run_started = bool(data.get("static_service_run_started", false))
	static_service_run_completed = bool(data.get("static_service_run_completed", false))
	gus_static_run_anecdote_seen = bool(data.get("gus_static_run_anecdote_seen", false))
	maintenance_sync_started = bool(data.get("maintenance_sync_started", maintenance_sync_started))
	maintenance_sync_completed = bool(data.get("maintenance_sync_completed", maintenance_sync_completed))
	story_puzzle_completed = data.get("story_puzzle_completed", story_puzzle_completed)
	if story_puzzle_completed:
		static_service_run_started = true
		static_service_run_completed = true
		maintenance_sync_started = true
		maintenance_sync_completed = true
	if maintenance_sync_completed:
		lost_shift_file_completed = true
		static_service_run_started = true
		static_service_run_completed = true
	staff_room_unlocked = data.get("staff_room_unlocked", staff_room_unlocked)
	staff_corridor_unlocked = bool(data.get("staff_corridor_unlocked", staff_room_unlocked or story_puzzle_completed))
	if static_service_run_started or lost_shift_file_completed:
		staff_corridor_unlocked = true
	security_tape_assembly_started = bool(data.get("security_tape_assembly_started", false))
	security_tape_assembly_completed = bool(data.get("security_tape_assembly_completed", false))
	security_tape_wrong_order_count = int(data.get("security_tape_wrong_order_count", security_tape_wrong_order_count))
	final_night_walk_started = bool(data.get("final_night_walk_started", false))
	final_night_walk_completed = bool(data.get("final_night_walk_completed", false))
	staff_door_final_walk_anecdote_seen = bool(data.get("staff_door_final_walk_anecdote_seen", false))
	memory_echo_started = bool(data.get("memory_echo_started", memory_echo_started))
	memory_echo_completed = bool(data.get("memory_echo_completed", memory_echo_completed))
	conscience_encounter_1_seen = bool(data.get("conscience_encounter_1_seen", conscience_encounter_1_seen))
	conscience_encounter_2_seen = bool(data.get("conscience_encounter_2_seen", conscience_encounter_2_seen))
	conscience_encounter_3_seen = bool(data.get("conscience_encounter_3_seen", conscience_encounter_3_seen))
	conscience_encounter_4_seen = bool(data.get("conscience_encounter_4_seen", conscience_encounter_4_seen))
	conscience_final_encounter_seen = bool(data.get("conscience_final_encounter_seen", conscience_final_encounter_seen))
	conscience_final_room_seen = bool(data.get("conscience_final_room_seen", conscience_final_room_seen))
	conscience_name_revealed = bool(data.get("conscience_name_revealed", conscience_name_revealed))
	player_glitched_form_unlocked = bool(data.get("player_glitched_form_unlocked", player_glitched_form_unlocked))
	player_creator_monologue_seen = bool(data.get("player_creator_monologue_seen", player_creator_monologue_seen))
	if security_tape_assembly_completed:
		lost_shift_file_completed = true
		static_service_run_started = true
		static_service_run_completed = true
		maintenance_sync_started = true
		maintenance_sync_completed = true
		story_puzzle_completed = true
		staff_corridor_unlocked = true
	if final_night_walk_completed:
		lost_shift_file_completed = true
		static_service_run_started = true
		static_service_run_completed = true
		maintenance_sync_started = true
		maintenance_sync_completed = true
		story_puzzle_completed = true
		staff_corridor_unlocked = true
		security_tape_assembly_started = true
		security_tape_assembly_completed = true
	if memory_echo_completed:
		lost_shift_file_completed = true
		static_service_run_started = true
		static_service_run_completed = true
		maintenance_sync_started = true
		maintenance_sync_completed = true
		story_puzzle_completed = true
		staff_corridor_unlocked = true
		staff_room_unlocked = true
		security_tape_assembly_started = true
		security_tape_assembly_completed = true
		final_night_walk_started = true
		final_night_walk_completed = true
	elif not twist_reveal_seen:
		staff_room_unlocked = false
	twist_reveal_seen = data.get("twist_reveal_seen", twist_reveal_seen)
	if twist_reveal_seen:
		lost_shift_file_completed = true
		static_service_run_started = true
		static_service_run_completed = true
		maintenance_sync_started = true
		maintenance_sync_completed = true
		story_puzzle_completed = true
		staff_corridor_unlocked = true
		staff_room_unlocked = true
		security_tape_assembly_started = true
		security_tape_assembly_completed = true
		final_night_walk_started = true
		final_night_walk_completed = true
		memory_echo_started = true
		memory_echo_completed = true
	ending_seen = data.get("ending_seen", ending_seen)
	post_reveal_roam_unlocked = data.get("post_reveal_roam_unlocked", post_reveal_roam_unlocked)
	set_memory_signal_level(int(data.get("memory_signal_level", memory_signal_level)))
	mira_intro_seen = data.get("mira_intro_seen", mira_intro_seen)
	mira_post_reveal_seen = data.get("mira_post_reveal_seen", mira_post_reveal_seen)
	gus_intro_seen = data.get("gus_intro_seen", gus_intro_seen)
	gus_post_reveal_seen = data.get("gus_post_reveal_seen", gus_post_reveal_seen)
	vendo_intro_seen = data.get("vendo_intro_seen", vendo_intro_seen)
	vendo_post_reveal_seen = data.get("vendo_post_reveal_seen", vendo_post_reveal_seen)
	roxy_met = bool(data.get("roxy_met", roxy_met))
	pip_met = bool(data.get("pip_met", pip_met))
	pip_secret_started = bool(data.get("pip_secret_started", pip_secret_started))
	prize_echo_unlocked = bool(data.get("prize_echo_unlocked", data.get("pip_secret_completed", pip_secret_completed)))
	pip_secret_completed = bool(data.get("pip_secret_completed", pip_secret_completed))
	prize_sort_completed = bool(data.get("prize_sort_completed", pip_secret_completed))
	if prize_sort_completed:
		prize_echo_unlocked = true
		pip_secret_completed = true
	pip_post_reveal_secret_seen = bool(data.get("pip_post_reveal_secret_seen", pip_post_reveal_secret_seen))
	night_ledger_started = bool(data.get("night_ledger_started", data.get("archive_history_started", night_ledger_started)))
	night_ledger_completed = bool(data.get("night_ledger_completed", data.get("archive_recall_completed", night_ledger_completed)))
	night_ledger_token_collected = bool(data.get("night_ledger_token_collected", data.get("archive_duplex_token_collected", night_ledger_completed)))
	night_ledger_debrief_seen = bool(data.get("night_ledger_debrief_seen", data.get("archive_history_debrief_seen", night_ledger_debrief_seen)))
	if night_ledger_completed:
		night_ledger_started = true
		night_ledger_token_collected = true
	mira_rockbyte_anecdote_seen = bool(data.get("mira_rockbyte_anecdote_seen", mira_rockbyte_anecdote_seen))
	mr_byte_truth_filter_anecdote_seen = bool(data.get("mr_byte_truth_filter_anecdote_seen", mr_byte_truth_filter_anecdote_seen))
	vendo_circuit_anecdote_seen = bool(data.get("vendo_circuit_anecdote_seen", vendo_circuit_anecdote_seen))
	vendo_unknown_clue_seen = bool(data.get("vendo_unknown_clue_seen", vendo_unknown_clue_seen))
	gus_sync_anecdote_seen = bool(data.get("gus_sync_anecdote_seen", gus_sync_anecdote_seen))
	memory_echo_anecdote_seen = bool(data.get("memory_echo_anecdote_seen", memory_echo_anecdote_seen))
	roxy_high_score_anecdote_seen = bool(data.get("roxy_high_score_anecdote_seen", roxy_high_score_anecdote_seen))
	pip_prize_anecdote_seen = bool(data.get("pip_prize_anecdote_seen", pip_prize_anecdote_seen))
	cabinet07_employee_hint_seen = data.get("cabinet07_employee_hint_seen", cabinet07_employee_hint_seen)
	mr_byte_intro_seen = data.get("mr_byte_intro_seen", mr_byte_intro_seen)
	mr_byte_post_reveal_seen = data.get("mr_byte_post_reveal_seen", mr_byte_post_reveal_seen)
	broken_cabinet_secret_found = data.get("broken_cabinet_secret_found", broken_cabinet_secret_found)
	broken_high_score_completed = bool(data.get("broken_high_score_completed", broken_high_score_completed))
	owner_portrait_secret_found = data.get("owner_portrait_secret_found", owner_portrait_secret_found)
	employee_04_file_found = data.get("employee_04_file_found", employee_04_file_found)
	vendo_memory_riddle_secret_found = data.get("vendo_memory_riddle_secret_found", vendo_memory_riddle_secret_found)
	ssr_secret_cache_found = bool(data.get("ssr_secret_cache_found", ssr_secret_cache_found))
	# Older saves stored this under the retired Final Night Walk name.
	tape_anomaly_frame_seen = bool(data.get("tape_anomaly_frame_seen", data.get("fnw_secret_echo_found", tape_anomaly_frame_seen)))
	post_reveal_witness_route_completed = bool(data.get("post_reveal_witness_route_completed", false))
	staff_record_01_read = bool(data.get("staff_record_01_read", false))
	staff_record_02_read = bool(data.get("staff_record_02_read", false))
	staff_record_03_read = bool(data.get("staff_record_03_read", false))
	staff_records_chain_completed = bool(data.get("staff_records_chain_completed", false))
	if staff_record_01_read and staff_record_02_read and staff_record_03_read:
		staff_records_chain_completed = true
	witness_mira_heard = bool(data.get("witness_mira_heard", false))
	witness_gus_heard = bool(data.get("witness_gus_heard", false))
	witness_vendo_heard = bool(data.get("witness_vendo_heard", false))
	witness_mr_byte_heard = bool(data.get("witness_mr_byte_heard", false))
	witness_cabinet07_heard = bool(data.get("witness_cabinet07_heard", false))
	witness_roxy_heard = bool(data.get("witness_roxy_heard", false))
	witness_pip_heard = bool(data.get("witness_pip_heard", false))
	witness_route_completed = bool(data.get("witness_route_completed", post_reveal_witness_route_completed))
	if post_reveal_witness_route_completed:
		witness_route_completed = true
	_complete_witness_route_if_ready()
	if witness_route_completed:
		post_reveal_witness_route_completed = true
	echo_cabinet07_seen = bool(data.get("echo_cabinet07_seen", echo_cabinet07_seen))
	echo_owner_portrait_04_seen = bool(data.get("echo_owner_portrait_04_seen", echo_owner_portrait_04_seen))
	opening_intro_seen = data.get("opening_intro_seen", opening_intro_seen)
	opening_npc_talks = int(data.get("opening_npc_talks", opening_npc_talks))
	opening_hint_monologue_seen = bool(data.get("opening_hint_monologue_seen", opening_hint_monologue_seen))
	memory_signal_explainer_seen = bool(data.get("memory_signal_explainer_seen", memory_signal_explainer_seen))
	midpoint_turn_seen = bool(data.get("midpoint_turn_seen", midpoint_turn_seen))
	midpoint_told_mira = bool(data.get("midpoint_told_mira", midpoint_told_mira))
	gus_hub_checkin_truth_filter_done = bool(data.get("gus_hub_checkin_truth_filter_done", gus_hub_checkin_truth_filter_done))
	gus_hub_checkin_prize_sort_done = bool(data.get("gus_hub_checkin_prize_sort_done", gus_hub_checkin_prize_sort_done))
	roxy_truth_filter_nudge_seen = bool(data.get("roxy_truth_filter_nudge_seen", roxy_truth_filter_nudge_seen))
	mr_byte_truth_filter_debriefed = bool(data.get("mr_byte_truth_filter_debriefed", mr_byte_truth_filter_debriefed))
	route_cue_close_tip_seen = bool(data.get("route_cue_close_tip_seen", route_cue_close_tip_seen))
	var dialogue_counts_value: Variant = data.get("npc_dialogue_counts", npc_dialogue_counts)
	if dialogue_counts_value is Dictionary:
		npc_dialogue_counts = dialogue_counts_value.duplicate(true)
	update_memory_signal_from_progress()
