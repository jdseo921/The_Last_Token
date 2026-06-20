extends Control

const TILE_SHEET_PATH := "res://assets/art/minigames/circuit_soda/circuit_soda_tiles_sheet.png"

const GRID_SIZE := 3
const SIDE_N := "N"
const SIDE_E := "E"
const SIDE_S := "S"
const SIDE_W := "W"
const OPPOSITE := {
	SIDE_N: SIDE_S,
	SIDE_E: SIDE_W,
	SIDE_S: SIDE_N,
	SIDE_W: SIDE_E,
}
const DIRS := {
	SIDE_N: Vector2i(0, -1),
	SIDE_E: Vector2i(1, 0),
	SIDE_S: Vector2i(0, 1),
	SIDE_W: Vector2i(-1, 0),
}

const ROUNDS: Array[Dictionary] = [
	{
		"title": "Round 1 / 3",
		"hint": "Make the middle row flow left to right.",
		"input": Vector2i(0, 1),
		"output": Vector2i(2, 1),
		"tiles": [
			{"shape": "corner", "rot": 0}, {"shape": "straight", "rot": 0}, {"shape": "corner", "rot": 1},
			{"shape": "straight", "rot": 0}, {"shape": "straight", "rot": 0}, {"shape": "straight", "rot": 0},
			{"shape": "corner", "rot": 3}, {"shape": "straight", "rot": 0}, {"shape": "corner", "rot": 2},
		],
	},
	{
		"title": "Round 2 / 3",
		"hint": "The blocker forces the signal around the bottom.",
		"input": Vector2i(0, 0),
		"output": Vector2i(2, 1),
		"tiles": [
			{"shape": "corner", "rot": 0}, {"shape": "straight", "rot": 1}, {"shape": "corner", "rot": 2},
			{"shape": "straight", "rot": 1}, {"shape": "blocker", "rot": 0}, {"shape": "corner", "rot": 2},
			{"shape": "corner", "rot": 3}, {"shape": "straight", "rot": 0}, {"shape": "corner", "rot": 0},
		],
	},
	{
		"title": "Round 3 / 3",
		"hint": "Only the lower route reaches Restore Output.",
		"input": Vector2i(0, 1),
		"output": Vector2i(2, 2),
		"tiles": [
			{"shape": "corner", "rot": 1}, {"shape": "straight", "rot": 0}, {"shape": "corner", "rot": 2},
			{"shape": "junction", "rot": 1}, {"shape": "straight", "rot": 0}, {"shape": "corner", "rot": 3},
			{"shape": "corner", "rot": 3}, {"shape": "straight", "rot": 0}, {"shape": "corner", "rot": 0},
		],
	},
]

@onready var round_label: Label = $MainPanel/InfoPanel/RoundLabel
@onready var instruction_label: Label = $MainPanel/InfoPanel/InstructionLabel
@onready var memory_signal_label: Label = $MainPanel/InfoPanel/MemorySignalLabel
@onready var status_label: Label = $MainPanel/StatusPanel/StatusLabel
@onready var grid: GridContainer = $MainPanel/GridPanel/Grid
@onready var reset_button: Button = $MainPanel/ButtonRow/ResetButton
@onready var hint_button: Button = $MainPanel/ButtonRow/HintButton
@onready var exit_button: Button = $MainPanel/ButtonRow/ExitButton

var current_round := 0
var moves_this_round := 0
var completed := false
var tiles: Array[Dictionary] = []
var tile_buttons: Array[Button] = []
var tile_sheet_texture: Texture2D = null

func _ready() -> void:
	reset_button.pressed.connect(_reset_round)
	hint_button.pressed.connect(_show_hint)
	exit_button.pressed.connect(_on_exit_pressed)
	tile_sheet_texture = _load_texture(TILE_SHEET_PATH)
	_create_grid_buttons()
	_start_round(0)

func _create_grid_buttons() -> void:
	tile_buttons.clear()
	for child in grid.get_children():
		child.queue_free()
	for index in range(GRID_SIZE * GRID_SIZE):
		var button := Button.new()
		button.custom_minimum_size = Vector2(96, 64)
		button.focus_mode = Control.FOCUS_ALL
		button.expand_icon = false
		button.pressed.connect(_on_tile_pressed.bind(index))
		grid.add_child(button)
		tile_buttons.append(button)

