extends Control

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

@onready var status_label: Label = $Panel/StatusLabel
@onready var selected_label: Label = $Panel/SelectedLabel
@onready var hint_label: Label = $Panel/HintLabel
@onready var submit_button: Button = $Panel/Controls/SubmitButton
@onready var reset_button: Button = $Panel/Controls/ResetButton
@onready var return_button: Button = $Panel/ReturnButton
@onready var fragment_a: Button = $Panel/Fragments/FragmentA
@onready var fragment_b: Button = $Panel/Fragments/FragmentB
@onready var fragment_c: Button = $Panel/Fragments/FragmentC
@onready var fragment_d: Button = $Panel/Fragments/FragmentD

var selected_fragments: Array[String] = []
var fragment_buttons: Array[Button] = []

func _ready() -> void:
	GameState.start_security_tape_assembly()
	fragment_buttons = [fragment_a, fragment_b, fragment_c, fragment_d]
	for index in range(fragment_buttons.size()):
		var button: Button = fragment_buttons[index]
		button.text = FRAGMENTS[index]
		button.pressed.connect(_on_fragment_pressed.bind(index))
	submit_button.pressed.connect(_on_submit_pressed)
	reset_button.pressed.connect(_reset_selection)
	return_button.pressed.connect(_return_to_staff_corridor)
	return_button.visible = false
	_refresh_view()

func _on_fragment_pressed(index: int) -> void:
	if index < 0 or index >= FRAGMENTS.size():
		return
	var fragment := FRAGMENTS[index]
	if selected_fragments.has(fragment):
		return
	selected_fragments.append(fragment)
	_refresh_view()

func _on_submit_pressed() -> void:
	if selected_fragments.size() != FRAGMENTS.size():
		status_label.text = "Select all four fragments before submitting."
		return
	if selected_fragments == CORRECT_ORDER:
		GameState.complete_security_tape_assembly()
		status_label.text = "TAPE ORDER RESTORED.\nFINAL NIGHT SEQUENCE PARTIAL.\nTHE STAFF DOOR DID NOT RECORD A CUSTOMER."
		_set_fragment_buttons_disabled(true)
		submit_button.disabled = true
		reset_button.disabled = true
		return_button.visible = true
		return
	GameState.record_security_tape_wrong_order()
	status_label.text = "TIMESTAMP CONFLICT.\nThe tape rewinds."
	_reset_selection()

func _reset_selection() -> void:
	selected_fragments.clear()
	_refresh_view()

func _refresh_view() -> void:
	var lines := PackedStringArray()
	for index in range(FRAGMENTS.size()):
		var slot_text := "[empty]"
		if index < selected_fragments.size():
			slot_text = selected_fragments[index]
		lines.append("%d. %s" % [index + 1, slot_text])
	selected_label.text = "\n".join(lines)
	for index in range(fragment_buttons.size()):
		var button: Button = fragment_buttons[index]
		button.disabled = selected_fragments.has(FRAGMENTS[index]) or GameState.security_tape_assembly_completed
	hint_label.visible = GameState.security_tape_wrong_order_count >= 2 and not GameState.security_tape_assembly_completed
	submit_button.disabled = GameState.security_tape_assembly_completed
	reset_button.disabled = GameState.security_tape_assembly_completed

func _set_fragment_buttons_disabled(disabled: bool) -> void:
	for button in fragment_buttons:
		button.disabled = disabled

func _return_to_staff_corridor() -> void:
	GameState.set_pending_spawn_id("Spawn_FromSecurityTape")
	SceneChanger.go_to_staff_corridor()
