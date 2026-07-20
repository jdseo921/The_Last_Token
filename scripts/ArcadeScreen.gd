extends RefCounted
class_name ArcadeScreen

# Shared "arcade cabinet screen" framing for minigames/puzzles/stages.
# One call — ArcadeScreen.apply(self) in _ready — wraps any full-rect Control host
# in scanlines + a neon CRT bezel + vignette, so every stage reads as a polished
# cabinet screen. Overlays are mouse-ignore and high-z, so they never block input.

const CRT_OVERLAY_PATH := "res://assets/art/ui/crt/crt_overlay.svg"

static func apply(host: Control, background_path: String = "", include_scanlines := true) -> void:
	if host == null or not is_instance_valid(host):
		return
	if not background_path.is_empty():
		_apply_background(host, background_path)
	if host.has_node("ArcadeScanlines") or host.has_node("ArcadeCRTOverlay"):
		return
	if include_scanlines:
		var scan := TextureRect.new()
		scan.name = "ArcadeScanlines"
		scan.texture = _make_scanline_texture()
		scan.stretch_mode = TextureRect.STRETCH_TILE
		scan.set_anchors_preset(Control.PRESET_FULL_RECT)
		scan.mouse_filter = Control.MOUSE_FILTER_IGNORE
		scan.z_index = 90
		host.add_child(scan)
	var tex := _load_texture(CRT_OVERLAY_PATH)
	if tex != null:
		var overlay := TextureRect.new()
		overlay.name = "ArcadeCRTOverlay"
		overlay.texture = tex
		overlay.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		overlay.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
		overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		overlay.z_index = 95
		host.add_child(overlay)

# Insert a bespoke neon screen behind the gameplay. Handles both scene shapes:
# a CanvasLayer "BackgroundLayer" (Rockbyte/TruthFilter) or a plain "Background"
# ColorRect child. The opaque placeholder is hidden so the art shows through.
static func _apply_background(host: Control, path: String) -> void:
	var tex := _load_texture(path)
	if tex == null:
		return
	var layer_node := host.get_node_or_null("BackgroundLayer")
	var parent_node: Node = host if layer_node == null else layer_node
	if parent_node.has_node("ArcadeBackground"):
		return
	for ph_name in ["BackgroundPlaceholder", "Background"]:
		var ph := parent_node.get_node_or_null(ph_name)
		if ph != null and ph is CanvasItem:
			(ph as CanvasItem).visible = false
	var bg := TextureRect.new()
	bg.name = "ArcadeBackground"
	bg.texture = tex
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent_node.add_child(bg)
	parent_node.move_child(bg, 0)

static func _make_scanline_texture() -> ImageTexture:
	var img := Image.create(4, 4, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for x in range(4):
		img.set_pixel(x, 0, Color(0, 0, 0, 0.43))
		img.set_pixel(x, 1, Color(0, 0, 0, 0.19))
	return ImageTexture.create_from_image(img)

static func _load_texture(path: String) -> Texture2D:
	if path.is_empty():
		return null
	if ResourceLoader.exists(path):
		var resource := load(path)
		if resource is Texture2D:
			return resource
	return _load_raw_png_texture(path)

static func _load_raw_png_texture(path: String) -> Texture2D:
	if not path.ends_with(".png"):
		return null
	var image := Image.new()
	var error := image.load(path)
	if error != OK and path.begins_with("res://"):
		error = image.load(ProjectSettings.globalize_path(path))
	if error != OK:
		return null
	return ImageTexture.create_from_image(image)
