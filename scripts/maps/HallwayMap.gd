extends Node2D

const ROUTE_CUE_SCRIPT := preload("res://scripts/RouteCue.gd")
const AMBIENT_EFFECTS := preload("res://scripts/AmbientSpriteEffects.gd")
const QUEST_NOTICE_SCENE := preload("res://scenes/ui/QuestNotice.tscn")
const HALLWAY_BG_DIR := "res://assets/art/maps/hallways/"
const HALLWAY_PLACEHOLDERS := ["Background", "FloorBand", "StaticStripe"]
const DEFAULT_EXIT_ANCHORS := [Vector2(58, 233), Vector2(581, 233)]
const HALLWAY_EXIT_ANCHORS := {
	"cabinet_hallway": [Vector2(58, 233), Vector2(581, 233)],
	"prize_hallway": [Vector2(73, 227), Vector2(566, 227)],
	"maintenance_hallway": [Vector2(59, 233), Vector2(579, 233)],
	"back_hallway": [Vector2(62, 231), Vector2(576, 231)],
	"cabinet_snack_hallway": [Vector2(61, 298), Vector2(578, 298)],
	"snack_prize_hallway": [Vector2(59, 233), Vector2(579, 232)],
	"maintenance_staff_hallway": [Vector2(77, 233), Vector2(562, 233)],
}
const SPAWN_CLEARANCE := 56.0

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
	# Hallways are transitional: keep whatever track is already playing.
	if AudioManager.get_current_music_id().is_empty():
		AudioManager.play_music_for_context(_get_music_context())
	_ensure_objective_hud()
	_align_side_exits()
	_apply_background_art()
	player.interaction_prompt_changed.connect(_on_prompt_changed)
	dialogue_box.dialogue_finished.connect(_on_dialogue_finished)
	title_label.text = title_text
	# RouteCue carries actionable guidance; keep the decorative subtitle clear so
	# the map title remains the only text in the upper-left header.
	hint_label.text = ""
	hint_label.visible = false
	_setup_ambient_sprite_effects()
	_setup_route_cue()
	_apply_spawn_position()
	_on_prompt_changed("")
	call_deferred("_maybe_show_hallway_message")


func _ensure_objective_hud() -> void:
	# Every hallway is a full map and must retain the same top-right objective
	# HUD as the destination rooms. One legacy hallway had an authored copy;
	# this shared setup supplies it everywhere else without duplicate layers.
	if get_node_or_null("QuestNotice") != null:
		return
	var quest_notice := QUEST_NOTICE_SCENE.instantiate()
	quest_notice.name = "QuestNotice"
	add_child(quest_notice)

func _align_side_exits() -> void:
	# The generated hallway frames use several different silhouettes. These
	# anchors are measured from each background's actual neon wall recess.
	var anchors: Array = HALLWAY_EXIT_ANCHORS.get(hallway_id, DEFAULT_EXIT_ANCHORS)
	for child in get_children():
		var is_transition := child is Area2D and child.get("target_scene_path") != null
		if not child is Marker2D and not is_transition:
			continue
		var side_node := child as Node2D
		var is_left: bool = side_node.position.x < 320.0
		var exit_anchor: Vector2 = anchors[0 if is_left else 1]
		if child is Marker2D:
			var inward_offset: float = SPAWN_CLEARANCE if is_left else -SPAWN_CLEARANCE
			side_node.position = exit_anchor + Vector2(inward_offset, 0.0)
		else:
			side_node.position = exit_anchor

func can_open_pause_menu() -> bool:
	return not _dialogue_is_active()

