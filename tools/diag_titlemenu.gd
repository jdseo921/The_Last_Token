extends SceneTree
# Title menu input audit: does anything block clicks on the buttons, and does
# WASD move the focus?

var frame := 0
var scene: Node = null

func _process(_delta: float) -> bool:
	frame += 1
	if frame == 1:
		scene = (load("res://scenes/main/Main.tscn") as PackedScene).instantiate()
		root.add_child(scene)
		return false
	if frame < 5:
		return false
	var button: Button = _find_button(scene)
	if button == null:
		print("no button found")
		return true
	var point: Vector2 = button.get_global_rect().get_center()
	print("first button: %s rect=%s focused=%s" % [button.name, button.get_global_rect(), button.has_focus()])
	var hits: Array = []
	_collect(scene, point, hits, 0)
	hits.reverse()
	print("controls under the button, topmost first:")
	for h in hits.slice(0, 8):
		print("   layer=%d filter=%d visible=%s %s" % [h[0], h[1], h[2], h[3]])
	print("ui_up events:  ", _events_for("ui_up"))
	print("ui_down events:", _events_for("ui_down"))
	print("move_up events:", _events_for("move_up"))
	return true

func _events_for(action: String) -> String:
	if not InputMap.has_action(action):
		return "<action missing>"
	var out: Array[String] = []
	for e in InputMap.action_get_events(action):
		if e is InputEventKey:
			var k := e as InputEventKey
			var code: int = k.physical_keycode if k.physical_keycode != 0 else k.keycode
			out.append(OS.get_keycode_string(code))
		else:
			out.append(e.get_class())
	return ", ".join(out)

func _find_button(node: Node) -> Button:
	if node is Button and (node as Button).is_visible_in_tree():
		return node as Button
	for child in node.get_children():
		var found := _find_button(child)
		if found != null:
			return found
	return null

func _collect(node: Node, point: Vector2, hits: Array, layer: int) -> void:
	var current_layer := layer
	if node is CanvasLayer:
		current_layer = (node as CanvasLayer).layer
	if node is Control:
		var c := node as Control
		if c.get_global_rect().has_point(point):
			hits.append([current_layer, c.mouse_filter, c.is_visible_in_tree(), c.get_path()])
	for child in node.get_children():
		_collect(child, point, hits, current_layer)
