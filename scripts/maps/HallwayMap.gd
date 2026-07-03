extends Node2D

const ROUTE_CUE_SCRIPT := preload("res://scripts/RouteCue.gd")
const AMBIENT_EFFECTS := preload("res://scripts/AmbientSpriteEffects.gd")

@export var hallway_id := ""
@export var title_text := "HALLWAY"
@export var hint_text := ""

@onready var player: CharacterBody2D = $Player
@onready var ui_layer: Node2D = $UILayer
@onready var dialogue_box: CanvasLayer = $UILayer/DialogueBox
@onready var prompt_label: Label = $UILayer/InteractionPrompt
@onready var prompt_background: ColorRect = $UILayer/InteractionPromptBackground
@onready var title_label: Label = $UILayer/TitleLabel
@onready var hint_label: Label = $UILayer/HintLabel

var pending_after_dialogue: Callable = Callable()
var route_cue: Control = null

func _ready() -> void:
	AudioManager.play_music_for_context(_get_music_context())
	player.interaction_prompt_changed.connect(_on_prompt_changed)
	dialogue_box.dialogue_finished.connect(_on_dialogue_finished)
	title_label.text = title_text
	hint_label.text = hint_text
	hint_label.visible = not hint_text.is_empty()
	_setup_ambient_sprite_effects()
	_setup_route_cue()
	_apply_spawn_position()
	_on_prompt_changed("")
	call_deferred("_maybe_show_hallway_message")

func can_open_pause_menu() -> bool:
	return not _dialogue_is_active()

func _get_music_context() -> String:
	match hallway_id:
		"cabinet_hallway", "cabinet_snack_hallway":
			return "cabinet_row"
		"snack_hallway", "snack_prize_hallway":
			return "snack_alcove"
		"prize_hallway":
			return "prize_corner"
		"maintenance_hallway", "maintenance_staff_hallway":
			return "maintenance_hall"
		"back_hallway":
			return "staff_corridor"
	return "arcade_hub"

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

func _setup_route_cue() -> void:
	route_cue = ROUTE_CUE_SCRIPT.new()
	ui_layer.add_child(route_cue)
	route_cue.call("setup", hallway_id, Vector2(24, 84), 390.0)

func _setup_ambient_sprite_effects() -> void:
	AMBIENT_EFFECTS.create_layer(self, ui_layer, _get_hallway_ambient_entries())

