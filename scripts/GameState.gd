extends Node

const QUEST_REGISTRY := preload("res://scripts/QuestRegistry.gd")

const ACTION_BINDINGS := {
	"move_up": [KEY_W, KEY_UP],
	"move_down": [KEY_S, KEY_DOWN],
	"move_left": [KEY_A, KEY_LEFT],
	"move_right": [KEY_D, KEY_RIGHT],
	"interact": [KEY_E, KEY_SPACE],
	"cancel": [KEY_ESCAPE, KEY_BACKSPACE],
}

const TOTAL_GAMES_COUNT := 4
const TOTAL_REQUIRED_PROGRESS_COUNT := 10
const TOTAL_OPTIONAL_GAMES_COUNT := 2
const TOTAL_SECRETS_COUNT := 5
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
var truth_filter_quest_started := false
var lying_cabinets_completed := false
var second_memory_fragment_collected := false
var circuit_soda_started := false
var circuit_soda_completed := false
var lost_shift_file_started := false
var lost_shift_file_completed := false
var closing_checklist_read := false
var maintenance_note_read := false
var staff_schedule_read := false
var mira_lost_shift_intro_seen := false
var gus_lost_shift_comment_seen := false
var mr_byte_lost_shift_comment_seen := false
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
var pip_secret_completed := false
var prize_sort_completed := false
var pip_post_reveal_secret_seen := false
var mira_rockbyte_anecdote_seen := false
var mr_byte_truth_filter_anecdote_seen := false
var vendo_circuit_anecdote_seen := false
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
var echo_ticket_counter_seen := false
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
var opening_intro_seen := false
var last_announced_quest_id := ""
var npc_dialogue_counts: Dictionary = {}
var pending_spawn_id := ""

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
	if bool(data.get("lying_cabinets_completed", false)):
		completed += 1
	if bool(data.get("circuit_soda_completed", false)):
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
	var completed := 0
	if bool(data.get("broken_high_score_completed", false)):
		completed += 1
	if bool(data.get("prize_sort_completed", false)):
		completed += 1
	return completed

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
		return "Final Night Walk"
	if bool(data.get("staff_corridor_unlocked", false)):
		return "Security Tape Assembly"
	if bool(data.get("story_puzzle_completed", false)):
		return "Staff Corridor"
	if bool(data.get("static_service_run_completed", false)):
		return "Maintenance Sync"
	if _is_lost_shift_file_complete_in_data(data):
		return "Static Service Run"
	if bool(data.get("circuit_soda_completed", false)) and not _is_lost_shift_file_complete_in_data(data):
		return "Lost Shift File"
	if bool(data.get("circuit_soda_completed", false)):
		return "Lost Shift File"
	if bool(data.get("second_memory_fragment_collected", false)) or bool(data.get("lying_cabinets_completed", false)):
		return "Truth Filter Cleared"
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
	if bool(data.get("staff_corridor_unlocked", false)) or bool(data.get("story_puzzle_completed", false)) or bool(data.get("maintenance_sync_completed", false)):
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
	truth_filter_quest_started = false
	lying_cabinets_completed = false
	second_memory_fragment_collected = false
	circuit_soda_started = false
	circuit_soda_completed = false
	lost_shift_file_started = false
	lost_shift_file_completed = false
	closing_checklist_read = false
	maintenance_note_read = false
	staff_schedule_read = false
	mira_lost_shift_intro_seen = false
	gus_lost_shift_comment_seen = false
	mr_byte_lost_shift_comment_seen = false
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
	pip_secret_completed = false
	prize_sort_completed = false
	pip_post_reveal_secret_seen = false
	mira_rockbyte_anecdote_seen = false
	mr_byte_truth_filter_anecdote_seen = false
	vendo_circuit_anecdote_seen = false
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
	echo_ticket_counter_seen = false
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
	last_announced_quest_id = ""
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

func set_arcade_return_position(position: Vector2) -> void:
	arcade_return_position = position
	has_arcade_return_position = true

func clear_arcade_return_position() -> void:
	arcade_return_position = Vector2.ZERO
	has_arcade_return_position = false

func start_lost_token_quest() -> void:
	story_started = true
	lost_token_quest_started = true

func collect_lost_token() -> void:
	lost_token_collected = true

func complete_lost_token_quest() -> void:
	lost_token_quest_started = true
	lost_token_collected = true
	lost_token_quest_completed = true
	truth_filter_quest_started = true
	update_memory_signal_from_progress()

func complete_truth_filter() -> void:
	truth_filter_quest_started = true
	lying_cabinets_completed = true
	second_memory_fragment_collected = true
	update_memory_signal_from_progress()

