# Copyright (c) 2026 jdseo921. All rights reserved.
# This software and associated documentation files are proprietary and confidential.
# Unauthorized copying, modification, or distribution of this file is strictly prohibited.
# Written by jdseo921, jdseo0921@gmail.com

extends SceneTree
## Can a player actually walk the game?
##
## Everything else in the suite checks that the route is wired correctly: that
## quests fire in order, that hints appear, that exits point at scenes and
## spawn markers that exist. None of it checks the thing a player experiences
## first - whether the geometry lets you get there.
##
## This flood-fills each room's standable space from its spawn point using the
## real player body against the real physics world, then asserts that every
## exit, every interactable and every other spawn marker lies inside that one
## connected region. It uses shape queries rather than reading the collision
## rectangle export, so collision derived from sprites and polygons counts too.
##
## What this still does not prove: movement feel, input timing, or that a stage
## is winnable once entered. It proves the overworld is navigable.

const ROOMS := [
	"res://scenes/arcade/ArcadeHub.tscn",
	"res://scenes/arcade/StaffRoom.tscn",
	"res://scenes/maps/CabinetRow.tscn",
	"res://scenes/maps/SnackAlcove.tscn",
	"res://scenes/maps/MaintenanceHall.tscn",
	"res://scenes/maps/StaffCorridor.tscn",
	"res://scenes/maps/PrizeCorner.tscn",
	"res://scenes/maps/FrontEntrance.tscn",
	"res://scenes/maps/PartyRoom.tscn",
	"res://scenes/maps/Restrooms.tscn",
	"res://scenes/maps/hallways/CabinetHallway.tscn",
	"res://scenes/maps/hallways/SnackHallway.tscn",
	"res://scenes/maps/hallways/PrizeHallway.tscn",
	"res://scenes/maps/hallways/MaintenanceHallway.tscn",
	"res://scenes/maps/hallways/CabinetSnackHallway.tscn",
	"res://scenes/maps/hallways/SnackPrizeHallway.tscn",
	"res://scenes/maps/hallways/MaintenanceStaffHallway.tscn",
]

const SCREEN := Vector2(640, 440)
const PLAYER_BODY := Vector2(12, 14)     # Player.tscn BodyCollision
const INTERACT_RADIUS := 8.0             # Player.tscn InteractionArea
const STEP := 4.0                        # fine enough to pass a 44px doorway

var failures := 0
var body_shape: RectangleShape2D = null
# Rooms ship with the Player (and any NPCs) already in the scene. They are
# actors, not geometry, so they are excluded from the standability queries -
# otherwise the hypothetical player collides with the real one standing on the
# spawn point and every default spawn reads as blocked.
var actor_exclusions: Array[RID] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	body_shape = RectangleShape2D.new()
	body_shape.size = PLAYER_BODY

	for path in ROOMS:
		await _check_room(path)

	print("RouteTraversalSmoke: %s" % ("PASS" if failures == 0 else "FAIL (%d)" % failures))
	quit(0 if failures == 0 else 1)


func _check_room(path: String) -> void:
	var packed := load(path) as PackedScene
	if packed == null:
		_fail("%s loads" % path.get_file())
		return
	var room := packed.instantiate()
	root.add_child(room)
	# MapCollisionBounds rebuilds its bodies on a deferred call, and the physics
	# server needs a tick to register them.
	await process_frame
	await physics_frame
	await physics_frame

	var name := path.get_file()
	var space := root.world_2d.direct_space_state
	actor_exclusions = _collect_actors(room)
	var spawns := _find_spawns(room)
	if spawns.is_empty():
		_fail("%s has a spawn marker" % name)
		room.queue_free()
		await process_frame
		return

	var start: Vector2 = spawns[0].position
	var reachable := _flood_fill(space, start)
	if reachable.is_empty():
		_fail("%s: the default spawn is not standable - the player starts inside geometry" % name)
		room.queue_free()
		await process_frame
		return

	# Every arrival point must land in the same walkable region, or entering from
	# that door strands the player. Standing partly inside geometry is reported
	# separately: move_and_slide pushes the player out, so it is untidy rather
	# than broken, and conflating the two would hide a genuine dead end.
	for marker in spawns:
		_expect(_cell_reachable(reachable, marker.position),
			"%s: spawn %s reaches the walkable region" % [name, marker.name])
		if not _standable(space, marker.position):
			print("NOTE: %s: spawn %s sits inside geometry; the player slides out on the first frame"
				% [name, marker.name])

	# Every exit must be walkable-to, or the room is a dead end.
	for node in room.get_children():
		if not node is Area2D or node.get("target_scene_path") == null:
			continue
		var rect := _area_rect(node as Area2D)
		_expect(_rect_touchable(reachable, rect),
			"%s: exit %s can be walked into" % [name, node.name])

	# Every interactable must be usable from somewhere the player can stand.
	var layer := room.get_node_or_null("InteractableLayer")
	if layer != null:
		for node in layer.get_children():
			if not node is Area2D:
				continue
			var rect := _area_rect(node as Area2D).grow(INTERACT_RADIUS)
			_expect(_rect_touchable(reachable, rect),
				"%s: interactable %s can be reached" % [name, node.name])

	room.queue_free()
	await process_frame


