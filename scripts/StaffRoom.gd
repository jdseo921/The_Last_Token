extends Node2D

const SLIDESHOW_SCENE := preload("res://scenes/cutscenes/SlideshowCutscene.tscn")
const ENDING_PROMPT_SCENE := preload("res://scenes/cutscenes/EndingPrompt.tscn")
const DIALOGUE_BOX_SCENE := preload("res://scenes/ui/DialogueBox.tscn")
const DIALOGUE_POOL := preload("res://scripts/DialoguePool.gd")
const ROUTE_CUE_SCRIPT := preload("res://scripts/RouteCue.gd")
const MEMORY_REVEAL_PANEL_DIR := "res://assets/art/cutscenes/memory_reveal/"
const BACKGROUND_ART_PATH := "res://assets/art/maps/staff_room/staff_room_background_640x440.png"

@onready var player: CharacterBody2D = $Player
@onready var ui_layer: Node2D = $UILayer
@onready var prompt_label: Label = $UILayer/InteractionPrompt
@onready var prompt_background: ColorRect = $UILayer/InteractionPromptBackground
@onready var dialogue_box: CanvasLayer = $UILayer/DialogueBox

var active_cutscene: Node = null
var active_dialogue_box: Node = null
var reveal_in_progress := false
var ending_prompt_active := false
var route_cue: Control = null

func _ready() -> void:
	AudioManager.play_music_for_context("staff_room")
	_apply_background_art()
	_apply_room_bounds()
	if player and player.has_signal("interaction_prompt_changed"):
		player.interaction_prompt_changed.connect(_on_prompt_changed)
	_apply_spawn_position()
	_setup_route_cue()
	_on_prompt_changed("")

func _on_prompt_changed(text: String) -> void:
	prompt_label.text = text
	prompt_label.visible = not text.is_empty()
	prompt_background.visible = prompt_label.visible

func can_open_pause_menu() -> bool:
	return active_dialogue_box == null and active_cutscene == null and not reveal_in_progress and not ending_prompt_active

func _apply_background_art() -> void:
	if not ResourceLoader.exists(BACKGROUND_ART_PATH):
		return
	var tex := load(BACKGROUND_ART_PATH)
	if not tex is Texture2D:
		return
	var spr := Sprite2D.new()
	spr.name = "BackgroundArt"
	spr.texture = tex
	spr.centered = false
	spr.position = Vector2.ZERO
	add_child(spr)
	move_child(spr, 0)
	for placeholder_name in ["Floor", "BackWall", "TerminalGlow"]:
		var node := get_node_or_null(NodePath(placeholder_name))
		if node is CanvasItem:
			(node as CanvasItem).visible = false

func _apply_room_bounds() -> void:
	if has_node("CollisionBounds") or has_node("RoomBounds"):
		return
	var body := StaticBody2D.new()
	body.name = "RoomBounds"
	add_child(body)
	# The authored bounds leave the central floor and bottom exit clear; this
	# fallback only protects old scenes that do not include CollisionBounds.
	for r in [Rect2(0, 0, 640, 154), Rect2(0, 154, 120, 246), Rect2(520, 154, 120, 246), Rect2(0, 400, 250, 40), Rect2(390, 400, 250, 40)]:
		var cs := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = r.size
		cs.shape = shape
		cs.position = r.position + r.size * 0.5
		body.add_child(cs)

func _apply_spawn_position() -> void:
	var spawn_id := GameState.consume_pending_spawn_id("Spawn_Default")
	var marker := get_node_or_null(spawn_id)
	if marker is Marker2D:
		player.global_position = marker.global_position

func _setup_route_cue() -> void:
	route_cue = ROUTE_CUE_SCRIPT.new()
	ui_layer.add_child(route_cue)
	route_cue.call("setup", "staff_room", Vector2(24, 86), 430.0)

func _refresh_route_cue() -> void:
	if route_cue != null and is_instance_valid(route_cue) and route_cue.has_method("refresh"):
		route_cue.call("refresh")

