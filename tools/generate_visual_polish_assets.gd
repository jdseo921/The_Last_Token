extends SceneTree

const PANEL_DIR := "res://assets/art/cutscenes/memory_reveal/"
const HUB_PROPS_DIR := "res://assets/art/hub/props/"
const ADVENTURE_DIR := "res://assets/art/minigames/adventure/"
const SECURITY_TAPE_DIR := "res://assets/art/minigames/security_tape/"
const ROCKBYTE_BG_DIR := "res://assets/art/minigames/rockbyte_duel/backgrounds/"
const AMBIENT_EFFECTS_DIR := "res://assets/art/effects/ambient/"
const SFX_DIR := "res://assets/audio/sfx/"

const DARK := Color8(4, 5, 9, 255)
const TRANSPARENT := Color(0, 0, 0, 0)

const FONT := {
	" ": ["000", "000", "000", "000", "000", "000", "000"],
	"0": ["111", "101", "101", "101", "101", "101", "111"],
	"1": ["010", "110", "010", "010", "010", "010", "111"],
	"2": ["111", "001", "001", "111", "100", "100", "111"],
	"3": ["111", "001", "001", "111", "001", "001", "111"],
	"4": ["101", "101", "101", "111", "001", "001", "001"],
	"5": ["111", "100", "100", "111", "001", "001", "111"],
	"6": ["111", "100", "100", "111", "101", "101", "111"],
	"7": ["111", "001", "001", "010", "010", "100", "100"],
	"8": ["111", "101", "101", "111", "101", "101", "111"],
	"9": ["111", "101", "101", "111", "001", "001", "111"],
	"A": ["01110", "10001", "10001", "11111", "10001", "10001", "10001"],
	"B": ["11110", "10001", "10001", "11110", "10001", "10001", "11110"],
	"C": ["01111", "10000", "10000", "10000", "10000", "10000", "01111"],
	"D": ["11110", "10001", "10001", "10001", "10001", "10001", "11110"],
	"E": ["11111", "10000", "10000", "11110", "10000", "10000", "11111"],
	"F": ["11111", "10000", "10000", "11110", "10000", "10000", "10000"],
	"G": ["01111", "10000", "10000", "10111", "10001", "10001", "01111"],
	"H": ["10001", "10001", "10001", "11111", "10001", "10001", "10001"],
	"I": ["111", "010", "010", "010", "010", "010", "111"],
	"J": ["00111", "00010", "00010", "00010", "10010", "10010", "01100"],
	"K": ["10001", "10010", "10100", "11000", "10100", "10010", "10001"],
	"L": ["10000", "10000", "10000", "10000", "10000", "10000", "11111"],
	"M": ["10001", "11011", "10101", "10101", "10001", "10001", "10001"],
	"N": ["10001", "11001", "10101", "10011", "10001", "10001", "10001"],
	"O": ["01110", "10001", "10001", "10001", "10001", "10001", "01110"],
	"P": ["11110", "10001", "10001", "11110", "10000", "10000", "10000"],
	"Q": ["01110", "10001", "10001", "10001", "10101", "10010", "01101"],
	"R": ["11110", "10001", "10001", "11110", "10100", "10010", "10001"],
	"S": ["01111", "10000", "10000", "01110", "00001", "00001", "11110"],
	"T": ["11111", "00100", "00100", "00100", "00100", "00100", "00100"],
	"U": ["10001", "10001", "10001", "10001", "10001", "10001", "01110"],
	"V": ["10001", "10001", "10001", "10001", "10001", "01010", "00100"],
	"W": ["10001", "10001", "10001", "10101", "10101", "11011", "10001"],
	"X": ["10001", "10001", "01010", "00100", "01010", "10001", "10001"],
	"Y": ["10001", "10001", "01010", "00100", "00100", "00100", "00100"],
	"Z": ["11111", "00001", "00010", "00100", "01000", "10000", "11111"],
	"?": ["111", "001", "001", "010", "010", "000", "010"],
	"-": ["0000", "0000", "0000", "1111", "0000", "0000", "0000"],
}

func _init() -> void:
	_ensure_directories()
	_generate_memory_panels()
	_generate_hub_props()
	_generate_adventure_sprites()
	_generate_security_tape_art()
	_generate_rockbyte_background()
	_generate_ambient_effect_sprites()
	_generate_sfx()
	print("Generated visual polish assets.")
	quit()

func _ensure_directories() -> void:
	for path in [PANEL_DIR, HUB_PROPS_DIR, ADVENTURE_DIR, SECURITY_TAPE_DIR, ROCKBYTE_BG_DIR, AMBIENT_EFFECTS_DIR, SFX_DIR]:
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path))

