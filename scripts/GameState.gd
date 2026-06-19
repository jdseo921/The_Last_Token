extends Node

const ACTION_BINDINGS := {
	"move_up": [KEY_W, KEY_UP],
	"move_down": [KEY_S, KEY_DOWN],
	"move_left": [KEY_A, KEY_LEFT],
	"move_right": [KEY_D, KEY_RIGHT],
	"interact": [KEY_E, KEY_SPACE],
	"cancel": [KEY_ESCAPE, KEY_BACKSPACE],
}

const TOTAL_GAMES_COUNT := 3
const TOTAL_SECRETS_COUNT := 4

var story_started := false
var lost_token_quest_started := false
var lost_token_collected := false
var lost_token_quest_completed := false
var rockbyte_duel_completed := false
var rockbyte_duel_loss_count := 0
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
var has_arcade_return_position := false
var arcade_return_position := Vector2.ZERO
var opening_intro_seen := false
var last_announced_quest_id := ""

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
	if bool(data.get("story_puzzle_completed", false)):
		completed += 1
	if bool(data.get("twist_reveal_seen", false)):
		completed += 1
	return completed

func get_total_games_count() -> int:
	return TOTAL_GAMES_COUNT

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
	return found

func get_total_secrets_count() -> int:
	return TOTAL_SECRETS_COUNT

func get_story_phase_label() -> String:
	return get_story_phase_label_from_data(to_save_data())

func get_story_phase_label_from_data(data: Dictionary) -> String:
	if bool(data.get("post_reveal_roam_unlocked", false)):
		return "Post-Reveal Roam"
	if bool(data.get("ending_seen", false)):
		return "Ending"
	if bool(data.get("twist_reveal_seen", false)):
		return "Truth Revealed"
	if bool(data.get("staff_room_unlocked", false)):
		return "Staff Room"
	if bool(data.get("story_puzzle_completed", false)):
		return "Sync Door Solved"
	if bool(data.get("lost_token_quest_completed", false)):
		return "Lost Token Returned"
	if bool(data.get("rockbyte_duel_completed", false)) or bool(data.get("lost_token_collected", false)):
		return "Lost Token Found"
	if bool(data.get("lost_token_quest_started", false)):
		return "Cabinet 07"
	if bool(data.get("story_started", false)):
		return "Opening Night"
	return "New Memory"

func reset_for_new_game() -> void:
	story_started = false
	lost_token_quest_started = false
	lost_token_collected = false
	lost_token_quest_completed = false
	rockbyte_duel_completed = false
	rockbyte_duel_loss_count = 0
	story_puzzle_completed = false
	staff_room_unlocked = false
	twist_reveal_seen = false
	ending_seen = false
	post_reveal_roam_unlocked = false
	mira_intro_seen = false
	mira_post_reveal_seen = false
	gus_intro_seen = false
	gus_post_reveal_seen = false
	vendo_intro_seen = false
	vendo_post_reveal_seen = false
	cabinet07_employee_hint_seen = false
	mr_byte_intro_seen = false
	mr_byte_post_reveal_seen = false
	broken_cabinet_secret_found = false
	owner_portrait_secret_found = false
	employee_04_file_found = false
	vendo_memory_riddle_secret_found = false
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
	clear_arcade_return_position()

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

func unlock_staff_room() -> void:
	staff_room_unlocked = true

func mark_twist_reveal_seen() -> void:
	twist_reveal_seen = true

func unlock_post_reveal_roam() -> void:
	post_reveal_roam_unlocked = true

func mark_opening_intro_seen() -> void:
	opening_intro_seen = true

func get_current_quest_id() -> String:
	if not story_started:
		return "opening_talk_to_mira"
	if lost_token_quest_started and not rockbyte_duel_completed:
		return "recover_lost_token"
	if rockbyte_duel_completed and not lost_token_quest_completed:
		return "return_lost_token"
	if lost_token_quest_completed and not story_puzzle_completed:
		return "check_staff_door"
	if story_puzzle_completed and staff_room_unlocked and not twist_reveal_seen:
		return "enter_staff_room"
	if twist_reveal_seen and not post_reveal_roam_unlocked:
		return "finish_memory"
	if post_reveal_roam_unlocked:
		return "talk_to_witnesses"
	return ""

func get_current_quest_data() -> Dictionary:
	match get_current_quest_id():
		"opening_talk_to_mira":
			return {
				"id": "opening_talk_to_mira",
				"title": "Find Mira",
				"summary": "Talk to Mira at the ticket counter.",
				"details": "Pixel Haven is closed, but Mira seems to know me. I should talk to her at the ticket counter.",
			}
		"recover_lost_token":
			return {
				"id": "recover_lost_token",
				"title": "Recover the Lost Token",
				"summary": "Play Cabinet 07.",
				"details": "Mira says Cabinet 07 has my Lost Token. I need to play it and bring the token back to her.",
			}
		"return_lost_token":
			return {
				"id": "return_lost_token",
				"title": "Return the Lost Token",
				"summary": "Bring the token back to Mira.",
				"details": "Cabinet 07 released the Lost Token. Mira is waiting for it by the ticket counter.",
			}
		"check_staff_door":
			return {
				"id": "check_staff_door",
				"title": "Check the Staff Door",
				"summary": "Inspect the Staff Door.",
				"details": "Mira remembered something when the token returned. The Staff Door should be listening now.",
			}
		"enter_staff_room":
			return {
				"id": "enter_staff_room",
				"title": "Enter the Staff Room",
				"summary": "Return to the Staff Door.",
				"details": "Both switches are active and the Staff Room is unlocked. I should go inside.",
			}
		"finish_memory":
			return {
				"id": "finish_memory",
				"title": "Finish the Memory",
				"summary": "Let the memory settle.",
				"details": "The truth is visible now. I need to let this memory finish and see what remains afterward.",
			}
		"talk_to_witnesses":
			return {
				"id": "talk_to_witnesses",
				"title": "Talk to Those Who Remembered",
				"summary": "Speak with the remaining witnesses.",
				"details": "Pixel Haven remembers me differently now. Mira, Gus, Vendo, and Mr. Byte may have changed things to say.",
			}
		_:
			return {
				"id": "",
				"title": "No Active Quest",
				"summary": "There is no current objective.",
				"details": "There is no active quest right now.",
			}

func mark_current_quest_announced() -> void:
	last_announced_quest_id = get_current_quest_id()

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
		"has_arcade_return_position": has_arcade_return_position,
		"arcade_return_position_x": arcade_return_position.x,
		"arcade_return_position_y": arcade_return_position.y,
		"story_started": story_started,
		"lost_token_quest_started": lost_token_quest_started,
		"lost_token_collected": lost_token_collected,
		"lost_token_quest_completed": lost_token_quest_completed,
		"rockbyte_duel_completed": rockbyte_duel_completed,
		"rockbyte_duel_loss_count": rockbyte_duel_loss_count,
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
		"opening_intro_seen": opening_intro_seen,
		"last_announced_quest_id": last_announced_quest_id,
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
	opening_intro_seen = data.get("opening_intro_seen", opening_intro_seen)
	last_announced_quest_id = str(data.get("last_announced_quest_id", last_announced_quest_id))
