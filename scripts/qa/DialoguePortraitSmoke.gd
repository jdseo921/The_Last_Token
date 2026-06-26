extends SceneTree

const PORTRAIT_REGISTRY := preload("res://scripts/DialoguePortraitRegistry.gd")

var failed := false

func _init() -> void:
	print("DialoguePortraitSmoke: checking dialogue portrait registry")
	_expect_portrait("Player", false, "res://assets/art/portraits/player/player_obscured.png")
	_expect_portrait("Player", true, "res://assets/art/portraits/player/player_neutral.png")
	_expect_portrait("\"Player\"", false, "res://assets/art/portraits/player/player_conscience_revealed.png")
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

func _fail(message: String) -> void:
	failed = true
	push_error(message)
