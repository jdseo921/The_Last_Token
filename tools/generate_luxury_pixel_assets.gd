extends SceneTree

const BROKEN_DIR := "res://assets/art/minigames/broken_high_score/"
const TRUTH_DIR := "res://assets/art/minigames/truth_filter/"
const TRUTH_BG_DIR := "res://assets/art/minigames/truth_filter/backgrounds/"
const PRIZE_DIR := "res://assets/art/maps/prize_corner/"
const ADVENTURE_DIR := "res://assets/art/minigames/adventure/"
const ADVENTURE_BG_DIR := "res://assets/art/minigames/adventure/backgrounds/"

const TRANSPARENT := Color(0, 0, 0, 0)
const DARK := Color8(5, 6, 14, 255)
const INK := Color8(17, 19, 36, 255)
const CYAN := Color8(71, 233, 255, 255)
const CYAN_DIM := Color8(31, 111, 148, 255)
const GOLD := Color8(255, 209, 91, 255)
const AMBER := Color8(255, 166, 67, 255)
const PINK := Color8(255, 82, 181, 255)
const VIOLET := Color8(165, 98, 255, 255)
const RED := Color8(255, 62, 86, 255)
const GREEN := Color8(74, 248, 153, 255)
const WHITE := Color8(234, 251, 255, 255)

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
	":": ["0", "1", "0", "0", "1", "0", "0"],
	"-": ["0000", "0000", "0000", "1111", "0000", "0000", "0000"],
	"?": ["111", "001", "001", "010", "010", "000", "010"],
}


func _init() -> void:
	_ensure_directories()
	_generate_broken_score_screen()
	_generate_truth_filter_assets()
	_generate_prize_corner_background()
	_generate_adventure_backgrounds()
	_generate_adventure_sprites()
	print("Generated luxury pixel minigame assets.")
	quit()


func _ensure_directories() -> void:
	for path in [BROKEN_DIR, TRUTH_DIR, TRUTH_BG_DIR, PRIZE_DIR, ADVENTURE_DIR, ADVENTURE_BG_DIR]:
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path))


func _generate_broken_score_screen() -> void:
	var image := _new_image(640, 440, Color8(7, 6, 18, 255))
	_fill_checker(image, Color8(11, 10, 25, 255), Color8(14, 11, 33, 255), 16)
	_luxe_bezel(image, Rect2i(20, 18, 600, 404), GOLD, PINK)
	_glow_rect(image, Rect2i(58, 62, 524, 64), Color(1.0, 0.21, 0.52, 0.18))
	_text(image, "BROKEN HIGH SCORE", 108, 76, 3, GOLD)
	_text(image, "ROXY GHOST BOARD", 202, 108, 1, PINK)
	_outline_rect(image, 132, 154, 376, 136, CYAN)
	_outline_rect(image, 144, 166, 352, 112, _tone(CYAN, 0.42))
	_rect(image, 154, 174, 332, 92, Color8(8, 12, 23, 255))
	for x in range(168, 472, 48):
		_rect(image, x, 178, 28, 84, Color(0.0, 0.9, 1.0, 0.04))
	_draw_seven_segment_number(image, "9999", 226, 184, 3, RED, _tone(RED, 0.2))
	_draw_seven_segment_number(image, "0099", 226, 226, 3, GREEN, _tone(GREEN, 0.16))
	_text(image, "FALSE", 174, 198, 1, RED)
	_text(image, "REAL", 182, 240, 1, GREEN)
	for index in range(3):
		var x := 116 + index * 204
		_outline_rect(image, x, 322, 104, 48, GOLD)
		_rect(image, x + 8, 330, 88, 32, Color8(23, 18, 35, 255))
		_text(image, "LOCK", x + 24, 340, 1, CYAN)
		_star(image, x + 88, 314, 8, PINK)
	_draw_score_ghost(image, Vector2i(86, 230), PINK)
	_draw_score_ghost(image, Vector2i(554, 230), _tone(CYAN, 0.72))
	_save_png(image, BROKEN_DIR + "broken_high_score_screen.png")


func _generate_truth_filter_assets() -> void:
	var bg := _new_image(640, 440, Color8(9, 7, 20, 255))
	_fill_checker(bg, Color8(10, 8, 24, 255), Color8(17, 10, 36, 255), 20)
	_luxe_bezel(bg, Rect2i(22, 20, 596, 400), VIOLET, CYAN)
	_text(bg, "TRUTH FILTER", 190, 42, 3, CYAN)
	for index in range(3):
		var x := 88 + index * 184
		_draw_truth_cabinet_large(bg, x, 176, index, _tone(CYAN, 0.42), _tone(VIOLET, 0.5))
		_line(bg, x + 44, 178, 320, 122, _tone(CYAN, 0.32), 2)
	_outline_rect(bg, 222, 96, 196, 54, GOLD)
	_text(bg, "SHIFT LOG", 260, 112, 2, GOLD)
	_text(bg, "LIE DENSITY", 246, 386, 1, PINK)
	for x in range(164, 492, 12):
		_rect(bg, x, 406, 8, 4, Color(1.0, 0.2, 0.65, 0.26))
	_save_png(bg, TRUTH_BG_DIR + "truth_filter_luxury_screen.png")

	var sheet := _new_image(384, 96, TRANSPARENT)
	_draw_truth_cabinet_frame(sheet, 0, CABINET_STATE_NORMAL())
	_draw_truth_cabinet_frame(sheet, 96, CABINET_STATE_ACTIVE())
	_draw_truth_cabinet_frame(sheet, 192, CABINET_STATE_CORRECT())
	_draw_truth_cabinet_frame(sheet, 288, CABINET_STATE_WRONG())
	_save_png(sheet, TRUTH_DIR + "truth_filter_cabinets_sheet.png")


