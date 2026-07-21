extends Node2D

# Party Room (structure-first shell) — the arcade's old birthday/party corner.
# Purposes: community-photo lore (the owner half in frame), mascot stage,
# an optional "birthday high-score" cabinet. Placeholder lore; dressed later.

const DIALOGUE_POOL := preload("res://scripts/DialoguePool.gd")
const ROUTE_CUE_SCRIPT := preload("res://scripts/RouteCue.gd")
const AMBIENT_EFFECTS := preload("res://scripts/AmbientSpriteEffects.gd")

@onready var player: CharacterBody2D = $Player
@onready var dialogue_box: CanvasLayer = $UILayer/DialogueBox
@onready var prompt_label: Label = $UILayer/InteractionPrompt
@onready var prompt_background: ColorRect = $UILayer/InteractionPromptBackground

var route_cue: Control = null

var pending_after_dialogue: Callable = Callable()

func _ready() -> void:
	AudioManager.play_music_for_context("prize_corner")
	player.interaction_prompt_changed.connect(_on_prompt_changed)
	dialogue_box.dialogue_finished.connect(_on_dialogue_finished)
	_setup_ambient_sprite_effects()
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
	route_cue.setup("party_room", Vector2(24, 86), 430.0)

func _refresh_route_cue() -> void:
	if route_cue != null and is_instance_valid(route_cue):
		route_cue.refresh()

func _dialogue_is_active() -> bool:
	if dialogue_box == null:
		return false
	return dialogue_box.get("active") == true

func handle_hub_interaction(interactable: Node, _player_node: Node = null) -> void:
	match str(interactable.interactable_kind):
		"community_photos":
			start_dialogue(_get_env_state("party_community_wall", [
				{"speaker": "Community Wall", "text": "In the corner of almost every shot, the same figure stands half in frame."},
				{"speaker": "Community Wall", "text": "Always making sure everyone else fit."},
			]))
		"mascot_stage":
			start_dialogue(_get_env_state("party_mascot_stage", [
				{"speaker": "Party Stage", "text": "Kids' drawings are still taped along the front."},
				{"speaker": "Party Stage", "text": "One reads: THANK YOU FOR THE FREE GO."},
			]))
		"birthday_cabinet":
			start_dialogue(_get_env_state("party_birthday_cabinet", [
				{"speaker": "Birthday Cabinet", "text": "Someone kept the score low on purpose, so kids could always win."},
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


func _setup_ambient_sprite_effects() -> void:
	AMBIENT_EFFECTS.create_layer(self, $UILayer, [
		{
			"name": "StageNeonFlickerA",
			"position": Vector2(250, 84),
			"scale": Vector2(1.15, 1.15),
			"effect_type": "flicker",
			"speed": 0.85,
			"intensity": 0.07,
			"sprite_sheet_path": AMBIENT_EFFECTS.BLINK_DOT,
			"sprite_alpha": 0.55,
			"sprite_modulate": Color(1.0, 0.62, 0.92, 1.0),
		},
		{
			"name": "StageNeonFlickerB",
			"position": Vector2(390, 84),
			"scale": Vector2(1.15, 1.15),
			"effect_type": "flicker",
			"speed": 0.68,
			"intensity": 0.07,
			"sprite_sheet_path": AMBIENT_EFFECTS.BLINK_DOT,
			"sprite_alpha": 0.55,
			"sprite_modulate": Color(0.62, 0.9, 1.0, 1.0),
		},
		{
			"name": "PhotoWallTwinkle",
			"position": Vector2(170, 262),
			"scale": Vector2(1.1, 1.1),
			"effect_type": "random_screen_flash",
			"speed": 0.5,
			"intensity": 0.05,
			"sprite_sheet_path": AMBIENT_EFFECTS.PRIZE_TWINKLE,
			"sprite_alpha": 0.5,
		},
		{
			"name": "BirthdayCabinetScanline",
			"position": Vector2(475, 268),
			"scale": Vector2(1.5, 1.5),
			"effect_type": "scanline_pulse",
			"speed": 0.7,
			"sprite_sheet_path": AMBIENT_EFFECTS.SCANLINE_BAR,
			"sprite_frame_size": Vector2i(32, 8),
			"sprite_alpha": 0.6,
			"sprite_modulate": Color(0.65, 0.85, 1.0, 1.0),
		},
	])
