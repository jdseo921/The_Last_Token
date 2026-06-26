extends Node2D

const BACKGROUND_ART_PATH := "res://assets/art/maps/snack_alcove/snack_alcove_background_640x440.png"
const DIALOGUE_POOL := preload("res://scripts/DialoguePool.gd")

@onready var player: CharacterBody2D = $Player
@onready var background_art: Sprite2D = $BackgroundArt
@onready var dialogue_box: CanvasLayer = $UILayer/DialogueBox
@onready var prompt_label: Label = $UILayer/InteractionPrompt
@onready var prompt_background: ColorRect = $UILayer/InteractionPromptBackground
@onready var circuit_soda_glow: Polygon2D = $CircuitSodaGlow
@onready var quest_notice: CanvasLayer = $QuestNotice

var pending_after_dialogue: Callable = Callable()

func _ready() -> void:
	AudioManager.play_music_for_context("snack_alcove")
	player.interaction_prompt_changed.connect(_on_prompt_changed)
	dialogue_box.dialogue_finished.connect(_on_dialogue_finished)
	_apply_background_art()
	_apply_spawn_position()
	_on_prompt_changed("")
	_refresh_circuit_soda_state()

func can_open_pause_menu() -> bool:
	return not _dialogue_is_active() and not ConscienceEncounterDirector.is_encounter_active()

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
	_refresh_circuit_soda_state()

func _dialogue_is_active() -> bool:
	if dialogue_box == null:
		return false
	return dialogue_box.get("active") == true

func _get_vendo_lines(key: String, fallback: Array) -> Array:
	return DIALOGUE_POOL.get_lines("vendo", key, fallback)

func _get_vendo_sequential_lines(key: String, fallback: Array) -> Array:
	return DIALOGUE_POOL.get_sequential_set("vendo", key, key, fallback)

func _get_environment_lines(key: String, fallback: Array) -> Array:
	return DIALOGUE_POOL.get_lines("environment_objects", key, fallback)

func _get_environment_state_lines(object_key: String, fallback: Array) -> Array:
	var state_key := "%s_%s" % [object_key, _get_environment_state_key()]
	var lines := _get_environment_lines(state_key, [])
	if not lines.is_empty():
		return lines
	lines = _get_environment_lines("%s_locked" % object_key, fallback)
	if not lines.is_empty():
		return lines
	return fallback

func _get_environment_state_key() -> String:
	GameState.update_memory_signal_from_progress()
	if _is_post_reveal():
		return "restored"
	return GameState.get_memory_signal_label().to_lower()

func handle_hub_interaction(interactable: Node, _player_node: Node = null) -> void:
	match str(interactable.interactable_kind):
		"vendo":
			_handle_vendo()
		"circuit_soda":
			_handle_circuit_soda()
		"snack_service_adventure":
			_handle_snack_service_adventure()
		_:
			start_dialogue([{"speaker": "System", "text": "Nothing happens."}])

func _handle_vendo() -> void:
	GameState.vendo_intro_seen = true
	if _is_post_reveal():
		GameState.vendo_post_reveal_seen = true
		var was_completed := _was_witness_route_completed()
		GameState.mark_witness_vendo_heard()
		start_dialogue(_get_vendo_lines("post_reveal_witness", [
			{"speaker": "Vendo", "text": "Employee 04."},
			{"speaker": "Vendo", "text": "Your memory has been partially restored."},
			{"speaker": "Vendo", "text": "Refunds remain impossible."},
		]), _get_witness_completion_callback(was_completed))
		return
	if not GameState.lying_cabinets_completed:
		start_dialogue([
			{"speaker": "Vendo", "text": "SNACK ALCOVE LOCKED."},
			{"speaker": "Vendo", "text": "TRUTH FILTER REQUIRED."},
		])
		return
	if not GameState.circuit_soda_completed:
		var circuit_soda_started := GameState.circuit_soda_started
		GameState.start_circuit_soda()
		if circuit_soda_started:
			start_dialogue(_get_vendo_sequential_lines("circuit_soda_repeat_hint", [
				{"speaker": "Vendo", "text": "Circuit Soda remains available."},
				{"speaker": "Vendo", "text": "Route the signal through the correct channels."},
				{"speaker": "Vendo", "text": "Think of it as pouring yourself back into the right can."},
			]))
			return
		start_dialogue(_get_vendo_lines("circuit_soda_intro", [
			{"speaker": "Vendo", "text": "Memory Signal: Fractured."},
			{"speaker": "Vendo", "text": "Your signal is going everywhere except where it should."},
			{"speaker": "Vendo", "text": "Luckily, I am a licensed beverage-adjacent routing system."},
		]))
		return
	if not GameState.vendo_circuit_anecdote_seen:
		GameState.vendo_circuit_anecdote_seen = true
		start_dialogue(_get_vendo_lines("circuit_soda_completion_anecdote", [
			{"speaker": "Vendo", "text": "Signal routed."},
			{"speaker": "Vendo", "text": "Unfortunately, routed does not mean understood."},
			{"speaker": "Vendo", "text": "Mira and Gus have records. Try not to enjoy paperwork."},
		]))
		return
	start_dialogue(_get_vendo_lines("overloaded_phase", [
		{"speaker": "Vendo", "text": "Signal routed."},
		{"speaker": "Vendo", "text": "Paperwork remains tragically next."},
	]))

