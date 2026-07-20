extends SceneTree
# Physics-based walkability audit. For every playable map:
#   1. sample the REAL physics world on an 8px grid (player-sized shape query)
#   2. flood-fill reachable space from the player spawn
#   3. assert every MapTransition trigger and every interactable is reachable.
# Run: godot --headless --script res://tools/smoke_walkability.gd --path <project>

const CELL := 8.0
const PLAYER_SIZE := Vector2(10.0, 12.0)
const INTERACT_REACH := 28.0

var scenes := [
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
	"res://scenes/maps/hallways/BackHallway.tscn",
	"res://scenes/maps/hallways/CabinetSnackHallway.tscn",
	"res://scenes/maps/hallways/SnackPrizeHallway.tscn",
	"res://scenes/maps/hallways/MaintenanceStaffHallway.tscn",
]
var i := 0
var inst: Node = null
var frame := 0
var total_fails := 0

func _initialize() -> void:
	var gs = root.get_node_or_null("GameState")
	if gs:
		gs.set("story_started", true)
		gs.set("staff_corridor_unlocked", true)
		gs.set("lying_cabinets_completed", true)

func _process(_d: float) -> bool:
	if inst == null:
		if i >= scenes.size():
			print("\n=== WALKABILITY AUDIT: %s ===" % ("PASS" if total_fails == 0 else "FAIL (%d)" % total_fails))
			quit(1 if total_fails > 0 else 0)
			return true
		inst = load(scenes[i]).instantiate()
		root.add_child(inst)
		frame = 0
		return false
	frame += 1
	if frame < 10:
		return false
	_audit(inst, scenes[i].get_file().get_basename())
	inst.free()
	inst = null
	i += 1
	return false

func _audit(scene: Node, label: String) -> void:
	var space := root.get_viewport().world_2d.direct_space_state
	var player: Node = scene.get_node_or_null("Player")
	var params := PhysicsShapeQueryParameters2D.new()
	var shape := RectangleShape2D.new()
	shape.size = PLAYER_SIZE
	params.shape = shape
	params.collide_with_areas = false
	if player is CharacterBody2D:
		params.exclude = [player.get_rid()]
	# 1. sample walkable cells
	var walkable := {}
	for gy in range(2, 54):
		for gx in range(2, 79):
			var pos := Vector2(gx * CELL + CELL * 0.5, gy * CELL + CELL * 0.5)
			params.transform = Transform2D(0.0, pos)
			walkable[Vector2i(gx, gy)] = space.intersect_shape(params, 1).is_empty()
	# 2. flood fill from player spawn
	var start_pos: Vector2 = player.global_position if player != null else Vector2(320, 220)
	var start := Vector2i(int(start_pos.x / CELL), int(start_pos.y / CELL))
	if not walkable.get(start, false):
		var found := false
		for r in range(1, 5):
			for dy in range(-r, r + 1):
				for dx in range(-r, r + 1):
					if walkable.get(start + Vector2i(dx, dy), false):
						start += Vector2i(dx, dy)
						found = true
						break
				if found: break
			if found: break
		if not found:
			print("  FAIL %s: spawn %s embedded in collision" % [label, str(start_pos)])
			total_fails += 1
			return
	var reachable := {}
	var queue: Array[Vector2i] = [start]
	reachable[start] = true
	while not queue.is_empty():
		var c: Vector2i = queue.pop_front()
		for d in [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]:
			var n: Vector2i = c + d
			if walkable.get(n, false) and not reachable.has(n):
				reachable[n] = true
				queue.append(n)
	var fails_here := 0
	# 3a. every transition trigger reachable
	for t in _find_transitions(scene):
		var rect := Rect2(t.global_position - Vector2(36, 20), Vector2(72, 40))
		if not _rect_reachable(rect, reachable):
			print("  FAIL %s: exit '%s' at %s unreachable" % [label, t.name, str(t.global_position)])
			fails_here += 1
	# 3b. every interactable reachable within the REAL interaction rule:
	# player 8px circle must overlap the 64x64 hotspot area, with margin for
	# move_and_slide safe margins -> a reachable cell within 28px per axis.
	for n in _find_interactables(scene):
		var half := Vector2(INTERACT_REACH, INTERACT_REACH)
		var extents_value: Variant = n.get("interact_extents")
		if extents_value is Vector2:
			half = Vector2(maxf((extents_value as Vector2).x * 0.5 - 4.0, 8.0), maxf((extents_value as Vector2).y * 0.5 - 4.0, 8.0))
		var rect := Rect2(n.global_position - half, half * 2.0)
		if not _rect_reachable(rect, reachable):
			print("  FAIL %s: interactable '%s' at %s out of reach" % [label, n.name, str(n.global_position)])
			fails_here += 1
		# floating-invisible-hotspot review: an interactable with no sprite and no
		# placeholder visual should anchor to solid furniture (the Vendo/Cab07 bug class)
		var sprite_path := str(n.get("sprite_texture_path")) if n.get("sprite_texture_path") != null else ""
		var sheet_path := str(n.get("idle_sheet_path")) if n.get("idle_sheet_path") != null else ""
		var placeholder: Variant = n.get("use_placeholder_visual")
		if sprite_path.is_empty() and sheet_path.is_empty() and placeholder != null and not bool(placeholder):
			var anchor := PhysicsShapeQueryParameters2D.new()
			var circle := CircleShape2D.new()
			circle.radius = 44.0
			anchor.shape = circle
			anchor.transform = Transform2D(0.0, n.global_position)
			if player is CharacterBody2D:
				anchor.exclude = [player.get_rid()]
			if space.intersect_shape(anchor, 1).is_empty():
				print("  WARN %s: invisible hotspot '%s' at %s not anchored to any solid object" % [label, n.name, str(n.global_position)])
	# 3c. every spawn marker usable
	for m in scene.get_children():
		if m is Marker2D and str(m.name).begins_with("Spawn"):
			var cell := Vector2i(int(m.position.x / CELL), int(m.position.y / CELL))
			var ok := false
			for dy in range(-1, 2):
				for dx in range(-1, 2):
					if reachable.get(cell + Vector2i(dx, dy), false):
						ok = true
			if not ok:
				print("  FAIL %s: spawn marker '%s' at %s stuck/isolated" % [label, m.name, str(m.position)])
				fails_here += 1
	total_fails += fails_here
	print("  %s %s (reach %d cells)" % ["OK  " if fails_here == 0 else "FAIL", label, reachable.size()])

func _rect_reachable(rect: Rect2, reachable: Dictionary) -> bool:
	for cell in reachable.keys():
		var p := Vector2(cell.x * CELL + CELL * 0.5, cell.y * CELL + CELL * 0.5)
		if rect.has_point(p):
			return true
	return false

func _find_transitions(scene: Node) -> Array:
	var out: Array = []
	_collect(scene, out, func(n): return n is Area2D and n.get("target_scene_path") != null)
	return out

func _find_interactables(scene: Node) -> Array:
	var out: Array = []
	_collect(scene, out, func(n): return n is Area2D and n.get("interactable_kind") != null)
	return out

func _collect(node: Node, out: Array, pred: Callable) -> void:
	for child in node.get_children():
		if pred.call(child):
			out.append(child)
		_collect(child, out, pred)
