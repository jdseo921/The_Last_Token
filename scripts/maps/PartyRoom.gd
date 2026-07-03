extends Node2D

# Party Room (structure-first shell) — the arcade's old birthday/party corner.
# Purposes: community-photo lore (the owner half in frame), mascot stage,
# an optional "birthday high-score" cabinet. Placeholder lore; dressed later.

@onready var player: CharacterBody2D = $Player
@onready var dialogue_box: CanvasLayer = $UILayer/DialogueBox
@onready var prompt_label: Label = $UILayer/InteractionPrompt
@onready var prompt_background: ColorRect = $UILayer/InteractionPromptBackground

var pending_after_dialogue: Callable = Callable()

func _ready() -> void:
	AudioManager.play_music_for_context("prize_corner")
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
		"community_photos":
			start_dialogue([
				{"speaker": "Community Wall", "text": "Rows of photos: birthday parties, tournament winners, staff pulling faces."},
				{"speaker": "Community Wall", "text": "In the corner of almost every shot, the same figure stands half in frame."},
				{"speaker": "Community Wall", "text": "Never the center of attention. Always making sure everyone else fit."},
			])
		"mascot_stage":
			start_dialogue([
				{"speaker": "Party Stage", "text": "A little stage for a mascot that never quite worked."},
				{"speaker": "Party Stage", "text": "Kids' drawings are still taped along the front."},
				{"speaker": "Party Stage", "text": "One reads: THANK YOU FOR THE FREE GO. It is not signed to anyone in particular."},
			])
		"birthday_cabinet":
			start_dialogue([
				{"speaker": "Birthday Cabinet", "text": "PARTY HIGH SCORE - a cheerful little game for the corner."},
				{"speaker": "Birthday Cabinet", "text": "Optional. Someone kept the score low on purpose, so kids could always win."},
			])
		_:
			start_dialogue([{"speaker": "System", "text": "Nothing happens."}])