func _start_round(round_index: int) -> void:
	current_round = round_index
	moves_this_round = 0
	completed = false
	exit_button.visible = false
	reset_button.visible = true
	hint_button.visible = true
	hint_button.disabled = true
	var round_data := ROUNDS[current_round]
	tiles = []
	for tile in round_data["tiles"]:
		var tile_data: Dictionary = tile
		tiles.append(tile_data.duplicate(true))
	round_label.text = str(round_data["title"])
	instruction_label.text = "CIRCUIT SODA\nRotate the pipes.\nConnect Memory Input to Restore Output.\nDo not spill identity."
	memory_signal_label.text = "Memory Signal: %s" % GameState.get_memory_signal_label()
	status_label.text = "Route Memory Input to Restore Output."
	_refresh_grid()
	_check_win()

func _on_tile_pressed(index: int) -> void:
	if completed or index < 0 or index >= tiles.size():
		return
	var tile := tiles[index]
	if str(tile.get("shape", "")) == "blocker":
		status_label.text = "BLOCKER: no beverage or identity may pass."
		return
	tile["rot"] = (int(tile.get("rot", 0)) + 1) % 4
	moves_this_round += 1
	if moves_this_round >= 4:
		hint_button.disabled = false
	_refresh_grid()
	if not _has_connected_path():
		status_label.text = "Signal still misrouted."
	_check_win()

func _reset_round() -> void:
	if completed:
		return
	_start_round(current_round)

func _show_hint() -> void:
	status_label.text = str(ROUNDS[current_round]["hint"])

func _check_win() -> void:
	if not _has_connected_path():
		return
	await get_tree().create_timer(0.25).timeout
	if completed:
		return
	if current_round + 1 >= ROUNDS.size():
		_complete_puzzle()
		return
	status_label.text = "MEMORY FLOW ACCEPTED."
	await get_tree().create_timer(0.75).timeout
	_start_round(current_round + 1)

func _complete_puzzle() -> void:
	completed = true
	GameState.complete_circuit_soda()
	memory_signal_label.text = "Memory Signal: %s" % GameState.get_memory_signal_label()
	round_label.text = "CIRCUIT SODA COMPLETE"
	instruction_label.text = "MEMORY FLOW RESTORED.\nCARBONATION LEVEL: UNRELATED.\nIDENTITY SIGNAL ROUTED."
	status_label.text = "Fractured signal stabilized."
	reset_button.visible = false
	hint_button.visible = false
	exit_button.visible = true
	exit_button.grab_focus()
	_play_audio("play_token_get")

func _has_connected_path() -> bool:
	var round_data := ROUNDS[current_round]
	var input_pos: Vector2i = round_data["input"]
	var output_pos: Vector2i = round_data["output"]
	var input_index := _index_from_pos(input_pos)
	if not _tile_has_side(input_index, SIDE_W):
		return false
	var queue: Array[Vector2i] = [input_pos]
	var visited := {}
	visited[input_pos] = true
	while not queue.is_empty():
		var pos: Vector2i = queue.pop_front()
		var index := _index_from_pos(pos)
		if pos == output_pos and _tile_has_side(index, SIDE_E):
			return true
		for side in _get_tile_connections(index):
			var next_pos: Vector2i = pos + DIRS[side]
			if not _pos_in_grid(next_pos):
				continue
			var next_index := _index_from_pos(next_pos)
			var opposite_side: String = OPPOSITE[side]
			if not _tile_has_side(next_index, opposite_side):
				continue
			if visited.has(next_pos):
				continue
			visited[next_pos] = true
			queue.append(next_pos)
	return false

