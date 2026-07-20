extends SceneTree

const BACKGROUND_MASTER := "res://assets/art/minigames/truth_filter/generated/truth_filter_verdict_chamber_master.png"
const CABINET_MASTER := "res://assets/art/minigames/truth_filter/generated/truth_filter_deluxe_cabinet_states_transparent.png"
const BACKGROUND_OUTPUT := "res://assets/art/minigames/truth_filter/backgrounds/truth_filter_verdict_chamber.png"
const CABINET_OUTPUT := "res://assets/art/minigames/truth_filter/truth_filter_deluxe_cabinet_states.png"
const BACKGROUND_SIZE := Vector2i(640, 440)
const CABINET_FRAME_SIZE := Vector2i(104, 144)
const CABINET_MAX_SIZE := Vector2i(96, 136)
const CABINET_STATE_COUNT := 4


func _initialize() -> void:
	var success := _build_background()
	success = _build_cabinet_sheet() and success
	quit(0 if success else 1)


func _build_background() -> bool:
	var image := Image.load_from_file(BACKGROUND_MASTER)
	if image.is_empty():
		push_error("Could not load Truth Filter background master: %s" % BACKGROUND_MASTER)
		return false
	image.resize(BACKGROUND_SIZE.x, BACKGROUND_SIZE.y, Image.INTERPOLATE_NEAREST)
	var error := image.save_png(BACKGROUND_OUTPUT)
	if error != OK:
		push_error("Could not save Truth Filter background: %s" % error_string(error))
		return false
	print("Built %s" % BACKGROUND_OUTPUT)
	return true


func _build_cabinet_sheet() -> bool:
	var source := Image.load_from_file(CABINET_MASTER)
	if source.is_empty():
		push_error("Could not load Truth Filter cabinet master: %s" % CABINET_MASTER)
		return false
	var output := Image.create_empty(
		CABINET_FRAME_SIZE.x * CABINET_STATE_COUNT,
		CABINET_FRAME_SIZE.y,
		false,
		Image.FORMAT_RGBA8
	)
	output.fill(Color.TRANSPARENT)
	for index in CABINET_STATE_COUNT:
		var x_start := roundi(float(index) * source.get_width() / CABINET_STATE_COUNT)
		var x_end := roundi(float(index + 1) * source.get_width() / CABINET_STATE_COUNT)
		var cell := source.get_region(Rect2i(x_start, 0, x_end - x_start, source.get_height()))
		var frame := _fit_on_canvas(cell, CABINET_FRAME_SIZE, CABINET_MAX_SIZE)
		output.blend_rect(
			frame,
			Rect2i(Vector2i.ZERO, CABINET_FRAME_SIZE),
			Vector2i(index * CABINET_FRAME_SIZE.x, 0)
		)
	var error := output.save_png(CABINET_OUTPUT)
	if error != OK:
		push_error("Could not save Truth Filter cabinet sheet: %s" % error_string(error))
		return false
	print("Built %s" % CABINET_OUTPUT)
	return true


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
