extends Control

const ARCADE_JUICE := preload("res://scripts/ArcadeJuice.gd")

const FRAGMENTS := [
	"Counter lights shut off.",
	"Cabinet 07 remains powered.",
	"A staff member enters the back hall.",
	"The Staff Door records two signals.",
]

const CORRECT_ORDER := [
	"Counter lights shut off.",
	"Cabinet 07 remains powered.",
	"A staff member enters the back hall.",
	"The Staff Door records two signals.",
]

const ANOMALY_TEXT := "A second figure stands at the door. No timestamp."
const STATIC_TEXT := "▓▓▓ STATIC ▓▓▓  (press to clear)"

const BACKGROUND_ART_PATH := "res://assets/art/minigames/security_tape/security_tape_background.png"
const FRAGMENT_PANEL_ART_PATH := "res://assets/art/minigames/security_tape/tape_fragment_panel.png"
const STATIC_OVERLAY_ART_PATH := "res://assets/art/minigames/security_tape/tape_static_overlay.png"

@onready var status_label: Label = $Panel/StatusLabel
@onready var selected_label: Label = $Panel/SelectedLabel
@onready var hint_label: Label = $Panel/HintLabel
@onready var submit_button: Button = $Panel/Controls/SubmitButton
@onready var reset_button: Button = $Panel/Controls/ResetButton
@onready var completion_overlay: Control = $CompletionOverlay
@onready var completion_message: Label = $CompletionOverlay/CompletionPanel/MessageLabel
@onready var return_button: Button = $CompletionOverlay/CompletionPanel/ReturnButton
@onready var fragment_container: VBoxContainer = $Panel/Fragments
@onready var fragment_a: Button = $Panel/Fragments/FragmentA
@onready var fragment_b: Button = $Panel/Fragments/FragmentB
@onready var fragment_c: Button = $Panel/Fragments/FragmentC
@onready var fragment_d: Button = $Panel/Fragments/FragmentD

var selected_fragments: Array[String] = []
var display_fragments: Array = []
var fragment_buttons: Array[Button] = []
var revealed_indices: Dictionary = {}
var anomaly_acknowledged := false
var feedback_flash: ColorRect = null

func _ready() -> void:
	ArcadeScreen.apply(self, "res://assets/art/minigames/security_tape/backgrounds/security_tape_screen.svg")
	GameState.start_security_tape_assembly()
	_apply_optional_art_hooks()
	_setup_feedback_flash()
	var fragment_e := Button.new()
	fragment_e.name = "FragmentE"
	fragment_container.add_child(fragment_e)
	fragment_buttons = [fragment_a, fragment_b, fragment_c, fragment_d, fragment_e]
	display_fragments = FRAGMENTS.duplicate()
	display_fragments.append(ANOMALY_TEXT)
	randomize()
	display_fragments.shuffle()
	while _looks_presolved():
		display_fragments.shuffle()
	for index in range(fragment_buttons.size()):
		var button: Button = fragment_buttons[index]
		button.text = STATIC_TEXT
		button.add_theme_font_size_override("font_size", 14)
		if not button.pressed.is_connected(_on_fragment_pressed):
			button.pressed.connect(_on_fragment_pressed.bind(index))
	submit_button.pressed.connect(_on_submit_pressed)
	reset_button.pressed.connect(_reset_selection)
	return_button.pressed.connect(_return_to_staff_corridor)
	completion_overlay.visible = false
	status_label.text = "Clear the static, then put the night back in order.\nOne frame will not fit. Watch the timestamps."
	_refresh_view()

func _looks_presolved() -> bool:
	for i in range(CORRECT_ORDER.size()):
		if i >= display_fragments.size() or display_fragments[i] != CORRECT_ORDER[i]:
			return false
	return true

func _on_fragment_pressed(index: int) -> void:
	if index < 0 or index >= display_fragments.size():
		return
	if not revealed_indices.get(index, false):
		revealed_indices[index] = true
		fragment_buttons[index].text = display_fragments[index]
		ARCADE_JUICE.pulse_control(self, fragment_buttons[index])
		_play_audio("play_button_pulse")
		_flash_feedback(ARCADE_JUICE.FLASH_CYAN, 0.1)
		return
	var fragment: String = display_fragments[index]
	if selected_fragments.has(fragment):
		_play_audio("play_error_buzz")
		_flash_feedback(ARCADE_JUICE.FLASH_RED, 0.28)
		return
	if selected_fragments.size() >= CORRECT_ORDER.size():
		_play_audio("play_error_buzz")
		status_label.text = "The reel only has four slots.\nOne of the five frames does not belong."
		return
	ARCADE_JUICE.pulse_control(self, fragment_buttons[index])
	_play_audio("play_button_pulse")
	selected_fragments.append(fragment)
	_refresh_view()

