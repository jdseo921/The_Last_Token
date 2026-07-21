extends Control
class_name RouteCue

const BALANCED_TEXT := preload("res://scripts/BalancedText.gd")

const DEFAULT_SIZE := Vector2(340, 48)
const TILE_SIZE := 16
const CLOSE_BUTTON_SIZE := Vector2(22, 22)
const DISMISS_TIP_HOLD_SECONDS := 3.2
const DISMISS_TIP_TEXT := "TIP: Quest info is still available from Esc > Quest."
const PANEL_COLOR := Color(0.015, 0.018, 0.028, 0.9)
const BORDER_COLOR := Color(0.25, 0.9, 1.0, 0.82)
const TEXT_COLOR := Color(0.86, 0.96, 1.0, 1.0)
const LOCAL_COLOR := Color(0.64, 1.0, 0.72, 1.0)

var location_id := ""
var background_panel: Panel = null
var route_label: Label = null
var close_button: Button = null
var dismissed := false
var dismissed_quest_id := ""
var showing_dismiss_tip := false
var dismiss_tip_tween: Tween = null

func setup(new_location_id: String, new_position: Vector2 = Vector2(24, 86), new_width: float = DEFAULT_SIZE.x) -> void:
	location_id = new_location_id
	position = new_position
	size = Vector2(new_width, DEFAULT_SIZE.y)
	custom_minimum_size = size
	dismissed = false
	showing_dismiss_tip = false
	if is_node_ready():
		_apply_layout()
		refresh()

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	z_index = 100
	_build_nodes()
	_apply_layout()
	if not get_tree().node_added.is_connected(_on_tree_node_added):
		get_tree().node_added.connect(_on_tree_node_added)
	_connect_dialogue_boxes()
	call_deferred("_connect_dialogue_boxes")
	refresh()

func _exit_tree() -> void:
	if get_tree() != null and get_tree().node_added.is_connected(_on_tree_node_added):
		get_tree().node_added.disconnect(_on_tree_node_added)

func refresh() -> void:
	var current_quest_id := _get_current_quest_id()
	# Dismissal belongs to the objective that opened the target dialogue. When
	# that conversation advances the story, the next objective gets a fresh cue.
	if dismissed and not dismissed_quest_id.is_empty() and current_quest_id != dismissed_quest_id:
		dismissed = false
		dismissed_quest_id = ""
	if dismissed:
		visible = showing_dismiss_tip
		return
	var hint := get_current_hint(location_id)
	visible = not hint.is_empty()
	if route_label == null:
		return
	route_label.text = BALANCED_TEXT.split_balanced(hint, 50)
	route_label.modulate = LOCAL_COLOR if hint.begins_with("LOCAL") else TEXT_COLOR
	if close_button != null:
		close_button.visible = visible
	_fit_to_text()

func _fit_to_text() -> void:
	if route_label == null or background_panel == null:
		return
	var right_reserve := 34.0 if close_button != null and close_button.visible else 10.0
	var inner_width := maxf(size.x - 10.0 - right_reserve, 80.0)
	var text_height := 16.0
	var font := route_label.get_theme_font("font")
	if font != null:
		var font_size := route_label.get_theme_font_size("font_size")
		text_height = font.get_multiline_string_size(route_label.text, HORIZONTAL_ALIGNMENT_LEFT, inner_width, font_size).y
	var box_height := maxf(text_height + 14.0, 26.0)
	size.y = box_height
	custom_minimum_size = size
	background_panel.size = Vector2(size.x, box_height)
	route_label.position = Vector2(10, 5)
	route_label.size = Vector2(inner_width, box_height - 10.0)
	if close_button != null:
		close_button.position = Vector2(size.x - CLOSE_BUTTON_SIZE.x - 4.0, 3.0)
		close_button.size = CLOSE_BUTTON_SIZE

