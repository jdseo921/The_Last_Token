extends Area2D

const SAVE_SLOT_MENU_SCENE := preload("res://scenes/ui/SaveSlotMenu.tscn")

var active_menu: Control = null

func interact(player: Node = null) -> void:
	if active_menu and is_instance_valid(active_menu):
		active_menu.queue_free()
	active_menu = SAVE_SLOT_MENU_SCENE.instantiate()
	get_tree().current_scene.add_child(active_menu)
	if active_menu.has_method("open_menu"):
		active_menu.open_menu(true)
	if active_menu.has_signal("menu_closed"):
		active_menu.menu_closed.connect(_on_menu_closed.bind(player), CONNECT_ONE_SHOT)
	if player and player.has_method("set_control_enabled"):
		player.set_control_enabled(false)

func _on_menu_closed(player: Node = null) -> void:
	if player and player.has_method("set_control_enabled"):
		player.set_control_enabled(true)
	if active_menu and is_instance_valid(active_menu):
		active_menu.queue_free()
	active_menu = null
