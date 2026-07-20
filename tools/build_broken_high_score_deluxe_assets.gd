extends SceneTree

const BACKGROUND_MASTER := "res://assets/art/minigames/broken_high_score/generated/broken_high_score_deluxe_background_master.png"
const SPRITE_SHEET := "res://assets/art/minigames/broken_high_score/generated/broken_high_score_deluxe_sprite_sheet.png"
const BACKGROUND_OUTPUT := "res://assets/art/minigames/broken_high_score/broken_high_score_deluxe.png"
const SPRITE_OUTPUTS := [
	{
		"path": "res://assets/art/minigames/broken_high_score/sprites/roxy_score_rival.png",
		"canvas_size": Vector2i(84, 140),
		"max_size": Vector2i(72, 132),
	},
	{
		"path": "res://assets/art/minigames/broken_high_score/sprites/broken_score_cabinet_deluxe.png",
		"canvas_size": Vector2i(96, 144),
		"max_size": Vector2i(86, 136),
	},
]


func _initialize() -> void:
	var success := _build_background()
	success = _build_sprites() and success
	quit(0 if success else 1)


func _build_background() -> bool:
	var image := Image.load_from_file(BACKGROUND_MASTER)
	if image.is_empty():
		push_error("Could not load Broken High Score background master: %s" % BACKGROUND_MASTER)
		return false
	image.resize(640, 440, Image.INTERPOLATE_NEAREST)
	var error := image.save_png(BACKGROUND_OUTPUT)
	if error != OK:
		push_error("Could not save Broken High Score background: %s" % error_string(error))
		return false
	print("Built %s" % BACKGROUND_OUTPUT)
	return true


func _build_sprites() -> bool:
	var sheet := Image.load_from_file(SPRITE_SHEET)
	if sheet.is_empty():
		push_error("Could not load Broken High Score sprite sheet: %s" % SPRITE_SHEET)
		return false
	var cell_size := Vector2i(sheet.get_width() / 2, sheet.get_height())
	var success := true
	for index in SPRITE_OUTPUTS.size():
		var definition: Dictionary = SPRITE_OUTPUTS[index]
		var cell := sheet.get_region(Rect2i(Vector2i(index * cell_size.x, 0), cell_size))
		var sprite := _fit_on_canvas(cell, definition["canvas_size"], definition["max_size"])
		var output_path: String = definition["path"]
		var error := sprite.save_png(output_path)
		if error != OK:
			push_error("Could not save %s: %s" % [output_path, error_string(error)])
			success = false
		else:
			print("Built %s" % output_path)
	return success


func _fit_on_canvas(source: Image, canvas_size: Vector2i, max_size: Vector2i) -> Image:
	var used_rect := source.get_used_rect()
	if used_rect.size == Vector2i.ZERO:
		return Image.create_empty(canvas_size.x, canvas_size.y, false, Image.FORMAT_RGBA8)
	var trimmed := source.get_region(used_rect)
	var scale_factor: float = minf(
		float(max_size.x) / float(trimmed.get_width()),
		float(max_size.y) / float(trimmed.get_height())
	)
	var output_size := Vector2i(
		maxi(1, roundi(trimmed.get_width() * scale_factor)),
		maxi(1, roundi(trimmed.get_height() * scale_factor))
	)
	trimmed.resize(output_size.x, output_size.y, Image.INTERPOLATE_NEAREST)
	var canvas := Image.create_empty(canvas_size.x, canvas_size.y, false, Image.FORMAT_RGBA8)
	canvas.fill(Color.TRANSPARENT)
	var destination := (canvas_size - output_size) / 2
	canvas.blend_rect(trimmed, Rect2i(Vector2i.ZERO, output_size), destination)
	return canvas