func _handle_circuit_soda() -> void:
	if not GameState.lying_cabinets_completed:
		start_dialogue(_get_environment_lines("circuit_soda_machine_locked", [
			{"speaker": "Circuit Soda", "text": "SNACK ALCOVE LOCKED."},
			{"speaker": "Circuit Soda", "text": "TRUTH FILTER REQUIRED."},
		]))
		return
	if GameState.circuit_soda_completed:
		start_dialogue(_get_environment_lines("circuit_soda_machine_restored", [
			{"speaker": "Circuit Soda", "text": "MEMORY FLOW RESTORED."},
			{"speaker": "Circuit Soda", "text": "FRACTURED SIGNAL STABILIZED."},
		]))
		return
	GameState.start_circuit_soda()
	start_dialogue(_get_environment_lines("circuit_soda_machine_fractured", [
		{"speaker": "Circuit Soda", "text": "MEMORY FLOW UNROUTED."},
		{"speaker": "Circuit Soda", "text": "CONNECT INPUT TO RESTORE OUTPUT."},
	]), Callable(self, "_go_to_circuit_soda"))

func _go_to_circuit_soda() -> void:
	GameState.set_pending_spawn_id("Spawn_FromCircuitSoda")
	SceneChanger.go_to_circuit_soda()

func _handle_snack_service_adventure() -> void:
	if not GameState.lying_cabinets_completed:
		start_dialogue([
			{"speaker": "Service Slot", "text": "SNACK SERVICE LOCKED."},
			{"speaker": "Service Slot", "text": "TRUTH FILTER REQUIRED."},
		])
		return
	start_dialogue([
		{"speaker": "Service Slot", "text": "SNACK SERVICE DASH READY."},
		{"speaker": "Service Slot", "text": "Collect labels without spilling the signal."},
		{"speaker": "Service Slot", "text": "Optional stock route. Refunds still impossible."},
	], Callable(self, "_go_to_snack_service_dash"))

func _go_to_snack_service_dash() -> void:
	GameState.set_pending_spawn_id("Spawn_FromSnackAdventure")
	SceneChanger.go_to_snack_service_dash()

func _apply_background_art() -> void:
	var loaded := _apply_sprite_texture(background_art, BACKGROUND_ART_PATH)
	for placeholder in [$Background, $SnackWall, $ServiceSlotPlaceholder, $VendoPlaceholder, $CircuitSodaPlaceholder]:
		if placeholder is CanvasItem:
			placeholder.visible = not loaded

func _refresh_circuit_soda_state() -> void:
	if circuit_soda_glow == null:
		return
	circuit_soda_glow.visible = GameState.lying_cabinets_completed and not GameState.circuit_soda_completed

func _is_post_reveal() -> bool:
	return GameState.post_reveal_roam_unlocked or GameState.twist_reveal_seen

func _was_witness_route_completed() -> bool:
	return GameState.witness_route_completed or GameState.post_reveal_witness_route_completed

func _get_witness_completion_callback(was_completed: bool) -> Callable:
	if not was_completed and _was_witness_route_completed():
		return Callable(self, "_show_witness_route_complete_notice")
	return Callable()

func _show_witness_route_complete_notice() -> void:
	if quest_notice and quest_notice.has_method("show_custom_notification"):
		quest_notice.call(
			"show_custom_notification",
			"QUEST COMPLETE",
			"POST-REVEAL WITNESSES COMPLETE",
			"Pixel Haven remembers you in pieces.\nTogether, they almost make a person."
		)

func _apply_sprite_texture(sprite_node: Sprite2D, path: String) -> bool:
	if sprite_node == null:
		return false
	sprite_node.visible = false
	sprite_node.texture = null
	if path.is_empty() or not ResourceLoader.exists(path):
		return false
	var resource := load(path)
	if not resource is Texture2D:
		return false
	sprite_node.texture = resource
	sprite_node.visible = true
	return true
