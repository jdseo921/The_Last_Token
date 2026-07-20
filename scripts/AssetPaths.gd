extends RefCounted
class_name AssetPaths

const ART_ROOT := "res://assets/art/"

const HUB := ART_ROOT + "hub/"
const HUB_BACKGROUNDS := HUB + "backgrounds/"
const HUB_PROPS := HUB + "props/"
const HUB_CABINETS := HUB + "cabinets/"
const HUB_BACKGROUND_ARCADE := HUB_BACKGROUNDS + "arcade_hub_background_640x440.png"
const HUB_TICKET_COUNTER := HUB_PROPS + "ticket_counter.png"
const HUB_STAFF_DOOR_CLOSED := HUB_PROPS + "staff_door_closed.png"
const HUB_STAFF_DOOR_OPEN := HUB_PROPS + "staff_door_open.png"
const HUB_OWNER_PORTRAIT_BLANK := HUB_PROPS + "owner_portrait_blank.png"
const HUB_OWNER_PORTRAIT_EMPLOYEE04 := HUB_PROPS + "owner_portrait_employee04.png"
const HUB_CABINET_07_IDLE := HUB_CABINETS + "cabinet_07_idle.png"
const HUB_CABINET_07_FLICKER := HUB_CABINETS + "cabinet_07_flicker.png"
const HUB_CABINET_07_FLICKER_SHEET := HUB_CABINETS + "cabinet_07_flicker_sheet.png"
const HUB_BROKEN_CABINET := HUB_CABINETS + "broken_cabinet.png"

const UI := ART_ROOT + "ui/"
const UI_TITLE := UI + "title/"
const UI_MENUS := UI + "menus/"
const TITLE_BACKGROUND := UI_TITLE + "title_background_640x440.png"
const TITLE_LOGO := UI_TITLE + "the_last_token_logo.png"
const TITLE_MENU_FRAME := UI_TITLE + "title_menu_frame.png"
const TITLE_SCANLINE_OVERLAY := UI_TITLE + "title_scanline_overlay.png"
const QUEST_WINDOW_FRAME := UI_MENUS + "quest_window_frame.png"


static func load_texture_or_null(path: String) -> Texture2D:
	if path.is_empty():
		return null
	if ResourceLoader.exists(path):
		var resource := load(path)
		if resource is Texture2D:
			return resource
	if path.ends_with(".png"):
		var image := Image.new()
		var error := image.load(path)
		if error != OK and path.begins_with("res://"):
			error = image.load(ProjectSettings.globalize_path(path))
		if error == OK:
			return ImageTexture.create_from_image(image)
	return null
