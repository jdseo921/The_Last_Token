extends SceneTree
# Behavior test for the expanded Static Service Run:
#   fuse lights cells -> breaker entry triggers blackout -> secret cache -> completion retreat.
# Run: godot --headless --script res://tools/test_ssr_flow.gd --path <project>

var _inst: Node = null
var _frame := 0
var _fails := 0

func _process(_delta: float) -> bool:
	if _inst == null:
		var ps = load("res://scenes/minigames/StaticServiceRun.tscn")
		_inst = ps.instantiate()
		root.add_child(_inst)
		return false
	_frame += 1
	if _frame < 3:
		return false
	print("\n=== SSR FLOW TEST ===")

	# 1. collect first fuse in entry -> breaker-reveal lights cells
	_collect_one_fuse()
	_check("fuse lights cells", (_inst.get("lit_cells") as Dictionary).size() > 0)

	# 2. walk the link chain: entry -> relay -> breaker (via _change_area) -> blackout
	_inst.call("_change_area", {"target_area": "relay", "target_spawn": Vector2i(1, 1)})
	_check("entered relay", str(_inst.get("active_area_id")) == "relay")
	_check("no blackout yet", bool(_inst.get("blackout_done")) == false)
	_inst.call("_change_area", {"target_area": "breaker", "target_spawn": Vector2i(1, 1)})
	_check("entered breaker", str(_inst.get("active_area_id")) == "breaker")
	_check("blackout fired", bool(_inst.get("blackout_done")) == true)
	_check("blackout cleared lit cells", (_inst.get("lit_cells") as Dictionary).size() == 0)
	var hz: Array = _inst.get("active_moving_hazards")
	if hz.size() > 0:
		_check("blackout sped patrols", float(hz[0].get("interval", 1.0)) < 0.34)
	else:
		_check("breaker has patrol", false)

	# 3. secret: jump to storage and step on S at (17, 1)
	_inst.call("_change_area", {"target_area": "storage", "target_spawn": Vector2i(16, 1)})
	_inst.set("player_grid_pos", Vector2i(17, 1))
	_inst.call("_handle_tile", "S")
	_check("secret found", bool(_inst.get("secret_found")) == true)
	var gs = root.get_node("GameState")
	_check("secret flag set", bool(gs.get("ssr_secret_cache_found")) == true)

	# 3b. reset: fresh run, set-piece re-armed, secret kept
	_inst.call("_reset_stage")
	_check("reset cleared collected", (_inst.get("collected_positions") as Array).size() == 0)
	_check("reset cleared lit cells", (_inst.get("lit_cells") as Dictionary).size() == 0)
	_check("reset re-armed blackout", bool(_inst.get("blackout_done")) == false)
	_check("reset kept secret", bool(_inst.get("secret_found")) == true)
	_check("reset restored start area", str(_inst.get("active_area_id")) == "entry")
	_check("reset restored patrols", (_inst.get("active_moving_hazards") as Array).size() == 1)

	# 4. completion: collect every fuse through the real path, then stand on goal
	for area_id in ["entry", "crawl", "relay", "storage", "breaker"]:
		_inst.call("_change_area", {"target_area": area_id, "target_spawn": Vector2i(1, 1)})
		var cps: Array = _inst.get("collectible_positions")
		for ref in cps:
			var parts := str(ref).split(":")
			if parts.size() == 2 and parts[0] == area_id:
				var xy := parts[1].split(",")
				_inst.call("_try_collect", Vector2i(int(xy[0]), int(xy[1])))
	_check("all 16 fuses collected", (_inst.get("collected_positions") as Array).size() == 16)
	_inst.call("_change_area", {"target_area": "breaker", "target_spawn": Vector2i(1, 1)})
	_inst.call("_try_complete")
	_check("stage completed", bool(_inst.get("completed")) == true)
	_check("patrols retreated", (_inst.get("active_moving_hazards") as Array).size() == 0)
	_check("GameState completion", bool(gs.get("static_service_run_completed")) == true)

	if _fails == 0:
		print("SSR FLOW: PASS")
	else:
		print("SSR FLOW: FAIL (%d)" % _fails)
	print("=== END SSR FLOW ===")
	quit(1 if _fails > 0 else 0)
	return true

func _collect_one_fuse() -> void:
	var cps: Array = _inst.get("collectible_positions")
	var active := str(_inst.get("active_area_id"))
	for ref in cps:
		var parts := str(ref).split(":")
		if parts.size() == 2 and parts[0] == active:
			var xy := parts[1].split(",")
			_inst.call("_try_collect", Vector2i(int(xy[0]), int(xy[1])))
			return

func _check(label: String, ok: bool) -> void:
	print("  [%s] %s" % ["PASS" if ok else "FAIL", label])
	if not ok:
		_fails += 1
