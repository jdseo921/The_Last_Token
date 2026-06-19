extends Control

signal menu_closed

const MODE_NEW_GAME := "new_game"
const MODE_LOAD := "load"
const MODE_SAVE := "save"
const OPEN_FADE_SECONDS := 0.18
const ENTER_GAME_FADE_SECONDS := 0.28

var current_mode := MODE_SAVE
var slot_buttons: Array[Button] = []
var pending_slot_id := 0
var pending_mode := ""
var transition_in_progress := false
var fade_tween: Tween = null

@onready var slots_vbox: VBoxContainer = $Panel/SlotsVBox
@onready var title_label: Label = $Panel/TitleLabel
@onready var subtitle_label: Label = $Panel/SubtitleLabel
@onready var status_label: Label = $Panel/StatusLabel
@onready var mode_label: Label = $Panel/ModeLabel
@onready var close_button: Button = $Panel/CloseButton
@onready var confirm_overwrite: ConfirmationDialog = $ConfirmOverwrite
@onready var fade_overlay: ColorRect = $FadeOverlay

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	close_button.pressed.connect(_on_close_pressed)
	confirm_overwrite.confirmed.connect(_on_overwrite_confirmed)
	confirm_overwrite.canceled.connect(_on_overwrite_canceled)
	_build_slots()

func open_menu(mode = MODE_SAVE) -> void:
	current_mode = _normalize_mode(mode)
	visible = true
	transition_in_progress = false
	title_label.text = "SAVE FILES"
	status_label.text = ""
	_refresh_slots()
	_play_open_fade()
	_focus_first_slot()

func _unhandled_input(event: InputEvent) -> void:
	if not visible or transition_in_progress:
		return
	if confirm_overwrite.visible:
		return
	if event.is_action_pressed("cancel"):
		get_viewport().set_input_as_handled()
		_play_audio("play_ui_cancel")
		close_menu()

func _on_close_pressed() -> void:
	if transition_in_progress:
		return
	_play_audio("play_ui_cancel")
	close_menu()

func close_menu() -> void:
	if not visible:
		return
	visible = false
	menu_closed.emit()

func _build_slots() -> void:
	for child in slots_vbox.get_children():
		child.queue_free()
	slot_buttons.clear()
	for slot_id in range(1, 4):
		var button := Button.new()
		button.text = "Save Slot %d" % slot_id
		button.custom_minimum_size = Vector2(0, 88)
		button.pressed.connect(_on_slot_pressed.bind(slot_id))
		slots_vbox.add_child(button)
		slot_buttons.append(button)

func _refresh_slots() -> void:
	subtitle_label.text = _get_subtitle_text()
	mode_label.text = _get_mode_display_text()
	for slot_id in range(1, 4):
		var button := slot_buttons[slot_id - 1]
		var summary := SaveManager.get_slot_summary(slot_id)
		var save_exists := bool(summary.get("save_exists", false))
		button.disabled = false
		if not save_exists:
			var empty_action := "Choose to begin" if current_mode == MODE_NEW_GAME else "Cannot load"
			button.text = "Save Slot %d\nEMPTY SAVE\n%s" % [slot_id, empty_action]
		else:
			button.text = "Save Slot %d\nStatus: %s    Signal: %s\nGames: %d / %d    Secrets: %d / %d\nLast Saved: %s" % [
				slot_id,
				summary.get("story_phase", "Unknown"),
				summary.get("memory_signal_label", "Grounded"),
				int(summary.get("games_completed_count", 0)),
				int(summary.get("total_games_count", 0)),
				int(summary.get("secrets_found_count", 0)),
				int(summary.get("total_secrets_count", 0)),
				summary.get("last_saved_at", "Unknown"),
			]

func _on_slot_pressed(slot_id: int) -> void:
	if transition_in_progress:
		return
	match current_mode:
		MODE_NEW_GAME:
			_handle_new_game_slot(slot_id)
		MODE_LOAD:
			_handle_load_slot(slot_id)
		MODE_SAVE:
			_handle_save_slot(slot_id)

func _handle_new_game_slot(slot_id: int) -> void:
	_play_audio("play_ui_confirm")
	if SaveManager.has_save(slot_id):
		_confirm_overwrite(slot_id, MODE_NEW_GAME)
		return
	if SaveManager.start_new_memory(slot_id):
		status_label.text = "New save created in Slot %d." % slot_id
		await _fade_out_for_scene_change()
		get_tree().paused = false
		SceneChanger.go_to_arcade_hub()
		return
	_show_failure("Could not create Save Slot %d." % slot_id)

