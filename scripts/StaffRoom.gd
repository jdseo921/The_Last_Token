extends Node2D

const SLIDESHOW_SCENE := preload("res://scenes/cutscenes/SlideshowCutscene.tscn")
const ENDING_PROMPT_SCENE := "res://scenes/cutscenes/EndingPrompt.tscn"

const TWIST_SLIDES := [
	{"image_path": "res://assets/cutscenes/twist/panel_01.png", "caption": "The staff room was not locked to keep you out.", "effect": "fade", "duration": 0.6},
	{"image_path": "res://assets/cutscenes/twist/panel_02.png", "caption": "It was locked because you had already been inside.", "effect": "slow_zoom", "duration": 0.8},
	{"image_path": "res://assets/cutscenes/twist/panel_03.png", "caption": "You tried to shut Pixel Haven down.", "effect": "glitch_flash", "duration": 0.5},
	{"image_path": "res://assets/cutscenes/twist/panel_04.png", "caption": "The system saved what it could.", "effect": "fade", "duration": 0.6},
	{"image_path": "res://assets/cutscenes/twist/panel_05.png", "caption": "Everyone remembered you.", "effect": "slow_zoom", "duration": 0.8},
	{"image_path": "res://assets/cutscenes/twist/panel_06.png", "caption": "Everyone except you.", "effect": "fade", "duration": 0.6},
	{"image_path": "res://assets/cutscenes/twist/panel_07.png", "caption": "WELCOME BACK, EMPLOYEE 04.", "effect": "glitch_flash", "duration": 0.5},
]

@onready var player: CharacterBody2D = $Player
@onready var dialogue_box: CanvasLayer = $DialogueBox
@onready var prompt_label: Label = $InteractionPrompt

var pending_after_dialogue: Callable = Callable()
var active_slideshow: CanvasLayer = null

func _ready() -> void:
	player.interaction_prompt_changed.connect(_on_prompt_changed)
	dialogue_box.dialogue_finished.connect(_on_dialogue_finished)
	_on_prompt_changed("")

func _on_prompt_changed(text: String) -> void:
	prompt_label.text = text
	prompt_label.visible = not text.is_empty()

func _on_dialogue_finished() -> void:
	if pending_after_dialogue.is_valid():
		pending_after_dialogue.call()
		pending_after_dialogue = Callable()
	if player and player.has_method("set_control_enabled"):
		player.set_control_enabled(true)

func start_dialogue(lines: Array, after_dialogue: Callable = Callable()) -> void:
	pending_after_dialogue = after_dialogue
	if player and player.has_method("set_control_enabled"):
		player.set_control_enabled(false)
	dialogue_box.start_dialogue(lines)

func handle_interactable_interaction(interactable: Node, player_node: Node = null) -> void:
	match str(interactable.interactable_kind):
		"terminal":
			_handle_terminal()
		"employee_file":
			_handle_employee_file()
		"exit_door":
			SceneChanger.go_to_arcade_hub()
		_:
			start_dialogue([{"speaker": "System", "text": "Nothing happens."}])

func _handle_terminal() -> void:
	if GameState.twist_reveal_seen:
		start_dialogue([
			{"speaker": "Terminal", "text": "EMPLOYEE 04 RESTORE STATUS: STABLE."},
		])
		return
	_start_twist_reveal()

func _start_twist_reveal() -> void:
	if active_slideshow and is_instance_valid(active_slideshow):
		active_slideshow.queue_free()
	active_slideshow = SLIDESHOW_SCENE.instantiate()
	add_child(active_slideshow)
	if player and player.has_method("set_control_enabled"):
		player.set_control_enabled(false)
	active_slideshow.cutscene_finished.connect(_on_twist_slideshow_finished, CONNECT_ONE_SHOT)
	active_slideshow.start_cutscene(TWIST_SLIDES)

func _on_twist_slideshow_finished() -> void:
	GameState.mark_twist_reveal_seen()
	GameState.employee_04_file_found = true
	if active_slideshow and is_instance_valid(active_slideshow):
		active_slideshow.queue_free()
	active_slideshow = null
	SceneChanger.change_scene(ENDING_PROMPT_SCENE)

func _handle_employee_file() -> void:
	GameState.employee_04_file_found = true
	start_dialogue([
		{"speaker": "Employee File", "text": "EMPLOYEE 04 // STATUS: ARCHIVED RESTORE PROFILE."},
	])
