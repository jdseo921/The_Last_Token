extends Node

const ARCADE_HUB_SCENE := "res://scenes/arcade/ArcadeHub.tscn"
const ROCKBYTE_DUEL_SCENE := "res://scenes/minigames/RockbyteDuel.tscn"
const TRUTH_FILTER_SCENE := "res://scenes/minigames/TruthFilter.tscn"
const CIRCUIT_SODA_SCENE := "res://scenes/minigames/CircuitSoda.tscn"
const STATIC_SERVICE_RUN_SCENE := "res://scenes/minigames/StaticServiceRun.tscn"
const HUB_TICKET_SWEEP_SCENE := "res://scenes/minigames/HubTicketSweep.tscn"
const CABINET_TRACE_RUN_SCENE := "res://scenes/minigames/CabinetTraceRun.tscn"
const SNACK_SERVICE_DASH_SCENE := "res://scenes/minigames/SnackServiceDash.tscn"
const PRIZE_SHELF_RUN_SCENE := "res://scenes/minigames/PrizeShelfRun.tscn"
const SECURITY_TAPE_ASSEMBLY_SCENE := "res://scenes/minigames/SecurityTapeAssembly.tscn"
const FINAL_NIGHT_WALK_SCENE := "res://scenes/minigames/FinalNightWalk.tscn"
const BROKEN_HIGH_SCORE_SCENE := "res://scenes/minigames/BrokenHighScore.tscn"
const SYNC_DOOR_PUZZLE_SCENE := "res://scenes/arcade/SyncDoorPuzzle.tscn"
const STAFF_ROOM_SCENE := "res://scenes/arcade/StaffRoom.tscn"
const MEMORY_ECHO_SCENE := "res://scenes/cutscenes/MemoryEcho.tscn"
const TITLE_OR_MAIN_SCENE := "res://scenes/main/Main.tscn"
const CABINET_ROW_SCENE := "res://scenes/maps/CabinetRow.tscn"
const SNACK_ALCOVE_SCENE := "res://scenes/maps/SnackAlcove.tscn"
const PRIZE_CORNER_SCENE := "res://scenes/maps/PrizeCorner.tscn"
const MAINTENANCE_HALL_SCENE := "res://scenes/maps/MaintenanceHall.tscn"
const STAFF_CORRIDOR_SCENE := "res://scenes/maps/StaffCorridor.tscn"

const FADE_OUT_SECONDS := 0.22
const FADE_IN_SECONDS := 0.3

var _fade_layer: CanvasLayer = null
var _fade_rect: ColorRect = null
var _transitioning := false

func change_scene(scene_path: String) -> void:
	if scene_path.is_empty():
		push_error("SceneChanger: empty scene path")
		return
	if not ResourceLoader.exists(scene_path):
		push_error("SceneChanger: scene path does not exist: %s" % scene_path)
		return
	var tree := get_tree()
	if tree == null:
		push_error("SceneChanger: SceneTree unavailable")
		return
	if _transitioning:
		return
	_transitioning = true
	_ensure_fade_overlay()
	_fade_rect.visible = true
	var fade_out := create_tween()
	fade_out.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	fade_out.tween_property(_fade_rect, "color:a", 1.0, FADE_OUT_SECONDS)
	await fade_out.finished
	tree.change_scene_to_file(scene_path)
	# A pause opened during the fade would otherwise survive into the new scene
	# with no live pause menu to lift it.
	tree.paused = false
	await tree.process_frame
	var fade_in := create_tween()
	fade_in.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	fade_in.tween_property(_fade_rect, "color:a", 0.0, FADE_IN_SECONDS)
	await fade_in.finished
	_fade_rect.visible = false
	_transitioning = false

func is_transitioning() -> bool:
	return _transitioning