func _new_image(width: int, height: int, color: Color) -> Image:
	var image := Image.create(width, height, false, Image.FORMAT_RGBA8)
	image.fill(color)
	return image

func _save_png(image: Image, path: String) -> void:
	var error := image.save_png(path)
	if error != OK:
		push_error("Could not save PNG: %s" % path)

func _mono_panel(ink: Color) -> Image:
	var image := _new_image(320, 180, DARK)
	var dim := _tone(ink, 0.22)
	var mid := _tone(ink, 0.48)
	for y in range(14, 166, 6):
		_rect(image, 12, y, 296, 1, dim)
	_outline_rect(image, 8, 8, 304, 164, ink)
	_outline_rect(image, 14, 14, 292, 152, mid)
	_rect(image, 8, 8, 26, 3, ink)
	_rect(image, 286, 169, 26, 3, ink)
	return image

func _generate_memory_panels() -> void:
	var inks := [
		Color8(79, 227, 255, 255),
		Color8(108, 255, 184, 255),
		Color8(255, 203, 77, 255),
		Color8(255, 93, 132, 255),
		Color8(154, 138, 255, 255),
		Color8(122, 255, 148, 255),
		Color8(180, 206, 255, 255),
		Color8(255, 245, 166, 255),
	]
	for index in range(8):
		var image := _mono_panel(inks[index])
		match index:
			0:
				_draw_panel_staff_door(image, inks[index])
			1:
				_draw_panel_inside_room(image, inks[index])
			2:
				_draw_panel_shutdown(image, inks[index])
			3:
				_draw_panel_machine_panic(image, inks[index])
			4:
				_draw_panel_system_save(image, inks[index])
			5:
				_draw_panel_everyone_remembers(image, inks[index])
			6:
				_draw_panel_player_forgot(image, inks[index])
			_:
				_draw_panel_employee_04(image, inks[index])
		_save_png(image, PANEL_DIR + "panel_%02d.png" % (index + 1))

func _draw_panel_staff_door(image: Image, ink: Color) -> void:
	var dim := _tone(ink, 0.35)
	_outline_rect(image, 116, 32, 88, 108, ink)
	_rect(image, 128, 44, 64, 84, dim)
	_text(image, "STAFF", 133, 52, 2, ink)
	_rect(image, 178, 88, 8, 8, ink)
	_draw_person(image, Vector2i(74, 120), ink, 2, false)
	_line(image, 88, 116, 116, 96, ink, 2)
	_line(image, 88, 124, 116, 118, dim, 2)
	_text(image, "LOCK", 232, 92, 2, ink)

func _draw_panel_inside_room(image: Image, ink: Color) -> void:
	var dim := _tone(ink, 0.35)
	_outline_rect(image, 40, 34, 72, 94, ink)
	_line(image, 112, 34, 138, 48, ink, 2)
	_line(image, 112, 128, 138, 112, ink, 2)
	_outline_rect(image, 152, 54, 92, 48, ink)
	_rect(image, 162, 64, 72, 28, dim)
	_outline_rect(image, 188, 106, 42, 26, ink)
	_text(image, "FILE", 194, 114, 2, ink)
	_draw_person(image, Vector2i(84, 106), ink, 2, false)
	_rect(image, 256, 56, 22, 10, dim)
	_rect(image, 264, 74, 22, 10, dim)
	_text(image, "INSIDE", 136, 144, 2, ink)

func _draw_panel_shutdown(image: Image, ink: Color) -> void:
	var dim := _tone(ink, 0.34)
	_outline_rect(image, 46, 36, 104, 94, ink)
	_rect(image, 60, 50, 76, 40, dim)
	_line(image, 70, 66, 126, 66, ink, 1)
	_outline_rect(image, 196, 42, 60, 88, ink)
	_rect(image, 216, 58, 20, 48, dim)
	_line(image, 226, 96, 248, 66, ink, 4)
	_rect(image, 238, 58, 24, 20, ink)
	_line(image, 156, 130, 224, 84, ink, 5)
	_rect(image, 142, 124, 28, 16, ink)
	_text(image, "POWER", 72, 142, 2, ink)

func _draw_panel_machine_panic(image: Image, ink: Color) -> void:
	var dim := _tone(ink, 0.32)
	for x in [42, 102, 162, 222]:
		_outline_rect(image, x, 58, 46, 64, ink)
		_rect(image, x + 8, 68, 30, 24, dim)
		_rect(image, x + 18, 102, 10, 8, ink)
	_text(image, "!", 58, 74, 3, ink)
	_text(image, "!", 118, 74, 3, ink)
	_text(image, "!", 178, 74, 3, ink)
	_text(image, "!", 238, 74, 3, ink)
	for x in range(52, 268, 24):
		_line(image, x, 42, x + 10, 30, ink, 2)
		_line(image, x + 10, 30, x + 20, 42, ink, 2)
	_text(image, "PANIC", 112, 140, 2, ink)

