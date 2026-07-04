extends Control

const ARCADE_JUICE := preload("res://scripts/ArcadeJuice.gd")
const TILE_SIZE := 28
const GRID_ORIGIN := Vector2(48, 112)
const DEFAULT_AREA_ID := "main"

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
var background_screen_path := ""
var tile_size := TILE_SIZE
var grid_origin := GRID_ORIGIN
var side_panel_x := 404
var move_step_interval := 0.18
var move_cooldown_seconds := 0.0
var fog_enabled := false
var fog_radius := 3
var hazards_blink := false
var hazard_blink_interval := 1.6
var hazards_dangerous := true
var hazard_blink_timer := 0.0
var moving_hazard_defs: Array[Dictionary] = []
var conscience_hazard_lines: Array[String] = []
var moving_hazard_color := Color(0.96, 0.36, 0.46, 1.0)
var moving_hazard_sprite_path := ""
var active_moving_hazards: Array = []
var breaker_reveal_enabled := false
var breaker_reveal_radius := 3
var lit_cells: Dictionary = {}
var secret_lines: Array[String] = []
var secret_flag := ""
var secret_found := false
var stage_areas: Array[Dictionary] = []
var area_links: Array[Dictionary] = []
var active_area_id := DEFAULT_AREA_ID
var start_area_id := DEFAULT_AREA_ID
var area_layouts: Dictionary = {}
var area_names: Dictionary = {}
var area_spawns: Dictionary = {}

var player_grid_pos := Vector2i.ZERO
var spawn_grid_pos := Vector2i.ZERO
var collectible_positions: Array[String] = []
var collected_positions: Array[String] = []
var next_collectible_index := 0
var completed := false
var return_in_progress := false

var initial_config: Dictionary = {}
var status_label: Label
var counter_label: Label
var player_marker: ColorRect
var return_button: Button
var reset_button: Button
var tile_container: Control
var feedback_flash: ColorRect
var tile_rects: Dictionary = {}
var tile_markers: Dictionary = {}

func configure_stage(config: Dictionary) -> void:
	if initial_config.is_empty():
		initial_config = config.duplicate(true)
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
	background_screen_path = str(config.get("background_screen_path", ""))
	tile_size = int(config.get("tile_size", TILE_SIZE))
	grid_origin = _to_vector2(config.get("grid_origin", GRID_ORIGIN), GRID_ORIGIN)
	side_panel_x = int(config.get("side_panel_x", side_panel_x))
	move_step_interval = float(config.get("move_step_interval", move_step_interval))
	if move_step_interval <= 0.0:
		move_step_interval = 0.18
	fog_enabled = bool(config.get("fog_enabled", false))
	fog_radius = int(config.get("fog_radius", 3))
	hazards_blink = bool(config.get("hazards_blink", false))
	hazard_blink_interval = float(config.get("hazard_blink_interval", 1.6))
	if hazard_blink_interval <= 0.0:
		hazard_blink_interval = 1.6
	moving_hazard_defs = _to_dictionary_array(config.get("moving_hazards", []))
	conscience_hazard_lines = _to_string_array(config.get("conscience_hazard_lines", conscience_hazard_lines))
	moving_hazard_color = config.get("moving_hazard_color", moving_hazard_color)
	moving_hazard_sprite_path = str(config.get("moving_hazard_sprite_path", ""))
	breaker_reveal_enabled = bool(config.get("breaker_reveal", false))
	breaker_reveal_radius = int(config.get("breaker_reveal_radius", 3))
	secret_lines = _to_string_array(config.get("secret_lines", []))
	secret_flag = str(config.get("secret_flag", ""))
	stage_areas = _to_dictionary_array(config.get("areas", []))
	area_links = _to_dictionary_array(config.get("area_links", []))
	start_area_id = str(config.get("start_area", DEFAULT_AREA_ID))
	if stage_areas.is_empty():
		stage_areas.append({
			"id": DEFAULT_AREA_ID,
			"name": stage_title,
			"layout": layout,
		})
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

