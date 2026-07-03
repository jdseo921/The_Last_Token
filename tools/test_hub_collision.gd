extends SceneTree
# Verifies the ArcadeHub's runtime-generated wall collision actually blocks a body.
#   godot --headless --script res://tools/test_hub_collision.gd --path <project>

var _out: Array = []
var _hub: Node = null
var _test: CharacterBody2D = null
var _frame := 0
var _start_y := 0.0
var _start_x := 0.0

func _initialize() -> void:
	var ps = load("res://scenes/arcade/ArcadeHub.tscn")
	if ps == null:
		_out.append("HUB LOAD FAILED")
		_dump()
		quit()
		return
	_hub = ps.instantiate()
	root.add_child(_hub)

func _process(_d: float) -> bool:
	if _hub == null:
		_dump(); return true
	_frame += 1
	if _frame == 3:
		var cb = _hub.get_node_or_null("CollisionBounds")
		var bodies := 0
		if cb:
			for c in cb.get_children():
				if c is StaticBody2D:
					bodies += 1
		_out.append("CollisionBounds StaticBody2D built: %d (expect >=9 perimeter)" % bodies)
		_test = CharacterBody2D.new()
		var shape := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = Vector2(12, 14)
		shape.shape = rect
		_test.add_child(shape)
		_hub.add_child(_test)
		_test.global_position = Vector2(320, 70)
		_start_y = _test.global_position.y
		return false
	if _frame > 3 and _frame < 45:
		if _test:
			_test.velocity = Vector2(0, -240)
			_test.move_and_slide()
		return false
	if _frame == 45:
		_out.append("Body pushed UP into top wall (y0-28): start_y=%.1f end_y=%.1f  -> %s" % [
			_start_y, _test.global_position.y,
			"BLOCKED (collision works)" if _test.global_position.y > 30.0 else "PASSED THROUGH (no collision)"])
		_test.global_position = Vector2(300, 220)
		_start_x = _test.global_position.x
		return false
	if _frame > 45 and _frame < 90:
		if _test:
			_test.velocity = Vector2(-240, 0)
			_test.move_and_slide()
		return false
	_out.append("Body pushed LEFT into left wall (x0-16): start_x=%.1f end_x=%.1f  -> %s" % [
		_start_x, _test.global_position.x,
		"BLOCKED (collision works)" if _test.global_position.x < 60.0 and _test.global_position.x > 16.0 else "check"])
	_dump()
	return true

func _dump() -> void:
	print("\n=== HUB COLLISION TEST ===")
	for l in _out:
		print("  " + str(l))
	print("=== END ===")
