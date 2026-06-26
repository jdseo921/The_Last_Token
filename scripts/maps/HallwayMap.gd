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
	var counter_key := "hallway_message:%s:%s" % [hallway_id, _get_hallway_message_phase()]
	if GameState.get_npc_dialogue_count(counter_key) > 0:
		return
	GameState.increment_npc_dialogue_count(counter_key)
	start_dialogue(lines)

func _get_hallway_message_phase() -> String:
	var quest_id := GameState.get_current_quest_id()
	if not quest_id.is_empty():
		return quest_id
	return GameState.get_memory_signal_label().to_lower()

func _get_hallway_message_lines() -> Array:
	if hallway_id.is_empty() or GameState.twist_reveal_seen or GameState.post_reveal_roam_unlocked:
		return []
	match hallway_id:
		"cabinet_hallway":
			if GameState.lost_token_quest_completed and not GameState.lying_cabinets_completed:
				return [
					{"speaker": "???", "text": "The cabinets wake for tokens, not mercy.", "effect": "glitch"},
					{"speaker": "???", "text": "A prize can open a door. It cannot clear the score."},
				]
		"snack_hallway":
			if GameState.lying_cabinets_completed and not GameState.circuit_soda_completed:
				return [
					{"speaker": "???", "text": "Every route in this arcade has a return path.", "effect": "glitch"},
					{"speaker": "???", "text": "Watch which lights follow you back."},
				]
		"prize_hallway":
			if GameState.lost_token_quest_completed and not GameState.memory_echo_completed:
				return [
					{"speaker": "???", "text": "Prizes remember hands better than names."},
					{"speaker": "???", "text": "Something on the shelf is choosing which hand to trust.", "effect": "glitch"},
				]
		"maintenance_hallway":
			if GameState.lost_shift_file_completed and not GameState.static_service_run_completed:
				return [
					{"speaker": "???", "text": "The file opened a service route.", "effect": "glitch"},
					{"speaker": "???", "text": "Service routes are where arcades hide their bad wiring."},
				]
			if GameState.circuit_soda_completed and not GameState.lost_shift_file_completed:
				return [
					{"speaker": "???", "text": "Maintenance is a tidy word for old damage.", "effect": "glitch"},
					{"speaker": "???", "text": "Ask Gus why the door counted one extra signal."},
				]
		"back_hallway":
			if GameState.final_night_walk_completed and not GameState.memory_echo_completed:
				return [
					{"speaker": "???", "text": "The route played back clean."},
					{"speaker": "???", "text": "Clean playback does not mean a clean ending.", "effect": "glitch"},
				]
			if GameState.staff_corridor_unlocked and not GameState.memory_echo_completed:
				return [
					{"speaker": "???", "text": "Back halls count footsteps after the tokens stop falling."},
					{"speaker": "???", "text": "One set keeps landing half a beat behind yours.", "effect": "shake"},
				]
		"cabinet_snack_hallway":
			if GameState.lying_cabinets_completed and not GameState.circuit_soda_completed:
				return [
					{"speaker": "???", "text": "Truth leaves a metallic taste.", "effect": "glitch"},
					{"speaker": "???", "text": "Fizz can cover it. It cannot fix it."},
				]
		"snack_prize_hallway":
			if GameState.circuit_soda_completed and not GameState.memory_echo_completed:
				return [
					{"speaker": "???", "text": "The prize shelf still knows what you wanted."},
					{"speaker": "???", "text": "Wanting is not always a safe memory.", "effect": "glitch"},
				]
		"maintenance_staff_hallway":
			if GameState.maintenance_sync_completed and not GameState.memory_echo_completed:
				return [
					{"speaker": "???", "text": "The door heard both knocks."},
					{"speaker": "???", "text": "The second knock is still waiting for your hand.", "effect": "glitch"},
				]
	return []