static func get_current_hint(current_location_id: String) -> String:
	var state := _get_game_state()
	if state == null or not state.has_method("get_current_quest_id"):
		return ""
	var quest_id := str(state.call("get_current_quest_id"))
	match quest_id:
		"opening_look_around":
			return _local_or_route(current_location_id, "arcade_hub", "LOCAL: Look around. Talk to whoever is still here.")
		"opening_talk_to_mira":
			return _local_or_route(current_location_id, "arcade_hub", "LOCAL: Talk to Mira at the ticket counter.")
		"recover_lost_token":
			return _local_or_route(current_location_id, "arcade_hub", "LOCAL: Play Cabinet 07 on the main floor.")
		"return_lost_token":
			return _local_or_route(current_location_id, "arcade_hub", "LOCAL: Return the Lost Token to Mira.")
		"broken_high_score":
			if not bool(state.get("roxy_met")):
				return _local_or_route(current_location_id, "cabinet_row", "LOCAL: Talk to Roxy by the score cabinet.")
			return _local_or_route(current_location_id, "cabinet_row", "LOCAL: Use the BROKEN SCORE cabinet.")
		"vendo_circuit_debrief":
			return _local_or_route(current_location_id, "snack_alcove", "LOCAL: Talk to Vendo after Circuit Soda.")
		"ask_vendo_about_unknown":
			return _local_or_route(current_location_id, "snack_alcove", "LOCAL: Ask Vendo about the unknown voice.")
		"prize_sort":
			if bool(state.get("prize_sort_completed")) and not bool(state.get("pip_prize_anecdote_seen")):
				return _local_or_route(current_location_id, "prize_corner", "LOCAL: Take the Echo Token to Pip.")
			if not bool(state.get("pip_met")):
				if current_location_id == "snack_alcove":
					return "LOCAL: Take the right passage between the two machines."
				return _local_or_route(current_location_id, "prize_corner", "LOCAL: Talk to Pip by the prize counter.")
			return _local_or_route(current_location_id, "prize_corner", "LOCAL: Use the shelf beside Pip.")
		"truth_filter":
			if int(state.call("get_npc_dialogue_count", "mr_byte_tf_explained")) == 0:
				return _local_or_route(current_location_id, "cabinet_row", "LOCAL: Talk to Mr. Byte about the Truth Filter.")
			return _local_or_route(current_location_id, "cabinet_row", "LOCAL: Use the Truth Filter cabinet.")
		"mr_byte_debrief":
			return _local_or_route(current_location_id, "cabinet_row", "LOCAL: Tell Mr. Byte what the Filter found.")
		"gus_checkin_truth_filter":
			return _local_or_route(current_location_id, "arcade_hub", "LOCAL: Talk to Gus on the arcade floor.")
		"circuit_soda":
			if int(state.call("get_npc_dialogue_count", "vendo_circuit_explained")) == 0:
				return _local_or_route(current_location_id, "snack_alcove", "LOCAL: Talk to Vendo about Circuit Soda.")
			return _local_or_route(current_location_id, "snack_alcove", "LOCAL: Use the Circuit Soda machine.")
		"gus_checkin_prize_sort":
			return _local_or_route(current_location_id, "arcade_hub", "LOCAL: Talk to Gus on the arcade floor.")
		"lost_shift_file":
			return _get_lost_shift_hint(current_location_id, state)
		"static_service_run":
			return _local_or_route(current_location_id, "maintenance_hall", "LOCAL: Talk to Gus, then run Static Service.")
		"maintenance_sync":
			return _local_or_route(current_location_id, "maintenance_hall", "LOCAL: Report to Gus in Maintenance Hall.")
		"staff_corridor":
			return _local_or_route(current_location_id, "staff_corridor", "LOCAL: Take the NORTH exit to the Staff Room.")
		"security_tape_assembly":
			return _local_or_route(current_location_id, "staff_room", "LOCAL: Inspect the archive desk for the Security Tape.")
		"enter_staff_room":
			return _local_or_route(current_location_id, "staff_room", "LOCAL: Inspect the restore terminal.")
		"finish_memory":
			return ""
		"talk_to_witnesses":
			return _get_witness_hint(current_location_id, state)
	return ""

func _build_nodes() -> void:
	background_panel = Panel.new()
	background_panel.name = "RouteCuePanel"
	background_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background_panel)

	route_label = Label.new()
	route_label.name = "RouteCueLabel"
	route_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	route_label.add_theme_font_size_override("font_size", 16)
	route_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	route_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	route_label.text = ""
	add_child(route_label)

	close_button = Button.new()
	close_button.name = "CloseButton"
	close_button.text = "X"
	close_button.tooltip_text = "Close navigation"
	close_button.focus_mode = Control.FOCUS_NONE
	close_button.custom_minimum_size = CLOSE_BUTTON_SIZE
	close_button.add_theme_font_size_override("font_size", 14)
	close_button.pressed.connect(_on_close_pressed)
	add_child(close_button)

