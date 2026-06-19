extends Node2D

const BACKGROUND_ART_PATH := "res://assets/art/maps/maintenance_hall/maintenance_hall_background_640x440.png"

@onready var player: CharacterBody2D = $Player
@onready var background_art: Sprite2D = $BackgroundArt
@onready var dialogue_box: CanvasLayer = $UILayer/DialogueBox
@onready var prompt_label: Label = $UILayer/InteractionPrompt
@onready var prompt_background: ColorRect = $UILayer/InteractionPromptBackground
@onready var sync_door_glow: Polygon2D = $SyncDoorGlow
@onready var quest_notice: CanvasLayer = $QuestNotice

var pending_after_dialogue: Callable = Callable()

func _ready() -> void:
	player.interaction_prompt_changed.connect(_on_prompt_changed)
	dialogue_box.dialogue_finished.connect(_on_dialogue_finished)
	_apply_background_art()
	_apply_spawn_position()
	_on_prompt_changed("")
	_refresh_sync_state()

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
	_refresh_sync_state()

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
		"maintenance_note":
			_handle_maintenance_note()
		"staff_record_02":
			_handle_staff_record_02()
		_:
			start_dialogue([{"speaker": "System", "text": "Nothing happens."}])

func _handle_gus() -> void:
	GameState.gus_intro_seen = true
	if not GameState.circuit_soda_completed:
		start_dialogue([
			{"speaker": "Gus", "text": "Maintenance Hall is not ready for you yet."},
			{"speaker": "Gus", "text": "Go let Vendo route whatever counts as your signal first."},
		])
		return
	if not GameState.lost_shift_file_completed and not GameState.maintenance_sync_completed and not GameState.story_puzzle_completed:
		GameState.start_lost_shift_file()
		start_dialogue([
			{"speaker": "Gus", "text": "I can help with the door."},
			{"speaker": "Gus", "text": "But not until you know what shift you are standing in."},
			{"speaker": "Gus", "text": "Find the Lost Shift File first."},
		])
		return
	if GameState.lost_shift_file_completed and not GameState.static_service_run_completed and not GameState.maintenance_sync_completed and not GameState.story_puzzle_completed:
		GameState.gus_lost_shift_comment_seen = true
		start_dialogue([
			{"speaker": "Gus", "text": "Employee 04. Cabinet shutdown."},
			{"speaker": "Gus", "text": "Yeah. That is where the night went bad."},
			{"speaker": "Gus", "text": "Before I sync anything, the service route needs power."},
		], Callable(self, "_go_to_static_service_run"))
		return
	if GameState.static_service_run_completed and not GameState.gus_static_run_anecdote_seen:
		GameState.gus_static_run_anecdote_seen = true
		start_dialogue([
			{"speaker": "Gus", "text": "Power's back."},
			{"speaker": "Gus", "text": "Door's awake."},
			{"speaker": "Gus", "text": "That is usually good news, except when the door is smarter than the staff."},
			{"speaker": "Gus", "text": "Now we can sync the two signals."},
		])
		return
	if not GameState.maintenance_sync_completed and not GameState.story_puzzle_completed:
		start_dialogue([
			{"speaker": "Gus", "text": "Power's back. Door's listening."},
			{"speaker": "Gus", "text": "I still hate that sentence."},
			{"speaker": "Gus", "text": "Two signals are fighting in the door."},
		], Callable(self, "_go_to_maintenance_sync"))
		return
	if not GameState.gus_sync_anecdote_seen:
		GameState.gus_sync_anecdote_seen = true
		start_dialogue([
			{"speaker": "Gus", "text": "Door's listening now."},
			{"speaker": "Gus", "text": "I do not like doors that listen."},
			{"speaker": "Gus", "text": "But if it opens, part of you matched something it lost."},
			{"speaker": "Gus", "text": "Door heard both knocks. Yours, and the one you forgot making."},
		])
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
		start_dialogue([
			{"speaker": "Maintenance Sync", "text": "SIGNAL ROUTE MISSING."},
			{"speaker": "Maintenance Sync", "text": "CIRCUIT SODA REQUIRED."},
		])
		return
	if not GameState.lost_shift_file_completed and not GameState.maintenance_sync_completed and not GameState.story_puzzle_completed:
		start_dialogue([
			{"speaker": "Maintenance Sync", "text": "MAINTENANCE SYNC LOCKED."},
			{"speaker": "Maintenance Sync", "text": "LOST SHIFT FILE REQUIRED."},
		])
		return
	if not GameState.static_service_run_completed and not GameState.maintenance_sync_completed and not GameState.story_puzzle_completed:
		start_dialogue([
			{"speaker": "Maintenance Sync", "text": "MAINTENANCE SYNC LOCKED."},
			{"speaker": "Maintenance Sync", "text": "STATIC SERVICE REQUIRED."},
		])
		return
	if GameState.maintenance_sync_completed or GameState.story_puzzle_completed:
		start_dialogue([
			{"speaker": "Maintenance Sync", "text": "ACCESS GRANTED."},
			{"speaker": "Maintenance Sync", "text": "EMPLOYEE SIGNAL ACCEPTED."},
		])
		return
	_go_to_maintenance_sync()

func _go_to_static_service_run() -> void:
	GameState.start_static_service_run()
	GameState.set_pending_spawn_id("Spawn_FromMaintenanceSync")
	SceneChanger.go_to_static_service_run()

func _go_to_maintenance_sync() -> void:
	GameState.start_maintenance_sync()
	GameState.set_pending_spawn_id("Spawn_FromMaintenanceSync")
	SceneChanger.go_to_maintenance_sync()

func _handle_maintenance_note() -> void:
	if not GameState.circuit_soda_completed:
		start_dialogue([
			{"speaker": "Maintenance Note", "text": "Most of the note is routine cleaning nonsense."},
		])
		return
	var was_completed := GameState.lost_shift_file_completed
	GameState.read_maintenance_note()
	var lines: Array = [
		{"speaker": "Maintenance Note", "text": "MAINTENANCE NOTE"},
		{"speaker": "Maintenance Note", "text": "Staff Door reported two signals after closing."},
		{"speaker": "Maintenance Note", "text": "One signal entered."},
		{"speaker": "Maintenance Note", "text": "One signal remained."},
		{"speaker": "Maintenance Note", "text": "Gus note: I do not get paid enough for doors with opinions."},
	]
	lines.append_array(_get_lost_shift_completion_lines())
	var after_dialogue := Callable(self, "_show_lost_shift_complete_notice") if not was_completed and GameState.lost_shift_file_completed else Callable()
	start_dialogue(lines, after_dialogue)

func _handle_staff_record_02() -> void:
	if not GameState.lying_cabinets_completed:
		start_dialogue([
			{"speaker": "Staff Record", "text": "The maintenance record is still sealed."},
		])
		return
	var was_completed := GameState.staff_records_chain_completed
	GameState.read_staff_record_02()
	var lines: Array = [
		{"speaker": "Staff Record", "text": "MAINTENANCE WARNING"},
		{"speaker": "Staff Record", "text": "Door responds to two signatures."},
		{"speaker": "Staff Record", "text": "One physical. One stored."},
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

func _apply_background_art() -> void:
	var loaded := _apply_sprite_texture(background_art, BACKGROUND_ART_PATH)
	for placeholder in [$Background, $UtilityWall, $GusPlaceholder, $SyncDoorPlaceholder]:
		if placeholder is CanvasItem:
			placeholder.visible = not loaded

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
