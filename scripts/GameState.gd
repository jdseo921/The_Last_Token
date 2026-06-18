extends Node

const ACTION_BINDINGS := {
	"move_up": [KEY_W, KEY_UP],
	"move_down": [KEY_S, KEY_DOWN],
	"move_left": [KEY_A, KEY_LEFT],
	"move_right": [KEY_D, KEY_RIGHT],
	"interact": [KEY_E, KEY_SPACE],
	"cancel": [KEY_ESCAPE, KEY_BACKSPACE],
}

var story_started := false
var lost_token_quest_started := false
var lost_token_collected := false
var lost_token_quest_completed := false
var rockbyte_duel_completed := false
var story_puzzle_completed := false
var staff_room_unlocked := false
var twist_reveal_seen := false
var ending_seen := false
var post_reveal_roam_unlocked := false

var mira_intro_seen := false
var mira_post_reveal_seen := false
var gus_intro_seen := false
var gus_post_reveal_seen := false
var vendo_intro_seen := false
var vendo_post_reveal_seen := false
var cabinet07_employee_hint_seen := false
var mr_byte_intro_seen := false
var mr_byte_post_reveal_seen := false

var broken_cabinet_secret_found := false
var owner_portrait_secret_found := false
var employee_04_file_found := false
var vendo_memory_riddle_secret_found := false

var save_slot_index := 0
var save_slot_name := ""
var save_timestamp := ""
var save_version := 1
var save_scene_name := ""
var save_player_position_x := 0.0
var save_player_position_y := 0.0
var save_player_facing := "down"
var save_progress_stage := "New Game"

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
	var completed := 0
	if lost_token_quest_completed:
		completed += 1
	if rockbyte_duel_completed:
		completed += 1
	if story_puzzle_completed:
		completed += 1
	return completed

func get_total_games_count() -> int:
	return 3

func get_secrets_found_count() -> int:
	var found := 0
	if broken_cabinet_secret_found:
		found += 1
	if owner_portrait_secret_found:
		found += 1
	if employee_04_file_found:
		found += 1
	if vendo_memory_riddle_secret_found:
		found += 1
	return found

func get_total_secrets_count() -> int:
	return 4

func get_story_phase_label() -> String:
	if ending_seen:
		return "Ending"
	if twist_reveal_seen:
		return "Post-Reveal"
	if staff_room_unlocked:
		return "Staff Access"
	if story_puzzle_completed:
		return "Clue Solved"
	if lost_token_quest_completed:
		return "Quest Complete"
	if lost_token_quest_started:
		return "Quest Active"
	if story_started:
		return "Story Started"
	return "New Game"

func start_lost_token_quest() -> void:
	story_started = true
	lost_token_quest_started = true

func collect_lost_token() -> void:
	lost_token_collected = true

func complete_lost_token_quest() -> void:
	lost_token_quest_started = true
	lost_token_collected = true
	lost_token_quest_completed = true

func unlock_staff_room() -> void:
	staff_room_unlocked = true

func mark_twist_reveal_seen() -> void:
	twist_reveal_seen = true

func unlock_post_reveal_roam() -> void:
	post_reveal_roam_unlocked = true

func to_save_data() -> Dictionary:
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
		"story_started": story_started,
		"lost_token_quest_started": lost_token_quest_started,
		"lost_token_collected": lost_token_collected,
		"lost_token_quest_completed": lost_token_quest_completed,
		"rockbyte_duel_completed": rockbyte_duel_completed,
		"story_puzzle_completed": story_puzzle_completed,
		"staff_room_unlocked": staff_room_unlocked,
		"twist_reveal_seen": twist_reveal_seen,
		"ending_seen": ending_seen,
		"post_reveal_roam_unlocked": post_reveal_roam_unlocked,
		"mira_intro_seen": mira_intro_seen,
		"mira_post_reveal_seen": mira_post_reveal_seen,
		"gus_intro_seen": gus_intro_seen,
		"gus_post_reveal_seen": gus_post_reveal_seen,
		"vendo_intro_seen": vendo_intro_seen,
		"vendo_post_reveal_seen": vendo_post_reveal_seen,
		"cabinet07_employee_hint_seen": cabinet07_employee_hint_seen,
		"mr_byte_intro_seen": mr_byte_intro_seen,
		"mr_byte_post_reveal_seen": mr_byte_post_reveal_seen,
		"broken_cabinet_secret_found": broken_cabinet_secret_found,
		"owner_portrait_secret_found": owner_portrait_secret_found,
		"employee_04_file_found": employee_04_file_found,
		"vendo_memory_riddle_secret_found": vendo_memory_riddle_secret_found,
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
	story_started = data.get("story_started", story_started)
	lost_token_quest_started = data.get("lost_token_quest_started", lost_token_quest_started)
	lost_token_collected = data.get("lost_token_collected", lost_token_collected)
	lost_token_quest_completed = data.get("lost_token_quest_completed", lost_token_quest_completed)
	rockbyte_duel_completed = data.get("rockbyte_duel_completed", rockbyte_duel_completed)
	story_puzzle_completed = data.get("story_puzzle_completed", story_puzzle_completed)
	staff_room_unlocked = data.get("staff_room_unlocked", staff_room_unlocked)
	twist_reveal_seen = data.get("twist_reveal_seen", twist_reveal_seen)
	ending_seen = data.get("ending_seen", ending_seen)
	post_reveal_roam_unlocked = data.get("post_reveal_roam_unlocked", post_reveal_roam_unlocked)
	mira_intro_seen = data.get("mira_intro_seen", mira_intro_seen)
	mira_post_reveal_seen = data.get("mira_post_reveal_seen", mira_post_reveal_seen)
	gus_intro_seen = data.get("gus_intro_seen", gus_intro_seen)
	gus_post_reveal_seen = data.get("gus_post_reveal_seen", gus_post_reveal_seen)
	vendo_intro_seen = data.get("vendo_intro_seen", vendo_intro_seen)
	vendo_post_reveal_seen = data.get("vendo_post_reveal_seen", vendo_post_reveal_seen)
	cabinet07_employee_hint_seen = data.get("cabinet07_employee_hint_seen", cabinet07_employee_hint_seen)
	mr_byte_intro_seen = data.get("mr_byte_intro_seen", mr_byte_intro_seen)
	mr_byte_post_reveal_seen = data.get("mr_byte_post_reveal_seen", mr_byte_post_reveal_seen)
	broken_cabinet_secret_found = data.get("broken_cabinet_secret_found", broken_cabinet_secret_found)
	owner_portrait_secret_found = data.get("owner_portrait_secret_found", owner_portrait_secret_found)
	employee_04_file_found = data.get("employee_04_file_found", employee_04_file_found)
	vendo_memory_riddle_secret_found = data.get("vendo_memory_riddle_secret_found", vendo_memory_riddle_secret_found)