func _apply_layout() -> void:
	if background_panel == null or route_label == null or close_button == null:
		return
	background_panel.position = Vector2.ZERO
	background_panel.size = size
	background_panel.add_theme_stylebox_override("panel", _make_panel_style())
	route_label.position = Vector2(10, 4)
	route_label.size = Vector2(maxf(size.x - 44, 80.0), maxf(size.y - 8, 20.0))
	close_button.position = Vector2(size.x - CLOSE_BUTTON_SIZE.x - 4.0, 3.0)
	close_button.size = CLOSE_BUTTON_SIZE


func _connect_dialogue_boxes() -> void:
	for dialogue_box in get_tree().get_nodes_in_group("dialogue_boxes"):
		_connect_dialogue_box(dialogue_box)

func _on_tree_node_added(node: Node) -> void:
	call_deferred("_connect_dialogue_box", node)

func _connect_dialogue_box(dialogue_box: Node) -> void:
	if not is_instance_valid(dialogue_box) or not dialogue_box.is_in_group("dialogue_boxes"):
		return
	if not dialogue_box.has_signal("dialogue_started"):
		return
	var callback := Callable(self, "_on_dialogue_started")
	if not dialogue_box.is_connected("dialogue_started", callback):
		dialogue_box.connect("dialogue_started", callback)


func _on_dialogue_started(lines: Array) -> void:
	if showing_dismiss_tip:
		_finish_dismiss_tip()
	if dismissed or route_label == null:
		return
	var displayed_hint := route_label.text.strip_edges()
	if not displayed_hint.begins_with("LOCAL:"):
		return
	if _dialogue_matches_displayed_target(displayed_hint, lines):
		dismiss_for_target_dialogue()


func dismiss_for_target_dialogue() -> void:
	dismissed = true
	dismissed_quest_id = _get_current_quest_id()
	showing_dismiss_tip = false
	if dismiss_tip_tween and dismiss_tip_tween.is_valid():
		dismiss_tip_tween.kill()
	if close_button != null:
		close_button.visible = false
	visible = false


func _on_close_pressed() -> void:
	_play_audio("play_ui_cancel")
	dismissed = true
	dismissed_quest_id = _get_current_quest_id()
	var state := _get_game_state()
	if state != null and not bool(state.get("route_cue_close_tip_seen")):
		state.set("route_cue_close_tip_seen", true)
		_show_dismiss_tip()
		return
	visible = false


func _show_dismiss_tip() -> void:
	showing_dismiss_tip = true
	visible = true
	modulate.a = 1.0
	close_button.visible = false
	route_label.text = DISMISS_TIP_TEXT
	route_label.modulate = TEXT_COLOR
	_fit_to_text()
	if dismiss_tip_tween and dismiss_tip_tween.is_valid():
		dismiss_tip_tween.kill()
	dismiss_tip_tween = create_tween()
	dismiss_tip_tween.tween_interval(DISMISS_TIP_HOLD_SECONDS)
	dismiss_tip_tween.tween_property(self, "modulate:a", 0.0, 0.35)
	dismiss_tip_tween.tween_callback(_finish_dismiss_tip)


func _finish_dismiss_tip() -> void:
	if dismiss_tip_tween and dismiss_tip_tween.is_valid():
		dismiss_tip_tween.kill()
	showing_dismiss_tip = false
	visible = false
	modulate.a = 1.0


static func _dialogue_matches_displayed_target(hint: String, lines: Array) -> bool:
	var lowered_hint := hint.to_lower().replace("\n", " ")
	var expected_speakers: Array[String] = []
	if lowered_hint.contains("archive desk"):
		expected_speakers = ["archive desk"]
	elif lowered_hint.contains("terminal"):
		expected_speakers = ["terminal"]
	elif lowered_hint.contains("cabinet 07"):
		expected_speakers = ["cabinet 07"]
	elif lowered_hint.contains("broken score"):
		expected_speakers = ["broken score", "score cabinet", "roxy"]
	elif lowered_hint.contains("truth filter"):
		expected_speakers = ["truth filter", "mr. byte"]
	elif lowered_hint.contains("circuit soda"):
		expected_speakers = ["circuit soda", "vendo"]
	elif lowered_hint.contains("shelf beside pip"):
		expected_speakers = ["prize shelf", "pip"]
	elif lowered_hint.contains("mr. byte"):
		expected_speakers = ["mr. byte"]
	elif lowered_hint.contains("mira"):
		expected_speakers = ["mira"]
	elif lowered_hint.contains("roxy"):
		expected_speakers = ["roxy"]
	elif lowered_hint.contains("vendo"):
		expected_speakers = ["vendo"]
	elif lowered_hint.contains("pip"):
		expected_speakers = ["pip"]
	elif lowered_hint.contains("gus"):
		expected_speakers = ["gus"]
	elif lowered_hint.contains("whoever is still here"):
		expected_speakers = ["mira", "gus", "roxy", "pip"]
	if expected_speakers.is_empty():
		return false
	for line_value in lines:
		if not line_value is Dictionary:
			continue
		var speaker := str((line_value as Dictionary).get("speaker", "")).to_lower()
		if speaker in expected_speakers:
			return true
	return false


