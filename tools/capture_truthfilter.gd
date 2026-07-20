extends SceneTree
# Captures Truth Filter AFTER its ~0.95s round-intro timer, where the cabinet
# stacking bug occurred. Verifies A/B/C stay in their three positions.
var _n: Node = null
var _elapsed := 0.0
var _capture_stage := 0

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute("res://tmp/captures")

func _process(_d: float) -> bool:
	if _n == null:
		_n = load("res://scenes/minigames/TruthFilter.tscn").instantiate()
		root.add_child(_n)
		_elapsed = 0.0
		return false
	_elapsed += _d
	if _capture_stage == 0 and _elapsed >= 1.8:
		var viewport_texture := root.get_texture()
		if viewport_texture == null:
			return false
		var image := viewport_texture.get_image()
		if image == null:
			return false
		image.save_png("res://tmp/captures/truthfilter_after.png")
		print("saved res://tmp/captures/truthfilter_after.png")
		_n.set("current_round", 3)
		_n.call("_show_round")
		_n.call("_destabilize")
		_capture_stage = 1
		_elapsed = 0.0
		return false
	if _capture_stage == 1 and _elapsed >= 0.35:
		root.get_texture().get_image().save_png("res://tmp/captures/truthfilter_critical.png")
		print("saved res://tmp/captures/truthfilter_critical.png")
		_n.call("_complete_puzzle")
		_capture_stage = 2
		_elapsed = 0.0
		return false
	if _capture_stage == 2 and _elapsed >= 0.35:
		root.get_texture().get_image().save_png("res://tmp/captures/truthfilter_complete.png")
		print("saved res://tmp/captures/truthfilter_complete.png")
		return true
	return false
