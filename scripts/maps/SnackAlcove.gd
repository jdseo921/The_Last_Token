extends Node2D

const ROUTE_CUE_SCRIPT := preload("res://scripts/RouteCue.gd")
const AMBIENT_EFFECTS := preload("res://scripts/AmbientSpriteEffects.gd")
const BACKGROUND_ART_PATH := "res://assets/art/maps/snack_alcove/snack_alcove_background_640x440.png"
const DIALOGUE_POOL := preload("res://scripts/DialoguePool.gd")

@onready var player: CharacterBody2D = $Player
@onready var background_art: Sprite2D = $BackgroundArt
@onready var ui_layer: Node2D = $UILayer
@onready var dialogue_box: CanvasLayer = $UILayer/DialogueBox
@onready var prompt_label: Label = $UILayer/InteractionPrompt
@onready var prompt_background: ColorRect = $UILayer/InteractionPromptBackground
@onready var circuit_soda_glow: Polygon2D = $CircuitSodaGlow
@onready var quest_notice: CanvasLayer = $QuestNotice

var pending_after_dialogue: Callable = Callable()
var route_cue: Control = null

func _ready() -> void:
	AudioManager.play_music_for_context("snack_alcove")
	player.interaction_prompt_changed.connect(_on_prompt_changed)
	dialogue_box.dialogue_finished.connect(_on_dialogue_finished)
	_apply_background_art()
	_setup_ambient_sprite_effects()
	_setup_route_cue()
	_apply_spawn_position()
	_on_prompt_changed("")
	_refresh_circuit_soda_state()
	call_deferred("_maybe_play_circuit_replay_return")

func can_open_pause_menu() -> bool:
	return not _dialogue_is_active() and not ConscienceEncounterDirector.is_encounter_active()

func _maybe_play_circuit_replay_return() -> void:
	if _dialogue_is_active() or ConscienceEncounterDirector.is_encounter_active():
		return
	if GameState.consume_postgame_replay_return("circuit_soda"):
		start_dialogue(_get_vendo_lines("circuit_soda_replay_return", [
			{"speaker": "Vendo", "text": "Route stable. No identity was spilled today."},
			{"speaker": "Vendo", "text": "This machine counts that as a five-star review."},
		]))

func _queue_post_circuit_conscience() -> void:
	call_deferred("_start_post_circuit_conscience")

func _start_post_circuit_conscience() -> void:
	ConscienceEncounterDirector.maybe_start_encounter(self, "after_circuit_soda")

func _complete_vendo_unknown_clue() -> void:
	GameState.vendo_unknown_clue_seen = true

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
	route_cue.call("setup", "snack_alcove", Vector2(24, 86), 390.0)

