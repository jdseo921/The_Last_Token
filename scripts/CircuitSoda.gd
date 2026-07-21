extends Control

const TILE_SHEET_PATH := "res://assets/art/minigames/circuit_soda/circuit_soda_tiles_sheet.png"
const ADVANCED_TILE_SHEET_PATH := "res://assets/art/minigames/circuit_soda/circuit_soda_advanced_tiles_sheet.png"
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
const TERMINAL_INPUT_COLOR := Color(0.0, 0.88, 0.92, 1.0)
const TERMINAL_OUTPUT_COLOR := Color(0.98, 0.08, 0.55, 1.0)
const TERMINAL_BODY_COLOR := Color(0.035, 0.08, 0.1, 1.0)
const TERMINAL_EDGE_COLOR := Color(0.18, 0.28, 0.31, 1.0)
const FIXED_PIPE_COLOR := Color(1.0, 0.62, 0.12, 1.0)

const ADVANCED_CROSS_FRAME := 0
const ADVANCED_CAP_FRAME := 1
const ADVANCED_INPUT_FRAME := 2
const ADVANCED_OUTPUT_FRAME := 3

# Every level is four columns by three rows. INPUT/OUTPUT terminals expose
# exactly the sides listed in "connections"; those same sides are drawn and
# used by path validation. "locked" tiles cannot rotate; blockers pass nothing.
const ROUNDS: Array[Dictionary] = [
	{
		"title": "Round 1 / 4",
		"hint": "Ignore INPUT's capped south hose. Route east, then bend down and east again.",
		"cols": 4, "rows": 3,
		"input": Vector2i(0, 0), "input_connections": [SIDE_E, SIDE_S],
		"output": Vector2i(3, 2), "output_connections": [SIDE_W],
		"tiles": [
			{}, {"shape": "straight", "rot": 0, "locked": true}, {"shape": "corner", "rot": 2}, {"shape": "blocker", "rot": 0},
			{"shape": "cap", "rot": 3, "locked": true}, {"shape": "blocker", "rot": 0}, {"shape": "straight", "rot": 1, "locked": true}, {"shape": "junction", "rot": 3},
			{"shape": "corner", "rot": 1}, {"shape": "cross", "rot": 0}, {"shape": "corner", "rot": 0}, {},
		],
	},
	{
		"title": "Round 2 / 4",
		"hint": "The fixed junction sends flow north. Cross the manifold, then turn south into OUTPUT.",
		"cols": 4, "rows": 3,
		"input": Vector2i(0, 1), "input_connections": [SIDE_E],
		"output": Vector2i(3, 2), "output_connections": [SIDE_W, SIDE_N],
		"tiles": [
			{"shape": "cap", "rot": 0}, {"shape": "corner", "rot": 2}, {"shape": "cross", "rot": 0}, {"shape": "corner", "rot": 3},
			{}, {"shape": "junction", "rot": 0, "locked": true}, {"shape": "cap", "rot": 3, "locked": true}, {"shape": "straight", "rot": 1, "locked": true},
			{"shape": "blocker", "rot": 0}, {"shape": "cap", "rot": 3, "locked": true}, {"shape": "blocker", "rot": 0}, {},
		],
	},
	{
		"title": "Round 3 / 4",
		"hint": "North and east are capped. Leave INPUT south, cross the fixed tee, then climb to OUTPUT.",
		"cols": 4, "rows": 3,
		"input": Vector2i(1, 1), "input_connections": [SIDE_N, SIDE_E, SIDE_S],
		"output": Vector2i(3, 0), "output_connections": [SIDE_S, SIDE_W],
		"tiles": [
			{"shape": "blocker", "rot": 0}, {"shape": "cap", "rot": 1, "locked": true}, {"shape": "corner", "rot": 3}, {},
			{"shape": "cross", "rot": 0}, {}, {"shape": "cap", "rot": 2, "locked": true}, {"shape": "straight", "rot": 0},
			{"shape": "blocker", "rot": 0}, {"shape": "corner", "rot": 1}, {"shape": "junction", "rot": 1, "locked": true}, {"shape": "corner", "rot": 0},
		],
	},
	{
		"title": "Round 4 / 4",
		"hint": "INPUT north is capped. Snake east, north, east, south, east, then north into OUTPUT.",
		"cols": 4, "rows": 3,
		"input": Vector2i(0, 2), "input_connections": [SIDE_N, SIDE_E],
		"output": Vector2i(3, 0), "output_connections": [SIDE_N, SIDE_S, SIDE_W],
		"tiles": [
			{"shape": "blocker", "rot": 0}, {"shape": "corner", "rot": 2}, {"shape": "corner", "rot": 3}, {},
			{"shape": "cap", "rot": 1, "locked": true}, {"shape": "straight", "rot": 1, "locked": true}, {"shape": "junction", "rot": 2, "locked": true}, {"shape": "corner", "rot": 0},
			{}, {"shape": "corner", "rot": 0}, {"shape": "cap", "rot": 3, "locked": true}, {"shape": "blocker", "rot": 0},
		],
	},
]

