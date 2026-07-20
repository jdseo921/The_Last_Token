extends SceneTree

var minigame: Node = null
var elapsed := 0.0
var pause_revealed := false


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute("res://tmp/captures")


func _process(delta: float) -> bool:
	if minigame == null:
		minigame = load("res://scenes/minigames/TruthFilter.tscn").instantiate()
		root.add_child(minigame)
		return false
	elapsed += delta
	if not pause_revealed and elapsed >= 0.8:
		var pause_menu := minigame.get_node("PauseMenu") as CanvasLayer
		pause_menu.visible = true
		pause_menu.get_node("Panel").visible = true
		pause_revealed = true
		elapsed = 0.0
		return false
	if pause_revealed and elapsed >= 0.25:
		var viewport_texture := root.get_texture()
		if viewport_texture == null:
			push_error("Pause-menu capture requires a rendering display.")
			return true
		viewport_texture.get_image().save_png("res://tmp/captures/pause_menu_compact.png")
		print("saved res://tmp/captures/pause_menu_compact.png")
		return true
	return false