func _generate_prize_corner_background() -> void:
	var image := _new_image(640, 440, Color8(15, 10, 24, 255))
	_rect(image, 0, 0, 640, 440, Color8(13, 9, 24, 255))
	for y in range(218, 440, 22):
		_rect(image, 0, y, 640, 1, Color(1.0, 0.82, 0.35, 0.08))
	for x in range(0, 640, 28):
		_line(image, x, 218, x - 84, 440, Color(0.9, 0.3, 0.8, 0.06), 1)
	_luxe_bezel(image, Rect2i(76, 72, 488, 116), GOLD, PINK)
	_rect(image, 108, 96, 424, 70, Color8(34, 20, 42, 255))
	for index in range(6):
		var x := 130 + index * 66
		_draw_prize_plush(image, x, 132, index)
	_outline_rect(image, 108, 198, 424, 72, CYAN)
	_rect(image, 122, 212, 396, 44, Color8(22, 17, 29, 236))
	_draw_prize_item(image, Vector2i(174, 234), "ticket")
	_draw_prize_item(image, Vector2i(320, 234), "token")
	_draw_prize_item(image, Vector2i(466, 234), "badge")
	_text(image, "PRIZE CORNER", 162, 28, 3, GOLD)
	_text(image, "SORT THE MEMORIES", 196, 284, 2, CYAN)
	_draw_pip_spot(image, Vector2i(320, 334))
	_outline_rect(image, 420, 288, 92, 62, VIOLET)
	_text(image, "SHELF", 438, 304, 1, VIOLET)
	_text(image, "RUN", 452, 324, 1, GOLD)
	_star(image, 246, 112, 10, GOLD)
	_star(image, 396, 116, 8, PINK)
	_save_png(image, PRIZE_DIR + "prize_corner_background_640x440.png")


func _generate_adventure_backgrounds() -> void:
	_save_png(_adventure_stage_background("POWER THE DARK ROUTE", CYAN, GOLD, "SERVICE GRID", "static"), ADVENTURE_BG_DIR + "static_service_run_bg_640x440.png")
	_save_png(_adventure_stage_background("TICKET SWEEP", GOLD, CYAN, "FLOOR ROUTE", "ticket"), ADVENTURE_BG_DIR + "ticket_sweep_bg_640x440.png")
	_save_png(_adventure_stage_background("CABINET TRACE", CYAN, VIOLET, "TRACE SPARKS", "cabinet"), ADVENTURE_BG_DIR + "cabinet_trace_bg_640x440.png")
	_save_png(_adventure_stage_background("SNACK SERVICE", GREEN, AMBER, "FIZZ ROUTE", "snack"), ADVENTURE_BG_DIR + "snack_service_bg_640x440.png")
	_save_png(_adventure_stage_background("PRIZE SHELF", PINK, GOLD, "TAG RAIL", "prize"), ADVENTURE_BG_DIR + "prize_shelf_bg_640x440.png")


func _adventure_stage_background(title: String, primary: Color, secondary: Color, subtitle: String, motif: String) -> Image:
	var image := _new_image(640, 440, Color8(6, 8, 18, 255))
	_fill_checker(image, _tone(primary, 0.06), _tone(secondary, 0.05), 20)
	_luxe_bezel(image, Rect2i(18, 18, 604, 404), primary, secondary)
	_outline_rect(image, 30, 110, 382, 298, _tone(primary, 0.38))
	_outline_rect(image, 430, 92, 178, 258, _tone(secondary, 0.4))
	_text(image, title, 48, 44, 2, primary)
	_text(image, subtitle, 444, 112, 1, secondary)
	for y in range(136, 386, 28):
		_rect(image, 52, y, 338, 2, Color(primary.r, primary.g, primary.b, 0.08))
	for x in range(64, 390, 28):
		_rect(image, x, 132, 2, 254, Color(secondary.r, secondary.g, secondary.b, 0.055))
	match motif:
		"static":
			for index in range(9):
				_line(image, 76 + index * 32, 360 - index * 12, 128 + index * 28, 164 + index * 13, _tone(CYAN, 0.42), 2)
			_draw_breaker_panel(image, Vector2i(512, 222), 3)
		"memory":
			for index in range(5):
				_draw_memory_card(image, Vector2i(88 + index * 58, 176 + (index % 2) * 64), 2, primary)
			_draw_staff_door(image, Vector2i(514, 230), 3)
		"ticket":
			for index in range(8):
				_draw_ticket_tag(image, Vector2i(82 + index * 36, 182 + (index % 3) * 44), 2)
			_draw_counter_goal(image, Vector2i(514, 236), 2)
		"cabinet":
			for index in range(5):
				_draw_trace_spark(image, Vector2i(98 + index * 58, 190 + (index % 2) * 52), 2)
			_draw_log_marker(image, Vector2i(514, 236), 2)
		"snack":
			for index in range(5):
				_draw_soda_label(image, Vector2i(94 + index * 54, 188 + (index % 2) * 50), 2)
			_draw_out_marker(image, Vector2i(514, 236), 2)
		"prize":
			for index in range(6):
				_draw_prize_tag(image, Vector2i(92 + index * 44, 178 + (index % 2) * 62), 2)
			_draw_tag_goal(image, Vector2i(514, 236), 2)
	return image