@onready var round_label: Label = $MainPanel/InfoPanel/RoundLabel
@onready var instruction_label: Label = $MainPanel/InfoPanel/InstructionLabel
@onready var status_label: Label = $MainPanel/StatusPanel/StatusLabel
@onready var grid: GridContainer = $MainPanel/GridPanel/Grid
@onready var reset_button: Button = $MainPanel/ButtonRow/ResetButton
@onready var hint_button: Button = $MainPanel/ButtonRow/HintButton
@onready var exit_button: Button = $MainPanel/ButtonRow/ExitButton

var current_round := 0
var moves_this_round := 0
var completed := false
# Set the instant a visible input-to-output route is accepted. The success
# transition waits briefly for feedback, but pipe inputs must not keep turning
# during that delay.
var round_input_locked := false
var grid_cols := 4
var grid_rows := 3
var tiles: Array[Dictionary] = []
var tile_buttons: Array[Button] = []
var tile_sheet_texture: Texture2D = null
var tile_sheet_image: Image = null
var advanced_tile_sheet_texture: Texture2D = null
var advanced_tile_sheet_image: Image = null
var rotated_tile_cache: Dictionary = {}
var advanced_rotated_tile_cache: Dictionary = {}
var locked_tile_cache: Dictionary = {}
var terminal_tile_cache: Dictionary = {}
var feedback_flash: ColorRect = null

func _ready() -> void:
	AudioManager.play_music_for_context("circuit_soda")
	ArcadeScreen.apply(self, "res://assets/art/minigames/circuit_soda/backgrounds/circuit_soda_screen.svg")
	reset_button.pressed.connect(_reset_round)
	hint_button.pressed.connect(_show_hint)
	exit_button.pressed.connect(_on_exit_pressed)
	tile_sheet_texture = _load_texture(TILE_SHEET_PATH)
	advanced_tile_sheet_texture = _load_texture(ADVANCED_TILE_SHEET_PATH)
	_setup_feedback_flash()
	_start_round(0)

func _create_grid_buttons() -> void:
	tile_buttons.clear()
	for child in grid.get_children():
		child.queue_free()
	grid.columns = grid_cols
	var button_size := Vector2(88, 52)
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
	round_input_locked = false
	exit_button.visible = false
	reset_button.visible = true
	reset_button.disabled = false
	hint_button.visible = true
	hint_button.disabled = true
	var round_data := ROUNDS[current_round]
	grid_cols = int(round_data.get("cols", 4))
	grid_rows = int(round_data.get("rows", 3))
	_create_grid_buttons()
	tiles = []
	for tile in round_data["tiles"]:
		var tile_data: Dictionary = tile
		tiles.append(tile_data.duplicate(true))
	# Fixed sockets live in the grid as immovable tiles.
	tiles[_index_from_pos(round_data["input"])] = {"shape": "input", "connections": round_data["input_connections"].duplicate()}
	tiles[_index_from_pos(round_data["output"])] = {"shape": "output", "connections": round_data["output_connections"].duplicate()}
	round_label.text = str(round_data["title"])
	instruction_label.text = "CIRCUIT SODA\nLink visible hoses from INPUT to OUTPUT.\nAmber-bolted pipes are fixed.\nSome hoses lead to dead ends."
	status_label.text = "Route the soda from INPUT to OUTPUT."
	_refresh_grid()
	_check_win()

