extends SceneTree
# Headless project validator. Run with:
#   godot --headless --script res://tools/validate_project.gd --path <project>
# Parse-checks every GDScript, load-checks every scene, validates dialogue JSON,
# and unit-tests ArcadeScreen background injection against both scene shapes.
# Dev-only tool; not referenced by any game scene.

func _initialize() -> void:
	var errors: Array = []

	var scripts := _find_files("res://", ".gd")
	for path in scripts:
		if path.ends_with("tools/validate_project.gd"):
			continue
		var res = ResourceLoader.load(path)
		if res == null:
			errors.append("SCRIPT LOAD/PARSE FAILED: " + path)

	var scenes := _find_files("res://", ".tscn")
	for path in scenes:
		var res = ResourceLoader.load(path)
		if res == null:
			errors.append("SCENE LOAD FAILED: " + path)

	var jsons := _find_files("res://data", ".json")
	for path in jsons:
		var f = FileAccess.open(path, FileAccess.READ)
		if f == null:
			errors.append("JSON OPEN FAILED: " + path)
			continue
		var txt = f.get_as_text()
		f.close()
		var j = JSON.new()
		if j.parse(txt) != OK:
			errors.append("JSON PARSE FAILED: %s (line %d: %s)" % [path, j.get_error_line(), j.get_error_message()])

	_test_arcade_screen(errors)

	print("\n=== VALIDATION RESULTS ===")
	print("Scripts: %d | Scenes: %d | JSON: %d" % [scripts.size(), scenes.size(), jsons.size()])
	if errors.is_empty():
		print("RESULT: NO ERRORS")
	else:
		print("RESULT: %d ERROR(S):" % errors.size())
		for e in errors:
			print("  - " + e)
	print("=== END VALIDATION ===")
	quit()

func _test_arcade_screen(errors: Array) -> void:
	# Shape A: plain "Background" ColorRect child (CircuitSoda/SyncDoor/SecurityTape/MemoryEcho)
	var host_a := Control.new()
	var bgc := ColorRect.new()
	bgc.name = "Background"
	host_a.add_child(bgc)
	ArcadeScreen.apply(host_a, "res://assets/art/minigames/truth_filter/backgrounds/truth_filter_screen.svg")
	if not host_a.has_node("ArcadeBackground"):
		errors.append("ArcadeScreen: ArcadeBackground not injected (plain Background shape)")
	if bgc.visible:
		errors.append("ArcadeScreen: opaque Background not hidden (plain shape)")
	if not host_a.has_node("ArcadeScanlines"):
		errors.append("ArcadeScreen: scanlines not added (plain shape)")
	host_a.free()

	# Shape B: BackgroundLayer(CanvasLayer)/BackgroundPlaceholder (TruthFilter/Rockbyte)
	var host_b := Control.new()
	var layer := CanvasLayer.new()
	layer.name = "BackgroundLayer"
	var ph := ColorRect.new()
	ph.name = "BackgroundPlaceholder"
	layer.add_child(ph)
	host_b.add_child(layer)
	ArcadeScreen.apply(host_b, "res://assets/art/minigames/sync_door/backgrounds/sync_door_screen.svg")
	if not layer.has_node("ArcadeBackground"):
		errors.append("ArcadeScreen: ArcadeBackground not injected into BackgroundLayer")
	if ph.visible:
		errors.append("ArcadeScreen: BackgroundPlaceholder not hidden (layer shape)")
	host_b.free()

func _find_files(root: String, ext: String) -> Array:
	var out: Array = []
	var dirs: Array = [root]
	while not dirs.is_empty():
		var d = dirs.pop_back()
		var da = DirAccess.open(d)
		if da == null:
			continue
		da.list_dir_begin()
		var name = da.get_next()
		while name != "":
			if da.current_is_dir():
				if not name.begins_with("."):
					dirs.append(d.path_join(name))
			elif name.ends_with(ext):
				out.append(d.path_join(name))
			name = da.get_next()
		da.list_dir_end()
	return out
