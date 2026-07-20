extends SceneTree

const SPAWN_CLEARANCE := 56.0
const EXPECTED_EXIT_ANCHORS := {
	"cabinet_hallway": [Vector2(58, 233), Vector2(581, 233)],
	"prize_hallway": [Vector2(73, 227), Vector2(566, 227)],
	"maintenance_hallway": [Vector2(59, 233), Vector2(579, 233)],
	"back_hallway": [Vector2(62, 231), Vector2(576, 231)],
	"cabinet_snack_hallway": [Vector2(61, 298), Vector2(578, 298)],
	"snack_prize_hallway": [Vector2(59, 233), Vector2(579, 232)],
	"maintenance_staff_hallway": [Vector2(77, 233), Vector2(562, 233)],
}
const NORTH_ONLY_EXIT_ANCHOR := Vector2(320, 30)
const NORTH_ONLY_SPAWN_POSITION := Vector2(320, 112)
const HALLWAY_SCENES := {
	"cabinet_hallway": "res://scenes/maps/hallways/CabinetHallway.tscn",
	"snack_hallway": "res://scenes/maps/hallways/SnackHallway.tscn",
	"prize_hallway": "res://scenes/maps/hallways/PrizeHallway.tscn",
	"maintenance_hallway": "res://scenes/maps/hallways/MaintenanceHallway.tscn",
	"back_hallway": "res://scenes/maps/hallways/BackHallway.tscn",
	"cabinet_snack_hallway": "res://scenes/maps/hallways/CabinetSnackHallway.tscn",
	"snack_prize_hallway": "res://scenes/maps/hallways/SnackPrizeHallway.tscn",
	"maintenance_staff_hallway": "res://scenes/maps/hallways/MaintenanceStaffHallway.tscn",
}

var failures := 0
var game_state: Node = null


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	game_state = root.get_node_or_null("GameState")
	_expect(game_state != null, "GameState autoload is available")
	if game_state == null:
		quit(1)
		return
	await _check_exit_alignment()
	_check_story_gates()
	print("HallwayFlowSmoke: %s" % ("PASS" if failures == 0 else "FAIL (%d)" % failures))
	quit(0 if failures == 0 else 1)


func _check_exit_alignment() -> void:
	for hallway_id: String in HALLWAY_SCENES:
		game_state.call("reset_for_new_game")
		var scene_path: String = HALLWAY_SCENES[hallway_id]
		var packed := load(scene_path) as PackedScene
		_expect(packed != null, "%s loads" % scene_path.get_file())
		if packed == null:
			continue
		var hallway := packed.instantiate()
		root.add_child(hallway)
		await process_frame
		_expect(hallway.get_node_or_null("QuestNotice") != null, "%s keeps its quest HUD source" % scene_path.get_file())

		var transitions: Array[Node] = []
		var markers: Array[Node] = []
		for child in hallway.get_children():
			if child is Area2D and child.get("target_scene_path") != null:
				transitions.append(child)
			elif child is Marker2D:
				markers.append(child)
		if hallway_id == "snack_hallway":
			_expect(transitions.size() == 1, "%s has one north exit" % scene_path.get_file())
			if transitions.size() == 1:
				_expect(transitions[0].position.is_equal_approx(NORTH_ONLY_EXIT_ANCHOR), "%s exit sits in the north doorway" % scene_path.get_file())
				_expect(str(transitions[0].get("arrow_direction")) == "up", "%s exit arrow points north" % scene_path.get_file())
			var north_spawn := hallway.get_node_or_null("Spawn_FromSnackAlcove") as Marker2D
			_expect(north_spawn != null and north_spawn.position.is_equal_approx(NORTH_ONLY_SPAWN_POSITION), "%s spawn clears the north trigger" % scene_path.get_file())
			_expect(game_state.call("get_npc_dialogue_count", "hallway_message:%s" % hallway_id) == 0, "%s early visit does not consume its whisper" % scene_path.get_file())
			hallway.queue_free()
			await process_frame
			continue

		transitions.sort_custom(func(a: Node, b: Node): return a.position.x < b.position.x)
		_expect(transitions.size() == 2, "%s has two side exits" % scene_path.get_file())
		var expected_anchors: Array = EXPECTED_EXIT_ANCHORS[hallway_id]
		if transitions.size() == 2:
			_expect(transitions[0].position.is_equal_approx(expected_anchors[0]), "%s left exit sits on its measured wall recess" % scene_path.get_file())
			_expect(transitions[1].position.is_equal_approx(expected_anchors[1]), "%s right exit sits on its measured wall recess" % scene_path.get_file())
		for marker in markers:
			var expected: Vector2
			if marker.position.x < 320.0:
				expected = expected_anchors[0] + Vector2(SPAWN_CLEARANCE, 0.0)
			else:
				expected = expected_anchors[1] - Vector2(SPAWN_CLEARANCE, 0.0)
			_expect(marker.position.is_equal_approx(expected), "%s %s clears its exit trigger" % [scene_path.get_file(), marker.name])
		for transition in transitions:
			var hitbox := transition.get_node_or_null("CollisionShape2D") as CollisionShape2D
			var shape := hitbox.shape as RectangleShape2D if hitbox != null else null
			_expect(shape != null and shape.size.is_equal_approx(Vector2(94, 52)), "%s exit arrow uses the enlarged hitbox" % scene_path.get_file())
		_expect(game_state.call("get_npc_dialogue_count", "hallway_message:%s" % hallway_id) == 0, "%s early visit does not consume its whisper" % scene_path.get_file())

		hallway.queue_free()
		await process_frame