func _generate_adventure_sprites() -> void:
	_save_png(_sprite_player(), ADVENTURE_DIR + "player_8bit.png")
	_save_png(_sprite_breaker_node(), ADVENTURE_DIR + "breaker_panel.png")
	_save_png(_sprite_breaker_node(), ADVENTURE_DIR + "breaker_panel_gen.png")
	_save_png(_sprite_signal_fuse(), ADVENTURE_DIR + "signal_fuse.png")
	_save_png(_sprite_signal_fuse(), ADVENTURE_DIR + "signal_fuse_gen.png")
	_save_png(_sprite_static_leak(), ADVENTURE_DIR + "static_leak.png")
	_save_png(_sprite_static_leak(), ADVENTURE_DIR + "static_leak_gen.png")
	_save_png(_sprite_static_surge(), ADVENTURE_DIR + "static_surge_gen.png")
	_save_png(_sprite_memory_frame(), ADVENTURE_DIR + "memory_frame.png")
	_save_png(_sprite_memory_frame(), ADVENTURE_DIR + "memory_frame_gen.png")
	_save_png(_sprite_rewind_static(), ADVENTURE_DIR + "rewind_static.png")
	_save_png(_sprite_rewind_static(), ADVENTURE_DIR + "rewind_static_gen.png")
	_save_png(_sprite_second_signal(), ADVENTURE_DIR + "second_signal_gen.png")
	_save_png(_sprite_staff_door(), ADVENTURE_DIR + "staff_door_marker.png")
	_save_png(_sprite_staff_door(), ADVENTURE_DIR + "staff_door_gen.png")
	_save_png(_sprite_service_cell_luxe(), ADVENTURE_DIR + "service_cell.png")
	_save_png(_sprite_power_gate_luxe(), ADVENTURE_DIR + "power_gate.png")
	_save_png(_sprite_service_beacon_luxe(), ADVENTURE_DIR + "service_beacon.png")
	_save_png(_sprite_memory_anchor_luxe(), ADVENTURE_DIR + "memory_anchor.png")
	_save_png(_sprite_memory_lock_luxe(), ADVENTURE_DIR + "memory_lock.png")
	_save_png(_sprite_memory_beacon_luxe(), ADVENTURE_DIR + "memory_beacon.png")
	_save_png(_sprite_ticket_tag(), ADVENTURE_DIR + "ticket_tag_luxe.png")
	_save_png(_sprite_spill_hazard(), ADVENTURE_DIR + "spill_hazard_luxe.png")
	_save_png(_sprite_counter_goal(), ADVENTURE_DIR + "counter_goal_luxe.png")
	_save_png(_sprite_trace_spark(), ADVENTURE_DIR + "trace_spark_luxe.png")
	_save_png(_sprite_error_static(), ADVENTURE_DIR + "error_static_luxe.png")
	_save_png(_sprite_log_goal(), ADVENTURE_DIR + "log_goal_luxe.png")
	_save_png(_sprite_soda_label(), ADVENTURE_DIR + "soda_label_luxe.png")
	_save_png(_sprite_fizz_hazard(), ADVENTURE_DIR + "fizz_hazard_luxe.png")
	_save_png(_sprite_out_goal(), ADVENTURE_DIR + "out_goal_luxe.png")
	_save_png(_sprite_prize_tag(), ADVENTURE_DIR + "prize_tag_luxe.png")
	_save_png(_sprite_hook_hazard(), ADVENTURE_DIR + "hook_hazard_luxe.png")
	_save_png(_sprite_tag_goal(), ADVENTURE_DIR + "tag_goal_luxe.png")


func _sprite_player() -> Image:
	var image := _new_image(16, 16, TRANSPARENT)
	_rect(image, 6, 1, 4, 2, CYAN)
	_rect(image, 5, 3, 6, 4, WHITE)
	_rect(image, 6, 4, 4, 2, Color8(32, 52, 74, 255))
	_rect(image, 4, 7, 8, 5, _tone(CYAN, 0.82))
	_rect(image, 3, 8, 2, 4, GOLD)
	_rect(image, 11, 8, 2, 4, GOLD)
	_rect(image, 5, 12, 3, 3, WHITE)
	_rect(image, 9, 12, 3, 3, WHITE)
	return image


