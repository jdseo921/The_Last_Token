extends Control

const SAVE_SLOT_MENU_SCENE := preload("res://scenes/ui/SaveSlotMenu.tscn")

@onready var save_and_continue_button: Button = $Panel/VBox/SaveAndContinueButton
@onready var return_to_title_button: Button = $Panel/VBox/ReturnToTitleButton

var save_slot_menu: Control = null
var return_to_title_confirm: ConfirmationDialog = null

func _ready() -> void:
	save_and_continue_button.pressed.connect(_on_save_and_continue_pressed)
	return_to_title_button.pressed.connect(_on_return_to_title_pressed)
	_build_return_to_title_confirm()

func _on_save_and_continue_pressed() -> void:
	_mark_post_reveal_state()
	if SaveManager.active_slot_id > 0:
		SaveManager.save_game(SaveManager.active_slot_id)
		_continue_to_arcade_hub()
		return
	_open_save_menu_before_continue()

func _on_return_to_title_pressed() -> void:
	_mark_post_reveal_state()
	if SaveManager.active_slot_id > 0:
		return_to_title_confirm.popup_centered()
		return
	_return_to_title()

func _mark_post_reveal_state() -> void:
	GameState.ending_seen = true
	GameState.twist_reveal_seen = true
	GameState.post_reveal_roam_unlocked = true

func _open_save_menu_before_continue() -> void:
	if save_slot_menu and is_instance_valid(save_slot_menu):
		save_slot_menu.queue_free()
	save_slot_menu = SAVE_SLOT_MENU_SCENE.instantiate()
	add_child(save_slot_menu)
	save_and_continue_button.disabled = true
	return_to_title_button.disabled = true
	if save_slot_menu.has_signal("menu_closed"):
		save_slot_menu.menu_closed.connect(_on_save_slot_menu_closed, CONNECT_ONE_SHOT)
	if save_slot_menu.has_method("open_menu"):
		save_slot_menu.open_menu("save")

func _on_save_slot_menu_closed() -> void:
	if save_slot_menu and is_instance_valid(save_slot_menu):
		save_slot_menu.queue_free()
	save_slot_menu = null
	if SaveManager.active_slot_id > 0:
		_continue_to_arcade_hub()
		return
	save_and_continue_button.disabled = false
	return_to_title_button.disabled = false

func _continue_to_arcade_hub() -> void:
	SceneChanger.go_to_arcade_hub()

func _build_return_to_title_confirm() -> void:
	return_to_title_confirm = ConfirmationDialog.new()
	return_to_title_confirm.title = "Return to Title"
	return_to_title_confirm.dialog_text = "Save before returning to title?"
	return_to_title_confirm.ok_button_text = "Save"
	return_to_title_confirm.cancel_button_text = "Do Not Save"
	add_child(return_to_title_confirm)
	return_to_title_confirm.confirmed.connect(_on_return_to_title_save_confirmed)
	return_to_title_confirm.canceled.connect(_on_return_to_title_save_canceled)

func _on_return_to_title_save_confirmed() -> void:
	if SaveManager.active_slot_id > 0:
		SaveManager.save_game(SaveManager.active_slot_id)
	_return_to_title()

func _on_return_to_title_save_canceled() -> void:
	_return_to_title()

func _return_to_title() -> void:
	SceneChanger.go_to_title_or_main()
