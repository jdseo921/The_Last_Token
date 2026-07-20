extends SceneTree

# Captures the compact quest HUD and both route-cue states for layout review.
var _hub: Node = null
var _elapsed := 0.0
var _normal_saved := false
var _tip_started := false


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://tmp"))


func _process(delta: float) -> bool:
	if _hub == null:
		var game_state := root.get_node_or_null("GameState")
		if game_state != null:
			game_state.reset_for_new_game()
			game_state.opening_intro_seen = true
			game_state.route_cue_close_tip_seen = false
		_hub = load("res://scenes/arcade/ArcadeHub.tscn").instantiate()
		root.add_child(_hub)
		current_scene = _hub
		return false
	_elapsed += delta
	if not _normal_saved and _elapsed >= 0.9:
		root.get_texture().get_image().save_png("res://tmp/navigation_ui_normal.png")
		_normal_saved = true
	if _normal_saved and not _tip_started:
		var route_cue: Node = _hub.get("route_cue")
		if route_cue != null:
			route_cue.call("_on_close_pressed")
		_tip_started = true
		_elapsed = 0.0
	if _tip_started and _elapsed >= 0.25:
		root.get_texture().get_image().save_png("res://tmp/navigation_ui_close_tip.png")
		print("saved navigation UI captures")
		return true
	return false
