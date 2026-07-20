extends Node2D

const ROUTE_CUE_SCRIPT := preload("res://scripts/RouteCue.gd")
const AMBIENT_EFFECTS := preload("res://scripts/AmbientSpriteEffects.gd")
const BACKGROUND_ART_PATH := "res://assets/art/maps/cabinet_row/cabinet_row_background_640x440.png"
const DIALOGUE_POOL := preload("res://scripts/DialoguePool.gd")

@onready var player: CharacterBody2D = $Player
@onready var background_art: Sprite2D = $BackgroundArt
@onready var ui_layer: Node2D = $UILayer
@onready var dialogue_box: CanvasLayer = $UILayer/DialogueBox
@onready var prompt_label: Label = $UILayer/InteractionPrompt
@onready var prompt_background: ColorRect = $UILayer/InteractionPromptBackground
@onready var truth_filter_glow: Polygon2D = $TruthFilterGlow
@onready var quest_notice: CanvasLayer = $QuestNotice

var pending_after_dialogue: Callable = Callable()
var route_cue: Control = null

func _ready() -> void:
	AudioManager.play_music_for_context("cabinet_row")
	player.interaction_prompt_changed.connect(_on_prompt_changed)
	dialogue_box.dialogue_finished.connect(_on_dialogue_finished)
	_apply_background_art()
	_setup_ambient_sprite_effects()
	_setup_route_cue()
	_apply_spawn_position()
	_on_prompt_changed("")
	_refresh_truth_filter_state()
	call_deferred("_maybe_start_conscience_encounter")

func can_open_pause_menu() -> bool:
	return not _dialogue_is_active() and not ConscienceEncounterDirector.is_encounter_active()

func _maybe_start_conscience_encounter() -> void:
	# The ??? encounter no longer ambushes the doorway: it lands inside the
	# Mr. Byte debrief, right before the protagonist decides to ask about it.
	_maybe_play_completion_anecdote()

func _maybe_play_completion_anecdote() -> void:
	if _dialogue_is_active() or ConscienceEncounterDirector.is_encounter_active():
		return
	if GameState.consume_postgame_replay_return("truth_filter"):
		start_dialogue(_get_environment_lines("truth_filter_machine_replay_return", [
			{"speaker": "Truth Filter", "text": "SORT COMPLETE. LIE DENSITY: ZERO."},
			{"speaker": "Truth Filter", "text": "THEY ARGUE ANYWAY. IT KEEPS THEM WARM."},
		]))
		return
	if GameState.consume_postgame_replay_return("broken_high_score"):
		start_dialogue(_get_roxy_lines("broken_high_score_replay_return", [
			{"speaker": "Roxy", "text": "Zero stakes and you still played like rent was due."},
			{"speaker": "Roxy", "text": "That is exactly why it looks good on you."},
		]))
		return
	if GameState.lying_cabinets_completed and not GameState.roxy_truth_filter_nudge_seen:
		GameState.roxy_truth_filter_nudge_seen = true
		start_dialogue(_get_roxy_lines("truth_filter_completion_nudge", [
			{"speaker": "Roxy", "text": "Huh. The Filter actually shut up for once."},
			{"speaker": "Roxy", "text": "Whatever it just coughed up, Mr. Byte is the one who files it."},
			{"speaker": "Roxy", "text": "Go make him explain it. He lives for that."},
		]))
		return
	if GameState.broken_high_score_completed and not GameState.roxy_high_score_anecdote_seen:
		GameState.roxy_high_score_anecdote_seen = true
		start_dialogue(_get_roxy_lines("broken_high_score_completion", [
			{"speaker": "Roxy", "text": "Huh. Your score came back."},
			{"speaker": "Roxy", "text": "The points restored clean. The name stayed blank."},
		]))

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
	route_cue.call("setup", "cabinet_row", Vector2(24, 86), 390.0)

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
	_refresh_truth_filter_state()
	_refresh_route_cue()

func _dialogue_is_active() -> bool:
	if dialogue_box == null:
		return false
	return dialogue_box.get("active") == true

func _get_mr_byte_lines(key: String, fallback: Array) -> Array:
	return DIALOGUE_POOL.get_lines("mr_byte", key, fallback)

