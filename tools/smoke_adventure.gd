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
	if _frame == 2:
		var key = _targets[_i][0]
		_out.append("%s: [ready] screenbg=%s scan=%s crt=%s" % [key, _inst.has_node("ScreenBackground"), _inst.has_node("ArcadeScanlines"), _inst.has_node("ArcadeCRTOverlay")])
		if _inst.has_method("_rebuild_area_view"):
			_inst.call("_rebuild_area_view", "smoke")
		return false
	if _frame >= 4:
		var key2 = _targets[_i][0]
		_out.append("%s: [post-rebuild] screenbg=%s scan=%s crt=%s (overlay must persist)" % [key2, _inst.has_node("ScreenBackground"), _inst.has_node("ArcadeScanlines"), _inst.has_node("ArcadeCRTOverlay")])
		_inst.free()
		_inst = null
		_i += 1
	return false

func _dump(out: Array) -> void:
	print("\n=== ADVENTURE SMOKE TEST ===")
	for l in out:
		print("  " + str(l))
	print("=== END SMOKE ===")
