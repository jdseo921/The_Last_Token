extends SceneTree
# Instantiate every map/hallway/hub/staff-room and tick _ready to catch runtime errors
# from the art/portrait/RouteCue wiring. Run:
#   godot --headless --script res://tools/smoke_all_maps.gd --path <project>

var scenes := [
	"res://scenes/arcade/ArcadeHub.tscn",
	"res://scenes/arcade/StaffRoom.tscn",
	"res://scenes/maps/CabinetRow.tscn",
	"res://scenes/maps/SnackAlcove.tscn",
	"res://scenes/maps/MaintenanceHall.tscn",
	"res://scenes/maps/StaffCorridor.tscn",
	"res://scenes/maps/PrizeCorner.tscn",
	"res://scenes/maps/FrontEntrance.tscn",
	"res://scenes/maps/PartyRoom.tscn",
	"res://scenes/maps/Restrooms.tscn",
	"res://scenes/maps/hallways/CabinetHallway.tscn",
	"res://scenes/maps/hallways/SnackHallway.tscn",
	"res://scenes/maps/hallways/PrizeHallway.tscn",
	"res://scenes/maps/hallways/MaintenanceHallway.tscn",
	"res://scenes/maps/hallways/CabinetSnackHallway.tscn",
	"res://scenes/maps/hallways/SnackPrizeHallway.tscn",
	"res://scenes/maps/hallways/MaintenanceStaffHallway.tscn",
]
var i := 0
var inst: Node = null
var frame := 0
var results: Array = []

func _initialize() -> void:
	var gs = root.get_node_or_null("GameState")
	if gs:
		gs.set("story_started", true)
		gs.set("staff_corridor_unlocked", true)

func _process(_d: float) -> bool:
	if inst == null:
		if i >= scenes.size():
			print("\n=== MAP LOAD SWEEP ===")
			for r in results:
				print("  " + str(r))
			print("=== END (%d scenes) ===" % scenes.size())
			return true
		var ps = load(scenes[i])
		if ps == null:
			results.append("LOAD-FAIL " + scenes[i]); i += 1; return false
		inst = ps.instantiate()
		root.add_child(inst)
		frame = 0
		return false
	frame += 1
	if frame >= 3:
		var ok = is_instance_valid(inst) and inst.get_child_count() > 0
		results.append(("OK    " if ok else "EMPTY ") + str(scenes[i]).get_file())
		inst.free()
		inst = null
		i += 1
	return false
