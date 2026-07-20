extends RefCounted

const QUEST_DATA_PATH := "res://data/quests.json"

static var _quests_loaded := false
static var _quests: Dictionary = {}


static func get_quest(id: String) -> Dictionary:
	var quests := _get_quests()
	if quests.has(id) and quests[id] is Dictionary:
		return (quests[id] as Dictionary).duplicate(true)
	return {}


static func _get_quests() -> Dictionary:
	if not _quests_loaded:
		_quests = _load_quests()
		_quests_loaded = true
	return _quests


static func _load_quests() -> Dictionary:
	if not ResourceLoader.exists(QUEST_DATA_PATH):
		push_error("QuestRegistry: missing %s" % QUEST_DATA_PATH)
		return {}
	var file := FileAccess.open(QUEST_DATA_PATH, FileAccess.READ)
	if file == null:
		push_error("QuestRegistry: could not open %s" % QUEST_DATA_PATH)
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		push_error("QuestRegistry: invalid quest JSON")
		return {}
	var quest_value: Variant = (parsed as Dictionary).get("quests", {})
	if not quest_value is Dictionary:
		push_error("QuestRegistry: quest JSON has no quests dictionary")
		return {}
	return (quest_value as Dictionary).duplicate(true)
