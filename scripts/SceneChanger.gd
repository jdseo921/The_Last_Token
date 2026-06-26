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
	tree.change_scene_to_file(scene_path)

func go_to_arcade_hub() -> void:
	change_scene(ARCADE_HUB_SCENE)

func go_to_rockbyte_duel() -> void:
	change_scene(ROCKBYTE_DUEL_SCENE)

func go_to_truth_filter() -> void:
	change_scene(TRUTH_FILTER_SCENE)

func go_to_circuit_soda() -> void:
	change_scene(CIRCUIT_SODA_SCENE)

func go_to_static_service_run() -> void:
	change_scene(STATIC_SERVICE_RUN_SCENE)

func go_to_hub_ticket_sweep() -> void:
	change_scene(HUB_TICKET_SWEEP_SCENE)

func go_to_cabinet_trace_run() -> void:
	change_scene(CABINET_TRACE_RUN_SCENE)

func go_to_snack_service_dash() -> void:
	change_scene(SNACK_SERVICE_DASH_SCENE)

func go_to_prize_shelf_run() -> void:
	change_scene(PRIZE_SHELF_RUN_SCENE)

func go_to_security_tape_assembly() -> void:
	change_scene(SECURITY_TAPE_ASSEMBLY_SCENE)

func go_to_final_night_walk() -> void:
	change_scene(FINAL_NIGHT_WALK_SCENE)

func go_to_broken_high_score() -> void:
	change_scene(BROKEN_HIGH_SCORE_SCENE)

func go_to_sync_door_puzzle() -> void:
	change_scene(SYNC_DOOR_PUZZLE_SCENE)

func go_to_maintenance_sync() -> void:
	change_scene(SYNC_DOOR_PUZZLE_SCENE)

func go_to_staff_room() -> void:
	change_scene(STAFF_ROOM_SCENE)

func go_to_memory_echo() -> void:
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