func _draw_panel_system_save(image: Image, ink: Color) -> void:
	var dim := _tone(ink, 0.35)
	_outline_rect(image, 48, 52, 72, 76, ink)
	for y in [62, 80, 98]:
		_rect(image, 58, y, 52, 10, dim)
		_rect(image, 64, y + 3, 8, 4, ink)
	for i in range(8):
		_rect(image, 130 + i * 10, 86 - i * 3, 4, 4, ink)
	_disc(image, 226, 80, 30, dim)
	_disc(image, 226, 80, 18, DARK)
	_disc(image, 226, 80, 8, ink)
	_text(image, "SAVE", 68, 142, 2, ink)
	_text(image, "TOKEN", 190, 142, 2, ink)

func _draw_panel_everyone_remembers(image: Image, ink: Color) -> void:
	var dim := _tone(ink, 0.32)
	_disc(image, 160, 86, 18, ink)
	_disc(image, 160, 86, 8, DARK)
	_draw_person(image, Vector2i(82, 96), ink, 2, false)
	_draw_person(image, Vector2i(120, 126), dim, 2, false)
	_draw_machine(image, 218, 70, ink)
	_draw_machine(image, 232, 120, dim)
	_outline_rect(image, 68, 48, 34, 30, ink)
	_rect(image, 78, 58, 14, 8, dim)
	for point in [Vector2i(98, 94), Vector2i(130, 112), Vector2i(204, 82), Vector2i(210, 116)]:
		_line(image, point.x, point.y, 160, 86, ink, 1)
	_text(image, "REMEMBER", 100, 148, 2, ink)

func _draw_panel_player_forgot(image: Image, ink: Color) -> void:
	var dim := _tone(ink, 0.28)
	_draw_person(image, Vector2i(160, 96), ink, 3, true)
	for i in range(10):
		var x := 74 + i * 18
		var y := 42 + (i % 3) * 18
		_rect(image, x, y, 8, 8, dim)
		_line(image, x + 8, y + 4, 146, 78, dim, 1)
	_text(image, "MISSING", 104, 142, 2, ink)

func _draw_panel_employee_04(image: Image, ink: Color) -> void:
	var dim := _tone(ink, 0.34)
	_outline_rect(image, 82, 34, 156, 104, ink)
	_rect(image, 96, 48, 128, 20, dim)
	_text(image, "EMPLOYEE", 103, 52, 2, ink)
	_outline_rect(image, 100, 78, 48, 42, ink)
	_draw_person(image, Vector2i(124, 96), ink, 1, true)
	_text(image, "04", 164, 82, 6, ink)
	_line(image, 78, 144, 242, 144, ink, 2)
	_text(image, "WELCOME BACK", 84, 150, 2, ink)

func _generate_hub_props() -> void:
	var door := _new_image(64, 96, TRANSPARENT)
	var cyan := Color8(92, 235, 255, 255)
	var red := Color8(210, 56, 72, 255)
	var dark := Color8(9, 9, 16, 240)
	_rect(door, 6, 4, 52, 88, _tone(red, 0.35))
	_outline_rect(door, 6, 4, 52, 88, red)
	_rect(door, 14, 14, 28, 72, dark)
	_line(door, 42, 14, 56, 8, cyan, 2)
	_line(door, 42, 86, 56, 92, cyan, 2)
	_rect(door, 48, 42, 8, 12, cyan)
	_text(door, "OPEN", 14, 6, 1, cyan)
	_save_png(door, HUB_PROPS_DIR + "staff_door_open.png")

	var portrait := _new_image(48, 48, TRANSPARENT)
	var gold := Color8(255, 215, 104, 255)
	_rect(portrait, 0, 0, 48, 48, _tone(gold, 0.26))
	_outline_rect(portrait, 0, 0, 48, 48, gold)
	_outline_rect(portrait, 8, 6, 32, 26, gold)
	_draw_person(portrait, Vector2i(24, 18), gold, 1, true)
	_text(portrait, "EMP", 7, 35, 1, gold)
	_text(portrait, "04", 29, 35, 1, gold)
	_save_png(portrait, HUB_PROPS_DIR + "owner_portrait_employee04.png")