func _on_tile_pressed(index: int) -> void:
	if completed or round_input_locked or index < 0 or index >= tiles.size():
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
	if shape == "cross":
		status_label.text = "FOUR-WAY MANIFOLD: all four hoses stay open."
		_play_audio("play_error_buzz")
		return
	if bool(tile.get("locked", false)):
		status_label.text = "FIXED PIPE: this routing cannot turn."
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
	if round_input_locked or not _has_connected_path():
		return
	round_input_locked = true
	for button in tile_buttons:
		button.disabled = true
	reset_button.disabled = true
	hint_button.disabled = true
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
	round_label.text = "CIRCUIT SODA COMPLETE"
	instruction_label.text = "MEMORY FLOW RESTORED.\nONE ROUTE STABLE. IDENTITY UNSETTLED."
	status_label.text = "Success returned a clue, not a verdict."
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
	var queue: Array[Vector2i] = [input_pos]
	var visited := {}
	visited[input_pos] = true
	while not queue.is_empty():
		var pos: Vector2i = queue.pop_front()
		if pos == output_pos:
			return true
		for side in _get_tile_connections(_index_from_pos(pos)):
			var next_pos: Vector2i = pos + DIRS[side]
			if not _pos_in_grid(next_pos):
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
			button.modulate = Color(1.0, 0.9, 0.72, 1.0)
			button.tooltip_text = "Fixed pipe - does not turn."
		elif shape == "cross":
			button.modulate = Color.WHITE
			button.tooltip_text = "Four-way manifold - always open on every side."
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
		"cross":
			return "4-WAY"
		"":
			return ""
	var label := _format_sides(_get_connections_for_tile(tile))
	if bool(tile.get("locked", false)):
		label += "\nFIXED"
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
		"cross":
			return "4-WAY"
		"":
			return ""
	if bool(tile.get("locked", false)):
		return "FIXED"
	return _format_sides(_get_connections_for_tile(tile))

func _get_tile_icon(tile: Dictionary) -> Texture2D:
	var shape := str(tile.get("shape", ""))
	var rot := int(tile.get("rot", 0)) % 4
	var icon: Texture2D = null
	match shape:
		"input":
			icon = _get_terminal_tile(shape, tile.get("connections", []))
		"output":
			icon = _get_terminal_tile(shape, tile.get("connections", []))
		"straight":
			icon = _get_rotated_tile(0, rot)
		"corner":
			icon = _get_rotated_tile(1, rot)
		"junction":
			icon = _get_rotated_tile(2, rot)
		"cross":
			icon = _get_advanced_tile_atlas(ADVANCED_CROSS_FRAME)
		"cap":
			icon = _get_rotated_advanced_tile(ADVANCED_CAP_FRAME, rot)
		"blocker":
			icon = _get_tile_atlas(3)
	if bool(tile.get("locked", false)) and icon != null:
		return _get_locked_tile_icon(icon, "%s:%d" % [shape, rot])
	return icon

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

func _get_advanced_tile_atlas(frame_index: int) -> AtlasTexture:
	if advanced_tile_sheet_texture == null:
		return null
	var cell_width := maxi(int(advanced_tile_sheet_texture.get_width() / 2), 1)
	var cell_height := maxi(int(advanced_tile_sheet_texture.get_height() / 2), 1)
	var atlas := AtlasTexture.new()
	atlas.atlas = advanced_tile_sheet_texture
	atlas.region = Rect2((frame_index % 2) * cell_width, int(frame_index / 2) * cell_height, cell_width, cell_height)
	return atlas

func _get_rotated_advanced_tile(frame_index: int, rot: int) -> Texture2D:
	if rot == 0:
		return _get_advanced_tile_atlas(frame_index)
	var key := frame_index * 10 + rot
	if advanced_rotated_tile_cache.has(key):
		return advanced_rotated_tile_cache[key]
	var region := _get_advanced_tile_image(frame_index)
	if region == null:
		return null
	for i in range(rot):
		region.rotate_90(CLOCKWISE)
	var texture := ImageTexture.create_from_image(region)
	advanced_rotated_tile_cache[key] = texture
	return texture

