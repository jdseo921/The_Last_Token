extends SceneTree
# Renders the ??? conscience encounter (dim + fade-in) to verify #4.
var _n: Node = null
var _elapsed := 0.0

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute("user://captures")
	var bg := ColorRect.new()
	bg.color = Color(0.12, 0.06, 0.16, 1.0)
	bg.size = Vector2(640, 440)
	root.add_child(bg)

func _process(d: float) -> bool:
	if _n == null:
		_n = load("res://scenes/cutscenes/ConscienceEncounter.tscn").instantiate()
		root.add_child(_n)
		_n.call("start_encounter", "test", [{"speaker": "???", "text": "One of them keeps taking your turn.", "effect": "glitch"}])
		_elapsed = 0.0
		return false
	_elapsed += d
	if _elapsed >= 0.8:
		root.get_texture().get_image().save_png("user://captures/conscience.png")
		print("saved conscience.png")
		return true
	return false
