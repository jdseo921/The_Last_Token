extends Node2D

const ROUTE_CUE_SCRIPT := preload("res://scripts/RouteCue.gd")
const AMBIENT_EFFECTS := preload("res://scripts/AmbientSpriteEffects.gd")
const DIALOGUE_POOL := preload("res://scripts/DialoguePool.gd")
const BACKGROUND_ART_PATH := "res://assets/art/maps/maintenance_hall/maintenance_hall_background_640x440.png"

@onready var player: CharacterBody2D = $Player
@onready var background_art: Sprite2D = $BackgroundArt
@onready var ui_layer: Node2D = $UILayer
@onready var dialogue_box: CanvasLayer = $UILayer/DialogueBox
@onready var prompt_label: Label = $UILayer/InteractionPrompt
@onready var prompt_background: ColorRect = $UILayer/InteractionPromptBackground
@onready var sync_door_glow: Polygon2D = $SyncDoorGlow
@onready var quest_notice: CanvasLayer = $QuestNotice
@onready var gus: Area2D = $InteractableLayer/Gus

var pending_after_dialogue: Callable = Callable()
var route_cue: Control = null

func _ready() -> void:
	AudioManager.play_music_for_context("maintenance_hall")
	player.interaction_prompt_changed.connect(_on_prompt_changed)
	dialogue_box.dialogue_finished.connect(_on_dialogue_finished)
	_apply_background_art()
	_setup_ambient_sprite_effects()
	_setup_route_cue()
	_apply_spawn_position()
	_on_prompt_changed("")
	_refresh_gus_presence()
	_refresh_sync_state()
	call_deferred("_maybe_play_completion_anecdote")

func can_open_pause_menu() -> bool:
	return not _dialogue_is_active() and not ConscienceEncounterDirector.is_encounter_active() and not _choice_box_is_open()

func _choice_box_is_open() -> bool:
	if ui_layer == null:
		return false
	for child in ui_layer.get_children():
		if child.has_method("open_choice") and child is CanvasItem and (child as CanvasItem).visible:
			return true
	return false

func _apply_spawn_position() -> void:
	var spawn_id := GameState.consume_pending_spawn_id()
	# Coming back from a minigame in this room: stand exactly where we left.
	var back: Variant = GameState.consume_return_point(scene_file_path)
	if back != null:
		player.global_position = back
		return
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
	route_cue.call("setup", "maintenance_hall", Vector2(24, 86), 430.0)

func _refresh_route_cue() -> void:
	if route_cue != null and is_instance_valid(route_cue) and route_cue.has_method("refresh"):
		route_cue.call("refresh")

func start_dialogue(lines: Array, after_dialogue: Callable = Callable()) -> void:
	pending_after_dialogue = after_dialogue
	if player and player.has_method("set_control_enabled"):
		player.set_control_enabled(false)
	dialogue_box.start_dialogue(lines)

func _get_gus_lines(key: String, fallback: Array) -> Array:
	return DIALOGUE_POOL.get_lines("gus", key, fallback)

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
	lines = _get_environment_lines("%s_grounded" % object_key, fallback)
	if not lines.is_empty():
		return lines
	return fallback

func _get_environment_state_key() -> String:
	GameState.update_memory_signal_from_progress()
	if GameState.twist_reveal_seen or GameState.post_reveal_roam_unlocked:
		return "restored"
	return GameState.get_memory_signal_label().to_lower()

func _combine_dialogue_lines(first_lines: Array, second_lines: Array) -> Array:
	var combined := first_lines.duplicate(true)
	combined.append_array(second_lines.duplicate(true))
	return combined

func _on_dialogue_finished() -> void:
	if pending_after_dialogue.is_valid():
		pending_after_dialogue.call()
		pending_after_dialogue = Callable()
	if player and player.has_method("set_control_enabled"):
		player.set_control_enabled(true)
	_refresh_sync_state()
	_refresh_gus_presence()
	_refresh_route_cue()

func _dialogue_is_active() -> bool:
	if dialogue_box == null:
		return false
	return dialogue_box.get("active") == true

func handle_hub_interaction(interactable: Node, _player_node: Node = null) -> void:
	match str(interactable.interactable_kind):
		"gus":
			_handle_gus()
		"maintenance_sync":
			_handle_maintenance_sync()
		_:
			start_dialogue([{"speaker": "System", "text": "Nothing happens."}])