func _generate_adventure_sprites() -> void:
	var player := _new_image(16, 16, TRANSPARENT)
	var white := Color8(220, 244, 255, 255)
	_rect(player, 6, 2, 4, 4, white)
	_rect(player, 5, 6, 6, 6, white)
	_rect(player, 4, 12, 3, 3, white)
	_rect(player, 9, 12, 3, 3, white)
	_rect(player, 7, 3, 2, 2, DARK)
	_save_png(player, ADVENTURE_DIR + "player_8bit.png")

	var fuse := _new_image(16, 16, TRANSPARENT)
	var amber := Color8(255, 213, 74, 255)
	_rect(fuse, 5, 2, 6, 12, amber)
	_rect(fuse, 3, 4, 10, 2, amber)
	_rect(fuse, 3, 10, 10, 2, amber)
	_rect(fuse, 7, 5, 2, 6, DARK)
	_save_png(fuse, ADVENTURE_DIR + "signal_fuse.png")

	var leak := _new_image(16, 16, TRANSPARENT)
	var electric := Color8(70, 224, 255, 255)
	_line(leak, 8, 1, 4, 7, electric, 2)
	_line(leak, 4, 7, 9, 7, electric, 2)
	_line(leak, 9, 7, 5, 15, electric, 2)
	_save_png(leak, ADVENTURE_DIR + "static_leak.png")

	var breaker := _new_image(16, 16, TRANSPARENT)
	var green := Color8(70, 240, 142, 255)
	_outline_rect(breaker, 2, 2, 12, 12, green)
	_rect(breaker, 5, 5, 2, 6, green)
	_rect(breaker, 9, 4, 2, 8, green)
	_rect(breaker, 4, 12, 8, 1, green)
	_save_png(breaker, ADVENTURE_DIR + "breaker_panel.png")

	var frame := _new_image(16, 16, TRANSPARENT)
	var blue := Color8(116, 162, 255, 255)
	_outline_rect(frame, 3, 2, 10, 12, blue)
	_rect(frame, 5, 4, 6, 8, _tone(blue, 0.38))
	_rect(frame, 7, 6, 2, 4, blue)
	_save_png(frame, ADVENTURE_DIR + "memory_frame.png")

	var rewind := _new_image(16, 16, TRANSPARENT)
	var violet := Color8(230, 87, 255, 255)
	_line(rewind, 13, 3, 5, 8, violet, 2)
	_line(rewind, 5, 8, 13, 13, violet, 2)
	_rect(rewind, 3, 5, 3, 6, violet)
	_rect(rewind, 1, 7, 3, 2, violet)
	_save_png(rewind, ADVENTURE_DIR + "rewind_static.png")

	var marker := _new_image(16, 16, TRANSPARENT)
	var gold := Color8(255, 175, 82, 255)
	_outline_rect(marker, 4, 1, 8, 14, gold)
	_rect(marker, 6, 3, 4, 10, _tone(gold, 0.36))
	_rect(marker, 9, 7, 2, 2, gold)
	_save_png(marker, ADVENTURE_DIR + "staff_door_marker.png")

func _generate_security_tape_art() -> void:
	var bg := _new_image(640, 440, Color8(9, 10, 17, 255))
	var blue := Color8(66, 162, 210, 255)
	var dim := _tone(blue, 0.18)
	for y in range(40, 404, 42):
		_rect(bg, 46, y, 548, 2, dim)
		_rect(bg, 72, y + 14, 496, 1, dim)
	for x in [94, 212, 330, 448]:
		_outline_rect(bg, x, 74, 86, 54, _tone(blue, 0.32))
		_outline_rect(bg, x, 284, 86, 54, _tone(blue, 0.26))
	_text(bg, "SECURITY TAPE", 190, 190, 4, _tone(blue, 0.36))
	_save_png(bg, SECURITY_TAPE_DIR + "security_tape_background.png")

	var overlay := _new_image(640, 440, TRANSPARENT)
	for y in range(0, 440, 5):
		_rect(overlay, 0, y, 640, 1, Color(0.2, 0.95, 1.0, 0.06))
	for x in range(0, 640, 17):
		for y in range(0, 440, 29):
			if (x * 3 + y * 5) % 4 == 0:
				_rect(overlay, x, y, 2, 1, Color(1.0, 1.0, 1.0, 0.12))
	_save_png(overlay, SECURITY_TAPE_DIR + "tape_static_overlay.png")