func _get_hallway_ambient_entries() -> Array[Dictionary]:
	var accent := Color(0.62, 0.9, 1.0, 1.0)
	var secondary := Color(1.0, 0.86, 0.52, 1.0)
	match hallway_id:
		"cabinet_hallway", "cabinet_snack_hallway":
			accent = Color(0.84, 0.72, 1.0, 1.0)
			secondary = Color(0.52, 0.95, 1.0, 1.0)
		"snack_hallway", "snack_prize_hallway":
			accent = Color(0.58, 1.0, 0.72, 1.0)
			secondary = Color(1.0, 0.86, 0.48, 1.0)
		"prize_hallway":
			accent = Color(1.0, 0.86, 0.42, 1.0)
			secondary = Color(1.0, 0.62, 0.92, 1.0)
		"maintenance_hallway", "maintenance_staff_hallway":
			accent = Color(1.0, 0.58, 0.38, 1.0)
			secondary = Color(0.62, 1.0, 0.82, 1.0)
		"back_hallway":
			accent = Color(0.62, 0.82, 1.0, 1.0)
			secondary = Color(1.0, 0.72, 1.0, 1.0)
	var entries: Array[Dictionary] = [
		{
			"name": "LeftExitArrow",
			"position": Vector2(34, 222),
			"rotation": PI,
			"scale": Vector2(1.35, 1.35),
			"effect_type": "blink",
			"speed": 0.62,
			"sprite_sheet_path": AMBIENT_EFFECTS.NEON_ARROW,
			"sprite_alpha": 0.62,
			"sprite_modulate": accent,
		},
		{
			"name": "RightExitArrow",
			"position": Vector2(606, 222),
			"scale": Vector2(1.35, 1.35),
			"effect_type": "blink",
			"speed": 0.72,
			"sprite_sheet_path": AMBIENT_EFFECTS.NEON_ARROW,
			"sprite_alpha": 0.66,
			"sprite_modulate": secondary,
		},
		{
			"name": "HallScanlineCenter",
			"position": Vector2(320, 220),
			"scale": Vector2(5.8, 1.25),
			"effect_type": "scanline_pulse",
			"speed": 0.58,
			"sprite_sheet_path": AMBIENT_EFFECTS.SCANLINE_BAR,
			"sprite_frame_size": Vector2i(32, 8),
			"sprite_alpha": 0.4,
			"sprite_modulate": accent,
		},
		{
			"name": "HallBlinkDotLeft",
			"position": Vector2(224, 220),
			"scale": Vector2(1.0, 1.0),
			"effect_type": "glow_pulse",
			"speed": 0.58,
			"sprite_sheet_path": AMBIENT_EFFECTS.BLINK_DOT,
			"sprite_alpha": 0.52,
			"sprite_modulate": accent,
		},
		{
			"name": "HallBlinkDotRight",
			"position": Vector2(416, 220),
			"scale": Vector2(1.0, 1.0),
			"effect_type": "glow_pulse",
			"speed": 0.68,
			"sprite_sheet_path": AMBIENT_EFFECTS.BLINK_DOT,
			"sprite_alpha": 0.5,
			"sprite_modulate": secondary,
		},
		{
			"name": "HallStaticSpark",
			"position": Vector2(320, 222),
			"scale": Vector2(1.15, 1.15),
			"effect_type": "random_screen_flash",
			"speed": 0.82,
			"intensity": 0.08,
			"sprite_sheet_path": AMBIENT_EFFECTS.STATIC_SPARK,
			"sprite_alpha": 0.54,
			"sprite_modulate": accent,
		},
	]
	if hallway_id.find("snack") >= 0:
		entries.append({
			"name": "HallSodaBubble",
			"position": Vector2(470, 210),
			"scale": Vector2(1.2, 1.2),
			"effect_type": "bob",
			"speed": 0.56,
			"intensity": 0.16,
			"sprite_sheet_path": AMBIENT_EFFECTS.SODA_BUBBLE,
			"sprite_alpha": 0.58,
		})
	if hallway_id.find("prize") >= 0:
		entries.append({
			"name": "HallPrizeTwinkle",
			"position": Vector2(170, 210),
			"scale": Vector2(1.2, 1.2),
			"effect_type": "random_screen_flash",
			"speed": 0.52,
			"sprite_sheet_path": AMBIENT_EFFECTS.PRIZE_TWINKLE,
			"sprite_alpha": 0.58,
			"sprite_modulate": secondary,
		})
	if hallway_id.find("maintenance") >= 0:
		entries.append({
			"name": "HallWarningLight",
			"position": Vector2(320, 160),
			"scale": Vector2(1.2, 1.2),
			"effect_type": "blink",
			"speed": 0.48,
			"sprite_sheet_path": AMBIENT_EFFECTS.WARNING_LIGHT,
			"sprite_alpha": 0.58,
		})
	if hallway_id.find("staff") >= 0 or hallway_id == "back_hallway":
		entries.append({
			"name": "HallMemoryWisp",
			"position": Vector2(318, 206),
			"scale": Vector2(1.2, 1.2),
			"effect_type": "dust_mote_drift",
			"speed": 0.44,
			"intensity": 0.16,
			"sprite_sheet_path": AMBIENT_EFFECTS.MEMORY_WISP,
			"sprite_frame_size": Vector2i(24, 16),
			"sprite_alpha": 0.54,
			"sprite_modulate": secondary,
		})
	return entries

func _refresh_route_cue() -> void:
	if route_cue != null and is_instance_valid(route_cue) and route_cue.has_method("refresh"):
		route_cue.call("refresh")

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
					{"speaker": "???", "text": "The one walking behind you is carrying what you set down.", "effect": "shake"},
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