func _get_mr_byte_sequential_lines(key: String, fallback: Array) -> Array:
	return DIALOGUE_POOL.get_sequential_set("mr_byte", key, key, fallback)

func _get_roxy_lines(key: String, fallback: Array) -> Array:
	return DIALOGUE_POOL.get_lines("roxy", key, fallback)

func _get_roxy_sequential_lines(key: String, fallback: Array) -> Array:
	return DIALOGUE_POOL.get_sequential_set("roxy", key, key, fallback)

func _get_environment_lines(key: String, fallback: Array) -> Array:
	return DIALOGUE_POOL.get_lines("environment_objects", key, fallback)

func _get_environment_state_lines(object_key: String, fallback: Array) -> Array:
	var state_key := "%s_%s" % [object_key, _get_environment_state_key()]
	var lines := _get_environment_lines(state_key, [])
	if not lines.is_empty():
		return lines
	lines = _get_environment_lines("%s_grounded" % object_key, fallback)
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
		"mr_byte":
			_handle_mr_byte()
		"truth_filter":
			_handle_truth_filter()
		"roxy":
			_handle_roxy()
		"broken_high_score":
			_handle_broken_high_score()
		"truth_filter_logs":
			_handle_truth_filter_logs()
		_:
			start_dialogue([{"speaker": "System", "text": "Nothing happens."}])

func _handle_mr_byte() -> void:
	GameState.mr_byte_intro_seen = true
	if _is_post_reveal():
		GameState.mr_byte_post_reveal_seen = true
		GameState.employee_04_file_found = true
		var was_completed := _was_witness_route_completed()
		GameState.mark_witness_mr_byte_heard()
		start_dialogue(_get_mr_byte_lines("post_reveal_witness", [
			{"speaker": "Mr. Byte", "text": "Employee 04."},
			{"speaker": "Mr. Byte", "text": "Identity conflict resolved."},
			{"speaker": "Mr. Byte", "text": "Emotional cache remains unstable."},
		]), _get_witness_completion_callback(was_completed))
		return
	if not GameState.lost_token_quest_completed:
		start_dialogue(_get_mr_byte_sequential_lines("pre_truth_filter_locked", [
			{"speaker": "Mr. Byte", "text": "TRUTH FILTER LOCKED."},
			{"speaker": "Mr. Byte", "text": "SIGNAL TOO QUIET."},
		]))
		return
	if not GameState.broken_high_score_completed and not GameState.lying_cabinets_completed:
		start_dialogue(_get_mr_byte_lines("pre_roxy_redirect", [
			{"speaker": "Mr. Byte", "text": "Sequencing error detected."},
			{"speaker": "Mr. Byte", "text": "The score cabinet is broadcasting a louder falsehood than my queue."},
			{"speaker": "Mr. Byte", "text": "Resolve Roxy's board first. Then report back for Truth Filter orientation."},
		]))
		return
	if not GameState.lying_cabinets_completed:
		GameState.truth_filter_quest_started = true
		GameState.increment_npc_dialogue_count("mr_byte_tf_explained")
		GameState.update_memory_signal_from_progress()
		start_dialogue(_get_mr_byte_sequential_lines("truth_filter_intro", [
			{"speaker": "Mr. Byte", "text": "Contradiction threshold reached."},
			{"speaker": "Mr. Byte", "text": "Truth Filter is ready."},
			{"speaker": "Mr. Byte", "text": "Please choose the least broken answer."},
		]))
		return
	if not GameState.mr_byte_truth_filter_anecdote_seen:
		GameState.mr_byte_truth_filter_anecdote_seen = true
		GameState.mr_byte_truth_filter_debriefed = true
		var debrief_lines := _get_mr_byte_lines("truth_filter_completion_anecdote", [
			{"speaker": "Mr. Byte", "text": "Truth Filter passed."},
			{"speaker": "Mr. Byte", "text": "The records identify operator STAFF 04. The owner name is missing."},
		])
		debrief_lines.append_array(_get_mr_byte_lines("truth_filter_voice_debrief", [
			{"speaker": "Mr. Byte", "text": "The hallway broadcast had no registered speaker."},
			{"speaker": "Mr. Byte", "text": "Ask Gus whether he heard it."},
		]))
		start_dialogue(debrief_lines, Callable(self, "_after_byte_debrief"))
		return
	if GameState.lost_shift_file_started and not GameState.lost_shift_file_completed and not GameState.story_puzzle_completed:
		start_dialogue(_get_mr_byte_sequential_lines("closing_shift_echoes_support", [
			{"speaker": "Mr. Byte", "text": "Closing-shift evidence route detected."},
			{"speaker": "Mr. Byte", "text": "Gus is sorting the files. Begin with Mira; recovered connections may supply the rest."},
			{"speaker": "Mr. Byte", "text": "The Logs beside this kiosk remain available for Truth Filter reference."},
		]))
		return
	if GameState.lost_shift_file_completed and not GameState.maintenance_sync_completed and not GameState.story_puzzle_completed:
		start_dialogue(_get_mr_byte_lines("closing_shift_echoes_complete_support", [
			{"speaker": "Mr. Byte", "text": "Closing-shift sequence reconstructed."},
			{"speaker": "Mr. Byte", "text": "Service-line continuation authorized."},
		]))
		return
	if GameState.maintenance_sync_completed and not GameState.security_tape_assembly_completed and not GameState.story_puzzle_completed:
		start_dialogue(_get_mr_byte_sequential_lines("security_tape_support", [
			{"speaker": "Mr. Byte", "text": "Security tape fragments detected."},
			{"speaker": "Mr. Byte", "text": "Recommended action: Security Tape Assembly."},
		]))
		return
	start_dialogue(_get_mr_byte_lines("truth_filter_completion_anecdote", [
		{"speaker": "Mr. Byte", "text": "Truth Filter passed."},
		{"speaker": "Mr. Byte", "text": "Identity conflict remains."},
	]))

