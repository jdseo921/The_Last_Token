extends SceneTree

const MINIGAME_TEST_CATALOG := preload("res://scripts/qa/MinigameTestCatalog.gd")

var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	for path in MINIGAME_TEST_CATALOG.PLAYABLE_SCENES:
		var packed := load(path) as PackedScene
		_expect(packed != null, "%s loads" % path.get_file())
		if packed == null:
			continue
		var scene := packed.instantiate()
		root.add_child(scene)
		await process_frame
		var pause_menu := scene.get_node_or_null("PauseMenu")
		_expect(pause_menu != null, "%s exposes Esc pause" % path.get_file())
		if pause_menu != null:
			_expect(bool(pause_menu.get("is_minigame_context")), "%s uses minigame pause controls" % path.get_file())
		scene.queue_free()
		await process_frame
	print("MinigamePauseCoverageSmoke: %s" % ("PASS" if failures == 0 else "FAIL (%d)" % failures))
	quit(0 if failures == 0 else 1)


func _expect(condition: bool, label: String) -> void:
	if condition:
		print("PASS: %s" % label)
		return
	failures += 1
	push_error("FAIL: %s" % label)
