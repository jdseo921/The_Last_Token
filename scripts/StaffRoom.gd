extends Node2D

const SLIDESHOW_SCENE := preload("res://scenes/cutscenes/SlideshowCutscene.tscn")
const ENDING_PROMPT_SCENE := preload("res://scenes/cutscenes/EndingPrompt.tscn")

@onready var player: CharacterBody2D = $Player
@onready var prompt_label: Label = $InteractionPrompt
@onready var return_button: Button = $Panel/ReturnButton

var active_cutscene: Node = null

func _ready() -> void:
	if player and player.has_signal("interaction_prompt_changed"):
		player.interaction_prompt_changed.connect(_on_prompt_changed)
	return_button.pressed.connect(_on_return_pressed)
	_on_prompt_changed("")

func _on_prompt_changed(text: String) -> void:
	prompt_label.text = text
	prompt_label.visible = not text.is_empty()

func handle_hub_interaction(interactable: Node, player_node: Node = null) -> void:
	if str(interactable.interactable_kind) == "reveal_terminal":
		_start_reveal()

func _start_reveal() -> void:
	if player and player.has_method("set_control_enabled"):
		player.set_control_enabled(false)
	active_cutscene = SLIDESHOW_SCENE.instantiate()
	add_child(active_cutscene)
	if active_cutscene.has_signal("cutscene_finished"):
		active_cutscene.connect("cutscene_finished", _on_reveal_finished, CONNECT_ONE_SHOT)
	if active_cutscene.has_method("start_cutscene"):
		active_cutscene.start_cutscene([
			{"image_path": "", "caption": "The Staff Room terminal wakes up.", "effect": "fade"},
			{"image_path": "", "caption": "Employee 04 was never missing. Employee 04 was restored.", "effect": "glitch_flash"},
			{"image_path": "", "caption": "You are the last saved memory of the arcade technician.", "effect": "slow_zoom"},
		])

func _on_reveal_finished() -> void:
	GameState.mark_twist_reveal_seen()
	var ending_prompt := ENDING_PROMPT_SCENE.instantiate()
	add_child(ending_prompt)

func _on_return_pressed() -> void:
	SceneChanger.go_to_arcade_hub()
