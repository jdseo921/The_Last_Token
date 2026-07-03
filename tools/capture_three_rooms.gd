extends SceneTree
# Windowed capture of Snack Alcove / Maintenance Hall / Prize Corner with new backgrounds.
# Run WITHOUT --headless: godot --script res://tools/capture_three_rooms.gd --path <project>

var _targets := [
	["snack_alcove", "res://scenes/maps/SnackAlcove.tscn"],
	["maintenance_hall", "res://scenes/maps/MaintenanceHall.tscn"],
	["prize_corner", "res://scenes/maps/PrizeCorner.tscn"],
]
var _i := 0
var _inst: Node = null
var _frame := 0

func _process(_delta: float) -> bool:
	if _inst == null:
		if _i >= _targets.size():
			print("CAPTURE DONE")
			return true
		_inst = load(_targets[_i][1]).instantiate()
		root.add_child(_inst)
		_frame = 0
		return false
	_frame += 1
	if _frame == 14:
		var img := root.get_viewport().get_texture().get_image()
		img.save_png("user://captures/room_%s.png" % _targets[_i][0])
		print("saved ", _targets[_i][0])
		_inst.free()
		_inst = null
		_i += 1
	return false
