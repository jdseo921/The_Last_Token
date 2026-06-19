extends Control

const TILE_SIZE := 28
const GRID_ORIGIN := Vector2(48, 112)

var stage_title := "ARCADE ADVENTURE"
var objective_text := "Collect everything and reach the exit."
var collectible_label := "Items"
var required_collectibles := 0
var ordered_collectibles := false
var reset_order_on_conflict := false
var layout: Array[String] = []
var collectible_texts: Array[String] = []
var completion_lines: Array[String] = []
var hazard_lines: Array[String] = ["STATIC DISCHARGE.", "Signal reset."]
var wrong_order_lines: Array[String] = ["TIMESTAMP CONFLICT.", "The memory rewinds."]
var player_adventure_sprite_path := ""
var tile_sheet_path := ""
var hazard_sprite_path := ""
var collectible_sprite_path := ""

var player_grid_pos := Vector2i.ZERO
var spawn_grid_pos := Vector2i.ZERO
var collectible_positions: Array[Vector2i] = []
var collected_positions: Array[Vector2i] = []
var next_collectible_index := 0
var completed := false

var status_label: Label
var counter_label: Label
var player_marker: ColorRect
var return_button: Button
var tile_container: Control

func configure_stage(config: Dictionary) -> void:
	stage_title = str(config.get("title", stage_title))
	objective_text = str(config.get("objective", objective_text))
	collectible_label = str(config.get("collectible_label", collectible_label))
	required_collectibles = int(config.get("required_collectibles", required_collectibles))
	ordered_collectibles = bool(config.get("ordered_collectibles", ordered_collectibles))
	reset_order_on_conflict = bool(config.get("reset_order_on_conflict", reset_order_on_conflict))
	layout = _to_string_array(config.get("layout", layout))
	collectible_texts = _to_string_array(config.get("collectible_texts", collectible_texts))
	completion_lines = _to_string_array(config.get("completion_lines", completion_lines))
	hazard_lines = _to_string_array(config.get("hazard_lines", hazard_lines))
	wrong_order_lines = _to_string_array(config.get("wrong_order_lines", wrong_order_lines))
	player_adventure_sprite_path = str(config.get("player_adventure_sprite_path", ""))
	tile_sheet_path = str(config.get("tile_sheet_path", ""))
	hazard_sprite_path = str(config.get("hazard_sprite_path", ""))
	collectible_sprite_path = str(config.get("collectible_sprite_path", ""))
	_build_stage()

func _ready() -> void:
	if layout.is_empty():
		configure_stage({
			"title": "ARCADE ADVENTURE",
			"objective": "Move with WASD or arrows. Collect the marker and reach the exit.",
			"collectible_label": "Items",
			"required_collectibles": 1,
			"layout": [
				"########",
				"#P..C.E#",
				"########",
			],
			"completion_lines": ["STAGE COMPLETE."],
		})

func _to_string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if value is Array:
		for item in value:
			result.append(str(item))
	return result

func _build_stage() -> void:
	_clear_children()
	_scan_layout()
	_build_background()
	_build_labels()
	_build_grid()
	_build_player()
	_refresh_status("")
	_refresh_counter()
	grab_focus()

func _clear_children() -> void:
	for child in get_children():
		child.queue_free()

func _scan_layout() -> void:
	collectible_positions.clear()
	collected_positions.clear()
	next_collectible_index = 0
	spawn_grid_pos = Vector2i.ZERO
	player_grid_pos = Vector2i.ZERO
	for y in range(layout.size()):
		var row := layout[y]
		for x in range(row.length()):
			var tile := row.substr(x, 1)
			if tile == "P":
				spawn_grid_pos = Vector2i(x, y)
				player_grid_pos = spawn_grid_pos
			elif tile == "C":
				collectible_positions.append(Vector2i(x, y))
	if required_collectibles <= 0:
		required_collectibles = collectible_positions.size()

