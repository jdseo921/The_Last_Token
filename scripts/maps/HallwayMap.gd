extends Node2D

@export var hallway_id := ""
@export var title_text := "HALLWAY"
@export var hint_text := ""

@onready var player: CharacterBody2D = $Player
@onready var dialogue_box: CanvasLayer = $UILayer/DialogueBox
@onready var prompt_label: Label = $UILayer/InteractionPrompt
@onready var prompt_background: ColorRect = $UILayer/InteractionPromptBackground
@onready var title_label: Label = $UILayer/TitleLabel
@onready var hint_label: Label = $UILayer/HintLabel

var pending_after_dialogue: Callable = Callable()

func _ready() -> void:
	player.interaction_prompt_changed.connect(_on_prompt_changed)
	dialogue_box.dialogue_finished.connect(_on_dialogue_finished)
	title_label.text = title_text
	hint_label.text = hint_text
	hint_label.visible = not hint_text.is_empty()
	_apply_spawn_position()
	_on_prompt_changed("")
	call_deferred("_maybe_show_hallway_message")

func can_open_pause_menu() -> bool:
	return not _dialogue_is_active()

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

func _apply_spawn_position() -> void:
	var spawn_id := GameState.consume_pending_spawn_id("Spawn_Default")
	var marker := get_node_or_null(spawn_id)
	if marker is Marker2D:
		player.global_position = marker.global_position

func _on_prompt_changed(text: String) -> void:
	prompt_label.text = text
	prompt_label.visible = not text.is_empty()
	prompt_background.visible = prompt_label.visible

func _maybe_show_hallway_message() -> void:
	if _dialogue_is_active():
		return
	var lines := _get_hallway_message_lines()
	if lines.is_empty():
		return
	var counter_key := "hallway_message:%s" % hallway_id
	if GameState.get_npc_dialogue_count(counter_key) > 0:
		return
	GameState.increment_npc_dialogue_count(counter_key)
	start_dialogue(lines)

func _get_hallway_message_lines() -> Array:
	if hallway_id.is_empty() or GameState.twist_reveal_seen or GameState.post_reveal_roam_unlocked:
		return []
	match hallway_id:
		"cabinet_hallway":
			if GameState.lost_token_quest_completed and not GameState.lying_cabinets_completed:
				return [
					{"speaker": "???", "text": "The cabinets are waking because you brought them proof.", "effect": "glitch"},
					{"speaker": "???", "text": "Proof is not forgiveness."},
				]
		"snack_hallway":
			if GameState.lying_cabinets_completed and not GameState.circuit_soda_completed:
				return [
					{"speaker": "???", "text": "You keep calling every route progress.", "effect": "glitch"},
					{"speaker": "???", "text": "Some routes only circle back."},
				]
		"prize_hallway":
			if GameState.lost_token_quest_completed and not GameState.memory_echo_completed:
				return [
					{"speaker": "???", "text": "Prizes remember hands better than names."},
					{"speaker": "???", "text": "Careful what yours picks up.", "effect": "glitch"},
				]
		"maintenance_hallway":
			if GameState.circuit_soda_completed and not GameState.lost_shift_file_completed:
				return [
					{"speaker": "???", "text": "Maintenance is a nice word for hiding damage.", "effect": "glitch"},
					{"speaker": "???", "text": "Ask Gus what the door reported."},
				]
		"back_hallway":
			if GameState.staff_corridor_unlocked and not GameState.memory_echo_completed:
				return [
					{"speaker": "???", "text": "Back halls keep the footsteps people do not want counted."},
					{"speaker": "???", "text": "Yours are loud tonight.", "effect": "shake"},
				]
		"cabinet_snack_hallway":
			if GameState.lying_cabinets_completed and not GameState.circuit_soda_completed:
				return [
					{"speaker": "???", "text": "Truth made you thirsty for a fix.", "effect": "glitch"},
					{"speaker": "???", "text": "Try not to mistake fizz for healing."},
				]
		"snack_prize_hallway":
			if GameState.circuit_soda_completed and not GameState.memory_echo_completed:
				return [
					{"speaker": "???", "text": "The prize shelf still knows what you wanted."},
					{"speaker": "???", "text": "Wanting is not the same as deserving it.", "effect": "glitch"},
				]
		"maintenance_staff_hallway":
			if GameState.maintenance_sync_completed and not GameState.memory_echo_completed:
				return [
					{"speaker": "???", "text": "The door heard both knocks."},
					{"speaker": "???", "text": "Now listen to the one you keep denying.", "effect": "glitch"},
				]
	return []
