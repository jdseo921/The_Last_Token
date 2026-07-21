extends CanvasLayer

const ENABLE_ARG := "--dev-route-menu"
const ENABLE_ENV := "THE_LAST_TOKEN_DEV_ROUTE_MENU"
const ENABLE_SETTING := "the_last_token/dev_route_menu_enabled"

const CHECKPOINTS := [
	{"id": "new_memory", "label": "New Memory"},
	{"id": "after_lost_token", "label": "After Lost Token"},
	{"id": "after_truth_filter", "label": "After Truth Filter"},
	{"id": "after_circuit_soda", "label": "After Circuit Soda"},
	{"id": "after_closing_shift_echoes", "label": "After Closing Shift Echoes"},
	{"id": "after_static_service_run", "label": "After Static Service Run"},
	{"id": "after_maintenance_sync", "label": "After Maintenance Sync"},
	{"id": "after_security_tape_assembly", "label": "After Security Tape Assembly"},
	{"id": "after_memory_echo", "label": "After Memory Echo"},
	{"id": "post_reveal_roam", "label": "Post-Reveal Roam"},
]

var dev_menu_enabled := false
var menu_root: Control = null
var status_label: Label = null

func _ready() -> void:
	layer = 120
	process_mode = Node.PROCESS_MODE_ALWAYS
	dev_menu_enabled = _should_enable_menu()
	set_process_unhandled_input(dev_menu_enabled)
	if not dev_menu_enabled:
		return
	_build_menu()

func _unhandled_input(event: InputEvent) -> void:
	if not dev_menu_enabled:
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F10:
		_toggle_menu()
		get_viewport().set_input_as_handled()

func _should_enable_menu() -> bool:
	if not OS.has_feature("debug"):
		return false
	if _env_flag_enabled():
		return true
	if OS.get_cmdline_args().has(ENABLE_ARG):
		return true
	if ProjectSettings.has_setting(ENABLE_SETTING):
		return bool(ProjectSettings.get_setting(ENABLE_SETTING))
	return false

func _env_flag_enabled() -> bool:
	var value := OS.get_environment(ENABLE_ENV).strip_edges().to_lower()
	return value == "1" or value == "true" or value == "yes"

func _build_menu() -> void:
	menu_root = Control.new()
	menu_root.name = "DevRouteMenuRoot"
	menu_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	menu_root.visible = false
	add_child(menu_root)

	var dim := ColorRect.new()
	dim.name = "Dim"
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.0, 0.0, 0.0, 0.58)
	menu_root.add_child(dim)

	var panel := Panel.new()
	panel.name = "Panel"
	panel.position = Vector2(154, 34)
	panel.size = Vector2(332, 372)
	panel.add_theme_stylebox_override("panel", _make_panel_style())
	menu_root.add_child(panel)

	var title := Label.new()
	title.position = Vector2(16, 14)
	title.size = Vector2(300, 24)
	title.add_theme_font_size_override("font_size", 16)
	title.text = "DEV ROUTE CHECKPOINTS"
	panel.add_child(title)

	var hint := Label.new()
	hint.position = Vector2(16, 38)
	hint.size = Vector2(300, 34)
	hint.add_theme_font_size_override("font_size", 16)
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.text = "Debug only. Launch with --dev-route-menu or THE_LAST_TOKEN_DEV_ROUTE_MENU=1. Toggle: F10."
	panel.add_child(hint)

	var y := 82.0
	for checkpoint in CHECKPOINTS:
		var button := Button.new()
		button.position = Vector2(18, y)
		button.size = Vector2(296, 24)
		button.text = str(checkpoint.get("label", "Checkpoint"))
		button.pressed.connect(_on_checkpoint_pressed.bind(str(checkpoint.get("id", ""))))
		panel.add_child(button)
		y += 26.0

	status_label = Label.new()
	status_label.position = Vector2(18, 336)
	status_label.size = Vector2(220, 24)
	status_label.add_theme_font_size_override("font_size", 16)
	status_label.text = "Ready."
	panel.add_child(status_label)

	var close_button := Button.new()
	close_button.position = Vector2(250, 334)
	close_button.size = Vector2(64, 26)
	close_button.text = "Close"
	close_button.pressed.connect(_hide_menu)
	panel.add_child(close_button)

func _make_panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.015, 0.018, 0.028, 0.96)
	style.border_color = Color(0.28, 0.92, 1.0, 0.86)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 0
	style.corner_radius_top_right = 0
	style.corner_radius_bottom_left = 0
	style.corner_radius_bottom_right = 0
	return style

func _toggle_menu() -> void:
	if menu_root == null:
		return
	menu_root.visible = not menu_root.visible
	if menu_root.visible:
		var first_button := menu_root.find_child("Button", true, false)
		if first_button is Button:
			first_button.grab_focus()

func _hide_menu() -> void:
	if menu_root != null:
		menu_root.visible = false