func _handle_gus() -> void:
	if GameState.post_reveal_roam_unlocked and GameState.witness_gus_heard:
		start_dialogue(_get_gus_lines("static_run_replay_offer", [
			{"speaker": "Gus", "text": "The route is alive and humming, thanks to you."},
			{"speaker": "Gus", "text": "Want to run it again anyway? For fun."},
		]), Callable(self, "_offer_static_run_replay"))
		return
	GameState.gus_intro_seen = true
	if GameState.twist_reveal_seen or GameState.post_reveal_roam_unlocked:
		GameState.gus_post_reveal_seen = true
		var was_completed := _was_witness_route_completed()
		GameState.mark_witness_gus_heard()
		start_dialogue(_get_gus_lines("post_reveal_witness", [
			{"speaker": "Gus", "text": "Employee 04."},
			{"speaker": "Gus", "text": "Yeah. I know."},
			{"speaker": "Gus", "text": "Keep breathing."},
		]), _get_witness_completion_callback(was_completed))
		return
	if not GameState.circuit_soda_completed:
		start_dialogue([
			{"speaker": "Gus", "text": "Maintenance Hall is not ready for you yet."},
			{"speaker": "Gus", "text": "Go let Vendo route whatever counts as your signal first."},
		])
		return
	if not GameState.lost_shift_file_completed and not GameState.maintenance_sync_completed and not GameState.story_puzzle_completed:
		if not GameState.lost_shift_file_started:
			start_dialogue([
				{"speaker": "Gus", "text": "I do not have a service lead yet."},
				{"speaker": "Gus", "text": "If Pip found anything in Prize Corner, bring it to me on the Arcade Hub floor."},
			])
		else:
			start_dialogue([
				{"speaker": "Gus", "text": "I am still sorting the shift files upstairs."},
				{"speaker": "Gus", "text": "Finish the Closing Shift Echoes route, then report to me in the Arcade Hub."},
			])
		return
	if GameState.lost_shift_file_completed and not GameState.static_service_run_completed and not GameState.maintenance_sync_completed and not GameState.story_puzzle_completed:
		start_dialogue(_get_gus_lines("static_service_full_intro", [
			{"speaker": "Gus", "text": "The file gives me enough to work with."},
			{"speaker": "Gus", "text": "The maintenance route is still dead, but the Sync can run a diagnostic."},
			{"speaker": "Gus", "text": "Use the Maintenance Sync when you are ready. I will keep the door from developing more opinions."},
		]))
		return
	if GameState.static_service_run_completed and not GameState.maintenance_sync_completed:
		start_dialogue(_get_gus_lines("maintenance_sync_completion_anecdote", [
			{"speaker": "Gus", "text": "The Sync read your signal cleanly. That is more than I expected."},
			{"speaker": "Gus", "text": "I opened Staff Access. It is off-limits to everyone except you."},
			{"speaker": "Player", "text": "Why me?"},
			{"speaker": "Gus", "text": "I do not know yet. Just take it slowly in there, okay?"},
		]), Callable(self, "_complete_sync_and_send_gus_back_to_hub"))
		return
	if not GameState.gus_sync_anecdote_seen:
		start_dialogue(_get_gus_lines("maintenance_sync_completion_anecdote", [
			{"speaker": "Gus", "text": "The Sync accepted you. Staff Access is off-limits to everyone except you."},
			{"speaker": "Player", "text": "Why me?"},
			{"speaker": "Gus", "text": "You will find out soon enough."},
		]), Callable(self, "_send_gus_back_to_hub"))
		return
	if GameState.memory_echo_completed and not GameState.twist_reveal_seen:
		start_dialogue([
			{"speaker": "Gus", "text": "Hallway stopped buzzing."},
			{"speaker": "Gus", "text": "That means it is either fixed or waiting."},
			{"speaker": "Gus", "text": "I hate both options."},
		])
		return
	start_dialogue([
		{"speaker": "Gus", "text": "Door still listens."},
		{"speaker": "Gus", "text": "Still hate that."},
	])

