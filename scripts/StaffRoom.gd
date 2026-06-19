extends Node2D

const SLIDESHOW_SCENE := preload("res://scenes/cutscenes/SlideshowCutscene.tscn")
const ENDING_PROMPT_SCENE := preload("res://scenes/cutscenes/EndingPrompt.tscn")
const DIALOGUE_BOX_SCENE := preload("res://scenes/ui/DialogueBox.tscn")

@onready var player: CharacterBody2D = $Player
@onready var prompt_label: Label = $InteractionPrompt
@onready var return_button: Button = $Panel/ReturnButton

var active_cutscene: Node = null
var active_dialogue_box: Node = null
var reveal_in_progress := false

func _ready() -> void:
	if player and player.has_signal("interaction_prompt_changed"):
		player.interaction_prompt_changed.connect(_on_prompt_changed)
	return_button.pressed.connect(_on_return_pressed)
	_on_prompt_changed("")

func _on_prompt_changed(text: String) -> void:
	prompt_label.text = text
	prompt_label.visible = not text.is_empty()

func can_open_pause_menu() -> bool:
	return active_dialogue_box == null and active_cutscene == null and not reveal_in_progress

func handle_hub_interaction(interactable: Node, player_node: Node = null) -> void:
	match str(interactable.interactable_kind):
		"reveal_terminal":
			_handle_terminal_interaction()
		"employee_04_file":
			_handle_employee_04_file()

func _handle_employee_04_file() -> void:
	if player and player.has_method("set_control_enabled"):
		player.set_control_enabled(false)
	if GameState.twist_reveal_seen:
		GameState.employee_04_file_found = true
		_start_terminal_dialogue([
			{"speaker": "Employee File", "text": "EMPLOYEE 04 // RESTORED MEMORY ACTIVE."},
			{"speaker": "Employee File", "text": "The photo is yours."},
			{"speaker": "Employee File", "text": "The file was never about someone else."},
		], Callable(self, "_restore_player_control"))
		return
	_start_terminal_dialogue([
		{"speaker": "Employee File", "text": "EMPLOYEE 04 // STATUS: ARCHIVED RESTORE PROFILE."},
		{"speaker": "Employee File", "text": "The photo is corrupted beyond recognition."},
	], Callable(self, "_restore_player_control"))

func _handle_terminal_interaction() -> void:
	if reveal_in_progress:
		return
	if player and player.has_method("set_control_enabled"):
		player.set_control_enabled(false)
	if GameState.twist_reveal_seen:
		_start_terminal_dialogue([
			{"speaker": "Terminal", "text": "EMPLOYEE 04 RESTORE STATUS: STABLE."},
			{"speaker": "Terminal", "text": "MEMORY LOOP CLOSED."},
		], Callable(self, "_restore_player_control"))
		return
	reveal_in_progress = true
	_start_terminal_dialogue([
		{"speaker": "Terminal", "text": "Employee file recovered."},
		{"speaker": "Terminal", "text": "Restoration subject found."},
		{"speaker": "Terminal", "text": "Name: Employee 04."},
	], Callable(self, "_start_reveal"))

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
			{"image_path": "res://assets/cutscenes/twist/panel_01.png", "caption": "The staff room was not locked to keep you out.", "effect": "fade"},
			{"image_path": "res://assets/cutscenes/twist/panel_02.png", "caption": "It was locked because you had already been inside.", "effect": "slow_zoom"},
			{"image_path": "res://assets/cutscenes/twist/panel_03.png", "caption": "You came here to shut Pixel Haven down.", "effect": "glitch_flash"},
			{"image_path": "res://assets/cutscenes/twist/panel_04.png", "caption": "The machines panicked.", "effect": "fade"},
			{"image_path": "res://assets/cutscenes/twist/panel_05.png", "caption": "The system saved what it could.", "effect": "slow_zoom"},
			{"image_path": "res://assets/cutscenes/twist/panel_06.png", "caption": "Everyone remembered you.", "effect": "fade"},
			{"image_path": "res://assets/cutscenes/twist/panel_07.png", "caption": "Everyone except you.", "effect": "slow_zoom"},
			{"image_path": "res://assets/cutscenes/twist/panel_08.png", "caption": "WELCOME BACK, EMPLOYEE 04.", "effect": "glitch_flash"},
		])

func _on_reveal_finished() -> void:
	GameState.mark_twist_reveal_seen()
	GameState.employee_04_file_found = true
	reveal_in_progress = false
	if active_cutscene and is_instance_valid(active_cutscene):
		active_cutscene.queue_free()
	active_cutscene = null
	var ending_prompt := ENDING_PROMPT_SCENE.instantiate()
	add_child(ending_prompt)

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