func _sprite_breaker_node() -> Image:
	var image := _new_image(32, 32, TRANSPARENT)
	_draw_breaker_panel(image, Vector2i(16, 16), 1)
	return image


func _sprite_signal_fuse() -> Image:
	var image := _new_image(32, 32, TRANSPARENT)
	_outline_rect(image, 10, 5, 12, 22, GOLD)
	_rect(image, 12, 7, 8, 18, Color8(52, 36, 22, 255))
	_line(image, 16, 9, 13, 16, AMBER, 2)
	_line(image, 13, 16, 18, 16, WHITE, 1)
	_line(image, 18, 16, 15, 24, AMBER, 2)
	_rect(image, 7, 10, 18, 3, GOLD)
	_rect(image, 7, 21, 18, 3, GOLD)
	return image


func _sprite_static_leak() -> Image:
	var image := _new_image(32, 32, TRANSPARENT)
	_line(image, 18, 2, 9, 13, CYAN, 3)
	_line(image, 9, 13, 18, 13, WHITE, 2)
	_line(image, 18, 13, 11, 30, CYAN, 3)
	_rect(image, 4, 21, 4, 2, VIOLET)
	_rect(image, 24, 8, 3, 3, WHITE)
	return image


func _sprite_static_surge() -> Image:
	var image := _new_image(32, 32, TRANSPARENT)
	_disc(image, 16, 16, 12, Color(0.25, 0.9, 1.0, 0.18))
	_line(image, 3, 17, 12, 7, CYAN, 3)
	_line(image, 12, 7, 20, 15, WHITE, 2)
	_line(image, 20, 15, 11, 28, CYAN, 3)
	_line(image, 15, 3, 27, 12, VIOLET, 2)
	_line(image, 27, 12, 20, 25, PINK, 2)
	return image


func _sprite_memory_frame() -> Image:
	var image := _new_image(32, 32, TRANSPARENT)
	_draw_memory_card(image, Vector2i(16, 16), 1, VIOLET)
	return image


func _sprite_rewind_static() -> Image:
	var image := _new_image(32, 32, TRANSPARENT)
	_disc(image, 16, 16, 12, Color(0.65, 0.18, 0.95, 0.12))
	_line(image, 25, 7, 9, 16, VIOLET, 4)
	_line(image, 9, 16, 25, 25, VIOLET, 4)
	_rect(image, 5, 10, 6, 12, PINK)
	_rect(image, 2, 14, 5, 4, PINK)
	_rect(image, 15, 15, 3, 3, WHITE)
	return image


func _sprite_second_signal() -> Image:
	var image := _new_image(32, 32, TRANSPARENT)
	_line(image, 8, 26, 16, 6, PINK, 3)
	_line(image, 16, 6, 24, 26, VIOLET, 3)
	_line(image, 10, 15, 22, 15, WHITE, 2)
	_rect(image, 13, 2, 6, 4, PINK)
	_rect(image, 11, 26, 10, 3, VIOLET)
	return image


func _sprite_staff_door() -> Image:
	var image := _new_image(32, 32, TRANSPARENT)
	_draw_staff_door(image, Vector2i(16, 16), 1)
	return image


func _sprite_service_cell_luxe() -> Image:
	var image := _new_image(32, 32, TRANSPARENT)
	_outline_rect(image, 7, 9, 18, 15, CYAN)
	_rect(image, 9, 11, 14, 11, Color8(12, 34, 45, 255))
	_rect(image, 12, 14, 8, 5, GREEN)
	_rect(image, 14, 6, 4, 4, GOLD)
	_rect(image, 11, 4, 10, 2, GOLD)
	_star(image, 24, 8, 3, WHITE)
	return image


func _sprite_power_gate_luxe() -> Image:
	var image := _new_image(32, 32, TRANSPARENT)
	_outline_rect(image, 5, 6, 7, 22, RED)
	_outline_rect(image, 20, 6, 7, 22, RED)
	_line(image, 11, 12, 21, 12, RED, 3)
	_line(image, 11, 20, 21, 20, RED, 3)
	_outline_rect(image, 12, 13, 8, 7, GOLD)
	_rect(image, 15, 15, 2, 5, GOLD)
	_rect(image, 8, 3, 16, 2, CYAN)
	_rect(image, 8, 29, 16, 2, CYAN_DIM)
	return image


func _sprite_service_beacon_luxe() -> Image:
	var image := _new_image(32, 32, TRANSPARENT)
	_rect(image, 8, 24, 16, 4, CYAN_DIM)
	_outline_rect(image, 12, 12, 8, 12, GREEN)
	_rect(image, 14, 14, 4, 8, CYAN)
	_outline_rect(image, 10, 6, 12, 7, GOLD)
	_rect(image, 13, 8, 6, 3, GREEN)
	_star(image, 7, 7, 3, CYAN)
	_star(image, 25, 8, 3, CYAN)
	return image


func _sprite_memory_anchor_luxe() -> Image:
	var image := _new_image(32, 32, TRANSPARENT)
	_outline_rect(image, 7, 4, 18, 24, VIOLET)
	_rect(image, 10, 7, 12, 18, Color8(26, 18, 56, 255))
	_line(image, 16, 8, 16, 24, CYAN, 2)
	_line(image, 11, 16, 21, 16, PINK, 2)
	_rect(image, 12, 2, 8, 3, WHITE)
	_star(image, 5, 17, 3, PINK)
	_star(image, 27, 17, 3, CYAN)
	return image


