extends SceneTree
# Headless smoke test for adventure stages: confirms the neon ScreenBackground +
# CRT overlay build, and that the overlay PERSISTS across an area rebuild (which
# clears children). Run:
#   godot --headless --script res://tools/smoke_adventure.gd --path <project>

var _out: Array = []
var _targets := [
	["StaticServiceRun", "res://scenes/minigames/StaticServiceRun.tscn"],
	["FinalNightWalk", "res://scenes/minigames/FinalNightWalk.tscn"],
]
var _i := 0
var _inst: Node = null
var _frame := 0

func _initialize() -> void:
	_out.append("Autoloads: AudioManager=%s GameState=%s" % [root.has_node("AudioManager"), root.has_node("GameState")])

func _process(_delta: float) -> bool:
	if _inst == null:
		if _i >= _targets.size():
			_dump(_out)
			return true
		var ps = load(_targets[_i][1])
		if ps == null:
			_out.append("%s: LOAD FAILED" % _targets[_i][0])
			_i += 1
			return false
		_inst = ps.instantiate()
		root.add_child(_inst)
		_frame = 0
		return false
	_frame += 1
	var key = _targets[_i][0]
	if _frame == 2:
		_out.append("%s: [ready] screenbg=%s scan=%s crt=%s hazards=%d" % [key, _inst.has_node("ScreenBackground"), _inst.has_node("ArcadeScanlines"), _inst.has_node("ArcadeCRTOverlay"), _hazard_count()])
		if bool(_inst.get("breaker_reveal_enabled")):
			_out.append("%s: [breaker] %s" % [key, _breaker_probe()])
		return false
	if _frame == 40:
		_out.append("%s: [after 40f] hazards=%d (patrols stepped, no crash)" % [key, _hazard_count()])
		if _inst.has_method("_rebuild_area_view"):
			_inst.call("_rebuild_area_view", "smoke")
		return false
	if _frame >= 42:
		_out.append("%s: [post-rebuild] screenbg=%s crt=%s hazards=%d (overlay must persist)" % [key, _inst.has_node("ScreenBackground"), _inst.has_node("ArcadeCRTOverlay"), _hazard_count()])
		_inst.free()
		_inst = null
		_i += 1
	return false

func _hazard_count() -> int:
	if _inst == null:
		return -1
	var mh = _inst.get("active_moving_hazards")
	if mh is Array:
		return (mh as Array).size()
	return -1

func _breaker_probe() -> String:
	var lit_before: int = (_inst.get("lit_cells") as Dictionary).size()
	var cps: Array = _inst.get("collectible_positions")
	var active := str(_inst.get("active_area_id"))
	for ref in cps:
		var parts := str(ref).split(":")
		if parts.size() == 2 and parts[0] == active:
			var xy := parts[1].split(",")
			if xy.size() == 2:
				_inst.call("_try_collect", Vector2i(int(xy[0]), int(xy[1])))
				break
	var lit_after: int = (_inst.get("lit_cells") as Dictionary).size()
	return "lit_cells %d -> %d after collecting a fuse" % [lit_before, lit_after]

func _dump(out: Array) -> void:
	print("\n=== ADVENTURE SMOKE TEST ===")
	for l in out:
		print("  " + str(l))
	print("=== END SMOKE ===")