func _handle_truth_filter() -> void:
	if not GameState.lost_token_quest_completed:
		start_dialogue(_get_environment_lines("truth_filter_machine_grounded", [
			{"speaker": "Truth Filter", "text": "SIGNAL TOO QUIET."},
			{"speaker": "Truth Filter", "text": "MR. BYTE AUTHORIZATION REQUIRED."},
		]))
		return
	if GameState.post_reveal_roam_unlocked and GameState.lying_cabinets_completed:
		start_dialogue(_get_environment_lines("truth_filter_machine_replay_offer", [
			{"speaker": "Truth Filter", "text": "TRUTH FILTER ONLINE. NO CONTRADICTIONS PENDING."},
			{"speaker": "Truth Filter", "text": "RECREATIONAL SORTING AVAILABLE."},
		]), Callable(self, "_offer_truth_filter_replay"))
		return
	if GameState.lying_cabinets_completed:
		start_dialogue(_get_environment_state_lines("truth_filter_machine", [
			{"speaker": "Truth Filter", "text": "TRUTH FILTER PASSED."},
			{"speaker": "Truth Filter", "text": "RECORDS RECONCILED."},
		]))
		return
	if GameState.get_npc_dialogue_count("mr_byte_tf_explained") == 0:
		start_dialogue([
			{"speaker": "Player", "text": "The Truth Filter hums like it is waiting for a proctor."},
			{"speaker": "Player", "text": "Mr. Byte runs this row. He should walk me in."},
		])
		return
	GameState.update_memory_signal_from_progress()
	GameState.set_pending_spawn_id("Spawn_FromTruthFilter")
	start_dialogue(_get_environment_lines("truth_filter_machine_uneasy", [
		{"speaker": "Truth Filter", "text": "CONTRADICTION THRESHOLD REACHED."},
		{"speaker": "Truth Filter", "text": "SORT FALSE RECORDS."},
	]), Callable(SceneChanger, "go_to_truth_filter"))

