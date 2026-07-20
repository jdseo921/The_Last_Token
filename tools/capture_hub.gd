extends SceneTree
# Renders the wired ArcadeHub (skipping the opening intro fade).
var _n: Node = null
var _el := 0.0

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute("res://tmp/captures")

func _process(d: float) -> bool:
	if _n == null:
		var gs = root.get_node_or_null("GameState")
		if gs != null:
			gs.opening_intro_seen = true
			gs.last_announced_quest_id = "opening_look_around"
		_n = load("res://scenes/arcade/ArcadeHub.tscn").instantiate()
		root.add_child(_n)
		var qn = _n.get_node_or_null("QuestNotice")
		if qn != null:
			qn.visible = false
		_el = 0.0
		return false
	_el += d
	if _el >= 1.2:
		var viewport_texture := root.get_texture()
		if viewport_texture == null:
			push_error("Hub capture requires a rendering display; the headless dummy renderer has no framebuffer.")
			return true
		viewport_texture.get_image().save_png("res://tmp/captures/hub_wired.png")
		print("saved hub_wired.png")
		return true
	return false
