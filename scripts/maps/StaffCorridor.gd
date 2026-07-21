extends Node2D

const ROUTE_CUE_SCRIPT := preload("res://scripts/RouteCue.gd")
const AMBIENT_EFFECTS := preload("res://scripts/AmbientSpriteEffects.gd")
const BACKGROUND_ART_PATH := "res://assets/art/maps/staff_corridor/staff_corridor_background_640x440.png"
const BACKGROUND_PLACEHOLDERS := ["Background", "CorridorPath", "MemoryEchoPlaceholder", "SecurityTapePlaceholder", "StaffRoomDoorPlaceholder"]

@onready var player: CharacterBody2D = $Player
@onready var ui_layer: Node2D = $UILayer
@onready var prompt_label: Label = $UILayer/InteractionPrompt
@onready var prompt_background: ColorRect = $UILayer/InteractionPromptBackground
@onready var quest_notice: CanvasLayer = $QuestNotice
@onready var dialogue_box: CanvasLayer = $DialogueBox

var route_cue: Control = null
var pending_after_dialogue: Callable = Callable()


func _ready() -> void:
	AudioManager.play_music_for_context("staff_corridor")
	_apply_background_art()
	player.interaction_prompt_changed.connect(_on_prompt_changed)
	dialogue_box.dialogue_finished.connect(_on_dialogue_finished)
	_setup_ambient_sprite_effects()
	_setup_route_cue()
	_apply_spawn_position()
	_on_prompt_changed("")
	call_deferred("_maybe_start_conscience_encounter")


func can_open_pause_menu() -> bool:
	return not _dialogue_is_active() and not ConscienceEncounterDirector.is_encounter_active()


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


func _maybe_start_conscience_encounter() -> void:
	ConscienceEncounterDirector.maybe_start_encounter(self, "staff_corridor_approach")


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
			"name": "StaffDoorWarningLight",
			"position": Vector2(296, 52),
			"scale": Vector2(1.2, 1.2),
			"effect_type": "blink",
			"speed": 0.45,
			"intensity": 0.07,
			"sprite_sheet_path": AMBIENT_EFFECTS.WARNING_LIGHT,
			"sprite_alpha": 0.66,
		},
		{
			"name": "CorridorDustWispC",
			"position": Vector2(282, 356),
			"scale": Vector2(1.1, 1.1),
			"effect_type": "dust_mote_drift",
			"speed": 0.4,
			"intensity": 0.14,
			"sprite_sheet_path": AMBIENT_EFFECTS.MEMORY_WISP,
			"sprite_frame_size": Vector2i(24, 16),
			"sprite_alpha": 0.5,
		},
	])
