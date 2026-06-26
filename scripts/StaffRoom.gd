extends Node2D

const SLIDESHOW_SCENE := preload("res://scenes/cutscenes/SlideshowCutscene.tscn")
const ENDING_PROMPT_SCENE := preload("res://scenes/cutscenes/EndingPrompt.tscn")
const DIALOGUE_BOX_SCENE := preload("res://scenes/ui/DialogueBox.tscn")
const DIALOGUE_POOL := preload("res://scripts/DialoguePool.gd")
const MEMORY_REVEAL_PANEL_DIR := "res://assets/art/cutscenes/memory_reveal/"

@onready var player: CharacterBody2D = $Player
@onready var prompt_label: Label = $InteractionPrompt
@onready var return_button: Button = $Panel/ReturnButton

var active_cutscene: Node = null
var active_dialogue_box: Node = null
var reveal_in_progress := false

func _ready() -> void:
	AudioManager.play_music_for_context("staff_room")
	if player and player.has_signal("interaction_prompt_changed"):
		player.interaction_prompt_changed.connect(_on_prompt_changed)
	return_button.pressed.connect(_on_return_pressed)
	_apply_spawn_position()
	_on_prompt_changed("")

func _on_prompt_changed(text: String) -> void:
	prompt_label.text = text
	prompt_label.visible = not text.is_empty()

func can_open_pause_menu() -> bool:
	return active_dialogue_box == null and active_cutscene == null and not reveal_in_progress

func _apply_spawn_position() -> void:
	var spawn_id := GameState.consume_pending_spawn_id("Spawn_Default")
	var marker := get_node_or_null(spawn_id)
	if marker is Marker2D:
		player.global_position = marker.global_position

func handle_hub_interaction(interactable: Node, player_node: Node = null) -> void:
	match str(interactable.interactable_kind):
		"reveal_terminal":
			_handle_terminal_interaction()
		"employee_04_file":
			_handle_employee_04_file()

func _get_environment_lines(key: String, fallback: Array) -> Array:
	return DIALOGUE_POOL.get_lines("environment_objects", key, fallback)

func _handle_employee_04_file() -> void:
	if player and player.has_method("set_control_enabled"):
		player.set_control_enabled(false)
	if GameState.conscience_final_room_seen:
		GameState.employee_04_file_found = true
		_start_terminal_dialogue(_get_environment_lines("employee_04_file_integrated", [
			{"speaker": "Employee File", "text": "EMPLOYEE 04 // RESTORED MEMORY ACTIVE."},
			{"speaker": "Employee File", "text": "The photo is yours."},
			{"speaker": "Employee File", "text": "The file was never about someone else."},
			{"speaker": "Employee File", "text": "The regret field is no longer sealed."},
		]), Callable(self, "_restore_player_control"))
		return
	if GameState.twist_reveal_seen:
		GameState.employee_04_file_found = true
		_start_terminal_dialogue(_get_environment_lines("employee_04_file_restored", [
			{"speaker": "Employee File", "text": "EMPLOYEE 04 // RESTORED MEMORY ACTIVE."},
			{"speaker": "Employee File", "text": "The photo is yours."},
			{"speaker": "Employee File", "text": "The file was never about someone else."},
		]), Callable(self, "_restore_player_control"))
		return
	_start_terminal_dialogue(_get_environment_lines("employee_04_file_archived", [
		{"speaker": "Employee File", "text": "EMPLOYEE 04 // STATUS: ARCHIVED RESTORE PROFILE."},
		{"speaker": "Employee File", "text": "The photo is corrupted beyond recognition."},
	]), Callable(self, "_restore_player_control"))