func _sprite_memory_lock_luxe() -> Image:
	var image := _new_image(32, 32, TRANSPARENT)
	_line(image, 10, 14, 10, 8, VIOLET, 3)
	_line(image, 10, 8, 22, 8, VIOLET, 3)
	_line(image, 22, 8, 22, 14, VIOLET, 3)
	_outline_rect(image, 7, 13, 18, 14, PINK)
	_rect(image, 10, 16, 12, 8, Color8(42, 16, 55, 255))
	_rect(image, 14, 18, 4, 4, GOLD)
	_rect(image, 15, 22, 2, 3, GOLD)
	_star(image, 24, 5, 3, CYAN)
	return image


func _sprite_memory_beacon_luxe() -> Image:
	var image := _new_image(32, 32, TRANSPARENT)
	_rect(image, 9, 24, 14, 4, VIOLET)
	_line(image, 16, 24, 16, 12, CYAN, 2)
	_line(image, 16, 12, 11, 8, CYAN, 2)
	_line(image, 16, 12, 21, 8, PINK, 2)
	_outline_rect(image, 12, 9, 8, 6, WHITE)
	_rect(image, 14, 11, 4, 2, CYAN)
	_star(image, 7, 16, 3, PINK)
	_star(image, 25, 16, 3, CYAN)
	return image


func _sprite_ticket_tag() -> Image:
	var image := _new_image(32, 32, TRANSPARENT)
	_draw_ticket_tag(image, Vector2i(16, 16), 1)
	return image


func _sprite_spill_hazard() -> Image:
	var image := _new_image(32, 32, TRANSPARENT)
	_disc(image, 14, 20, 9, Color(0.25, 0.9, 1.0, 0.5))
	_disc(image, 21, 14, 5, Color(0.5, 1.0, 0.75, 0.45))
	_rect(image, 7, 23, 18, 3, CYAN)
	_star(image, 10, 14, 3, WHITE)
	return image


func _sprite_counter_goal() -> Image:
	var image := _new_image(32, 32, TRANSPARENT)
	_draw_counter_goal(image, Vector2i(16, 16), 1)
	return image


func _sprite_trace_spark() -> Image:
	var image := _new_image(32, 32, TRANSPARENT)
	_draw_trace_spark(image, Vector2i(16, 16), 1)
	return image


func _sprite_error_static() -> Image:
	var image := _new_image(32, 32, TRANSPARENT)
	_line(image, 5, 8, 16, 18, RED, 3)
	_line(image, 16, 18, 27, 9, PINK, 3)
	_line(image, 6, 24, 26, 24, VIOLET, 2)
	_text(image, "ERR", 7, 2, 1, RED)
	return image


func _sprite_log_goal() -> Image:
	var image := _new_image(32, 32, TRANSPARENT)
	_draw_log_marker(image, Vector2i(16, 16), 1)
	return image


func _sprite_soda_label() -> Image:
	var image := _new_image(32, 32, TRANSPARENT)
	_draw_soda_label(image, Vector2i(16, 16), 1)
	return image


func _sprite_fizz_hazard() -> Image:
	var image := _new_image(32, 32, TRANSPARENT)
	for point in [Vector2i(10, 20), Vector2i(15, 13), Vector2i(21, 22), Vector2i(23, 10)]:
		_outline_rect(image, point.x - 3, point.y - 3, 6, 6, GREEN)
	_disc(image, 16, 25, 8, Color(0.2, 1.0, 0.74, 0.22))
	_text(image, "FZ", 11, 3, 1, CYAN)
	return image


func _sprite_out_goal() -> Image:
	var image := _new_image(32, 32, TRANSPARENT)
	_draw_out_marker(image, Vector2i(16, 16), 1)
	return image


func _sprite_prize_tag() -> Image:
	var image := _new_image(32, 32, TRANSPARENT)
	_draw_prize_tag(image, Vector2i(16, 16), 1)
	return image


func _sprite_hook_hazard() -> Image:
	var image := _new_image(32, 32, TRANSPARENT)
	_line(image, 16, 3, 16, 14, VIOLET, 3)
	_line(image, 16, 14, 22, 19, RED, 3)
	_line(image, 22, 19, 15, 27, RED, 3)
	_line(image, 15, 27, 10, 22, PINK, 2)
	_star(image, 22, 8, 3, GOLD)
	return image


func _sprite_tag_goal() -> Image:
	var image := _new_image(32, 32, TRANSPARENT)
	_draw_tag_goal(image, Vector2i(16, 16), 1)
	return image


func CABINET_STATE_NORMAL() -> Dictionary:
	return {"body": Color8(34, 31, 56, 255), "screen": CYAN, "accent": GOLD, "glitch": false}


func CABINET_STATE_ACTIVE() -> Dictionary:
	return {"body": Color8(42, 30, 72, 255), "screen": VIOLET, "accent": CYAN, "glitch": true}


