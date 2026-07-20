class_name MinigameUI
extends RefCounted

## Shared typography and fitting rules for minigame/adventure interfaces.
##
## New dynamic text should be configured through this helper (or through
## MinigameTextBox). The layout guard also applies these rules to legacy scenes.

enum TextRole {
	TITLE,
	HEADING,
	BODY,
	COMPACT,
	HUD,
}

const BODY_FONT := preload("res://assets/fonts/m6x11.ttf")
const TITLE_FONT := preload("res://assets/fonts/PressStart2P-Regular.ttf")

const META_MANAGED := "minigame_ui_managed"
const META_ROLE := "minigame_ui_role"
const META_MIN_FONT := "minigame_ui_min_font"
const META_MAX_FONT := "minigame_ui_max_font"
const META_PADDING := "minigame_ui_padding"
const META_CENTER := "minigame_ui_center"
const META_FIT_OK := "minigame_ui_fit_ok"
const META_IGNORE := "minigame_ui_ignore"
const META_FIT_WARNING_SIGNATURE := "minigame_ui_fit_warning_signature"


static func configure_label(
	label: Label,
	role: TextRole = TextRole.BODY,
	wrap := true,
	center := true,
	min_font_size := -1,
	max_font_size := -1,
	padding := Vector2(6.0, 3.0)
) -> void:
	if label == null:
		return
	var defaults := _role_defaults(role)
	var resolved_max := max_font_size
	if resolved_max <= 0:
		resolved_max = int(defaults.max_font)
	var resolved_min := min_font_size
	if resolved_min <= 0:
		resolved_min = int(defaults.min_font)
	resolved_min = mini(resolved_min, resolved_max)

	label.add_theme_font_override("font", defaults.font)
	label.set_meta(META_MANAGED, true)
	label.set_meta(META_ROLE, int(role))
	label.set_meta(META_MIN_FONT, resolved_min)
	label.set_meta(META_MAX_FONT, resolved_max)
	label.set_meta(META_PADDING, padding)
	label.set_meta(META_CENTER, center)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART if wrap else TextServer.AUTOWRAP_OFF
	if center:
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	fit_label(label)


static func adopt_label(label: Label) -> void:
	if label == null or bool(label.get_meta(META_IGNORE, false)):
		return
	if bool(label.get_meta(META_MANAGED, false)):
		fit_label(label)
		return
	var current_size := label.get_theme_font_size("font_size")
	if current_size <= 0:
		current_size = 16
	var role := _infer_role(label.name)
	var wraps := label.autowrap_mode != TextServer.AUTOWRAP_OFF
	var multiline := wraps or label.text.contains("\n")
	var inferred_padding := Vector2(3.0, 2.0)
	if multiline and label.size.y <= 24.0:
		inferred_padding.y = 0.0
	configure_label(
		label,
		role,
		wraps,
		multiline,
		maxi(10, current_size - 4),
		current_size,
		inferred_padding
	)


static func fit_label(label: Label) -> bool:
	if label == null or not bool(label.get_meta(META_MANAGED, false)):
		return true
	if label.size.x <= 0.0 or label.size.y <= 0.0:
		return true
	var padding: Vector2 = label.get_meta(META_PADDING, Vector2.ZERO)
	var available := Vector2(
		maxf(1.0, label.size.x - padding.x * 2.0),
		maxf(1.0, label.size.y - padding.y * 2.0)
	)
	var min_font_size := int(label.get_meta(META_MIN_FONT, 10))
	var max_font_size := int(label.get_meta(META_MAX_FONT, label.get_theme_font_size("font_size")))
	var font_size := max_font_size
	var fits := false
	while font_size >= min_font_size:
		label.add_theme_font_size_override("font_size", font_size)
		if _label_fits(label, available, font_size):
			fits = true
			break
		font_size -= 1
	if not fits:
		label.add_theme_font_size_override("font_size", min_font_size)
	label.clip_text = not fits
	label.set_meta(META_FIT_OK, fits)
	_report_fit_result(label, fits, "label", available, min_font_size)
	return fits


static func configure_button(button: Button, min_font_size := 10, max_font_size := -1, horizontal_padding := 6.0) -> void:
	if button == null:
		return
	var resolved_max := max_font_size
	if resolved_max <= 0:
		resolved_max = button.get_theme_font_size("font_size")
	if resolved_max <= 0:
		resolved_max = 16
	button.set_meta(META_MANAGED, true)
	button.set_meta(META_MIN_FONT, mini(min_font_size, resolved_max))
	button.set_meta(META_MAX_FONT, resolved_max)
	button.set_meta(META_PADDING, Vector2(horizontal_padding, 3.0))
	fit_button(button)


static func fit_button(button: Button) -> bool:
	if button == null or button.text.strip_edges().is_empty() or button.size.x <= 0.0:
		return true
	var padding: Vector2 = button.get_meta(META_PADDING, Vector2(6.0, 3.0))
	var min_font_size := int(button.get_meta(META_MIN_FONT, 10))
	var max_font_size := int(button.get_meta(META_MAX_FONT, button.get_theme_font_size("font_size")))
	var font := button.get_theme_font("font")
	var available_width := button.size.x
	var parent_control := button.get_parent() as Control
	if parent_control != null and parent_control.size.x > 0.0:
		available_width = minf(available_width, parent_control.size.x)
		if button.size.x > parent_control.size.x + 0.5:
			# A container can briefly honor a new caption's minimum width before
			# this guard runs. Clamp only that overflow case; ordinary HBox button
			# minimum sizes remain untouched.
			button.clip_text = true
			button.size.x = parent_control.size.x
	for font_size in range(max_font_size, min_font_size - 1, -1):
		button.add_theme_font_size_override("font_size", font_size)
		var measured := font.get_string_size(button.text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size)
		if measured.x <= maxf(1.0, available_width - padding.x * 2.0):
			button.set_meta(META_FIT_OK, true)
			_report_fit_result(button, true, "button", Vector2(available_width - padding.x * 2.0, button.size.y), font_size)
			return true
	button.add_theme_font_size_override("font_size", min_font_size)
	button.set_meta(META_FIT_OK, false)
	_report_fit_result(button, false, "button", Vector2(available_width - padding.x * 2.0, button.size.y), min_font_size)
	return false


