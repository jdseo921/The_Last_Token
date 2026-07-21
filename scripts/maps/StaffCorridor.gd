extends Node2D

const ROUTE_CUE_SCRIPT := preload("res://scripts/RouteCue.gd")
const AMBIENT_EFFECTS := preload("res://scripts/AmbientSpriteEffects.gd")
const BACKGROUND_ART_PATH := "res://assets/art/maps/staff_corridor/staff_corridor_background_640x440.png"
const BACKGROUND_PLACEHOLDERS := ["Background", "CorridorPath", "MemoryEchoPlaceholder", "SecurityTapePlaceholder", "FinalNightWalkPlaceholder", "StaffRoomDoorPlaceholder"]

@onready var player: CharacterBody2D = $Player
@onready var ui_layer: Node2D = $UILayer
@onready var prompt_label: Label = $UILayer/InteractionPrompt
@onready var prompt_background: ColorRect = $UILayer/InteractionPromptBackground
@onready var quest_notice: CanvasLayer = $QuestNotice

var route_cue: Control = null


func _ready() -> void:
	AudioManager.play_music_for_context("staff_corridor")
	_apply_background_art()
	player.interaction_prompt_changed.connect(_on_prompt_changed)
	_setup_ambient_sprite_effects()
	_setup_route_cue()
	_apply_spawn_position()
	_on_prompt_changed("")


func can_open_pause_menu() -> bool:
	return true


func _apply_background_art() -> void:
	if not ResourceLoader.exists(BACKGROUND_ART_PATH):
		return
	var texture := load(BACKGROUND_ART_PATH)
	if not texture is Texture2D:
		return
	var background := Sprite2D.new()
	background.name = "BackgroundArt"
	background.texture = texture
	background.centered = false
	background.position = Vector2.ZERO
	add_child(background)
	move_child(background, 0)
	for placeholder_name in BACKGROUND_PLACEHOLDERS:
		var placeholder := get_node_or_null(NodePath(placeholder_name))
		if placeholder is CanvasItem:
			(placeholder as CanvasItem).visible = false


func _apply_spawn_position() -> void:
	var spawn_id := GameState.consume_pending_spawn_id()
	var return_point: Variant = GameState.consume_return_point(scene_file_path)
	if return_point != null:
		player.global_position = return_point
		return
	var marker := get_node_or_null(spawn_id)
	if marker is Marker2D:
		player.global_position = marker.global_position


func _on_prompt_changed(text: String) -> void:
	prompt_label.text = text
	prompt_label.visible = not text.is_empty()
	prompt_background.visible = prompt_label.visible


func _setup_route_cue() -> void:
	if quest_notice != null and quest_notice.has_method("set_location_context"):
		quest_notice.call("set_location_context", "staff_corridor")
	route_cue = ROUTE_CUE_SCRIPT.new()
	ui_layer.add_child(route_cue)
	route_cue.call("setup", "staff_corridor", Vector2(24, 86), 430.0)


func _setup_ambient_sprite_effects() -> void:
	AMBIENT_EFFECTS.create_layer(self, ui_layer, [
		{
			"name": "StaffDoorLockBlink",
			"position": Vector2(338, 86),
			"scale": Vector2(1.55, 1.55),
			"effect_type": "blink",
			"speed": 0.6,
			"sprite_sheet_path": AMBIENT_EFFECTS.STAFF_LOCK_BLINK,
			"sprite_alpha": 0.8,
		},
		{
			"name": "MemoryEchoBeacon",
			"position": Vector2(320, 228),
			"scale": Vector2(1.9, 1.9),
			"effect_type": "glow_pulse",
			"speed": 0.5,
			"sprite_sheet_path": AMBIENT_EFFECTS.MEMORY_WISP,
			"sprite_frame_size": Vector2i(24, 16),
			"sprite_alpha": 0.85,
			"sprite_modulate": Color(0.6, 0.98, 1.0, 1.0),
		},
		{
			"name": "MemoryEchoWispA",
			"position": Vector2(292, 190),
			"scale": Vector2(1.55, 1.55),
			"effect_type": "dust_mote_drift",
			"speed": 0.44,
			"intensity": 0.18,
			"sprite_sheet_path": AMBIENT_EFFECTS.MEMORY_WISP,
			"sprite_frame_size": Vector2i(24, 16),
			"sprite_alpha": 0.76,
		},
		{
			"name": "MemoryEchoWispB",
			"position": Vector2(360, 238),
			"scale": Vector2(1.35, 1.35),
			"effect_type": "dust_mote_drift",
			"speed": 0.58,
			"intensity": 0.14,
			"sprite_sheet_path": AMBIENT_EFFECTS.MEMORY_WISP,
			"sprite_frame_size": Vector2i(24, 16),
			"sprite_alpha": 0.62,
			"sprite_modulate": Color(1.0, 0.76, 1.0, 1.0),
		},
		{
			"name": "SecurityTapeScanline",
			"position": Vector2(320, 309),
			"scale": Vector2(2.25, 1.7),
			"effect_type": "scanline_pulse",
			"speed": 0.74,
			"active_flag_optional": "maintenance_sync_completed",
			"sprite_sheet_path": AMBIENT_EFFECTS.SCANLINE_BAR,
			"sprite_frame_size": Vector2i(32, 8),
			"sprite_alpha": 0.72,
		},
	])
