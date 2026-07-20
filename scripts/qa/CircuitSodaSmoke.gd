extends SceneTree

const CIRCUIT_SODA_SCENE_PATH := "res://scenes/minigames/CircuitSoda.tscn"
const ADVANCED_TILE_SHEET_PATH := "res://assets/art/minigames/circuit_soda/circuit_soda_advanced_tiles_sheet.png"

const SOLUTION_ROTATIONS: Array[Dictionary] = [
	{2: 1, 10: 3},
	{1: 0, 3: 1},
	{7: 1, 9: 3, 11: 2},
	{1: 0, 2: 1, 7: 2, 9: 2},
]

const TERMINAL_CONNECTION_COUNTS := [
	Vector2i(2, 1),
	Vector2i(1, 2),
	Vector2i(3, 2),
	Vector2i(2, 3),
]

const MINIMUM_FIXED_PIPE_COUNTS := [3, 4, 3, 4]

var failures: Array[String] = []
var puzzle: Control = null

func _initialize() -> void:
	var circuit_soda_scene := load(CIRCUIT_SODA_SCENE_PATH) as PackedScene
	if circuit_soda_scene == null:
		print("FAIL: Circuit Soda scene did not load.")
		quit(1)
		return
	puzzle = circuit_soda_scene.instantiate()
	root.add_child(puzzle)
	call_deferred("_run_checks")

func _run_checks() -> void:
	_expect(ResourceLoader.exists(ADVANCED_TILE_SHEET_PATH), "Advanced generated tile sheet is missing.")
	var info_panel := puzzle.get_node("MainPanel/InfoPanel") as Control
	var grid_panel := puzzle.get_node("MainPanel/GridPanel") as Control
	var status_panel := puzzle.get_node("MainPanel/StatusPanel") as Control
	var button_row := puzzle.get_node("MainPanel/ButtonRow") as Control
	_expect(info_panel.position.y <= 44.0, "Info panel was not raised below the fixed title.")
	_expect(grid_panel.position.y <= 136.0, "Puzzle grid was not raised with the info panel.")
	_expect(status_panel.position.y <= 334.0, "Status panel remains too low.")
	_expect(button_row.position.y <= 366.0 and button_row.position.y + button_row.size.y <= 396.0, "Reset and Hint remain too close to the lower edge.")
	for round_index in range(SOLUTION_ROTATIONS.size()):
		puzzle.call("_start_round", round_index)
		_expect(puzzle.get("grid_cols") == 4 and puzzle.get("grid_rows") == 3, "Round %d is not 4x3." % [round_index + 1])
		_expect(not bool(puzzle.call("_has_connected_path")), "Round %d starts already solved." % [round_index + 1])
		_check_terminal_counts(round_index)
		_check_advanced_and_fixed_tiles(round_index)
		var round_solution: Dictionary = SOLUTION_ROTATIONS[round_index]
		var round_tiles: Array = puzzle.get("tiles")
		for index in round_solution:
			round_tiles[int(index)]["rot"] = int(round_solution[index])
		_expect(bool(puzzle.call("_has_connected_path")), "Round %d known visual route is not accepted." % [round_index + 1])
	_check_solution_input_lock()

	print("\n=== CIRCUIT SODA SMOKE ===")
	if failures.is_empty():
		print("All four advanced 4x3 rounds accept their visually connected route.")
	else:
		for failure in failures:
			print("FAIL: " + failure)
	print("=== END CIRCUIT SODA SMOKE ===")
	puzzle.queue_free()
	await process_frame
	quit(0 if failures.is_empty() else 1)

func _check_terminal_counts(round_index: int) -> void:
	var round_tiles: Array = puzzle.get("tiles")
	var expected: Vector2i = TERMINAL_CONNECTION_COUNTS[round_index]
	var input_connections: Array = []
	var output_connections: Array = []
	for tile in round_tiles:
		var tile_data: Dictionary = tile
		if str(tile_data.get("shape", "")) == "input":
			input_connections = tile_data.get("connections", [])
		elif str(tile_data.get("shape", "")) == "output":
			output_connections = tile_data.get("connections", [])
	_expect(input_connections.size() == expected.x, "Round %d INPUT hose count changed." % [round_index + 1])
	_expect(output_connections.size() == expected.y, "Round %d OUTPUT hose count changed." % [round_index + 1])

func _check_advanced_and_fixed_tiles(round_index: int) -> void:
	var round_tiles: Array = puzzle.get("tiles")
	var fixed_count := 0
	var has_advanced_shape := false
	var first_fixed_index := -1
	var first_cross_index := -1
	for index in range(round_tiles.size()):
		var tile: Dictionary = round_tiles[index]
		var shape := str(tile.get("shape", ""))
		if shape == "cross" or shape == "cap":
			has_advanced_shape = true
		if shape == "cross" and first_cross_index < 0:
			first_cross_index = index
		if bool(tile.get("locked", false)):
			fixed_count += 1
			if first_fixed_index < 0:
				first_fixed_index = index
	_expect(has_advanced_shape, "Round %d has no generated advanced pipe type." % [round_index + 1])
	_expect(fixed_count >= MINIMUM_FIXED_PIPE_COUNTS[round_index], "Round %d lost its fixed-pipe difficulty." % [round_index + 1])
	if first_fixed_index >= 0:
		var before_fixed_rot := int(round_tiles[first_fixed_index].get("rot", 0))
		puzzle.call("_on_tile_pressed", first_fixed_index)
		_expect(int(round_tiles[first_fixed_index].get("rot", 0)) == before_fixed_rot, "Round %d fixed pipe rotated on click." % [round_index + 1])
	if first_cross_index >= 0:
		var before_cross_rot := int(round_tiles[first_cross_index].get("rot", 0))
		puzzle.call("_on_tile_pressed", first_cross_index)
		_expect(int(round_tiles[first_cross_index].get("rot", 0)) == before_cross_rot, "Round %d four-way manifold rotated on click." % [round_index + 1])


func _check_solution_input_lock() -> void:
	puzzle.call("_start_round", 0)
	var round_tiles: Array = puzzle.get("tiles")
	for index in SOLUTION_ROTATIONS[0]:
		round_tiles[int(index)]["rot"] = int(SOLUTION_ROTATIONS[0][index])
	puzzle.call("_check_win")
	_expect(bool(puzzle.get("round_input_locked")), "Circuit Soda locks input as soon as a correct route is detected.")
	var tile_buttons: Array = puzzle.get("tile_buttons")
	for button_value in tile_buttons:
		_expect((button_value as Button).disabled, "Solved Circuit Soda tiles cannot keep spinning during success feedback.")
	var before_rotation := int(round_tiles[2].get("rot", 0))
	puzzle.call("_on_tile_pressed", 2)
	_expect(int(round_tiles[2].get("rot", 0)) == before_rotation, "A solved pipe ignores additional clicks immediately.")

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
