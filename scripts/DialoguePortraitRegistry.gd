extends RefCounted
class_name DialoguePortraitRegistry

const DEFAULT_PORTRAITS := {
	"Mira": "res://assets/art/portraits/mira/mira_neutral.png",
	"Gus": "res://assets/art/portraits/gus/gus_neutral.png",
	"Vendo": "res://assets/art/portraits/vendo/vendo_neutral.png",
	"Mr. Byte": "res://assets/art/portraits/mr_byte/mr_byte_neutral.png",
	"Cabinet 07": "res://assets/art/portraits/mr_byte/cabinet_07_screen.png",
	"Player": "res://assets/art/portraits/player/player_neutral.png",
}

static func get_default_portrait_path(speaker: String) -> String:
	return str(DEFAULT_PORTRAITS.get(speaker, ""))
