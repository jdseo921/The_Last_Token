extends SceneTree
# Behavior test for the expanded Final Night Walk:
#   ordered frames -> soft wrong-order fail -> staff_door ambush -> secret -> completion.
# Run: godot --headless --script res://tools/test_fnw_flow.gd --path <project>

const AREA_ORDER := ["counter", "cabinet", "snack_prize", "back_hall", "staff_door"]

var _inst: Node = null
var _frame := 0
var _fails := 0

func _process(_delta: float) -> bool:
	if _inst == null:
		var ps = load("res://scenes/minigames/FinalNightWalk.tscn")
		_inst = ps.instantiate()
		root.add_child(_inst)
		return false
	_frame += 1
	if _frame < 3:
		return false
	print("\n=== FNW FLOW TEST ===")

	# 1. wrong order is soft: try to collect frame 2 first
	var refs := _refs_in_area("counter")
	_check("counter has 4 frames", refs.size() == 4)
	_collect_ref(refs[1])
	_check("wrong order rejected", (_inst.get("collected_positions") as Array).size() == 0)
	_collect_ref(refs[0])
	_check("right order accepted", (_inst.get("collected_positions") as Array).size() == 1)
	_collect_ref(refs[1])
	_check("soft fail kept progress", (_inst.get("collected_positions") as Array).size() == 2)

	# 2. secret in snack_prize at (5, 11)
	_inst.call("_change_area", {"target_area": "snack_prize", "target_spawn": Vector2i(1, 1)})
	_inst.set("player_grid_pos", Vector2i(5, 11))
	_inst.call("_handle_tile", "S")
	_check("secret found", bool(_inst.get("secret_found")) == true)
	var gs = root.get_node("GameState")
	_check("secret flag set", bool(gs.get("fnw_secret_echo_found")) == true)

	# 3. staff_door ambush: entering spawns the second patrol
	_inst.call("_change_area", {"target_area": "staff_door", "target_spawn": Vector2i(1, 1)})
	_check("ambush fired", bool(_inst.get("ambush_done")) == true)
	_check("two patrols in staff_door", (_inst.get("active_moving_hazards") as Array).size() == 2)

	# 4. collect all frames in order across areas, then complete
	for area_id in AREA_ORDER:
		_inst.call("_change_area", {"target_area": area_id, "target_spawn": Vector2i(1, 1)})
		for ref in _refs_in_area(area_id):
			_collect_ref(ref)
	_check("all 16 frames collected", (_inst.get("collected_positions") as Array).size() == 16)
	_inst.call("_try_complete")
	_check("stage completed", bool(_inst.get("completed")) == true)
	_check("second signal retreated", (_inst.get("active_moving_hazards") as Array).size() == 0)
	_check("GameState completion", bool(gs.get("final_night_walk_completed")) == true)

	if _fails == 0:
		print("FNW FLOW: PASS")
	else:
		print("FNW FLOW: FAIL (%d)" % _fails)
	print("=== END FNW FLOW ===")
	quit(1 if _fails > 0 else 0)
	return true

func _refs_in_area(area_id: String) -> Array:
	var out: Array = []
	for ref in (_inst.get("collectible_positions") as Array):
		if str(ref).begins_with(area_id + ":"):
			out.append(str(ref))
	return out

func _collect_ref(ref: String) -> void:
	var parts := ref.split(":")
	var xy := parts[1].split(",")
	_inst.call("_try_collect", Vector2i(int(xy[0]), int(xy[1])))

func _check(label: String, ok: bool) -> void:
	print("  [%s] %s" % ["PASS" if ok else "FAIL", label])
	if not ok:
		_fails += 1