func CABINET_STATE_CORRECT() -> Dictionary:
	return {"body": Color8(22, 54, 42, 255), "screen": GREEN, "accent": CYAN, "glitch": false}


func CABINET_STATE_WRONG() -> Dictionary:
	return {"body": Color8(62, 20, 35, 255), "screen": RED, "accent": PINK, "glitch": true}


func _draw_truth_cabinet_frame(image: Image, ox: int, colors: Dictionary) -> void:
	var body: Color = colors.get("body", INK)
	var screen: Color = colors.get("screen", CYAN)
	var accent: Color = colors.get("accent", GOLD)
	var glitch := bool(colors.get("glitch", false))
	_outline_rect(image, ox + 18, 4, 60, 88, accent)
	_rect(image, ox + 22, 8, 52, 80, body)
	_outline_rect(image, ox + 28, 14, 40, 32, screen)
	_rect(image, ox + 32, 18, 32, 24, _tone(screen, 0.32))
	_rect(image, ox + 38, 54, 20, 8, accent)
	_rect(image, ox + 30, 68, 36, 5, _tone(accent, 0.55))
	_rect(image, ox + 25, 84, 46, 6, Color8(12, 10, 22, 255))
	if glitch:
		_rect(image, ox + 24, 26, 48, 3, PINK)
		_rect(image, ox + 32, 34, 28, 2, WHITE)
		_line(image, ox + 20, 12, ox + 76, 60, _tone(screen, 0.55), 1)
	else:
		_star(image, ox + 70, 11, 3, WHITE)


func _draw_truth_cabinet_large(image: Image, x: int, y: int, index: int, body: Color, accent: Color) -> void:
	_outline_rect(image, x, y, 92, 116, accent)
	_rect(image, x + 8, y + 8, 76, 100, Color(body.r, body.g, body.b, 0.74))
	_outline_rect(image, x + 20, y + 24, 52, 38, CYAN)
	_text(image, String.chr(65 + index), x + 42, y + 72, 2, GOLD)
	_rect(image, x + 30, y + 92, 32, 8, accent)


func _draw_prize_plush(image: Image, x: int, y: int, index: int) -> void:
	var palette: Array[Color] = [PINK, CYAN, GOLD, VIOLET, GREEN, AMBER]
	var color: Color = palette[index % palette.size()]
	_disc(image, x, y - 10, 12, _tone(color, 0.68))
	_disc(image, x - 8, y - 20, 5, _tone(color, 0.72))
	_disc(image, x + 8, y - 20, 5, _tone(color, 0.72))
	_rect(image, x - 12, y, 24, 18, _tone(color, 0.58))
	_rect(image, x - 5, y - 13, 3, 3, DARK)
	_rect(image, x + 3, y - 13, 3, 3, DARK)
	_rect(image, x - 4, y + 5, 8, 3, WHITE)


func _draw_prize_item(image: Image, center: Vector2i, kind: String) -> void:
	match kind:
		"ticket":
			_draw_ticket_tag(image, center, 2)
		"token":
			_disc(image, center.x, center.y, 14, GOLD)
			_disc(image, center.x, center.y, 8, Color8(96, 55, 22, 255))
			_text(image, "T", center.x - 5, center.y - 7, 2, WHITE)
		"badge":
			_outline_rect(image, center.x - 18, center.y - 14, 36, 28, CYAN)
			_rect(image, center.x - 14, center.y - 8, 28, 16, Color8(24, 32, 48, 255))
			_text(image, "04", center.x - 10, center.y - 5, 2, GOLD)


func _draw_pip_spot(image: Image, center: Vector2i) -> void:
	_disc(image, center.x, center.y + 4, 42, Color(1.0, 0.78, 0.2, 0.11))
	_draw_prize_plush(image, center.x, center.y, 2)
	_text(image, "PIP", center.x - 17, center.y + 28, 1, GOLD)


func _draw_breaker_panel(image: Image, center: Vector2i, scale: int) -> void:
	var x := center.x
	var y := center.y
	_outline_rect(image, x - 10 * scale, y - 12 * scale, 20 * scale, 24 * scale, GREEN)
	_rect(image, x - 7 * scale, y - 9 * scale, 14 * scale, 18 * scale, Color8(14, 34, 26, 255))
	_line(image, x - 4 * scale, y + 6 * scale, x - 1 * scale, y - 5 * scale, GOLD, maxi(scale, 1))
	_line(image, x + 4 * scale, y + 5 * scale, x + 2 * scale, y - 7 * scale, CYAN, maxi(scale, 1))
	_rect(image, x - 5 * scale, y + 10 * scale, 10 * scale, scale, GREEN)


func _draw_memory_card(image: Image, center: Vector2i, scale: int, color: Color) -> void:
	var x := center.x
	var y := center.y
	_outline_rect(image, x - 9 * scale, y - 11 * scale, 18 * scale, 22 * scale, color)
	_rect(image, x - 6 * scale, y - 8 * scale, 12 * scale, 16 * scale, _tone(color, 0.26))
	_rect(image, x - 3 * scale, y - 5 * scale, 6 * scale, 10 * scale, CYAN)
	_rect(image, x - 1 * scale, y - 3 * scale, 2 * scale, 6 * scale, WHITE)


