extends Control
class_name RouteCue

const DEFAULT_SIZE := Vector2(340, 48)
const TILE_SIZE := 16
const PANEL_COLOR := Color(0.015, 0.018, 0.028, 0.9)
const BORDER_COLOR := Color(0.25, 0.9, 1.0, 0.82)
const TEXT_COLOR := Color(0.86, 0.96, 1.0, 1.0)
const LOCAL_COLOR := Color(0.64, 1.0, 0.72, 1.0)

var location_id := ""
var background_panel: Panel = null
var route_label: Label = null

func setup(new_location_id: String, new_position: Vector2 = Vector2(24, 86), new_width: float = DEFAULT_SIZE.x) -> void:
	location_id = new_location_id
	position = new_position
	size = Vector2(new_width, DEFAULT_SIZE.y)
	custom_minimum_size = size
	if is_node_ready():
		_apply_layout()
		refresh()

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 100
	_build_nodes()
	_apply_layout()
	refresh()

func refresh() -> void:
	var hint := get_current_hint(location_id)
	visible = not hint.is_empty()
	if route_label == null:
		return
	route_label.text = hint
	route_label.modulate = LOCAL_COLOR if hint.begins_with("LOCAL") else TEXT_COLOR
	_fit_to_text()

func _fit_to_text() -> void:
	if route_label == null or background_panel == null:
		return
	var inner_width := maxf(size.x - 20.0, 80.0)
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
		"prize_sort":
			if not bool(state.get("pip_met")):
				return _local_or_route(current_location_id, "prize_corner", "LOCAL: Talk to Pip by the prize counter.")
			return _local_or_route(current_location_id, "prize_corner", "LOCAL: Use the PRIZE COUNTER.")
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
			return _local_or_route(current_location_id, "maintenance_hall", "LOCAL: Use Maintenance Sync by Gus.")
		"staff_corridor":
			return _local_or_route(current_location_id, "staff_corridor", "LOCAL: Follow the Staff Door signal deeper.")
		"security_tape_assembly":
			return _local_or_route(current_location_id, "staff_corridor", "LOCAL: Restore the Security Tape.")
		"final_night_walk":
			return _local_or_route(current_location_id, "staff_corridor", "LOCAL: Walk the Final Night route.")
		"stabilize_memory_echo":
			return _local_or_route(current_location_id, "staff_corridor", "LOCAL: Stabilize the Memory Echo.")
		"enter_staff_room":
			return _local_or_route(current_location_id, "staff_corridor", "LOCAL: Enter the Staff Room.")
		"finish_memory":
			return _local_or_route(current_location_id, "staff_room", "LOCAL: Let the memory finish.")
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

func _apply_layout() -> void:
	if background_panel == null or route_label == null:
		return
	background_panel.position = Vector2.ZERO
	background_panel.size = size
	background_panel.add_theme_stylebox_override("panel", _make_panel_style())
	route_label.position = Vector2(10, 4)
	route_label.size = Vector2(maxf(size.x - 20, 80.0), maxf(size.y - 8, 20.0))

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
	if not bool(state.get("closing_checklist_read")):
		return _local_or_route(current_location_id, "arcade_hub", "LOCAL: Read the Closing Checklist near the counter.")
	if not bool(state.get("staff_schedule_read")):
		return _local_or_route(current_location_id, "cabinet_row", "LOCAL: Read the Staff Schedule by Mr. Byte.")
	if not bool(state.get("maintenance_note_read")):
		return _local_or_route(current_location_id, "maintenance_hall", "LOCAL: Read Gus's Maintenance Note.")
	return _local_or_route(current_location_id, "maintenance_hall", "LOCAL: Tell Gus the Lost Shift File is complete.")

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
				return "Take the SNACK HALLWAY at the bottom."
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
				return "Use STAFF ROOM door."
			if target_location_id == "maintenance_hall":
				return "Take the STAFF ACCESS HALL at the bottom."
			if target_location_id == "arcade_hub":
				return "Take the BACK HALLWAY on the left."
			return "Back to ARCADE HUB, then %s." % _get_target_label(target_location_id)
		"cabinet_hallway":
			return "Take CABINET ROW exit." if target_location_id == "cabinet_row" else "Take ARCADE HUB exit."
		"snack_hallway":
			return "Take SNACK ALCOVE exit." if target_location_id == "snack_alcove" else "Take ARCADE HUB exit."
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
