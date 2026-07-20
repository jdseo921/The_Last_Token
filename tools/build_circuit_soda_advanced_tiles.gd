extends SceneTree

# Normalizes the generated 2x2 source atlas into four Godot-ready 32x32 cells.
# Run:
#   godot --headless --path . --script res://tools/build_circuit_soda_advanced_tiles.gd

const SOURCE_PATH := "res://assets/art/minigames/circuit_soda/circuit_soda_advanced_tiles_transparent.png"
const OUTPUT_PATH := "res://assets/art/minigames/circuit_soda/circuit_soda_advanced_tiles_sheet.png"
const CELL_SIZE := 32
const SPRITE_SIZE := 30

func _init() -> void:
	var source := Image.load_from_file(SOURCE_PATH)
	if source == null or source.is_empty():
		push_error("Circuit Soda advanced source atlas could not be loaded.")
		quit(1)
		return

	var quadrant_size := Vector2i(source.get_width() / 2, source.get_height() / 2)
	var output := Image.create(CELL_SIZE * 2, CELL_SIZE * 2, false, Image.FORMAT_RGBA8)
	output.fill(Color.TRANSPARENT)
	for row in range(2):
		for column in range(2):
			var quadrant_rect := Rect2i(Vector2i(column, row) * quadrant_size, quadrant_size)
			var quadrant := source.get_region(quadrant_rect)
			var used_rect := quadrant.get_used_rect()
			if used_rect.size.x <= 0 or used_rect.size.y <= 0:
				push_error("Generated atlas cell %d,%d is empty." % [column, row])
				quit(1)
				return
			var sprite := quadrant.get_region(used_rect)
			var scale_factor := minf(float(SPRITE_SIZE) / sprite.get_width(), float(SPRITE_SIZE) / sprite.get_height())
			var target_size := Vector2i(
				maxi(int(round(sprite.get_width() * scale_factor)), 1),
				maxi(int(round(sprite.get_height() * scale_factor)), 1)
			)
			sprite.resize(target_size.x, target_size.y, Image.INTERPOLATE_NEAREST)
			var cell_origin := Vector2i(column, row) * CELL_SIZE
			var centered_offset := Vector2i((CELL_SIZE - target_size.x) / 2, (CELL_SIZE - target_size.y) / 2)
			output.blend_rect(sprite, Rect2i(Vector2i.ZERO, target_size), cell_origin + centered_offset)

	var error := output.save_png(OUTPUT_PATH)
	if error != OK:
		push_error("Could not save Circuit Soda advanced tile sheet: %s" % error_string(error))
		quit(1)
		return
	print("Circuit Soda advanced tile sheet written to %s" % OUTPUT_PATH)
	quit(0)