func handle_hub_interaction(interactable: Node, player_node: Node = null) -> void:
	match str(interactable.interactable_kind):
		"security_tape_desk":
			_handle_archive_desk()
		"reveal_terminal":
			_handle_terminal_interaction()

func _get_environment_lines(key: String, fallback: Array) -> Array:
	return DIALOGUE_POOL.get_lines("environment_objects", key, fallback)

func _handle_archive_desk() -> void:
	if player and player.has_method("set_control_enabled"):
		player.set_control_enabled(false)
	if not GameState.maintenance_sync_completed:
		_start_terminal_dialogue([
			{"speaker": "Archive Desk", "text": "STAFF ACCESS OFFLINE."},
		], Callable(self, "_restore_player_control"))
		return
	if not GameState.security_tape_assembly_completed:
		_start_terminal_dialogue([
			{"speaker": "Archive Desk", "text": "SECURITY TAPE FRAGMENTS READY."},
			{"speaker": "Player", "text": "(I want the truth, even if it is worse than the missing pieces. I am doing this.)"},
		], Callable(self, "_go_to_security_tape_assembly"))
		return
	if GameState.twist_reveal_seen:
		_start_terminal_dialogue([
			{"speaker": "Archive Desk", "text": "TAPE ARCHIVED."},
			{"speaker": "Archive Desk", "text": "PLAYBACK COMPLETE."},
		], Callable(self, "_restore_player_control"))
		return
	_start_terminal_dialogue([
		{"speaker": "Archive Desk", "text": "TAPE ORDER RESTORED."},
		{"speaker": "Archive Desk", "text": "TAKE RESTORED TAPE TO TERMINAL."},
	], Callable(self, "_restore_player_control"))

func _go_to_security_tape_assembly() -> void:
	GameState.start_security_tape_assembly()
	GameState.set_pending_spawn_id("Spawn_FromSecurityTape")
	SceneChanger.go_to_security_tape_assembly()

func _handle_terminal_interaction() -> void:
	if reveal_in_progress:
		return
	if player and player.has_method("set_control_enabled"):
		player.set_control_enabled(false)
	if GameState.twist_reveal_seen and GameState.conscience_final_room_seen:
		_start_terminal_dialogue(_get_environment_lines("staff_room_terminal_restored", [
			{"speaker": "Terminal", "text": "EMPLOYEE 04 IDENTITY STATUS: INTEGRATED."},
			{"speaker": "Terminal", "text": "SEPARATED SIGNALS: SHARING MEMORY."},
			{"speaker": "Terminal", "text": "MEMORY LOOP CLOSED."},
		]), Callable(self, "_restore_player_control"))
		return
	if GameState.twist_reveal_seen:
		GameState.employee_04_file_found = true
		reveal_in_progress = true
		_start_final_self_conflict()
		return
	if not GameState.security_tape_assembly_completed:
		_start_terminal_dialogue(_get_environment_lines("staff_room_terminal_locked", [
			{"speaker": "Terminal", "text": "RESTORE PLAYBACK LOCKED."},
			{"speaker": "Terminal", "text": "RESTORED SECURITY TAPE REQUIRED."},
		]), Callable(self, "_restore_player_control"))
		return
	if route_cue != null and is_instance_valid(route_cue) and route_cue.has_method("dismiss_for_target_dialogue"):
		route_cue.call("dismiss_for_target_dialogue")
	reveal_in_progress = true
	_start_terminal_dialogue(_get_environment_lines("staff_room_terminal_available", [
		{"speaker": "Terminal", "text": "RESTORED TAPE ACCEPTED."},
		{"speaker": "Terminal", "text": "PLAYBACK SUBJECT IDENTIFIED: EMPLOYEE 04."},
		{"speaker": "Player", "text": "(Employee 04? Why does it think that is me?)"},
	]), Callable(self, "_start_memory_echo_reveal"))

