extends Control

signal menu_closed

var save_mode := true
var slot_buttons: Array[Button] = []
var pending_slot_id := 0

@onready var slots_vbox: VBoxContainer = $Panel/SlotsVBox
@onready var title_label: Label = $Panel/TitleLabel
@onready var subtitle_label: Label = $Panel/SubtitleLabel
@onready var mode_button: Button = $Panel/ModeButton
@onready var close_button: Button = $Panel/CloseButton
@onready var confirm_overwrite: ConfirmationDialog = $ConfirmOverwrite

func _ready() -> void:
	visible = false
	mode_button.pressed.connect(_on_mode_pressed)
	close_button.pressed.connect(close_menu)
	_build_slots()

func open_menu(in_save_mode: bool) -> void:
	save_mode = in_save_mode
	visible = true
	title_label.text = "MEMORY TERMINAL"
	_refresh_slots()

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
		button.pressed.connect(_on_slot_pressed.bind(slot_id))
		slots_vbox.add_child(button)
		slot_buttons.append(button)

func _refresh_slots() -> void:
	subtitle_label.text = "Save Memory - choose a slot" if save_mode else "Restore Memory - choose a saved slot"
	mode_button.text = "Restore Memory" if save_mode else "Save Memory"
	for slot_id in range(1, 4):
		var button := slot_buttons[slot_id - 1]
		button.custom_minimum_size = Vector2(0, 36)
		var summary := SaveManager.get_slot_summary(slot_id)
		if not summary.get("save_exists", false):
			button.text = "New Memory Slot %d - Empty" % slot_id
		else:
			button.text = "Memory Slot %d - %s | Games %d/%d | Secrets %d/%d" % [slot_id, summary.get("story_phase", "Unknown"), int(summary.get("games_completed_count", 0)), int(summary.get("total_games_count", 0)), int(summary.get("secrets_found_count", 0)), int(summary.get("total_secrets_count", 0))]

func _on_slot_pressed(slot_id: int) -> void:
	if save_mode:
		if SaveManager.has_save(slot_id):
			pending_slot_id = slot_id
			confirm_overwrite.popup_centered()
			confirm_overwrite.confirmed.connect(_save_pending_slot, CONNECT_ONE_SHOT)
			return
		SaveManager.save_game(slot_id)
	else:
		SaveManager.load_game(slot_id)
	close_menu()

func _save_pending_slot() -> void:
	if pending_slot_id > 0:
		SaveManager.save_game(pending_slot_id)
	close_menu()

func _on_mode_pressed() -> void:
	save_mode = not save_mode
	_refresh_slots()
