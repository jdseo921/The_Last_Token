extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var dialogue_box: CanvasLayer = $DialogueBox
@onready var prompt_label: Label = $InteractionPrompt
@onready var hint_label: Label = $HintLabel

var save_slot_menu: Control = null
var choice_box: CanvasLayer = null
var pending_after_dialogue: Callable = Callable()

func _ready() -> void:
	player.interaction_prompt_changed.connect(_on_prompt_changed)
	dialogue_box.dialogue_finished.connect(_on_dialogue_finished)
	if GameState.rockbyte_duel_completed and not GameState.twist_reveal_seen:
		player.global_position = Vector2(240, 96)
	_on_prompt_changed("")
	_refresh_hint()

func _on_prompt_changed(text: String) -> void:
	prompt_label.text = text
	prompt_label.visible = not text.is_empty()

func start_dialogue(lines: Array, after_dialogue: Callable = Callable()) -> void:
	pending_after_dialogue = after_dialogue
	if player and player.has_method("set_control_enabled"):
		player.set_control_enabled(false)
	dialogue_box.start_dialogue(lines)

func _on_dialogue_finished() -> void:
	if pending_after_dialogue.is_valid():
		pending_after_dialogue.call()
		pending_after_dialogue = Callable()
	if player and player.has_method("set_control_enabled") and not _choice_box_is_open():
		player.set_control_enabled(true)
	_refresh_hint()

func _choice_box_is_open() -> bool:
	return choice_box != null and is_instance_valid(choice_box) and choice_box.visible

func _refresh_hint() -> void:
	hint_label.visible = not GameState.story_started

func handle_hub_interaction(interactable: Node, player_node: Node = null) -> void:
	match str(interactable.interactable_kind):
		"mira":
			_handle_mira()
		"gus":
			_handle_gus()
		"vendo":
			_handle_vendo()
		"mr_byte":
			_handle_mr_byte()
		"cabinet07":
			_handle_cabinet_07()
		"memory_terminal":
			_handle_memory_terminal()
		"staff_door":
			_handle_staff_door()
		"owner_portrait":
			_handle_owner_portrait()
		"broken_cabinet":
			_handle_broken_cabinet(interactable)
		_:
			start_dialogue([{"speaker": "System", "text": "Nothing happens."}])

func _handle_mira() -> void:
	if GameState.twist_reveal_seen:
		GameState.mira_post_reveal_seen = true
		start_dialogue([
			{"speaker": "Mira", "text": "You finally remembered."},
			{"speaker": "Mira", "text": "I was worried you would choose to disappear again."},
		])
		return
	if not GameState.lost_token_quest_started:
		GameState.mira_intro_seen = true
		start_dialogue([
			{"speaker": "Mira", "text": "Welcome to Pixel Haven. You're late again."},
			{"speaker": "Player", "text": "Again?"},
			{"speaker": "Mira", "text": "Never mind. Find the Lost Token before the lights go out."},
		], Callable(GameState, "start_lost_token_quest"))
		return
	if GameState.lost_token_quest_started and not GameState.lost_token_collected:
		start_dialogue([
			{"speaker": "Mira", "text": "Cabinet 07 is awake."},
			{"speaker": "Mira", "text": "It does not recognize customers. Only employees."},
		])
		return
	if GameState.lost_token_collected and not GameState.lost_token_quest_completed:
		start_dialogue([
			{"speaker": "Player", "text": "I found the token."},
			{"speaker": "Mira", "text": "Good. One memory is awake now."},
			{"speaker": "Mira", "text": "You really do not remember, do you?"},
		], Callable(GameState, "complete_lost_token_quest"))
		return
	start_dialogue([{"speaker": "Mira", "text": "Welcome to Pixel Haven."}])

