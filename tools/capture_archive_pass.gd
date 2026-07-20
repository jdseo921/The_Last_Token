extends SceneTree

var targets := [
	{"name": "snack_archive_single_npc", "path": "res://scenes/maps/hallways/SnackHallway.tscn", "seconds": 0.45},
	{"name": "night_ledger_scroll_start", "path": "res://scenes/minigames/NightLedgerRun.tscn", "seconds": 0.55},
	{"name": "night_ledger_scroll_sublayer", "path": "res://scenes/minigames/NightLedgerRun.tscn", "seconds": 0.55, "sublayer": true},
	{"name": "night_ledger_scroll_reward", "path": "res://scenes/minigames/NightLedgerRun.tscn", "seconds": 0.55, "complete": true},
]

var target_index := 0
var instance: Node = null
var elapsed := 0.0
var state_prepared := false


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute("res://tmp/captures")
	var game_state := root.get_node_or_null("GameState")
	if game_state:
		game_state.call("reset_for_new_game")
		game_state.set("circuit_soda_completed", true)
		game_state.call("complete_pip_secret")


func _process(delta: float) -> bool:
	if instance == null:
		if target_index >= targets.size():
			return true
		var packed := load(str(targets[target_index]["path"]))
		if packed == null:
			push_error("Could not load %s" % targets[target_index]["path"])
			return true
		instance = packed.instantiate()
		root.add_child(instance)
		elapsed = 0.0
		state_prepared = false
		return false
	elapsed += delta
	if not state_prepared and elapsed >= 0.12:
		if bool(targets[target_index].get("sublayer", false)):
			var explorer := instance.get_node_or_null("AdventureView/WorldViewport/HybridWorld/Explorer") as CharacterBody2D
			if explorer != null:
				explorer.respawn_at(Vector2(1680, 990))
				var camera := explorer.get_node_or_null("Camera2D") as Camera2D
				if camera != null:
					camera.reset_smoothing()
		if bool(targets[target_index].get("complete", false)):
			instance.call("_complete_run")
		state_prepared = true
	if elapsed < float(targets[target_index]["seconds"]):
		return false
	var output_path := "res://tmp/captures/%s.png" % targets[target_index]["name"]
	var viewport_texture := root.get_texture()
	if viewport_texture == null:
		push_error("Archive capture requires a rendering display.")
		return true
	var image := viewport_texture.get_image()
	if image == null:
		push_error("Archive capture could not read the viewport image.")
		return true
	image.save_png(output_path)
	print("saved %s" % output_path)
	instance.free()
	instance = null
	target_index += 1
	return false