func _generate_rockbyte_background() -> void:
	var image := _new_image(640, 440, Color8(8, 9, 18, 255))
	var cyan := Color8(75, 214, 255, 255)
	var amber := Color8(255, 194, 86, 255)
	_outline_rect(image, 28, 22, 584, 398, _tone(cyan, 0.36))
	for x in range(58, 582, 32):
		_rect(image, x, 384, 18, 4, _tone(amber, 0.25))
	for x in [74, 494]:
		_outline_rect(image, x, 176, 72, 96, _tone(cyan, 0.44))
		_rect(image, x + 12, 192, 48, 34, _tone(cyan, 0.18))
		_rect(image, x + 27, 238, 18, 10, _tone(amber, 0.36))
	_outline_rect(image, 244, 188, 152, 70, _tone(amber, 0.42))
	_text(image, "ROCKBYTE", 178, 92, 4, _tone(cyan, 0.45))
	_text(image, "DUEL", 250, 132, 4, _tone(amber, 0.52))
	_save_png(image, ROCKBYTE_BG_DIR + "rockbyte_background.png")

func _generate_ambient_effect_sprites() -> void:
	_generate_static_spark_sheet()
	_generate_blink_dot_sheet()
	_generate_scanline_bar_sheet()
	_generate_warning_light_sheet()
	_generate_soda_bubble_sheet()
	_generate_prize_twinkle_sheet()
	_generate_memory_wisp_sheet()
	_generate_neon_arrow_sheet()
	_generate_ticket_glint_sheet()
	_generate_staff_lock_blink_sheet()

func _generate_static_spark_sheet() -> void:
	var image := _new_image(64, 16, TRANSPARENT)
	var cyan := Color8(88, 236, 255, 255)
	var white := Color8(235, 252, 255, 255)
	var violet := Color8(224, 86, 255, 220)
	for frame in range(4):
		var ox := frame * 16
		match frame:
			0:
				_line(image, ox + 3, 8, ox + 8, 3, cyan, 2)
				_line(image, ox + 8, 3, ox + 6, 8, white, 1)
				_line(image, ox + 6, 8, ox + 12, 5, cyan, 2)
				_rect(image, ox + 2, 12, 2, 1, violet)
				_rect(image, ox + 12, 11, 2, 2, white)
			1:
				_line(image, ox + 4, 4, ox + 11, 10, white, 2)
				_line(image, ox + 11, 10, ox + 7, 13, cyan, 2)
				_rect(image, ox + 2, 6, 2, 2, cyan)
				_rect(image, ox + 13, 3, 1, 2, violet)
			2:
				_line(image, ox + 8, 2, ox + 5, 7, cyan, 2)
				_line(image, ox + 5, 7, ox + 10, 8, white, 1)
				_line(image, ox + 10, 8, ox + 4, 14, cyan, 2)
				_rect(image, ox + 12, 6, 2, 1, white)
			_:
				_line(image, ox + 2, 11, ox + 7, 5, violet, 2)
				_line(image, ox + 7, 5, ox + 12, 8, cyan, 2)
				_rect(image, ox + 4, 3, 2, 1, white)
				_rect(image, ox + 12, 13, 2, 1, cyan)
	_save_png(image, AMBIENT_EFFECTS_DIR + "static_spark_sheet.png")

func _generate_blink_dot_sheet() -> void:
	var image := _new_image(64, 16, TRANSPARENT)
	var colors := [
		Color8(38, 255, 172, 150),
		Color8(92, 255, 224, 255),
		Color8(255, 244, 144, 255),
		Color8(92, 255, 224, 205),
	]
	for frame in range(4):
		var ox := frame * 16
		var radius := 2 + (1 if frame == 1 or frame == 2 else 0)
		_disc(image, ox + 8, 8, radius + 2, _tone(colors[frame], 0.32))
		_disc(image, ox + 8, 8, radius, colors[frame])
		_rect(image, ox + 7, 7, 2, 2, Color8(255, 255, 255, 210))
	_save_png(image, AMBIENT_EFFECTS_DIR + "blink_dot_sheet.png")

func _generate_scanline_bar_sheet() -> void:
	var image := _new_image(128, 8, TRANSPARENT)
	var cyan := Color8(68, 218, 255, 190)
	var blue := Color8(58, 110, 255, 110)
	for frame in range(4):
		var ox := frame * 32
		_rect(image, ox + 1, 2 + (frame % 2), 30, 1, cyan)
		_rect(image, ox + 4 + frame * 2, 5, 12, 1, blue)
		_rect(image, ox + 18 - frame, 1, 8, 1, _tone(cyan, 0.55))
	_save_png(image, AMBIENT_EFFECTS_DIR + "scanline_bar_sheet.png")