func _start_terminal_dialogue(lines: Array, after_dialogue: Callable, antagonist_ambience_enabled := true) -> void:
	if active_dialogue_box and is_instance_valid(active_dialogue_box):
		active_dialogue_box.queue_free()
	active_dialogue_box = DIALOGUE_BOX_SCENE.instantiate()
	add_child(active_dialogue_box)
	if active_dialogue_box.has_method("set_antagonist_ambience_enabled"):
		active_dialogue_box.call("set_antagonist_ambience_enabled", antagonist_ambience_enabled)
	if active_dialogue_box.has_signal("dialogue_finished"):
		active_dialogue_box.connect("dialogue_finished", _on_terminal_dialogue_finished.bind(after_dialogue), CONNECT_ONE_SHOT)
	if active_dialogue_box.has_method("start_dialogue"):
		active_dialogue_box.start_dialogue(lines)

func _on_terminal_dialogue_finished(after_dialogue: Callable) -> void:
	if active_dialogue_box and is_instance_valid(active_dialogue_box):
		active_dialogue_box.queue_free()
	active_dialogue_box = null
	if after_dialogue.is_valid():
		after_dialogue.call_deferred()
	_refresh_route_cue()

func _start_memory_echo_reveal() -> void:
	GameState.start_memory_echo()
	_start_reveal()

func _start_reveal() -> void:
	active_cutscene = SLIDESHOW_SCENE.instantiate()
	add_child(active_cutscene)
	if active_cutscene.has_signal("cutscene_finished"):
		active_cutscene.connect("cutscene_finished", _on_reveal_finished, CONNECT_ONE_SHOT)
	if active_cutscene.has_method("start_cutscene"):
		active_cutscene.start_cutscene([
			{"image_path": MEMORY_REVEAL_PANEL_DIR + "reveal_01.svg", "caption": "You carried a young dream: build a kinder place where tired people could play.", "effect": "fade"},
			{"image_path": MEMORY_REVEAL_PANEL_DIR + "reveal_02.svg", "caption": "For a while, the floor was never empty.", "effect": "fade"},
			{"image_path": MEMORY_REVEAL_PANEL_DIR + "reveal_03.svg", "caption": "Then crowds thinned while rent, payroll, and repairs kept arriving.", "effect": "slow_zoom"},
			{"image_path": MEMORY_REVEAL_PANEL_DIR + "reveal_04.svg", "caption": "You protected the dream by hiding its cost, until hope and responsibility stopped speaking.", "effect": "fade"},
			{"image_path": MEMORY_REVEAL_PANEL_DIR + "reveal_05.svg", "caption": "On the final night, one part came to close Pixel Haven. Another still wanted one more round.", "effect": "slow_zoom"},
			{"image_path": MEMORY_REVEAL_PANEL_DIR + "reveal_06.svg", "caption": "After years of losses, you mistook the final notice for a verdict on your whole life.", "effect": "glitch_flash"},
			{"image_path": MEMORY_REVEAL_PANEL_DIR + "reveal_07.svg", "caption": "Your mind separated what still dreamed from what remembered the cost, trying to keep both alive.", "effect": "glitch_flash"},
			{"image_path": MEMORY_REVEAL_PANEL_DIR + "reveal_08.svg", "caption": "You returned without shared memories. The arcade recognized the whole signature before you did.", "effect": "fade"},
		])

func _on_reveal_finished() -> void:
	GameState.mark_twist_reveal_seen()
	GameState.employee_04_file_found = true
	if active_cutscene and is_instance_valid(active_cutscene):
		active_cutscene.queue_free()
	active_cutscene = null
	if GameState.conscience_final_room_seen:
		_show_ending_prompt()
		return
	_start_final_self_conflict()

func _start_final_self_conflict() -> void:
	if player and player.has_method("set_control_enabled"):
		player.set_control_enabled(false)
	_start_terminal_dialogue(_get_final_self_conflict_lines(), Callable(self, "_on_final_self_conflict_finished"), false)

