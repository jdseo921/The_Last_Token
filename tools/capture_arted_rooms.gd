extends SceneTree
# Capture all rooms with real art for exit-vs-art review.
# Run WITHOUT --headless: godot --script res://tools/capture_arted_rooms.gd --path <project>

var _targets := [
	["hub", "res://scenes/arcade/ArcadeHub.tscn"],
	["cabinet_row", "res://scenes/maps/CabinetRow.tscn"],
	["snack_alcove", "res://scenes/maps/SnackAlcove.tscn"],
	["maintenance_hall", "res://scenes/maps/MaintenanceHall.tscn"],
	["prize_corner", "res://scenes/maps/PrizeCorner.tscn"],
	["staff_corridor", "res://scenes/maps/StaffCorridor.tscn"],
	["staff_room", "res://scenes/arcade/StaffRoom.tscn"],
]
var _i := 0
var _inst: Node = null
var _frame := 0

func _initialize() -> void:
	var gs = root.get_node_or_null("GameState")
	if gs:
		gs.set("story_started", true)
		gs.set("opening_intro_seen", true)
		gs.set("opening_hint_monologue_seen", true)
		gs.set("staff_corridor_unlocked", true)
		gs.set("lying_cabinets_completed", true)
		gs.set("last_announced_quest_id", gs.call("get_current_quest_id"))

func _process(_d: float) -> bool:
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
		img.save_png("user://captures/arted_%s.png" % _targets[_i][0])
		print("saved ", _targets[_i][0])
		_inst.free()
		_inst = null
		_i += 1
	return false
