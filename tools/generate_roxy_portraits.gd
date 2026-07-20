extends SceneTree

const OUT_DIR := "res://assets/art/portraits/roxy/"
const SIZE := 96

const TRANSPARENT := Color(0, 0, 0, 0)
const OUTLINE := Color8(18, 12, 66, 255)
const DEEP_BLUE := Color8(23, 45, 142, 255)
const BLUE := Color8(35, 96, 222, 255)
const CYAN_DARK := Color8(20, 165, 214, 255)
const CYAN := Color8(50, 221, 245, 255)
const CYAN_LIGHT := Color8(139, 252, 255, 255)
const MAGENTA_DARK := Color8(139, 25, 176, 255)
const MAGENTA := Color8(236, 37, 216, 255)
const HOT_PINK := Color8(255, 87, 220, 255)
const SOFT_PINK := Color8(255, 151, 228, 255)
const WHITE := Color8(235, 252, 255, 255)

func _init() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	_make_portrait("roxy_smug.png", "smug")
	_make_portrait("roxy_respectful.png", "respectful")
	_make_portrait("roxy_focused.png", "focused")
	_make_portrait("roxy_startled.png", "startled")
	_make_portrait("roxy_uneasy.png", "uneasy")
	_make_portrait("roxy_sincere.png", "sincere")
	print("Generated Roxy dialogue portraits.")
	quit()

func _make_portrait(file_name: String, expression: String) -> void:
	var image := Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	image.fill(TRANSPARENT)
	_draw_roxy(image, expression)
	var error := image.save_png(OUT_DIR + file_name)
	if error != OK:
		push_error("Could not save Roxy portrait: %s" % file_name)

func _draw_roxy(image: Image, expression: String) -> void:
	_draw_body(image, expression)
	_draw_hair_back(image)
	_draw_face(image)
	_draw_hair_front(image)
	_draw_expression(image, expression)
	_draw_arcade_glow(image, expression)

func _draw_body(image: Image, expression: String) -> void:
	_rect(image, 32, 73, 32, 9, OUTLINE)
	_rect(image, 28, 81, 40, 10, OUTLINE)
	_rect(image, 36, 69, 24, 14, CYAN_DARK)
	_rect(image, 30, 82, 36, 8, BLUE)
	_rect(image, 42, 73, 12, 9, CYAN)
	_rect(image, 36, 86, 24, 4, DEEP_BLUE)
	if expression == "focused":
		_rect(image, 26, 84, 8, 4, HOT_PINK)
	elif expression == "respectful" or expression == "sincere":
		_rect(image, 58, 82, 8, 5, SOFT_PINK)
	else:
		_rect(image, 60, 83, 7, 5, MAGENTA)

func _draw_hair_back(image: Image) -> void:
	_ellipse(image, 48, 30, 31, 18, OUTLINE)
	_ellipse(image, 49, 31, 28, 15, MAGENTA_DARK)
	_rect(image, 18, 33, 19, 31, OUTLINE)
	_rect(image, 21, 35, 15, 28, MAGENTA_DARK)
	_rect(image, 63, 30, 17, 38, OUTLINE)
	_rect(image, 63, 33, 14, 33, MAGENTA_DARK)
	_rect(image, 25, 22, 52, 10, OUTLINE)
	_rect(image, 28, 20, 46, 9, MAGENTA)
	_rect(image, 34, 16, 31, 9, HOT_PINK)
	_rect(image, 68, 24, 15, 8, MAGENTA)
	_rect(image, 16, 42, 12, 16, MAGENTA)
	_rect(image, 70, 46, 13, 17, MAGENTA)

func _draw_face(image: Image) -> void:
	_ellipse(image, 48, 48, 24, 27, OUTLINE)
	_ellipse(image, 48, 49, 21, 24, CYAN_DARK)
	_ellipse(image, 50, 47, 18, 22, CYAN)
	_rect(image, 31, 50, 6, 12, BLUE)
	_rect(image, 62, 49, 5, 14, CYAN_LIGHT)
	_rect(image, 44, 66, 15, 5, CYAN_LIGHT)
	_rect(image, 35, 36, 8, 5, CYAN_LIGHT)
	_rect(image, 56, 38, 7, 4, Color8(91, 236, 255, 255))

func _draw_hair_front(image: Image) -> void:
	_rect(image, 25, 29, 32, 9, OUTLINE)
	_rect(image, 28, 28, 30, 8, MAGENTA)
	_rect(image, 41, 27, 31, 8, OUTLINE)
	_rect(image, 43, 26, 28, 7, HOT_PINK)
	_rect(image, 26, 36, 15, 12, MAGENTA)
	_rect(image, 30, 45, 9, 24, OUTLINE)
	_rect(image, 32, 46, 7, 21, MAGENTA)
	_rect(image, 61, 33, 14, 12, HOT_PINK)
	_rect(image, 67, 43, 9, 22, OUTLINE)
	_rect(image, 66, 44, 8, 20, MAGENTA)
	_rect(image, 38, 24, 23, 4, SOFT_PINK)
	_rect(image, 57, 31, 10, 5, SOFT_PINK)
	_rect(image, 24, 38, 5, 9, HOT_PINK)