func _get_advanced_tile_image(frame_index: int) -> Image:
	if advanced_tile_sheet_texture == null:
		return null
	if advanced_tile_sheet_image == null:
		advanced_tile_sheet_image = advanced_tile_sheet_texture.get_image()
		if advanced_tile_sheet_image == null:
			return null
		if advanced_tile_sheet_image.is_compressed():
			advanced_tile_sheet_image.decompress()
	var cell_width := maxi(int(advanced_tile_sheet_image.get_width() / 2), 1)
	var cell_height := maxi(int(advanced_tile_sheet_image.get_height() / 2), 1)
	return advanced_tile_sheet_image.get_region(Rect2i((frame_index % 2) * cell_width, int(frame_index / 2) * cell_height, cell_width, cell_height))

func _get_locked_tile_icon(icon: Texture2D, key: String) -> Texture2D:
	if locked_tile_cache.has(key):
		return locked_tile_cache[key]
	var image := icon.get_image()
	if image == null:
		return icon
	if image.is_compressed():
		image.decompress()
	if image.get_size() != Vector2i(32, 32):
		image.resize(32, 32, Image.INTERPOLATE_NEAREST)
	for bolt in [Vector2i(2, 2), Vector2i(28, 2), Vector2i(2, 28), Vector2i(28, 28)]:
		image.fill_rect(Rect2i(bolt - Vector2i.ONE, Vector2i(3, 3)), Color(0.12, 0.08, 0.03, 1.0))
		image.set_pixelv(bolt, FIXED_PIPE_COLOR)
	var texture := ImageTexture.create_from_image(image)
	locked_tile_cache[key] = texture
	return texture

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
			var connections: Array = []
			for side in tile.get("connections", []):
				connections.append(str(side))
			return connections
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
		"cross":
			return [SIDE_N, SIDE_E, SIDE_S, SIDE_W]
		"cap":
			match rot:
				0:
					return [SIDE_E]
				1:
					return [SIDE_S]
				2:
					return [SIDE_W]
				_:
					return [SIDE_N]
		_:
			return []

func _tile_has_side(index: int, side: String) -> bool:
	return _get_tile_connections(index).has(side)

func _get_terminal_tile(shape: String, sides_value: Variant) -> Texture2D:
	var sides: Array = []
	if sides_value is Array:
		for side in sides_value:
			sides.append(str(side))
	var key := "%s:%s" % [shape, _format_sides(sides)]
	if terminal_tile_cache.has(key):
		return terminal_tile_cache[key]
	var image := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	var hose_color := TERMINAL_INPUT_COLOR if shape == "input" else TERMINAL_OUTPUT_COLOR
	for side in sides:
		_draw_terminal_hose(image, side, hose_color)
	var core_frame := ADVANCED_INPUT_FRAME if shape == "input" else ADVANCED_OUTPUT_FRAME
	var core_image := _get_advanced_tile_image(core_frame)
	if core_image != null:
		core_image.resize(20, 20, Image.INTERPOLATE_NEAREST)
		image.blend_rect(core_image, Rect2i(0, 0, 20, 20), Vector2i(6, 6))
	else:
		image.fill_rect(Rect2i(7, 7, 18, 18), TERMINAL_EDGE_COLOR)
		image.fill_rect(Rect2i(9, 9, 14, 14), TERMINAL_BODY_COLOR)
		image.fill_rect(Rect2i(11, 11, 10, 3), hose_color.darkened(0.35))
		image.fill_rect(Rect2i(11, 17, 10, 3), hose_color)
	var texture := ImageTexture.create_from_image(image)
	terminal_tile_cache[key] = texture
	return texture

func _draw_terminal_hose(image: Image, side: String, color: Color) -> void:
	match side:
		SIDE_N:
			image.fill_rect(Rect2i(14, 0, 4, 9), color)
		SIDE_E:
			image.fill_rect(Rect2i(23, 14, 9, 4), color)
		SIDE_S:
			image.fill_rect(Rect2i(14, 23, 4, 9), color)
		SIDE_W:
			image.fill_rect(Rect2i(0, 14, 9, 4), color)

func _format_sides(sides: Array) -> String:
	var side_names: Array[String] = []
	for side in sides:
		side_names.append(str(side))
	return "-".join(side_names)

func _pos_in_grid(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < grid_cols and pos.y >= 0 and pos.y < grid_rows

func _index_from_pos(pos: Vector2i) -> int:
	return pos.y * grid_cols + pos.x

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