func _on_submit_pressed() -> void:
	if selected_fragments.size() != CORRECT_ORDER.size():
		ARCADE_JUICE.pulse_control(self, submit_button, ARCADE_JUICE.PULSE_RED)
		_play_audio("play_error_buzz")
		_flash_feedback(ARCADE_JUICE.FLASH_RED, 0.28)
		status_label.text = "TAPE HEAD BUZZES.\nSeat four frames before playback."
		return
	if selected_fragments.has(ANOMALY_TEXT):
		GameState.record_security_tape_wrong_order()
		_play_audio("play_error_buzz")
		_flash_feedback(ARCADE_JUICE.FLASH_RED, 0.4)
		status_label.text = "FRAME REJECTED: NO TIMESTAMP.\nThat frame does not belong to any hour of that night.\nThe recorder has no matching entry."
		anomaly_acknowledged = true
		_reset_selection(false)
		return
	if selected_fragments == CORRECT_ORDER:
		ARCADE_JUICE.pulse_control(self, submit_button, ARCADE_JUICE.PULSE_GREEN)
		_play_audio("play_success_jingle")
		_flash_feedback(ARCADE_JUICE.FLASH_CYAN, 0.32)
		GameState.complete_security_tape_assembly()
		var closing := "THE STAFF DOOR DID NOT RECORD A CUSTOMER."
		if anomaly_acknowledged:
			closing += "\nOne frame stays on the reel. It has no hour to return to."
		else:
			closing += "\nOne frame was never seated. It has no hour to return to."
		closing += "\nTake the restored tape to the terminal."
		status_label.text = ""
		_set_fragment_buttons_disabled(true)
		submit_button.disabled = true
		reset_button.disabled = true
		_show_completion_popup(closing)
		return
	GameState.record_security_tape_wrong_order()
	_play_audio("play_error_buzz")
	_flash_feedback(ARCADE_JUICE.FLASH_RED, 0.34)
	status_label.text = "TIMESTAMP CONFLICT.\nThe tape rewinds with an angry buzz."
	_reset_selection(false)

func _reset_selection(play_sound: bool = true) -> void:
	if play_sound and not selected_fragments.is_empty():
		ARCADE_JUICE.pulse_control(self, reset_button)
		_play_audio("play_button_pulse")
	selected_fragments.clear()
	_refresh_view()

func _refresh_view() -> void:
	var lines := PackedStringArray()
	for index in range(CORRECT_ORDER.size()):
		var slot_text := "[empty]"
		if index < selected_fragments.size():
			slot_text = selected_fragments[index]
		lines.append("%d. %s" % [index + 1, slot_text])
	selected_label.text = "RESTORED ORDER\n%s" % "\n".join(lines)
	for index in range(fragment_buttons.size()):
		var button: Button = fragment_buttons[index]
		var fragment: String = display_fragments[index]
		button.disabled = (revealed_indices.get(index, false) and selected_fragments.has(fragment)) or GameState.security_tape_assembly_completed
	hint_label.visible = GameState.security_tape_wrong_order_count >= 2 and not GameState.security_tape_assembly_completed
	submit_button.disabled = GameState.security_tape_assembly_completed
	reset_button.disabled = GameState.security_tape_assembly_completed

func _set_fragment_buttons_disabled(disabled: bool) -> void:
	for button in fragment_buttons:
		button.disabled = disabled

func _show_completion_popup(message: String) -> void:
	completion_message.text = message
	completion_overlay.visible = true
	return_button.grab_focus()

func _return_to_staff_corridor() -> void:
	ARCADE_JUICE.pulse_control(self, return_button)
	_play_audio("play_button_pulse")
	GameState.set_pending_spawn_id("Spawn_FromSecurityTape")
	SceneChanger.go_to_staff_room()

func _flash_feedback(color: Color, peak_alpha: float) -> void:
	ARCADE_JUICE.flash_overlay(self, feedback_flash, color, peak_alpha)

func _setup_feedback_flash() -> void:
	feedback_flash = ColorRect.new()
	feedback_flash.name = "ArcadeFeedbackFlash"
	feedback_flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	feedback_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	feedback_flash.visible = false
	feedback_flash.z_index = 80
	add_child(feedback_flash)

func _apply_optional_art_hooks() -> void:
	_add_optional_full_rect_texture(BACKGROUND_ART_PATH, 0, "SecurityTapeBackgroundArt")
	_add_optional_full_rect_texture(STATIC_OVERLAY_ART_PATH, 10, "SecurityTapeStaticOverlay")
	var fragment_texture := _load_texture_or_null(FRAGMENT_PANEL_ART_PATH)
	if fragment_texture == null:
		return
	for button in [fragment_a, fragment_b, fragment_c, fragment_d]:
		button.icon = fragment_texture
		button.expand_icon = true

func _add_optional_full_rect_texture(path: String, z_index_value: int, node_name: String) -> void:
	var texture := _load_texture_or_null(path)
	if texture == null:
		return
	var texture_rect := TextureRect.new()
	texture_rect.name = node_name
	texture_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	texture_rect.texture = texture
	texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_rect.z_index = z_index_value
	add_child(texture_rect)
	move_child(texture_rect, 1)

func _load_texture_or_null(path: String) -> Texture2D:
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	var resource := load(path)
	if resource is Texture2D:
		return resource
	return null

func _play_audio(method_name: String) -> void:
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager and audio_manager.has_method(method_name):
		audio_manager.call(method_name)
