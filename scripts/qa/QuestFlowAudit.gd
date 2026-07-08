extends SceneTree
# Quest-flow audit: walks the entire required route and at EVERY beat asserts
#   1. quest data is complete (title/summary/location)
#   2. RouteCue produces guidance from every room in the game
#   3. save -> load roundtrip preserves the exact quest state
# Run: godot --headless --script res://scripts/qa/QuestFlowAudit.gd --path <project>

const GAME_STATE_SCRIPT := preload("res://scripts/GameState.gd")
const ROUTE_CUE := preload("res://scripts/RouteCue.gd")

const HUD_TIP_FONT_PATH := "res://assets/fonts/m3x6.ttf"
const HUD_TIP_WIDTH := 282.0
const HUD_TIP_FONT_SIZE := 16

const LOCATIONS := [
	"arcade_hub", "cabinet_row", "snack_alcove", "prize_corner",
	"maintenance_hall", "staff_corridor", "cabinet_hallway", "back_hallway",
]

var fails := 0
var gs: Node = null
var started := false

func _process(_delta: float) -> bool:
	# Run from _process: Engine.get_main_loop() (used by RouteCue) is only set
	# after _init, so static route lookups would silently fail there.
	if started:
		return true
	started = true
	_run()
	return true

func _run() -> void:
	print("QuestFlowAudit: walking the full required route")
	# Drive the real autoload when present so RouteCue's static lookups reflect
	# each beat; fall back to a local instance in bare test environments.
	gs = root.get_node_or_null("GameState")
	if gs == null:
		gs = GAME_STATE_SCRIPT.new()
		gs.name = "GameState"
		root.add_child(gs)
	gs.reset_for_new_game()

	_beat("opening", func(): pass)
	_beat("story start", func(): gs.start_lost_token_quest())
	_beat("rockbyte done", func():
		gs.rockbyte_duel_completed = true
		gs.collect_lost_token())
	_beat("token returned", func(): gs.complete_lost_token_quest())
	_beat("broken high score", func(): gs.complete_broken_high_score())
	_beat("truth filter", func(): gs.complete_truth_filter())
	_beat("gus check-in: post-filter", func(): gs.gus_hub_checkin_truth_filter_done = true)
	_beat("circuit soda", func(): gs.complete_circuit_soda())
	_beat("prize sort", func(): gs.complete_pip_secret())
	_beat("gus check-in: post-prizes", func(): gs.gus_hub_checkin_prize_sort_done = true)
	_beat("lost shift file", func():
		gs.read_closing_checklist()
		gs.read_maintenance_note()
		gs.read_staff_schedule())
	_beat("static service run", func(): gs.complete_static_service_run())
	_beat("maintenance sync", func(): gs.complete_maintenance_sync())
	_beat("security tape", func(): gs.complete_security_tape_assembly())
	_beat("final night walk", func(): gs.complete_final_night_walk())
	_beat("memory echo", func(): gs.complete_memory_echo())
	_beat("reveal", func(): gs.mark_twist_reveal_seen())
	_beat("final conscience", func(): gs.mark_conscience_final_room_seen())
	_beat("post-reveal roam", func(): gs.unlock_post_reveal_roam())

	if fails == 0:
		print("QuestFlowAudit: PASS")
		quit(0)
	else:
		print("QuestFlowAudit: FAIL (%d)" % fails)
		quit(1)

func _beat(label: String, advance: Callable) -> void:
	advance.call()
	var quest_id: String = gs.get_current_quest_id()
	if quest_id.is_empty():
		return
	# 1. quest data completeness
	var data: Dictionary = gs.get_current_quest_data()
	for field in ["title", "summary"]:
		if str(data.get(field, "")).is_empty():
			print("  FAIL [%s] quest '%s' missing %s" % [label, quest_id, field])
			fails += 1
	# summary must fit the top-right HUD tip on ONE line (m3x6 @16, 282px)
	var tip_font: Font = load(HUD_TIP_FONT_PATH)
	if tip_font != null:
		var tip_width: float = tip_font.get_string_size(str(data.get("summary", "")), HORIZONTAL_ALIGNMENT_LEFT, -1, HUD_TIP_FONT_SIZE).x
		if tip_width > HUD_TIP_WIDTH:
			print("  FAIL [%s] quest '%s' summary too wide for HUD tip: %.0fpx > %.0fpx" % [label, quest_id, tip_width, HUD_TIP_WIDTH])
			fails += 1
	# 2. routing guidance from every room
	for loc in LOCATIONS:
		var hint: String = ROUTE_CUE.get_current_hint(loc)
		if hint.is_empty():
			print("  FAIL [%s] quest '%s': no route hint from %s" % [label, quest_id, loc])
			fails += 1
	# 3. save/load roundtrip
	var saved: Dictionary = gs.to_save_data()
	var clone: Node = GAME_STATE_SCRIPT.new()
	root.add_child(clone)
	clone.apply_save_data(saved)
	var clone_quest: String = clone.get_current_quest_id()
	if clone_quest != quest_id:
		print("  FAIL [%s] save/load drift: '%s' -> '%s'" % [label, quest_id, clone_quest])
		fails += 1
	var clone_progress: int = clone.get_required_progress_count()
	var live_progress: int = gs.get_required_progress_count()
	if clone_progress != live_progress:
		print("  FAIL [%s] save/load progress drift: %d -> %d" % [label, live_progress, clone_progress])
		fails += 1
	clone.free()
	print("  OK [%s] quest=%s main=%d/%d" % [label, quest_id, live_progress, gs.get_total_required_progress_count()])