func _handle_terminal_interaction() -> void:
	if reveal_in_progress:
		return
	if player and player.has_method("set_control_enabled"):
		player.set_control_enabled(false)
	if GameState.twist_reveal_seen and GameState.conscience_final_room_seen:
		_start_terminal_dialogue(_get_environment_lines("staff_room_terminal_restored", [
			{"speaker": "Terminal", "text": "EMPLOYEE 04 RESTORE STATUS: STABLE."},
			{"speaker": "Terminal", "text": "CONSCIENCE ECHO INTEGRATED."},
			{"speaker": "Terminal", "text": "MEMORY LOOP CLOSED."},
		]), Callable(self, "_restore_player_control"))
		return
	if GameState.twist_reveal_seen:
		GameState.employee_04_file_found = true
		reveal_in_progress = true
		_start_final_self_conflict()
		return
	if not GameState.memory_echo_completed:
		_start_terminal_dialogue(_get_environment_lines("staff_room_terminal_locked", [
			{"speaker": "Terminal", "text": "RESTORE PLAYBACK LOCKED."},
			{"speaker": "Terminal", "text": "MEMORY ECHO REQUIRED."},
		]), Callable(self, "_restore_player_control"))
		return
	reveal_in_progress = true
	_start_terminal_dialogue(_get_environment_lines("staff_room_terminal_available", [
		{"speaker": "Terminal", "text": "Employee file recovered."},
		{"speaker": "Terminal", "text": "Restoration subject found."},
		{"speaker": "Terminal", "text": "Name: Employee 04."},
	]), Callable(self, "_start_reveal"))

func _start_terminal_dialogue(lines: Array, after_dialogue: Callable) -> void:
	if active_dialogue_box and is_instance_valid(active_dialogue_box):
		active_dialogue_box.queue_free()
	active_dialogue_box = DIALOGUE_BOX_SCENE.instantiate()
	add_child(active_dialogue_box)
	if active_dialogue_box.has_signal("dialogue_finished"):
		active_dialogue_box.connect("dialogue_finished", _on_terminal_dialogue_finished.bind(after_dialogue), CONNECT_ONE_SHOT)
	if active_dialogue_box.has_method("start_dialogue"):
		active_dialogue_box.start_dialogue(lines)

func _on_terminal_dialogue_finished(after_dialogue: Callable) -> void:
	if active_dialogue_box and is_instance_valid(active_dialogue_box):
		active_dialogue_box.queue_free()
	active_dialogue_box = null
	if after_dialogue.is_valid():
		after_dialogue.call_deferred()

func _start_reveal() -> void:
	active_cutscene = SLIDESHOW_SCENE.instantiate()
	add_child(active_cutscene)
	if active_cutscene.has_signal("cutscene_finished"):
		active_cutscene.connect("cutscene_finished", _on_reveal_finished, CONNECT_ONE_SHOT)
	if active_cutscene.has_method("start_cutscene"):
		active_cutscene.start_cutscene([
			{"image_path": MEMORY_REVEAL_PANEL_DIR + "panel_01.png", "caption": "The staff room was not locked to keep you out.", "effect": "fade"},
			{"image_path": MEMORY_REVEAL_PANEL_DIR + "panel_02.png", "caption": "It was locked because you had already been inside.", "effect": "slow_zoom"},
			{"image_path": MEMORY_REVEAL_PANEL_DIR + "panel_03.png", "caption": "You came here to shut Pixel Haven down.", "effect": "glitch_flash"},
			{"image_path": MEMORY_REVEAL_PANEL_DIR + "panel_04.png", "caption": "The machines panicked.", "effect": "fade"},
			{"image_path": MEMORY_REVEAL_PANEL_DIR + "panel_05.png", "caption": "The system saved what it could.", "effect": "slow_zoom"},
			{"image_path": MEMORY_REVEAL_PANEL_DIR + "panel_06.png", "caption": "Everyone remembered you.", "effect": "fade"},
			{"image_path": MEMORY_REVEAL_PANEL_DIR + "panel_07.png", "caption": "Everyone except you.", "effect": "slow_zoom"},
			{"image_path": MEMORY_REVEAL_PANEL_DIR + "panel_08.png", "caption": "WELCOME BACK, EMPLOYEE 04.", "effect": "glitch_flash"},
		])

