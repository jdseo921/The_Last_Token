extends RefCounted
class_name DialoguePortraitRegistry

const PLAYER_OBSCURED_PORTRAIT := "res://assets/art/portraits/player/player_obscured.png"
const PLAYER_REVEALED_PORTRAIT := "res://assets/art/portraits/player/player_neutral.png"
const PLAYER_CONSCIENCE_REVEALED_PORTRAIT := "res://assets/art/portraits/player/player_conscience_revealed.png"

const DEFAULT_PORTRAITS := {
	"Mira": "res://assets/art/portraits/mira/mira_neutral.png",
	"Gus": "res://assets/art/portraits/gus/gus_neutral.png",
	"Vendo": "res://assets/art/portraits/vendo/vendo_neutral.png",
	"SIP-2": "res://assets/art/portraits/vendo/vendo_neutral.png",
	"Mr. Byte": "res://assets/art/portraits/mr_byte/mr_byte_neutral.png",
	"Cabinet 07": "res://assets/art/portraits/mr_byte/cabinet_07_screen.png",
	"Roxy": "res://assets/art/portraits/roxy/roxy_smug.png",
	"Pip": "res://assets/art/portraits/pip/pip_warm.png",
	"Night Ledger": "res://assets/art/portraits/night_ledger/night_ledger_neutral.png",
	"\"Player\"": PLAYER_CONSCIENCE_REVEALED_PORTRAIT,
}

static func get_default_portrait_path(speaker: String, player_revealed := false) -> String:
	if speaker == "Player":
		return PLAYER_REVEALED_PORTRAIT if player_revealed else PLAYER_OBSCURED_PORTRAIT
	return str(DEFAULT_PORTRAITS.get(speaker, ""))