func _build_background() -> void:
	var background := ColorRect.new()
	background.name = "Background"
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.color = Color(0.018, 0.02, 0.028, 1.0)
	add_child(background)
	var panel := ColorRect.new()
	panel.name = "Panel"
	panel.position = Vector2(24, 18)
	panel.size = Vector2(592, 404)
	panel.color = Color(0.045, 0.05, 0.068, 1.0)
	add_child(panel)

func _build_labels() -> void:
	var title_label := Label.new()
	title_label.position = Vector2(44, 30)
	title_label.size = Vector2(552, 28)
	title_label.add_theme_font_size_override("font_size", 20)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.text = stage_title
	add_child(title_label)

	var objective_label := Label.new()
	objective_label.position = Vector2(48, 62)
	objective_label.size = Vector2(544, 38)
	objective_label.add_theme_font_size_override("font_size", 11)
	objective_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	objective_label.text = objective_text
	add_child(objective_label)

	counter_label = Label.new()
	counter_label.position = Vector2(404, 112)
	counter_label.size = Vector2(178, 26)
	counter_label.add_theme_font_size_override("font_size", 12)
	add_child(counter_label)

	status_label = Label.new()
	status_label.position = Vector2(404, 148)
	status_label.size = Vector2(178, 130)
	status_label.add_theme_font_size_override("font_size", 12)
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(status_label)

	var controls_label := Label.new()
	controls_label.position = Vector2(404, 282)
	controls_label.size = Vector2(178, 42)
	controls_label.add_theme_font_size_override("font_size", 10)
	controls_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	controls_label.text = "Move: WASD / Arrow Keys\nGoal unlocks after objectives."
	add_child(controls_label)

	return_button = Button.new()
	return_button.position = Vector2(426, 342)
	return_button.size = Vector2(134, 34)
	return_button.text = "Return"
	return_button.visible = false
	return_button.pressed.connect(_on_return_pressed)
	add_child(return_button)

func _build_grid() -> void:
	tile_container = Control.new()
	tile_container.name = "TileGrid"
	tile_container.position = GRID_ORIGIN
	add_child(tile_container)
	for y in range(layout.size()):
		var row := layout[y]
		for x in range(row.length()):
			var tile := row.substr(x, 1)
			var tile_rect := ColorRect.new()
			tile_rect.position = Vector2(x * TILE_SIZE, y * TILE_SIZE)
			tile_rect.size = Vector2(TILE_SIZE - 2, TILE_SIZE - 2)
			tile_rect.color = _get_tile_color(tile)
			tile_container.add_child(tile_rect)
			var marker_text := _get_tile_marker(tile, Vector2i(x, y))
			if not marker_text.is_empty():
				var marker := Label.new()
				marker.position = tile_rect.position
				marker.size = tile_rect.size
				marker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				marker.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
				marker.add_theme_font_size_override("font_size", 12)
				marker.text = marker_text
				tile_container.add_child(marker)

func _build_player() -> void:
	player_marker = ColorRect.new()
	player_marker.name = "AdventurePlayer"
	player_marker.size = Vector2(TILE_SIZE - 8, TILE_SIZE - 8)
	player_marker.color = Color(0.86, 0.96, 1.0, 1.0)
	tile_container.add_child(player_marker)
	_update_player_marker()

func _get_tile_color(tile: String) -> Color:
	match tile:
		"#":
			return Color(0.09, 0.105, 0.13, 1.0)
		"C":
			return Color(0.22, 0.48, 0.88, 1.0)
		"H":
			return Color(0.8, 0.16, 0.28, 1.0)
		"E":
			return Color(0.15, 0.55, 0.36, 1.0)
		"G":
			return Color(0.84, 0.64, 0.16, 1.0)
		"N":
			return Color(0.28, 0.28, 0.45, 1.0)
		_:
			return Color(0.13, 0.15, 0.19, 1.0)

