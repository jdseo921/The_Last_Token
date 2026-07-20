extends SceneTree

# Captures Broken High Score in its completed state for layout review.
var _game: Node = null
var _elapsed := 0.0
var _completed := false


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://tmp"))


func _process(delta: float) -> bool:
	if _game == null:
		_game = load("res://scenes/minigames/BrokenHighScore.tscn").instantiate()
		root.add_child(_game)
		return false
	_elapsed += delta
	if not _completed and _elapsed >= 0.25:
		for _match_index in 4:
			_game.set("stable", true)
			_game.call("_on_score_pressed")
		_completed = true
	if _completed and _elapsed >= 0.75:
		root.get_texture().get_image().save_png("res://tmp/broken_high_score_complete.png")
		print("saved broken_high_score_complete.png")
		return true
	return false