func _handle_gus() -> void:
	if GameState.twist_reveal_seen:
		GameState.gus_post_reveal_seen = true
		start_dialogue([
			{"speaker": "Gus", "text": "About time."},
			{"speaker": "Gus", "text": "I was running out of ways to hint at it."},
		])
		return
	if GameState.lost_token_quest_completed:
		start_dialogue([
			{"speaker": "Gus", "text": "You walked into that back room once."},
			{"speaker": "Gus", "text": "You walked out different."},
			{"speaker": "Gus", "text": "Then you did not walk out at all."},
		])
		return
	GameState.gus_intro_seen = true
	start_dialogue([
		{"speaker": "Gus", "text": "You again? Great. The floor just stopped bleeding quarters."},
		{"speaker": "Gus", "text": "Try not to step in the glowing stuff. Last time, it learned your shoe size."},
	])

func _handle_vendo() -> void:
	if GameState.post_reveal_roam_unlocked and GameState.vendo_memory_riddle_secret_found:
		GameState.vendo_post_reveal_seen = true
		start_dialogue([
			{"speaker": "Vendo", "text": "Turns out MEMORY COLA was not a metaphor."},
			{"speaker": "Vendo", "text": "Legally, I should have put that on the label."},
		])
		return
	if GameState.twist_reveal_seen:
		GameState.vendo_post_reveal_seen = true
		start_dialogue([
			{"speaker": "Vendo", "text": "Congratulations."},
			{"speaker": "Vendo", "text": "You are officially both a customer and a stored file."},
		])
		return
	if GameState.vendo_memory_riddle_secret_found:
		GameState.vendo_intro_seen = true
		start_dialogue([
			{"speaker": "Vendo", "text": "Memory Cola is sold out."},
			{"speaker": "Vendo", "text": "Mostly because you keep losing it."},
		])
		return
	if GameState.lost_token_quest_started:
		GameState.vendo_intro_seen = true
		start_dialogue([
			{"speaker": "Vendo", "text": "Cabinet 07 does not recognize customers."},
			{"speaker": "Vendo", "text": "Only employees."},
			{"speaker": "Vendo", "text": "Care for a beverage-based psychological evaluation?"},
		], Callable(self, "_open_vendo_memory_riddle"))
		return
	GameState.vendo_intro_seen = true
	start_dialogue([
		{"speaker": "Vendo", "text": "Welcome, thirsty mortal. I sell soda, secrets, and emotionally unstable peanuts."},
		{"speaker": "Vendo", "text": "Please do not shake me. I contain carbonated beverages and unresolved trauma."},
		{"speaker": "Vendo", "text": "Care for a beverage-based psychological evaluation?"},
	], Callable(self, "_open_vendo_memory_riddle"))

func _open_vendo_memory_riddle() -> void:
	if GameState.vendo_memory_riddle_secret_found:
		return
	if choice_box and is_instance_valid(choice_box):
		choice_box.queue_free()
	choice_box = load("res://scenes/ui/ChoiceBox.tscn").instantiate()
	add_child(choice_box)
	if player and player.has_method("set_control_enabled"):
		player.set_control_enabled(false)
	if choice_box.has_signal("choice_selected"):
		choice_box.connect("choice_selected", _on_vendo_riddle_choice_selected, CONNECT_ONE_SHOT)
	if choice_box.has_method("open_choice"):
		choice_box.open_choice("What do you lose every time you return?", [
			"STATIC SODA",
			"MEMORY COLA",
			"TOKEN TEA",
			"REGRET JUICE",
		])

func _on_vendo_riddle_choice_selected(index: int) -> void:
	if choice_box and is_instance_valid(choice_box):
		choice_box.queue_free()
	choice_box = null
	if index == 1:
		GameState.vendo_memory_riddle_secret_found = true
		start_dialogue([
			{"speaker": "Vendo", "text": "Correct."},
			{"speaker": "Vendo", "text": "You lose memory."},
			{"speaker": "Vendo", "text": "I lose coins."},
			{"speaker": "Vendo", "text": "We all suffer in our own branded containers."},
		])
		return
	start_dialogue([
		{"speaker": "Vendo", "text": "Incorrect."},
		{"speaker": "Vendo", "text": "But emotionally marketable."},
		{"speaker": "Vendo", "text": "Try again after your next identity crisis."},
	])

