# Copyright (c) 2026 jdseo921. All rights reserved.
# This software and associated documentation files are proprietary and confidential.
# Unauthorized copying, modification, or distribution of this file is strictly prohibited.
# Written by jdseo921, jdseo0921@gmail.com

extends SceneTree
## Every hallway must funnel the player into its exit arrow.
##
## The connector hallways were authored with a full-width top and bottom wall
## and no side walls, so the 180px corridor was guarded by a 52px exit trigger.
## A player walking along the floor reached the screen edge without ever
## touching the arrow, and could stand past it.
##
## The property asserted here: anywhere the player can physically stand against
## a screen edge, an exit trigger is already on them. Walls are read from each
## scene's MapCollisionBounds export, triggers from the live Area2D positions
## after _ready() has aligned them, so anchor edits cannot silently desync.

const HALLWAYS := [
	"res://scenes/maps/hallways/CabinetHallway.tscn",
	"res://scenes/maps/hallways/CabinetSnackHallway.tscn",
	"res://scenes/maps/hallways/MaintenanceHallway.tscn",
	"res://scenes/maps/hallways/MaintenanceStaffHallway.tscn",
	"res://scenes/maps/hallways/PrizeHallway.tscn",
	"res://scenes/maps/hallways/SnackHallway.tscn",
	"res://scenes/maps/hallways/SnackPrizeHallway.tscn",
]

const SCREEN := Vector2(640, 440)
const PLAYER_BOX := Vector2(12, 14)
const SAMPLE_STEP := 2.0
const EDGE_PROBE := 1.0

var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	for path in HALLWAYS:
		await _check_hallway(path)
	print("HallwayExitSealSmoke: %s" % ("PASS" if failures == 0 else "FAIL (%d)" % failures))
	quit(0 if failures == 0 else 1)


func _check_hallway(path: String) -> void:
	var packed := load(path) as PackedScene
	if packed == null:
		_fail("%s loads" % path.get_file())
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	# _ready() moves each exit onto its measured wall recess, so sample after it.
	await process_frame
	await process_frame

	var name := path.get_file()
	var walls := _collect_walls(scene)
	var exits := _collect_exit_rects(scene)
	_expect(not walls.is_empty(), "%s declares collision bounds" % name)
	_expect(not exits.is_empty(), "%s has at least one exit" % name)

	# This check only models rectangle-declared walls. If a hallway ever starts
	# deriving collision from sprites or polygons instead, the sampling below
	# would quietly stop seeing those walls and report false leaks, so fail loudly
	# rather than mislead.
	var bounds := scene.get_node_or_null("CollisionBounds")
	if bounds != null:
		var derived: int = (bounds.get("visual_node_paths") as Array).size() \
			+ (bounds.get("visible_visual_node_paths") as Array).size()
		_expect(derived == 0,
			"%s declares its walls as rectangles, which is all this check can model" % name)

	var leaks := 0
	var first_leak := Vector2.ZERO
	for edge in ["left", "right", "top", "bottom"]:
		var leak := _first_leak_on_edge(edge, walls, exits)
		if leak.x < 0.0:
			continue
		leaks += 1
		if first_leak == Vector2.ZERO:
			first_leak = leak
	if leaks == 0:
		print("PASS: %s seals every screen edge behind an exit" % name)
	else:
		_fail("%s can be walked off the screen at %s without entering an exit (%d edge(s) leak)"
			% [name, first_leak, leaks])

	# A doorway the player cannot fit through is as broken as one that leaks.
	for exit_rect in exits:
		var passable := _door_is_passable(exit_rect, walls)
		_expect(passable, "%s exit at %s leaves a gap the player fits through" % [name, exit_rect.get_center()])

	scene.queue_free()
	await process_frame


func _collect_walls(scene: Node) -> Array[Rect2]:
	var result: Array[Rect2] = []
	var bounds := scene.get_node_or_null("CollisionBounds")
	if bounds == null:
		return result
	for value in bounds.get("rectangles"):
		if value is Vector4:
			var v: Vector4 = value
			result.append(Rect2(v.x, v.y, v.z, v.w))
	return result


func _collect_exit_rects(scene: Node) -> Array[Rect2]:
	var result: Array[Rect2] = []
	for child in scene.get_children():
		if not child is Area2D or child.get("target_scene_path") == null:
			continue
		var area := child as Area2D
		var shape_node := area.get_node_or_null("CollisionShape2D") as CollisionShape2D
		if shape_node == null or not shape_node.shape is RectangleShape2D:
			continue
		var size: Vector2 = (shape_node.shape as RectangleShape2D).size
		var center: Vector2 = area.position + shape_node.position
		result.append(Rect2(center - size * 0.5, size))
	return result


func _first_leak_on_edge(edge: String, walls: Array[Rect2], exits: Array[Rect2]) -> Vector2:
	# Walk the inside face of one screen edge. Any spot the player box fits into
	# without an exit trigger covering it is a way out of the room.
	var half := PLAYER_BOX * 0.5
	var limit: float = SCREEN.y if edge == "left" or edge == "right" else SCREEN.x
	var value := 0.0
	while value <= limit:
		var center: Vector2
		match edge:
			"left":
				center = Vector2(half.x + EDGE_PROBE, value)
			"right":
				center = Vector2(SCREEN.x - half.x - EDGE_PROBE, value)
			"top":
				center = Vector2(value, half.y + EDGE_PROBE)
			_:
				center = Vector2(value, SCREEN.y - half.y - EDGE_PROBE)
		value += SAMPLE_STEP
		var box := Rect2(center - half, PLAYER_BOX)
		if _overlaps_any(box, walls):
			continue  # solid here, the player cannot stand in it
		if _overlaps_any(box, exits):
			continue  # standing here means the exit already fired
		return center
	return Vector2(-1.0, -1.0)


func _door_is_passable(exit_rect: Rect2, walls: Array[Rect2]) -> bool:
	# Somewhere inside the trigger there must be room for the player to stand,
	# otherwise the wall has sealed the doorway shut.
	var half := PLAYER_BOX * 0.5
	var y := exit_rect.position.y + half.y
	while y <= exit_rect.end.y - half.y:
		var x := exit_rect.position.x + half.x
		while x <= exit_rect.end.x - half.x:
			if not _overlaps_any(Rect2(Vector2(x, y) - half, PLAYER_BOX), walls):
				return true
			x += SAMPLE_STEP
		y += SAMPLE_STEP
	return false


func _overlaps_any(box: Rect2, rects: Array[Rect2]) -> bool:
	for rect in rects:
		if rect.intersects(box):
			return true
	return false


func _expect(condition: bool, label: String) -> void:
	if condition:
		print("PASS: %s" % label)
		return
	_fail(label)


func _fail(label: String) -> void:
	failures += 1
	push_error("FAIL: %s" % label)