func _refresh_route_cue() -> void:
	if route_cue != null and is_instance_valid(route_cue) and route_cue.has_method("refresh"):
		route_cue.call("refresh")

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
	_refresh_route_cue()

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
	if not GameState.mr_byte_truth_filter_debriefed and not GameState.circuit_soda_completed:
		start_dialogue([
			{"speaker": "Vendo", "text": "One moment. The row next door says your Truth Filter report is still open."},
			{"speaker": "Vendo", "text": "Mr. Byte flags my power draw when paperwork goes missing. Go get debriefed."},
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
		GameState.increment_npc_dialogue_count("vendo_circuit_explained")
		start_dialogue(_get_vendo_lines("circuit_soda_intro", [
			{"speaker": "Vendo", "text": "Scanner mood: fractured."},
			{"speaker": "Player", "text": "(A vending machine missed me. Nothing makes sense anymore, but apparently my signal needs a soda.)"},
			{"speaker": "Vendo", "text": "Your signal is going everywhere except where it should."},
			{"speaker": "Vendo", "text": "Luckily, I am a licensed beverage-adjacent routing system."},
		]))
		return
	if not GameState.vendo_circuit_anecdote_seen:
		GameState.vendo_circuit_anecdote_seen = true
		start_dialogue(_get_vendo_lines("circuit_soda_completion_anecdote", [
			{"speaker": "Vendo", "text": "Signal routed. Receipt says: identity recognized, label unavailable."},
			{"speaker": "Player", "text": "It recognized me without knowing what I am."},
			{"speaker": "Vendo", "text": "One route moved toward the bright display. Another kept checking the cutoff valve."},
			{"speaker": "Player", "text": "So the machine fixed a route, not me."},
		]), Callable(self, "_queue_post_circuit_conscience"))
		return
	if not GameState.conscience_encounter_2_seen:
		start_dialogue([
			{"speaker": "Player", "text": "That static is still hanging in the air."},
		], Callable(self, "_queue_post_circuit_conscience"))
		return
	if not GameState.vendo_unknown_clue_seen:
		start_dialogue(_get_vendo_lines("unknown_voice_clue", [
			{"speaker": "Player", "text": "Something spoke through the static after Circuit Soda. Any idea what it was?"},
			{"speaker": "Vendo", "text": "Diagnostic result: speaker unknown. Customer service equally unknown."},
			{"speaker": "Vendo", "text": "It sounded like a warning that forgot to introduce itself."},
			{"speaker": "Player", "text": "So it may be protecting me. Or hiding something."},
			{"speaker": "Vendo", "text": "Correct. Extremely unhelpful."},
			{"speaker": "Vendo", "text": "Prize Service Hall is the passage on the right, between Circuit Soda and me."},
			{"speaker": "Vendo", "text": "Ask Pip about the loose labels. Shelves overhear what machines miss."},
			{"speaker": "Player", "text": "(Mystery voice, talking vending machine, suspicious plush. Finally, a normal errand.)"},
		]), Callable(self, "_complete_vendo_unknown_clue"))
		return
	start_dialogue(_get_vendo_lines("overloaded_phase", [
		{"speaker": "Vendo", "text": "Signal routed."},
		{"speaker": "Vendo", "text": "Paperwork remains tragically next."},
	]))

func _handle_circuit_soda() -> void:
	if GameState.lying_cabinets_completed and not GameState.mr_byte_truth_filter_debriefed and not GameState.circuit_soda_completed:
		start_dialogue([
			{"speaker": "Player", "text": "Mr. Byte wanted the Filter report first."},
			{"speaker": "Player", "text": "Loose ends hum in this place. I should not leave one behind me."},
		])
		return
	if not GameState.lying_cabinets_completed:
		start_dialogue(_get_environment_lines("circuit_soda_machine_locked", [
			{"speaker": "Circuit Soda", "text": "SNACK ALCOVE LOCKED."},
			{"speaker": "Circuit Soda", "text": "TRUTH FILTER REQUIRED."},
		]))
		return
	if GameState.post_reveal_roam_unlocked and GameState.circuit_soda_completed:
		start_dialogue(_get_vendo_lines("circuit_soda_replay_offer", [
			{"speaker": "Vendo", "text": "Circuit Soda: post-crisis edition. Zero stakes."},
			{"speaker": "Vendo", "text": "One replay, on the house."},
		]), Callable(self, "_offer_circuit_soda_replay"))
		return
	if GameState.circuit_soda_completed:
		start_dialogue(_get_environment_lines("circuit_soda_machine_restored", [
			{"speaker": "Circuit Soda", "text": "MEMORY FLOW RESTORED."},
			{"speaker": "Circuit Soda", "text": "FRACTURED SIGNAL STABILIZED."},
		]))
		return
	if GameState.get_npc_dialogue_count("vendo_circuit_explained") == 0:
		start_dialogue([
			{"speaker": "Player", "text": "This machine has too many hoses to guess at."},
			{"speaker": "Player", "text": "The vending machine nearby looks unusually talkative. I should ask before touching this."},
		])
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
	if GameState.lost_shift_file_started and not GameState.lost_shift_file_completed:
		if not GameState.closing_shift_mira_clue_found:
			start_dialogue([
				{"speaker": "Player", "text": "This route feels familiar, but Gus said to ask Mira first."},
			])
			return
		if not GameState.closing_shift_score_clue_found:
			start_dialogue([
				{"speaker": "Player", "text": "The route is missing its start time. Broken Score should have it."},
			])
			return
		if not GameState.closing_shift_service_clue_found:
			GameState.find_closing_shift_service_clue()
			start_dialogue([
				{"speaker": "Service Dash", "text": "LAST SERVICE CUTOFF: 00:18"},
				{"speaker": "Player", "text": "Broken Score logged 00:17, and this cutoff followed one minute later."},
				{"speaker": "Player", "text": "I found the route without remembering it. Gus may understand what that means."},
			])
			return
		start_dialogue([
			{"speaker": "Player", "text": "00:17 at Broken Score. 00:18 here. I should take the sequence back to Gus."},
		])
		return
	var lines := [
		{"speaker": "Service Slot", "text": "The service slot is jammed with old labels."},
	]
	if GameState.vendo_intro_seen:
		lines.append({"speaker": "Service Slot", "text": "Vendo insists this is a feature. Refunds remain impossible."})
	else:
		lines.append({"speaker": "Service Slot", "text": "A faded sticker calls this a feature. It also rejects refunds."})
	start_dialogue(lines)

func _go_to_snack_service_dash() -> void:
	GameState.set_pending_spawn_id("Spawn_FromSnackAdventure")
	SceneChanger.go_to_snack_service_dash()

func _apply_background_art() -> void:
	var loaded := _apply_sprite_texture(background_art, BACKGROUND_ART_PATH)
	for placeholder in [$Background, $SnackWall, $ServiceSlotPlaceholder, $VendoPlaceholder, $CircuitSodaPlaceholder]:
		if placeholder is CanvasItem:
			placeholder.visible = not loaded

func _setup_ambient_sprite_effects() -> void:
	AMBIENT_EFFECTS.create_layer(self, ui_layer, [
		{
			"name": "VendoBubbleSpriteA",
			"position": Vector2(318, 128),
			"scale": Vector2(1.55, 1.55),
			"effect_type": "bob",
			"speed": 0.58,
			"intensity": 0.18,
			"sprite_sheet_path": AMBIENT_EFFECTS.SODA_BUBBLE,
			"sprite_alpha": 0.78,
		},
		{
			"name": "VendoBubbleSpriteB",
			"position": Vector2(342, 150),
			"scale": Vector2(1.1, 1.1),
			"effect_type": "bob",
			"speed": 0.74,
			"intensity": 0.14,
			"sprite_sheet_path": AMBIENT_EFFECTS.SODA_BUBBLE,
			"sprite_alpha": 0.62,
		},
		{
			"name": "CircuitSodaScanline",
			"position": Vector2(452, 134),
			"scale": Vector2(1.8, 1.8),
			"effect_type": "scanline_pulse",
			"speed": 0.76,
			"sprite_sheet_path": AMBIENT_EFFECTS.SCANLINE_BAR,
			"sprite_frame_size": Vector2i(32, 8),
			"sprite_alpha": 0.74,
			"sprite_modulate": Color(0.72, 1.0, 0.86, 1.0),
		},
		{
			"name": "ServiceSlotSpark",
			"position": Vector2(198, 140),
			"scale": Vector2(1.35, 1.35),
			"effect_type": "random_screen_flash",
			"speed": 0.82,
			"intensity": 0.08,
			"sprite_sheet_path": AMBIENT_EFFECTS.STATIC_SPARK,
			"sprite_alpha": 0.68,
		},
	])

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

func _offer_circuit_soda_replay() -> void:
	PostGameReplay.open_offer(ui_layer, player, "Route the circuit again?", "circuit_soda", Callable(self, "_go_to_circuit_soda"))