func _to_dictionary_array(value: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if value is Array:
		for item in value:
			if item is Dictionary:
				result.append(item)
	return result

func _to_vector2(value: Variant, fallback: Vector2) -> Vector2:
	if value is Vector2:
		return value
	if value is Vector2i:
		return Vector2(value)
	return fallback

func _build_stage() -> void:
	completed = false
	return_in_progress = false
	move_cooldown_seconds = 0.0
	hazards_dangerous = true
	hazard_blink_timer = 0.0
	_scan_stage()
	_rebuild_area_view("")
	ArcadeScreen.apply(self)

func _rebuild_area_view(status_message: String) -> void:
	_clear_children()
	_apply_active_layout()
	_build_background()
	_build_labels()
	_build_grid()
	_build_player()
	_build_moving_hazards()
	_build_feedback_flash()
	_refresh_status(status_message)
	_refresh_counter()

func _clear_children() -> void:
	tile_rects.clear()
	tile_markers.clear()
	active_moving_hazards.clear()
	feedback_flash = null
	for child in get_children():
		if child.name == "ArcadeScanlines" or child.name == "ArcadeCRTOverlay":
			continue
		remove_child(child)
		child.queue_free()

func _scan_stage() -> void:
	lit_cells.clear()
	area_layouts.clear()
	area_names.clear()
	area_spawns.clear()
	collectible_positions.clear()
	collected_positions.clear()
	next_collectible_index = 0
	spawn_grid_pos = Vector2i.ZERO
	player_grid_pos = Vector2i.ZERO
	var fallback_area_id := DEFAULT_AREA_ID
	for index in range(stage_areas.size()):
		var area := stage_areas[index]
		var area_id := str(area.get("id", "area_%d" % index))
		if index == 0:
			fallback_area_id = area_id
		var area_layout := _to_string_array(area.get("layout", []))
		area_layouts[area_id] = area_layout
		area_names[area_id] = str(area.get("name", area_id))
		for y in range(area_layout.size()):
			var row := area_layout[y]
			for x in range(row.length()):
				var tile := row.substr(x, 1)
				if tile == "P":
					area_spawns[area_id] = Vector2i(x, y)
				elif tile == "C":
					collectible_positions.append(_make_position_ref(area_id, Vector2i(x, y)))
	if required_collectibles <= 0:
		required_collectibles = collectible_positions.size()
	if not area_layouts.has(start_area_id):
		start_area_id = fallback_area_id
	active_area_id = start_area_id
	spawn_grid_pos = area_spawns.get(active_area_id, Vector2i.ZERO)
	player_grid_pos = spawn_grid_pos

func _apply_active_layout() -> void:
	layout = area_layouts.get(active_area_id, [])

func _build_background() -> void:
	var screen_tex := _load_texture_or_null(background_screen_path)
	if screen_tex != null:
		var screen := TextureRect.new()
		screen.name = "ScreenBackground"
		screen.set_anchors_preset(Control.PRESET_FULL_RECT)
		screen.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		screen.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
		screen.texture = screen_tex
		add_child(screen)
	else:
		var background := ColorRect.new()
		background.name = "Background"
		background.set_anchors_preset(Control.PRESET_FULL_RECT)
		background.color = Color(0.018, 0.02, 0.028, 1.0)
		add_child(background)
	var panel := ColorRect.new()
	panel.name = "Panel"
	if screen_tex != null:
		var cols := 0
		for row in layout:
			cols = maxi(cols, row.length())
		var gw := cols * tile_size
		var gh := layout.size() * tile_size
		panel.position = Vector2(grid_origin.x - 12, grid_origin.y - 12)
		panel.size = Vector2(gw + 24, gh + 24)
		panel.color = Color(0.02, 0.025, 0.035, 0.66)
	else:
		panel.position = Vector2(24, 18)
		panel.size = Vector2(592, 404)
		panel.color = Color(0.045, 0.05, 0.068, 1.0)
	add_child(panel)
	if screen_tex != null:
		var side := ColorRect.new()
		side.name = "SidePanelBacking"
		side.position = Vector2(side_panel_x - 12, grid_origin.y - 26)
		side.size = Vector2(632 - side_panel_x, 322)
		side.color = Color(0.02, 0.025, 0.035, 0.72)
		add_child(side)

func _build_feedback_flash() -> void:
	feedback_flash = ColorRect.new()
	feedback_flash.name = "ArcadeFeedbackFlash"
	feedback_flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	feedback_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	feedback_flash.visible = false
	feedback_flash.z_index = 80
	add_child(feedback_flash)

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
	counter_label.position = Vector2(side_panel_x, 112)
	counter_label.size = Vector2(596 - side_panel_x, 26)
	counter_label.add_theme_font_size_override("font_size", 12)
	add_child(counter_label)

	status_label = Label.new()
	status_label.position = Vector2(side_panel_x, 148)
	status_label.size = Vector2(596 - side_panel_x, 130)
	status_label.add_theme_font_size_override("font_size", 12)
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(status_label)

	var controls_label := Label.new()
	controls_label.position = Vector2(side_panel_x, 278)
	controls_label.size = Vector2(596 - side_panel_x, 56)
	controls_label.add_theme_font_size_override("font_size", 10)
	controls_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	controls_label.text = "%s\n%s" % [controls_hint, goal_hint]
	add_child(controls_label)

	var legend_label := Label.new()
	legend_label.position = Vector2(side_panel_x, 338)
	legend_label.size = Vector2(596 - side_panel_x, 22)
	legend_label.add_theme_font_size_override("font_size", 8)
	legend_label.text = _get_legend_text()
	add_child(legend_label)

	return_button = Button.new()
	return_button.position = Vector2(side_panel_x + 22, 368)
	return_button.size = Vector2(134, 34)
	return_button.text = "Return"
	return_button.visible = false
	return_button.pressed.connect(_on_return_pressed)
	add_child(return_button)

	reset_button = Button.new()
	reset_button.position = Vector2(side_panel_x + 22, 368)
	reset_button.size = Vector2(134, 34)
	reset_button.add_theme_font_size_override("font_size", 11)
	reset_button.text = "Restart (R)"
	reset_button.focus_mode = Control.FOCUS_NONE
	reset_button.pressed.connect(_reset_stage)
	add_child(reset_button)

	var area_label := Label.new()
	area_label.position = Vector2(grid_origin.x, grid_origin.y - 20)
	area_label.size = Vector2(side_panel_x - grid_origin.x - 12, 18)
	area_label.add_theme_font_size_override("font_size", 10)
	area_label.text = _get_active_area_name()
	add_child(area_label)

func _build_grid() -> void:
	tile_container = Control.new()
	tile_container.name = "TileGrid"
	tile_container.position = grid_origin
	add_child(tile_container)
	for y in range(layout.size()):
		var row := layout[y]
		for x in range(row.length()):
			var tile := row.substr(x, 1)
			var tile_rect := ColorRect.new()
			tile_rect.position = Vector2(x * tile_size, y * tile_size)
			tile_rect.size = Vector2(tile_size - 2, tile_size - 2)
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
	player_marker.size = Vector2(tile_size - 8, tile_size - 8)
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
	sprite.size = Vector2(tile_size - 2, tile_size - 2)
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
		"S":
			return floor_color.lightened(0.10) if not secret_found else floor_color
		"N":
			return Color(0.28, 0.28, 0.45, 1.0)
		_:
			if _get_area_link_for_tile(tile).size() > 0:
				return Color(0.18, 0.42, 0.58, 1.0)
			return floor_color

func _get_tile_marker(tile: String, grid_pos: Vector2i) -> String:
	if tile == "C":
		var index := collectible_positions.find(_make_position_ref(active_area_id, grid_pos))
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
	var link := _get_area_link_for_tile(tile)
	if link.size() > 0:
		return str(link.get("label", tile))
	return ""

func _get_active_area_name() -> String:
	return str(area_names.get(active_area_id, active_area_id))

func _make_position_ref(area_id: String, grid_pos: Vector2i) -> String:
	return "%s:%d,%d" % [area_id, grid_pos.x, grid_pos.y]

func _parse_position_ref(position_ref: String) -> Dictionary:
	var parts := position_ref.split(":", false, 1)
	if parts.size() != 2:
		return {"area_id": "", "position": Vector2i.ZERO}
	var coords := parts[1].split(",", false, 1)
	if coords.size() != 2:
		return {"area_id": parts[0], "position": Vector2i.ZERO}
	return {
		"area_id": parts[0],
		"position": Vector2i(int(coords[0]), int(coords[1])),
	}

func _get_area_link_for_tile(tile: String) -> Dictionary:
	if tile.is_empty():
		return {}
	for link in area_links:
		if str(link.get("from_area", "")) == active_area_id and str(link.get("marker", "")) == tile:
			return link
	return {}

func _change_area(link: Dictionary) -> void:
	var target_area_id := str(link.get("target_area", ""))
	if target_area_id.is_empty() or not area_layouts.has(target_area_id):
		_refresh_status("Passage signal missing.")
		return
	active_area_id = target_area_id
	var fallback_spawn: Vector2i = area_spawns.get(active_area_id, Vector2i.ZERO)
	spawn_grid_pos = _to_vector2i(link.get("target_spawn", fallback_spawn), fallback_spawn)
	player_grid_pos = spawn_grid_pos
	move_cooldown_seconds = move_step_interval
	hazards_dangerous = true
	hazard_blink_timer = 0.0
	_rebuild_area_view("Entered %s." % _get_active_area_name())
	_on_area_entered(active_area_id)

func _to_vector2i(value: Variant, fallback: Vector2i) -> Vector2i:
	if value is Vector2i:
		return value
	if value is Vector2:
		return Vector2i(int(value.x), int(value.y))
	return fallback

func _process(delta: float) -> void:
	if completed or return_in_progress:
		return
	_update_hazard_blink(delta)
	_update_moving_hazards(delta)
	if move_cooldown_seconds > 0.0:
		move_cooldown_seconds = maxf(0.0, move_cooldown_seconds - delta)
		if move_cooldown_seconds > 0.0:
			return
	var direction := _get_input_direction()
	if direction == Vector2i.ZERO:
		return
	var moved := _try_move(direction)
	move_cooldown_seconds = move_step_interval if moved else move_step_interval * 0.5

func _get_input_direction() -> Vector2i:
	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_vector == Vector2.ZERO:
		return Vector2i.ZERO
	if absf(input_vector.x) >= absf(input_vector.y):
		return Vector2i(1 if input_vector.x > 0.0 else -1, 0)
	return Vector2i(0, 1 if input_vector.y > 0.0 else -1)

func _try_move(direction: Vector2i) -> bool:
	if completed or return_in_progress:
		return false
	var next_pos := player_grid_pos + direction
	if _is_wall(next_pos):
		_refresh_status("Blocked.")
		return false
	player_grid_pos = next_pos
	_update_player_marker()
	_handle_tile(_get_tile_at(player_grid_pos))
	_check_moving_hazard_collision()
	return true

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
	var link := _get_area_link_for_tile(tile)
	if link.size() > 0:
		_play_audio("play_button_pulse")
		_flash_feedback(ARCADE_JUICE.FLASH_CYAN, 0.12)
		_change_area(link)
		return
	if tile == "H":
		if hazards_blink and not hazards_dangerous:
			return
		_play_audio("play_error_buzz")
		_flash_feedback(ARCADE_JUICE.FLASH_RED, 0.32)
		_reset_player(_format_lines(hazard_lines))
		return
	if tile == "C":
		_try_collect(player_grid_pos)
		return
	if tile == "S":
		_trigger_secret()
		return
	if tile == "G" or tile == "E":
		_try_complete()

func _try_collect(grid_pos: Vector2i) -> void:
	var position_ref := _make_position_ref(active_area_id, grid_pos)
	if collected_positions.has(position_ref):
		return
	var collectible_index := collectible_positions.find(position_ref)
	if ordered_collectibles and collectible_index != next_collectible_index:
		_handle_wrong_order()
		return
	collected_positions.append(position_ref)
	_play_audio("play_score_blip")
	_flash_feedback(ARCADE_JUICE.FLASH_CYAN, 0.2)
	if breaker_reveal_enabled:
		_light_area_around(grid_pos)
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
	_play_audio("play_error_buzz")
	_flash_feedback(ARCADE_JUICE.FLASH_RED, 0.34)
	if reset_order_on_conflict:
		var reset_positions := collected_positions.duplicate()
		collected_positions.clear()
		next_collectible_index = 0
		_refresh_counter()
		for position_ref in reset_positions:
			var parsed_position := _parse_position_ref(str(position_ref))
			if str(parsed_position.get("area_id", "")) == active_area_id:
				var reset_position := _to_vector2i(parsed_position.get("position", Vector2i.ZERO), Vector2i.ZERO)
				_refresh_tile_state(reset_position)
	_reset_player(_format_lines(wrong_order_lines))

func _try_complete() -> void:
	if completed or return_in_progress:
		return
	if collected_positions.size() < required_collectibles:
		_play_audio("play_error_buzz")
		_flash_feedback(ARCADE_JUICE.FLASH_RED, 0.3)
		_refresh_status("Exit locked.\n%s: %d / %d" % [collectible_label, collected_positions.size(), required_collectibles])
		return
	completed = true
	_play_audio("play_success_jingle")
	_flash_feedback(ARCADE_JUICE.FLASH_CYAN, 0.34)
	_retreat_moving_hazards()
	_on_stage_completed()
	_refresh_status(_format_lines(completion_lines))
	if reset_button:
		reset_button.visible = false
	return_button.visible = true

func _retreat_moving_hazards() -> void:
	# The antagonist pulls back: patrols fade out instead of vanishing.
	for h: Dictionary in active_moving_hazards:
		var rect: ColorRect = h.get("rect", null)
		if rect != null and is_instance_valid(rect):
			var tween := create_tween()
			tween.tween_property(rect, "modulate:a", 0.0, 0.9)
	active_moving_hazards.clear()

func _trigger_secret() -> void:
	if secret_found:
		return
	secret_found = true
	_play_audio("play_success_jingle")
	_flash_feedback(ARCADE_JUICE.FLASH_CYAN, 0.3)
	if breaker_reveal_enabled:
		_light_whole_area()
	if not secret_flag.is_empty():
		var gs := get_node_or_null("/root/GameState")
		if gs != null:
			gs.set(secret_flag, true)
	_refresh_status(_format_lines(secret_lines))

func _light_whole_area() -> void:
	for y in range(layout.size()):
		var row := layout[y]
		for x in range(row.length()):
			if row.substr(x, 1) != "#":
				lit_cells[_make_position_ref(active_area_id, Vector2i(x, y))] = true
	_update_fog()
	_position_moving_hazards()

func trigger_blackout(message: String, speed_multiplier: float = 0.7) -> void:
	# The antagonist cuts the power: all restored light is lost, patrols speed up.
	lit_cells.clear()
	_play_audio("play_error_buzz")
	_flash_feedback(Color(0.9, 0.2, 0.4, 1.0), 0.5)
	_update_fog()
	_position_moving_hazards()
	for h: Dictionary in active_moving_hazards:
		h["interval"] = maxf(0.18, float(h.get("interval", 0.5)) * speed_multiplier)
	_refresh_status(message)

func _on_area_entered(_area_id: String) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if (event as InputEventKey).keycode == KEY_R and not completed and not return_in_progress:
			_reset_stage()

func _reset_stage() -> void:
	# Full restart: fresh layout, collectibles, patrols, fog, and set-piece state.
	if completed or return_in_progress or initial_config.is_empty():
		return
	_play_audio("play_button_pulse")
	# note: secret_found intentionally survives reset; the GameState flag is already set
	_on_stage_reset()
	configure_stage(initial_config.duplicate(true))
	_refresh_status("STAGE RESTARTED.\nThe route resets. The dark does not mind.")

func _on_stage_reset() -> void:
	pass

func _reset_player(message: String) -> void:
	player_grid_pos = spawn_grid_pos
	_update_player_marker()
	_refresh_status(message)

func _update_player_marker() -> void:
	if player_marker == null:
		return
	player_marker.position = Vector2(player_grid_pos.x * tile_size + 4, player_grid_pos.y * tile_size + 4)
	_update_fog()
	_position_moving_hazards()

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
	var position_ref := _make_position_ref(active_area_id, grid_pos)
	if tile == "C" and collected_positions.has(position_ref):
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
	return "%s=%s  %s=Hazard  %s=Goal" % [
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

func _play_audio(method_name: String) -> void:
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager and audio_manager.has_method(method_name):
		audio_manager.call(method_name)

func _on_stage_completed() -> void:
	pass

func _on_return_pressed() -> void:
	if return_in_progress:
		return
	return_in_progress = true
	_play_audio("play_button_pulse")
	ARCADE_JUICE.pulse_control(self, return_button)
	if return_button:
		return_button.disabled = true
	SceneChanger.go_to_arcade_hub()

func _flash_feedback(color: Color, peak_alpha: float) -> void:
	ARCADE_JUICE.flash_overlay(self, feedback_flash, color, peak_alpha)

func _update_fog() -> void:
	if not fog_enabled:
		return
	for pos in tile_rects.keys():
		var a := _fog_alpha_for(pos)
		var rect: ColorRect = tile_rects[pos]
		if rect:
			rect.modulate.a = a
		var marker: Label = tile_markers.get(pos, null)
		if marker:
			marker.modulate.a = a

func _fog_alpha_for(pos: Vector2i) -> float:
	if not fog_enabled:
		return 1.0
	if breaker_reveal_enabled and lit_cells.has(_make_position_ref(active_area_id, pos)):
		return 1.0
	var d: int = maxi(absi(pos.x - player_grid_pos.x), absi(pos.y - player_grid_pos.y))
	if d > fog_radius + 1:
		return 0.22
	elif d > fog_radius:
		return 0.55
	return 1.0

func _light_area_around(center: Vector2i) -> void:
	for dy in range(-breaker_reveal_radius, breaker_reveal_radius + 1):
		for dx in range(-breaker_reveal_radius, breaker_reveal_radius + 1):
			var cell := Vector2i(center.x + dx, center.y + dy)
			if _get_tile_at(cell) == "#":
				continue
			lit_cells[_make_position_ref(active_area_id, cell)] = true
	_update_fog()
	_position_moving_hazards()

func _update_hazard_blink(delta: float) -> void:
	if not hazards_blink:
		return
	hazard_blink_timer += delta
	if hazard_blink_timer >= hazard_blink_interval:
		hazard_blink_timer = 0.0
		hazards_dangerous = not hazards_dangerous
		_recolor_hazards()

func _recolor_hazards() -> void:
	for pos in tile_rects.keys():
		if _get_tile_at(pos) != "H":
			continue
		var rect: ColorRect = tile_rects[pos]
		if rect:
			rect.color = hazard_color if hazards_dangerous else hazard_color.darkened(0.62)
		var marker: Label = tile_markers.get(pos, null)
		if marker:
			var mcol := Color.WHITE if hazards_dangerous else Color(0.5, 0.5, 0.55, 1.0)
			mcol.a = _fog_alpha_for(pos)
			marker.modulate = mcol

func _build_moving_hazards() -> void:
	active_moving_hazards.clear()
	if moving_hazard_defs.is_empty() or tile_container == null:
		return
	for def: Dictionary in moving_hazard_defs:
		if str(def.get("area", active_area_id)) != active_area_id:
			continue
		var waypoints := _expand_hazard_waypoints(def)
		if waypoints.size() <= 1:
			continue
		var rect := ColorRect.new()
		rect.size = Vector2(tile_size - 6, tile_size - 6)
		rect.color = moving_hazard_color
		tile_container.add_child(rect)
		var hazard_tex := _load_texture_or_null(moving_hazard_sprite_path)
		if hazard_tex != null:
			var hsprite := TextureRect.new()
			hsprite.size = rect.size
			hsprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			hsprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			hsprite.texture = hazard_tex
			rect.color = Color(1, 1, 1, 0)
			rect.add_child(hsprite)
		var label_text := "" if hazard_tex != null else str(def.get("marker", hazard_marker))
		if not label_text.is_empty():
			var lbl := Label.new()
			lbl.size = rect.size
			lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			lbl.add_theme_font_size_override("font_size", 9)
			lbl.text = label_text
			rect.add_child(lbl)
		var interval := float(def.get("interval", 0.5))
		if interval <= 0.0:
			interval = 0.5
		var start_index := clampi(int(def.get("start_index", 0)), 0, waypoints.size() - 1)
		active_moving_hazards.append({
			"rect": rect,
			"waypoints": waypoints,
			"index": start_index,
			"dir": 1,
			"timer": 0.0,
			"interval": interval,
			"cell": waypoints[start_index],
		})
	_position_moving_hazards()

func _expand_hazard_waypoints(def: Dictionary) -> Array:
	var explicit: Variant = def.get("waypoints", null)
	if explicit is Array and (explicit as Array).size() > 0:
		var out: Array = []
		for item: Variant in explicit as Array:
			out.append(_to_vector2i(item, Vector2i.ZERO))
		return out
	var axis := str(def.get("axis", "h"))
	var line := int(def.get("line", 1))
	var from_i := int(def.get("from", 1))
	var to_i := int(def.get("to", from_i))
	var wps: Array = []
	var step := 1 if to_i >= from_i else -1
	var i := from_i
	while true:
		if axis == "v":
			wps.append(Vector2i(line, i))
		else:
			wps.append(Vector2i(i, line))
		if i == to_i:
			break
		i += step
	return wps

func _position_moving_hazards() -> void:
	for h: Dictionary in active_moving_hazards:
		var rect: ColorRect = h.get("rect", null)
		if rect == null or not is_instance_valid(rect):
			continue
		var cell: Vector2i = h.get("cell", Vector2i.ZERO)
		rect.position = Vector2(cell.x * tile_size + 3, cell.y * tile_size + 3)
		rect.modulate.a = _fog_alpha_for(cell)

func _update_moving_hazards(delta: float) -> void:
	if active_moving_hazards.is_empty():
		return
	var stepped := false
	for h: Dictionary in active_moving_hazards:
		h["timer"] = float(h.get("timer", 0.0)) + delta
		if h["timer"] >= float(h.get("interval", 0.5)):
			h["timer"] = 0.0
			_step_moving_hazard(h)
			stepped = true
	if stepped:
		_position_moving_hazards()
		_check_moving_hazard_collision()

func _step_moving_hazard(h: Dictionary) -> void:
	var wps: Array = h.get("waypoints", [])
	if wps.size() <= 1:
		return
	var idx := int(h.get("index", 0))
	var dir := int(h.get("dir", 1))
	idx += dir
	if idx >= wps.size():
		idx = maxi(wps.size() - 2, 0)
		dir = -1
	elif idx < 0:
		idx = mini(1, wps.size() - 1)
		dir = 1
	h["index"] = idx
	h["dir"] = dir
	h["cell"] = wps[idx]

func _check_moving_hazard_collision() -> void:
	if completed or return_in_progress:
		return
	for h: Dictionary in active_moving_hazards:
		if h.get("cell", Vector2i.ZERO) == player_grid_pos:
			_hit_by_moving_hazard()
			return

func _hit_by_moving_hazard() -> void:
	_play_audio("play_error_buzz")
	_flash_feedback(ARCADE_JUICE.FLASH_RED, 0.34)
	var lines: Array[String] = conscience_hazard_lines if not conscience_hazard_lines.is_empty() else hazard_lines
	_reset_player(_format_lines(lines))
	for h: Dictionary in active_moving_hazards:
		h["timer"] = 0.0