func _play_audio(method_name: String) -> void:
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager and audio_manager.has_method(method_name):
		audio_manager.call(method_name)

static func _make_panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = PANEL_COLOR
	style.border_color = BORDER_COLOR
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 0
	style.corner_radius_top_right = 0
	style.corner_radius_bottom_left = 0
	style.corner_radius_bottom_right = 0
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	return style

static func _get_lost_shift_hint(current_location_id: String, state: Node) -> String:
	if not bool(state.get("closing_shift_mira_clue_found")):
		return _local_or_route(current_location_id, "arcade_hub", "LOCAL: Ask Mira about the closing shift.")
	if not bool(state.get("closing_shift_score_clue_found")):
		return _local_or_route(current_location_id, "cabinet_row", "LOCAL: Inspect BROKEN SCORE.")
	if not bool(state.get("closing_shift_service_clue_found")):
		return _local_or_route(current_location_id, "snack_alcove", "LOCAL: Inspect SERVICE DASH.")
	return _local_or_route(current_location_id, "arcade_hub", "LOCAL: Report the echoes to Gus.")

static func _get_witness_hint(current_location_id: String, state: Node) -> String:
	if not bool(state.get("witness_mira_heard")):
		return _local_or_route(current_location_id, "arcade_hub", "LOCAL: Talk to Mira.")
	if not bool(state.get("witness_cabinet07_heard")):
		return _local_or_route(current_location_id, "arcade_hub", "LOCAL: Check Cabinet 07.")
	if not bool(state.get("witness_mr_byte_heard")):
		return _local_or_route(current_location_id, "cabinet_row", "LOCAL: Talk to Mr. Byte.")
	if bool(state.get("roxy_met")) and not bool(state.get("witness_roxy_heard")):
		return _local_or_route(current_location_id, "cabinet_row", "LOCAL: Talk to Roxy.")
	if not bool(state.get("witness_vendo_heard")):
		return _local_or_route(current_location_id, "snack_alcove", "LOCAL: Talk to Vendo.")
	if bool(state.get("pip_met")) and not bool(state.get("witness_pip_heard")):
		return _local_or_route(current_location_id, "prize_corner", "LOCAL: Talk to Pip.")
	if not bool(state.get("witness_gus_heard")):
		return _local_or_route(current_location_id, "maintenance_hall", "LOCAL: Talk to Gus.")
	return "LOCAL: Witness route complete."

static func _local_or_route(current_location_id: String, target_location_id: String, local_text: String) -> String:
	if current_location_id == target_location_id:
		return local_text
	return "ROUTE: %s" % _get_next_step(current_location_id, target_location_id)

