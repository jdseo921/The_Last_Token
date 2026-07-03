extends SceneTree
# Captures Truth Filter AFTER its ~0.95s round-intro timer, where the cabinet
# stacking bug occurred. Verifies A/B/C stay in their three positions.
var _n: Node = null
var _elapsed := 0.0

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute("user://captures")

func _process(_d: float) -> bool:
	if _n == null:
		_n = load("res://scenes/minigames/TruthFilter.tscn").instantiate()
		root.add_child(_n)
		_elapsed = 0.0
		return false
	_elapsed += _d
	if _elapsed >= 1.8:
		root.get_texture().get_image().save_png("user://captures/truthfilter_after.png")
		print("saved truthfilter_after.png")
		return true
	return false