func _generate_warning_light_sheet() -> void:
	var image := _new_image(64, 16, TRANSPARENT)
	var red := Color8(255, 58, 74, 255)
	var amber := Color8(255, 193, 74, 255)
	var dark_red := Color8(72, 17, 28, 220)
	for frame in range(4):
		var ox := frame * 16
		var lamp := red if frame % 2 == 0 else amber
		_rect(image, ox + 5, 10, 6, 3, Color8(31, 34, 46, 255))
		_outline_rect(image, ox + 4, 4, 8, 8, lamp)
		_rect(image, ox + 6, 6, 4, 4, lamp if frame != 3 else dark_red)
		if frame == 1 or frame == 2:
			_rect(image, ox + 3, 3, 10, 1, _tone(lamp, 0.62))
			_rect(image, ox + 3, 12, 10, 1, _tone(lamp, 0.44))
			_rect(image, ox + 2, 6, 1, 4, _tone(lamp, 0.42))
			_rect(image, ox + 13, 6, 1, 4, _tone(lamp, 0.42))
	_save_png(image, AMBIENT_EFFECTS_DIR + "warning_light_sheet.png")

func _generate_soda_bubble_sheet() -> void:
	var image := _new_image(64, 16, TRANSPARENT)
	var green := Color8(86, 255, 146, 225)
	var cyan := Color8(95, 239, 255, 210)
	for frame in range(4):
		var ox := frame * 16
		var y0 := 13 - frame * 3
		_outline_rect(image, ox + 5, y0, 4, 4, green)
		_outline_rect(image, ox + 10, 10 - ((frame + 1) % 4) * 2, 3, 3, cyan)
		if frame == 0 or frame == 3:
			_rect(image, ox + 3, 8, 2, 2, _tone(green, 0.7))
		else:
			_outline_rect(image, ox + 2, 6, 3, 3, _tone(cyan, 0.8))
	_save_png(image, AMBIENT_EFFECTS_DIR + "soda_bubble_sheet.png")

func _generate_prize_twinkle_sheet() -> void:
	var image := _new_image(64, 16, TRANSPARENT)
	var gold := Color8(255, 229, 111, 255)
	var pink := Color8(255, 96, 178, 230)
	for frame in range(4):
		var ox := frame * 16
		var color := gold if frame != 2 else pink
		_rect(image, ox + 7, 3 + frame % 2, 2, 10 - frame % 2, color)
		_rect(image, ox + 3 + frame % 2, 7, 10 - frame % 2, 2, color)
		_rect(image, ox + 5, 5, 2, 2, _tone(color, 0.74))
		_rect(image, ox + 10, 10, 2, 2, _tone(color, 0.62))
		if frame == 1:
			_rect(image, ox + 2, 2, 2, 2, color)
			_rect(image, ox + 12, 12, 2, 2, color)
	_save_png(image, AMBIENT_EFFECTS_DIR + "prize_twinkle_sheet.png")

func _generate_memory_wisp_sheet() -> void:
	var image := _new_image(96, 16, TRANSPARENT)
	var cyan := Color8(96, 236, 255, 230)
	var violet := Color8(218, 98, 255, 210)
	var white := Color8(238, 250, 255, 210)
	for frame in range(4):
		var ox := frame * 24
		_line(image, ox + 4, 11 - frame % 2, ox + 9, 5 + frame % 2, cyan, 2)
		_line(image, ox + 9, 5 + frame % 2, ox + 16, 7 - frame % 2, violet, 2)
		_line(image, ox + 16, 7 - frame % 2, ox + 20, 3 + frame % 2, white, 1)
		_disc(image, ox + 8 + frame, 10, 2, _tone(cyan, 0.72))
		_rect(image, ox + 3 + frame, 4, 2, 2, _tone(violet, 0.7))
	_save_png(image, AMBIENT_EFFECTS_DIR + "memory_wisp_sheet.png")

func _generate_neon_arrow_sheet() -> void:
	var image := _new_image(64, 16, TRANSPARENT)
	var cyan := Color8(78, 238, 255, 255)
	var amber := Color8(255, 206, 86, 230)
	for frame in range(4):
		var ox := frame * 16
		var color := cyan if frame != 2 else amber
		var dim := _tone(color, 0.42)
		_line(image, ox + 3, 8, ox + 11, 8, dim, 3)
		_line(image, ox + 9, 4, ox + 13, 8, dim, 3)
		_line(image, ox + 9, 12, ox + 13, 8, dim, 3)
		_line(image, ox + 4, 8, ox + 10, 8, color, 1 + frame % 2)
		_line(image, ox + 10, 5, ox + 13, 8, color, 1 + frame % 2)
		_line(image, ox + 10, 11, ox + 13, 8, color, 1 + frame % 2)
	_save_png(image, AMBIENT_EFFECTS_DIR + "neon_arrow_sheet.png")

