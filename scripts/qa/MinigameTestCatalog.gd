class_name MinigameTestCatalog
extends RefCounted

## One inventory for minigame-wide QA. Add a new playable screen here once;
## pause coverage, layout coverage and UI architecture coverage all inherit it.

const PLAYABLE_SCENES := [
	"res://scenes/minigames/RockbyteDuel.tscn",
	"res://scenes/minigames/BrokenHighScore.tscn",
	"res://scenes/minigames/TruthFilter.tscn",
	"res://scenes/minigames/CircuitSoda.tscn",
	"res://scenes/minigames/SecurityTapeAssembly.tscn",
	"res://scenes/cutscenes/MemoryEcho.tscn",
	"res://scenes/minigames/StaticServiceRun.tscn",
	"res://scenes/minigames/SnackServiceDash.tscn",
	"res://scenes/minigames/PrizeShelfRun.tscn",
	"res://scenes/minigames/NightLedgerRun.tscn",
	"res://scenes/arcade/SyncDoorPuzzle.tscn",
]

const TEMPLATE_SCENE := "res://scenes/minigames/MinigameScreenTemplate.tscn"
const LAYOUT_SCENES := PLAYABLE_SCENES + [TEMPLATE_SCENE]
