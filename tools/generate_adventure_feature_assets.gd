extends SceneTree

const OUT_DIR := "res://assets/art/minigames/adventure/"
const SIZE := 32
const TRANSPARENT := Color(0, 0, 0, 0)
const DARK := Color8(8, 10, 22, 255)
const OUTLINE := Color8(18, 16, 54, 255)
const CYAN := Color8(74, 232, 255, 255)
const CYAN_DIM := Color8(35, 118, 168, 255)
const BLUE := Color8(57, 95, 226, 255)
const GREEN := Color8(91, 255, 164, 255)
const AMBER := Color8(255, 210, 82, 255)
const RED := Color8(255, 75, 98, 255)
const PINK := Color8(255, 91, 217, 255)
const VIOLET := Color8(167, 99, 255, 255)
const WHITE := Color8(236, 252, 255, 255)

func _init() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	_save(_service_cell(), "service_cell.png")
	_save(_power_gate(), "power_gate.png")
	_save(_service_beacon(), "service_beacon.png")
	_save(_memory_anchor(), "memory_anchor.png")
	_save(_memory_lock(), "memory_lock.png")
	_save(_memory_beacon(), "memory_beacon.png")
	print("Generated adventure feature assets.")
	quit()

func _new_image() -> Image:
	var image := Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	image.fill(TRANSPARENT)
	return image

func _save(image: Image, file_name: String) -> void:
	var error := image.save_png(OUT_DIR + file_name)
	if error != OK:
		push_error("Could not save adventure feature asset: %s" % file_name)

func _service_cell() -> Image:
	var image := _new_image()
	_rect(image, 7, 10, 18, 14, OUTLINE)
	_rect(image, 9, 12, 14, 10, CYAN_DIM)
	_rect(image, 11, 14, 10, 6, CYAN)
	_rect(image, 13, 8, 6, 3, OUTLINE)
	_rect(image, 14, 7, 4, 2, AMBER)
	_rect(image, 12, 15, 3, 3, WHITE)
	_rect(image, 20, 18, 2, 2, AMBER)
	_line(image, 5, 25, 27, 25, BLUE, 2)
	return image

func _power_gate() -> Image:
	var image := _new_image()
	_rect(image, 5, 8, 6, 18, OUTLINE)
	_rect(image, 21, 8, 6, 18, OUTLINE)
	_rect(image, 7, 10, 2, 14, RED)
	_rect(image, 23, 10, 2, 14, RED)
	_rect(image, 10, 12, 12, 3, RED)
	_rect(image, 10, 18, 12, 3, RED)
	_rect(image, 13, 13, 6, 7, DARK)
	_rect(image, 14, 15, 4, 3, AMBER)
	_rect(image, 15, 16, 2, 4, AMBER)
	_rect(image, 9, 5, 14, 2, CYAN)
	_rect(image, 9, 27, 14, 2, CYAN_DIM)
	return image

func _service_beacon() -> Image:
	var image := _new_image()
	_rect(image, 8, 21, 16, 5, OUTLINE)
	_rect(image, 10, 22, 12, 2, GREEN)
	_rect(image, 13, 11, 6, 11, OUTLINE)
	_rect(image, 15, 13, 2, 8, CYAN)
	_rect(image, 12, 7, 8, 6, OUTLINE)
	_rect(image, 14, 8, 4, 4, GREEN)
	_rect(image, 9, 5, 3, 3, CYAN)
	_rect(image, 21, 6, 3, 3, CYAN)
	_line(image, 5, 27, 27, 27, CYAN_DIM, 2)
	return image

func _memory_anchor() -> Image:
	var image := _new_image()
	_rect(image, 8, 6, 16, 20, OUTLINE)
	_rect(image, 10, 8, 12, 16, VIOLET)
	_rect(image, 12, 10, 8, 12, DARK)
	_rect(image, 14, 12, 4, 8, BLUE)
	_rect(image, 15, 13, 2, 6, CYAN)
	_rect(image, 6, 14, 4, 4, PINK)
	_rect(image, 22, 14, 4, 4, CYAN)
	_rect(image, 12, 3, 8, 3, WHITE)
	_line(image, 6, 27, 26, 27, VIOLET, 2)
	return image

func _memory_lock() -> Image:
	var image := _new_image()
	_line(image, 10, 13, 10, 8, VIOLET, 3)
	_line(image, 10, 8, 22, 8, VIOLET, 3)
	_line(image, 22, 8, 22, 13, VIOLET, 3)
	_rect(image, 7, 13, 18, 14, OUTLINE)
	_rect(image, 9, 15, 14, 10, PINK)
	_rect(image, 13, 17, 6, 5, DARK)
	_rect(image, 15, 21, 2, 3, DARK)
	_rect(image, 10, 16, 3, 2, WHITE)
	_rect(image, 21, 4, 3, 3, CYAN)
	_rect(image, 6, 5, 3, 3, VIOLET)
	return image

func _memory_beacon() -> Image:
	var image := _new_image()
	_rect(image, 9, 23, 14, 4, OUTLINE)
	_rect(image, 11, 24, 10, 2, VIOLET)
	_line(image, 16, 22, 16, 12, CYAN, 2)
	_line(image, 16, 12, 12, 8, CYAN, 2)
	_line(image, 16, 12, 20, 8, VIOLET, 2)
	_rect(image, 13, 10, 6, 5, WHITE)
	_rect(image, 14, 11, 4, 3, CYAN)
	_rect(image, 7, 15, 3, 3, PINK)
	_rect(image, 22, 15, 3, 3, CYAN)
	_rect(image, 5, 21, 3, 2, VIOLET)
	_rect(image, 24, 21, 3, 2, VIOLET)
	return image

func _rect(image: Image, x: int, y: int, width: int, height: int, color: Color) -> void:
	var x0 := clampi(x, 0, image.get_width())
	var y0 := clampi(y, 0, image.get_height())
	var x1 := clampi(x + width, 0, image.get_width())
	var y1 := clampi(y + height, 0, image.get_height())
	for py in range(y0, y1):
		for px in range(x0, x1):
			image.set_pixel(px, py, color)

func _line(image: Image, x0: int, y0: int, x1: int, y1: int, color: Color, thickness: int = 1) -> void:
	var dx := absi(x1 - x0)
	var sx := 1 if x0 < x1 else -1
	var dy := -absi(y1 - y0)
	var sy := 1 if y0 < y1 else -1
	var err := dx + dy
	var x := x0
	var y := y0
	while true:
		_rect(image, x - thickness / 2, y - thickness / 2, thickness, thickness, color)
		if x == x1 and y == y1:
			break
		var e2 := 2 * err
		if e2 >= dy:
			err += dy
			x += sx
		if e2 <= dx:
			err += dx
			y += sy
