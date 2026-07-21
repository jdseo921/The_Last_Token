extends SceneTree
# Behavior test for the Security Tape Assembly beat:
#   correct order completes the tape, and acknowledging the timestampless
#   anomaly frame seats the echo flag the Staff Room reprise reads.
# Run: godot --headless --script res://tools/test_tape_echo_flow.gd --path <project>

var _tape: Node = null
var _frame := 0
var _fails := 0

func _process(_delta: float) -> bool:
	if _tape == null:
		var tape_scene = load("res://scenes/minigames/SecurityTapeAssembly.tscn")
		_tape = tape_scene.instantiate()
		root.add_child(_tape)
		return false
	_frame += 1
	if _frame < 4:
		return false
	print("\n=== TAPE ECHO FLOW TEST ===")
	var gs = root.get_node("GameState")
	var constants: Dictionary = _tape.get_script().get_script_constant_map()
	var correct_order: Array = constants.get("CORRECT_ORDER", [])
	var anomaly_text: String = str(constants.get("ANOMALY_TEXT", ""))
	_check("tape defines a four frame order", correct_order.size() == 4)
	_check("tape defines the timestampless frame", anomaly_text != "")

	# 1. the anomaly frame is never part of a winning order
	_check("anomaly frame excluded from the answer", not correct_order.has(anomaly_text))

	# 2. seating the anomaly frame is rejected and counted, not accepted
	gs.set("security_tape_assembly_completed", false)
	gs.set("tape_anomaly_frame_seen", false)
	_tape.set("anomaly_acknowledged", false)
	var selected: Array = _tape.get("selected_fragments")
	selected.clear()
	for index in range(3):
		selected.append(correct_order[index])
	selected.append(anomaly_text)
	_tape.call("_on_submit_pressed")
	_check("anomaly submission rejected", bool(gs.get("security_tape_assembly_completed")) == false)
	_check("anomaly acknowledged by the attempt", bool(_tape.get("anomaly_acknowledged")) == true)

	# 3. the correct order completes the tape and, because the player looked at
	# the timestampless frame, seats the reveal reprise flag
	selected = _tape.get("selected_fragments")
	selected.clear()
	for fragment in correct_order:
		selected.append(fragment)
	_tape.call("_on_submit_pressed")
	_check("tape completes", bool(gs.get("security_tape_assembly_completed")) == true)
	_check("echo flag set from anomaly", bool(gs.get("tape_anomaly_frame_seen")) == true)

	if _fails == 0:
		print("TAPE ECHO FLOW: PASS")
	else:
		print("TAPE ECHO FLOW: FAIL (%d)" % _fails)
	print("=== END TAPE ECHO FLOW ===")
	quit(1 if _fails > 0 else 0)
	return true

func _check(label: String, ok: bool) -> void:
	print("  [%s] %s" % ["PASS" if ok else "FAIL", label])
	if not ok:
		_fails += 1
