class_name MinigameTextBox
extends PanelContainer

## Padded, centered, auto-fitting text panel for instructions, status and results.

const MINIGAME_UI := preload("res://scripts/ui/MinigameUI.gd")
const BALANCED_TEXT := preload("res://scripts/BalancedText.gd")

@export_multiline var text_value := ""
@export_enum("Title", "Heading", "Body", "Compact", "HUD") var text_role: int = int(MinigameUI.TextRole.BODY)
@export var min_font_size := -1
@export var max_font_size := -1
@export var horizontal_padding := 12
@export var vertical_padding := 8
@export var wrap_text := true

@onready var content_margin: MarginContainer = $Content
@onready var text_label: Label = $Content/Text


func _ready() -> void:
	_apply_padding()
	text_label.text = BALANCED_TEXT.split_balanced(text_value)
	MINIGAME_UI.configure_label(
		text_label,
		text_role,
		wrap_text,
		true,
		min_font_size,
		max_font_size,
		Vector2.ZERO
	)
	resized.connect(_fit_text)
	call_deferred("_fit_text")


func set_text(value: String) -> void:
	text_value = value
	if not is_node_ready():
		return
	text_label.text = BALANCED_TEXT.split_balanced(text_value)
	_fit_text()


func get_label() -> Label:
	return text_label


func _apply_padding() -> void:
	content_margin.add_theme_constant_override("margin_left", horizontal_padding)
	content_margin.add_theme_constant_override("margin_right", horizontal_padding)
	content_margin.add_theme_constant_override("margin_top", vertical_padding)
	content_margin.add_theme_constant_override("margin_bottom", vertical_padding)


func _fit_text() -> void:
	if is_node_ready():
		# Hidden container branches do not receive a layout pass. Assigning the
		# inner rectangle here keeps result panels correct the instant they open.
		content_margin.position = Vector2.ZERO
		content_margin.size = size
		text_label.position = Vector2(horizontal_padding, vertical_padding)
		text_label.size = Vector2(
			maxf(1.0, size.x - horizontal_padding * 2.0),
			maxf(1.0, size.y - vertical_padding * 2.0)
		)
		MINIGAME_UI.fit_label(text_label)
