extends SceneTree
# Renders room scenes (Node2D) to PNGs to verify NPC nameplates / layout.
#   godot --path <project> --script res://tools/capture_rooms.gd
var _targets := [
	["cabinet_row", "res://scenes/maps/CabinetRow.tscn"],
	["snack_alcove", "res://scenes/maps/SnackAlcove.tscn"],
	["maintenance_hall", "res://scenes/maps/MaintenanceHall.tscn"],
	["prize_corner", "res://scenes/maps/PrizeCorner.tscn"],
	["staff_corridor", "res://scenes/maps/StaffCorridor.tscn"],
	["arcade_hub", "res://scenes/arcade/ArcadeHub.tscn"],
]
var _i := 0
var _inst: Node = null
var _frame := 0

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute("user://captures")

func _process(_d: float) -> bool:
	if _inst == null:
		if _i >= _targets.size():
			print("done rooms")
			return true
		var ps = load(_targets[_i][1])
		if ps == null:
			print("%s LOAD FAIL" % _targets[_i][0]); _i += 1; return false
		_inst = ps.instantiate()
		root.add_child(_inst)
		_frame = 0
		return false
	_frame += 1
	if _frame >= 16:
		var img := root.get_texture().get_image()
		img.save_png("user://captures/room_%s.png" % _targets[_i][0])
		print("saved room_%s" % _targets[_i][0])
		_inst.free()
		_inst = null
		_i += 1
	return false
