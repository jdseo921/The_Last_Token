extends CanvasLayer

signal quest_closed

const ASSET_PATHS := preload("res://scripts/AssetPaths.gd")
const NOTIFICATION_FADE_IN_SECONDS := 1.0
const NOTIFICATION_HOLD_SECONDS := 3.0
const NOTIFICATION_FADE_OUT_SECONDS := 1.5
const PANEL_SCREEN_RATIO := Vector2(0.8, 0.8)
const DEFAULT_VIEWPORT_SIZE := Vector2(640.0, 440.0)
const NOTIFICATION_TIP_TEXT := "Tip: Press Esc, then choose Quest to read these details again."

@onready var panel: Panel = $Panel
@onready var frame_texture: TextureRect = $Panel/FrameTexture
@onready var eyebrow_label: Label = $Panel/EyebrowLabel
@onready var title_label: Label = $Panel/TitleLabel
@onready var body_label: Label = $Panel/BodyLabel
@onready var tip_label: Label = $Panel/TipLabel
@onready var close_button: Button = $Panel/CloseButton

var hide_tween: Tween = null
var notification_token := 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	close_button.pressed.connect(_on_close_pressed)
	_apply_frame_art()

func show_notification(quest_data: Dictionary) -> void:
	notification_token += 1
	_configure_window(
		"NEW QUEST",
		str(quest_data.get("title", "Quest Updated")),
		str(quest_data.get("summary", "")),
		false
	)
	visible = true
	panel.modulate.a = 0.0
	_play_audio("play_quest_update")
	if hide_tween and hide_tween.is_valid():
		hide_tween.kill()
	hide_tween = create_tween()
	hide_tween.tween_property(panel, "modulate:a", 1.0, NOTIFICATION_FADE_IN_SECONDS)
	hide_tween.tween_interval(NOTIFICATION_HOLD_SECONDS)
	hide_tween.tween_property(panel, "modulate:a", 0.0, NOTIFICATION_FADE_OUT_SECONDS)
	hide_tween.tween_callback(hide)

func show_details(quest_data: Dictionary) -> void:
	notification_token += 1
	if hide_tween and hide_tween.is_valid():
		hide_tween.kill()
	_configure_window(
		"ACTIVE QUEST",
		str(quest_data.get("title", "No Active Quest")),
		str(quest_data.get("details", "")),
		true
	)
	visible = true
	panel.modulate.a = 1.0
	close_button.grab_focus()
	_play_audio("play_ui_confirm")

func close_details() -> void:
	hide()
	quest_closed.emit()

func _configure_window(eyebrow: String, title: String, body: String, details_mode: bool) -> void:
	eyebrow_label.text = eyebrow
	title_label.text = title
	body_label.text = body
	tip_label.visible = not details_mode
	tip_label.text = NOTIFICATION_TIP_TEXT if not details_mode else ""
	close_button.visible = details_mode
	var rect := _get_scaled_panel_rect()
	var content_left := rect.size.x * 0.14
	var content_width := rect.size.x * 0.72
	panel.offset_left = rect.position.x
	panel.offset_top = rect.position.y
	panel.offset_right = rect.position.x + rect.size.x
	panel.offset_bottom = rect.position.y + rect.size.y
	eyebrow_label.offset_left = content_left
	eyebrow_label.offset_top = rect.size.y * 0.16
	eyebrow_label.offset_right = content_left + content_width
	eyebrow_label.offset_bottom = eyebrow_label.offset_top + rect.size.y * 0.07
	title_label.offset_left = eyebrow_label.offset_left
	title_label.offset_top = rect.size.y * 0.27
	title_label.offset_right = content_left + content_width
	title_label.offset_bottom = title_label.offset_top + rect.size.y * 0.12
	body_label.offset_left = content_left
	body_label.offset_top = rect.size.y * 0.43
	body_label.offset_right = content_left + content_width
	body_label.offset_bottom = rect.size.y * 0.82 if details_mode else rect.size.y * 0.70
	tip_label.offset_left = content_left
	tip_label.offset_top = rect.size.y * 0.76
	tip_label.offset_right = content_left + content_width
	tip_label.offset_bottom = rect.size.y * 0.86
	close_button.offset_left = (rect.size.x - 124.0) * 0.5
	close_button.offset_top = rect.size.y * 0.88
	close_button.offset_right = close_button.offset_left + 124.0
	close_button.offset_bottom = close_button.offset_top + 28.0

func _get_scaled_panel_rect() -> Rect2:
	var viewport_size := get_viewport().get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		viewport_size = DEFAULT_VIEWPORT_SIZE
	var panel_size := Vector2(
		viewport_size.x * PANEL_SCREEN_RATIO.x,
		viewport_size.y * PANEL_SCREEN_RATIO.y
	)
	var panel_position := (viewport_size - panel_size) * 0.5
	return Rect2(panel_position, panel_size)

func _apply_frame_art() -> void:
	var texture := ASSET_PATHS.load_texture_or_null(ASSET_PATHS.QUEST_WINDOW_FRAME)
	frame_texture.visible = texture != null
	frame_texture.texture = texture
	panel.self_modulate.a = 0.0 if texture != null else 0.92

func _on_close_pressed() -> void:
	_play_audio("play_ui_cancel")
	close_details()

func _play_audio(method_name: String) -> void:
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager and audio_manager.has_method(method_name):
		audio_manager.call(method_name)
