extends SceneTree

# Guards the simplified maintenance branch: one service door, no retired
# document hotspots, and a collision-free path from the room floor to the door.
const MAINTENANCE_HALL := "res://scenes/maps/MaintenanceHall.tscn"
const STAFF_CORRIDOR := "res://scenes/maps/StaffCorridor.tscn"

var failures := 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var maintenance := (load(MAINTENANCE_HALL) as PackedScene).instantiate()
	var corridor := (load(STAFF_CORRIDOR) as PackedScene).instantiate()

	_expect(maintenance.get_node_or_null("InteractableLayer/MaintenanceNote") == null, "Maintenance note hotspot removed")
	_expect(maintenance.get_node_or_null("InteractableLayer/StaffRecord02") == null, "Maintenance record hotspot removed")
	_expect(corridor.get_node_or_null("InteractableLayer/StaffRecord03") == null, "Corridor record hotspot removed")
	_expect(maintenance.get_node_or_null("ToWorkshop") == null, "Workshop exit removed")
	_expect(corridor.get_node_or_null("ToMemoryCore") == null, "Memory Core exit removed")
	_expect(not ResourceLoader.exists("res://scenes/maps/Workshop.tscn"), "Workshop scene removed")
	_expect(not ResourceLoader.exists("res://scenes/maps/MemoryCore.tscn"), "Memory Core scene removed")

	var staff_exit := maintenance.get_node_or_null("ToStaffCorridor") as Node2D
	_expect(staff_exit != null and staff_exit.position.distance_to(Vector2(346, 174)) < 1.0, "Staff Access exit is at the central marked doorway")
	_expect(_has_clear_vertical_path(maintenance, Vector2(346, 236), Vector2(346, 174)), "Central service doorway has no collision blockade")
	var corridor_transitions := _count_transitions(corridor)
	_expect(corridor_transitions == 1, "Staff Corridor keeps one return exit")

	maintenance.free()
	corridor.free()
	print("MaintenanceRouteSmoke: %s" % ("PASS" if failures == 0 else "FAIL (%d)" % failures))
	quit(0 if failures == 0 else 1)

func _has_clear_vertical_path(scene: Node, from: Vector2, to: Vector2) -> bool:
	var bounds := scene.get_node_or_null("CollisionBounds")
	if bounds == null:
		return false
	for value in bounds.get("rectangles"):
		var rect_value: Vector4 = value
		var rect := Rect2(Vector2(rect_value.x, rect_value.y), Vector2(rect_value.z, rect_value.w))
		if rect.has_point(from) or rect.has_point(to):
			return false
		if from.x >= rect.position.x and from.x <= rect.end.x:
			var segment_top := minf(from.y, to.y)
			var segment_bottom := maxf(from.y, to.y)
			if segment_bottom >= rect.position.y and segment_top <= rect.end.y:
				return false
	return true

func _count_transitions(scene: Node) -> int:
	var count := 0
	for child in scene.get_children():
		if child.has_method("get_target_scene_path") or child.name.begins_with("ReturnTo") or child.name.begins_with("To"):
			if child.get("target_scene_path") != null:
				count += 1
	return count

func _expect(condition: bool, label: String) -> void:
	if condition:
		print("PASS: " + label)
		return
	failures += 1
	push_error("FAIL: " + label)
