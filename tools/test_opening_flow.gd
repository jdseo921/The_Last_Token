extends SceneTree
# Verifies the new look-around -> 3 talks -> monologue -> talk-to-Mira quest gating.
var _frame := 0
var _out: Array = []

func _process(_d: float) -> bool:
	_frame += 1
	if _frame < 3:
		return false
	var gs = root.get_node_or_null("GameState")
	if gs == null:
		_out.append("GameState autoload MISSING")
		_dump()
		return true
	_out.append("start quest_id = %s  (expect opening_look_around)" % gs.get_current_quest_id())
	_out.append("look_around_active = %s  (expect true)" % gs.opening_look_around_active())
	gs.register_opening_talk()
	gs.register_opening_talk()
	_out.append("after 2 talks: monologue_due = %s  (expect false)" % gs.opening_monologue_due())
	gs.register_opening_talk()
	_out.append("after 3 talks: monologue_due = %s  (expect true)" % gs.opening_monologue_due())
	gs.opening_hint_monologue_seen = true
	_out.append("after monologue: quest_id = %s  (expect opening_talk_to_mira)" % gs.get_current_quest_id())
	if gs.has_method("start_lost_token_quest"):
		gs.start_lost_token_quest()
	_out.append("after Mira: quest_id = %s  story_started = %s  (expect recover_lost_token, true)" % [gs.get_current_quest_id(), gs.story_started])
	_dump()
	return true

func _dump() -> void:
	print("\n=== OPENING FLOW TEST ===")
	for l in _out:
		print("  " + str(l))
	print("=== END ===")