func start_circuit_soda() -> void:
	circuit_soda_started = true
	update_memory_signal_from_progress()

func complete_circuit_soda() -> void:
	circuit_soda_started = true
	circuit_soda_completed = true
	lost_shift_file_started = true
	update_memory_signal_from_progress()

func start_lost_shift_file() -> void:
	lost_shift_file_started = true

func read_closing_checklist() -> void:
	lost_shift_file_started = true
	closing_checklist_read = true
	_complete_lost_shift_file_if_ready()

func read_maintenance_note() -> void:
	lost_shift_file_started = true
	maintenance_note_read = true
	_complete_lost_shift_file_if_ready()

func read_staff_schedule() -> void:
	lost_shift_file_started = true
	staff_schedule_read = true
	_complete_lost_shift_file_if_ready()

func _complete_lost_shift_file_if_ready() -> void:
	if closing_checklist_read and maintenance_note_read and staff_schedule_read:
		lost_shift_file_completed = true

func start_static_service_run() -> void:
	static_service_run_started = true
	update_memory_signal_from_progress()

func complete_static_service_run() -> void:
	static_service_run_started = true
	static_service_run_completed = true
	update_memory_signal_from_progress()

func start_maintenance_sync() -> void:
	maintenance_sync_started = true
	update_memory_signal_from_progress()

func complete_maintenance_sync() -> void:
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
	security_tape_assembly_started = true
	security_tape_assembly_completed = true
	update_memory_signal_from_progress()

func start_final_night_walk() -> void:
	final_night_walk_started = true
	update_memory_signal_from_progress()

func complete_final_night_walk() -> void:
	final_night_walk_started = true
	final_night_walk_completed = true
	update_memory_signal_from_progress()

func start_memory_echo() -> void:
	memory_echo_started = true
	update_memory_signal_from_progress()

func complete_memory_echo() -> void:
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
		"after_final_night_walk":
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
		"after_final_night_walk":
			return conscience_encounter_4_seen
		"final_conscience":
			return conscience_final_encounter_seen or conscience_final_room_seen
		_:
			return false

func unlock_player_glitched_form() -> void:
	player_glitched_form_unlocked = true

func should_use_glitched_player_sprite() -> bool:
	return player_glitched_form_unlocked or post_reveal_roam_unlocked or twist_reveal_seen

func complete_broken_high_score() -> void:
	broken_high_score_completed = true

func complete_pip_secret() -> void:
	pip_secret_started = true
	pip_secret_completed = true
	prize_sort_completed = true

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

func unlock_staff_room() -> void:
	staff_room_unlocked = true
	staff_corridor_unlocked = true
	update_memory_signal_from_progress()

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

