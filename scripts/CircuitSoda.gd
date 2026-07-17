extends Control

const TILE_SHEET_PATH := "res://assets/art/minigames/circuit_soda/circuit_soda_tiles_sheet.png"
const ARCADE_JUICE := preload("res://scripts/ArcadeJuice.gd")

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
# How many clockwise art turns point a socket's opening at a given side
# (frames 4/5 open toward S at rot 0).
const SOCKET_ROT_FOR_SIDE := {
	SIDE_S: 0,
	SIDE_W: 1,
	SIDE_N: 2,
	SIDE_E: 3,
}

# Levels. INPUT/OUTPUT are fixed sockets: the flow leaves the input through
# "input_exit" and must enter the output through "output_enter". "locked"
# tiles cannot be rotated; "blocker" tiles pass nothing.
const ROUNDS: Array[Dictionary] = [
	{
		"title": "Round 1 / 4",
		"hint": "Turn the middle pipe until the row flows straight across.",
		"cols": 3, "rows": 3,
		"input": Vector2i(0, 1), "input_exit": SIDE_E,
		"output": Vector2i(2, 1), "output_enter": SIDE_W,
		"tiles": [
			{"shape": "corner", "rot": 0}, {"shape": "straight", "rot": 1}, {"shape": "corner", "rot": 1},
			{}, {"shape": "straight", "rot": 1}, {},
			{"shape": "corner", "rot": 3}, {"shape": "straight", "rot": 0}, {"shape": "corner", "rot": 2},
		],
	},
	{
		"title": "Round 2 / 4",
		"hint": "The blocker seals the middle. Route the soda around the bottom.",
		"cols": 3, "rows": 3,
		"input": Vector2i(0, 0), "input_exit": SIDE_S,
		"output": Vector2i(2, 1), "output_enter": SIDE_S,
		"tiles": [
			{}, {"shape": "straight", "rot": 0}, {"shape": "corner", "rot": 2},
			{"shape": "straight", "rot": 0}, {"shape": "blocker", "rot": 0}, {},
			{"shape": "corner", "rot": 2}, {"shape": "straight", "rot": 0, "locked": true}, {"shape": "corner", "rot": 0},
		],
	},
	{
		"title": "Round 3 / 4",
		"hint": "The middle is sealed. Ride the top edge over the blocker.",
		"cols": 3, "rows": 3,
		"input": Vector2i(0, 1), "input_exit": SIDE_N,
		"output": Vector2i(2, 1), "output_enter": SIDE_N,
		"tiles": [
			{"shape": "corner", "rot": 2}, {"shape": "straight", "rot": 0, "locked": true}, {"shape": "corner", "rot": 3},
			{}, {"shape": "blocker", "rot": 0}, {},
			{"shape": "corner", "rot": 0}, {"shape": "straight", "rot": 1}, {"shape": "corner", "rot": 3},
		],
	},
	{
		"title": "Round 4 / 4",
		"hint": "Two blockers, two sealed plates. Snake it: right, down, back, down, right.",
		"cols": 3, "rows": 3,
		"input": Vector2i(0, 0), "input_exit": SIDE_E,
		"output": Vector2i(2, 2), "output_enter": SIDE_W,
		"tiles": [
			{}, {"shape": "straight", "rot": 0, "locked": true}, {"shape": "corner", "rot": 3},
			{"shape": "blocker", "rot": 0}, {"shape": "corner", "rot": 2}, {"shape": "corner", "rot": 0},
			{"shape": "blocker", "rot": 0}, {"shape": "corner", "rot": 1}, {},
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
var grid_cols := 3
var grid_rows := 3
var tiles: Array[Dictionary] = []
var tile_buttons: Array[Button] = []
var tile_sheet_texture: Texture2D = null
var tile_sheet_image: Image = null
var rotated_tile_cache: Dictionary = {}
var feedback_flash: ColorRect = null

func _ready() -> void:
	AudioManager.play_music_for_context("circuit_soda")
	ArcadeScreen.apply(self, "res://assets/art/minigames/circuit_soda/backgrounds/circuit_soda_screen.svg")
	reset_button.pressed.connect(_reset_round)
	hint_button.pressed.connect(_show_hint)
	exit_button.pressed.connect(_on_exit_pressed)
	tile_sheet_texture = _load_texture(TILE_SHEET_PATH)
	_setup_feedback_flash()
	_start_round(0)

func _create_grid_buttons() -> void:
	tile_buttons.clear()
	for child in grid.get_children():
		child.queue_free()
	grid.columns = grid_cols
	var button_size := Vector2(88, 56) if grid_cols <= 3 else Vector2(68, 52)
	for index in range(grid_cols * grid_rows):
		var button := Button.new()
		button.custom_minimum_size = button_size
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
	grid_cols = int(round_data.get("cols", 3))
	grid_rows = int(round_data.get("rows", 3))
	_create_grid_buttons()
	tiles = []
	for tile in round_data["tiles"]:
		var tile_data: Dictionary = tile
		tiles.append(tile_data.duplicate(true))
	# Fixed sockets live in the grid as immovable tiles.
	tiles[_index_from_pos(round_data["input"])] = {"shape": "input", "side": str(round_data["input_exit"])}
	tiles[_index_from_pos(round_data["output"])] = {"shape": "output", "side": str(round_data["output_enter"])}
	round_label.text = str(round_data["title"])
	instruction_label.text = "CIRCUIT SODA\nRotate the pipes to link INPUT to OUTPUT.\nSealed plates and blockers do not turn.\nDo not spill identity."
	memory_signal_label.text = "Line Pressure: Nominal"
	status_label.text = "Route the soda from INPUT to OUTPUT."
	_refresh_grid()
	_check_win()

func _on_tile_pressed(index: int) -> void:
	if completed or index < 0 or index >= tiles.size():
		return
	var tile := tiles[index]
	var shape := str(tile.get("shape", ""))
	if shape == "blocker":
		status_label.text = "BLOCKER: no beverage or identity may pass."
		_play_audio("play_error_buzz")
		ARCADE_JUICE.flash_overlay(self, feedback_flash, ARCADE_JUICE.FLASH_RED, 0.28)
		return
	if shape == "input" or shape == "output":
		status_label.text = "The socket is welded in place. Route to it."
		_play_audio("play_error_buzz")
		return
	if bool(tile.get("locked", false)):
		status_label.text = "SEALED PLATE: this pipe does not turn."
		_play_audio("play_error_buzz")
		ARCADE_JUICE.flash_overlay(self, feedback_flash, ARCADE_JUICE.FLASH_RED, 0.2)
		return
	ARCADE_JUICE.pulse_control(self, tile_buttons[index])
	_play_audio("play_button_pulse")
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
	ARCADE_JUICE.pulse_control(self, reset_button)
	_play_audio("play_button_pulse")
	_start_round(current_round)

func _show_hint() -> void:
	ARCADE_JUICE.pulse_control(self, hint_button)
	_play_audio("play_score_blip")
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
	_play_audio("play_score_blip")
	ARCADE_JUICE.flash_overlay(self, feedback_flash, ARCADE_JUICE.FLASH_CYAN, 0.22)
	status_label.text = "MEMORY FLOW ACCEPTED."
	await get_tree().create_timer(0.75).timeout
	_start_round(current_round + 1)

func _complete_puzzle() -> void:
	completed = true
	GameState.complete_circuit_soda()
	memory_signal_label.text = "Line Pressure: Carbonated"
	round_label.text = "CIRCUIT SODA COMPLETE"
	instruction_label.text = "MEMORY FLOW RESTORED.\nCARBONATION LEVEL: UNRELATED.\nIDENTITY SIGNAL ROUTED."
	status_label.text = "Fractured signal stabilized."
	reset_button.visible = false
	hint_button.visible = false
	exit_button.visible = true
	exit_button.grab_focus()
	_play_audio("play_success_jingle")
	ARCADE_JUICE.flash_overlay(self, feedback_flash, ARCADE_JUICE.FLASH_CYAN, 0.34)
	_refresh_grid()

func _has_connected_path() -> bool:
	# What you see is what routes: flow leaves the INPUT socket through its
	# visible opening and wins the moment it enters the OUTPUT socket through
	# the OUTPUT's visible opening.
	var round_data := ROUNDS[current_round]
	var input_pos: Vector2i = round_data["input"]
	var output_pos: Vector2i = round_data["output"]
	var output_enter := str(round_data["output_enter"])
	var queue: Array[Vector2i] = [input_pos]
	var visited := {}
	visited[input_pos] = true
	while not queue.is_empty():
		var pos: Vector2i = queue.pop_front()
		for side in _get_tile_connections(_index_from_pos(pos)):
			var next_pos: Vector2i = pos + DIRS[side]
			if not _pos_in_grid(next_pos):
				continue
			if next_pos == output_pos:
				if str(OPPOSITE[side]) == output_enter:
					return true
				continue
			var next_index := _index_from_pos(next_pos)
			if not _tile_has_side(next_index, str(OPPOSITE[side])):
				continue
			if visited.has(next_pos):
				continue
			visited[next_pos] = true
			queue.append(next_pos)
	return false

func _refresh_grid() -> void:
	for index in range(tile_buttons.size()):
		var button := tile_buttons[index]
		var tile := tiles[index]
		var shape := str(tile.get("shape", ""))
		if tile_sheet_texture != null:
			button.icon = _get_tile_icon(tile)
			button.text = _get_compact_tile_text(tile)
		else:
			button.icon = null
			button.text = _get_tile_text(tile)
		button.disabled = completed or shape == "blocker" or shape == "input" or shape == "output"
		if bool(tile.get("locked", false)):
			button.modulate = Color(0.78, 0.82, 0.9, 1.0)
			button.tooltip_text = "Sealed plate - does not turn."
		else:
			button.modulate = Color.WHITE
			button.tooltip_text = ""

func _get_tile_text(tile: Dictionary) -> String:
	var shape := str(tile.get("shape", ""))
	match shape:
		"blocker":
			return "BLOCK"
		"input":
			return "INPUT"
		"output":
			return "OUTPUT"
		"":
			return ""
	var label := _format_sides(_get_connections_for_tile(tile))
	if bool(tile.get("locked", false)):
		label += "\nSEALED"
	return label

func _get_compact_tile_text(tile: Dictionary) -> String:
	var shape := str(tile.get("shape", ""))
	match shape:
		"blocker":
			return "BLOCK"
		"input":
			return "INPUT"
		"output":
			return "OUTPUT"
		"":
			return ""
	if bool(tile.get("locked", false)):
		return "SEALED"
	return _format_sides(_get_connections_for_tile(tile))

func _get_tile_icon(tile: Dictionary) -> Texture2D:
	var shape := str(tile.get("shape", ""))
	var rot := int(tile.get("rot", 0)) % 4
	match shape:
		"input":
			return _get_rotated_tile(4, int(SOCKET_ROT_FOR_SIDE.get(str(tile.get("side", SIDE_S)), 0)))
		"output":
			return _get_rotated_tile(5, int(SOCKET_ROT_FOR_SIDE.get(str(tile.get("side", SIDE_S)), 0)))
		"straight":
			return _get_rotated_tile(0, rot)
		"corner":
			return _get_rotated_tile(1, rot)
		"junction":
			return _get_rotated_tile(2, rot)
		"blocker":
			return _get_tile_atlas(3)
		_:
			return null

func _get_rotated_tile(frame_index: int, rot: int) -> Texture2D:
	# Rotate the pipe sprite itself so a click visibly turns the pipe; the
	# connection tables below are keyed to the drawn art, so what you see is
	# exactly what the flow check evaluates.
	if rot == 0:
		return _get_tile_atlas(frame_index)
	var key := frame_index * 10 + rot
	if rotated_tile_cache.has(key):
		return rotated_tile_cache[key]
	if tile_sheet_image == null:
		tile_sheet_image = tile_sheet_texture.get_image()
		if tile_sheet_image == null:
			return _get_tile_atlas(frame_index)
		if tile_sheet_image.is_compressed():
			tile_sheet_image.decompress()
	var frame_width := maxi(int(tile_sheet_image.get_width() / 6), 1)
	var region := tile_sheet_image.get_region(Rect2i(frame_index * frame_width, 0, frame_width, tile_sheet_image.get_height()))
	for i in range(rot):
		region.rotate_90(CLOCKWISE)
	var texture := ImageTexture.create_from_image(region)
	rotated_tile_cache[key] = texture
	return texture

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
	# Base orientations match the DRAWN sprites at rot 0:
	# straight = horizontal (E-W), corner = E-S bend, junction = S-W-N tee.
	var shape := str(tile.get("shape", ""))
	var rot := int(tile.get("rot", 0)) % 4
	match shape:
		"input", "output":
			return [str(tile.get("side", SIDE_S))]
		"straight":
			if rot % 2 == 0:
				return [SIDE_E, SIDE_W]
			return [SIDE_N, SIDE_S]
		"corner":
			match rot:
				0:
					return [SIDE_E, SIDE_S]
				1:
					return [SIDE_S, SIDE_W]
				2:
					return [SIDE_W, SIDE_N]
				_:
					return [SIDE_N, SIDE_E]
		"junction":
			match rot:
				0:
					return [SIDE_S, SIDE_W, SIDE_N]
				1:
					return [SIDE_W, SIDE_N, SIDE_E]
				2:
					return [SIDE_N, SIDE_E, SIDE_S]
				_:
					return [SIDE_E, SIDE_S, SIDE_W]
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
	return pos.x >= 0 and pos.x < grid_cols and pos.y >= 0 and pos.y < grid_rows

func _index_from_pos(pos: Vector2i) -> int:
	return pos.y * grid_cols + pos.x

func _pos_from_index(index: int) -> Vector2i:
	return Vector2i(index % grid_cols, int(index / grid_cols))

func _on_exit_pressed() -> void:
	ARCADE_JUICE.pulse_control(self, exit_button)
	_play_audio("play_button_pulse")
	SceneChanger.go_to_snack_alcove()

func _setup_feedback_flash() -> void:
	feedback_flash = ColorRect.new()
	feedback_flash.name = "ArcadeFeedbackFlash"
	feedback_flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	feedback_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	feedback_flash.visible = false
	feedback_flash.z_index = 80
	add_child(feedback_flash)

func _play_audio(method_name: String) -> void:
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager and audio_manager.has_method(method_name):
		audio_manager.call(method_name)
