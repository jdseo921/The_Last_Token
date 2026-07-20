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
				{"speaker": "???", "text": "Truth Filter passed.", "effect": "glitch"},
				{"speaker": "???", "text": "The cabinets are not cheering. They know a correct answer is only one clean record."},
				{"speaker": "???", "text": "One impulse reaches for the bright buttons. Another counts what every light costs."},
				{"speaker": "???", "text": "The woman at the counter feels that distance in you and blames the late hour."},
				{"speaker": "???", "text": "She is closer than she knows.", "effect": "glitch"},
				{"speaker": "???", "text": "You call the second answer hesitation. I call it remembering the price.", "effect": "shake"},
			]
		"after_circuit_soda":
			return [
				{"speaker": "???", "text": "Signal routed.", "effect": "glitch"},
				{"speaker": "???", "text": "Labels help machines behave. They do not decide what is inside the can."},
				{"speaker": "???", "text": "The vending machine caught a second current checking every cutoff valve."},
				{"speaker": "???", "text": "It logged that current as a fault. It was trying to keep the line from bursting.", "effect": "glitch"},
				{"speaker": "???", "text": "Every time you move toward the lights, something in you checks the nearest exit."},
				{"speaker": "???", "text": "Do you think that warning hates the dream... or remembers what the dream cost?", "effect": "shake"},
			]
		"after_lost_shift_file":
			return []
		"after_final_night_walk":
			return [
				{"speaker": "???", "text": "You walked the route. Counter dark. Cabinet awake. Back hall open."},
				{"speaker": "???", "text": "Two signals in one door. One kept the dream. One kept the cost."},
				{"speaker": "???", "text": "You have spent this whole night asking which one you are."},
				{"speaker": "???", "text": "The staff never stopped seeing one person. They only saw that you no longer knew what they knew.", "effect": "glitch"},
				{"speaker": "???", "text": "I did not appear in one instant. Every bill you hid, every fear you swallowed, taught me how to speak."},
				{"speaker": "???", "text": "The last night only made the separation impossible to ignore."},
				{"speaker": "???", "text": "One more echo, and you will have to look at who.", "effect": "shake"},
				{"speaker": "???", "text": "I am not going to make it easy.", "effect": "silent", "pause": 0.2},
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
			return false
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
