extends Node2D

const BACKGROUND_ART_PATH := "res://assets/art/maps/cabinet_row/cabinet_row_background_640x440.png"

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
	_refresh_truth_filter_state()

func _dialogue_is_active() -> bool:
	if dialogue_box == null:
		return false
	return dialogue_box.get("active") == true

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
	if not GameState.lost_token_quest_completed:
		start_dialogue([
			{"speaker": "Mr. Byte", "text": "TRUTH FILTER LOCKED."},
			{"speaker": "Mr. Byte", "text": "MEMORY SIGNAL TOO QUIET."},
		])
		return
	if not GameState.lying_cabinets_completed:
		GameState.truth_filter_quest_started = true
		GameState.update_memory_signal_from_progress()
		start_dialogue([
			{"speaker": "Mr. Byte", "text": "Contradiction threshold reached."},
			{"speaker": "Mr. Byte", "text": "Truth Filter is ready."},
			{"speaker": "Mr. Byte", "text": "Please choose the least broken answer."},
		])
		return
	if not GameState.mr_byte_truth_filter_anecdote_seen:
		GameState.mr_byte_truth_filter_anecdote_seen = true
		start_dialogue([
			{"speaker": "Mr. Byte", "text": "Truth Filter passed."},
			{"speaker": "Mr. Byte", "text": "Contradictions remain."},
			{"speaker": "Mr. Byte", "text": "That means the memory is alive enough to argue."},
			{"speaker": "Mr. Byte", "text": "Record conflict reduced. Identity conflict remains."},
		])
		return
	if GameState.circuit_soda_completed and not GameState.lost_shift_file_completed and not GameState.story_puzzle_completed:
		GameState.start_lost_shift_file()
		start_dialogue([
			{"speaker": "Mr. Byte", "text": "Staff schedule access: damaged but readable."},
			{"speaker": "Mr. Byte", "text": "Machines refuse the name. Records retain the assignment."},
			{"speaker": "Mr. Byte", "text": "Read the schedule near this kiosk."},
		])
		return
	if GameState.lost_shift_file_completed and not GameState.maintenance_sync_completed and not GameState.story_puzzle_completed:
		GameState.mr_byte_lost_shift_comment_seen = true
		start_dialogue([
			{"speaker": "Mr. Byte", "text": "Lost Shift File reconstructed."},
			{"speaker": "Mr. Byte", "text": "Identity reference remains restricted."},
		])
		return
	start_dialogue([
		{"speaker": "Mr. Byte", "text": "Truth Filter passed."},
		{"speaker": "Mr. Byte", "text": "Identity conflict remains."},
	])

func _handle_truth_filter() -> void:
	if not GameState.lost_token_quest_completed:
		start_dialogue([
			{"speaker": "Truth Filter", "text": "SIGNAL TOO QUIET."},
			{"speaker": "Truth Filter", "text": "MR. BYTE AUTHORIZATION REQUIRED."},
		])
		return
	if GameState.lying_cabinets_completed:
		start_dialogue([
			{"speaker": "Truth Filter", "text": "TRUTH FILTER PASSED."},
			{"speaker": "Truth Filter", "text": "MEMORY SIGNAL: FRACTURED."},
		])
		return
	GameState.truth_filter_quest_started = true
	GameState.update_memory_signal_from_progress()
	GameState.set_pending_spawn_id("Spawn_FromTruthFilter")
	SceneChanger.go_to_truth_filter()

