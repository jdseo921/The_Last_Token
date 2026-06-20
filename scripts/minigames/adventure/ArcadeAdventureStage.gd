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
var controls_hint := "Move: WASD / Arrow Keys"
var goal_hint := "Goal unlocks after objectives."
var hazard_marker := "~"
var collectible_marker := ""
var goal_marker := "EXIT"
var floor_color := Color(0.13, 0.15, 0.19, 1.0)
var wall_color := Color(0.09, 0.105, 0.13, 1.0)
var hazard_color := Color(0.8, 0.16, 0.28, 1.0)
var collectible_color := Color(0.22, 0.48, 0.88, 1.0)
var goal_color := Color(0.15, 0.55, 0.36, 1.0)
var player_color := Color(0.86, 0.96, 1.0, 1.0)
var player_adventure_sprite_path := ""
var tile_sheet_path := ""
var hazard_sprite_path := ""
var collectible_sprite_path := ""
var goal_sprite_path := ""

var player_grid_pos := Vector2i.ZERO
var spawn_grid_pos := Vector2i.ZERO
var collectible_positions: Array[Vector2i] = []
var collected_positions: Array[Vector2i] = []
var next_collectible_index := 0
var completed := false
var return_in_progress := false

var status_label: Label
var counter_label: Label
var player_marker: ColorRect
var return_button: Button
var tile_container: Control
var tile_rects: Dictionary = {}
var tile_markers: Dictionary = {}

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
	controls_hint = str(config.get("controls_hint", controls_hint))
	goal_hint = str(config.get("goal_hint", goal_hint))
	hazard_marker = str(config.get("hazard_marker", hazard_marker))
	collectible_marker = str(config.get("collectible_marker", collectible_marker))
	goal_marker = str(config.get("goal_marker", goal_marker))
	floor_color = config.get("floor_color", floor_color)
	wall_color = config.get("wall_color", wall_color)
	hazard_color = config.get("hazard_color", hazard_color)
	collectible_color = config.get("collectible_color", collectible_color)
	goal_color = config.get("goal_color", goal_color)
	player_color = config.get("player_color", player_color)
	player_adventure_sprite_path = str(config.get("player_adventure_sprite_path", ""))
	tile_sheet_path = str(config.get("tile_sheet_path", ""))
	hazard_sprite_path = str(config.get("hazard_sprite_path", ""))
	collectible_sprite_path = str(config.get("collectible_sprite_path", ""))
	goal_sprite_path = str(config.get("goal_sprite_path", ""))
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
	completed = false
	return_in_progress = false
	_clear_children()
	_scan_layout()
	_build_background()
	_build_labels()
	_build_grid()
	_build_player()
	_refresh_status("")
	_refresh_counter()

func _clear_children() -> void:
	tile_rects.clear()
	tile_markers.clear()
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
	controls_label.text = "%s\n%s" % [controls_hint, goal_hint]
	add_child(controls_label)

	var legend_label := Label.new()
	legend_label.position = Vector2(404, 318)
	legend_label.size = Vector2(178, 24)
	legend_label.add_theme_font_size_override("font_size", 9)
	legend_label.text = _get_legend_text()
	add_child(legend_label)

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
			tile_rects[Vector2i(x, y)] = tile_rect
			_add_optional_tile_sprite(tile, tile_rect.position)
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
				tile_markers[Vector2i(x, y)] = marker

func _build_player() -> void:
	player_marker = ColorRect.new()
	player_marker.name = "AdventurePlayer"
	player_marker.size = Vector2(TILE_SIZE - 8, TILE_SIZE - 8)
	player_marker.color = player_color
	tile_container.add_child(player_marker)
	_add_optional_player_sprite()
	_update_player_marker()