func _handle_roxy() -> void:
	var was_roxy_met := GameState.roxy_met
	GameState.roxy_met = true
	if _is_post_reveal():
		var was_completed := _was_witness_route_completed()
		GameState.mark_witness_roxy_heard()
		start_dialogue(_get_roxy_lines("post_reveal", [
			{"speaker": "Roxy", "text": "So you were Employee 04."},
			{"speaker": "Roxy", "text": "That explains the blank high score."},
			{"speaker": "Roxy", "text": "Hard to rank a whole person."},
		]), _get_witness_completion_callback(was_completed))
		return
	if not _broken_high_score_unlocked():
		start_dialogue(_get_roxy_lines("first_meeting_locked", [
			{"speaker": "Roxy", "text": "Whoa. You look exactly like the person in half the staff photos."},
			{"speaker": "Roxy", "text": "Except you are looking at this room like you have never seen it."},
			{"speaker": "Roxy", "text": "Come back when the score cabinet wakes up."},
		]))
		return
	if GameState.broken_high_score_completed:
		if not GameState.roxy_high_score_anecdote_seen:
			GameState.roxy_high_score_anecdote_seen = true
			start_dialogue(_get_roxy_lines("broken_high_score_completion", [
				{"speaker": "Roxy", "text": "Huh. Your score came back."},
				{"speaker": "Roxy", "text": "That usually does not happen after a reset."},
				{"speaker": "Roxy", "text": "Do not let it go to your head. You still walk like a tutorial."},
			]))
			return
		start_dialogue(_get_roxy_sequential_lines("repeat_after_completion", [
			{"speaker": "Roxy", "text": "Your score came back."},
			{"speaker": "Roxy", "text": "Still weird."},
		]))
		return
	if not was_roxy_met or GameState.get_npc_dialogue_count("roxy:broken_high_score_intro") == 0:
		GameState.increment_npc_dialogue_count("roxy:broken_high_score_intro")
		start_dialogue(_get_roxy_lines("broken_high_score_intro", [
			{"speaker": "Roxy", "text": "Finally. Player Two showed up."},
			{"speaker": "Roxy", "text": "You look like someone who loses to menus."},
			{"speaker": "Roxy", "text": "Try the Broken High Score cabinet."},
			{"speaker": "Roxy", "text": "The screen lies, but badly."},
		]), Callable(self, "_announce_optional_quest").bind("broken_high_score"))
		return
	start_dialogue(_get_roxy_sequential_lines("broken_high_score_hint", [
		{"speaker": "Roxy", "text": "Finally. Player Two showed up."},
		{"speaker": "Roxy", "text": "Try the Broken High Score cabinet."},
		{"speaker": "Roxy", "text": "The screen lies, but badly."},
	]))

func _announce_optional_quest(_quest_id: String) -> void:
	# Retired: the persistent top-right HUD announces quest changes now.
	pass

func _handle_broken_high_score() -> void:
	if not _broken_high_score_unlocked():
		start_dialogue(_get_roxy_lines("first_meeting_locked", [
			{"speaker": "Roxy", "text": "The score cabinet is not ready yet."},
			{"speaker": "Roxy", "text": "Come back after you beat something louder."},
		]))
		return
	if GameState.post_reveal_roam_unlocked and GameState.broken_high_score_completed:
		start_dialogue(_get_roxy_lines("broken_high_score_replay_offer", [
			{"speaker": "Roxy", "text": "Back at my cabinet, 04?"},
			{"speaker": "Roxy", "text": "Coin up or step aside."},
		]), Callable(self, "_offer_high_score_replay"))
		return
	if GameState.broken_high_score_completed:
		if GameState.lost_shift_file_started and not GameState.lost_shift_file_completed:
			if not GameState.closing_shift_mira_clue_found:
				start_dialogue([
					{"speaker": "Player", "text": "The restored digits feel familiar, but I need to ask Mira about the closing shift first."},
				])
				return
			if not GameState.closing_shift_score_clue_found:
				GameState.find_closing_shift_score_clue()
				start_dialogue(_get_environment_lines("broken_score_closing_shift_clue", [
					{"speaker": "Broken Score", "text": "RESTORED ENTRY: 00:17 / FINAL INPUT"},
					{"speaker": "Player", "text": "That is not a score. It is a time."},
					{"speaker": "Player", "text": "And I somehow know the next check was Service Dash in Snack Alcove."},
				]))
				return
			if not GameState.closing_shift_service_clue_found:
				start_dialogue([
					{"speaker": "Player", "text": "00:17. The next check was Service Dash in Snack Alcove."},
				])
				return
		start_dialogue([
			{"speaker": "Broken High Score", "text": "PREVIOUS SCORE FOUND."},
			{"speaker": "Broken High Score", "text": "RECORD RESTORED."},
		])
		return
	if not GameState.roxy_met:
		start_dialogue([
			{"speaker": "Player", "text": "The woman beside that score cabinet keeps watching it."},
			{"speaker": "Player", "text": "I should ask her before touching anything."},
		])
		return
	GameState.set_pending_spawn_id("Spawn_FromBrokenHighScore")
	SceneChanger.go_to_broken_high_score()