func _refresh_grid() -> void:
	var round_data := ROUNDS[current_round]
	var input_pos: Vector2i = round_data["input"]
	var output_pos: Vector2i = round_data["output"]
	for index in range(tile_buttons.size()):
		var button := tile_buttons[index]
		var pos := _pos_from_index(index)
		var tile := tiles[index]
		var text := _get_tile_text(tile)
		if pos == input_pos:
			text = "INPUT\n%s" % text
		elif pos == output_pos:
			text = "%s\nOUTPUT" % text
		if tile_sheet_texture != null:
			button.icon = _get_tile_icon(tile, pos, input_pos, output_pos)
			button.text = _get_compact_tile_text(tile, pos, input_pos, output_pos)
		else:
			button.icon = null
			button.text = text
		button.disabled = completed or str(tile.get("shape", "")) == "blocker"

func _get_tile_text(tile: Dictionary) -> String:
	var shape := str(tile.get("shape", "blocker"))
	if shape == "blocker":
		return "BLOCK"
	var sides := _get_connections_for_tile(tile)
	return "%s\n%s" % [shape.to_upper(), _format_sides(sides)]

func _get_compact_tile_text(tile: Dictionary, pos: Vector2i, input_pos: Vector2i, output_pos: Vector2i) -> String:
	if pos == input_pos:
		return "INPUT"
	if pos == output_pos:
		return "OUTPUT"
	var shape := str(tile.get("shape", "blocker"))
	if shape == "blocker":
		return "BLOCK"
	return _format_sides(_get_connections_for_tile(tile))

func _get_tile_icon(tile: Dictionary, pos: Vector2i, input_pos: Vector2i, output_pos: Vector2i) -> Texture2D:
	if pos == input_pos:
		return _get_tile_atlas(4)
	if pos == output_pos:
		return _get_tile_atlas(5)
	match str(tile.get("shape", "blocker")):
		"straight":
			return _get_tile_atlas(0)
		"corner":
			return _get_tile_atlas(1)
		"junction":
			return _get_tile_atlas(2)
		_:
			return _get_tile_atlas(3)

func _get_tile_atlas(frame_index: int) -> AtlasTexture:
	var frame_width := maxi(int(tile_sheet_texture.get_width() / 6), 1)
	var atlas := AtlasTexture.new()
	atlas.atlas = tile_sheet_texture
	atlas.region = Rect2(frame_index * frame_width, 0, frame_width, tile_sheet_texture.get_height())
	return atlas

func _load_texture(path: String) -> Texture2D:
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	var resource := load(path)
	if resource is Texture2D:
		return resource
	return null

func _get_tile_connections(index: int) -> Array:
	if index < 0 or index >= tiles.size():
		return []
	return _get_connections_for_tile(tiles[index])

func _get_connections_for_tile(tile: Dictionary) -> Array:
	var shape := str(tile.get("shape", "blocker"))
	var rot := int(tile.get("rot", 0)) % 4
	match shape:
		"straight":
			if rot % 2 == 0:
				return [SIDE_N, SIDE_S]
			return [SIDE_E, SIDE_W]
		"corner":
			match rot:
				0:
					return [SIDE_N, SIDE_E]
				1:
					return [SIDE_E, SIDE_S]
				2:
					return [SIDE_S, SIDE_W]
				_:
					return [SIDE_W, SIDE_N]
		"junction":
			match rot:
				0:
					return [SIDE_E, SIDE_S, SIDE_W]
				1:
					return [SIDE_S, SIDE_W, SIDE_N]
				2:
					return [SIDE_W, SIDE_N, SIDE_E]
				_:
					return [SIDE_N, SIDE_E, SIDE_S]
		_:
			return []

func _tile_has_side(index: int, side: String) -> bool:
	return _get_tile_connections(index).has(side)

func _format_sides(sides: Array) -> String:
	var side_names: Array[String] = []
	for side in sides:
		side_names.append(str(side))
	return "-".join(side_names)

func _pos_in_grid(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < GRID_SIZE and pos.y >= 0 and pos.y < GRID_SIZE

func _index_from_pos(pos: Vector2i) -> int:
	return pos.y * GRID_SIZE + pos.x

func _pos_from_index(index: int) -> Vector2i:
	return Vector2i(index % GRID_SIZE, int(index / GRID_SIZE))

func _on_exit_pressed() -> void:
	_play_audio("play_ui_confirm")
	SceneChanger.go_to_snack_alcove()

func _play_audio(method_name: String) -> void:
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager and audio_manager.has_method(method_name):
		audio_manager.call(method_name)