func _draw_staff_door(image: Image, center: Vector2i, scale: int) -> void:
	var x := center.x
	var y := center.y
	_outline_rect(image, x - 8 * scale, y - 13 * scale, 16 * scale, 26 * scale, AMBER)
	_rect(image, x - 5 * scale, y - 10 * scale, 10 * scale, 20 * scale, Color8(48, 27, 23, 255))
	_rect(image, x + 3 * scale, y, 2 * scale, 2 * scale, GOLD)
	_text(image, "S", x - 3 * scale, y - 8 * scale, scale, CYAN)


func _draw_ticket_tag(image: Image, center: Vector2i, scale: int) -> void:
	var x := center.x
	var y := center.y
	_outline_rect(image, x - 10 * scale, y - 6 * scale, 20 * scale, 12 * scale, GOLD)
	_rect(image, x - 7 * scale, y - 3 * scale, 14 * scale, 6 * scale, _tone(GOLD, 0.3))
	_rect(image, x - 2 * scale, y - 2 * scale, 4 * scale, 4 * scale, WHITE)


func _draw_counter_goal(image: Image, center: Vector2i, scale: int) -> void:
	var x := center.x
	var y := center.y
	_outline_rect(image, x - 12 * scale, y - 8 * scale, 24 * scale, 16 * scale, CYAN)
	_rect(image, x - 9 * scale, y - 5 * scale, 18 * scale, 10 * scale, Color8(21, 35, 45, 255))
	_text(image, "CTR", x - 9 * scale, y - 3 * scale, scale, GOLD)


func _draw_trace_spark(image: Image, center: Vector2i, scale: int) -> void:
	var x := center.x
	var y := center.y
	_line(image, x, y - 12 * scale, x - 5 * scale, y, CYAN, maxi(scale + 1, 1))
	_line(image, x - 5 * scale, y, x + 3 * scale, y, WHITE, maxi(scale, 1))
	_line(image, x + 3 * scale, y, x - 2 * scale, y + 12 * scale, VIOLET, maxi(scale + 1, 1))
	_star(image, x + 8 * scale, y - 7 * scale, 3 * scale, GOLD)


func _draw_log_marker(image: Image, center: Vector2i, scale: int) -> void:
	var x := center.x
	var y := center.y
	_outline_rect(image, x - 9 * scale, y - 12 * scale, 18 * scale, 24 * scale, CYAN)
	_rect(image, x - 6 * scale, y - 8 * scale, 12 * scale, 3 * scale, GOLD)
	_rect(image, x - 6 * scale, y - 2 * scale, 12 * scale, 2 * scale, VIOLET)
	_rect(image, x - 6 * scale, y + 4 * scale, 9 * scale, 2 * scale, GREEN)


func _draw_soda_label(image: Image, center: Vector2i, scale: int) -> void:
	var x := center.x
	var y := center.y
	_outline_rect(image, x - 8 * scale, y - 11 * scale, 16 * scale, 22 * scale, GREEN)
	_rect(image, x - 5 * scale, y - 8 * scale, 10 * scale, 16 * scale, Color8(17, 43, 35, 255))
	_rect(image, x - 4 * scale, y - scale, 8 * scale, 3 * scale, CYAN)
	_star(image, x + 5 * scale, y - 8 * scale, 2 * scale, WHITE)


func _draw_out_marker(image: Image, center: Vector2i, scale: int) -> void:
	var x := center.x
	var y := center.y
	_outline_rect(image, x - 12 * scale, y - 9 * scale, 24 * scale, 18 * scale, AMBER)
	_line(image, x - 7 * scale, y, x + 6 * scale, y, GREEN, maxi(scale + 1, 1))
	_line(image, x + 2 * scale, y - 5 * scale, x + 8 * scale, y, GREEN, maxi(scale + 1, 1))
	_line(image, x + 2 * scale, y + 5 * scale, x + 8 * scale, y, GREEN, maxi(scale + 1, 1))


func _draw_prize_tag(image: Image, center: Vector2i, scale: int) -> void:
	var x := center.x
	var y := center.y
	_outline_rect(image, x - 10 * scale, y - 8 * scale, 20 * scale, 16 * scale, PINK)
	_rect(image, x - 6 * scale, y - 4 * scale, 12 * scale, 8 * scale, _tone(PINK, 0.3))
	_disc(image, x + 6 * scale, y - 4 * scale, 2 * scale, GOLD)
	_line(image, x + 7 * scale, y - 5 * scale, x + 13 * scale, y - 12 * scale, GOLD, maxi(scale, 1))


func _draw_tag_goal(image: Image, center: Vector2i, scale: int) -> void:
	var x := center.x
	var y := center.y
	_outline_rect(image, x - 12 * scale, y - 9 * scale, 24 * scale, 18 * scale, GOLD)
	_text(image, "TAG", x - 9 * scale, y - 4 * scale, scale, PINK)
	_star(image, x + 10 * scale, y - 8 * scale, 3 * scale, CYAN)