func _handle_maintenance_sync() -> void:
	if not GameState.circuit_soda_completed:
		start_dialogue(_get_environment_lines("maintenance_sync_machine_circuit_required", [
			{"speaker": "Maintenance Sync", "text": "SIGNAL ROUTE MISSING."},
			{"speaker": "Maintenance Sync", "text": "CIRCUIT SODA REQUIRED."},
		]))
		return
	if not GameState.lost_shift_file_completed and not GameState.maintenance_sync_completed and not GameState.story_puzzle_completed:
		start_dialogue(_get_environment_lines("maintenance_sync_machine_lost_shift_required", [
			{"speaker": "Maintenance Sync", "text": "MAINTENANCE SYNC LOCKED."},
			{"speaker": "Maintenance Sync", "text": "CLOSING SHIFT ECHOES REQUIRED."},
		]))
		return
	if not GameState.static_service_run_completed and not GameState.maintenance_sync_completed and not GameState.story_puzzle_completed:
		start_dialogue(_get_environment_lines("maintenance_sync_machine_static_service_required", [
			{"speaker": "Maintenance Sync", "text": "STATIC SERVICE ROUTE READY."},
			{"speaker": "Maintenance Sync", "text": "RUN DIAGNOSTIC?"},
		]), Callable(self, "_go_to_static_service_run"))
		return
	if GameState.post_reveal_roam_unlocked and GameState.maintenance_sync_completed:
		start_dialogue(_get_environment_lines("maintenance_sync_machine_replay_offer", [
			{"speaker": "Maintenance Sync", "text": "DOOR AND LOCK IN AGREEMENT."},
			{"speaker": "Maintenance Sync", "text": "RECREATIONAL SYNC AVAILABLE."},
		]), Callable(self, "_offer_maintenance_sync_replay"))
		return
	if GameState.static_service_run_completed and not GameState.maintenance_sync_completed and not GameState.story_puzzle_completed:
		start_dialogue([
			{"speaker": "Maintenance Sync", "text": "SERVICE CURRENT NORMAL. STAFF ACCESS READY."},
			{"speaker": "Player", "text": "(It finally sounds calm. I should report to Gus.)"},
		])
		return
	if GameState.maintenance_sync_completed or GameState.story_puzzle_completed:
		start_dialogue(_get_environment_state_lines("maintenance_sync_machine", [
			{"speaker": "Maintenance Sync", "text": "ACCESS GRANTED."},
			{"speaker": "Maintenance Sync", "text": "EMPLOYEE SIGNAL ACCEPTED."},
		]))
		return
	start_dialogue(_get_environment_lines("maintenance_sync_machine_static_service_required", [
		{"speaker": "Maintenance Sync", "text": "STATIC SERVICE ROUTE READY."},
	]))

func _go_to_static_service_run() -> void:
	GameState.start_static_service_run()
	GameState.set_pending_spawn_id("Spawn_FromMaintenanceSync")
	SceneChanger.go_to_static_service_run()

func _go_to_maintenance_sync() -> void:
	GameState.start_maintenance_sync()
	GameState.set_pending_spawn_id("Spawn_FromMaintenanceSync")
	SceneChanger.go_to_maintenance_sync()

func _refresh_gus_presence() -> void:
	# Gus moves here only for the service sequence. Once the Sync accepts the
	# player, he returns to the hub and leaves the Staff Access discovery alone.
	# Post-reveal he drifts back so the Static Service Run replay stays reachable.
	var post_reveal := GameState.twist_reveal_seen or GameState.post_reveal_roam_unlocked
	var available := (GameState.lost_shift_file_completed and (not GameState.maintenance_sync_completed or not GameState.gus_sync_anecdote_seen) and not post_reveal) or GameState.post_reveal_roam_unlocked
	gus.visible = available
	gus.monitoring = available
	gus.monitorable = available
	var collision := gus.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision != null:
		collision.set_deferred("disabled", not available)

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

func _apply_background_art() -> void:
	var loaded := _apply_sprite_texture(background_art, BACKGROUND_ART_PATH)
	for placeholder in [$Background, $UtilityWall, $GusPlaceholder, $SyncDoorPlaceholder]:
		if placeholder is CanvasItem:
			placeholder.visible = not loaded

