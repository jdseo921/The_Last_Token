extends SceneTree
# Windowed capture of the two adventure stages (with generated art) to user://captures/.
# Run WITHOUT --headless:
#   godot --script res://tools/capture_adventures.gd --path <project>

var _targets := [
	["static_service_run", "res://scenes/minigames/StaticServiceRun.tscn"],
]
var _i := 0
var _inst: Node = null
var _frame := 0

func _process(_delta: float) -> bool:
	if _inst == null:
		if _i >= _targets.size():
			print("CAPTURE DONE")
			return true
		var ps = load(_targets[_i][1])
		_inst = ps.instantiate()
		root.add_child(_inst)
		_frame = 0
		return false
	_frame += 1
	if _frame == 12:
		var img := root.get_viewport().get_texture().get_image()
		var dir := DirAccess.open("user://")
		if dir and not dir.dir_exists("captures"):
			dir.make_dir("captures")
		var path := "user://captures/adventure_%s.png" % _targets[_i][0]
		img.save_png(path)
		print("saved ", path)
		_inst.free()
		_inst = null
		_i += 1
	return false