func _apply_background_art() -> void:
	var path := HALLWAY_BG_DIR + hallway_id + "_background_640x440.png"
	if hallway_id.is_empty() or not ResourceLoader.exists(path):
		return
	var tex := load(path)
	if not tex is Texture2D:
		return
	var spr := Sprite2D.new()
	spr.name = "BackgroundArt"
	spr.texture = tex
	spr.centered = false
	spr.position = Vector2.ZERO
	add_child(spr)
	move_child(spr, 0)
	for placeholder_name in HALLWAY_PLACEHOLDERS:
		var node := get_node_or_null(NodePath(placeholder_name))
		if node is CanvasItem:
			(node as CanvasItem).visible = false

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
			"name": "HallScanlineCenter",
			"position": Vector2(320, 282),
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
			"position": Vector2(224, 282),
			"scale": Vector2(1.0, 1.0),
			"effect_type": "glow_pulse",
			"speed": 0.58,
			"sprite_sheet_path": AMBIENT_EFFECTS.BLINK_DOT,
			"sprite_alpha": 0.52,
			"sprite_modulate": accent,
		},
		{
			"name": "HallBlinkDotRight",
			"position": Vector2(416, 282),
			"scale": Vector2(1.0, 1.0),
			"effect_type": "glow_pulse",
			"speed": 0.68,
			"sprite_sheet_path": AMBIENT_EFFECTS.BLINK_DOT,
			"sprite_alpha": 0.5,
			"sprite_modulate": secondary,
		},
		{
			"name": "HallStaticSpark",
			"position": Vector2(320, 284),
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
			"position": Vector2(470, 272),
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
			"position": Vector2(170, 272),
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
			"position": Vector2(318, 268),
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
	# One whisper per hallway for the whole run - the phase only picks WHICH
	# lines play on that first visit, it must never re-arm the location.
	var counter_key := "hallway_message:%s" % hallway_id
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
	if not _hallway_message_story_gate_is_open():
		return []
	match hallway_id:
		"cabinet_hallway":
			return [
				{"speaker": "???", "text": "The cabinets know your hands. You do not know theirs.", "effect": "glitch"},
				{"speaker": "???", "text": "A prize can return a clue. It cannot tell you what your whole life means."},
			]
		"snack_hallway":
			return [
				{"speaker": "???", "text": "Every route in this arcade has a return path.", "effect": "glitch"},
				{"speaker": "???", "text": "Watch which lights follow you back."},
			]
		"prize_hallway":
			return [
				{"speaker": "???", "text": "Prizes remember hands better than names."},
				{"speaker": "???", "text": "Something on the shelf remembers those hands wanting and working.", "effect": "glitch"},
			]
		"maintenance_hallway":
			if GameState.lost_shift_file_completed and not GameState.static_service_run_completed:
				return [
					{"speaker": "???", "text": "The file opened a service route.", "effect": "glitch"},
					{"speaker": "???", "text": "Service routes are where arcades hide their bad wiring."},
				]
			return [
				{"speaker": "???", "text": "Maintenance is a tidy word for old damage.", "effect": "glitch"},
				{"speaker": "???", "text": "Ask Gus why one access code answered with two priorities."},
			]
		"back_hallway":
			if GameState.final_night_walk_completed and not GameState.memory_echo_completed:
				return [
					{"speaker": "???", "text": "The route played back clean."},
					{"speaker": "???", "text": "Clean playback does not mean a clean ending.", "effect": "glitch"},
					{"speaker": "???", "text": "The one walking behind you is carrying what you set down.", "effect": "shake"},
				]
			return [
				{"speaker": "???", "text": "Back halls count footsteps after the tokens stop falling."},
				{"speaker": "???", "text": "One set keeps landing half a beat behind yours.", "effect": "shake"},
			]
		"cabinet_snack_hallway":
			return [
				{"speaker": "???", "text": "Truth leaves a metallic taste.", "effect": "glitch"},
				{"speaker": "???", "text": "Fizz can cover it. It cannot fix it."},
			]
		"snack_prize_hallway":
			return [
				{"speaker": "???", "text": "The prize shelf still knows what you wanted."},
				{"speaker": "???", "text": "Wanting is not always a safe memory.", "effect": "glitch"},
				{"speaker": "Player", "text": "Is it trying to keep me away from something?"},
				{"speaker": "Player", "text": "I cannot tell if that is malice... or genuine concern."},
			]
		"maintenance_staff_hallway":
			return [
				{"speaker": "???", "text": "The door heard one hand knock with two intentions."},
				{"speaker": "???", "text": "One asked to enter. One asked to be done.", "effect": "glitch"},
			]
	return []

func _hallway_message_story_gate_is_open() -> bool:
	match hallway_id:
		"cabinet_hallway":
			return GameState.lost_token_quest_completed and not GameState.broken_high_score_completed
		"snack_hallway", "cabinet_snack_hallway":
			return GameState.lying_cabinets_completed \
				and GameState.mr_byte_truth_filter_debriefed \
				and GameState.gus_hub_checkin_truth_filter_done \
				and not GameState.circuit_soda_completed
		"prize_hallway", "snack_prize_hallway":
			return GameState.circuit_soda_completed \
				and GameState.vendo_unknown_clue_seen \
				and not GameState.prize_sort_completed
		"maintenance_hallway":
			return GameState.circuit_soda_completed \
				and GameState.prize_sort_completed \
				and GameState.gus_hub_checkin_prize_sort_done \
				and not GameState.static_service_run_completed
		"back_hallway":
			var final_walk_window := GameState.final_night_walk_completed and not GameState.memory_echo_completed
			var security_tape_window := GameState.maintenance_sync_completed and not GameState.security_tape_assembly_completed
			return final_walk_window or security_tape_window
		"maintenance_staff_hallway":
			return GameState.maintenance_sync_completed and not GameState.security_tape_assembly_completed
	return false