func _handle_load_slot(slot_id: int) -> void:
	if not SaveManager.has_save(slot_id):
		_play_audio("play_error")
		_show_failure("Save Slot %d is empty. Nothing to load." % slot_id)
		return
	_play_audio("play_ui_confirm")
	status_label.text = "Loading Save Slot %d..." % slot_id
	await _fade_out_for_scene_change()
	var was_paused := get_tree().paused
	get_tree().paused = false
	if SaveManager.load_game(slot_id):
		return
	get_tree().paused = was_paused
	transition_in_progress = false
	_reset_fade_overlay()
	_show_failure("Could not load Save Slot %d." % slot_id)

func _handle_save_slot(slot_id: int) -> void:
	_play_audio("play_ui_confirm")
	if SaveManager.has_save(slot_id):
		_confirm_overwrite(slot_id, MODE_SAVE)
		return
	if SaveManager.save_game(slot_id):
		status_label.text = "Saved to Slot %d." % slot_id
		await get_tree().create_timer(0.25).timeout
		close_menu()
		return
	_show_failure("Could not save to Slot %d." % slot_id)

func _confirm_overwrite(slot_id: int, mode: String) -> void:
	pending_slot_id = slot_id
	pending_mode = mode
	confirm_overwrite.title = "Overwrite Save Slot %d" % slot_id
	confirm_overwrite.ok_button_text = "Overwrite"
	confirm_overwrite.cancel_button_text = "Keep Slot"
	confirm_overwrite.dialog_text = "Replace Save Slot %d?\nThe old save file in this slot will be lost." % slot_id
	confirm_overwrite.popup_centered()
	call_deferred("_focus_overwrite_confirm")

func _on_overwrite_confirmed() -> void:
	if pending_slot_id <= 0:
		return
	_play_audio("play_ui_confirm")
	var slot_id := pending_slot_id
	var mode := pending_mode
	pending_slot_id = 0
	pending_mode = ""
	match mode:
		MODE_NEW_GAME:
			if SaveManager.start_new_memory(slot_id):
				status_label.text = "Save Slot %d overwritten." % slot_id
				await _fade_out_for_scene_change()
				get_tree().paused = false
				SceneChanger.go_to_arcade_hub()
				return
			_show_failure("Could not overwrite Save Slot %d." % slot_id)
		MODE_SAVE:
			if SaveManager.save_game(slot_id):
				status_label.text = "Save Slot %d overwritten." % slot_id
				await get_tree().create_timer(0.25).timeout
				close_menu()
				return
			_show_failure("Could not overwrite Save Slot %d." % slot_id)

func _on_overwrite_canceled() -> void:
	_play_audio("play_ui_cancel")
	pending_slot_id = 0
	pending_mode = ""
	status_label.text = "Overwrite canceled. Slot was kept."
	_focus_first_slot()

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
			return "New Save - choose a slot"
		MODE_LOAD:
			return "Load Save - choose a saved slot"
		_:
			return "Save File - choose a slot"

func _get_mode_display_text() -> String:
	match current_mode:
		MODE_SAVE:
			return "Mode: Save File"
		MODE_LOAD:
			return "Mode: Load Save"
		_:
			return "Mode: New Save"

func _focus_first_slot() -> void:
	for button in slot_buttons:
		if not button.disabled:
			button.grab_focus()
			return
	close_button.grab_focus()

func _focus_overwrite_confirm() -> void:
	var ok_button := confirm_overwrite.get_ok_button()
	if ok_button:
		ok_button.grab_focus()

func _show_failure(message: String) -> void:
	transition_in_progress = false
	_reset_fade_overlay()
	status_label.text = message
	_refresh_slots()
	_focus_first_slot()

func _play_open_fade() -> void:
	if fade_tween and fade_tween.is_valid():
		fade_tween.kill()
	fade_overlay.visible = true
	fade_overlay.modulate.a = 1.0
	fade_tween = create_tween()
	fade_tween.tween_property(fade_overlay, "modulate:a", 0.0, OPEN_FADE_SECONDS)
	fade_tween.tween_callback(_hide_fade_overlay)

func _fade_out_for_scene_change() -> void:
	transition_in_progress = true
	_set_slot_buttons_disabled(true)
	close_button.disabled = true
	if fade_tween and fade_tween.is_valid():
		fade_tween.kill()
	fade_overlay.visible = true
	fade_overlay.modulate.a = 0.0
	fade_tween = create_tween()
	fade_tween.tween_property(fade_overlay, "modulate:a", 1.0, ENTER_GAME_FADE_SECONDS)
	await fade_tween.finished

func _hide_fade_overlay() -> void:
	fade_overlay.visible = false

func _reset_fade_overlay() -> void:
	if fade_tween and fade_tween.is_valid():
		fade_tween.kill()
	fade_overlay.visible = false
	fade_overlay.modulate.a = 0.0
	_set_slot_buttons_disabled(false)
	close_button.disabled = false

func _set_slot_buttons_disabled(disabled: bool) -> void:
	for button in slot_buttons:
		button.disabled = disabled

func _play_audio(method_name: String) -> void:
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager and audio_manager.has_method(method_name):
		audio_manager.call(method_name)