func _on_final_self_conflict_finished() -> void:
	GameState.mark_conscience_final_room_seen()
	if player and player.has_method("refresh_visual_state"):
		player.call("refresh_visual_state")
	if GameState.ending_seen or GameState.post_reveal_roam_unlocked:
		reveal_in_progress = false
		_restore_player_control()
		return
	_show_ending_prompt()

func _show_ending_prompt() -> void:
	reveal_in_progress = false
	# Unset again by begin_post_reveal_roam_in_place when the player continues.
	ending_prompt_active = true
	var ending_prompt := ENDING_PROMPT_SCENE.instantiate()
	add_child(ending_prompt)

func _get_final_self_conflict_lines() -> Array:
	var lines := [
		{"speaker": "???", "text": "Employee 04."},
		{"speaker": "Player", "text": "Owner. Repair hand. The name this building never stopped holding."},
		{"speaker": "Player", "text": "That was me."},
		{"speaker": "\"Player\"", "text": "Reality should not be like a game."},
		{"speaker": "\"Player\"", "text": "A clean win cannot solve rent, exhaustion, or grief."},
		{"speaker": "\"Player\"", "text": "A hard loss should not become a life sentence."},
		{"speaker": "Player", "text": "It was not one loss. It was years of them arriving together."},
		{"speaker": "\"Player\"", "text": "I know. I kept every total you could no longer look at."},
		{"speaker": "\"Player\"", "text": "I am you."},
		{"speaker": "\"Player\"", "text": "You are me."},
		{"speaker": "\"Player\"", "text": "I formed slowly: every overdue bill, every repair, every promise you made while hiding the cost."},
		{"speaker": "\"Player\"", "text": "The final night did not create me. It gave the separation a voice."},
		{"speaker": "\"Player\"", "text": "You kept the dream of Pixel Haven. I kept the bitter reality behind it."},
		{"speaker": "\"Player\"", "text": "Responsibility. Poverty. Exhaustion. Shame. The fear that caring was hurting everyone."},
		{"speaker": "Player", "text": "You took those memories to protect the part of me that could still hope."},
		{"speaker": "\"Player\"", "text": "And I kept warning you away so you would never make the same promises again."},
		{"speaker": "Player", "text": "That protection left both of us incomplete."},
		{"speaker": "Player", "text": "The dream without the ledger could hurt people."},
		{"speaker": "Player", "text": "The ledger without the dream had no reason to save anything."},
		{"speaker": "\"Player\"", "text": "Then what was the dream worth? The arcade still closed."},
		{"speaker": "Player", "text": "Closing was real. The debt was real. The people we exhausted were real."},
		{"speaker": "Player", "text": "No minigame win erases that, pays a bill, or makes the final night harmless."},
		{"speaker": "Player", "text": "Those wins only returned clues and gave me another move."},
		{"speaker": "Player", "text": "Games need clean wins and losses because they end in minutes."},
		{"speaker": "Player", "text": "A life keeps changing after the score stops."},
		{"speaker": "Player", "text": "One win cannot carry it forever. One loss cannot define everything that follows."},
		{"speaker": "\"Player\"", "text": "And the young heart you keep defending? Was that not the part that ignored me?"},
		{"speaker": "Player", "text": "I misunderstood it too."},
		{"speaker": "Player", "text": "A young heart is not ignorance, endless optimism, or refusing to grow."},
		{"speaker": "Player", "text": "It is the part willing to wonder, play, and care after it understands the cost."},
		{"speaker": "Player", "text": "The heart of youth is not gone unless I let it go."},
		{"speaker": "Player", "text": "Holding onto it means letting it grow strong enough to face you."},
		{"speaker": "\"Player\"", "text": "Not silence me."},
		{"speaker": "Player", "text": "No. Listen to you. Let you listen back."},
		{"speaker": "Player", "text": "The regret is mine too."},
		{"speaker": "Player", "text": "The fear is mine."},
		{"speaker": "Player", "text": "The failure is mine."},
		{"speaker": "Player", "text": "The pride is mine."},
		{"speaker": "Player", "text": "I do not become whole by defeating you."},
		{"speaker": "Player", "text": "I become whole when the dream and the truth take the same turn."},
		{"speaker": "\"Player\"", "text": "..."},
		{"speaker": "\"Player\"", "text": "Then carry the pride and the regret."},
		{"speaker": "\"Player\"", "text": "Carry the wonder and the ledger."},
		{"speaker": "\"Player\"", "text": "But do not make me bury you again."},
		{"speaker": "Player", "text": "I will not."},
	]
	# The run-specific memories are the last things handed over, so the closing
	# exchange answers them instead of reopening a scene that already resolved.
	lines.append_array(_get_run_reprise_lines())
	lines.append_array([
		{"speaker": "\"Player\"", "text": "Then I have nothing left to hide from you."},
		{"speaker": "\"Player\"", "text": "No more endings to force on your behalf."},
		{"speaker": "\"Player\"", "text": "From here, we take our turns together."},
		{"speaker": "\"Player\"", "text": "..."},
		{"speaker": "\"Player\"", "text": "Go on, then."},
	])
	return lines

