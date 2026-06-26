extends SceneTree

const PORTRAIT_REGISTRY := preload("res://scripts/DialoguePortraitRegistry.gd")
const DIALOGUE_DIR := "res://data/dialogue"

var failed := false

func _init() -> void:
	print("DialoguePortraitSmoke: checking dialogue portrait registry")
	_expect_portrait("Player", false, "res://assets/art/portraits/player/player_obscured.png")
	_expect_portrait("Player", true, "res://assets/art/portraits/player/player_neutral.png")
	_expect_portrait("\"Player\"", false, "res://assets/art/portraits/player/player_conscience_revealed.png")
	_expect_portrait("Roxy", false, "res://assets/art/portraits/roxy/roxy_smug.png")
	_expect_portrait("Pip", false, "res://assets/art/portraits/pip/pip_warm.png")
	_check_dialogue_portrait_references()
	if failed:
		push_error("DialoguePortraitSmoke: FAIL")
		quit(1)
		return
	print("DialoguePortraitSmoke: PASS")
	quit(0)

func _expect_portrait(speaker: String, player_revealed: bool, expected_path: String) -> void:
	var actual_path := PORTRAIT_REGISTRY.get_default_portrait_path(speaker, player_revealed)
	if actual_path != expected_path:
		_fail("%s portrait path expected %s but got %s" % [speaker, expected_path, actual_path])
		return
	if not ResourceLoader.exists(actual_path):
		_fail("%s portrait resource missing at %s" % [speaker, actual_path])
		return
	var resource := load(actual_path)
	if not resource is Texture2D:
		_fail("%s portrait is not a Texture2D: %s" % [speaker, actual_path])

func _check_dialogue_portrait_references() -> void:
	var dir := DirAccess.open(DIALOGUE_DIR)
	if dir == null:
		_fail("Dialogue portrait directory missing: %s" % DIALOGUE_DIR)
		return
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while not file_name.is_empty():
		if not dir.current_is_dir() and file_name.ends_with(".json"):
			_check_dialogue_file("%s/%s" % [DIALOGUE_DIR, file_name])
		file_name = dir.get_next()
	dir.list_dir_end()

func _check_dialogue_file(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		_fail("Dialogue portrait file unreadable: %s" % path)
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		_fail("Dialogue portrait file is not a JSON object: %s" % path)
		return
	_scan_variant_for_portraits(parsed, path)

func _scan_variant_for_portraits(value: Variant, source_path: String) -> void:
	if value is Dictionary:
		var dict: Dictionary = value
		if dict.has("portrait"):
			_expect_portrait_resource(str(dict.get("portrait", "")), source_path)
		for child: Variant in dict.values():
			_scan_variant_for_portraits(child, source_path)
		return
	if value is Array:
		var array: Array = value
		for child: Variant in array:
			_scan_variant_for_portraits(child, source_path)

func _expect_portrait_resource(path: String, source_path: String) -> void:
	if path.is_empty():
		_fail("Empty portrait path in %s" % source_path)
		return
	if not ResourceLoader.exists(path):
		_fail("Portrait resource missing at %s referenced by %s" % [path, source_path])
		return
	var resource := load(path)
	if not resource is Texture2D:
		_fail("Portrait resource is not a Texture2D at %s referenced by %s" % [path, source_path])

func _fail(message: String) -> void:
	failed = true
	push_error(message)
