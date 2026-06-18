extends RefCounted
class_name AssetPaths

const ART_ROOT := "res://assets/art/"

const CHARACTERS := ART_ROOT + "characters/"
const CHARACTER_PLAYER := CHARACTERS + "player/"
const CHARACTER_MIRA := CHARACTERS + "mira/"
const CHARACTER_GUS := CHARACTERS + "gus/"
const CHARACTER_VENDO := CHARACTERS + "vendo/"
const CHARACTER_MR_BYTE := CHARACTERS + "mr_byte/"
const CHARACTER_ROXY := CHARACTERS + "roxy/"
const CHARACTER_PIP := CHARACTERS + "pip/"

const PORTRAITS := ART_ROOT + "portraits/"
const PORTRAIT_PLAYER := PORTRAITS + "player/"
const PORTRAIT_MIRA := PORTRAITS + "mira/"
const PORTRAIT_GUS := PORTRAITS + "gus/"
const PORTRAIT_VENDO := PORTRAITS + "vendo/"
const PORTRAIT_MR_BYTE := PORTRAITS + "mr_byte/"
const PORTRAIT_ROXY := PORTRAITS + "roxy/"
const PORTRAIT_PIP := PORTRAITS + "pip/"

const HUB := ART_ROOT + "hub/"
const HUB_TILES := HUB + "tiles/"
const HUB_PROPS := HUB + "props/"
const HUB_CABINETS := HUB + "cabinets/"
const HUB_EFFECTS := HUB + "effects/"

const MINIGAMES := ART_ROOT + "minigames/"
const MINIGAME_ROCKBYTE_DUEL := MINIGAMES + "rockbyte_duel/"
const MINIGAME_SYNC_DOOR := MINIGAMES + "sync_door/"
const MINIGAME_BROKEN_HIGH_SCORE := MINIGAMES + "broken_high_score/"

const CUTSCENES := ART_ROOT + "cutscenes/"
const CUTSCENE_MEMORY_REVEAL := CUTSCENES + "memory_reveal/"

const UI := ART_ROOT + "ui/"
const UI_DIALOGUE := UI + "dialogue/"
const UI_TITLE := UI + "title/"
const UI_MENUS := UI + "menus/"
const UI_CRT := UI + "crt/"

static func exists(path: String) -> bool:
	if path.is_empty():
		return false
	return ResourceLoader.exists(path)

static func load_texture_or_null(path: String) -> Texture2D:
	if not exists(path):
		return null
	var resource := load(path)
	if resource is Texture2D:
		return resource
	return null