func _collect_actors(room: Node) -> Array[RID]:
	var result: Array[RID] = []
	var pending: Array[Node] = [room]
	while not pending.is_empty():
		var node: Node = pending.pop_back()
		if node is CharacterBody2D:
			result.append((node as CollisionObject2D).get_rid())
		for child in node.get_children():
			pending.append(child)
	return result


func _find_spawns(room: Node) -> Array[Marker2D]:
	var result: Array[Marker2D] = []
	var default_marker: Marker2D = null
	for child in room.get_children():
		if child is Marker2D and child.name.begins_with("Spawn"):
			if child.name == "Spawn_Default":
				default_marker = child
			else:
				result.append(child)
	# Spawn_Default first: it is the region every other arrival is measured against.
	if default_marker != null:
		result.insert(0, default_marker)
	return result


func _flood_fill(space: PhysicsDirectSpaceState2D, start: Vector2) -> Dictionary:
	var open: Array[Vector2i] = []
	var seen := {}
	var origin := _to_cell(start)
	if not _standable(space, _to_world(origin)):
		# Nudge on to the nearest free cell: markers are often authored a few
		# pixels inside a wall's visual, which the player slides out of anyway.
		var found := false
		for radius in range(1, 7):
			for dx in range(-radius, radius + 1):
				for dy in range(-radius, radius + 1):
					var probe := origin + Vector2i(dx, dy)
					if _standable(space, _to_world(probe)):
						origin = probe
						found = true
						break
				if found: break
			if found: break
		if not found:
			return {}

	open.append(origin)
	seen[origin] = true
	var guard := 60000
	while not open.is_empty() and guard > 0:
		guard -= 1
		var cell: Vector2i = open.pop_back()
		for step in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var next: Vector2i = cell + step
			if seen.has(next):
				continue
			var world := _to_world(next)
			if world.x < 0.0 or world.y < 0.0 or world.x > SCREEN.x or world.y > SCREEN.y:
				continue
			if not _standable(space, world):
				continue
			seen[next] = true
			open.append(next)
	return seen


func _standable(space: PhysicsDirectSpaceState2D, at: Vector2) -> bool:
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = body_shape
	query.transform = Transform2D(0.0, at)
	query.collide_with_bodies = true
	query.collide_with_areas = false
	query.exclude = actor_exclusions
	return space.intersect_shape(query, 1).is_empty()


func _cell_reachable(reachable: Dictionary, at: Vector2) -> bool:
	# A marker counts as reachable if any cell within a body's width of it is.
	var center := _to_cell(at)
	for dx in range(-6, 7):
		for dy in range(-6, 7):
			if reachable.has(center + Vector2i(dx, dy)):
				return true
	return false


func _rect_touchable(reachable: Dictionary, rect: Rect2) -> bool:
	# True when the player can stand somewhere whose body overlaps the rect.
	var grown := rect.grow_individual(
		PLAYER_BODY.x * 0.5, PLAYER_BODY.y * 0.5, PLAYER_BODY.x * 0.5, PLAYER_BODY.y * 0.5)
	for cell in reachable:
		if grown.has_point(_to_world(cell)):
			return true
	return false


func _area_rect(area: Area2D) -> Rect2:
	var shape_node := area.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if shape_node == null or not shape_node.shape is RectangleShape2D:
		return Rect2(area.global_position, Vector2.ONE)
	var size: Vector2 = (shape_node.shape as RectangleShape2D).size
	var center: Vector2 = area.position + shape_node.position
	return Rect2(center - size * 0.5, size)


func _to_cell(world: Vector2) -> Vector2i:
	return Vector2i(int(round(world.x / STEP)), int(round(world.y / STEP)))


func _to_world(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * STEP, cell.y * STEP)


func _expect(condition: bool, label: String) -> void:
	if condition:
		print("PASS: %s" % label)
		return
	_fail(label)


func _fail(label: String) -> void:
	failures += 1
	push_error("FAIL: %s" % label)