func _setup_ambient_sprite_effects() -> void:
	AMBIENT_EFFECTS.create_layer(self, ui_layer, [
		{
			"name": "WarningLightLeft",
			"position": Vector2(230, 78),
			"scale": Vector2(1.4, 1.4),
			"effect_type": "blink",
			"speed": 0.45,
			"intensity": 0.08,
			"sprite_sheet_path": AMBIENT_EFFECTS.WARNING_LIGHT,
			"sprite_alpha": 0.76,
		},
		{
			"name": "WarningLightRight",
			"position": Vector2(404, 78),
			"scale": Vector2(1.4, 1.4),
			"effect_type": "blink",
			"speed": 0.52,
			"intensity": 0.08,
			"sprite_sheet_path": AMBIENT_EFFECTS.WARNING_LIGHT,
			"sprite_alpha": 0.74,
		},
		{
			"name": "SyncDoorLockBlink",
			"position": Vector2(496, 136),
			"scale": Vector2(1.55, 1.55),
			"effect_type": "blink",
			"speed": 0.62,
			"only_when_memory_signal_at_least": 2,
			"sprite_sheet_path": AMBIENT_EFFECTS.STAFF_LOCK_BLINK,
			"sprite_alpha": 0.8,
		},
		{
			"name": "SyncDoorScanline",
			"position": Vector2(478, 124),
			"scale": Vector2(1.7, 1.7),
			"effect_type": "scanline_pulse",
			"speed": 0.68,
			"sprite_sheet_path": AMBIENT_EFFECTS.SCANLINE_BAR,
			"sprite_frame_size": Vector2i(32, 8),
			"sprite_alpha": 0.72,
			"sprite_modulate": Color(0.7, 1.0, 0.82, 1.0),
		},
		{
			"name": "MaintenanceSparkA",
			"position": Vector2(254, 146),
			"scale": Vector2(1.25, 1.25),
			"effect_type": "random_screen_flash",
			"speed": 0.82,
			"sprite_sheet_path": AMBIENT_EFFECTS.STATIC_SPARK,
			"sprite_alpha": 0.64,
		},
		{
			"name": "StaffPassageWarningLight",
			"position": Vector2(346, 132),
			"scale": Vector2(1.25, 1.25),
			"effect_type": "blink",
			"speed": 0.4,
			"intensity": 0.07,
			"sprite_sheet_path": AMBIENT_EFFECTS.WARNING_LIGHT,
			"sprite_alpha": 0.7,
		},
		{
			"name": "GusWorkbenchSpark",
			"position": Vector2(138, 226),
			"scale": Vector2(1.15, 1.15),
			"effect_type": "random_screen_flash",
			"speed": 0.78,
			"intensity": 0.07,
			"sprite_sheet_path": AMBIENT_EFFECTS.STATIC_SPARK,
			"sprite_alpha": 0.6,
		},
		{
			"name": "SyncDoorSparkB",
			"position": Vector2(500, 172),
			"scale": Vector2(1.1, 1.1),
			"effect_type": "random_screen_flash",
			"speed": 0.9,
			"intensity": 0.06,
			"sprite_sheet_path": AMBIENT_EFFECTS.STATIC_SPARK,
			"sprite_alpha": 0.55,
		},
		{
			"name": "HallFloorDustDrift",
			"position": Vector2(280, 300),
			"scale": Vector2(0.9, 0.9),
			"effect_type": "dust_mote_drift",
			"speed": 0.4,
			"intensity": 0.16,
			"sprite_sheet_path": AMBIENT_EFFECTS.BLINK_DOT,
			"sprite_alpha": 0.26,
			"sprite_modulate": Color(1.0, 0.72, 0.55, 1.0),
		},
	])

func _refresh_sync_state() -> void:
	if sync_door_glow == null:
		return
	sync_door_glow.visible = GameState.circuit_soda_completed and GameState.lost_shift_file_completed and GameState.static_service_run_completed and not GameState.story_puzzle_completed

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

func _maybe_play_completion_anecdote() -> void:
	if _dialogue_is_active() or ConscienceEncounterDirector.is_encounter_active():
		return
	if GameState.consume_postgame_replay_return("maintenance_sync"):
		start_dialogue(_get_environment_lines("maintenance_sync_machine_replay_return", [
			{"speaker": "Maintenance Sync", "text": "SYNC COMPLETE. AGREEMENT MAINTAINED."},
			{"speaker": "Maintenance Sync", "text": "THE DOOR SAYS THANK YOU. IN DOOR."},
		]))
		return
	if GameState.consume_postgame_replay_return("static_service_run"):
		start_dialogue(_get_gus_lines("static_run_replay_return", [
			{"speaker": "Gus", "text": "Power held the whole way down."},
			{"speaker": "Gus", "text": "That is not forgetting. That is the good version of remembering."},
		]))
		return
	if GameState.static_service_run_completed and not GameState.maintenance_sync_completed and GameState.get_npc_dialogue_count("maintenance_sync_restored_notice") == 0:
		GameState.increment_npc_dialogue_count("maintenance_sync_restored_notice")
		start_dialogue([
			{"speaker": "Maintenance Sync", "text": "SERVICE CURRENT NORMAL. STAFF ACCESS READY."},
			{"speaker": "Player", "text": "(The signal settled down. I should report to Gus.)"},
		])

func _send_gus_back_to_hub() -> void:
	await SceneChanger.play_brief_fade()
	GameState.gus_sync_anecdote_seen = true
	_refresh_gus_presence()

func _complete_sync_and_send_gus_back_to_hub() -> void:
	GameState.complete_maintenance_sync()
	_send_gus_back_to_hub()

func _offer_maintenance_sync_replay() -> void:
	PostGameReplay.open_offer(ui_layer, player, "Sync the door again?", "maintenance_sync", Callable(self, "_go_to_maintenance_sync"))

func _offer_static_run_replay() -> void:
	PostGameReplay.open_offer(ui_layer, player, "Run the service route again?", "static_service_run", Callable(self, "_go_to_static_service_run"))
