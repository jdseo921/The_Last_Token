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
const HUB_BACKGROUNDS := HUB + "backgrounds/"
const HUB_TILES := HUB + "tiles/"
const HUB_PROPS := HUB + "props/"
const HUB_CABINETS := HUB + "cabinets/"
const HUB_EFFECTS := HUB + "effects/"
const HUB_BACKGROUND_ARCADE := HUB_BACKGROUNDS + "arcade_hub_background_640x440.png"
const HUB_TICKET_COUNTER := HUB_PROPS + "ticket_counter.png"
const HUB_MEMORY_TERMINAL := HUB_PROPS + "memory_terminal.png"
const HUB_STAFF_DOOR_CLOSED := HUB_PROPS + "staff_door_closed.png"
const HUB_STAFF_DOOR_OPEN := HUB_PROPS + "staff_door_open.png"
const HUB_OWNER_PORTRAIT_BLANK := HUB_PROPS + "owner_portrait_blank.png"
const HUB_OWNER_PORTRAIT_EMPLOYEE04 := HUB_PROPS + "owner_portrait_employee04.png"
const HUB_CABINET_07_IDLE := HUB_CABINETS + "cabinet_07_idle.png"
const HUB_CABINET_07_FLICKER := HUB_CABINETS + "cabinet_07_flicker.png"
const HUB_CABINET_07_FLICKER_SHEET := HUB_CABINETS + "cabinet_07_flicker_sheet.png"
const HUB_BROKEN_CABINET := HUB_CABINETS + "broken_cabinet.png"

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
const TITLE_BACKGROUND := UI_TITLE + "title_background_640x440.png"
const TITLE_LOGO := UI_TITLE + "the_last_token_logo.png"
const TITLE_MENU_FRAME := UI_TITLE + "title_menu_frame.png"
const TITLE_SCANLINE_OVERLAY := UI_TITLE + "title_scanline_overlay.png"

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
