extends Node2D

const SLIDESHOW_SCENE := preload("res://scenes/cutscenes/SlideshowCutscene.tscn")
const ENDING_PROMPT_SCENE := preload("res://scenes/cutscenes/EndingPrompt.tscn")
const DIALOGUE_BOX_SCENE := preload("res://scenes/ui/DialogueBox.tscn")
const DIALOGUE_POOL := preload("res://scripts/DialoguePool.gd")
const MEMORY_REVEAL_PANEL_DIR := "res://assets/art/cutscenes/memory_reveal/"
const BACKGROUND_ART_PATH := "res://assets/art/maps/staff_room/staff_room_background_640x440.png"

@onready var player: CharacterBody2D = $Player
@onready var prompt_label: Label = $InteractionPrompt
@onready var return_button: Button = $Panel/ReturnButton

var active_cutscene: Node = null
var active_dialogue_box: Node = null
var reveal_in_progress := false

func _ready() -> void:
	AudioManager.play_music_for_context("staff_room")
	_apply_background_art()
	_apply_room_bounds()
	if player and player.has_signal("interaction_prompt_changed"):
		player.interaction_prompt_changed.connect(_on_prompt_changed)
	return_button.pressed.connect(_on_return_pressed)
	_apply_spawn_position()
	_on_prompt_changed("")

func _on_prompt_changed(text: String) -> void:
	prompt_label.text = text
	prompt_label.visible = not text.is_empty()

func can_open_pause_menu() -> bool:
	return active_dialogue_box == null and active_cutscene == null and not reveal_in_progress

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
	for placeholder_name in ["Floor", "BackWall", "TerminalGlow", "EmployeeFileVisual", "EmployeeFileLabel"]:
		var node := get_node_or_null(NodePath(placeholder_name))
		if node is CanvasItem:
			(node as CanvasItem).visible = false

func _apply_room_bounds() -> void:
	if has_node("RoomBounds"):
		return
	var body := StaticBody2D.new()
	body.name = "RoomBounds"
	add_child(body)
	for r in [Rect2(0, 0, 640, 44), Rect2(0, 404, 640, 36), Rect2(0, 0, 40, 440), Rect2(600, 0, 40, 440), Rect2(218, 58, 214, 116)]:
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

func handle_hub_interaction(interactable: Node, player_node: Node = null) -> void:
	match str(interactable.interactable_kind):
		"security_tape_desk":
			_handle_archive_desk()
		"reveal_terminal":
			_handle_terminal_interaction()
		"employee_04_file":
			_handle_employee_04_file()

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
			{"speaker": "Player", "text": "(The desk has the damaged tape. I can put its night back in order.)"},
		], Callable(self, "_go_to_security_tape_assembly"))
		return
	if not GameState.final_night_walk_completed:
		_start_terminal_dialogue([
			{"speaker": "Archive Desk", "text": "TAPE ORDER RESTORED. ROUTE TRACE AVAILABLE."},
			{"speaker": "Player", "text": "(The final night is next. I can follow it from here.)"},
		], Callable(self, "_go_to_final_night_walk"))
		return
	if not GameState.memory_echo_completed:
		_start_terminal_dialogue([
			{"speaker": "Archive Desk", "text": "MEMORY ECHO CONSOLE RESPONDING."},
			{"speaker": "Player", "text": "(One last signal is waiting in the archive.)"},
		], Callable(self, "_go_to_memory_echo"))
		return
	_start_terminal_dialogue([
		{"speaker": "Archive Desk", "text": "ARCHIVE COMPLETE. THE DRAWER IS QUIET."},
	], Callable(self, "_restore_player_control"))

func _go_to_security_tape_assembly() -> void:
	GameState.start_security_tape_assembly()
	GameState.set_pending_spawn_id("Spawn_FromSecurityTape")
	SceneChanger.go_to_security_tape_assembly()

func _go_to_final_night_walk() -> void:
	GameState.start_final_night_walk()
	GameState.set_pending_spawn_id("Spawn_FromFinalNightWalk")
	SceneChanger.go_to_final_night_walk()

func _go_to_memory_echo() -> void:
	GameState.start_memory_echo()
	GameState.set_pending_spawn_id("Spawn_FromMemoryEcho")
	SceneChanger.go_to_memory_echo()

