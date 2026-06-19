extends CanvasLayer

const SAVE_SLOT_MENU_SCENE := preload("res://scenes/ui/SaveSlotMenu.tscn")
const TITLE_FADE_SECONDS := 0.28

@export var is_minigame_context := false

@onready var panel: Panel = $Panel
@onready var continue_button: Button = $Panel/VBox/ContinueButton
@onready var quest_button: Button = $Panel/VBox/QuestButton
@onready var save_button: Button = $Panel/VBox/SaveButton
@onready var load_button: Button = $Panel/VBox/LoadButton
@onready var settings_button: Button = $Panel/VBox/SettingsButton
@onready var exit_minigame_button: Button = $Panel/VBox/ExitMinigameButton
@onready var title_button: Button = $Panel/VBox/TitleButton
@onready var status_label: Label = $Panel/VBox/StatusLabel
@onready var fade_overlay: ColorRect = $FadeOverlay
@onready var settings_menu: CanvasLayer = $SettingsMenu
@onready var quest_notice: CanvasLayer = $QuestNotice

var save_slot_menu: Control = null
var transition_in_progress := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	continue_button.pressed.connect(_on_continue_pressed)
	quest_button.pressed.connect(_on_quest_pressed)
	save_button.pressed.connect(_on_save_pressed)
	load_button.pressed.connect(_on_load_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	exit_minigame_button.pressed.connect(_on_exit_minigame_pressed)
	title_button.pressed.connect(_on_title_pressed)
	if settings_menu.has_signal("settings_closed"):
		settings_menu.settings_closed.connect(_on_settings_closed)
	if quest_notice.has_signal("quest_closed"):
		quest_notice.connect("quest_closed", _on_quest_closed)
	exit_minigame_button.visible = is_minigame_context

func _unhandled_input(event: InputEvent) -> void:
	if transition_in_progress:
		return
	if settings_menu.visible:
		return
	if save_slot_menu != null and is_instance_valid(save_slot_menu) and save_slot_menu.visible:
		return
	if event.is_action_pressed("cancel"):
		if event is InputEventKey and event.echo:
			get_viewport().set_input_as_handled()
			return
		get_viewport().set_input_as_handled()
		if quest_notice.visible:
			if quest_notice.has_method("close_details"):
				quest_notice.call("close_details")
			return
		if visible:
			close_menu()
		else:
			open_menu()

func open_menu() -> void:
	if visible:
		return
	var host := get_parent()
	if host != null and host.has_method("can_open_pause_menu") and not bool(host.call("can_open_pause_menu")):
		return
	visible = true
	panel.visible = true
	status_label.text = ""
	get_tree().paused = true
	_play_audio("play_ui_confirm")
	continue_button.grab_focus()

func close_menu() -> void:
	if transition_in_progress:
		return
	if save_slot_menu != null and is_instance_valid(save_slot_menu):
		save_slot_menu.queue_free()
	save_slot_menu = null
	visible = false
	panel.visible = true
	get_tree().paused = false
	_play_audio("play_ui_cancel")

func _on_continue_pressed() -> void:
	close_menu()

func _on_quest_pressed() -> void:
	_play_audio("play_ui_confirm")
	panel.visible = false
	if quest_notice.has_method("show_details"):
		quest_notice.call("show_details", GameState.get_current_quest_data())

func _on_save_pressed() -> void:
	_play_audio("play_ui_confirm")
	_open_save_slot_menu("save")

func _on_load_pressed() -> void:
	_play_audio("play_ui_confirm")
	_open_save_slot_menu("load")

func _on_exit_minigame_pressed() -> void:
	_play_audio("play_ui_confirm")
	get_tree().paused = false
	SceneChanger.go_to_arcade_hub()

func _on_title_pressed() -> void:
	_play_audio("play_ui_cancel")
	await _fade_out()
	get_tree().paused = false
	SceneChanger.go_to_title_or_main()

func _on_settings_pressed() -> void:
	_play_audio("play_ui_confirm")
	panel.visible = false
	if settings_menu.has_method("open_menu"):
		settings_menu.open_menu()

func _on_settings_closed() -> void:
	if not visible:
		return
	panel.visible = true
	settings_button.grab_focus()

func _on_quest_closed() -> void:
	if not visible:
		return
	panel.visible = true
	quest_button.grab_focus()

func _open_save_slot_menu(mode: String) -> void:
	if save_slot_menu != null and is_instance_valid(save_slot_menu):
		save_slot_menu.queue_free()
	panel.visible = false
	save_slot_menu = SAVE_SLOT_MENU_SCENE.instantiate()
	save_slot_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(save_slot_menu)
	if save_slot_menu.has_signal("menu_closed"):
		save_slot_menu.menu_closed.connect(_on_save_slot_menu_closed, CONNECT_ONE_SHOT)
	if save_slot_menu.has_method("open_menu"):
		save_slot_menu.open_menu(mode)

func _on_save_slot_menu_closed() -> void:
	if save_slot_menu != null and is_instance_valid(save_slot_menu):
		save_slot_menu.queue_free()
	save_slot_menu = null
	if not visible:
		return
	panel.visible = true
	status_label.text = "Save menu closed."
	continue_button.grab_focus()

func _fade_out() -> void:
	transition_in_progress = true
	fade_overlay.visible = true
	fade_overlay.modulate.a = 0.0
	var fade_tween := create_tween()
	fade_tween.tween_property(fade_overlay, "modulate:a", 1.0, TITLE_FADE_SECONDS)
	await fade_tween.finished

func _play_audio(method_name: String) -> void:
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager and audio_manager.has_method(method_name):
		audio_manager.call(method_name)
