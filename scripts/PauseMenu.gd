extends CanvasLayer

const SAVE_SLOT_MENU_SCENE := preload("res://scenes/ui/SaveSlotMenu.tscn")
const MINIGAME_LAYOUT_GUARD_SCRIPT := preload("res://scripts/ui/MinigameUILayoutGuard.gd")
const TITLE_FADE_SECONDS := 0.28
const ROOM_PANEL_HEIGHT := 330.0
const MINIGAME_PANEL_HEIGHT := 368.0
const PANEL_VERTICAL_PADDING := 18.0

@export var is_minigame_context := false

@onready var panel: Panel = $Panel
@onready var continue_button: Button = $Panel/VBox/ContinueButton
@onready var quest_button: Button = $Panel/VBox/QuestButton
@onready var save_button: Button = $Panel/VBox/SaveButton
@onready var load_button: Button = $Panel/VBox/LoadButton
@onready var settings_button: Button = $Panel/VBox/SettingsButton
@onready var controls_button: Button = $Panel/VBox/ControlsButton
@onready var exit_minigame_button: Button = $Panel/VBox/ExitMinigameButton
@onready var title_button: Button = $Panel/VBox/TitleButton
@onready var menu_vbox: VBoxContainer = $Panel/VBox
@onready var fade_overlay: ColorRect = $FadeOverlay
@onready var settings_menu: CanvasLayer = $SettingsMenu
@onready var quest_notice: CanvasLayer = $QuestNotice

const CONTROLS_TEXT := """Move - WASD or Arrow Keys
Interact / Advance dialogue - E or Space
Menu / Back - Esc
Adventure stages - R returns you to the last checkpoint
Scrolling stages - hold E or Space for jump height; press again in air

Walk close to a glowing arrow to see where a doorway leads.
Walk up to people and machines and press E to talk."""

var save_slot_menu: Control = null
var transition_in_progress := false
var focus_owner_before_menu: Control = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	continue_button.pressed.connect(_on_continue_pressed)
	quest_button.pressed.connect(_on_quest_pressed)
	save_button.pressed.connect(_on_save_pressed)
	load_button.pressed.connect(_on_load_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	controls_button.pressed.connect(_on_controls_pressed)
	exit_minigame_button.pressed.connect(_on_exit_minigame_pressed)
	title_button.pressed.connect(_on_title_pressed)
	if settings_menu.has_signal("settings_closed"):
		settings_menu.settings_closed.connect(_on_settings_closed)
	if quest_notice.has_signal("quest_closed"):
		quest_notice.connect("quest_closed", _on_quest_closed)
	exit_minigame_button.visible = is_minigame_context
	_fit_panel_to_context()
	if is_minigame_context:
		call_deferred("_install_minigame_layout_guard")

func _install_minigame_layout_guard() -> void:
	var host := get_parent()
	if host == null or host.get_node_or_null("MinigameUILayoutGuard") != null:
		return
	var guard := MINIGAME_LAYOUT_GUARD_SCRIPT.new()
	guard.name = "MinigameUILayoutGuard"
	host.add_child(guard)

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
	if SceneChanger.has_method("is_transitioning") and SceneChanger.is_transitioning():
		return
	var host := get_parent()
	if host != null and host.has_method("can_open_pause_menu") and not bool(host.call("can_open_pause_menu")):
		return
	focus_owner_before_menu = get_viewport().gui_get_focus_owner()
	visible = true
	panel.visible = true
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
	if focus_owner_before_menu != null and is_instance_valid(focus_owner_before_menu) \
			and focus_owner_before_menu.is_visible_in_tree():
		focus_owner_before_menu.grab_focus()
	focus_owner_before_menu = null

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
	# Back to the room the minigame was launched from (falls back to the hub).
	if not SceneChanger.go_to_return_point():
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

func _on_controls_pressed() -> void:
	_play_audio("play_ui_confirm")
	panel.visible = false
	if quest_notice.has_method("show_custom_details"):
		quest_notice.call("show_custom_details", "CONTROLS", "HOW TO PLAY", CONTROLS_TEXT)

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
	continue_button.grab_focus()

func _fit_panel_to_context() -> void:
	var panel_height := MINIGAME_PANEL_HEIGHT if is_minigame_context else ROOM_PANEL_HEIGHT
	panel.offset_top = -panel_height * 0.5
	panel.offset_bottom = panel_height * 0.5
	menu_vbox.offset_bottom = panel_height - PANEL_VERTICAL_PADDING

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
