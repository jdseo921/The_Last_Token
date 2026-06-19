extends RefCounted

const QUEST_DATA_PATH := "res://data/quests.json"

static var _quests_loaded := false
static var _quests: Dictionary = {}

static func get_quest(id: String) -> Dictionary:
	var quests := _get_quests()
	if quests.has(id) and quests[id] is Dictionary:
		return (quests[id] as Dictionary).duplicate(true)
	return {}

static func get_active_main_quest_id() -> String:
	if not GameState.lost_token_quest_completed:
		return "lost_token"
	if not GameState.lying_cabinets_completed:
		return "truth_filter"
	if not GameState.circuit_soda_completed:
		return "circuit_soda"
	if not GameState.story_puzzle_completed:
		return "maintenance_sync"
	if not GameState.twist_reveal_seen:
		return "maintenance_sync"
	return ""

static func get_active_main_quest_data() -> Dictionary:
	return get_quest(get_active_main_quest_id())

static func get_quest_owner(id: String) -> String:
	return str(get_quest(id).get("owner", ""))

static func get_quest_location(id: String) -> String:
	return str(get_quest(id).get("location", ""))

static func get_completion_dialogue(id: String) -> Array:
	var quest := get_quest(id)
	var value: Variant = quest.get("completion_dialogue", [])
	if value is Array:
		return (value as Array).duplicate(true)
	return []

static func _get_quests() -> Dictionary:
	if not _quests_loaded:
		_quests = _load_quests()
		_quests_loaded = true
	return _quests

static func _load_quests() -> Dictionary:
	if ResourceLoader.exists(QUEST_DATA_PATH):
		var file := FileAccess.open(QUEST_DATA_PATH, FileAccess.READ)
		if file != null:
			var parsed: Variant = JSON.parse_string(file.get_as_text())
			if parsed is Dictionary:
				var parsed_dict := parsed as Dictionary
				var quest_value: Variant = parsed_dict.get("quests", {})
				if quest_value is Dictionary:
					return (quest_value as Dictionary).duplicate(true)
	push_warning("QuestRegistry: using fallback quest definitions.")
	return _fallback_quests()

static func _fallback_quests() -> Dictionary:
	return {
		"lost_token": {
			"id": "lost_token",
			"title": "Recover the Lost Token",
			"owner": "Mira",
			"location": "ArcadeHub",
			"summary": "Play Cabinet 07 and bring the Lost Token back to Mira.",
			"details": "Mira says Cabinet 07 has the Lost Token. Recover it, then return to the ticket counter.",
			"minigame": "Rockbyte Duel",
			"required": true,
			"starts_after": "story_started",
			"completion_dialogue": [
				{"speaker": "Mira", "text": "You brought it back."},
				{"speaker": "Mira", "text": "That token used to be just a prize."},
				{"speaker": "Mira", "text": "Then it became proof that part of you could still return."},
			],
			"memory_signal_after": "Uneasy",
		},
		"truth_filter": {
			"id": "truth_filter",
			"title": "Truth Filter",
			"owner": "Mr. Byte",
			"location": "Cabinet Row",
			"summary": "Meet Mr. Byte in Cabinet Row and open the Truth Filter.",
			"details": "The Lost Token woke a memory, but the arcade is still filtering the truth. Mr. Byte can open the Truth Filter from Cabinet Row.",
			"minigame": "Truth Filter",
			"required": true,
			"starts_after": "lost_token_quest_completed",
			"completion_dialogue": [
				{"speaker": "Mr. Byte", "text": "Truth Filter passed."},
				{"speaker": "Mr. Byte", "text": "Contradictions remain."},
				{"speaker": "Mr. Byte", "text": "That means the memory is alive enough to argue."},
			],
			"memory_signal_after": "Fractured",
		},
		"circuit_soda": {
			"id": "circuit_soda",
			"title": "Circuit Soda",
			"owner": "Vendo",
			"location": "Snack Alcove",
			"summary": "Route the fractured Memory Signal through Vendo's machine.",
			"details": "Vendo claims the player's signal is being routed through the wrong channels. Circuit Soda should stabilize the fractured signal before the staff systems will trust it.",
			"minigame": "Circuit Soda",
			"required": true,
			"starts_after": "lying_cabinets_completed",
			"completion_dialogue": [
				{"speaker": "Vendo", "text": "Signal routed."},
				{"speaker": "Vendo", "text": "You successfully became beverage-adjacent data."},
				{"speaker": "Vendo", "text": "I would offer a receipt, but the printer remembers too much."},
			],
			"memory_signal_after": "Fractured",
		},
		"maintenance_sync": {
			"id": "maintenance_sync",
			"title": "Maintenance Sync",
			"owner": "Gus",
			"location": "Maintenance Hall",
			"summary": "Stabilize the two signals needed by the Staff Door.",
			"details": "Gus says the Staff Door listens for two stable signals.",
			"minigame": "Maintenance Sync",
			"required": true,
			"starts_after": "circuit_soda_completed",
			"completion_dialogue": [
				{"speaker": "Gus", "text": "Door's listening now."},
				{"speaker": "Gus", "text": "I do not like doors that listen."},
				{"speaker": "Gus", "text": "But if it opens, part of you matched something it lost."},
			],
			"memory_signal_after": "Overloaded",
		},
		"broken_high_score": {
			"id": "broken_high_score",
			"title": "Broken High Score",
			"owner": "Roxy",
			"location": "Cabinet Row",
			"summary": "Restore a corrupted high-score record.",
			"details": "The score claims the target is 9999, but the display is broken. The real record may be much smaller and much stranger.",
			"minigame": "Broken High Score",
			"required": false,
			"starts_after": "rockbyte_duel_completed",
			"completion_dialogue": [
				{"speaker": "Roxy", "text": "Huh. Your score came back."},
				{"speaker": "Roxy", "text": "That usually does not happen after a reset."},
			],
			"memory_signal_after": "No Change",
		},
		"prize_counter_secret": {
			"id": "prize_counter_secret",
			"title": "Prize Sort",
			"owner": "Pip",
			"location": "Prize Corner",
			"summary": "Arrange three prize labels by memory state.",
			"details": "Pip says the prize labels remember an order: Ticket Stub, Lost Token, then Blank Employee Badge.",
			"minigame": "Prize Sort",
			"required": false,
			"starts_after": "lying_cabinets_completed",
			"completion_dialogue": [
				{"speaker": "Pip", "text": "Prizes remember hands."},
				{"speaker": "Pip", "text": "Yours feel familiar."},
			],
			"memory_signal_after": "No Change",
		},
	}
