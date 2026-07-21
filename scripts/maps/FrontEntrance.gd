extends Node2D

# Front Entrance (structure-first shell) — the wake/entry framing room.
# Purposes: the locked exit ("why can't I leave"), arcade history, closing notice.
# Placeholder lore; final text/visuals dressed in the later passes.

const DIALOGUE_POOL := preload("res://scripts/DialoguePool.gd")
const ROUTE_CUE_SCRIPT := preload("res://scripts/RouteCue.gd")

@onready var player: CharacterBody2D = $Player
@onready var dialogue_box: CanvasLayer = $UILayer/DialogueBox
@onready var prompt_label: Label = $UILayer/InteractionPrompt
@onready var prompt_background: ColorRect = $UILayer/InteractionPromptBackground

var route_cue: Control = null

var pending_after_dialogue: Callable = Callable()

func _ready() -> void:
	AudioManager.play_music_for_context("arcade_hub")
	player.interaction_prompt_changed.connect(_on_prompt_changed)
	dialogue_box.dialogue_finished.connect(_on_dialogue_finished)
	_setup_route_cue()
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
	_refresh_route_cue()

func _setup_route_cue() -> void:
	route_cue = ROUTE_CUE_SCRIPT.new()
	$UILayer.add_child(route_cue)
	route_cue.setup("front_entrance", Vector2(24, 86), 430.0)

func _refresh_route_cue() -> void:
	if route_cue != null and is_instance_valid(route_cue):
		route_cue.refresh()

func _dialogue_is_active() -> bool:
	if dialogue_box == null:
		return false
	return dialogue_box.get("active") == true

func handle_hub_interaction(interactable: Node, _player_node: Node = null) -> void:
	match str(interactable.interactable_kind):
		"locked_exit":
			start_dialogue(_get_env_state("front_doors", [
				{"speaker": "Front Doors", "text": "The main doors are chained shut from the outside."},
				{"speaker": "Front Doors", "text": "Something here is not finished with you yet."},
			]))
		"arcade_history":
			start_dialogue(_get_env_state("arcade_history", [
				{"speaker": "History Board", "text": "Photos of fuller years. The most recent ones have been taken down."},
			]))
		"closing_notice":
			start_dialogue(_get_env_state("closing_notice", [
				{"speaker": "Closing Notice", "text": "NOTICE: Pixel Haven will close after final maintenance."},
				{"speaker": "Closing Notice", "text": "The signature at the bottom is scratched out."},
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
