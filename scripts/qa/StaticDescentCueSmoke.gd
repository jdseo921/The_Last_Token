extends SceneTree
## Guards the descent arrows in Static Service Depths.
##
## The arrows are the only thing telling a player which way the shaft continues,
## and this course authors no mid-shaft thresholds: `checkpoints` is empty, so
## `respawn_position` never leaves the intake. A cue pointing at a gap with no
## shelf under it therefore costs the player the whole descent.
##
## Each cue is re-simulated here against the real platform table and the real
## controller tuning: step off the indicated edge at run speed, spend up to the
## stage's midair jumps, and require that the fall reaches a shelf.

const ADVENTURE_CATALOG := preload("res://scripts/minigames/adventure/HybridAdventureCatalog.gd")
const EXPLORER_CONTROLLER := preload("res://scripts/minigames/adventure/HybridExplorerController.gd")

const STAGE_ID := "static_service_run"
const CUE_SURFACE_OFFSET := 26.0
const CUE_OFFSET_TOLERANCE := 6.0
const STEP_SECONDS := 1.0 / 240.0
const MAX_FLIGHT_SECONDS := 12.0

var failures := 0
var run_speed := 172.0
var gravity := 980.0
var terminal_velocity := 620.0
var jump_speed := 344.0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_read_controller_tuning()

	var profile: Dictionary = ADVENTURE_CATALOG.get_profile(STAGE_ID)
	var platforms: Array = profile.get("platforms", [])
	var cues: Array = profile.get("descent_cues", [])
	var world_size: Vector2 = profile.get("world_size", Vector2.ZERO)
	var midair_jumps := int(profile.get("max_midair_jumps", 3))

	_expect(not platforms.is_empty(), "the descent course builds platforms")
	_expect(not cues.is_empty(), "the descent course authors cues")

	# Without thresholds a void fall rewinds the whole stage. If this course ever
	# gains checkpoints the cue rules can relax, so state the assumption loudly.
	_expect((profile.get("checkpoints", []) as Array).is_empty(),
		"descent still has no mid-shaft thresholds, so a void fall is expensive")

	var shelves_with_cues := {}
	for index in range(cues.size()):
		var cue: Dictionary = cues[index]
		var position: Vector2 = cue.get("position", Vector2.ZERO)
		var direction := str(cue.get("direction", "down"))
		var label := "cue %02d at %s %s" % [index + 1, position, direction]

		var shelf := _shelf_under(position, platforms)
		if shelf < 0:
			_fail("%s sits on a shelf" % label)
			continue
		shelves_with_cues[shelf] = true

		var shelf_rect: Rect2 = platforms[shelf]
		_expect(absf(shelf_rect.position.y - position.y - CUE_SURFACE_OFFSET) <= CUE_OFFSET_TOLERANCE,
			"%s floats the standard %dpx above its shelf" % [label, int(CUE_SURFACE_OFFSET)])

		if direction == "down":
			continue

		var landing := _simulate_drop(shelf, direction, midair_jumps, platforms, world_size)
		_expect(landing >= 0,
			"%s points at a drop that lands on a shelf, not the void" % label)
		if landing >= 0:
			_expect(platforms[landing].position.y > shelf_rect.position.y,
				"%s points downward rather than at a shelf level with it" % label)

	# Every shelf a player stands on needs a cue. The exit floor is the one that
	# does not: there is nowhere further to go.
	for shelf in range(platforms.size() - 1):
		_expect(shelves_with_cues.has(shelf),
			"shelf %d carries at least one descent cue" % shelf)

	_check_required_route(profile, platforms, cues)

	print("StaticDescentCueSmoke: %s" % ("PASS" if failures == 0 else "FAIL (%d)" % failures))
	quit(0 if failures == 0 else 1)


func _check_required_route(profile: Dictionary, platforms: Array, cues: Array) -> void:
	# The cores are ordered, so the shelves holding them are the route. Each of
	# those shelves must carry a cue whose drop makes progress toward the next.
	var collectibles: Array = profile.get("collectibles", [])
	var midair_jumps := int(profile.get("max_midair_jumps", 3))
	var world_size: Vector2 = profile.get("world_size", Vector2.ZERO)
	for index in range(collectibles.size()):
		var core: Vector2 = collectibles[index]
		var shelf := _shelf_under(core, platforms)
		_expect(shelf >= 0, "core %02d rests on a shelf" % [index + 1])
		if shelf < 0 or index == collectibles.size() - 1:
			continue
		var descends := false
		for cue_value in cues:
			var cue: Dictionary = cue_value
			var cue_position: Vector2 = cue.get("position", Vector2.ZERO)
			if _shelf_under(cue_position, platforms) != shelf:
				continue
			var landing := _simulate_drop(shelf, str(cue.get("direction", "down")), midair_jumps, platforms, world_size)
			if landing >= 0:
				descends = true
				break
		_expect(descends, "the shelf holding core %02d has a cue that reaches another shelf" % [index + 1])


func _read_controller_tuning() -> void:
	# Read the live tuning so retuning the controller retunes this check too.
	var controller := EXPLORER_CONTROLLER.new()
	run_speed = float(controller.run_speed)
	gravity = float(controller.gravity)
	terminal_velocity = float(controller.terminal_velocity)
	jump_speed = float(controller.jump_speed)
	controller.free()


func _shelf_under(point: Vector2, platforms: Array) -> int:
	for index in range(platforms.size()):
		var rect: Rect2 = platforms[index]
		var above_surface := point.y < rect.position.y
		var within_span := point.x >= rect.position.x and point.x <= rect.position.x + rect.size.x
		if above_surface and within_span and rect.position.y - point.y <= 64.0:
			return index
	return -1


func _simulate_drop(from_shelf: int, direction: String, midair_jumps: int, platforms: Array, world_size: Vector2) -> int:
	var shelf: Rect2 = platforms[from_shelf]
	var x := shelf.position.x if direction == "left" else shelf.position.x + shelf.size.x
	var y := shelf.position.y
	var horizontal := -run_speed if direction == "left" else run_speed
	var vertical := 0.0
	# Spend the jumps immediately: that is the longest reach available, and it is
	# what a player stretching for a far shelf does.
	var jumps_left := midair_jumps
	var elapsed := 0.0
	while elapsed < MAX_FLIGHT_SECONDS:
		var previous_y := y
		if jumps_left > 0 and vertical > 0.0:
			vertical = -jump_speed
			jumps_left -= 1
		vertical = minf(vertical + gravity * STEP_SECONDS, terminal_velocity)
		x += horizontal * STEP_SECONDS
		y += vertical * STEP_SECONDS
		elapsed += STEP_SECONDS
		if x <= 0.0 or x >= world_size.x:
			x = clampf(x, 0.0, world_size.x)
			horizontal = 0.0
		if y > world_size.y:
			return -1
		if vertical <= 0.0:
			continue
		for index in range(platforms.size()):
			if index == from_shelf:
				continue
			var rect: Rect2 = platforms[index]
			var crossed_surface := previous_y <= rect.position.y and y >= rect.position.y
			var over_shelf := x >= rect.position.x and x <= rect.position.x + rect.size.x
			if crossed_surface and over_shelf:
				return index
	return -1


func _expect(condition: bool, label: String) -> void:
	if condition:
		print("PASS: %s" % label)
		return
	_fail(label)


func _fail(label: String) -> void:
	failures += 1
	push_error("FAIL: %s" % label)