func _on_checkpoint_pressed(checkpoint_id: String) -> void:
	if checkpoint_id.is_empty():
		return
	_apply_checkpoint(checkpoint_id)
	_hide_menu()

func _apply_checkpoint(checkpoint_id: String) -> void:
	match checkpoint_id:
		"new_memory":
			_apply_new_memory()
		"after_lost_token":
			_apply_after_lost_token()
			_finish_checkpoint(SceneChanger.CABINET_ROW_SCENE, "Spawn_Default", "After Lost Token")
		"after_truth_filter":
			_apply_after_truth_filter()
			_finish_checkpoint(SceneChanger.SNACK_ALCOVE_SCENE, "Spawn_Default", "After Truth Filter")
		"after_circuit_soda":
			_apply_after_circuit_soda()
			_finish_checkpoint(SceneChanger.ARCADE_HUB_SCENE, "Spawn_Default", "After Circuit Soda")
		"after_closing_shift_echoes":
			_apply_after_closing_shift_echoes()
			_finish_checkpoint(SceneChanger.MAINTENANCE_HALL_SCENE, "Spawn_Default", "After Closing Shift Echoes")
		"after_static_service_run":
			_apply_after_static_service_run()
			_finish_checkpoint(SceneChanger.MAINTENANCE_HALL_SCENE, "Spawn_FromMaintenanceSync", "After Static Service Run")
		"after_maintenance_sync":
			_apply_after_maintenance_sync()
			_finish_checkpoint(SceneChanger.STAFF_CORRIDOR_SCENE, "Spawn_Default", "After Maintenance Sync")
		"after_security_tape_assembly":
			_apply_after_security_tape_assembly()
			_finish_checkpoint(SceneChanger.STAFF_CORRIDOR_SCENE, "Spawn_FromSecurityTape", "After Security Tape Assembly")
		"after_memory_echo":
			_apply_after_memory_echo()
			_finish_checkpoint(SceneChanger.STAFF_CORRIDOR_SCENE, "Spawn_FromMemoryEcho", "After Memory Echo")
		"post_reveal_roam":
			_apply_post_reveal_roam()
			_finish_checkpoint(SceneChanger.ARCADE_HUB_SCENE, "Spawn_Default", "Post-Reveal Roam")

func _apply_new_memory() -> void:
	GameState.reset_for_new_game()
	GameState.clear_arcade_return_position()
	GameState.save_progress_stage = GameState.get_story_phase_label()
	_finish_checkpoint(SceneChanger.ARCADE_HUB_SCENE, "Spawn_Default", "New Memory")

func _apply_started_route() -> void:
	GameState.reset_for_new_game()
	GameState.opening_intro_seen = true
	GameState.start_lost_token_quest()

func _apply_after_lost_token() -> void:
	_apply_started_route()
	GameState.rockbyte_duel_completed = true
	GameState.collect_lost_token()
	GameState.complete_lost_token_quest()

func _apply_after_truth_filter() -> void:
	_apply_after_lost_token()
	GameState.complete_truth_filter()

func _apply_after_circuit_soda() -> void:
	_apply_after_truth_filter()
	GameState.complete_circuit_soda()

func _apply_after_closing_shift_echoes() -> void:
	_apply_after_circuit_soda()
	GameState.mark_conscience_encounter_seen("after_circuit_soda")
	GameState.vendo_unknown_clue_seen = true
	GameState.complete_pip_secret()
	GameState.pip_prize_anecdote_seen = true
	GameState.gus_hub_checkin_prize_sort_done = true
	GameState.start_lost_shift_file()
	GameState.find_closing_shift_mira_clue()
	GameState.find_closing_shift_score_clue()
	GameState.find_closing_shift_service_clue()
	GameState.complete_closing_shift_echoes()

func _apply_after_static_service_run() -> void:
	_apply_after_closing_shift_echoes()
	GameState.complete_static_service_run()

func _apply_after_maintenance_sync() -> void:
	_apply_after_static_service_run()
	GameState.complete_maintenance_sync()

func _apply_after_security_tape_assembly() -> void:
	_apply_after_maintenance_sync()
	GameState.complete_security_tape_assembly()

func _apply_after_memory_echo() -> void:
	_apply_after_security_tape_assembly()
	GameState.complete_memory_echo()

func _apply_post_reveal_roam() -> void:
	_apply_after_memory_echo()
	GameState.mark_twist_reveal_seen()
	GameState.mark_conscience_final_room_seen()
	GameState.ending_seen = true
	GameState.unlock_post_reveal_roam()

func _finish_checkpoint(scene_path: String, spawn_id: String, label: String) -> void:
	GameState.clear_arcade_return_position()
	GameState.save_progress_stage = GameState.get_story_phase_label()
	GameState.set_pending_spawn_id(spawn_id)
	if status_label != null:
		status_label.text = "Jumped: %s" % label
	SceneChanger.change_scene(scene_path)