func get_current_quest_id() -> String:
	if not story_started:
		return "opening_talk_to_mira"
	if lost_token_quest_started and not rockbyte_duel_completed:
		return "recover_lost_token"
	if rockbyte_duel_completed and not lost_token_quest_completed:
		return "return_lost_token"
	if lost_token_quest_completed and not lying_cabinets_completed:
		return "truth_filter"
	if lying_cabinets_completed and not circuit_soda_completed:
		return "circuit_soda"
	if circuit_soda_completed and not lost_shift_file_completed and not maintenance_sync_completed and not story_puzzle_completed:
		return "lost_shift_file"
	if lost_shift_file_completed and not static_service_run_completed and not maintenance_sync_completed and not story_puzzle_completed:
		return "static_service_run"
	if static_service_run_completed and not maintenance_sync_completed and not story_puzzle_completed:
		return "maintenance_sync"
	if maintenance_sync_completed and not security_tape_assembly_completed and not memory_echo_completed:
		return "security_tape_assembly"
	if security_tape_assembly_completed and not final_night_walk_completed and not memory_echo_completed:
		return "final_night_walk"
	if final_night_walk_completed and not memory_echo_completed:
		return "stabilize_memory_echo"
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
				"summary": "Play Cabinet 07.",
				"details": "Mira says Cabinet 07 has my Lost Token. I need to play it and bring the token back to her.",
			}, "lost_token")
		"return_lost_token":
			return _with_registry_quest_data({
				"id": "return_lost_token",
				"title": "Return the Lost Token",
				"summary": "Bring the token back to Mira.",
				"details": "Cabinet 07 released the Lost Token. Mira is waiting for it by the ticket counter.",
			}, "lost_token")
		"maintenance_sync":
			return _with_registry_quest_data({
				"id": "maintenance_sync",
				"title": "Maintenance Sync",
				"summary": "Help Gus stabilize the Staff Door signals.",
				"details": "Vendo routed the signal, but the Staff Door still needs two unstable signals to line up. Gus says the door is listening for something doubled.",
			}, "maintenance_sync")
		"static_service_run":
			return _with_registry_quest_data({
				"id": "static_service_run",
				"title": "Static Service Run",
				"summary": "Restore service power for the Staff Door systems.",
				"details": "The Lost Shift File gave Gus enough context to work with the door, but the maintenance system still needs power. Run the service route and recover the Signal Fuses.",
			}, "static_service_run")
		"lost_shift_file":
			return {
				"id": "lost_shift_file",
				"title": "Lost Shift File",
				"owner": "Mira / Gus / Mr. Byte",
				"location": "ArcadeHub, Maintenance Hall, Cabinet Row",
				"summary": "Read the records from the Final Night.",
				"details": "The signal is routed, but the Staff Door still refuses to open. Three records from the Final Night may explain why.",
				"required": true,
				"starts_after": "circuit_soda_completed",
				"minigame": "None",
				"memory_signal_after": "Fractured",
			}
		"staff_corridor":
			return _with_registry_quest_data({
				"id": "staff_corridor",
				"title": "Enter the Staff Corridor",
				"summary": "Follow the Overloaded signal past the Staff Door.",
				"details": "Gus stabilized the door, but the arcade is not ready to show the Staff Room yet. Something is echoing in the corridor.",
			}, "staff_corridor")
		"security_tape_assembly":
			return {
				"id": "security_tape_assembly",
				"title": "Assemble the Security Tape",
				"owner": "Staff Door / Mr. Byte",
				"location": "Staff Corridor",
				"summary": "Restore the damaged Final Night sequence.",
				"details": "The Staff Door recorded two signals, but the tape is damaged. Assemble the fragments before confronting the Memory Echo.",
				"required": true,
				"starts_after": "maintenance_sync_completed",
				"minigame": "Security Tape Assembly",
				"memory_signal_after": "Overloaded",
			}
		"final_night_walk":
			return _with_registry_quest_data({
				"id": "final_night_walk",
				"title": "Final Night Walk",
				"summary": "Walk through the reconstructed Final Night.",
				"details": "The security tape is assembled, but the memory is still too unstable to play back. Walk the reconstructed route before confronting the Memory Echo.",
			}, "final_night_walk")
		"stabilize_memory_echo":
			return _with_registry_quest_data({
				"id": "stabilize_memory_echo",
				"title": "Stabilize the Memory Echo",
				"summary": "Stabilize the Memory Echo.",
				"details": "The Final Night route is stable. The Memory Echo can now stabilize the signal before the Staff Room reveals what happened.",
			}, "memory_echo")
		"circuit_soda":
			return _with_registry_quest_data({
				"id": "circuit_soda",
				"title": "Route the Signal",
				"summary": "Help Vendo stabilize the memory signal.",
				"details": "The Truth Filter recovered a second fragment, but the signal is still misrouted. Vendo says the arcade can move a memory through the wrong machine and still recognize the flavor.",
			}, "circuit_soda")
		"truth_filter":
			return _with_registry_quest_data({
				"id": "truth_filter",
				"title": "Open the Truth Filter",
				"summary": "Find Mr. Byte in Cabinet Row.",
				"details": "The Lost Token woke a memory, but Mira says the arcade is still filtering the truth. Mr. Byte can open the Truth Filter in Cabinet Row.",
			}, "truth_filter")
		"enter_staff_room":
			return _with_registry_quest_data({
				"id": "enter_staff_room",
				"title": "Enter the Staff Room",
				"summary": "Enter the Staff Room.",
				"details": "The echo in the corridor stabilized. The Staff Room door is ready.",
			}, "staff_corridor")
		"finish_memory":
			return {
				"id": "finish_memory",
				"title": "Finish the Memory",
				"summary": "Let the memory settle.",
				"details": "The truth is visible now. I need to let this memory finish and see what remains afterward.",
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

func mark_current_quest_announced() -> void:
	last_announced_quest_id = get_current_quest_id()

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
	if staff_corridor_unlocked or story_puzzle_completed:
		set_memory_signal_level(MEMORY_SIGNAL_OVERLOADED)
		return
	if lying_cabinets_completed or second_memory_fragment_collected:
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
		"truth_filter_quest_started": truth_filter_quest_started,
		"lying_cabinets_completed": lying_cabinets_completed,
		"second_memory_fragment_collected": second_memory_fragment_collected,
		"circuit_soda_started": circuit_soda_started,
		"circuit_soda_completed": circuit_soda_completed,
		"lost_shift_file_started": lost_shift_file_started,
		"lost_shift_file_completed": lost_shift_file_completed,
		"closing_checklist_read": closing_checklist_read,
		"maintenance_note_read": maintenance_note_read,
		"staff_schedule_read": staff_schedule_read,
		"mira_lost_shift_intro_seen": mira_lost_shift_intro_seen,
		"gus_lost_shift_comment_seen": gus_lost_shift_comment_seen,
		"mr_byte_lost_shift_comment_seen": mr_byte_lost_shift_comment_seen,
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
		"pip_secret_completed": pip_secret_completed,
		"prize_sort_completed": prize_sort_completed,
		"pip_post_reveal_secret_seen": pip_post_reveal_secret_seen,
		"mira_rockbyte_anecdote_seen": mira_rockbyte_anecdote_seen,
		"mr_byte_truth_filter_anecdote_seen": mr_byte_truth_filter_anecdote_seen,
		"vendo_circuit_anecdote_seen": vendo_circuit_anecdote_seen,
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
		"echo_ticket_counter_seen": echo_ticket_counter_seen,
		"echo_cabinet07_seen": echo_cabinet07_seen,
		"echo_owner_portrait_04_seen": echo_owner_portrait_04_seen,
		"opening_intro_seen": opening_intro_seen,
		"last_announced_quest_id": last_announced_quest_id,
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
	truth_filter_quest_started = bool(data.get("truth_filter_quest_started", truth_filter_quest_started))
	lying_cabinets_completed = bool(data.get("lying_cabinets_completed", lying_cabinets_completed))
	second_memory_fragment_collected = bool(data.get("second_memory_fragment_collected", second_memory_fragment_collected))
	circuit_soda_started = bool(data.get("circuit_soda_started", circuit_soda_started))
	circuit_soda_completed = bool(data.get("circuit_soda_completed", circuit_soda_completed))
	lost_shift_file_started = bool(data.get("lost_shift_file_started", false))
	lost_shift_file_completed = bool(data.get("lost_shift_file_completed", false))
	closing_checklist_read = bool(data.get("closing_checklist_read", false))
	maintenance_note_read = bool(data.get("maintenance_note_read", false))
	staff_schedule_read = bool(data.get("staff_schedule_read", false))
	mira_lost_shift_intro_seen = bool(data.get("mira_lost_shift_intro_seen", false))
	gus_lost_shift_comment_seen = bool(data.get("gus_lost_shift_comment_seen", false))
	mr_byte_lost_shift_comment_seen = bool(data.get("mr_byte_lost_shift_comment_seen", false))
	if closing_checklist_read or maintenance_note_read or staff_schedule_read:
		lost_shift_file_started = true
	if closing_checklist_read and maintenance_note_read and staff_schedule_read:
		lost_shift_file_completed = true
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
	pip_secret_completed = bool(data.get("pip_secret_completed", pip_secret_completed))
	prize_sort_completed = bool(data.get("prize_sort_completed", pip_secret_completed))
	if prize_sort_completed:
		pip_secret_completed = true
	pip_post_reveal_secret_seen = bool(data.get("pip_post_reveal_secret_seen", pip_post_reveal_secret_seen))
	mira_rockbyte_anecdote_seen = bool(data.get("mira_rockbyte_anecdote_seen", mira_rockbyte_anecdote_seen))
	mr_byte_truth_filter_anecdote_seen = bool(data.get("mr_byte_truth_filter_anecdote_seen", mr_byte_truth_filter_anecdote_seen))
	vendo_circuit_anecdote_seen = bool(data.get("vendo_circuit_anecdote_seen", vendo_circuit_anecdote_seen))
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
	echo_ticket_counter_seen = bool(data.get("echo_ticket_counter_seen", echo_ticket_counter_seen))
	echo_cabinet07_seen = bool(data.get("echo_cabinet07_seen", echo_cabinet07_seen))
	echo_owner_portrait_04_seen = bool(data.get("echo_owner_portrait_04_seen", echo_owner_portrait_04_seen))
	opening_intro_seen = data.get("opening_intro_seen", opening_intro_seen)
	last_announced_quest_id = str(data.get("last_announced_quest_id", last_announced_quest_id))
	var dialogue_counts_value: Variant = data.get("npc_dialogue_counts", npc_dialogue_counts)
	if dialogue_counts_value is Dictionary:
		npc_dialogue_counts = dialogue_counts_value.duplicate(true)
	update_memory_signal_from_progress()
