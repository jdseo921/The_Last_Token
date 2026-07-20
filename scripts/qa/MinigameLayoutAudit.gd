
extends SceneTree

const MINIGAME_TEST_CATALOG := preload("res://scripts/qa/MinigameTestCatalog.gd")

var failures := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	for path in MINIGAME_TEST_CATALOG.LAYOUT_SCENES:
		var game_state := root.get_node_or_null("GameState")
		if game_state != null and game_state.has_method("reset_for_new_game"):
			game_state.call("reset_for_new_game")
		var packed := load(path) as PackedScene
		_expect(packed != null, "%s loads" % path.get_file())
		if packed == null:
			continue
		var scene := packed.instantiate()
		root.add_child(scene)
		await process_frame
		_audit_node(scene, path.get_file())
		_audit_alternate_states(scene, path.get_file())
		_audit_multiline_capacity(scene, path.get_file())
		scene.queue_free()
		await process_frame
	print("MinigameLayoutAudit: %s" % ("PASS" if failures == 0 else "FAIL (%d)" % failures))
	quit(0 if failures == 0 else 1)

func _audit_node(node: Node, scene_name: String) -> void:
	var layout_guard := node.get_node_or_null("MinigameUILayoutGuard")
	if layout_guard != null and layout_guard.has_method("refresh_now"):
		layout_guard.call("refresh_now")
	if node is Label or node is Button or node is RichTextLabel:
		var control := node as Control
		if control.is_visible_in_tree() and not _is_exempt(control):
			var parent_control := control.get_parent() as Control
			if parent_control != null and parent_control.size.x > 0.0 and parent_control.size.y > 0.0:
				var rect := control.get_rect()
				var tolerance := 1.5
				var contained := (
					rect.position.x >= -tolerance
					and rect.position.y >= -tolerance
					and rect.end.x <= parent_control.size.x + tolerance
					and rect.end.y <= parent_control.size.y + tolerance
				)
				_expect(contained, "%s: %s stays inside %s" % [scene_name, str(control.get_path()), parent_control.name])
			var font := control.get_theme_font("font")
			if font != null:
				_expect(not font.resource_path.ends_with("m3x6.ttf"), "%s: %s uses readable body font" % [scene_name, str(control.get_path())])
			_audit_text_fit(control, scene_name)
	for child in node.get_children():
		_audit_node(child, scene_name)

func _is_exempt(control: Control) -> bool:
	if control.get_parent() is Node2D:
		return true
	if control.top_level:
		return true
	return false

func _audit_text_fit(control: Control, scene_name: String) -> void:
	if control is Button:
		var button := control as Button
		if button.text.strip_edges().is_empty():
			return
		var button_font := button.get_theme_font("font")
		var button_size := button.get_theme_font_size("font_size")
		var button_text_size := button_font.get_string_size(button.text, HORIZONTAL_ALIGNMENT_LEFT, -1, button_size)
		_expect(button_text_size.x <= button.size.x - 12.0, "%s: %s button text fits horizontally (%.1f <= %.1f)" % [scene_name, str(button.get_path()), button_text_size.x, button.size.x - 12.0])
		return
	if not control is Label:
		return
	var label := control as Label
	if label.text.strip_edges().is_empty():
		return
	var multiline_capable := label.autowrap_mode != TextServer.AUTOWRAP_OFF or label.text.contains("\n")
	if multiline_capable:
		_expect(label.horizontal_alignment == HORIZONTAL_ALIGNMENT_CENTER, "%s: %s wrapped text is horizontally centered" % [scene_name, str(label.get_path())])
		_expect(label.vertical_alignment == VERTICAL_ALIGNMENT_CENTER, "%s: %s wrapped text is vertically centered" % [scene_name, str(label.get_path())])
	var font := label.get_theme_font("font")
	var font_size := label.get_theme_font_size("font_size")
	var wrap_width := -1.0
	if label.autowrap_mode != TextServer.AUTOWRAP_OFF:
		wrap_width = label.size.x
	var measured := font.get_multiline_string_size(label.text, label.horizontal_alignment, wrap_width, font_size)
	_expect(measured.y <= label.size.y + 3.0, "%s: %s text fits vertically (%.1f <= %.1f)" % [scene_name, str(label.get_path()), measured.y, label.size.y])
	if label.autowrap_mode == TextServer.AUTOWRAP_OFF and not label.clip_text:
		_expect(measured.x <= label.size.x + 3.0, "%s: %s text fits horizontally (%.1f <= %.1f)" % [scene_name, str(label.get_path()), measured.x, label.size.x])