func _handle_mr_byte() -> void:
	if GameState.twist_reveal_seen:
		GameState.mr_byte_post_reveal_seen = true
		GameState.employee_04_file_found = true
		start_dialogue([
			{"speaker": "Mr. Byte", "text": "Identity conflict resolved."},
			{"speaker": "Mr. Byte", "text": "Emotional damage remains unresolved."},
		])
		return
	GameState.mr_byte_intro_seen = true
	start_dialogue([
		{"speaker": "Mr. Byte", "text": "HELP MENU LOADED."},
		{"speaker": "Mr. Byte", "text": "Tip 1: Press buttons to cause consequences."},
		{"speaker": "Mr. Byte", "text": "Tip 2: Avoid consequences when possible."},
	])

func _handle_cabinet_07() -> void:
	if not GameState.lost_token_quest_started:
		GameState.cabinet07_employee_hint_seen = true
		start_dialogue([{"speaker": "Cabinet 07", "text": "INSERT PURPOSE."}])
		return
	if not GameState.rockbyte_duel_completed:
		SceneChanger.go_to_rockbyte_duel()
		return
	start_dialogue([
		{"speaker": "Cabinet 07", "text": "TOKEN ACCEPTED."},
		{"speaker": "Cabinet 07", "text": "PLAYER RECOGNIZED."},
		{"speaker": "Cabinet 07", "text": "WELCOME BACK, EMPLOYEE 04."},
	])

func _handle_memory_terminal() -> void:
	if save_slot_menu and is_instance_valid(save_slot_menu):
		save_slot_menu.queue_free()
	save_slot_menu = load("res://scenes/ui/SaveSlotMenu.tscn").instantiate()
	add_child(save_slot_menu)
	if player and player.has_method("set_control_enabled"):
		player.set_control_enabled(false)
	if save_slot_menu.has_signal("menu_closed"):
		save_slot_menu.menu_closed.connect(_on_save_slot_menu_closed, CONNECT_ONE_SHOT)
	if save_slot_menu.has_method("open_menu"):
		save_slot_menu.open_menu(true)

func _on_save_slot_menu_closed() -> void:
	if player and player.has_method("set_control_enabled"):
		player.set_control_enabled(true)
	save_slot_menu = null

func _handle_staff_door() -> void:
	if GameState.staff_room_unlocked:
		SceneChanger.go_to_staff_room()
		return
	if GameState.lost_token_quest_completed and GameState.rockbyte_duel_completed:
		SceneChanger.go_to_sync_door_puzzle()
		return
	start_dialogue([
		{"speaker": "Staff Door", "text": "TWO SIGNALS REQUIRED."},
		{"speaker": "Staff Door", "text": "MEMORY TOKEN NOT VERIFIED."},
	])

func _handle_owner_portrait() -> void:
	GameState.owner_portrait_secret_found = true
	start_dialogue([
		{"speaker": "Owner Portrait", "text": "The frame is cracked and the nameplate is scratched blank."},
	])

func _handle_broken_cabinet(interactable: Node) -> void:
	interactable.broken_interaction_count += 1
	if interactable.broken_interaction_count >= 5:
		GameState.broken_cabinet_secret_found = true
		start_dialogue([{"speaker": "Broken Cabinet", "text": "STOP PRESSING E. I AM TRYING TO REMEMBER MY CHILDHOOD."}])
		return
	if interactable.broken_interaction_count == 3:
		start_dialogue([{"speaker": "Broken Cabinet", "text": "STILL OUT OF ORDER."}])
		return
	start_dialogue([{"speaker": "Broken Cabinet", "text": "OUT OF ORDER."}])
