extends Node

const CONSCIENCE_ENCOUNTER_SCENE := preload("res://scenes/cutscenes/ConscienceEncounter.tscn")

var active_encounter: Node = null

func is_encounter_active() -> bool:
	return active_encounter != null and is_instance_valid(active_encounter)

func maybe_start_encounter(parent: Node, encounter_id: String, after: Callable = Callable()) -> bool:
	if parent == null or not is_instance_valid(parent):
		return false
	if is_encounter_active():
		return false
	if not _should_trigger(encounter_id):
		return false
	var lines := get_encounter_lines(encounter_id)
	if lines.is_empty():
		return false
	var player := _find_player(parent)
	active_encounter = CONSCIENCE_ENCOUNTER_SCENE.instantiate()
	parent.add_child(active_encounter)
	if active_encounter.has_method("set_controlled_player"):
		active_encounter.call("set_controlled_player", player)
	if active_encounter.has_signal("encounter_finished"):
		active_encounter.connect("encounter_finished", _on_encounter_finished.bind(after, parent), CONNECT_ONE_SHOT)
	if active_encounter.has_method("start_encounter"):
		active_encounter.call("start_encounter", encounter_id, lines)
	return true

func get_encounter_lines(encounter_id: String) -> Array:
	match encounter_id:
		"after_truth_filter":
			return [
				{"speaker": "???", "text": "You should not have returned.", "effect": "glitch"},
				{"speaker": "???", "text": "Did you really think this arcade would see any light after your decision?"},
				{"speaker": "???", "text": "The machines remember what you tried to bury.", "effect": "shake"},
				{"speaker": "???", "text": "Keep playing. You always were better at games than consequences.", "effect": "glitch"},
			]
		"after_circuit_soda":
			return [
				{"speaker": "???", "text": "You routed yourself through a vending machine and called it progress.", "effect": "glitch"},
				{"speaker": "???", "text": "That is what you always did."},
				{"speaker": "???", "text": "Take something broken."},
				{"speaker": "???", "text": "Put a label on it."},
				{"speaker": "???", "text": "Hope the people using it never see the wires.", "effect": "shake"},
			]
		"after_lost_shift_file":
			return [
				{"speaker": "???", "text": "Employee number.", "effect": "silent", "pause": 0.25},
				{"speaker": "???", "text": "There. Part of it finally crawled back."},
				{"speaker": "???", "text": "Mira remembered the counter."},
				{"speaker": "???", "text": "Gus remembered the door."},
				{"speaker": "???", "text": "Mr. Byte remembered the record."},
				{"speaker": "???", "text": "And you?", "effect": "glitch"},
				{"speaker": "???", "text": "You remembered only enough to keep walking."},
			]
		"after_final_night_walk":
			return [
				{"speaker": "???", "text": "You walked the route."},
				{"speaker": "???", "text": "Counter dark."},
				{"speaker": "???", "text": "Cabinet awake."},
				{"speaker": "???", "text": "Back hall open."},
				{"speaker": "???", "text": "Two signals in one door.", "effect": "glitch"},
				{"speaker": "???", "text": "Still pretending the second signal is someone else?"},
				{"speaker": "???", "text": "Fine."},
				{"speaker": "???", "text": "One more echo, then.", "effect": "silent", "pause": 0.2},
			]
		_:
			return []

func _should_trigger(encounter_id: String) -> bool:
	if GameState.is_conscience_encounter_seen(encounter_id):
		return false
	match encounter_id:
		"after_truth_filter":
			return GameState.lying_cabinets_completed and not GameState.twist_reveal_seen
		"after_circuit_soda":
			return GameState.circuit_soda_completed and not GameState.twist_reveal_seen
		"after_lost_shift_file":
			return GameState.lost_shift_file_completed and not GameState.twist_reveal_seen
		"after_final_night_walk":
			return GameState.final_night_walk_completed and not GameState.twist_reveal_seen
		_:
			return false

func _on_encounter_finished(finished_encounter_id: String, after: Callable, parent: Node) -> void:
	_mark_seen(finished_encounter_id)
	active_encounter = null
	_refresh_player_visual(parent)
	if after.is_valid():
		after.call_deferred()

func _mark_seen(encounter_id: String) -> void:
	GameState.mark_conscience_encounter_seen(encounter_id)

func _find_player(root: Node) -> Node:
	if root == null:
		return null
	if root is CharacterBody2D and root.has_method("set_control_enabled"):
		return root
	for child in root.get_children():
		var player := _find_player(child)
		if player != null:
			return player
	return null

func _refresh_player_visual(parent: Node) -> void:
	var player := _find_player(parent)
	if player != null and player.has_method("refresh_visual_state"):
		player.call("refresh_visual_state")
