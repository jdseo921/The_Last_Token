extends Node2D

const BACKGROUND_ART_PATH := "res://assets/art/maps/cabinet_row/cabinet_row_background_640x440.png"
const DIALOGUE_POOL := preload("res://scripts/DialoguePool.gd")

@onready var player: CharacterBody2D = $Player
@onready var background_art: Sprite2D = $BackgroundArt
@onready var dialogue_box: CanvasLayer = $UILayer/DialogueBox
@onready var prompt_label: Label = $UILayer/InteractionPrompt
@onready var prompt_background: ColorRect = $UILayer/InteractionPromptBackground
@onready var truth_filter_glow: Polygon2D = $TruthFilterGlow
@onready var quest_notice: CanvasLayer = $QuestNotice

var pending_after_dialogue: Callable = Callable()

func _ready() -> void:
	player.interaction_prompt_changed.connect(_on_prompt_changed)
	dialogue_box.dialogue_finished.connect(_on_dialogue_finished)
	_apply_background_art()
	_apply_spawn_position()
	_on_prompt_changed("")
	_refresh_truth_filter_state()
	call_deferred("_maybe_start_conscience_encounter")

func can_open_pause_menu() -> bool:
	return not _dialogue_is_active() and not ConscienceEncounterDirector.is_encounter_active()

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
	_refresh_truth_filter_state()

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
		"staff_schedule":
			_handle_staff_schedule()
		"staff_record_01":
			_handle_staff_record_01()
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
			{"speaker": "Mr. Byte", "text": "MEMORY SIGNAL TOO QUIET."},
		]))
		return
	if not GameState.lying_cabinets_completed:
		GameState.truth_filter_quest_started = true
		GameState.update_memory_signal_from_progress()
		start_dialogue(_get_mr_byte_sequential_lines("truth_filter_intro", [
			{"speaker": "Mr. Byte", "text": "Contradiction threshold reached."},
			{"speaker": "Mr. Byte", "text": "Truth Filter is ready."},
			{"speaker": "Mr. Byte", "text": "Please choose the least broken answer."},
		]))
		return
	if not GameState.mr_byte_truth_filter_anecdote_seen:
		GameState.mr_byte_truth_filter_anecdote_seen = true
		start_dialogue(_get_mr_byte_lines("truth_filter_completion_anecdote", [
			{"speaker": "Mr. Byte", "text": "Truth Filter passed."},
			{"speaker": "Mr. Byte", "text": "Contradictions remain."},
			{"speaker": "Mr. Byte", "text": "That means the memory is alive enough to argue."},
			{"speaker": "Mr. Byte", "text": "Record conflict reduced. Identity conflict remains."},
		]))
		return
	if GameState.circuit_soda_completed and not GameState.lost_shift_file_completed and not GameState.story_puzzle_completed:
		GameState.start_lost_shift_file()
		start_dialogue(_get_mr_byte_sequential_lines("lost_shift_file_support", [
			{"speaker": "Mr. Byte", "text": "Staff schedule access: damaged but readable."},
			{"speaker": "Mr. Byte", "text": "Machines refuse the name. Records retain the assignment."},
			{"speaker": "Mr. Byte", "text": "Read the schedule near this kiosk."},
		]))
		return
	if GameState.lost_shift_file_completed and not GameState.maintenance_sync_completed and not GameState.story_puzzle_completed:
		GameState.mr_byte_lost_shift_comment_seen = true
		start_dialogue(_get_mr_byte_lines("lost_shift_file_support", [
			{"speaker": "Mr. Byte", "text": "Lost Shift File reconstructed."},
			{"speaker": "Mr. Byte", "text": "Identity reference remains restricted."},
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
	if GameState.lying_cabinets_completed:
		start_dialogue(_get_environment_state_lines("truth_filter_machine", [
			{"speaker": "Truth Filter", "text": "TRUTH FILTER PASSED."},
			{"speaker": "Truth Filter", "text": "MEMORY SIGNAL: FRACTURED."},
		]))
		return
	GameState.truth_filter_quest_started = true
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
			{"speaker": "Roxy", "text": "Hard to rank a memory."},
		]), _get_witness_completion_callback(was_completed))
		return
	if not _broken_high_score_unlocked():
		start_dialogue(_get_roxy_lines("first_meeting_locked", [
			{"speaker": "Roxy", "text": "Whoa. New challenger detected."},
			{"speaker": "Roxy", "text": "Actually, no. New challenger pending."},
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
		]))
		return
	start_dialogue(_get_roxy_sequential_lines("broken_high_score_hint", [
		{"speaker": "Roxy", "text": "Finally. Player Two showed up."},
		{"speaker": "Roxy", "text": "Try the Broken High Score cabinet."},
		{"speaker": "Roxy", "text": "The screen lies, but badly."},
	]))

