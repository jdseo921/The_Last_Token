extends Control

signal new_memory_requested
signal restore_memory_requested

const ASSET_PATHS := preload("res://scripts/AssetPaths.gd")

@onready var background_texture: TextureRect = $BackgroundLayer/BackgroundTexture
@onready var background_fallback: ColorRect = $BackgroundLayer/BackgroundFallback
@onready var scanline_overlay: TextureRect = $EffectsLayer/ScanlineOverlay
@onready var flicker_overlay: ColorRect = $EffectsLayer/FlickerOverlay
@onready var logo_texture: TextureRect = $UILayer/LogoTexture
@onready var logo_fallback_label: Label = $UILayer/LogoFallbackLabel
@onready var menu_frame: TextureRect = $UILayer/Panel/MenuFrame
@onready var new_memory_button: Button = $UILayer/Panel/VBox/NewMemoryButton
@onready var restore_memory_button: Button = $UILayer/Panel/VBox/RestoreMemoryButton
@onready var window_size_button: Button = $UILayer/Panel/VBox/WindowSizeButton
@onready var quit_button: Button = $UILayer/Panel/VBox/QuitButton

var flicker_tween: Tween = null
var logo_tween: Tween = null
var background_tween: Tween = null

func _ready() -> void:
	_apply_optional_art()
	_start_flicker_pulse()
	_start_logo_glow_pulse()
	_start_background_glow_pulse()
	new_memory_button.pressed.connect(request_new_memory)
	restore_memory_button.pressed.connect(request_restore_memory)
	window_size_button.pressed.connect(_on_window_size_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	_refresh_window_size_button()
	focus_default()

func focus_default() -> void:
	new_memory_button.grab_focus()

func request_new_memory() -> void:
	_play_audio("play_ui_confirm")
	new_memory_requested.emit()

func request_restore_memory() -> void:
	_play_audio("play_ui_confirm")
	restore_memory_requested.emit()

func _on_window_size_pressed() -> void:
	_play_audio("play_ui_confirm")
	DisplayOptions.cycle_window_size()
	_refresh_window_size_button()

func _on_quit_pressed() -> void:
	_play_audio("play_ui_cancel")
	get_tree().quit()

func _refresh_window_size_button() -> void:
	if DisplayOptions and DisplayOptions.has_method("get_window_size_label"):
		window_size_button.text = DisplayOptions.get_window_size_label()

func _apply_optional_art() -> void:
	_apply_texture_with_fallback(ASSET_PATHS.TITLE_BACKGROUND, background_texture, background_fallback)
	_apply_logo_texture()
	_apply_optional_texture(ASSET_PATHS.TITLE_MENU_FRAME, menu_frame)
	_apply_optional_texture(ASSET_PATHS.TITLE_SCANLINE_OVERLAY, scanline_overlay)

func _apply_logo_texture() -> void:
	var texture: Texture2D = ASSET_PATHS.load_texture_or_null(ASSET_PATHS.TITLE_LOGO)
	logo_texture.texture = texture
	logo_texture.visible = texture != null
	logo_fallback_label.visible = texture == null
	logo_texture.modulate = Color.WHITE
	logo_fallback_label.modulate = Color.WHITE

func _apply_texture_with_fallback(path: String, texture_rect: TextureRect, fallback: CanvasItem) -> void:
	var texture: Texture2D = ASSET_PATHS.load_texture_or_null(path)
	texture_rect.texture = texture
	texture_rect.visible = texture != null
	fallback.visible = texture == null
	texture_rect.modulate = Color.WHITE

func _apply_optional_texture(path: String, texture_rect: TextureRect) -> void:
	var texture: Texture2D = ASSET_PATHS.load_texture_or_null(path)
	texture_rect.texture = texture
	texture_rect.visible = texture != null

func _start_flicker_pulse() -> void:
	if flicker_tween and flicker_tween.is_valid():
		flicker_tween.kill()
	flicker_overlay.modulate.a = 0.025
	flicker_tween = create_tween()
	flicker_tween.set_loops()
	flicker_tween.tween_property(flicker_overlay, "modulate:a", 0.045, 1.8)
	flicker_tween.tween_property(flicker_overlay, "modulate:a", 0.014, 1.2)

func _start_logo_glow_pulse() -> void:
	if logo_tween and logo_tween.is_valid():
		logo_tween.kill()
	if not logo_texture.visible:
		return
	logo_tween = create_tween()
	logo_tween.set_loops()
	logo_tween.tween_property(logo_texture, "modulate", Color(1.0, 1.0, 1.0, 0.92), 1.4)
	logo_tween.tween_property(logo_texture, "modulate", Color(0.82, 0.95, 1.0, 1.0), 1.6)

func _start_background_glow_pulse() -> void:
	if background_tween and background_tween.is_valid():
		background_tween.kill()
	if not background_texture.visible:
		return
	background_tween = create_tween()
	background_tween.set_loops()
	background_tween.tween_property(background_texture, "modulate", Color(0.92, 0.96, 1.0, 1.0), 2.4)
	background_tween.tween_property(background_texture, "modulate", Color.WHITE, 2.8)

func _play_audio(method_name: String) -> void:
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager and audio_manager.has_method(method_name):
		audio_manager.call(method_name)
