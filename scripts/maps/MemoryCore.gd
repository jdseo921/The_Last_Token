extends Node2D

# Memory Core / Basement (structure-first shell) — off Staff Corridor.
# Purposes: the arcade's memory heart (banks holding everyone's memory of 04);
# pays off "the system saved what it could." A quiet, late lore beat. Placeholder.

const DIALOGUE_POOL := preload("res://scripts/DialoguePool.gd")

@onready var player: CharacterBody2D = $Player
@onready var dialogue_box: CanvasLayer = $UILayer/DialogueBox
@onready var prompt_label: Label = $UILayer/InteractionPrompt
@onready var prompt_background: ColorRect = $UILayer/InteractionPromptBackground

var pending_after_dialogue: Callable = Callable()

func _ready() -> void:
	AudioManager.play_music_for_context("staff_corridor")
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
		"memory_bank":
			start_dialogue(_get_env_state("memory_banks", [
				{"speaker": "Memory Bank", "text": "Each one holds a memory the arcade refused to lose."},
				{"speaker": "Memory Bank", "text": "Faces. Voices. Closing nights. All of it kept."},
			]))
		"core_terminal":
			start_dialogue(_get_env_state("memory_core_terminal", [
				{"speaker": "Core Terminal", "text": "WHEN THE FLOOR WENT DARK, THE SYSTEM SAVED WHAT IT COULD."},
				{"speaker": "Core Terminal", "text": "IT CHOSE PEOPLE OVER PROFIT. ONE LAST TIME."},
			]))
		"employee_drive":
			start_dialogue(_get_env_state("memory_sealed_drive", [
				{"speaker": "Sealed Drive", "text": "One drive is labeled only with a number. The rest is scratched away."},
				{"speaker": "Sealed Drive", "text": "It has been waiting to be read."},
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
