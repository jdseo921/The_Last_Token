extends SceneTree
# Headless runtime smoke test with frame-stepping (diagnostic).
#   godot --headless --script res://tools/smoke_minigames.gd --path <project>

var _out: Array = []
var _targets := [
	["RockbyteDuel", "res://scenes/minigames/RockbyteDuel.tscn"],
	["TruthFilter", "res://scenes/minigames/TruthFilter.tscn"],
	["CircuitSoda", "res://scenes/minigames/CircuitSoda.tscn"],
	["SyncDoorPuzzle", "res://scenes/arcade/SyncDoorPuzzle.tscn"],
	["SecurityTapeAssembly", "res://scenes/minigames/SecurityTapeAssembly.tscn"],
	["MemoryEcho", "res://scenes/cutscenes/MemoryEcho.tscn"],
]
var _i := 0
var _inst: Node = null
var _frame := 0

func _initialize() -> void:
	_out.append("Autoloads: AudioManager=%s GameState=%s inside_tree=%s" % [root.has_node("AudioManager"), root.has_node("GameState"), root.is_inside_tree()])

func _process(_delta: float) -> bool:
	if _inst == null:
		if _i >= _targets.size():
			_dump(_out)
			return true
		var key = _targets[_i][0]
		var ps = load(_targets[_i][1])
		if ps == null:
			_out.append("%s: LOAD FAILED" % key)
			_i += 1
			return false
		_inst = ps.instantiate()
		root.add_child(_inst)
		_frame = 0
		_out.append("%s: [immediate] scan=%s children=%s" % [key, _inst.has_node("ArcadeScanlines"), _child_names(_inst)])
		return false
	_frame += 1
	if _frame >= 2:
		var key = _targets[_i][0]
		_out.append("%s: [+%d fr] scan=%s crt=%s bg=%s bgtex=%s" % [key, _frame, _inst.has_node("ArcadeScanlines"), _inst.has_node("ArcadeCRTOverlay"), _deep_has(_inst, "ArcadeBackground"), _bgtex_visible(_inst)])
		_inst.free()
		_inst = null
		_i += 1
	return false

func _child_names(n: Node) -> String:
	var names: Array = []
	for c in n.get_children():
		names.append(str(c.name))
	return str(names)

func _deep_has(node: Node, nm: String) -> bool:
	if node.has_node(nm):
		return true
	for c in node.get_children():
		if c is CanvasLayer and c.has_node(nm):
			return true
	return false

func _bgtex_visible(node: Node) -> bool:
	var bl = node.get_node_or_null("BackgroundLayer")
	if bl == null:
		return false
	var bt = bl.get_node_or_null("BackgroundTexture")
	return bt != null and bt is CanvasItem and (bt as CanvasItem).visible

func _dump(out: Array) -> void:
	print("\n=== MINIGAME SMOKE TEST ===")
	for l in out:
		print("  " + str(l))
	print("=== END SMOKE ===")