func _generate_ticket_glint_sheet() -> void:
	var image := _new_image(64, 16, TRANSPARENT)
	var gold := Color8(255, 217, 105, 230)
	var cyan := Color8(86, 234, 255, 200)
	for frame in range(4):
		var ox := frame * 16
		_outline_rect(image, ox + 3, 5, 10, 6, _tone(gold, 0.45))
		_rect(image, ox + 5, 7, 2, 2, _tone(gold, 0.62))
		var gx := ox + 5 + frame * 2
		_rect(image, gx, 3, 1, 10, cyan)
		_rect(image, gx - 2, 7, 5, 1, Color8(255, 255, 255, 210))
		if frame == 3:
			_rect(image, ox + 11, 4, 2, 2, gold)
	_save_png(image, AMBIENT_EFFECTS_DIR + "ticket_glint_sheet.png")

func _generate_staff_lock_blink_sheet() -> void:
	var image := _new_image(64, 16, TRANSPARENT)
	var red := Color8(255, 66, 86, 255)
	var green := Color8(80, 255, 154, 255)
	var cyan := Color8(84, 230, 255, 255)
	for frame in range(4):
		var ox := frame * 16
		var color := green if frame == 2 else red
		_outline_rect(image, ox + 4, 6, 8, 7, color)
		_rect(image, ox + 6, 9, 4, 2, color)
		_rect(image, ox + 7, 11, 2, 1, color)
		_line(image, ox + 6, 6, ox + 6, 3, cyan if frame == 2 else _tone(red, 0.52), 1)
		_line(image, ox + 9, 3, ox + 9, 6, cyan if frame == 2 else _tone(red, 0.52), 1)
		_line(image, ox + 6, 3, ox + 9, 3, cyan if frame == 2 else _tone(red, 0.52), 1)
		if frame == 1:
			_rect(image, ox + 2, 7, 1, 4, _tone(red, 0.7))
			_rect(image, ox + 13, 7, 1, 4, _tone(red, 0.7))
	_save_png(image, AMBIENT_EFFECTS_DIR + "staff_lock_blink_sheet.png")

func _generate_sfx() -> void:
	_write_tone_sfx(SFX_DIR + "memory_panel.wav", [
		{"freq": 392.0, "duration": 0.06, "volume": 0.22},
		{"freq": 784.0, "duration": 0.10, "volume": 0.18},
	])
	_write_tone_sfx(SFX_DIR + "memory_accept.wav", [
		{"freq": 523.25, "duration": 0.07, "volume": 0.24},
		{"freq": 659.25, "duration": 0.07, "volume": 0.22},
		{"freq": 880.0, "duration": 0.12, "volume": 0.18},
	])
	_write_tone_sfx(SFX_DIR + "door_unlock.wav", [
		{"freq": 164.81, "duration": 0.09, "volume": 0.25},
		{"freq": 329.63, "duration": 0.12, "volume": 0.22},
		{"freq": 493.88, "duration": 0.16, "volume": 0.18},
	])
	_write_tone_sfx(SFX_DIR + "button_pulse.wav", [
		{"freq": 220.0, "duration": 0.035, "volume": 0.24},
		{"freq": 440.0, "duration": 0.045, "volume": 0.18},
	])
	_write_tone_sfx(SFX_DIR + "score_blip.wav", [
		{"freq": 659.25, "duration": 0.045, "volume": 0.22},
		{"freq": 987.77, "duration": 0.06, "volume": 0.18},
	])
	_write_tone_sfx(SFX_DIR + "error_buzz.wav", [
		{"freq": 110.0, "duration": 0.075, "volume": 0.22},
		{"freq": 103.83, "duration": 0.075, "volume": 0.2},
		{"freq": 98.0, "duration": 0.09, "volume": 0.18},
	])
	_write_tone_sfx(SFX_DIR + "success_jingle.wav", [
		{"freq": 392.0, "duration": 0.055, "volume": 0.22},
		{"freq": 523.25, "duration": 0.055, "volume": 0.21},
		{"freq": 659.25, "duration": 0.07, "volume": 0.2},
		{"freq": 1046.5, "duration": 0.12, "volume": 0.16},
	])