func _handle_broken_high_score() -> void:
	if not _broken_high_score_unlocked():
		start_dialogue(_get_roxy_lines("first_meeting_locked", [
			{"speaker": "Roxy", "text": "The score cabinet is not ready yet."},
			{"speaker": "Roxy", "text": "Come back after you beat something louder."},
		]))
		return
	if GameState.broken_high_score_completed:
		start_dialogue([
			{"speaker": "Broken High Score", "text": "PREVIOUS SCORE FOUND."},
			{"speaker": "Broken High Score", "text": "RECORD RESTORED."},
		])
		return
	GameState.roxy_met = true
	GameState.set_pending_spawn_id("Spawn_FromBrokenHighScore")
	SceneChanger.go_to_broken_high_score()

func _handle_staff_schedule() -> void:
	if not GameState.circuit_soda_completed:
		start_dialogue(_get_environment_lines("staff_schedule_grounded", [
			{"speaker": "Staff Schedule", "text": "The schedule screen is scrambled."},
			{"speaker": "Staff Schedule", "text": "Mr. Byte has not unlocked staff records yet."},
		]))
		return
	var was_completed := GameState.lost_shift_file_completed
	GameState.read_staff_schedule()
	var lines := _get_environment_state_lines("staff_schedule", [
		{"speaker": "Staff Schedule", "text": "STAFF SCHEDULE"},
		{"speaker": "Staff Schedule", "text": "Final Night"},
		{"speaker": "Staff Schedule", "text": "Mira - Counter"},
		{"speaker": "Staff Schedule", "text": "Gus - Maintenance"},
		{"speaker": "Staff Schedule", "text": "Employee ## - Cabinet shutdown"},
		{"speaker": "Staff Schedule", "text": "Status: unresolved"},
	])
	lines.append_array(_get_lost_shift_completion_lines())
	var after_dialogue := Callable(self, "_after_lost_shift_file_completed") if not was_completed and GameState.lost_shift_file_completed else Callable()
	start_dialogue(lines, after_dialogue)

func _handle_staff_record_01() -> void:
	if not GameState.lying_cabinets_completed:
		start_dialogue(_get_environment_lines("staff_records_locked", [
			{"speaker": "Staff Record", "text": "The record terminal is still filtering contradictions."},
		]))
		return
	var was_completed := GameState.staff_records_chain_completed
	GameState.read_staff_record_01()
	var lines := _get_environment_state_lines("staff_records", [
		{"speaker": "Staff Record", "text": "RESTORE SYSTEM NOTE"},
		{"speaker": "Staff Record", "text": "Subject memory incomplete."},
		{"speaker": "Staff Record", "text": "Do not repeat name until signal stabilizes."},
	])
	lines.append_array(_get_mr_byte_lines("staff_records_chain", [
		{"speaker": "Mr. Byte", "text": "Staff record chain active."},
		{"speaker": "Mr. Byte", "text": "Names withheld until signal stabilizes."},
		{"speaker": "Mr. Byte", "text": "Additional staff records required."},
	]))
	lines.append_array(_get_staff_records_completion_lines())
	var after_dialogue := Callable(self, "_show_staff_records_complete_notice") if not was_completed and GameState.staff_records_chain_completed else Callable()
	start_dialogue(lines, after_dialogue)

func _get_lost_shift_completion_lines() -> Array:
	if not GameState.lost_shift_file_completed:
		return []
	return [
		{"speaker": "Quest", "text": "LOST SHIFT FILE COMPLETE"},
		{"speaker": "Quest", "text": "A redacted staff number was assigned to Cabinet shutdown."},
	]

func _show_lost_shift_complete_notice() -> void:
	if quest_notice and quest_notice.has_method("show_custom_notification"):
		quest_notice.call(
			"show_custom_notification",
			"QUEST COMPLETE",
			"LOST SHIFT FILE COMPLETE",
			"A redacted staff number was assigned to Cabinet shutdown."
		)

func _after_lost_shift_file_completed() -> void:
	if ConscienceEncounterDirector.maybe_start_encounter(self, "after_lost_shift_file", Callable(self, "_show_lost_shift_complete_notice")):
		return
	_show_lost_shift_complete_notice()

func _maybe_start_conscience_encounter() -> void:
	ConscienceEncounterDirector.maybe_start_encounter(self, "after_truth_filter")

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