func _draw_score_ghost(image: Image, center: Vector2i, color: Color) -> void:
	_disc(image, center.x, center.y - 18, 22, Color(color.r, color.g, color.b, 0.18))
	_rect(image, center.x - 18, center.y - 18, 36, 46, Color(color.r, color.g, color.b, 0.18))
	_rect(image, center.x - 10, center.y - 24, 7, 7, color)
	_rect(image, center.x + 4, center.y - 24, 7, 7, color)
	for i in range(3):
		_line(image, center.x - 18 + i * 18, center.y + 27, center.x - 10 + i * 18, center.y + 36, color, 2)


func _draw_seven_segment_number(image: Image, value: String, x: int, y: int, scale: int, on_color: Color, off_color: Color) -> void:
	for index in range(value.length()):
		_draw_seven_segment_digit(image, value.substr(index, 1), x + index * maxi(38, 11 * scale), y, scale, on_color, off_color)


func _draw_seven_segment_digit(image: Image, digit: String, x: int, y: int, scale: int, on_color: Color, off_color: Color) -> void:
	var segments := {
		"0": [true, true, true, true, true, true, false],
		"1": [false, true, true, false, false, false, false],
		"2": [true, true, false, true, true, false, true],
		"3": [true, true, true, true, false, false, true],
		"4": [false, true, true, false, false, true, true],
		"5": [true, false, true, true, false, true, true],
		"6": [true, false, true, true, true, true, true],
		"7": [true, true, true, false, false, false, false],
		"8": [true, true, true, true, true, true, true],
		"9": [true, true, true, true, false, true, true],
	}
	var active: Array = segments.get(digit, segments["8"])
	_segment(image, x + 3 * scale, y, 5 * scale, scale, on_color if active[0] else off_color)
	_segment(image, x + 8 * scale, y + scale, scale, 5 * scale, on_color if active[1] else off_color)
	_segment(image, x + 8 * scale, y + 7 * scale, scale, 5 * scale, on_color if active[2] else off_color)
	_segment(image, x + 3 * scale, y + 12 * scale, 5 * scale, scale, on_color if active[3] else off_color)
	_segment(image, x + 2 * scale, y + 7 * scale, scale, 5 * scale, on_color if active[4] else off_color)
	_segment(image, x + 2 * scale, y + scale, scale, 5 * scale, on_color if active[5] else off_color)
	_segment(image, x + 3 * scale, y + 6 * scale, 5 * scale, scale, on_color if active[6] else off_color)


func _segment(image: Image, x: int, y: int, w: int, h: int, color: Color) -> void:
	_rect(image, x, y, w, h, color)


func _luxe_bezel(image: Image, rect: Rect2i, color_a: Color, color_b: Color) -> void:
	_outline_rect(image, rect.position.x, rect.position.y, rect.size.x, rect.size.y, color_a)
	_outline_rect(image, rect.position.x + 6, rect.position.y + 6, rect.size.x - 12, rect.size.y - 12, _tone(color_b, 0.58))
	_outline_rect(image, rect.position.x + 14, rect.position.y + 14, rect.size.x - 28, rect.size.y - 28, _tone(color_a, 0.28))
	for corner in [
		Vector2i(rect.position.x + 16, rect.position.y + 16),
		Vector2i(rect.position.x + rect.size.x - 16, rect.position.y + 16),
		Vector2i(rect.position.x + 16, rect.position.y + rect.size.y - 16),
		Vector2i(rect.position.x + rect.size.x - 16, rect.position.y + rect.size.y - 16),
	]:
		_star(image, corner.x, corner.y, 7, color_b)


func _fill_checker(image: Image, a: Color, b: Color, size: int) -> void:
	for y in range(0, image.get_height(), size):
		for x in range(0, image.get_width(), size):
			_rect(image, x, y, size, size, a if ((x / size + y / size) % 2 == 0) else b)


func _new_image(width: int, height: int, color: Color) -> Image:
	var image := Image.create(width, height, false, Image.FORMAT_RGBA8)
	image.fill(color)
	return image


func _save_png(image: Image, path: String) -> void:
	var error := image.save_png(path)
	if error != OK:
		push_error("Could not save PNG: %s" % path)


func _tone(color: Color, amount: float) -> Color:
	return Color(color.r * amount, color.g * amount, color.b * amount, color.a)


func _glow_rect(image: Image, rect: Rect2i, color: Color) -> void:
	for inset in range(8, -1, -2):
		_rect(
			image,
			rect.position.x - inset,
			rect.position.y - inset,
			rect.size.x + inset * 2,
			rect.size.y + inset * 2,
			Color(color.r, color.g, color.b, color.a * (1.0 - float(inset) / 12.0))
		)


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


func _star(image: Image, cx: int, cy: int, radius: int, color: Color) -> void:
	_rect(image, cx, cy - radius, 1, radius * 2 + 1, color)
	_rect(image, cx - radius, cy, radius * 2 + 1, 1, color)
	_rect(image, cx - radius / 2, cy - radius / 2, radius + 1, radius + 1, Color(color.r, color.g, color.b, color.a * 0.34))


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