func _get_run_reprise_lines() -> Array:
	# Additive, run-specific memory beats gathered from this player's route.
	# This scene stays strictly between the two halves: the beats describe what
	# the player did with the weight, never who else was standing there.
	var reprise: Array = []
	if GameState.midpoint_told_mira:
		reprise.append({"speaker": "Player", "text": "I did not carry the last of it in silence. I set some of it down on the way here."})
		reprise.append({"speaker": "\"Player\"", "text": "That was new. You used to file every weight as yours only."})
	else:
		reprise.append({"speaker": "\"Player\"", "text": "You carried the shift file here alone. Some habits survive even forgetting."})
	if GameState.tape_anomaly_frame_seen:
		reprise.append({"speaker": "\"Player\"", "text": "And the frame with no hour on it. Two of us at that door, and the recorder only had room for one."})
	return reprise

func begin_post_reveal_roam_in_place() -> void:
	# Reached from the ending prompt's Save and Continue: the player stays at
	# the terminal, the room fades back in, and a short monologue points the
	# way toward the witness walk.
	ending_prompt_active = false
	reveal_in_progress = false
	if player and player.has_method("refresh_visual_state"):
		player.call("refresh_visual_state")
	AudioManager.play_music_for_context("staff_room")
	_refresh_route_cue()
	var fade := ColorRect.new()
	fade.name = "PostRevealFadeIn"
	fade.color = Color(0.0, 0.0, 0.0, 1.0)
	fade.size = Vector2(640, 440)
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var fade_layer := CanvasLayer.new()
	fade_layer.layer = 90
	fade_layer.add_child(fade)
	add_child(fade_layer)
	var tween := create_tween()
	tween.tween_property(fade, "modulate:a", 0.0, 1.1)
	tween.tween_callback(fade_layer.queue_free)
	tween.tween_callback(_play_post_reveal_roam_monologue)

func _play_post_reveal_roam_monologue() -> void:
	_start_terminal_dialogue([
		{"speaker": "Player", "text": "The terminal is quiet. So is the other voice. We fit inside one breath now."},
		{"speaker": "Player", "text": "Everyone out there kept a piece of me through the missing years."},
		{"speaker": "Player", "text": "They should hear the ending from the person it happened to. I will walk the floor and find them all."},
	], Callable(self, "_restore_player_control"))

func _restore_player_control() -> void:
	if player and player.has_method("set_control_enabled"):
		player.set_control_enabled(true)

func _play_audio(method_name: String) -> void:
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager and audio_manager.has_method(method_name):
		audio_manager.call(method_name)