func _write_tone_sfx(path: String, tones: Array) -> void:
	var sample_rate := 22050
	var samples := PackedByteArray()
	for tone_value in tones:
		var tone: Dictionary = tone_value
		var freq := float(tone.get("freq", 440.0))
		var duration := float(tone.get("duration", 0.1))
		var volume := float(tone.get("volume", 0.2))
		var sample_count := int(duration * sample_rate)
		for index in range(sample_count):
			var local_t := float(index) / float(sample_rate)
			var progress := float(index) / maxf(float(sample_count - 1), 1.0)
			var envelope := sin(progress * PI)
			var tone_sample := sin(TAU * freq * local_t) * volume * envelope
			var grit := sin(TAU * freq * 2.01 * local_t) * volume * 0.18 * envelope
			_append_i16_le(samples, int(clampf(tone_sample + grit, -1.0, 1.0) * 32767.0))
		for _gap in range(int(0.012 * sample_rate)):
			_append_i16_le(samples, 0)
	var header := PackedByteArray()
	header.append_array("RIFF".to_ascii_buffer())
	_append_u32_le(header, 36 + samples.size())
	header.append_array("WAVE".to_ascii_buffer())
	header.append_array("fmt ".to_ascii_buffer())
	_append_u32_le(header, 16)
	_append_u16_le(header, 1)
	_append_u16_le(header, 1)
	_append_u32_le(header, sample_rate)
	_append_u32_le(header, sample_rate * 2)
	_append_u16_le(header, 2)
	_append_u16_le(header, 16)
	header.append_array("data".to_ascii_buffer())
	_append_u32_le(header, samples.size())
	header.append_array(samples)
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Could not save WAV: %s" % path)
		return
	file.store_buffer(header)
	file.close()

func _append_u16_le(bytes: PackedByteArray, value: int) -> void:
	bytes.append(value & 0xff)
	bytes.append((value >> 8) & 0xff)

func _append_i16_le(bytes: PackedByteArray, value: int) -> void:
	if value < 0:
		value = 65536 + value
	_append_u16_le(bytes, value)

func _append_u32_le(bytes: PackedByteArray, value: int) -> void:
	bytes.append(value & 0xff)
	bytes.append((value >> 8) & 0xff)
	bytes.append((value >> 16) & 0xff)
	bytes.append((value >> 24) & 0xff)

func _tone(color: Color, amount: float) -> Color:
	return Color(color.r * amount, color.g * amount, color.b * amount, color.a)

func _rect(image: Image, x: int, y: int, width: int, height: int, color: Color) -> void:
	var x0 := clampi(x, 0, image.get_width())
	var y0 := clampi(y, 0, image.get_height())
	var x1 := clampi(x + width, 0, image.get_width())
	var y1 := clampi(y + height, 0, image.get_height())
	for py in range(y0, y1):
		for px in range(x0, x1):
			image.set_pixel(px, py, color)

func _outline_rect(image: Image, x: int, y: int, width: int, height: int, color: Color) -> void:
	_rect(image, x, y, width, 2, color)
	_rect(image, x, y + height - 2, width, 2, color)
	_rect(image, x, y, 2, height, color)
	_rect(image, x + width - 2, y, 2, height, color)

func _disc(image: Image, cx: int, cy: int, radius: int, color: Color) -> void:
	for y in range(-radius, radius + 1):
		for x in range(-radius, radius + 1):
			if x * x + y * y <= radius * radius:
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

func _text(image: Image, text: String, x: int, y: int, scale: int, color: Color) -> void:
	var cursor := x
	for index in range(text.length()):
		var key := text.substr(index, 1).to_upper()
		var glyph: Array = FONT.get(key, FONT["?"])
		for row in range(glyph.size()):
			var line := str(glyph[row])
			for col in range(line.length()):
				if line.substr(col, 1) == "1":
					_rect(image, cursor + col * scale, y + row * scale, scale, scale, color)
		cursor += (str(glyph[0]).length() + 1) * scale

func _draw_person(image: Image, center: Vector2i, ink: Color, scale: int, glitch: bool) -> void:
	var x := center.x
	var y := center.y
	_rect(image, x - 3 * scale, y - 13 * scale, 6 * scale, 6 * scale, ink)
	_rect(image, x - 5 * scale, y - 6 * scale, 10 * scale, 12 * scale, ink)
	_rect(image, x - 7 * scale, y - 3 * scale, 2 * scale, 9 * scale, ink)
	_rect(image, x + 5 * scale, y - 3 * scale, 2 * scale, 9 * scale, ink)
	_rect(image, x - 5 * scale, y + 6 * scale, 3 * scale, 7 * scale, ink)
	_rect(image, x + 2 * scale, y + 6 * scale, 3 * scale, 7 * scale, ink)
	if glitch:
		_rect(image, x - 2 * scale, y - 11 * scale, 4 * scale, 3 * scale, DARK)
		_rect(image, x + 5 * scale, y - 9 * scale, 5 * scale, 2 * scale, ink)
		_rect(image, x - 10 * scale, y + 2 * scale, 4 * scale, 2 * scale, ink)

func _draw_machine(image: Image, x: int, y: int, ink: Color) -> void:
	_outline_rect(image, x, y, 38, 48, ink)
	_rect(image, x + 8, y + 9, 22, 14, _tone(ink, 0.38))
	_rect(image, x + 15, y + 32, 8, 6, ink)
