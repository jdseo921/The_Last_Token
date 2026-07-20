extends "res://scripts/maps/HallwayMap.gd"

const DIALOGUE_POOL := preload("res://scripts/DialoguePool.gd")
const NORTH_EXIT_ANCHOR := Vector2(320, 30)
const NORTH_SPAWN_POSITION := Vector2(320, 112)

@onready var night_ledger_cabinet: Area2D = $InteractableLayer/NightLedgerCabinet


func _ready() -> void:
	AudioManager.play_music_for_context("after_hours_archive")
	super._ready()
	_refresh_ledger_power_state()
	call_deferred("_maybe_start_token_return_monologue")


func _align_side_exits() -> void:
	# This optional archive is a destination room, not a connector hallway. Its
	# only route is the doorway centered in the north wall back to Snack Alcove.
	$ToSnackAlcove.position = NORTH_EXIT_ANCHOR
	$Spawn_FromSnackAlcove.position = NORTH_SPAWN_POSITION
	$Spawn_FromArcadeHub.position = NORTH_SPAWN_POSITION


func _apply_spawn_position() -> void:
	var back: Variant = GameState.consume_return_point(scene_file_path)
	if back != null:
		player.global_position = back
		return
	super._apply_spawn_position()


func handle_hub_interaction(interactable: Node, _player_node: Node = null) -> void:
	match str(interactable.interactable_kind):
		"night_ledger":
			_handle_night_ledger()
		"archive_bills":
			start_dialogue(_get_archive_prop_lines("archive_bills"))
		"archive_tv":
			start_dialogue(_get_archive_prop_lines("archive_tv"))
		_:
			start_dialogue([{"speaker": "System", "text": "Nothing happens."}])


func _handle_night_ledger() -> void:
	if GameState.post_reveal_roam_unlocked or GameState.twist_reveal_seen:
		start_dialogue(_get_ledger_lines("post_reveal_reboot", []))
		return
	if not GameState.circuit_soda_completed:
		start_dialogue(_get_ledger_lines("pre_circuit_soda", []))
		return
	if GameState.night_ledger_completed:
		if not GameState.night_ledger_debrief_seen:
			_show_duplex_token_debrief()
			return
		start_dialogue(_get_ledger_lines("offline_until_postgame", []))
		return
	if not GameState.night_ledger_started:
		GameState.night_ledger_started = true
		start_dialogue(_get_ledger_lines("quest_intro", []))
		return
	start_dialogue(_get_ledger_lines("quest_hint", []), Callable(self, "_go_to_night_ledger"))


func _go_to_night_ledger() -> void:
	GameState.set_pending_spawn_id("Spawn_FromNightLedger")
	SceneChanger.go_to_night_ledger()


func _maybe_start_token_return_monologue() -> void:
	if not GameState.night_ledger_token_collected or GameState.night_ledger_debrief_seen:
		return
	if GameState.get_npc_dialogue_count("night_ledger_token_return_monologue") > 0:
		return
	if _dialogue_is_active():
		return
	GameState.increment_npc_dialogue_count("night_ledger_token_return_monologue")
	start_dialogue(_get_ledger_lines("token_return_player", []))


func _show_duplex_token_debrief() -> void:
	GameState.night_ledger_debrief_seen = true
	start_dialogue(_get_ledger_lines("token_debrief", []), Callable(self, "_after_ledger_shutdown"))


func _after_ledger_shutdown() -> void:
	_refresh_ledger_power_state()
	_refresh_route_cue()


func _refresh_ledger_power_state() -> void:
	if night_ledger_cabinet == null:
		return
	var postgame := GameState.post_reveal_roam_unlocked or GameState.twist_reveal_seen
	var offline := GameState.night_ledger_debrief_seen and not postgame
	var visual_root := night_ledger_cabinet.get_node_or_null("VisualRoot") as CanvasItem
	if visual_root != null:
		visual_root.modulate = Color(0.28, 0.32, 0.38, 0.46) if offline else Color.WHITE
	var label := night_ledger_cabinet.get_node_or_null("Label") as CanvasItem
	if label != null:
		label.modulate.a = 0.36 if offline else 0.72


func _get_archive_prop_lines(base_key: String) -> Array:
	var key := base_key
	if GameState.post_reveal_roam_unlocked or GameState.twist_reveal_seen:
		key += "_post_reveal"
	return _get_ledger_lines(key, [])


func _get_ledger_lines(key: String, fallback: Array) -> Array:
	return DIALOGUE_POOL.get_lines("night_ledger", key, fallback)