func _add_optional_player_sprite() -> void:
	var texture := _load_texture_or_null(player_adventure_sprite_path)
	if texture == null:
		return
	var sprite := TextureRect.new()
	sprite.name = "PlayerSprite"
	sprite.position = Vector2.ZERO
	sprite.size = player_marker.size
	sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sprite.texture = texture
	player_marker.color = Color(1, 1, 1, 0)
	player_marker.add_child(sprite)

func _add_optional_tile_sprite(tile: String, tile_position: Vector2) -> void:
	var texture_path := ""
	match tile:
		"C":
			texture_path = collectible_sprite_path
		"H":
			texture_path = hazard_sprite_path
		"E", "G":
			texture_path = goal_sprite_path
		_:
			return
	var texture := _load_texture_or_null(texture_path)
	if texture == null:
		return
	var sprite := TextureRect.new()
	sprite.position = tile_position
	sprite.size = Vector2(TILE_SIZE - 2, TILE_SIZE - 2)
	sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sprite.texture = texture
	tile_container.add_child(sprite)

func _get_tile_color(tile: String) -> Color:
	match tile:
		"#":
			return wall_color
		"C":
			return collectible_color
		"H":
			return hazard_color
		"E":
			return goal_color
		"G":
			return goal_color
		"N":
			return Color(0.28, 0.28, 0.45, 1.0)
		_:
			return floor_color

func _get_tile_marker(tile: String, grid_pos: Vector2i) -> String:
	if tile == "C":
		var index := collectible_positions.find(grid_pos)
		if index >= 0:
			if ordered_collectibles:
				return str(index + 1)
			if not collectible_marker.is_empty():
				return collectible_marker
			return "F"
	if tile == "H":
		return hazard_marker
	if tile == "E":
		return goal_marker
	if tile == "G":
		return goal_marker
	return ""

func _unhandled_input(event: InputEvent) -> void:
	if completed or return_in_progress:
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
	if completed or return_in_progress:
		return
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
	_refresh_tile_state(grid_pos)
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
		var reset_positions := collected_positions.duplicate()
		collected_positions.clear()
		next_collectible_index = 0
		_refresh_counter()
		for position in reset_positions:
			_refresh_tile_state(position)
	_reset_player(_format_lines(wrong_order_lines))

func _try_complete() -> void:
	if completed or return_in_progress:
		return
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

func _refresh_tile_state(grid_pos: Vector2i) -> void:
	var tile := _get_tile_at(grid_pos)
	var tile_rect: ColorRect = tile_rects.get(grid_pos, null)
	if tile_rect == null:
		return
	if tile == "C" and collected_positions.has(grid_pos):
		tile_rect.color = floor_color.lightened(0.18)
		var marker: Label = tile_markers.get(grid_pos, null)
		if marker:
			marker.text = "OK"
			marker.modulate = Color(0.75, 1.0, 0.82, 1.0)
	elif tile == "C":
		tile_rect.color = collectible_color
		var marker: Label = tile_markers.get(grid_pos, null)
		if marker:
			marker.text = _get_tile_marker(tile, grid_pos)
			marker.modulate = Color.WHITE

func _get_legend_text() -> String:
	var collectible_name := collectible_label
	if collectible_name.ends_with("s"):
		collectible_name = collectible_name.substr(0, collectible_name.length() - 1)
	return "%s = %s  %s = Hazard  %s = Goal" % [
		collectible_marker if not collectible_marker.is_empty() else "C",
		collectible_name,
		hazard_marker,
		goal_marker,
	]

func _format_lines(lines: Array[String]) -> String:
	var packed := PackedStringArray()
	for line in lines:
		packed.append(line)
	return "\n".join(packed)

func _load_texture_or_null(path: String) -> Texture2D:
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	var resource := load(path)
	if resource is Texture2D:
		return resource
	return null

func _on_stage_completed() -> void:
	pass

func _on_return_pressed() -> void:
	if return_in_progress:
		return
	return_in_progress = true
	if return_button:
		return_button.disabled = true
	SceneChanger.go_to_arcade_hub()
