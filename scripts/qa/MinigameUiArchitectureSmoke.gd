extends SceneTree

const MINIGAME_UI := preload("res://scripts/ui/MinigameUI.gd")
const TEXT_BOX_SCENE := preload("res://scenes/ui/MinigameTextBox.tscn")
const MINIGAME_TEST_CATALOG := preload("res://scripts/qa/MinigameTestCatalog.gd")

const EXCLUDED_BRANCHES := {
	"PauseMenu": true,
	"QuestNotice": true,
	"SettingsMenu": true,
	"DialogueBox": true,
	"ChoiceBox": true,
	"TileGrid": true,
	"ScrollingViewport": true,
}

var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	await _stress_text_box()
	for path in MINIGAME_TEST_CATALOG.LAYOUT_SCENES:
		var packed := load(path) as PackedScene
		_expect(packed != null, "%s loads" % path.get_file())
		if packed == null:
			continue
		var scene: Node = packed.instantiate()
		root.add_child(scene)
		await process_frame
		await process_frame
		var guard: Node = scene.get_node_or_null("MinigameUILayoutGuard")
		_expect(guard != null, "%s installs the shared UI guard" % path.get_file())
		if guard != null:
			guard.call("refresh_now")
		var managed_count := _audit_branch(scene, path.get_file())
		_expect(managed_count > 0, "%s exposes managed UI text" % path.get_file())
		var pause_menu := scene.get_node_or_null("PauseMenu")
		if pause_menu != null:
			_expect(not _branch_has_managed_text(pause_menu), "%s keeps pause UI outside the minigame guard" % path.get_file())
		scene.queue_free()
		await process_frame
	print("MinigameUiArchitectureSmoke: %s" % ("PASS" if failures == 0 else "FAIL (%d)" % failures))
	quit(0 if failures == 0 else 1)


func _stress_text_box() -> void:
	var text_box := TEXT_BOX_SCENE.instantiate() as MinigameTextBox
	text_box.name = "ArchitectureProbe"
	text_box.position = Vector2(20, 20)
	text_box.size = Vector2(420, 104)
	root.add_child(text_box)
	await process_frame
	var cases := [
		"ONE CENTERED LINE",
		"CENTERED LINE ONE\nCENTERED LINE TWO",
		"A longer instruction can wrap naturally while its complete block remains centered inside the same padded panel.",
		"LINE ONE\nLINE TWO\nLINE THREE\nLINE FOUR",
	]
	for value in cases:
		text_box.set_text(value)
		var label := text_box.get_label()
		_expect(label.horizontal_alignment == HORIZONTAL_ALIGNMENT_CENTER, "text box centers '%s' horizontally" % value.left(12))
		_expect(label.vertical_alignment == VERTICAL_ALIGNMENT_CENTER, "text box centers '%s' vertically" % value.left(12))
		_expect(bool(label.get_meta(MINIGAME_UI.META_FIT_OK, false)), "text box fits '%s'" % value.left(12))
	text_box.queue_free()
	await process_frame


func _audit_branch(node: Node, scene_name: String) -> int:
	if node != root and _is_excluded(node):
		return 0
	var managed_count := 0
	if node is Label:
		var label := node as Label
		var managed := bool(label.get_meta(MINIGAME_UI.META_MANAGED, false))
		_expect(managed, "%s manages %s" % [scene_name, str(label.get_path())])
		if managed:
			managed_count += 1
			if label.autowrap_mode != TextServer.AUTOWRAP_OFF or label.text.contains("\n"):
				_expect(label.horizontal_alignment == HORIZONTAL_ALIGNMENT_CENTER, "%s centers wrapped %s horizontally" % [scene_name, str(label.get_path())])
				_expect(label.vertical_alignment == VERTICAL_ALIGNMENT_CENTER, "%s centers wrapped %s vertically" % [scene_name, str(label.get_path())])
			if label.visible and not label.text.strip_edges().is_empty() and label.size.x > 0.0 and label.size.y > 0.0:
				_expect(bool(label.get_meta(MINIGAME_UI.META_FIT_OK, true)), "%s fits %s above its readable floor" % [scene_name, str(label.get_path())])
	for child in node.get_children():
		managed_count += _audit_branch(child, scene_name)
	return managed_count


func _branch_has_managed_text(node: Node) -> bool:
	if node is Label and bool(node.get_meta(MINIGAME_UI.META_MANAGED, false)):
		return true
	for child in node.get_children():
		if _branch_has_managed_text(child):
			return true
	return false


func _is_excluded(node: Node) -> bool:
	if node is Node2D:
		return true
	if EXCLUDED_BRANCHES.has(str(node.name)):
		return true
	return bool(node.get_meta(MINIGAME_UI.META_IGNORE, false))


func _expect(condition: bool, label: String) -> void:
	if condition:
		return
	failures += 1
	push_error("FAIL: %s" % label)