static func fit_vertical_group(
	labels: Array,
	region: Rect2,
	gap := 8.0,
	min_font_size := 12,
	max_font_size := 14,
	padding := Vector2(3.0, 1.0)
) -> bool:
	var active: Array[Label] = []
	for value in labels:
		if value is Label and not (value as Label).text.strip_edges().is_empty():
			active.append(value as Label)
	if active.is_empty():
		return true

	var font_size := max_font_size
	var heights: Array[float] = []
	var fits := false
	while font_size >= min_font_size:
		heights.clear()
		var total_height := gap * maxf(0.0, float(active.size() - 1))
		for label in active:
			configure_label(label, TextRole.HUD, true, true, min_font_size, max_font_size, padding)
			label.add_theme_font_size_override("font_size", font_size)
			var height := measure_label_height(label, region.size.x - padding.x * 2.0, font_size) + padding.y * 2.0
			heights.append(height)
			total_height += height
		if total_height <= region.size.y:
			fits = true
			break
		font_size -= 1

	var used_height := gap * maxf(0.0, float(active.size() - 1))
	for height in heights:
		used_height += height
	var y := region.position.y + maxf(0.0, (region.size.y - used_height) * 0.5)
	for index in range(active.size()):
		var label := active[index]
		label.position = Vector2(region.position.x, y)
		label.size = Vector2(region.size.x, minf(heights[index], region.end.y - y))
		label.add_theme_font_size_override("font_size", maxi(font_size, min_font_size))
		label.set_meta(META_FIT_OK, fits)
		label.clip_text = not fits
		y += heights[index] + gap
	for value in labels:
		if value is Label and (value as Label).text.strip_edges().is_empty():
			(value as Label).size.y = 0.0
	return fits


static func measure_label_height(label: Label, width: float, font_size := -1) -> float:
	if label == null or label.text.strip_edges().is_empty():
		return 0.0
	var resolved_size := font_size if font_size > 0 else label.get_theme_font_size("font_size")
	var font := label.get_theme_font("font")
	var measured := font.get_multiline_string_size(
		label.text,
		HORIZONTAL_ALIGNMENT_CENTER,
		maxf(1.0, width),
		resolved_size
	)
	return ceilf(measured.y + 2.0)


static func make_panel_style(border_color: Color, background_color := Color(0.006, 0.009, 0.015, 0.94), border_width := 2) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background_color
	style.border_color = border_color
	style.set_border_width_all(border_width)
	style.corner_radius_top_left = 2
	style.corner_radius_top_right = 2
	style.corner_radius_bottom_left = 2
	style.corner_radius_bottom_right = 2
	return style


static func _label_fits(label: Label, available: Vector2, font_size: int) -> bool:
	if label.text.strip_edges().is_empty():
		return true
	var font := label.get_theme_font("font")
	var wrap_width := available.x if label.autowrap_mode != TextServer.AUTOWRAP_OFF else -1.0
	var measured := font.get_multiline_string_size(
		label.text,
		label.horizontal_alignment,
		wrap_width,
		font_size
	)
	if measured.y > available.y + 1.0:
		return false
	return label.autowrap_mode != TextServer.AUTOWRAP_OFF or measured.x <= available.x + 1.0


static func _infer_role(node_name: StringName) -> TextRole:
	var normalized := str(node_name).to_lower()
	if normalized.contains("title"):
		return TextRole.TITLE
	if normalized.contains("heading") or normalized.contains("header"):
		return TextRole.HEADING
	if normalized.contains("counter") or normalized.contains("status") or normalized.contains("hud"):
		return TextRole.HUD
	return TextRole.BODY


static func _role_defaults(role: TextRole) -> Dictionary:
	match role:
		TextRole.TITLE:
			return {"font": TITLE_FONT, "min_font": 12, "max_font": 20}
		TextRole.HEADING:
			return {"font": BODY_FONT, "min_font": 13, "max_font": 18}
		TextRole.COMPACT:
			return {"font": BODY_FONT, "min_font": 10, "max_font": 13}
		TextRole.HUD:
			return {"font": BODY_FONT, "min_font": 10, "max_font": 14}
		_:
			return {"font": BODY_FONT, "min_font": 11, "max_font": 16}


static func _report_fit_result(control: Control, fits: bool, kind: String, available: Vector2, font_size: int) -> void:
	if fits:
		if control.has_meta(META_FIT_WARNING_SIGNATURE):
			control.remove_meta(META_FIT_WARNING_SIGNATURE)
		return
	var text_value := ""
	if control is Label:
		text_value = (control as Label).text
	elif control is Button:
		text_value = (control as Button).text
	var signature := "%s|%.1f|%.1f|%d" % [text_value, available.x, available.y, font_size]
	if str(control.get_meta(META_FIT_WARNING_SIGNATURE, "")) == signature:
		return
	control.set_meta(META_FIT_WARNING_SIGNATURE, signature)
	var tree := control.get_tree()
	if tree == null:
		return
	var logger := tree.root.get_node_or_null("DebugLog")
	if logger != null and logger.has_method("warning"):
		logger.call("warning", "ui", "text_did_not_fit", {
			"kind": kind,
			"node": str(control.get_path()),
			"available": available,
			"minimum_font_size": font_size,
			"text": text_value,
		})