func _ensure_fade_overlay() -> void:
	if _fade_layer != null and is_instance_valid(_fade_layer):
		return
	_fade_layer = CanvasLayer.new()
	_fade_layer.name = "SceneFadeLayer"
	_fade_layer.layer = 120
	add_child(_fade_layer)
	_fade_rect = ColorRect.new()
	_fade_rect.name = "SceneFadeRect"
	_fade_rect.color = Color(0, 0, 0, 0)
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade_rect.visible = false
	_fade_layer.add_child(_fade_rect)

func _capture_return_point() -> void:
	# Called only on the way INTO a minigame, so the stored spot always belongs
	# to the room the player is standing in right now.
	var tree := get_tree()
	if tree == null or tree.current_scene == null:
		return
	var scene := tree.current_scene
	if scene.scene_file_path.is_empty():
		return
	var player := _find_player(scene)
	if player == null:
		return
	GameState.set_return_point(scene.scene_file_path, player.global_position)

func _find_player(node: Node) -> Node2D:
	if node is CharacterBody2D and node.has_method("set_control_enabled"):
		return node as Node2D
	for child in node.get_children():
		var found := _find_player(child)
		if found != null:
			return found
	return null

func go_to_return_point() -> bool:
	# Used by "quit minigame": go back to the room we came from, not the hub.
	if not GameState.has_return_point():
		return false
	change_scene(GameState.get_return_scene_path())
	return true

func go_to_arcade_hub() -> void:
	change_scene(ARCADE_HUB_SCENE)

func go_to_rockbyte_duel() -> void:
	_capture_return_point()
	change_scene(ROCKBYTE_DUEL_SCENE)

func go_to_truth_filter() -> void:
	_capture_return_point()
	change_scene(TRUTH_FILTER_SCENE)

func go_to_circuit_soda() -> void:
	_capture_return_point()
	change_scene(CIRCUIT_SODA_SCENE)

func go_to_static_service_run() -> void:
	_capture_return_point()
	change_scene(STATIC_SERVICE_RUN_SCENE)

func go_to_hub_ticket_sweep() -> void:
	change_scene(HUB_TICKET_SWEEP_SCENE)

func go_to_cabinet_trace_run() -> void:
	_capture_return_point()
	change_scene(CABINET_TRACE_RUN_SCENE)

func go_to_snack_service_dash() -> void:
	_capture_return_point()
	change_scene(SNACK_SERVICE_DASH_SCENE)

func go_to_prize_shelf_run() -> void:
	_capture_return_point()
	change_scene(PRIZE_SHELF_RUN_SCENE)

func go_to_security_tape_assembly() -> void:
	_capture_return_point()
	change_scene(SECURITY_TAPE_ASSEMBLY_SCENE)

func go_to_final_night_walk() -> void:
	_capture_return_point()
	change_scene(FINAL_NIGHT_WALK_SCENE)

func go_to_broken_high_score() -> void:
	_capture_return_point()
	change_scene(BROKEN_HIGH_SCORE_SCENE)

func go_to_sync_door_puzzle() -> void:
	_capture_return_point()
	change_scene(SYNC_DOOR_PUZZLE_SCENE)

func go_to_maintenance_sync() -> void:
	_capture_return_point()
	change_scene(SYNC_DOOR_PUZZLE_SCENE)

func go_to_staff_room() -> void:
	change_scene(STAFF_ROOM_SCENE)

func go_to_memory_echo() -> void:
	_capture_return_point()
	change_scene(MEMORY_ECHO_SCENE)

func go_to_title_or_main() -> void:
	change_scene(TITLE_OR_MAIN_SCENE)

func go_to_cabinet_row() -> void:
	change_scene(CABINET_ROW_SCENE)

func go_to_snack_alcove() -> void:
	change_scene(SNACK_ALCOVE_SCENE)

func go_to_prize_corner() -> void:
	change_scene(PRIZE_CORNER_SCENE)

func go_to_maintenance_hall() -> void:
	change_scene(MAINTENANCE_HALL_SCENE)

func go_to_staff_corridor() -> void:
	change_scene(STAFF_CORRIDOR_SCENE)
