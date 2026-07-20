
extends SceneTree

const CHARACTERS := {
	"mira": {
		"source": "res://tmp/imagegen/mira_atlas_source.png",
		"folder": "res://assets/art/characters/mira",
	},
	"gus": {
		"source": "res://tmp/imagegen/gus_atlas_source.png",
		"folder": "res://assets/art/characters/gus",
	},
	"roxy": {
		"source": "res://tmp/imagegen/roxy_atlas_source.png",
		"folder": "res://assets/art/characters/roxy",
	},
}

const FRAME_SIZE := Vector2i(32, 32)
const CELL_COLUMNS := 3
const CELL_ROWS := 2
const TARGET_BODY_HEIGHT := 29


func _initialize() -> void:
	for character_name in CHARACTERS:
		_build_character(character_name, CHARACTERS[character_name])
	quit()


func _build_character(character_name: String, config: Dictionary) -> void:
	var source := Image.new()
	var source_path := ProjectSettings.globalize_path(str(config["source"]))
	var load_error := source.load(source_path)
	if load_error != OK:
		push_error("Could not load %s (%d)" % [source_path, load_error])
		return
	var cell_size := Vector2i(source.get_width() / CELL_COLUMNS, source.get_height() / CELL_ROWS)
	var frames: Array[Image] = []
	for index in range(CELL_COLUMNS * CELL_ROWS):
		var cell_position := Vector2i(index % CELL_COLUMNS, index / CELL_COLUMNS) * cell_size
		var cell := source.get_region(Rect2i(cell_position, cell_size))
		frames.append(_normalize_cell(cell))

	var idle_sheet := Image.create(FRAME_SIZE.x * 2, FRAME_SIZE.y, false, Image.FORMAT_RGBA8)
	idle_sheet.fill(Color.TRANSPARENT)
	idle_sheet.blit_rect(frames[0], Rect2i(Vector2i.ZERO, FRAME_SIZE), Vector2i.ZERO)
	idle_sheet.blit_rect(frames[1], Rect2i(Vector2i.ZERO, FRAME_SIZE), Vector2i(FRAME_SIZE.x, 0))

	var facing_sheet := Image.create(FRAME_SIZE.x * 4, FRAME_SIZE.y, false, Image.FORMAT_RGBA8)
	facing_sheet.fill(Color.TRANSPARENT)
	for facing_index in range(4):
		facing_sheet.blit_rect(
			frames[facing_index + 2],
			Rect2i(Vector2i.ZERO, FRAME_SIZE),
			Vector2i(FRAME_SIZE.x * facing_index, 0)
		)

	var folder := str(config["folder"])
	var idle_path := "%s/%s_idle_sheet_v2.png" % [folder, character_name]
	var facing_path := "%s/%s_turn_diagonal_sheet_v2.png" % [folder, character_name]
	var idle_error := idle_sheet.save_png(ProjectSettings.globalize_path(idle_path))
	var facing_error := facing_sheet.save_png(ProjectSettings.globalize_path(facing_path))
	if idle_error != OK or facing_error != OK:
		push_error("%s sheet save failed: idle=%d facing=%d" % [character_name, idle_error, facing_error])
		return
	print("%s: wrote %s and %s" % [character_name, idle_path, facing_path])


func _normalize_cell(cell: Image) -> Image:
	cell.convert(Image.FORMAT_RGBA8)
	var bounds := _find_foreground_bounds(cell)
	if bounds.size.x <= 0 or bounds.size.y <= 0:
		push_error("Generated atlas cell has no foreground")
		return Image.create(FRAME_SIZE.x, FRAME_SIZE.y, false, Image.FORMAT_RGBA8)
	var cropped := cell.get_region(bounds)
	for y in range(cropped.get_height()):
		for x in range(cropped.get_width()):
			var color := cropped.get_pixel(x, y)
			if _is_key_background(color):
				cropped.set_pixel(x, y, Color.TRANSPARENT)
				continue
			# Remove any remaining bright key spill without muting cyan clothing.
			if color.g > maxf(color.r, color.b) * 1.15:
				color.g = maxf(color.r, color.b) * 1.08
			color.a = 1.0
			cropped.set_pixel(x, y, color)

	var scale_factor := minf(
		float(FRAME_SIZE.x - 4) / float(cropped.get_width()),
		float(TARGET_BODY_HEIGHT) / float(cropped.get_height())
	)
	var target_size := Vector2i(
		maxi(1, int(round(cropped.get_width() * scale_factor))),
		maxi(1, int(round(cropped.get_height() * scale_factor)))
	)
	cropped.resize(target_size.x, target_size.y, Image.INTERPOLATE_NEAREST)

	var frame := Image.create(FRAME_SIZE.x, FRAME_SIZE.y, false, Image.FORMAT_RGBA8)
	frame.fill(Color.TRANSPARENT)
	var destination := Vector2i(
		(FRAME_SIZE.x - target_size.x) / 2,
		FRAME_SIZE.y - target_size.y - 1
	)
	frame.blit_rect(cropped, Rect2i(Vector2i.ZERO, target_size), destination)
	return frame


func _find_foreground_bounds(image: Image) -> Rect2i:
	var min_point := Vector2i(image.get_width(), image.get_height())
	var max_point := Vector2i(-1, -1)
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			if _is_key_background(image.get_pixel(x, y)):
				continue
			min_point.x = mini(min_point.x, x)
			min_point.y = mini(min_point.y, y)
			max_point.x = maxi(max_point.x, x)
			max_point.y = maxi(max_point.y, y)
	if max_point.x < min_point.x or max_point.y < min_point.y:
		return Rect2i()
	return Rect2i(min_point, max_point - min_point + Vector2i.ONE)


func _is_key_background(color: Color) -> bool:
	return color.g > 0.58 and color.g > color.r * 1.25 and color.g > color.b * 1.25