func _handle_employee_04_file() -> void:
	if player and player.has_method("set_control_enabled"):
		player.set_control_enabled(false)
	if GameState.conscience_final_room_seen:
		GameState.employee_04_file_found = true
		_start_terminal_dialogue(_get_environment_lines("employee_04_file_integrated", [
			{"speaker": "Employee File", "text": "EMPLOYEE 04 // IDENTITY STATUS: INTEGRATED."},
			{"speaker": "Employee File", "text": "The photo is yours."},
			{"speaker": "Employee File", "text": "The file was never about someone else."},
			{"speaker": "Employee File", "text": "The regret field is no longer sealed."},
		]), Callable(self, "_restore_player_control"))
		return
	if GameState.twist_reveal_seen:
		GameState.employee_04_file_found = true
		_start_terminal_dialogue(_get_environment_lines("employee_04_file_restored", [
			{"speaker": "Employee File", "text": "EMPLOYEE 04 // MEMORY ACCESS: RECOVERED."},
			{"speaker": "Employee File", "text": "The photo is yours."},
			{"speaker": "Employee File", "text": "The file was never about someone else."},
		]), Callable(self, "_restore_player_control"))
		return
	_start_terminal_dialogue(_get_environment_lines("employee_04_file_archived", [
		{"speaker": "Employee File", "text": "EMPLOYEE 04 // MEMORY ACCESS: SEALED."},
		{"speaker": "Employee File", "text": "The photo is corrupted beyond recognition."},
	]), Callable(self, "_restore_player_control"))

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
	if not GameState.memory_echo_completed:
		_start_terminal_dialogue(_get_environment_lines("staff_room_terminal_locked", [
			{"speaker": "Terminal", "text": "RESTORE PLAYBACK LOCKED."},
			{"speaker": "Terminal", "text": "MEMORY ECHO REQUIRED."},
		]), Callable(self, "_restore_player_control"))
		return
	reveal_in_progress = true
	_start_terminal_dialogue(_get_environment_lines("staff_room_terminal_available", [
		{"speaker": "Terminal", "text": "Employee file recovered."},
		{"speaker": "Terminal", "text": "Identity signal matched."},
		{"speaker": "Terminal", "text": "Name: Employee 04."},
	]), Callable(self, "_start_reveal"))

func _start_terminal_dialogue(lines: Array, after_dialogue: Callable) -> void:
	if active_dialogue_box and is_instance_valid(active_dialogue_box):
		active_dialogue_box.queue_free()
	active_dialogue_box = DIALOGUE_BOX_SCENE.instantiate()
	add_child(active_dialogue_box)
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
	_start_terminal_dialogue(_get_final_self_conflict_lines(), Callable(self, "_on_final_self_conflict_finished"))

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
	var ending_prompt := ENDING_PROMPT_SCENE.instantiate()
	add_child(ending_prompt)

func _get_final_self_conflict_lines() -> Array:
	var lines := [
		{"speaker": "Player", "text": "Employee 04."},
		{"speaker": "Player", "text": "Owner. Repair hand. The person everyone here recognized."},
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
		{"speaker": "\"Player\"", "text": "Then I have nothing left to hide from you."},
		{"speaker": "\"Player\"", "text": "No more endings to force on your behalf."},
		{"speaker": "\"Player\"", "text": "From here, we take our turns together."},
	]
	lines.append_array(_get_run_reprise_lines())
	lines.append({"speaker": "\"Player\"", "text": "..."})
	lines.append({"speaker": "\"Player\"", "text": "Go on, then."})
	return lines

func _get_run_reprise_lines() -> Array:
	# Additive, run-specific memory beats gathered from this player's route.
	var reprise: Array = []
	if GameState.midpoint_told_mira:
		reprise.append({"speaker": "Player", "text": "Mira knew what I found before this door did. I did not walk in here alone."})
		reprise.append({"speaker": "\"Player\"", "text": "You told her. That was new. You used to file every weight as yours only."})
	else:
		reprise.append({"speaker": "\"Player\"", "text": "You carried the shift file here alone. Some habits survive even forgetting."})
	if GameState.ssr_secret_cache_found:
		reprise.append({"speaker": "\"Player\"", "text": "You found the spares you once labeled for the night shift. 'Take what you need.' You finally did."})
	if GameState.fnw_secret_echo_found:
		reprise.append({"speaker": "\"Player\"", "text": "And the frame no camera was meant to keep. The bow tie. You always fixed it before lights out."})
	return reprise

func _restore_player_control() -> void:
	if player and player.has_method("set_control_enabled"):
		player.set_control_enabled(true)

func _on_return_pressed() -> void:
	_play_audio("play_ui_confirm")
	SceneChanger.go_to_arcade_hub()

func _play_audio(method_name: String) -> void:
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager and audio_manager.has_method(method_name):
		audio_manager.call(method_name)
