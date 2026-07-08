extends SceneTree
# Diagnostic: which Control actually receives a click aimed at RockbyteDuel's
# move buttons? Emulates Godot's pick order (canvas layer, then tree order).

var frame := 0
var scene: Node = null

func _process(_delta: float) -> bool:
	frame += 1
	if frame == 1:
		scene = (load("res://scenes/minigames/RockbyteDuel.tscn") as PackedScene).instantiate()
		root.add_child(scene)
		return false
	if frame < 4:
		return false
	var button: Button = scene.get_node("ButtonArea/ButtonsHBox/TakeLeftButton")
	var point: Vector2 = button.get_global_rect().get_center()
	print("button rect=", button.get_global_rect(), " point=", point, " disabled=", button.disabled, " visible=", button.is_visible_in_tree())
	var hits: Array = []
	_collect(scene, point, hits, 0)
	print("controls under point, input order (topmost first):")
	hits.reverse()
	for h in hits.slice(0, 12):
		print("  layer=%d filter=%d %s" % [h[0], h[1], h[2]])
	return true

func _collect(node: Node, point: Vector2, hits: Array, layer: int) -> void:
	var current_layer := layer
	if node is CanvasLayer:
		current_layer = (node as CanvasLayer).layer
	if node is Control:
		var c := node as Control
		if c.is_visible_in_tree() and c.get_global_rect().has_point(point):
			hits.append([current_layer, c.mouse_filter, c.get_path()])
	for child in node.get_children():
		_collect(child, point, hits, current_layer)
