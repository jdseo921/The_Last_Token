extends RefCounted
class_name DialoguePool

const DIALOGUE_ROOT := "res://data/dialogue/"
const CHARACTER_FILES := {
	"mira": "mira.json",
	"gus": "gus.json",
	"vendo": "vendo.json",
	"mr_byte": "mr_byte.json",
	"cabinet_07": "cabinet_07.json",
	"roxy": "roxy.json",
	"pip": "pip.json",
	"staff_door": "staff_door.json",
	"environment_objects": "environment_objects.json",
}

static var _cache: Dictionary = {}
static var _sequential_counters: Dictionary = {}
static var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
static var _rng_ready := false

static func get_lines(character_id: String, key: String, fallback: Array = []) -> Array:
	var sets: Array = _get_dialogue_sets(character_id, key)
	if sets.is_empty():
		return fallback.duplicate(true)
	var first_set: Variant = sets[0]
	if first_set is Array:
		return (first_set as Array).duplicate(true)
	return fallback.duplicate(true)

static func get_random_set(character_id: String, key: String, fallback: Array = []) -> Array:
	var sets: Array = _get_dialogue_sets(character_id, key)
	if sets.is_empty():
		return fallback.duplicate(true)
	_randomize_once()
	var index := _rng.randi_range(0, sets.size() - 1)
	var selected_set: Variant = sets[index]
	if selected_set is Array:
		return (selected_set as Array).duplicate(true)
	return fallback.duplicate(true)

static func get_sequential_set(character_id: String, key: String, counter_key: String, fallback: Array = []) -> Array:
	var sets: Array = _get_dialogue_sets(character_id, key)
	if sets.is_empty():
		return fallback.duplicate(true)
	var safe_counter_key := "%s:%s:%s" % [_normalize_character_id(character_id), key, counter_key]
	var counter_value: Variant = _sequential_counters.get(safe_counter_key, 0)
	var counter := 0
	if counter_value is int:
		counter = int(counter_value)
	var index := counter % sets.size()
	_sequential_counters[safe_counter_key] = counter + 1
	var selected_set: Variant = sets[index]
	if selected_set is Array:
		return (selected_set as Array).duplicate(true)
	return fallback.duplicate(true)

static func _get_dialogue_sets(character_id: String, key: String) -> Array:
	if key.is_empty():
		return []
	var data: Dictionary = _get_dialogue_data(character_id)
	var sets_value: Variant = data.get("sets", {})
	if not sets_value is Dictionary:
		return []
	var sets_dict := sets_value as Dictionary
	if not sets_dict.has(key):
		return []
	var raw_value: Variant = sets_dict.get(key)
	return _normalize_sets(raw_value)

static func _get_dialogue_data(character_id: String) -> Dictionary:
	var normalized_id := _normalize_character_id(character_id)
	if normalized_id.is_empty():
		return {}
	if _cache.has(normalized_id):
		var cached_value: Variant = _cache.get(normalized_id, {})
		if cached_value is Dictionary:
			return cached_value as Dictionary
		return {}
	var loaded_data: Dictionary = _load_dialogue_file(normalized_id)
	_cache[normalized_id] = loaded_data
	return loaded_data

static func _load_dialogue_file(character_id: String) -> Dictionary:
	var path := _get_dialogue_path(character_id)
	if path.is_empty():
		return {}
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var text := file.get_as_text()
	var parsed: Variant = JSON.parse_string(text)
	if not parsed is Dictionary:
		return {}
	var parsed_dict := parsed as Dictionary
	var sets_value: Variant = parsed_dict.get("sets", {})
	if not sets_value is Dictionary:
		return {}
	return parsed_dict.duplicate(true)

static func _get_dialogue_path(character_id: String) -> String:
	var file_name_value: Variant = CHARACTER_FILES.get(character_id, "")
	var file_name := str(file_name_value)
	if file_name.is_empty():
		return ""
	return DIALOGUE_ROOT + file_name

static func _normalize_sets(raw_value: Variant) -> Array:
	var normalized_sets: Array = []
	if not raw_value is Array:
		return normalized_sets
	var raw_array := raw_value as Array
	if raw_array.is_empty():
		return normalized_sets
	if _looks_like_line_set(raw_array):
		var line_set := _normalize_line_set(raw_array)
		if not line_set.is_empty():
			normalized_sets.append(line_set)
		return normalized_sets
	for raw_set_value: Variant in raw_array:
		if not raw_set_value is Array:
			continue
		var raw_set := raw_set_value as Array
		var normalized_line_set := _normalize_line_set(raw_set)
		if not normalized_line_set.is_empty():
			normalized_sets.append(normalized_line_set)
	return normalized_sets

static func _looks_like_line_set(raw_array: Array) -> bool:
	if raw_array.is_empty():
		return false
	var first_value: Variant = raw_array[0]
	return first_value is Dictionary

static func _normalize_line_set(raw_lines: Array) -> Array:
	var normalized_lines: Array = []
	for raw_line_value: Variant in raw_lines:
		if not raw_line_value is Dictionary:
			continue
		var raw_line := raw_line_value as Dictionary
		normalized_lines.append(raw_line.duplicate(true))
	return normalized_lines

static func _normalize_character_id(character_id: String) -> String:
	return character_id.strip_edges().to_lower()

static func _randomize_once() -> void:
	if _rng_ready:
		return
	_rng.randomize()
	_rng_ready = true