func _handle_truth_filter_logs() -> void:
	if not GameState.broken_high_score_completed:
		start_dialogue(_get_environment_lines("staff_records_locked", [
			{"speaker": "Player", "text": "The stacked logs are too scrambled to follow. Restoring Broken Score may give them an order."},
		]))
		return
	if not GameState.lying_cabinets_completed:
		# The retired Record 01 clue now lives in a visible stack of Logs. It is
		# deliberately a readable hint rather than another quest collectible.
		GameState.read_staff_record_01()
		start_dialogue(_get_environment_lines("staff_record_01_shift_log", [
			{"speaker": "Logs", "text": "FINAL SHIFT EXCERPT"},
			{"speaker": "Logs", "text": "23:41 - Mira signed out last on the register."},
			{"speaker": "Logs", "text": "23:50 - Gus clocked out after mopping."},
			{"speaker": "Logs", "text": "00:05 - One worker remained. No sign-out followed."},
			{"speaker": "Player", "text": "Three clean facts. The Truth Filter probably wants the record that fits all of them."},
		]))
		return
	var was_completed := GameState.staff_records_chain_completed
	GameState.read_staff_record_01()
	var lines := _get_environment_state_lines("staff_records", [
		{"speaker": "Logs", "text": "RESTORE SYSTEM NOTE"},
		{"speaker": "Logs", "text": "Subject memory incomplete."},
		{"speaker": "Logs", "text": "Do not repeat name until signal stabilizes."},
	])
	lines.append_array(_get_mr_byte_lines("staff_records_chain", [
		{"speaker": "Mr. Byte", "text": "Staff record chain active."},
		{"speaker": "Mr. Byte", "text": "Names withheld until signal stabilizes."},
		{"speaker": "Mr. Byte", "text": "Additional staff records required."},
	]))
	lines.append_array(_get_staff_records_completion_lines())
	var after_dialogue := Callable(self, "_show_staff_records_complete_notice") if not was_completed and GameState.staff_records_chain_completed else Callable()
	start_dialogue(lines, after_dialogue)

func _get_staff_records_completion_lines() -> Array:
	if not GameState.staff_records_chain_completed:
		return []
	return [
		{"speaker": "Quest", "text": "STAFF RECORDS CHAIN COMPLETE"},
		{"speaker": "Quest", "text": "The arcade knew the number before it knew the name."},
	]

func _show_staff_records_complete_notice() -> void:
	if quest_notice and quest_notice.has_method("show_custom_notification"):
		quest_notice.call(
			"show_custom_notification",
			"QUEST COMPLETE",
			"STAFF RECORDS CHAIN COMPLETE",
			"The arcade knew the number before it knew the name."
		)

func _was_witness_route_completed() -> bool:
	return GameState.witness_route_completed or GameState.post_reveal_witness_route_completed

func _get_witness_completion_callback(was_completed: bool) -> Callable:
	if not was_completed and _was_witness_route_completed():
		return Callable(self, "_show_witness_route_complete_notice")
	return Callable()

func _broken_high_score_unlocked() -> bool:
	return GameState.rockbyte_duel_completed or GameState.broken_high_score_completed or _is_post_reveal()

func _show_witness_route_complete_notice() -> void:
	if quest_notice and quest_notice.has_method("show_custom_notification"):
		quest_notice.call(
			"show_custom_notification",
			"QUEST COMPLETE",
			"POST-REVEAL WITNESSES COMPLETE",
			"Pixel Haven remembers you in pieces.\nTogether, they almost make a person."
		)

