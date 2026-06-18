extends Control

@export var background_texture_path: String = ""
@export var frame_texture_path: String = ""
@export var title_text: String = "MINIGAME TITLE"
@export_multiline var instruction_text: String = "Instructions go here."
@export var status_text: String = "Status text goes here."
@export_multiline var result_text: String = ""

@onready var background_texture: TextureRect = $BackgroundLayer/BackgroundTexture
@onready var background_placeholder: ColorRect = $BackgroundLayer/BackgroundPlaceholder
@onready var frame_texture: TextureRect = $CabinetFrameLayer/FrameTexture
@onready var frame_placeholder: Panel = $CabinetFrameLayer/FramePlaceholder
@onready var title_label: Label = $TitleLabel
@onready var instruction_label: Label = $InstructionPanel/InstructionLabel
@onready var status_label: Label = $StatusPanel/StatusLabel
@onready var result_panel: Panel = $ResultPanel
@onready var result_label: Label = $ResultPanel/ResultLabel
@onready var exit_button: Button = $ExitButton

func _ready() -> void:
	_apply_optional_texture(background_texture_path, background_texture, background_placeholder)
	_apply_optional_texture(frame_texture_path, frame_texture, frame_placeholder)
	title_label.text = title_text
	instruction_label.text = instruction_text
	status_label.text = status_text
	set_result_text(result_text)
	exit_button.pressed.connect(_on_exit_pressed)

func set_status_text(text: String) -> void:
	status_text = text
	if status_label:
		status_label.text = status_text

func set_result_text(text: String) -> void:
	result_text = text
	if result_label:
		result_label.text = result_text
	if result_panel:
		result_panel.visible = not result_text.is_empty()

func _apply_optional_texture(path: String, texture_rect: TextureRect, placeholder: CanvasItem) -> void:
	texture_rect.visible = false
	texture_rect.texture = null
	placeholder.visible = true
	if path.is_empty():
		return
	if not ResourceLoader.exists(path):
		return
	var resource := load(path)
	if resource is Texture2D:
		texture_rect.texture = resource
		texture_rect.visible = true
		placeholder.visible = false

func _on_exit_pressed() -> void:
	SceneChanger.go_to_arcade_hub()
