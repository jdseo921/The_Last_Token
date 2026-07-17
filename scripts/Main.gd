extends Node2D

const SAVE_SLOT_MENU_SCENE := preload("res://scenes/ui/SaveSlotMenu.tscn")
const TITLE_RETURN_FADE_SECONDS := 0.22
const OPEN_FADE_SECONDS := 1.4

@onready var title_menu: Control = $TitleMenu
@onready var fade_overlay: ColorRect = $FadeLayer/FadeOverlay

var save_slot_menu: Control = null
var fade_tween: Tween = null

func _ready() -> void:
	title_menu.new_memory_requested.connect(_on_new_memory_requested)
	title_menu.restore_memory_requested.connect(_on_restore_memory_requested)
	_play_open_fade_in()

func _play_open_fade_in() -> void:
	# The game opens on black and breathes in: display and music together.
	fade_overlay.visible = true
	fade_overlay.modulate.a = 1.0
	if fade_tween and fade_tween.is_valid():
		fade_tween.kill()
	fade_tween = create_tween()
	fade_tween.tween_property(fade_overlay, "modulate:a", 0.0, OPEN_FADE_SECONDS)
	fade_tween.tween_callback(_hide_fade_overlay)
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager and audio_manager.has_method("fade_in_active_music"):
		audio_manager.call("fade_in_active_music", 0.5)

func _on_new_memory_requested() -> void:
	_open_save_slot_menu("new_game")

func _on_restore_memory_requested() -> void:
	_open_save_slot_menu("load")

func _open_save_slot_menu(mode: String) -> void:
	if save_slot_menu and is_instance_valid(save_slot_menu):
		save_slot_menu.queue_free()
	if title_menu and title_menu.has_method("hide_for_memory_menu"):
		title_menu.hide_for_memory_menu()
	elif title_menu:
		title_menu.visible = false
	save_slot_menu = SAVE_SLOT_MENU_SCENE.instantiate()
	add_child(save_slot_menu)
	if save_slot_menu.has_signal("menu_closed"):
		save_slot_menu.menu_closed.connect(_on_save_slot_menu_closed, CONNECT_ONE_SHOT)
	if save_slot_menu.has_method("open_menu"):
		save_slot_menu.open_menu(mode)

func _on_save_slot_menu_closed() -> void:
	if save_slot_menu and is_instance_valid(save_slot_menu):
		save_slot_menu.queue_free()
	save_slot_menu = null
	await _fade_to_title()
	if title_menu and is_instance_valid(title_menu):
		if title_menu.has_method("show_after_memory_menu"):
			title_menu.show_after_memory_menu()
		else:
			title_menu.visible = true
			if title_menu.has_method("focus_default"):
				title_menu.focus_default()
	await _fade_from_black()

func _fade_to_title() -> void:
	if fade_tween and fade_tween.is_valid():
		fade_tween.kill()
	fade_overlay.visible = true
	fade_overlay.modulate.a = 0.0
	fade_tween = create_tween()
	fade_tween.tween_property(fade_overlay, "modulate:a", 1.0, TITLE_RETURN_FADE_SECONDS)
	await fade_tween.finished

func _fade_from_black() -> void:
	if fade_tween and fade_tween.is_valid():
		fade_tween.kill()
	fade_overlay.visible = true
	fade_overlay.modulate.a = 1.0
	fade_tween = create_tween()
	fade_tween.tween_property(fade_overlay, "modulate:a", 0.0, TITLE_RETURN_FADE_SECONDS)
	fade_tween.tween_callback(_hide_fade_overlay)

func _hide_fade_overlay() -> void:
	fade_overlay.visible = false
