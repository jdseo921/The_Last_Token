extends SceneTree

const PORTRAIT_SIZE := Vector2i(128, 128)
const CELL_COLUMNS := 3
const CELL_ROWS := 2
const CELL_HORIZONTAL_INSET := 16
const BOTTOM_PADDING := 1
const CONTENT_SIDE_PADDING := 14
const MIN_SIDE_MARGIN := 8
const TOP_PADDING := 3

const CHARACTER_CONFIGS := {
	"mira": {
		"source": "res://tmp/imagegen/mira_dialogue_atlas_source.png",
		"folder": "res://assets/art/portraits/mira",
		"expressions": ["neutral", "worried", "sad", "relieved", "afraid"],
	},
	"gus": {
		"source": "res://tmp/imagegen/gus_dialogue_atlas_source.png",
		"folder": "res://assets/art/portraits/gus",
		"expressions": ["neutral", "deadpan", "caring", "annoyed", "alarmed"],
	},
}


func _initialize() -> void:
	for character_name in CHARACTER_CONFIGS:
		_build_portrait_set(character_name, CHARACTER_CONFIGS[character_name])
	quit()


func _build_portrait_set(character_name: String, config: Dictionary) -> void:
	var source := Image.new()
	var source_path := ProjectSettings.globalize_path(str(config["source"]))
	var load_error := source.load(source_path)
	if load_error != OK:
		push_error("Could not load %s (%d)" % [source_path, load_error])
		return
	var cell_size := Vector2i(source.get_width() / CELL_COLUMNS, source.get_height() / CELL_ROWS)
	var expressions: Array = config["expressions"]
	for index in range(expressions.size()):
		var cell_position := Vector2i(index % CELL_COLUMNS, index / CELL_COLUMNS) * cell_size
		# The generated middle-column busts can inherit a few pixels from the
		# previous wide shoulder, so give that edge one extra inset.
		var left_inset := CELL_HORIZONTAL_INSET * 2 if index % CELL_COLUMNS == 1 else CELL_HORIZONTAL_INSET
		var slice_position := cell_position + Vector2i(left_inset, 0)
		var slice_size := cell_size - Vector2i(left_inset + CELL_HORIZONTAL_INSET, 0)
		var cell := source.get_region(Rect2i(slice_position, slice_size))
		var portrait := _normalize_portrait(cell)
		var output_path := "%s/%s_%s.png" % [config["folder"], character_name, expressions[index]]
		var save_error := portrait.save_png(ProjectSettings.globalize_path(output_path))
		if save_error != OK:
			push_error("Could not save %s (%d)" % [output_path, save_error])
			continue
		print("wrote %s" % output_path)


func _normalize_portrait(cell: Image) -> Image:
	cell.convert(Image.FORMAT_RGBA8)
	var bounds := _find_foreground_bounds(cell)
	if bounds.size.x <= 0 or bounds.size.y <= 0:
		push_error("Generated dialogue atlas cell has no foreground")
		return Image.create(PORTRAIT_SIZE.x, PORTRAIT_SIZE.y, false, Image.FORMAT_RGBA8)
	var cropped := cell.get_region(bounds)
	for y in range(cropped.get_height()):
		for x in range(cropped.get_width()):
			var color := cropped.get_pixel(x, y)
			if _is_key_background(color):
				cropped.set_pixel(x, y, Color.TRANSPARENT)
				continue
			if color.g > maxf(color.r, color.b) * 1.15:
				color.g = maxf(color.r, color.b) * 1.08
			color.a = 1.0
			cropped.set_pixel(x, y, color)

	var scale_factor := minf(
		float(PORTRAIT_SIZE.x - CONTENT_SIDE_PADDING * 2) / float(cropped.get_width()),
		float(PORTRAIT_SIZE.y - TOP_PADDING - BOTTOM_PADDING) / float(cropped.get_height())
	)
	var target_size := Vector2i(
		maxi(1, int(round(cropped.get_width() * scale_factor))),
		maxi(1, int(round(cropped.get_height() * scale_factor)))
	)
	cropped.resize(target_size.x, target_size.y, Image.INTERPOLATE_NEAREST)

	var portrait := Image.create(PORTRAIT_SIZE.x, PORTRAIT_SIZE.y, false, Image.FORMAT_RGBA8)
	portrait.fill(Color.TRANSPARENT)
	# Anchor the head rather than the shoulders. Expression variants change the
	# towel and arm silhouette, which made Gus appear to slide sideways even
	# though every full-body alpha box was mathematically centered.
	var upper_center_x := _find_upper_foreground_center_x(cropped)
	var destination_x := int(round(float(PORTRAIT_SIZE.x) * 0.5 - upper_center_x))
	# Keep the full shoulder silhouette inside the portrait even when an
	# expression changes the upper-body pose. Face centering is retained within
	# this safe range instead of clipping the artwork against either side.
	destination_x = clampi(
		destination_x,
		MIN_SIDE_MARGIN,
		PORTRAIT_SIZE.x - MIN_SIDE_MARGIN - target_size.x
	)
	var destination := Vector2i(
		destination_x,
		PORTRAIT_SIZE.y - target_size.y - BOTTOM_PADDING
	)
	_blit_clipped(portrait, cropped, destination)
	return portrait


func _find_upper_foreground_center_x(image: Image) -> float:
	var upper_limit := maxi(1, int(round(float(image.get_height()) * 0.48)))
	var weighted_x := 0.0
	var total_weight := 0.0
	for y in range(upper_limit):
		for x in range(image.get_width()):
			var alpha := image.get_pixel(x, y).a
			if alpha <= 0.05:
				continue
			weighted_x += float(x) * alpha
			total_weight += alpha
	if total_weight <= 0.0:
		return float(image.get_width()) * 0.5
	return weighted_x / total_weight


func _blit_clipped(destination_image: Image, source_image: Image, destination: Vector2i) -> void:
	var source_position := Vector2i(maxi(0, -destination.x), maxi(0, -destination.y))
	var safe_destination := Vector2i(maxi(0, destination.x), maxi(0, destination.y))
	var copy_size := Vector2i(
		mini(source_image.get_width() - source_position.x, destination_image.get_width() - safe_destination.x),
		mini(source_image.get_height() - source_position.y, destination_image.get_height() - safe_destination.y)
	)
	if copy_size.x <= 0 or copy_size.y <= 0:
		return
	destination_image.blit_rect(source_image, Rect2i(source_position, copy_size), safe_destination)


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
