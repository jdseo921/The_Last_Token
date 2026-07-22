extends SceneTree
# Behavior test for the hybrid Static Service Run stage:
#   profile validity -> stage build -> checkpoint reset -> completion hook.
# Run: godot --headless --script res://tools/test_ssr_flow.gd --path <project>

const HYBRID_CATALOG := preload("res://scripts/minigames/adventure/HybridAdventureCatalog.gd")

var _inst: Node = null
var _frame := 0
var _fails := 0

func _process(_delta: float) -> bool:
	if _inst == null:
		var ps = load("res://scenes/minigames/StaticServiceRun.tscn")
		_inst = ps.instantiate()
		root.add_child(_inst)
		return false
	_frame += 1
	if _frame < 5:
		return false
	print("\n=== SSR FLOW TEST ===")
	var gs = root.get_node("GameState")

	# 1. profile sanity: the catalog entry drives the stage the scene built
	var profile: Dictionary = HYBRID_CATALOG.get_profile("static_service_run")
	_check("profile has title", str(profile.get("title", "")) != "")
	_check("profile requires collectibles", int(profile.get("required_collectibles", 0)) > 0)
	_check("descent needs no phase relays", int(profile.get("required_keys", -1)) == 0)
	_check("profile is ordered", bool(profile.get("ordered_collectibles", false)))

	# 2. stage build: enough pickups exist to satisfy the requirements
	var collectibles: Array = _inst.get("collectibles")
	var keys: Array = _inst.get("keys")
	_check("stage started quest flag", bool(gs.get("static_service_run_started")))
	_check("built enough collectibles", collectibles.size() >= int(profile.get("required_collectibles", 0)))
	_check("built enough keys", keys.size() >= int(profile.get("required_keys", 0)))
	_check("goal rect exists", (_inst.get("goal_rect") as Rect2).size != Vector2.ZERO)
	_check("player spawned", _inst.get("player") != null)
	_check("not completed at start", bool(_inst.get("completed")) == false)

	# 3. reset is a soft respawn, not a rebuild
	var before_collectibles: int = collectibles.size()
	_inst.call("_reset_stage")
	_check("reset keeps stage intact", (_inst.get("collectibles") as Array).size() == before_collectibles)
	_check("reset does not complete", bool(_inst.get("completed")) == false)

	# 4. completion: the compatibility hook must finish the stage and set the
	# GameState progression flag the quest chain waits for.
	_inst.call("_complete_run")
	_check("stage completed", bool(_inst.get("completed")) == true)
	_check("collected count filled", int(_inst.get("collected_count")) == int(profile.get("required_collectibles", 0)))
	_check("GameState completion", bool(gs.get("static_service_run_completed")) == true)

	if _fails == 0:
		print("SSR FLOW: PASS")
	else:
		print("SSR FLOW: FAIL (%d)" % _fails)
	print("=== END SSR FLOW ===")
	quit(1 if _fails > 0 else 0)
	return true

func _check(label: String, ok: bool) -> void:
	print("  [%s] %s" % ["PASS" if ok else "FAIL", label])
	if not ok:
		_fails += 1
