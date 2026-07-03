extends Node2D

# Front Entrance (structure-first shell) — the wake/entry framing room.
# Purposes: the locked exit ("why can't I leave"), arcade history, closing notice.
# Placeholder lore; final text/visuals dressed in the later passes.

@onready var player: CharacterBody2D = $Player
@onready var dialogue_box: CanvasLayer = $UILayer/DialogueBox
@onready var prompt_label: Label = $UILayer/InteractionPrompt
@onready var prompt_background: ColorRect = $UILayer/InteractionPromptBackground

var pending_after_dialogue: Callable = Callable()

func _ready() -> void:
	AudioManager.play_music_for_context("arcade_hub")
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
		"locked_exit":
			start_dialogue([
				{"speaker": "Front Doors", "text": "The main doors are locked from the outside."},
				{"speaker": "Front Doors", "text": "The closing notice is still taped to the glass."},
				{"speaker": "Player", "text": "Why can I not just leave?"},
				{"speaker": "Player", "text": "..."},
				{"speaker": "Player", "text": "Something here is not finished with me yet."},
			])
		"arcade_history":
			start_dialogue([
				{"speaker": "History Board", "text": "PIXEL HAVEN - loved, for a while."},
				{"speaker": "History Board", "text": "Photos of full weekends. Tournament nights. A staff that used to be larger."},
				{"speaker": "History Board", "text": "The most recent photos have been taken down."},
			])
		"closing_notice":
			start_dialogue([
				{"speaker": "Closing Notice", "text": "NOTICE: Pixel Haven will close after final maintenance."},
				{"speaker": "Closing Notice", "text": "Thank you for every quarter."},
				{"speaker": "Closing Notice", "text": "The signature at the bottom is scratched out."},
			])
		_:
			start_dialogue([{"speaker": "System", "text": "Nothing happens."}])
