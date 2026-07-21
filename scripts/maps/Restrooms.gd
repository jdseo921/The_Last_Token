extends Node2D

# Restrooms / Mirror Nook (structure-first shell) — off Party Room.
# Purposes: the mirror foreshadow (two signals where one stands), a hidden token.
# Small eerie beat. Placeholder text.

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
	AudioManager.play_music_for_context("arcade_hub")
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
	route_cue.setup("restrooms", Vector2(24, 86), 430.0)

func _refresh_route_cue() -> void:
	if route_cue != null and is_instance_valid(route_cue):
		route_cue.refresh()

func _dialogue_is_active() -> bool:
	if dialogue_box == null:
		return false
	return dialogue_box.get("active") == true

func handle_hub_interaction(interactable: Node, _player_node: Node = null) -> void:
	match str(interactable.interactable_kind):
		"mirror":
			start_dialogue(_get_env_state("restroom_mirror", [
				{"speaker": "Mirror", "text": "For a moment, two figures stand where only one should."},
				{"speaker": "Mirror", "text": "One of them is not quite finished moving when you are."},
			]))
		"stall":
			start_dialogue(_get_env_state("restroom_stall", [
				{"speaker": "Stall", "text": "A hand-drawn HIGH SCORE list is taped inside."},
				{"speaker": "Stall", "text": "Every name on it is the same handwriting."},
			]))
		"hidden_token":
			start_dialogue(_get_env_state("restroom_token", [
				{"speaker": "Windowsill", "text": "A single arcade token, cold and older than the others."},
				{"speaker": "Windowsill", "text": "It fits your hand like it remembers being held."},
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
	# No MEMORY_WISP here on purpose: the mirror's foreshadow stays in text.
	# Static and scanline read as an electrical fault, not the private channel.
	AMBIENT_EFFECTS.create_layer(self, $UILayer, [
		{
			"name": "MirrorStaticFlash",
			"position": Vector2(320, 132),
			"scale": Vector2(1.2, 1.2),
			"effect_type": "random_screen_flash",
			"speed": 0.8,
			"intensity": 0.07,
			"sprite_sheet_path": AMBIENT_EFFECTS.STATIC_SPARK,
			"sprite_alpha": 0.5,
		},
		{
			"name": "MirrorScanline",
			"position": Vector2(320, 152),
			"scale": Vector2(1.6, 1.3),
			"effect_type": "scanline_pulse",
			"speed": 0.6,
			"sprite_sheet_path": AMBIENT_EFFECTS.SCANLINE_BAR,
			"sprite_frame_size": Vector2i(32, 8),
			"sprite_alpha": 0.42,
			"sprite_modulate": Color(0.66, 0.84, 1.0, 1.0),
		},
		{
			"name": "WindowsillGlint",
			"position": Vector2(470, 318),
			"scale": Vector2(1.0, 1.0),
			"effect_type": "random_screen_flash",
			"speed": 0.55,
			"intensity": 0.05,
			"sprite_sheet_path": AMBIENT_EFFECTS.TICKET_GLINT,
			"sprite_alpha": 0.55,
		},
		{
			"name": "RestroomFloorDustDrift",
			"position": Vector2(200, 286),
			"scale": Vector2(0.85, 0.85),
			"effect_type": "dust_mote_drift",
			"speed": 0.38,
			"intensity": 0.14,
			"sprite_sheet_path": AMBIENT_EFFECTS.BLINK_DOT,
			"sprite_alpha": 0.25,
			"sprite_modulate": Color(0.72, 0.8, 0.9, 1.0),
		},
	])
