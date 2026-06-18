extends Node2D

const SAVE_SLOT_MENU_SCENE := preload("res://scenes/ui/SaveSlotMenu.tscn")

@onready var title_menu: Control = $TitleMenu

var save_slot_menu: Control = null

func _ready() -> void:
	title_menu.new_memory_requested.connect(_on_new_memory_requested)
	title_menu.restore_memory_requested.connect(_on_restore_memory_requested)

func _on_new_memory_requested() -> void:
	_open_save_slot_menu("new_game")

func _on_restore_memory_requested() -> void:
	_open_save_slot_menu("load")

func _open_save_slot_menu(mode: String) -> void:
	if save_slot_menu and is_instance_valid(save_slot_menu):
		save_slot_menu.queue_free()
	save_slot_menu = SAVE_SLOT_MENU_SCENE.instantiate()
	add_child(save_slot_menu)
	title_menu.visible = false
	if save_slot_menu.has_signal("menu_closed"):
		save_slot_menu.menu_closed.connect(_on_save_slot_menu_closed, CONNECT_ONE_SHOT)
	if save_slot_menu.has_method("open_menu"):
		save_slot_menu.open_menu(mode)

func _on_save_slot_menu_closed() -> void:
	if save_slot_menu and is_instance_valid(save_slot_menu):
		save_slot_menu.queue_free()
	save_slot_menu = null
	if title_menu and is_instance_valid(title_menu):
		title_menu.visible = true