func _audit_alternate_states(scene: Node, scene_name: String) -> void:
	match scene_name:
		"TruthFilter.tscn":
			scene.set_process(false)
			for round_index in range(5):
				scene.set("current_round", round_index)
				scene.call("_show_round")
				_audit_node(scene, "%s round %d" % [scene_name, round_index + 1])
			scene.call("_complete_puzzle")
			_audit_node(scene, "%s complete" % scene_name)
		"BrokenHighScore.tscn":
			scene.set_process(false)
			scene.call("_lose_round")
			_audit_node(scene, "%s loss" % scene_name)
			scene.call("_complete_game")
			_audit_node(scene, "%s complete" % scene_name)
		"RockbyteDuel.tscn":
			scene.set_process(false)
			scene.call("_finish_duel", true)
			_audit_node(scene, "%s complete" % scene_name)
		"CircuitSoda.tscn":
			scene.set_process(false)
			for round_index in range(4):
				scene.call("_start_round", round_index)
				scene.call("_show_hint")
				_audit_node(scene, "%s round %d hint" % [scene_name, round_index + 1])
			scene.call("_complete_puzzle")
			_audit_node(scene, "%s complete" % scene_name)
		"SyncDoorPuzzle.tscn":
			scene.set_process(false)
			for phase in range(3):
				scene.call("_start_phase", phase)
				_audit_node(scene, "%s phase %d" % [scene_name, phase + 1])
			scene.call("_signal_lost")
			_audit_node(scene, "%s signal lost" % scene_name)
			scene.call("_complete_puzzle")
			_audit_node(scene, "%s complete" % scene_name)
		"SecurityTapeAssembly.tscn":
			for fragment_index in range(5):
				scene.call("_on_fragment_pressed", fragment_index)
			_audit_node(scene, "%s revealed fragments" % scene_name)
			var security_status := scene.get_node("Panel/StatusLabel") as Label
			var security_messages := [
				"COILY: Ooh, home movies! Clear the static, then\nput the night back in order. One frame will not fit.\nTrust the feeling when you find it.",
				"FRAME REJECTED: NO TIMESTAMP.\nThat frame does not belong to any hour of that night.\nCOILY: ...I greeted everyone, pal. That one, I never greeted.",
				"TAPE ORDER RESTORED.\nTHE STAFF DOOR DID NOT RECORD A CUSTOMER.\nOne frame stays on the reel. It has no hour to return to.",
			]
			for index in range(security_messages.size()):
				security_status.text = security_messages[index]
				_audit_node(scene, "%s message %d" % [scene_name, index + 1])
			var selected := scene.get_node("Panel/SelectedLabel") as Label
			selected.text = "RESTORED ORDER\n1. Counter lights shut off.\n2. Cabinet 07 remains powered.\n3. A staff member enters the back hall.\n4. The Staff Door records two signals."
			_audit_node(scene, "%s restored order" % scene_name)
		"MemoryEcho.tscn":
			scene.set_process(false)
			for question_index in range(3):
				scene.set("current_question_index", question_index)
				scene.call("_show_question")
				_audit_node(scene, "%s question %d" % [scene_name, question_index + 1])
				scene.call("_clear_fragments")
			scene.call("_show_completion")
			_audit_node(scene, "%s complete" % scene_name)
		"NightLedgerRun.tscn":
			scene.set_process(false)
			scene.call("_complete_run")
			_audit_node(scene, "%s Duplex Token reward" % scene_name)
		"MinigameScreenTemplate.tscn":
			scene.call("set_status_text", "CENTERED STATUS LINE ONE\nCENTERED STATUS LINE TWO")
			scene.call("set_result_text", "CENTERED RESULT LINE ONE\nCENTERED RESULT LINE TWO")
			_audit_node(scene, "%s multiline" % scene_name)
		_:
			if scene.get("status_label") is Label and scene.get("counter_label") is Label:
				var adventure_status := scene.get("status_label") as Label
				var adventure_counter := scene.get("counter_label") as Label
				adventure_status.text = "CENTERED STATUS LINE ONE\nCENTERED STATUS LINE TWO\nCENTERED STATUS LINE THREE"
				adventure_counter.text = "OBJECTS: 0 / 10\nKEYS: 0 / 2"
				if scene.has_method("_recenter_side_panel_text"):
					scene.call("_recenter_side_panel_text")
				_audit_node(scene, "%s multiline HUD" % scene_name)
				if scene.has_method("is_hybrid_adventure"):
					# Hybrid stages intentionally place status and counters in two
					# independently centered panels instead of one legacy side block.
					return
				var group_center := (adventure_counter.position.y + adventure_status.position.y + adventure_status.size.y) * 0.5
				_expect(absf(group_center - 192.0) <= 1.5, "%s: counter and status center as one block" % scene_name)

func _audit_multiline_capacity(node: Node, scene_name: String) -> void:
	if node is Label:
		var label := node as Label
		if label.is_visible_in_tree() and label.autowrap_mode != TextServer.AUTOWRAP_OFF and not _is_exempt(label):
			var original_text := label.text
			label.text = "CENTERED LINE ONE\nCENTERED LINE TWO"
			var parent := label.get_parent()
			if parent != null and parent.has_method("_recenter_side_panel_text"):
				parent.call("_recenter_side_panel_text")
			var scene_root: Node = label
			while scene_root.get_parent() != null and scene_root.get_parent() != root:
				scene_root = scene_root.get_parent()
			var layout_guard := scene_root.get_node_or_null("MinigameUILayoutGuard")
			if layout_guard != null and layout_guard.has_method("refresh_now"):
				layout_guard.call("refresh_now")
			_audit_text_fit(label, "%s two-line probe" % scene_name)
			label.text = original_text
			if parent != null and parent.has_method("_recenter_side_panel_text"):
				parent.call("_recenter_side_panel_text")
	for child in node.get_children():
		_audit_multiline_capacity(child, scene_name)

func _expect(condition: bool, label: String) -> void:
	if condition:
		return
	failures += 1
	push_error("FAIL: %s" % label)
