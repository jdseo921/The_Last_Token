extends SceneTree
# Windowed capture of every hallway to verify backgrounds and side exits.
# Run WITHOUT --headless: godot --script res://tools/capture_hallways.gd --path <project>

var _targets := [
	["cabinet", "res://scenes/maps/hallways/CabinetHallway.tscn"],
	["snack", "res://scenes/maps/hallways/SnackHallway.tscn"],
	["prize", "res://scenes/maps/hallways/PrizeHallway.tscn"],
	["maintenance", "res://scenes/maps/hallways/MaintenanceHallway.tscn"],
	["cabinet_snack", "res://scenes/maps/hallways/CabinetSnackHallway.tscn"],
	["snack_prize", "res://scenes/maps/hallways/SnackPrizeHallway.tscn"],
	["maintenance_staff", "res://scenes/maps/hallways/MaintenanceStaffHallway.tscn"],
]
var _i := 0
var _inst: Node = null
var _frame := 0

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://tmp/hallway_captures"))

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
		img.save_png("res://tmp/hallway_captures/hall_%s.png" % _targets[_i][0])
		print("saved ", _targets[_i][0])
		_inst.free()
		_inst = null
		_i += 1
	return false
