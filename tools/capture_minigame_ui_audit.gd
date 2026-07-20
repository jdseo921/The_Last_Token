extends SceneTree

const SETTLE_FRAMES := 22
const TARGETS := [
	["rockbyte", "res://scenes/minigames/RockbyteDuel.tscn"],
	["broken_score", "res://scenes/minigames/BrokenHighScore.tscn"],
	["truth_filter", "res://scenes/minigames/TruthFilter.tscn"],
	["circuit_soda", "res://scenes/minigames/CircuitSoda.tscn"],
	["security_tape", "res://scenes/minigames/SecurityTapeAssembly.tscn"],
	["memory_echo", "res://scenes/cutscenes/MemoryEcho.tscn"],
	["night_ledger", "res://scenes/minigames/NightLedgerRun.tscn"],
	["maintenance_sync", "res://scenes/arcade/SyncDoorPuzzle.tscn"],
	["snack_service", "res://scenes/minigames/SnackServiceDash.tscn"],
	["prize_echo", "res://scenes/minigames/PrizeShelfRun.tscn"],
	["static_service", "res://scenes/minigames/StaticServiceRun.tscn"],
	["final_night", "res://scenes/minigames/FinalNightWalk.tscn"],
	["template", "res://scenes/minigames/MinigameScreenTemplate.tscn"],
]

var target_index := 0
var active_scene: Node = null
var frame_count := 0
var state_prepared := false

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute("res://tmp/captures/ui_audit")

func _process(_delta: float) -> bool:
	if active_scene == null:
		if target_index >= TARGETS.size():
			print("Minigame UI captures complete: %d" % TARGETS.size())
			return true
		var packed := load(str(TARGETS[target_index][1])) as PackedScene
		if packed == null:
			push_error("Could not load %s" % TARGETS[target_index][1])
			target_index += 1
			return false
		active_scene = packed.instantiate()
		root.add_child(active_scene)
		frame_count = 0
		state_prepared = false
		return false
	frame_count += 1
	if not state_prepared and frame_count >= 3:
		_prepare_runtime_state(str(TARGETS[target_index][0]))
		state_prepared = true
	if frame_count < SETTLE_FRAMES:
		return false
	var image := root.get_texture().get_image()
	var output_path := "res://tmp/captures/ui_audit/%s.png" % str(TARGETS[target_index][0])
	var error := image.save_png(output_path)
	print("%s: %s" % [output_path, "OK" if error == OK else "ERROR %d" % error])
	active_scene.free()
	active_scene = null
	target_index += 1
	return false

func _prepare_runtime_state(key: String) -> void:
	match key:
		"rockbyte":
			active_scene.get_node("StatusPanel/StatusVBox/StatusLabel").text = "Player move recorded.\nCabinet counter-move ready."
		"broken_score":
			active_scene.call("_lose_round")
		"truth_filter":
			active_scene.call("_destabilize")
		"security_tape":
			for index in range(5):
				active_scene.call("_on_fragment_pressed", index)
			var restored_order := [
				"Counter lights shut off.",
				"Cabinet 07 remains powered.",
				"A staff member enters the back hall.",
				"The Staff Door records two signals.",
			]
			var displayed: Array = active_scene.get("display_fragments")
			for fragment_text in restored_order:
				active_scene.call("_on_fragment_pressed", displayed.find(fragment_text))
		"memory_echo":
			active_scene.set_process(false)
		"maintenance_sync":
			active_scene.call("_signal_lost")
		"template":
			active_scene.call("set_status_text", "CENTERED STATUS LINE ONE\nCENTERED STATUS LINE TWO")
			active_scene.call("set_result_text", "CENTERED RESULT LINE ONE\nCENTERED RESULT LINE TWO")