func _check_story_gates() -> void:
	var cabinet_row := (load("res://scenes/maps/CabinetRow.tscn") as PackedScene).instantiate()
	var snack_alcove := (load("res://scenes/maps/SnackAlcove.tscn") as PackedScene).instantiate()
	_expect(str(cabinet_row.get_node("ToSnackAlcove").get("required_flag")) == "gus_hub_checkin_truth_filter_done", "Cabinet Row blocks Service Hall until the Gus catch-up is done")
	_expect(str(snack_alcove.get_node("ToCabinetRow").get("required_flag")) == "gus_hub_checkin_truth_filter_done", "Snack Alcove blocks Service Hall until the Gus catch-up is done")
	cabinet_row.free()
	snack_alcove.free()

	for hallway_id in [
		"cabinet_hallway", "snack_hallway", "prize_hallway", "maintenance_hallway",
		"back_hallway", "cabinet_snack_hallway", "snack_prize_hallway", "maintenance_staff_hallway",
	]:
		game_state.call("reset_for_new_game")
		_expect(_message_lines(hallway_id).is_empty(), "%s stays silent when accessed early" % hallway_id)

	game_state.call("reset_for_new_game")
	game_state.set("lost_token_quest_completed", true)
	_expect(not _message_lines("cabinet_hallway").is_empty(), "Cabinet whisper opens after the Lost Token quest")
	game_state.set("broken_high_score_completed", true)
	_expect(_message_lines("cabinet_hallway").is_empty(), "Cabinet whisper closes after Broken High Score")

	game_state.call("reset_for_new_game")
	game_state.set("lying_cabinets_completed", true)
	game_state.set("mr_byte_truth_filter_debriefed", true)
	game_state.set("gus_hub_checkin_truth_filter_done", true)
	_expect(not _message_lines("snack_hallway").is_empty(), "Snack whisper opens after the Truth Filter check-ins")
	_expect(not _message_lines("cabinet_snack_hallway").is_empty(), "Cabinet-Snack whisper shares the Circuit Soda story window")
	game_state.set("circuit_soda_completed", true)
	_expect(_message_lines("snack_hallway").is_empty(), "Snack whisper closes after Circuit Soda")

	game_state.call("reset_for_new_game")
	game_state.set("circuit_soda_completed", true)
	_expect(_message_lines("prize_hallway").is_empty(), "Prize whisper waits for Vendo's unknown-voice clue")
	_expect(_message_lines("snack_prize_hallway").is_empty(), "Snack-Prize whisper cannot fire before Vendo's clue")
	game_state.set("vendo_unknown_clue_seen", true)
	_expect(not _message_lines("prize_hallway").is_empty(), "Prize whisper opens after Vendo's clue")
	_expect(not _message_lines("snack_prize_hallway").is_empty(), "Snack-Prize whisper shares the clue-gated Prize Echo window")
	game_state.set("prize_sort_completed", true)
	_expect(_message_lines("prize_hallway").is_empty(), "Prize whisper closes after Prize Echo Ascent")

	game_state.set("gus_hub_checkin_prize_sort_done", true)
	_expect(not _message_lines("maintenance_hallway").is_empty(), "Maintenance whisper opens after Gus's records lead")
	game_state.set("static_service_run_completed", true)
	_expect(_message_lines("maintenance_hallway").is_empty(), "Maintenance whisper closes after Static Service")

	game_state.call("reset_for_new_game")
	game_state.set("maintenance_sync_completed", true)
	_expect(not _message_lines("back_hallway").is_empty(), "Back Hall whisper opens after Maintenance Sync")
	_expect(not _message_lines("maintenance_staff_hallway").is_empty(), "Maintenance-Staff whisper opens after Maintenance Sync")
	game_state.set("security_tape_assembly_completed", true)
	_expect(_message_lines("back_hallway").is_empty(), "early Back Hall whisper closes after Security Tape")
	game_state.set("final_night_walk_completed", true)
	_expect(not _message_lines("back_hallway").is_empty(), "late Back Hall whisper opens after Final Night Walk")
	game_state.set("memory_echo_completed", true)
	_expect(_message_lines("back_hallway").is_empty(), "late Back Hall whisper closes after Memory Echo")


func _message_lines(hallway_id: String) -> Array:
	var packed := load(HALLWAY_SCENES.get(hallway_id, "")) as PackedScene
	_expect(packed != null, "%s story-gate scene loads" % hallway_id)
	if packed == null:
		return []
	var hallway := packed.instantiate()
	var lines: Array = hallway.call("_get_hallway_message_lines")
	hallway.free()
	return lines


func _expect(condition: bool, label: String) -> void:
	if condition:
		print("PASS: %s" % label)
		return
	failures += 1
	push_error("FAIL: %s" % label)
