extends Node2D

# Workshop / Storage (structure-first shell) — off Maintenance Hall.
# Purposes: the maker's workbench (04 built the cabinets by hand), an unfinished
# free-to-play prototype, spare parts. Deepest maker lore. Placeholder text.

const DIALOGUE_POOL := preload("res://scripts/DialoguePool.gd")

@onready var player: CharacterBody2D = $Player
@onready var dialogue_box: CanvasLayer = $UILayer/DialogueBox
@onready var prompt_label: Label = $UILayer/InteractionPrompt
@onready var prompt_background: ColorRect = $UILayer/InteractionPromptBackground

var pending_after_dialogue: Callable = Callable()

func _ready() -> void:
	AudioManager.play_music_for_context("maintenance_hall")
	player.interaction_prompt_changed.connect(_on_prompt_changed)
	dialogue_box.dialogue_finished.connect(_on_dialogue_finished)
	_apply_spawn_position()
	_on_prompt_changed("")

func can_open_pause_menu() -> bool:
	return not _dialogue_is_active()

func _apply_spawn_position() -> void:
	var spawn_id := GameState.consume_pending_spawn_id()
	var marker := get_node_or_null(spawn_id)
	if marker is Marker2D:
		player.global_position = marker.global_position

func _on_prompt_changed(text: String) -> void:
	prompt_label.text = text
	prompt_label.visible = not text.is_empty()
	prompt_background.visible = prompt_label.visible

func start_dialogue(lines: Array, after_dialogue: Callable = Callable()) -> void:
	pending_after_dialogue = after_dialogue
	if player and player.has_method("set_control_enabled"):
		player.set_control_enabled(false)
	dialogue_box.start_dialogue(lines)

func _on_dialogue_finished() -> void:
	if pending_after_dialogue.is_valid():
		pending_after_dialogue.call()
		pending_after_dialogue = Callable()
	if player and player.has_method("set_control_enabled"):
		player.set_control_enabled(true)

func _dialogue_is_active() -> bool:
	if dialogue_box == null:
		return false
	return dialogue_box.get("active") == true

func handle_hub_interaction(interactable: Node, _player_node: Node = null) -> void:
	match str(interactable.interactable_kind):
		"workbench":
			start_dialogue(_get_env_state("workshop_bench", [
				{"speaker": "Workbench", "text": "Half-built cabinets lean against the wall, each one shaped by hand."},
				{"speaker": "Workbench", "text": "Whoever worked here cared more about the games than about being paid for them."},
			]))
		"prototype_cabinet":
			start_dialogue(_get_env_state("workshop_prototype", [
				{"speaker": "Prototype", "text": "An unfinished cabinet. A note reads: MAKE THIS ONE FREE."},
				{"speaker": "Prototype", "text": "It was never finished. The arcade closed first."},
			]))
		"spare_parts":
			start_dialogue(_get_env_state("workshop_spare_parts", [
				{"speaker": "Spare Parts", "text": "Everything here was kept working long past its time."},
			]))
		_:
			start_dialogue([{"speaker": "System", "text": "Nothing happens."}])

func _is_post_reveal() -> bool:
	return GameState.post_reveal_roam_unlocked or GameState.twist_reveal_seen

func _get_env_state(key: String, fallback: Array) -> Array:
	if _is_post_reveal():
		var restored: Array = DIALOGUE_POOL.get_lines("environment_objects", key + "_restored", [])
		if not restored.is_empty():
			return restored
	return DIALOGUE_POOL.get_lines("environment_objects", key, fallback)
