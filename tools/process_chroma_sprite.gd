extends SceneTree

## Converts a generated flat-background sprite into a tightly framed, transparent
## pixel asset. Usage:
## godot --headless --path . --script res://tools/process_chroma_sprite.gd -- input output width height

const TRANSPARENT_DISTANCE := 0.10
const OPAQUE_DISTANCE := 0.28
const CANVAS_PADDING := 4


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() != 4:
		push_error("Expected: input_path output_path width height")
		quit(1)
		return
	var source_path := str(args[0])
	var output_path := str(args[1])
	var target_size := Vector2i(int(args[2]), int(args[3]))
	var result := _process_sprite(source_path, output_path, target_size)
	quit(0 if result else 1)


func _process_sprite(source_path: String, output_path: String, target_size: Vector2i) -> bool:
	var source := Image.load_from_file(source_path)
	if source == null or source.is_empty():
		push_error("Could not load chroma sprite: %s" % source_path)
		return false
	if target_size.x <= CANVAS_PADDING * 2 or target_size.y <= CANVAS_PADDING * 2:
		push_error("Target canvas is too small: %s" % target_size)
		return false
	source.convert(Image.FORMAT_RGBA8)
	var key := source.get_pixel(0, 0)
	var bounds := Rect2i(source.get_width(), source.get_height(), 0, 0)
	var found_subject := false
	for y in range(source.get_height()):
		for x in range(source.get_width()):
			var pixel := source.get_pixel(x, y)
			var distance := Vector3(pixel.r, pixel.g, pixel.b).distance_to(Vector3(key.r, key.g, key.b))
			pixel.a = smoothstep(TRANSPARENT_DISTANCE, OPAQUE_DISTANCE, distance)
			if pixel.a < 1.0 and pixel.g > maxf(pixel.r, pixel.b):
				pixel.g = lerpf(maxf(pixel.r, pixel.b), pixel.g, pixel.a)
			source.set_pixel(x, y, pixel)
			if pixel.a <= 0.05:
				continue
			if not found_subject:
				bounds = Rect2i(x, y, 1, 1)
				found_subject = true
			else:
				bounds = bounds.merge(Rect2i(x, y, 1, 1))
	if not found_subject:
		push_error("No subject remained after chroma removal: %s" % source_path)
		return false
	var subject := source.get_region(bounds.grow(2).intersection(Rect2i(Vector2i.ZERO, source.get_size())))
	var usable := target_size - Vector2i(CANVAS_PADDING * 2, CANVAS_PADDING * 2)
	var scale_factor := minf(float(usable.x) / subject.get_width(), float(usable.y) / subject.get_height())
	var scaled_size := Vector2i(
		maxi(1, roundi(subject.get_width() * scale_factor)),
		maxi(1, roundi(subject.get_height() * scale_factor))
	)
	subject.resize(scaled_size.x, scaled_size.y, Image.INTERPOLATE_NEAREST)
	var canvas := Image.create_empty(target_size.x, target_size.y, false, Image.FORMAT_RGBA8)
	canvas.fill(Color.TRANSPARENT)
	var destination := (target_size - scaled_size) / 2
	canvas.blit_rect(subject, Rect2i(Vector2i.ZERO, scaled_size), destination)
	var output_directory := output_path.get_base_dir()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_directory))
	var error := canvas.save_png(output_path)
	if error != OK:
		push_error("Could not save processed sprite: %s" % output_path)
		return false
	print("Processed sprite: %s (%dx%d)" % [output_path, target_size.x, target_size.y])
	return true