func _get_tile_marker(tile: String, grid_pos: Vector2i) -> String:
	if tile == "C":
		var index := collectible_positions.find(grid_pos)
		if index >= 0:
			return str(index + 1) if ordered_collectibles else "F"
	if tile == "H":
		return "~"
	if tile == "E":
		return "EXIT"
	if tile == "G":
		return "PWR"
	return ""

func _unhandled_input(event: InputEvent) -> void:
	if completed:
		return
	if event.is_action_pressed("move_up"):
		_try_move(Vector2i(0, -1))
	elif event.is_action_pressed("move_down"):
		_try_move(Vector2i(0, 1))
	elif event.is_action_pressed("move_left"):
		_try_move(Vector2i(-1, 0))
	elif event.is_action_pressed("move_right"):
		_try_move(Vector2i(1, 0))

func _try_move(direction: Vector2i) -> void:
	var next_pos := player_grid_pos + direction
	if _is_wall(next_pos):
		_refresh_status("Blocked.")
		return
	player_grid_pos = next_pos
	_update_player_marker()
	_handle_tile(_get_tile_at(player_grid_pos))

func _is_wall(grid_pos: Vector2i) -> bool:
	return _get_tile_at(grid_pos) == "#"

func _get_tile_at(grid_pos: Vector2i) -> String:
	if grid_pos.y < 0 or grid_pos.y >= layout.size():
		return "#"
	var row := layout[grid_pos.y]
	if grid_pos.x < 0 or grid_pos.x >= row.length():
		return "#"
	return row.substr(grid_pos.x, 1)

func _handle_tile(tile: String) -> void:
	if tile == "H":
		_reset_player(_format_lines(hazard_lines))
		return
	if tile == "C":
		_try_collect(player_grid_pos)
		return
	if tile == "G" or tile == "E":
		_try_complete()

func _try_collect(grid_pos: Vector2i) -> void:
	if collected_positions.has(grid_pos):
		return
	var collectible_index := collectible_positions.find(grid_pos)
	if ordered_collectibles and collectible_index != next_collectible_index:
		_handle_wrong_order()
		return
	collected_positions.append(grid_pos)
	next_collectible_index += 1
	_refresh_counter()
	var item_name := collectible_label
	if item_name.ends_with("s"):
		item_name = item_name.substr(0, item_name.length() - 1)
	var message := "%s collected." % item_name
	if collectible_index >= 0 and collectible_index < collectible_texts.size():
		message = collectible_texts[collectible_index]
	_refresh_status(message)

func _handle_wrong_order() -> void:
	if reset_order_on_conflict:
		collected_positions.clear()
		next_collectible_index = 0
		_refresh_counter()
	_reset_player(_format_lines(wrong_order_lines))

func _try_complete() -> void:
	if collected_positions.size() < required_collectibles:
		_refresh_status("Exit locked.\n%s: %d / %d" % [collectible_label, collected_positions.size(), required_collectibles])
		return
	completed = true
	_on_stage_completed()
	_refresh_status(_format_lines(completion_lines))
	return_button.visible = true

func _reset_player(message: String) -> void:
	player_grid_pos = spawn_grid_pos
	_update_player_marker()
	_refresh_status(message)

func _update_player_marker() -> void:
	if player_marker == null:
		return
	player_marker.position = Vector2(player_grid_pos.x * TILE_SIZE + 4, player_grid_pos.y * TILE_SIZE + 4)

func _refresh_counter() -> void:
	if counter_label:
		counter_label.text = "%s: %d / %d" % [collectible_label, collected_positions.size(), required_collectibles]

func _refresh_status(message: String) -> void:
	if status_label:
		status_label.text = message

func _format_lines(lines: Array[String]) -> String:
	var packed := PackedStringArray()
	for line in lines:
		packed.append(line)
	return "\n".join(packed)

func _on_stage_completed() -> void:
	pass

func _on_return_pressed() -> void:
	SceneChanger.go_to_arcade_hub()
