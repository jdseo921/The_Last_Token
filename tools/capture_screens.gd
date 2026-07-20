extends SceneTree
# Rendered-screenshot harness (requires a real window — do NOT run --headless).
#   godot --path <project> --script res://tools/capture_screens.gd
# Loads each stage scene, waits for _ready + a few drawn frames, saves a PNG of
# the actual composited viewport, then quits. Output dir: user://captures/.

const SETTLE_FRAMES := 75

var _targets := [
	["title_main", "res://scenes/main/Main.tscn"],
	["rockbyte_duel", "res://scenes/minigames/RockbyteDuel.tscn"],
	["broken_high_score", "res://scenes/minigames/BrokenHighScore.tscn"],
	["truth_filter", "res://scenes/minigames/TruthFilter.tscn"],
	["circuit_soda", "res://scenes/minigames/CircuitSoda.tscn"],
	["sync_door", "res://scenes/arcade/SyncDoorPuzzle.tscn"],
	["security_tape", "res://scenes/minigames/SecurityTapeAssembly.tscn"],
	["memory_echo", "res://scenes/cutscenes/MemoryEcho.tscn"],
	["static_service_run", "res://scenes/minigames/StaticServiceRun.tscn"],
	["final_night_walk", "res://scenes/minigames/FinalNightWalk.tscn"],
]
var _i := 0
var _inst: Node = null
var _frame := 0
var _results: Array = []

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute("user://captures")

func _process(_delta: float) -> bool:
	if _inst == null:
		if _i >= _targets.size():
			print("\n=== CAPTURE RESULTS ===")
			for r in _results:
				print("  " + str(r))
			print("Saved under: " + ProjectSettings.globalize_path("user://captures"))
			print("=== END CAPTURE ===")
			return true
		var ps = load(_targets[_i][1])
		if ps == null:
			_results.append("%s: LOAD FAILED" % _targets[_i][0])
			_i += 1
			return false
		_inst = ps.instantiate()
		root.add_child(_inst)
		_frame = 0
		return false
	_frame += 1
	if _frame >= SETTLE_FRAMES:
		var key: String = _targets[_i][0]
		var img := root.get_texture().get_image()
		if img != null:
			var path := "user://captures/%s.png" % key
			var err := img.save_png(path)
			_results.append("%s: %s (%dx%d)" % [key, "OK" if err == OK else "SAVE ERR %d" % err, img.get_width(), img.get_height()])
		else:
			_results.append("%s: NO IMAGE" % key)
		_inst.free()
		_inst = null
		_i += 1
	return false
