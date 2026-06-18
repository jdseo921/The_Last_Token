extends Node

const CONFIG_PATH := "user://display.cfg"
const CONFIG_SECTION := "display"
const CONFIG_KEY_WINDOW_SIZE_INDEX := "window_size_index"
const WINDOW_SIZES: Array[Vector2i] = [
	Vector2i(640, 440),
	Vector2i(960, 660),
	Vector2i(1280, 880),
]

var window_size_index := 1

func _ready() -> void:
	_load_settings()
	_apply_window_size()

func cycle_window_size() -> void:
	window_size_index = (window_size_index + 1) % WINDOW_SIZES.size()
	_apply_window_size()
	_save_settings()

func get_window_size_label() -> String:
	var size := _get_current_window_size()
	return "Window Size: %d x %d" % [size.x, size.y]

func _get_current_window_size() -> Vector2i:
	return WINDOW_SIZES[clampi(window_size_index, 0, WINDOW_SIZES.size() - 1)]

func _apply_window_size() -> void:
	var size := _get_current_window_size()
	var screen_size := DisplayServer.screen_get_size()
	if screen_size.x > 0 and screen_size.y > 0:
		var max_size := Vector2i(screen_size.x - 80, screen_size.y - 80)
		if size.x > max_size.x or size.y > max_size.y:
			size = _get_largest_size_that_fits(max_size)
	DisplayServer.window_set_size(size)
	DisplayServer.window_set_min_size(WINDOW_SIZES[0])
	var centered_position := (screen_size - size) / 2
	if centered_position.x >= 0 and centered_position.y >= 0:
		DisplayServer.window_set_position(centered_position)

func _get_largest_size_that_fits(max_size: Vector2i) -> Vector2i:
	var best_size := WINDOW_SIZES[0]
	for size in WINDOW_SIZES:
		if size.x <= max_size.x and size.y <= max_size.y:
			best_size = size
	return best_size

func _load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(CONFIG_PATH) != OK:
		return
	window_size_index = int(config.get_value(CONFIG_SECTION, CONFIG_KEY_WINDOW_SIZE_INDEX, window_size_index))
	window_size_index = clampi(window_size_index, 0, WINDOW_SIZES.size() - 1)

func _save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value(CONFIG_SECTION, CONFIG_KEY_WINDOW_SIZE_INDEX, window_size_index)
	config.save(CONFIG_PATH)
