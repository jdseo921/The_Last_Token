extends Node2D

const BACKGROUND_ART_PATH := "res://assets/art/maps/snack_alcove/snack_alcove_background_640x440.png"

@onready var player: CharacterBody2D = $Player
@onready var background_art: Sprite2D = $BackgroundArt
@onready var dialogue_box: CanvasLayer = $UILayer/DialogueBox
@onready var prompt_label: Label = $UILayer/InteractionPrompt
@onready var prompt_background: ColorRect = $UILayer/InteractionPromptBackground
@onready var circuit_soda_glow: Polygon2D = $CircuitSodaGlow

var pending_after_dialogue: Callable = Callable()

func _ready() -> void:
	player.interaction_prompt_changed.connect(_on_prompt_changed)
	dialogue_box.dialogue_finished.connect(_on_dialogue_finished)
	_apply_background_art()
	_apply_spawn_position()
	_on_prompt_changed("")
	_refresh_circuit_soda_state()

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
	_refresh_circuit_soda_state()

func _dialogue_is_active() -> bool:
	if dialogue_box == null:
		return false
	return dialogue_box.get("active") == true

func handle_hub_interaction(interactable: Node, _player_node: Node = null) -> void:
	match str(interactable.interactable_kind):
		"vendo":
			_handle_vendo()
		"circuit_soda":
			_handle_circuit_soda()
		_:
			start_dialogue([{"speaker": "System", "text": "Nothing happens."}])

func _handle_vendo() -> void:
	GameState.vendo_intro_seen = true
	if not GameState.lying_cabinets_completed:
		start_dialogue([
			{"speaker": "Vendo", "text": "SNACK ALCOVE LOCKED."},
			{"speaker": "Vendo", "text": "TRUTH FILTER REQUIRED."},
		])
		return
	if not GameState.circuit_soda_completed:
		GameState.start_circuit_soda()
		start_dialogue([
			{"speaker": "Vendo", "text": "Memory Signal: Fractured."},
			{"speaker": "Vendo", "text": "Your signal is going everywhere except where it should."},
			{"speaker": "Vendo", "text": "Luckily, I am a licensed beverage-adjacent routing system."},
		])
		return
	if not GameState.vendo_circuit_anecdote_seen:
		GameState.vendo_circuit_anecdote_seen = true
		start_dialogue([
			{"speaker": "Vendo", "text": "Signal routed."},
			{"speaker": "Vendo", "text": "Unfortunately, routed does not mean understood."},
			{"speaker": "Vendo", "text": "Mira and Gus have records. Try not to enjoy paperwork."},
		])
		return
	start_dialogue([
		{"speaker": "Vendo", "text": "Signal routed."},
		{"speaker": "Vendo", "text": "Paperwork remains tragically next."},
	])

func _handle_circuit_soda() -> void:
	if not GameState.lying_cabinets_completed:
		start_dialogue([
			{"speaker": "Circuit Soda", "text": "SNACK ALCOVE LOCKED."},
			{"speaker": "Circuit Soda", "text": "TRUTH FILTER REQUIRED."},
		])
		return
	if GameState.circuit_soda_completed:
		start_dialogue([
			{"speaker": "Circuit Soda", "text": "MEMORY FLOW RESTORED."},
			{"speaker": "Circuit Soda", "text": "FRACTURED SIGNAL STABILIZED."},
		])
		return
	GameState.start_circuit_soda()
	_go_to_circuit_soda()

func _go_to_circuit_soda() -> void:
	GameState.set_pending_spawn_id("Spawn_FromCircuitSoda")
	SceneChanger.go_to_circuit_soda()

func _apply_background_art() -> void:
	var loaded := _apply_sprite_texture(background_art, BACKGROUND_ART_PATH)
	for placeholder in [$Background, $SnackWall, $VendoPlaceholder, $CircuitSodaPlaceholder]:
		if placeholder is CanvasItem:
			placeholder.visible = not loaded

func _refresh_circuit_soda_state() -> void:
	if circuit_soda_glow == null:
		return
	circuit_soda_glow.visible = GameState.lying_cabinets_completed and not GameState.circuit_soda_completed

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