func _is_post_reveal() -> bool:
	return GameState.post_reveal_roam_unlocked or GameState.twist_reveal_seen

func _apply_background_art() -> void:
	var loaded := _apply_sprite_texture(background_art, BACKGROUND_ART_PATH)
	for placeholder in [$Background, $CabinetWall, $TruthFilterPlaceholder, $MrBytePlaceholder, $DecorativeCabinetPlaceholder, $RoxyPlaceholder, $BrokenHighScorePlaceholder]:
		if placeholder is CanvasItem:
			placeholder.visible = not loaded

func _setup_ambient_sprite_effects() -> void:
	AMBIENT_EFFECTS.create_layer(self, ui_layer, [
		{
			"name": "MrByteScanlineSprite",
			"position": Vector2(150, 138),
			"scale": Vector2(1.65, 1.65),
			"effect_type": "scanline_pulse",
			"speed": 0.72,
			"sprite_sheet_path": AMBIENT_EFFECTS.SCANLINE_BAR,
			"sprite_frame_size": Vector2i(32, 8),
			"sprite_alpha": 0.7,
		},
		{
			"name": "TruthFilterMemoryWisp",
			"position": Vector2(320, 128),
			"scale": Vector2(1.6, 1.6),
			"effect_type": "dust_mote_drift",
			"speed": 0.45,
			"intensity": 0.22,
			"only_when_memory_signal_at_least": 1,
			"active_flag_optional": "lost_token_quest_completed",
			"sprite_sheet_path": AMBIENT_EFFECTS.MEMORY_WISP,
			"sprite_frame_size": Vector2i(24, 16),
			"sprite_alpha": 0.78,
		},
		{
			"name": "BrokenScoreStatic",
			"position": Vector2(500, 126),
			"scale": Vector2(1.45, 1.45),
			"effect_type": "jitter",
			"speed": 0.9,
			"intensity": 0.09,
			"sprite_sheet_path": AMBIENT_EFFECTS.STATIC_SPARK,
			"sprite_alpha": 0.68,
		},
		{
			"name": "ScheduleBlink",
			"position": Vector2(214, 138),
			"scale": Vector2(1.1, 1.1),
			"effect_type": "blink",
			"speed": 0.58,
			"intensity": 0.05,
			"sprite_sheet_path": AMBIENT_EFFECTS.BLINK_DOT,
			"sprite_alpha": 0.62,
			"sprite_modulate": Color(1.0, 0.88, 0.45, 1.0),
		},
	])

func _refresh_truth_filter_state() -> void:
	if truth_filter_glow == null:
		return
	truth_filter_glow.visible = GameState.lost_token_quest_completed and not GameState.lying_cabinets_completed

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

func _offer_truth_filter_replay() -> void:
	PostGameReplay.open_offer(ui_layer, player, "Run the Truth Filter again?", "truth_filter", Callable(self, "_launch_truth_filter_replay"))

func _launch_truth_filter_replay() -> void:
	GameState.set_pending_spawn_id("Spawn_FromTruthFilter")
	SceneChanger.go_to_truth_filter()

func _offer_high_score_replay() -> void:
	PostGameReplay.open_offer(ui_layer, player, "Chase the high score again?", "broken_high_score", Callable(self, "_launch_high_score_replay"))

func _launch_high_score_replay() -> void:
	GameState.set_pending_spawn_id("Spawn_FromBrokenHighScore")
	SceneChanger.go_to_broken_high_score()

func _after_byte_debrief() -> void:
	# ??? answers Mr. Byte's "there is no form for this" - then the protagonist
	# reacts to having heard it.
	if not ConscienceEncounterDirector.maybe_start_encounter(self, "after_truth_filter", Callable(self, "_play_byte_debrief_monologue")):
		_play_byte_debrief_monologue()

func _play_byte_debrief_monologue() -> void:
	start_dialogue([
		{"speaker": "Player", "text": "That was not ambient noise. It spoke to me and knew my next move."},
		{"speaker": "Player", "text": "Mr. Byte could not trace it. The man in the hub looks like he has spent too many nights keeping this place alive."},
		{"speaker": "Player", "text": "He might know what that voice was. It is worth asking."},
	])
