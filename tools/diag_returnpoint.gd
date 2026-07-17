extends SceneTree
# Verify the minigame return point: the exact spot is handed back to the room
# it was taken from, and never to any other room.

var started := false

func _process(_delta: float) -> bool:
	if started:
		return true
	started = true
	var gs := root.get_node("GameState")
	var cabinet_row := "res://scenes/maps/CabinetRow.tscn"
	var hub := "res://scenes/arcade/ArcadeHub.tscn"
	var spot := Vector2(412, 301)

	gs.set_return_point(cabinet_row, spot)
	print("stored %s at %s" % [cabinet_row.get_file(), spot])
	var wrong: Variant = gs.consume_return_point(hub)
	print("  arriving at ArcadeHub  -> %s (expect <null>: the spot is not this room's)" % ("null" if wrong == null else str(wrong)))
	var again: Variant = gs.consume_return_point(cabinet_row)
	print("  arriving at CabinetRow -> %s (expect <null>: a stale spot was dropped)" % ("null" if again == null else str(again)))

	gs.set_return_point(cabinet_row, spot)
	var right: Variant = gs.consume_return_point(cabinet_row)
	print("stored again, arriving at CabinetRow -> %s (expect %s)" % [str(right), str(spot)])
	var twice: Variant = gs.consume_return_point(cabinet_row)
	print("  consuming twice -> %s (expect <null>: spot used once)" % ("null" if twice == null else str(twice)))

	gs.set_return_point(cabinet_row, spot)
	print("has_return_point=%s scene=%s (quit-minigame sends you here)" % [gs.has_return_point(), gs.get_return_scene_path().get_file()])
	return true
