extends Node

const ARCADE_HUB_SCENE := "res://scenes/arcade/ArcadeHub.tscn"
const ROCKBYTE_DUEL_SCENE := "res://scenes/minigames/RockbyteDuel.tscn"
const SYNC_DOOR_PUZZLE_SCENE := "res://scenes/arcade/SyncDoorPuzzle.tscn"
const STAFF_ROOM_SCENE := "res://scenes/arcade/StaffRoom.tscn"
const TITLE_OR_MAIN_SCENE := "res://scenes/main/Main.tscn"

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

func go_to_sync_door_puzzle() -> void:
	change_scene(SYNC_DOOR_PUZZLE_SCENE)

func go_to_staff_room() -> void:
	change_scene(STAFF_ROOM_SCENE)

func go_to_title_or_main() -> void:
	change_scene(TITLE_OR_MAIN_SCENE)
