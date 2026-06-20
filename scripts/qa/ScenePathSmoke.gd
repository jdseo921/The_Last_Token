extends SceneTree

const REQUIRED_SCENES := [
	"res://scenes/main/Main.tscn",
	"res://scenes/arcade/ArcadeHub.tscn",
	"res://scenes/maps/CabinetRow.tscn",
	"res://scenes/maps/SnackAlcove.tscn",
	"res://scenes/maps/MaintenanceHall.tscn",
	"res://scenes/maps/StaffCorridor.tscn",
	"res://scenes/arcade/StaffRoom.tscn",
	"res://scenes/minigames/RockbyteDuel.tscn",
	"res://scenes/minigames/TruthFilter.tscn",
	"res://scenes/minigames/CircuitSoda.tscn",
	"res://scenes/minigames/StaticServiceRun.tscn",
	"res://scenes/arcade/SyncDoorPuzzle.tscn",
	"res://scenes/minigames/SecurityTapeAssembly.tscn",
	"res://scenes/minigames/FinalNightWalk.tscn",
	"res://scenes/cutscenes/MemoryEcho.tscn",
	"res://scenes/cutscenes/SlideshowCutscene.tscn",
	"res://scenes/cutscenes/EndingPrompt.tscn",
]

func _init() -> void:
	var missing_count := 0
	print("ScenePathSmoke: checking required route scenes")
	for scene_path in REQUIRED_SCENES:
		if ResourceLoader.exists(scene_path):
			print("OK  %s" % scene_path)
		else:
			missing_count += 1
			push_error("MISSING  %s" % scene_path)
	if missing_count == 0:
		print("ScenePathSmoke: PASS")
		quit(0)
		return
	print("ScenePathSmoke: FAIL missing=%d" % missing_count)
	quit(1)
