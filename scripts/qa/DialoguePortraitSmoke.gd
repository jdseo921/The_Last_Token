extends SceneTree

const PORTRAIT_REGISTRY := preload("res://scripts/DialoguePortraitRegistry.gd")
const DIALOGUE_DIR := "res://data/dialogue"
const REFRESHED_PORTRAITS := [
	"res://assets/art/portraits/mira/mira_neutral.png",
	"res://assets/art/portraits/mira/mira_worried.png",
	"res://assets/art/portraits/mira/mira_sad.png",
	"res://assets/art/portraits/mira/mira_relieved.png",
	"res://assets/art/portraits/mira/mira_afraid.png",
	"res://assets/art/portraits/gus/gus_neutral.png",
	"res://assets/art/portraits/gus/gus_deadpan.png",
	"res://assets/art/portraits/gus/gus_caring.png",
	"res://assets/art/portraits/gus/gus_annoyed.png",
	"res://assets/art/portraits/gus/gus_alarmed.png",
	"res://assets/art/portraits/night_ledger/night_ledger_neutral.png",
	"res://assets/art/portraits/night_ledger/night_ledger_dry.png",
	"res://assets/art/portraits/night_ledger/night_ledger_grave.png",
	"res://assets/art/portraits/night_ledger/night_ledger_delighted.png",
	"res://assets/art/portraits/night_ledger/night_ledger_panic.png",
	"res://assets/art/portraits/night_ledger/night_ledger_grin.png",
]
const SIDE_SAFETY_MARGIN := 4

var failed := false

func _init() -> void:
	print("DialoguePortraitSmoke: checking dialogue portrait registry")
	_expect_portrait("Player", false, "res://assets/art/portraits/player/player_obscured.png")
	_expect_portrait("Player", true, "res://assets/art/portraits/player/player_neutral.png")
	_expect_portrait("\"Player\"", false, "res://assets/art/portraits/player/player_conscience_revealed.png")
	_expect_portrait("Roxy", false, "res://assets/art/portraits/roxy/roxy_smug.png")
	_expect_portrait("Pip", false, "res://assets/art/portraits/pip/pip_warm.png")
	_expect_portrait("Night Ledger", false, "res://assets/art/portraits/night_ledger/night_ledger_neutral.png")
	_expect_portrait("Mira", false, "res://assets/art/portraits/mira/mira_neutral.png")
	_expect_portrait("Gus", false, "res://assets/art/portraits/gus/gus_neutral.png")
	_expect_portrait("SIP-2", false, "res://assets/art/portraits/vendo/vendo_neutral.png")
	for portrait_path in REFRESHED_PORTRAITS:
		_expect_refreshed_portrait(portrait_path)
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

func _expect_refreshed_portrait(path: String) -> void:
	var image := Image.new()
	var load_error := image.load(ProjectSettings.globalize_path(path))
	if load_error != OK:
		_fail("Refreshed portrait cannot be read: %s" % path)
		return
	if image.get_size() != Vector2i(128, 128):
		_fail("Refreshed portrait must be 128x128: %s" % path)
		return
	if image.get_pixel(0, 0).a > 0.05:
		_fail("Refreshed portrait must keep transparent corners: %s" % path)
	for y in range(image.get_height()):
		for x in range(SIDE_SAFETY_MARGIN):
			if image.get_pixel(x, y).a > 0.05 or image.get_pixel(image.get_width() - 1 - x, y).a > 0.05:
				_fail("Refreshed portrait clips the side safety margin: %s" % path)
				return
	var head_center_x := _get_upper_foreground_center_x(image)
	if absf(head_center_x - 64.0) > 3.5:
		_fail("Refreshed portrait head is not centered (%.2f): %s" % [head_center_x, path])

func _get_upper_foreground_center_x(image: Image) -> float:
	var upper_limit := int(round(float(image.get_height()) * 0.48))
	var weighted_x := 0.0
	var total_weight := 0.0
	for y in range(upper_limit):
		for x in range(image.get_width()):
			var alpha := image.get_pixel(x, y).a
			if alpha <= 0.05:
				continue
			weighted_x += float(x) * alpha
			total_weight += alpha
	return weighted_x / total_weight if total_weight > 0.0 else 64.0

func _fail(message: String) -> void:
	failed = true
	push_error(message)