static func _get_next_step(current_location_id: String, target_location_id: String) -> String:
	match current_location_id:
		"arcade_hub":
			# The hub has exactly three doors: CABINET ROW (right),
			# MAINTENANCE (bottom) and FRONT ENTRANCE (left). Everything else
			# is reached through one of those, so name the door and its side.
			match target_location_id:
				"cabinet_row":
					return "Take the CABINET HALLWAY exit on the right."
				"snack_alcove":
					return "Right to CABINET ROW, then the SERVICE HALLWAY."
				"prize_corner":
					return "Right to CABINET ROW, SNACK ALCOVE, then the PRIZE SERVICE HALL."
				"maintenance_hall":
					return "Take the MAINTENANCE HALLWAY exit at the bottom."
				"staff_corridor", "staff_room":
					return "Bottom to MAINTENANCE, then STAFF ACCESS HALL."
				"front_entrance":
					return "Take the FRONT ENTRANCE exit on the left."
			return "Use %s exit." % _get_target_label(target_location_id)
		"cabinet_row":
			if target_location_id == "snack_alcove":
				return "Use the SERVICE HALLWAY on the right."
			if target_location_id == "arcade_hub":
				return "Take the CABINET HALLWAY at the bottom."
			return "Back to ARCADE HUB, then %s." % _get_target_label(target_location_id)
		"snack_alcove":
			if target_location_id == "cabinet_row":
				return "Take the SERVICE HALLWAY at the left end."
			if target_location_id == "prize_corner":
				return "Take the PRIZE SERVICE HALL at the right end."
			if target_location_id == "arcade_hub":
				return "Left to CABINET ROW, then take CABINET HALLWAY to ARCADE HUB."
			return "Back to ARCADE HUB, then %s." % _get_target_label(target_location_id)
		"prize_corner":
			if target_location_id == "snack_alcove":
				return "Take the PRIZE SERVICE HALL on the left."
			if target_location_id == "arcade_hub":
				return "Take the PRIZE HALLWAY at the bottom."
			return "Back to ARCADE HUB, then %s." % _get_target_label(target_location_id)
		"maintenance_hall":
			if target_location_id == "staff_corridor":
				return "Take the STAFF ACCESS HALL on the right."
			if target_location_id == "staff_room":
				return "Take the STAFF ACCESS HALL on the right."
			if target_location_id == "arcade_hub":
				return "Take the MAINTENANCE HALLWAY at the bottom."
			return "Back to ARCADE HUB, then %s." % _get_target_label(target_location_id)
		"staff_corridor":
			if target_location_id == "staff_room":
				return "Take the NORTH exit to STAFF ROOM."
			if target_location_id == "maintenance_hall":
				return "Take the STAFF ACCESS HALL at the bottom."
			if target_location_id == "arcade_hub":
				return "Take the BACK HALLWAY on the left."
			return "Back to ARCADE HUB, then %s." % _get_target_label(target_location_id)
		"cabinet_hallway":
			return "Take CABINET ROW exit." if target_location_id == "cabinet_row" else "Take ARCADE HUB exit."
		"snack_hallway":
			return "Take the NORTH EXIT back to SNACK ALCOVE."
		"maintenance_hallway":
			return "Take MAINTENANCE exit." if target_location_id == "maintenance_hall" else "Take ARCADE HUB exit."
		"prize_hallway":
			return "Take PRIZE CORNER exit." if target_location_id == "prize_corner" else "Take ARCADE HUB exit."
		"back_hallway":
			return "Take STAFF CORRIDOR exit." if target_location_id == "staff_corridor" or target_location_id == "staff_room" else "Take ARCADE HUB exit."
		"cabinet_snack_hallway":
			return "Take SNACK ALCOVE exit." if target_location_id == "snack_alcove" else "Take CABINET ROW exit."
		"snack_prize_hallway":
			return "Take PRIZE CORNER exit." if target_location_id == "prize_corner" else "Take SNACK ALCOVE exit."
		"maintenance_staff_hallway":
			return "Take STAFF CORRIDOR exit." if target_location_id == "staff_corridor" or target_location_id == "staff_room" else "Take MAINTENANCE exit."
		"front_entrance":
			if target_location_id == "arcade_hub":
				return "Take the ARCADE HUB exit at the top."
			return "Take the ARCADE HUB exit at the top, then %s." % _get_target_label(target_location_id)
		"party_room":
			if target_location_id == "front_entrance":
				return "Take the FRONT ENTRANCE exit on the left."
			return "Take the FRONT ENTRANCE exit on the left, then ARCADE HUB."
		"restrooms":
			if target_location_id == "party_room":
				return "Take the PARTY ROOM exit on the left."
			return "Take the PARTY ROOM exit on the left, then FRONT ENTRANCE."
		"staff_room":
			return "Take the STAFF CORRIDOR exit at the bottom, then %s." % _get_target_label(target_location_id)
	return "Follow signs to %s." % _get_target_label(target_location_id)

static func _get_target_label(target_location_id: String) -> String:
	match target_location_id:
		"arcade_hub":
			return "ARCADE HUB"
		"cabinet_row":
			return "CABINET ROW"
		"snack_alcove":
			return "SNACK ALCOVE"
		"prize_corner":
			return "PRIZE CORNER"
		"maintenance_hall":
			return "MAINTENANCE"
		"staff_corridor":
			return "STAFF CORRIDOR"
		"staff_room":
			return "STAFF ROOM"
	return target_location_id.to_upper()

static func _get_game_state() -> Node:
	var main_loop := Engine.get_main_loop()
	if main_loop is SceneTree:
		return (main_loop as SceneTree).root.get_node_or_null("GameState")
	return null


static func _get_current_quest_id() -> String:
	var state := _get_game_state()
	if state == null or not state.has_method("get_current_quest_id"):
		return ""
	return str(state.call("get_current_quest_id"))