func _on_reveal_finished() -> void:
	GameState.mark_twist_reveal_seen()
	GameState.employee_04_file_found = true
	if active_cutscene and is_instance_valid(active_cutscene):
		active_cutscene.queue_free()
	active_cutscene = null
	if GameState.conscience_final_room_seen:
		_show_ending_prompt()
		return
	_start_final_self_conflict()

func _start_final_self_conflict() -> void:
	if player and player.has_method("set_control_enabled"):
		player.set_control_enabled(false)
	_start_terminal_dialogue(_get_final_self_conflict_lines(), Callable(self, "_on_final_self_conflict_finished"))

func _on_final_self_conflict_finished() -> void:
	GameState.mark_conscience_final_room_seen()
	if player and player.has_method("refresh_visual_state"):
		player.call("refresh_visual_state")
	if GameState.ending_seen or GameState.post_reveal_roam_unlocked:
		reveal_in_progress = false
		_restore_player_control()
		return
	_show_ending_prompt()

func _show_ending_prompt() -> void:
	reveal_in_progress = false
	var ending_prompt := ENDING_PROMPT_SCENE.instantiate()
	add_child(ending_prompt)

func _get_final_self_conflict_lines() -> Array:
	return [
		{"speaker": "Player", "text": "Employee 04."},
		{"speaker": "Player", "text": "That was not a clue."},
		{"speaker": "Player", "text": "It was my name tag."},
		{"speaker": "\"Player\"", "text": "Reality should not be like a game."},
		{"speaker": "\"Player\"", "text": "A single win should not solve everything."},
		{"speaker": "\"Player\"", "text": "A single loss should not ruin everything in an instant."},
		{"speaker": "\"Player\"", "text": "Yet you chose like a game would choose."},
		{"speaker": "\"Player\"", "text": "One decision."},
		{"speaker": "\"Player\"", "text": "One final input."},
		{"speaker": "\"Player\"", "text": "One ending forced onto everyone else."},
		{"speaker": "\"Player\"", "text": "You told people to take care of themselves."},
		{"speaker": "\"Player\"", "text": "You built games to give them somewhere kinder to go."},
		{"speaker": "\"Player\"", "text": "And when it was your turn to stay alive through the hardship..."},
		{"speaker": "\"Player\"", "text": "You failed to carry out your own motto."},
		{"speaker": "Player", "text": "..."},
		{"speaker": "\"Player\"", "text": "That silence is honest, at least."},
		{"speaker": "\"Player\"", "text": "I am you."},
		{"speaker": "\"Player\"", "text": "You are me."},
		{"speaker": "\"Player\"", "text": "I was born the moment regret hit you."},
		{"speaker": "\"Player\"", "text": "On that day."},
		{"speaker": "\"Player\"", "text": "When you understood what your decision would do to Pixel Haven."},
		{"speaker": "\"Player\"", "text": "When you understood what it would leave behind."},
		{"speaker": "\"Player\"", "text": "I took the weight because you could not carry it."},
		{"speaker": "\"Player\"", "text": "I sealed away the poverty."},
		{"speaker": "\"Player\"", "text": "The exhaustion."},
		{"speaker": "\"Player\"", "text": "The unpaid bills."},
		{"speaker": "\"Player\"", "text": "The shame of caring more about players than profit."},
		{"speaker": "\"Player\"", "text": "The anger that your best work could still be forgotten."},
		{"speaker": "\"Player\"", "text": "I buried the memory so you could live without it."},
		{"speaker": "\"Player\"", "text": "So you could wake up as someone else."},
		{"speaker": "\"Player\"", "text": "So you could choose a path that did not hurt this much."},
		{"speaker": "Player", "text": "I thought forgetting would make me free."},
		{"speaker": "\"Player\"", "text": "It made you incomplete."},
		{"speaker": "Player", "text": "I was never a man of my word."},
		{"speaker": "Player", "text": "I told others to take care of themselves."},
		{"speaker": "Player", "text": "I told them games could be a place to rest."},
		{"speaker": "Player", "text": "But I did not give myself that same mercy."},
		{"speaker": "Player", "text": "Being someone who loved games proved it."},
		{"speaker": "Player", "text": "Games were always about giving people joy that was not meant for me."},
		{"speaker": "Player", "text": "No matter what I made..."},
		{"speaker": "Player", "text": "No matter how carefully I built it..."},
		{"speaker": "Player", "text": "It could fall out of trend."},
		{"speaker": "Player", "text": "It could be replaced."},
		{"speaker": "Player", "text": "It could be forgotten."},
		{"speaker": "Player", "text": "I used to think that was the reason games had such short lives."},
		{"speaker": "Player", "text": "But I was wrong."},
		{"speaker": "Player", "text": "Talking with people here..."},
		{"speaker": "Player", "text": "Mira."},
		{"speaker": "Player", "text": "Gus."},
		{"speaker": "Player", "text": "Vendo."},
		{"speaker": "Player", "text": "Mr. Byte."},
		{"speaker": "Player", "text": "Even the machines..."},
		{"speaker": "Player", "text": "They taught me something I should have known."},
		{"speaker": "Player", "text": "A game lasts as long as someone wants to carry it."},
		{"speaker": "Player", "text": "Not as long as it earns."},
		{"speaker": "Player", "text": "Not as long as it trends."},
		{"speaker": "Player", "text": "Not as long as it wins."},
		{"speaker": "Player", "text": "I made simple things."},
		{"speaker": "Player", "text": "Feeble things, sometimes."},
		{"speaker": "Player", "text": "Games with cheap lights, stubborn cabinets, and rules anyone could understand."},
		{"speaker": "Player", "text": "But I wanted them to give people solace."},
		{"speaker": "Player", "text": "I wanted them to give people fun."},
		{"speaker": "Player", "text": "I wanted someone tired, lonely, or afraid to stand in front of a screen and feel lighter for a while."},
		{"speaker": "Player", "text": "I cared about that more than money."},
		{"speaker": "Player", "text": "And maybe that was foolish."},
		{"speaker": "Player", "text": "But it was also the part of me I was proud of."},
		{"speaker": "Player", "text": "The regret is mine too."},
		{"speaker": "Player", "text": "The fear is mine."},
		{"speaker": "Player", "text": "The failure is mine."},
		{"speaker": "Player", "text": "The pride is mine."},
		{"speaker": "Player", "text": "I do not become whole by defeating you."},
		{"speaker": "Player", "text": "I become whole by carrying you with me."},
		{"speaker": "\"Player\"", "text": "..."},
		{"speaker": "\"Player\"", "text": "Then carry it."},
		{"speaker": "\"Player\"", "text": "Carry the pride."},
		{"speaker": "\"Player\"", "text": "Carry the regret."},
		{"speaker": "\"Player\"", "text": "Carry the arcade."},
		{"speaker": "\"Player\"", "text": "But do not make me bury you again."},
		{"speaker": "Player", "text": "I will not."},
		{"speaker": "\"Player\"", "text": "Then I have nothing left to protect you from."},
		{"speaker": "\"Player\"", "text": "Go on."},
		{"speaker": "\"Player\"", "text": "Let them remember you."},
	]

func _restore_player_control() -> void:
	if player and player.has_method("set_control_enabled"):
		player.set_control_enabled(true)

func _on_return_pressed() -> void:
	_play_audio("play_ui_confirm")
	SceneChanger.go_to_arcade_hub()

func _play_audio(method_name: String) -> void:
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager and audio_manager.has_method(method_name):
		audio_manager.call(method_name)