func _handle_roxy() -> void:
	GameState.roxy_met = true
	if _is_post_reveal():
		var was_completed := _was_witness_route_completed()
		GameState.mark_witness_roxy_heard()
		start_dialogue([
			{"speaker": "Roxy", "text": "So you were Employee 04."},
			{"speaker": "Roxy", "text": "That explains the blank high score."},
			{"speaker": "Roxy", "text": "Hard to rank a memory."},
		], _get_witness_completion_callback(was_completed))
		return
	if GameState.broken_high_score_completed:
		if not GameState.roxy_high_score_anecdote_seen:
			GameState.roxy_high_score_anecdote_seen = true
			start_dialogue([
				{"speaker": "Roxy", "text": "Huh. Your score came back."},
				{"speaker": "Roxy", "text": "That usually does not happen after a reset."},
				{"speaker": "Roxy", "text": "Do not let it go to your head. You still walk like a tutorial."},
			])
			return
		start_dialogue([
			{"speaker": "Roxy", "text": "Your score came back."},
			{"speaker": "Roxy", "text": "Still weird."},
		])
		return
	start_dialogue([
		{"speaker": "Roxy", "text": "Finally. Player Two showed up."},
		{"speaker": "Roxy", "text": "You look like someone who loses to menus."},
		{"speaker": "Roxy", "text": "Try the Broken High Score cabinet."},
		{"speaker": "Roxy", "text": "The screen lies, but badly."},
	])

func _handle_broken_high_score() -> void:
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
		start_dialogue([
			{"speaker": "Staff Schedule", "text": "The schedule screen is scrambled."},
			{"speaker": "Staff Schedule", "text": "Mr. Byte has not unlocked staff records yet."},
		])
		return
	var was_completed := GameState.lost_shift_file_completed
	GameState.read_staff_schedule()
	var lines: Array = [
		{"speaker": "Staff Schedule", "text": "STAFF SCHEDULE"},
		{"speaker": "Staff Schedule", "text": "Final Night"},
		{"speaker": "Staff Schedule", "text": "Mira - Counter"},
		{"speaker": "Staff Schedule", "text": "Gus - Maintenance"},
		{"speaker": "Staff Schedule", "text": "Employee 04 - Cabinet shutdown"},
		{"speaker": "Staff Schedule", "text": "Status: unresolved"},
	]
	lines.append_array(_get_lost_shift_completion_lines())
	var after_dialogue := Callable(self, "_show_lost_shift_complete_notice") if not was_completed and GameState.lost_shift_file_completed else Callable()
	start_dialogue(lines, after_dialogue)

func _handle_staff_record_01() -> void:
	if not GameState.lying_cabinets_completed:
		start_dialogue([
			{"speaker": "Staff Record", "text": "The record terminal is still filtering contradictions."},
		])
		return
	var was_completed := GameState.staff_records_chain_completed
	GameState.read_staff_record_01()
	var lines: Array = [
		{"speaker": "Staff Record", "text": "RESTORE SYSTEM NOTE"},
		{"speaker": "Staff Record", "text": "Subject memory incomplete."},
		{"speaker": "Staff Record", "text": "Do not repeat name until signal stabilizes."},
	]
	lines.append_array(_get_staff_records_completion_lines())
	var after_dialogue := Callable(self, "_show_staff_records_complete_notice") if not was_completed and GameState.staff_records_chain_completed else Callable()
	start_dialogue(lines, after_dialogue)

func _get_lost_shift_completion_lines() -> Array:
	if not GameState.lost_shift_file_completed:
		return []
	return [
		{"speaker": "Quest", "text": "LOST SHIFT FILE COMPLETE"},
		{"speaker": "Quest", "text": "Employee 04 was assigned to Cabinet shutdown."},
	]

func _show_lost_shift_complete_notice() -> void:
	if quest_notice and quest_notice.has_method("show_custom_notification"):
		quest_notice.call(
			"show_custom_notification",
			"QUEST COMPLETE",
			"LOST SHIFT FILE COMPLETE",
			"Employee 04 was assigned to Cabinet shutdown."
		)

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

func _show_witness_route_complete_notice() -> void:
	if quest_notice and quest_notice.has_method("show_custom_notification"):
		quest_notice.call(
			"show_custom_notification",
			"QUEST COMPLETE",
			"POST-REVEAL WITNESSES COMPLETE",
			"Pixel Haven remembers you in pieces. Together, they almost make a person."
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
