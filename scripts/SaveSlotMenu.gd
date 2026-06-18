extends Control

signal menu_closed

const MODE_NEW_GAME := "new_game"
const MODE_LOAD := "load"
const MODE_SAVE := "save"

var current_mode := MODE_SAVE
var slot_buttons: Array[Button] = []
var pending_slot_id := 0
var pending_mode := ""

@onready var slots_vbox: VBoxContainer = $Panel/SlotsVBox
@onready var title_label: Label = $Panel/TitleLabel
@onready var subtitle_label: Label = $Panel/SubtitleLabel
@onready var mode_button: Button = $Panel/ModeButton
@onready var close_button: Button = $Panel/CloseButton
@onready var confirm_overwrite: ConfirmationDialog = $ConfirmOverwrite

func _ready() -> void:
	visible = false
	mode_button.disabled = true
	close_button.pressed.connect(close_menu)
	confirm_overwrite.confirmed.connect(_on_overwrite_confirmed)
	_build_slots()

func open_menu(mode = MODE_SAVE) -> void:
	current_mode = _normalize_mode(mode)
	visible = true
	title_label.text = "MEMORY TERMINAL"
	_refresh_slots()

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("cancel"):
		close_menu()

func close_menu() -> void:
	visible = false
	menu_closed.emit()

func _build_slots() -> void:
	for child in slots_vbox.get_children():
		child.queue_free()
	slot_buttons.clear()
	for slot_id in range(1, 4):
		var button := Button.new()
		button.text = "Memory Slot %d" % slot_id
		button.custom_minimum_size = Vector2(0, 78)
		button.pressed.connect(_on_slot_pressed.bind(slot_id))
		slots_vbox.add_child(button)
		slot_buttons.append(button)

func _refresh_slots() -> void:
	subtitle_label.text = _get_subtitle_text()
	mode_button.text = _get_mode_display_text()
	for slot_id in range(1, 4):
		var button := slot_buttons[slot_id - 1]
		var summary := SaveManager.get_slot_summary(slot_id)
		if not summary.get("save_exists", false):
			button.text = "Memory Slot %d\nEmpty Memory" % slot_id
		else:
			button.text = "Memory Slot %d\nStatus: %s\nGames: %d / %d\nSecrets: %d / %d\nLast Saved: %s" % [
				slot_id,
				summary.get("story_phase", "Unknown"),
				int(summary.get("games_completed_count", 0)),
				int(summary.get("total_games_count", 0)),
				int(summary.get("secrets_found_count", 0)),
				int(summary.get("total_secrets_count", 0)),
				summary.get("last_saved_at", "Unknown"),
			]

func _on_slot_pressed(slot_id: int) -> void:
	match current_mode:
		MODE_NEW_GAME:
			_handle_new_game_slot(slot_id)
		MODE_LOAD:
			_handle_load_slot(slot_id)
		MODE_SAVE:
			_handle_save_slot(slot_id)

func _handle_new_game_slot(slot_id: int) -> void:
	if SaveManager.has_save(slot_id):
		_confirm_overwrite(slot_id, MODE_NEW_GAME)
		return
	if SaveManager.start_new_memory(slot_id):
		close_menu()
		SceneChanger.go_to_arcade_hub()

func _handle_load_slot(slot_id: int) -> void:
	if not SaveManager.has_save(slot_id):
		_play_audio("play_error")
		return
	if SaveManager.load_game(slot_id):
		close_menu()

func _handle_save_slot(slot_id: int) -> void:
	if SaveManager.has_save(slot_id):
		_confirm_overwrite(slot_id, MODE_SAVE)
		return
	if SaveManager.save_game(slot_id):
		close_menu()

func _confirm_overwrite(slot_id: int, mode: String) -> void:
	pending_slot_id = slot_id
	pending_mode = mode
	confirm_overwrite.dialog_text = "Overwrite Memory Slot %d?" % slot_id
	confirm_overwrite.popup_centered()

func _on_overwrite_confirmed() -> void:
	if pending_slot_id <= 0:
		return
	var slot_id := pending_slot_id
	var mode := pending_mode
	pending_slot_id = 0
	pending_mode = ""
	match mode:
		MODE_NEW_GAME:
			if SaveManager.start_new_memory(slot_id):
				close_menu()
				SceneChanger.go_to_arcade_hub()
		MODE_SAVE:
			if SaveManager.save_game(slot_id):
				close_menu()

func _normalize_mode(mode) -> String:
	if typeof(mode) == TYPE_BOOL:
		return MODE_SAVE if mode else MODE_LOAD
	var mode_text := str(mode)
	if mode_text == MODE_NEW_GAME or mode_text == MODE_LOAD or mode_text == MODE_SAVE:
		return mode_text
	return MODE_SAVE

func _get_subtitle_text() -> String:
	match current_mode:
		MODE_NEW_GAME:
			return "New Memory - choose a slot"
		MODE_LOAD:
			return "Restore Memory - choose a saved slot"
		_:
			return "Save Memory - choose a slot"

func _get_mode_display_text() -> String:
	match current_mode:
		MODE_SAVE:
			return "Mode: Save Memory"
		MODE_LOAD:
			return "Mode: Restore Memory"
		_:
			return "Mode: New Memory"

func _play_audio(method_name: String) -> void:
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager and audio_manager.has_method(method_name):
		audio_manager.call(method_name)