func _draw_expression(image: Image, expression: String) -> void:
	match expression:
		"respectful":
			_brow(image, 35, 42, 11, 0)
			_brow(image, 55, 42, 11, 0)
			_eye_soft(image, 36, 48)
			_eye_soft(image, 56, 48)
			_mouth_line(image, 44, 63, 10, 0)
			_rect(image, 37, 59, 4, 2, SOFT_PINK)
		"focused":
			_brow(image, 34, 42, 13, -1)
			_brow(image, 55, 40, 13, 1)
			_eye_narrow(image, 35, 48, true)
			_eye_narrow(image, 56, 48, false)
			_mouth_line(image, 43, 63, 14, 0)
			_rect(image, 61, 58, 5, 2, BLUE)
		"startled":
			_brow(image, 34, 40, 11, -2)
			_brow(image, 56, 40, 11, 2)
			_eye_wide(image, 35, 47)
			_eye_wide(image, 56, 47)
			_rect(image, 47, 61, 8, 8, OUTLINE)
			_rect(image, 49, 63, 4, 4, SOFT_PINK)
			_rect(image, 30, 58, 5, 2, CYAN_LIGHT)
		"uneasy":
			_brow(image, 34, 41, 12, 1)
			_brow(image, 56, 43, 11, -1)
			_eye_soft(image, 36, 48)
			_eye_narrow(image, 56, 49, false)
			_mouth_line(image, 44, 64, 12, -1)
			_rect(image, 66, 55, 3, 5, CYAN_LIGHT)
			_rect(image, 67, 61, 2, 2, CYAN_LIGHT)
		"sincere":
			_brow(image, 35, 42, 11, 1)
			_brow(image, 55, 42, 11, -1)
			_eye_soft(image, 36, 48)
			_eye_soft(image, 56, 48)
			_rect(image, 43, 62, 14, 4, OUTLINE)
			_rect(image, 45, 62, 10, 2, SOFT_PINK)
			_rect(image, 47, 65, 6, 2, SOFT_PINK)
			_rect(image, 35, 58, 5, 2, SOFT_PINK)
			_rect(image, 59, 58, 5, 2, SOFT_PINK)
		_:
			_brow(image, 34, 42, 13, -1)
			_brow(image, 55, 41, 13, 1)
			_eye_narrow(image, 35, 48, true)
			_eye_soft(image, 57, 48)
			_rect(image, 44, 62, 15, 5, OUTLINE)
			_rect(image, 47, 63, 10, 2, SOFT_PINK)
			_rect(image, 57, 61, 3, 2, HOT_PINK)

func _draw_arcade_glow(image: Image, expression: String) -> void:
	_rect(image, 21, 62, 4, 5, BLUE)
	_rect(image, 73, 67, 5, 4, CYAN_LIGHT)
	_rect(image, 27, 73, 5, 3, HOT_PINK)
	_rect(image, 66, 76, 6, 3, CYAN)
	if expression == "startled" or expression == "uneasy":
		_rect(image, 22, 27, 6, 2, CYAN_LIGHT)
		_rect(image, 73, 22, 5, 3, BLUE)
	if expression == "sincere":
		_rect(image, 39, 19, 8, 3, SOFT_PINK)

func _eye_soft(image: Image, x: int, y: int) -> void:
	_rect(image, x, y, 12, 6, OUTLINE)
	_rect(image, x + 2, y + 1, 7, 3, CYAN_LIGHT)
	_rect(image, x + 7, y + 2, 3, 3, DEEP_BLUE)
	_rect(image, x + 8, y + 1, 2, 2, WHITE)

func _eye_narrow(image: Image, x: int, y: int, left: bool) -> void:
	_rect(image, x, y, 13, 4, OUTLINE)
	if left:
		_rect(image, x + 2, y + 1, 6, 2, CYAN_LIGHT)
	else:
		_rect(image, x + 5, y + 1, 6, 2, CYAN_LIGHT)

func _eye_wide(image: Image, x: int, y: int) -> void:
	_rect(image, x, y, 12, 9, OUTLINE)
	_rect(image, x + 2, y + 2, 8, 5, WHITE)
	_rect(image, x + 5, y + 3, 4, 4, DEEP_BLUE)
	_rect(image, x + 7, y + 2, 2, 2, CYAN_LIGHT)

func _brow(image: Image, x: int, y: int, width: int, slant: int) -> void:
	if slant == 0:
		_rect(image, x, y, width, 3, OUTLINE)
		return
	var y2 := y + slant
	_line(image, x, y, x + width, y2, OUTLINE, 3)

func _mouth_line(image: Image, x: int, y: int, width: int, slant: int) -> void:
	_line(image, x, y, x + width, y + slant, OUTLINE, 3)
	_line(image, x + 2, y - 1, x + width - 2, y + slant - 1, SOFT_PINK, 1)

func _rect(image: Image, x: int, y: int, width: int, height: int, color: Color) -> void:
	var x0 := clampi(x, 0, image.get_width())
	var y0 := clampi(y, 0, image.get_height())
	var x1 := clampi(x + width, 0, image.get_width())
	var y1 := clampi(y + height, 0, image.get_height())
	for py in range(y0, y1):
		for px in range(x0, x1):
			image.set_pixel(px, py, color)

func _ellipse(image: Image, cx: int, cy: int, rx: int, ry: int, color: Color) -> void:
	for y in range(-ry, ry + 1):
		for x in range(-rx, rx + 1):
			var nx := float(x) / float(rx)
			var ny := float(y) / float(ry)
			if nx * nx + ny * ny <= 1.0:
				var px := cx + x
				var py := cy + y
				if px >= 0 and py >= 0 and px < image.get_width() and py < image.get_height():
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
