extends Node2D

const ASSET_PATHS := preload("res://scripts/AssetPaths.gd")
const PLAYER_IDLE_SHEET_PATH := "res://assets/art/characters/player/player_idle_sheet.png"
const MIRA_IDLE_SHEET_PATH := "res://assets/art/characters/mira/mira_idle_sheet.png"
const GUS_IDLE_SHEET_PATH := "res://assets/art/characters/gus/gus_idle_sheet.png"
const VENDO_IDLE_SHEET_PATH := "res://assets/art/characters/vendo/vendo_idle_sheet.png"
const MR_BYTE_IDLE_SHEET_PATH := "res://assets/art/characters/mr_byte/mr_byte_idle_sheet.png"
const PORTRAIT_MIRA_WORRIED := "res://assets/art/portraits/mira/mira_worried.png"
const PORTRAIT_GUS_ANNOYED := "res://assets/art/portraits/gus/gus_annoyed.png"
const PORTRAIT_CABINET_07_SCREEN := "res://assets/art/portraits/mr_byte/cabinet_07_screen.png"
const PORTRAIT_PLAYER_NEUTRAL := "res://assets/art/portraits/player/player_neutral.png"

@onready var player: CharacterBody2D = $Player
@onready var background_sprite: Sprite2D = $BackgroundLayer/BackgroundSprite
@onready var floor_layer: Node2D = $FloorLayer
@onready var wall_layer: Node2D = $WallLayer
@onready var ticket_counter_sprite: Sprite2D = $PropLayer/TicketCounterSprite
@onready var owner_portrait_sprite: Sprite2D = $PropLayer/OwnerPortraitSprite
@onready var cabinet_07_sprite: Sprite2D = $PropLayer/Cabinet07Sprite
@onready var cabinet_07_flicker_sprite: AnimatedSprite2D = $PropLayer/Cabinet07FlickerSprite
@onready var broken_cabinet_sprite: Sprite2D = $PropLayer/BrokenCabinetSprite
@onready var staff_door_sprite: Sprite2D = $PropLayer/StaffDoorSprite
@onready var memory_terminal_sprite: Sprite2D = $PropLayer/MemoryTerminalSprite
@onready var ui_layer: Node2D = $UILayer
@onready var dialogue_box: CanvasLayer = $UILayer/DialogueBox
@onready var prompt_label: Label = $UILayer/InteractionPrompt
@onready var hint_label: Label = $UILayer/HintLabel
@onready var post_reveal_hint_label: Label = $UILayer/PostRevealHintLabel
@onready var objective_hint_label: Label = $UILayer/ObjectiveHintLabel

var save_slot_menu: Control = null
var choice_box: CanvasLayer = null
var pending_after_dialogue: Callable = Callable()
var cabinet_glow_tween: Tween = null
var player_idle_sprite: AnimatedSprite2D = null

func _ready() -> void:
	_apply_hub_art()
	_apply_player_art()
	player.interaction_prompt_changed.connect(_on_prompt_changed)
	dialogue_box.dialogue_finished.connect(_on_dialogue_finished)
	_apply_spawn_position()
	_on_prompt_changed("")
	_refresh_hint()
	_refresh_objective_hint()
	_refresh_hub_art_states()

func _apply_spawn_position() -> void:
	if GameState.has_arcade_return_position:
		player.global_position = GameState.arcade_return_position
		GameState.clear_arcade_return_position()
		return
	if GameState.post_reveal_roam_unlocked:
		player.global_position = Vector2(178, 246)
		return
	if GameState.rockbyte_duel_completed and not GameState.twist_reveal_seen:
		player.global_position = Vector2(430, 204)

func _on_prompt_changed(text: String) -> void:
	prompt_label.text = text
	prompt_label.visible = not text.is_empty()

func start_dialogue(lines: Array, after_dialogue: Callable = Callable()) -> void:
	pending_after_dialogue = after_dialogue
	if player and player.has_method("set_control_enabled"):
		player.set_control_enabled(false)
	dialogue_box.start_dialogue(lines)
	_refresh_hint()
	_refresh_objective_hint()
	_refresh_hub_art_states()

func _on_dialogue_finished() -> void:
	if pending_after_dialogue.is_valid():
		pending_after_dialogue.call()
		pending_after_dialogue = Callable()
	if player and player.has_method("set_control_enabled") and not _choice_box_is_open():
		player.set_control_enabled(true)
	_refresh_hint()
	_refresh_objective_hint()
	_refresh_hub_art_states()

func _choice_box_is_open() -> bool:
	return choice_box != null and is_instance_valid(choice_box) and choice_box.visible

func _refresh_hint() -> void:
	hint_label.visible = not GameState.story_started
	post_reveal_hint_label.visible = GameState.post_reveal_roam_unlocked and not _dialogue_is_active() and not _choice_box_is_open() and not _save_slot_menu_is_open()

func _refresh_objective_hint() -> void:
	objective_hint_label.text = _get_objective_hint_text()
	objective_hint_label.visible = not objective_hint_label.text.is_empty() and not _dialogue_is_active() and not _choice_box_is_open() and not _save_slot_menu_is_open()
	_refresh_hub_art_states()

func _get_objective_hint_text() -> String:
	if not GameState.story_started:
		return "Objective: Talk to Mira."
	if GameState.lost_token_quest_started and not GameState.rockbyte_duel_completed:
		return "Objective: Play Cabinet 07."
	if GameState.rockbyte_duel_completed and not GameState.lost_token_quest_completed:
		return "Objective: Return the Lost Token to Mira."
	if GameState.lost_token_quest_completed and not GameState.story_puzzle_completed:
		return "Objective: Check the Staff Door."
	if GameState.story_puzzle_completed and GameState.staff_room_unlocked and not GameState.twist_reveal_seen:
		return "Objective: Enter the Staff Room."
	if GameState.twist_reveal_seen and not GameState.post_reveal_roam_unlocked:
		return "Objective: Finish the memory."
	if GameState.post_reveal_roam_unlocked:
		return "Objective: Talk to those who remembered you."
	return ""

func _dialogue_is_active() -> bool:
	if dialogue_box == null:
		return false
	return dialogue_box.get("active") == true

func _save_slot_menu_is_open() -> bool:
	return save_slot_menu != null and is_instance_valid(save_slot_menu) and save_slot_menu.visible

func handle_hub_interaction(interactable: Node, player_node: Node = null) -> void:
	match str(interactable.interactable_kind):
		"mira":
			_handle_mira()
		"gus":
			_handle_gus()
		"vendo":
			_handle_vendo()
		"mr_byte":
			_handle_mr_byte()
		"cabinet07":
			_handle_cabinet_07()
		"memory_terminal":
			_handle_memory_terminal()
		"staff_door":
			_handle_staff_door()
		"owner_portrait":
			_handle_owner_portrait()
		"broken_cabinet":
			_handle_broken_cabinet(interactable)
		_:
			start_dialogue([{"speaker": "System", "text": "Nothing happens."}])

func _handle_mira() -> void:
	if _is_post_reveal():
		GameState.mira_post_reveal_seen = true
		start_dialogue([
			{"speaker": "Mira", "text": "You finally remembered."},
			{"speaker": "Mira", "text": "I was worried you would choose to disappear again.", "portrait": PORTRAIT_MIRA_WORRIED},
			{"speaker": "Mira", "text": "But you are still here.", "portrait": PORTRAIT_MIRA_WORRIED},
			{"speaker": "Mira", "text": "That counts for something."},
		])
		return
	if not GameState.lost_token_quest_started:
		GameState.mira_intro_seen = true
		start_dialogue([
			{"speaker": "Mira", "text": "Pixel Haven kept the lights on for you."},
			{"speaker": "Mira", "text": "You are late again."},
			{"speaker": "Player", "text": "Again?", "portrait": PORTRAIT_PLAYER_NEUTRAL},
			{"speaker": "Mira", "text": "Cabinet 07 has your Lost Token."},
			{"speaker": "Mira", "text": "Please bring it back to me."},
		], Callable(GameState, "start_lost_token_quest"))
		return
	if GameState.lost_token_quest_started and not GameState.lost_token_collected:
		start_dialogue([
			{"speaker": "Mira", "text": "Go to Cabinet 07."},
			{"speaker": "Mira", "text": "It remembers employees better than customers."},
		])
		return
	if GameState.lost_token_collected and not GameState.lost_token_quest_completed:
		start_dialogue([
			{"speaker": "Player", "text": "I found the token."},
			{"speaker": "Mira", "text": "You found it."},
			{"speaker": "Mira", "text": "I was afraid you would not.", "portrait": PORTRAIT_MIRA_WORRIED},
			{"speaker": "Mira", "text": "The Staff Door should hear you now."},
			{"speaker": "Mira", "text": "Please check it."},
		], Callable(GameState, "complete_lost_token_quest"))
		return
	start_dialogue([{"speaker": "Mira", "text": "Welcome to Pixel Haven."}])

func _handle_gus() -> void:
	if _is_post_reveal():
		GameState.gus_post_reveal_seen = true
		start_dialogue([
			{"speaker": "Gus", "text": "About time.", "portrait": PORTRAIT_GUS_ANNOYED},
			{"speaker": "Gus", "text": "I was almost out of practical hints.", "portrait": PORTRAIT_GUS_ANNOYED},
			{"speaker": "Gus", "text": "You came back anyway. Good."},
		])
		return
	if GameState.lost_token_quest_completed:
		start_dialogue([
			{"speaker": "Gus", "text": "Staff Door is humming again."},
			{"speaker": "Gus", "text": "Practical advice: do not ignore humming doors.", "portrait": PORTRAIT_GUS_ANNOYED},
		])
		return
	GameState.gus_intro_seen = true
	start_dialogue([
		{"speaker": "Gus", "text": "You again. Great.", "portrait": PORTRAIT_GUS_ANNOYED},
		{"speaker": "Gus", "text": "I just finished cleaning up the previous session."},
	])

func _handle_vendo() -> void:
	if GameState.post_reveal_roam_unlocked and GameState.vendo_memory_riddle_secret_found:
		GameState.vendo_post_reveal_seen = true
		start_dialogue([
			{"speaker": "Vendo", "text": "Turns out MEMORY COLA was not a metaphor."},
			{"speaker": "Vendo", "text": "Legally, that should have been on the label."},
		])
		return
	if _is_post_reveal():
		GameState.vendo_post_reveal_seen = true
		start_dialogue([
			{"speaker": "Vendo", "text": "Congratulations, valued stored file."},
			{"speaker": "Vendo", "text": "Your memory has been partially restored."},
			{"speaker": "Vendo", "text": "Refunds remain impossible."},
		])
		return
	if GameState.vendo_memory_riddle_secret_found:
		GameState.vendo_intro_seen = true
		start_dialogue([
			{"speaker": "Vendo", "text": "Memory Cola is sold out."},
			{"speaker": "Vendo", "text": "Mostly because you keep losing it."},
		])
		return
	if GameState.lost_token_quest_started:
		GameState.vendo_intro_seen = true
		start_dialogue([
			{"speaker": "Vendo", "text": "Cabinet 07 does not recognize customers."},
			{"speaker": "Vendo", "text": "Only employees."},
			{"speaker": "Vendo", "text": "Care for a beverage-based psychological evaluation?"},
		], Callable(self, "_open_vendo_memory_riddle"))
		return
	GameState.vendo_intro_seen = true
	start_dialogue([
		{"speaker": "Vendo", "text": "Welcome, valued almost-customer."},
		{"speaker": "Vendo", "text": "Please select a beverage or a coping mechanism."},
		{"speaker": "Vendo", "text": "Care for a beverage-based psychological evaluation?"},
	], Callable(self, "_open_vendo_memory_riddle"))

func _open_vendo_memory_riddle() -> void:
	if GameState.vendo_memory_riddle_secret_found:
		return
	if choice_box and is_instance_valid(choice_box):
		choice_box.queue_free()
	choice_box = load("res://scenes/ui/ChoiceBox.tscn").instantiate()
	ui_layer.add_child(choice_box)
	if player and player.has_method("set_control_enabled"):
		player.set_control_enabled(false)
	if choice_box.has_signal("choice_selected"):
		choice_box.connect("choice_selected", _on_vendo_riddle_choice_selected, CONNECT_ONE_SHOT)
	if choice_box.has_signal("choice_cancelled"):
		choice_box.connect("choice_cancelled", _on_vendo_riddle_choice_cancelled, CONNECT_ONE_SHOT)
	if choice_box.has_method("open_choice"):
		choice_box.open_choice("What do you lose every time you return?", [
			"STATIC SODA",
			"MEMORY COLA",
			"TOKEN TEA",
			"REGRET JUICE",
		])
	_refresh_hint()
	_refresh_objective_hint()

func _on_vendo_riddle_choice_selected(index: int) -> void:
	if choice_box and is_instance_valid(choice_box):
		choice_box.queue_free()
	choice_box = null
	if index == 1:
		GameState.vendo_memory_riddle_secret_found = true
		start_dialogue([
			{"speaker": "Vendo", "text": "Correct."},
			{"speaker": "Vendo", "text": "You lose memory."},
			{"speaker": "Vendo", "text": "I lose coins."},
			{"speaker": "Vendo", "text": "We all suffer in our own branded containers."},
		])
		return
	start_dialogue([
		{"speaker": "Vendo", "text": "Incorrect."},
		{"speaker": "Vendo", "text": "But emotionally marketable."},
		{"speaker": "Vendo", "text": "Try again after your next identity crisis."},
	])

func _on_vendo_riddle_choice_cancelled() -> void:
	if choice_box and is_instance_valid(choice_box):
		choice_box.queue_free()
	choice_box = null
	if player and player.has_method("set_control_enabled"):
		player.set_control_enabled(true)
	_refresh_hint()
	_refresh_objective_hint()

func _handle_mr_byte() -> void:
	if _is_post_reveal():
		GameState.mr_byte_post_reveal_seen = true
		GameState.employee_04_file_found = true
		start_dialogue([
			{"speaker": "Mr. Byte", "text": "Identity conflict resolved."},
			{"speaker": "Mr. Byte", "text": "Emotional cache remains unstable."},
			{"speaker": "Mr. Byte", "text": "Recommended action: talk to those who remembered you."},
		])
		return
	GameState.mr_byte_intro_seen = true
	start_dialogue([
		{"speaker": "Mr. Byte", "text": "HELP MENU LOADED."},
		{"speaker": "Mr. Byte", "text": "Tip: Mira has your first objective."},
		{"speaker": "Mr. Byte", "text": "Warning: Machines remember things."},
	])

func _handle_cabinet_07() -> void:
	if _is_post_reveal():
		start_dialogue([
			{"speaker": "Cabinet 07", "text": "EMPLOYEE 04 RESTORE STATUS: STABLE.", "portrait": PORTRAIT_CABINET_07_SCREEN},
			{"speaker": "Cabinet 07", "text": "WELCOME BACK, EMPLOYEE 04.", "portrait": PORTRAIT_CABINET_07_SCREEN},
			{"speaker": "Cabinet 07", "text": "PREVIOUS SESSION: CLOSED.", "portrait": PORTRAIT_CABINET_07_SCREEN},
			{"speaker": "Cabinet 07", "text": "CURRENT SESSION: YOURS.", "portrait": PORTRAIT_CABINET_07_SCREEN},
		])
		return
	if not GameState.lost_token_quest_started:
		GameState.cabinet07_employee_hint_seen = true
		start_dialogue([
			{"speaker": "Cabinet 07", "text": "CUSTOMER PROFILE: UNKNOWN."},
			{"speaker": "Cabinet 07", "text": "LOST TOKEN REQUIRED."},
		])
		return
	if not GameState.rockbyte_duel_completed:
		_store_arcade_return_position()
		SceneChanger.go_to_rockbyte_duel()
		return
	start_dialogue([
		{"speaker": "Cabinet 07", "text": "TOKEN ACCEPTED."},
		{"speaker": "Cabinet 07", "text": "EMPLOYEE SIGNAL PARTIAL."},
		{"speaker": "Cabinet 07", "text": "LOST TOKEN RECOVERED."},
		{"speaker": "Cabinet 07", "text": "RETURN TOKEN TO MIRA."},
	])

func _handle_memory_terminal() -> void:
	if save_slot_menu and is_instance_valid(save_slot_menu):
		save_slot_menu.queue_free()
	save_slot_menu = load("res://scenes/ui/SaveSlotMenu.tscn").instantiate()
	ui_layer.add_child(save_slot_menu)
	if player and player.has_method("set_control_enabled"):
		player.set_control_enabled(false)
	if save_slot_menu.has_signal("menu_closed"):
		save_slot_menu.menu_closed.connect(_on_save_slot_menu_closed, CONNECT_ONE_SHOT)
	if save_slot_menu.has_method("open_menu"):
		save_slot_menu.open_menu(true)
	_refresh_hint()
	_refresh_objective_hint()

func _on_save_slot_menu_closed() -> void:
	if player and player.has_method("set_control_enabled"):
		player.set_control_enabled(true)
	save_slot_menu = null
	_refresh_hint()
	_refresh_objective_hint()

func _handle_staff_door() -> void:
	if GameState.staff_room_unlocked:
		SceneChanger.go_to_staff_room()
		return
	if GameState.lost_token_quest_completed and GameState.rockbyte_duel_completed:
		_store_arcade_return_position()
		SceneChanger.go_to_sync_door_puzzle()
		return
	start_dialogue([
		{"speaker": "Staff Door", "text": "STAFF ACCESS LOCKED."},
		{"speaker": "Staff Door", "text": "MEMORY TOKEN SIGNAL MISSING."},
	])

func _handle_owner_portrait() -> void:
	if _is_post_reveal():
		GameState.owner_portrait_secret_found = true
		start_dialogue([
			{"speaker": "Owner Portrait", "text": "The scratched nameplate is readable now."},
			{"speaker": "Owner Portrait", "text": "It does not name the owner."},
			{"speaker": "Owner Portrait", "text": "It says: EMPLOYEE 04."},
		])
		return
	start_dialogue([
		{"speaker": "Owner Portrait", "text": "The frame is cracked and the nameplate is scratched blank."},
	])

func _handle_broken_cabinet(interactable: Node) -> void:
	if _is_post_reveal():
		start_dialogue([
			{"speaker": "Broken Cabinet", "text": "I remember your first quarter."},
			{"speaker": "Broken Cabinet", "text": "You looked happier then."},
			{"speaker": "Broken Cabinet", "text": "Not better. Just earlier."},
		])
		return
	interactable.broken_interaction_count += 1
	if interactable.broken_interaction_count >= 5:
		GameState.broken_cabinet_secret_found = true
		start_dialogue([{"speaker": "Broken Cabinet", "text": "STOP PRESSING E. I AM TRYING TO REMEMBER."}])
		return
	if interactable.broken_interaction_count == 3:
		start_dialogue([{"speaker": "Broken Cabinet", "text": "STILL OUT OF ORDER."}])
		return
	start_dialogue([{"speaker": "Broken Cabinet", "text": "OUT OF ORDER."}])

func _is_post_reveal() -> bool:
	return GameState.post_reveal_roam_unlocked or GameState.twist_reveal_seen

func _store_arcade_return_position() -> void:
	if player:
		GameState.set_arcade_return_position(player.global_position)

func _apply_hub_art() -> void:
	var has_background := _apply_sprite_texture(background_sprite, ASSET_PATHS.HUB_BACKGROUND_ARCADE)
	_set_children_visible(floor_layer, not has_background)
	_set_children_visible(wall_layer, not has_background)
	_apply_prop_sprite(
		ticket_counter_sprite,
		ASSET_PATHS.HUB_TICKET_COUNTER,
		[$PropLayer/TicketCounterVisual]
	)
	_apply_prop_sprite(
		memory_terminal_sprite,
		ASSET_PATHS.HUB_MEMORY_TERMINAL,
		[$PropLayer/MemoryTerminalVisual, $PropLayer/MemoryTerminalScreen]
	)
	_apply_prop_sprite(
		cabinet_07_sprite,
		ASSET_PATHS.HUB_CABINET_07_IDLE,
		[$PropLayer/Cabinet07Visual, $PropLayer/Cabinet07Screen]
	)
	var has_cabinet_flicker := _apply_animated_sprite_sheet(cabinet_07_flicker_sprite, ASSET_PATHS.HUB_CABINET_07_FLICKER_SHEET, 3, 0.18)
	if has_cabinet_flicker:
		cabinet_07_sprite.visible = false
	_apply_prop_sprite(
		broken_cabinet_sprite,
		ASSET_PATHS.HUB_BROKEN_CABINET,
		[$PropLayer/BrokenCabinetVisual, $PropLayer/BrokenCabinetScreen]
	)
	_refresh_hub_art_states()
	_start_cabinet_glow_pulse()

func _refresh_hub_art_states() -> void:
	if not is_node_ready():
		return
	var staff_door_path := ASSET_PATHS.HUB_STAFF_DOOR_OPEN if GameState.staff_room_unlocked else ASSET_PATHS.HUB_STAFF_DOOR_CLOSED
	_apply_prop_sprite(
		staff_door_sprite,
		staff_door_path,
		[$PropLayer/StaffDoorVisual, $PropLayer/StaffDoorHandle]
	)
	var owner_portrait_path := ASSET_PATHS.HUB_OWNER_PORTRAIT_EMPLOYEE04 if _is_post_reveal() else ASSET_PATHS.HUB_OWNER_PORTRAIT_BLANK
	_apply_prop_sprite(
		owner_portrait_sprite,
		owner_portrait_path,
		[$PropLayer/OwnerPortraitVisual, $PropLayer/OwnerPortraitInner]
	)

func _apply_player_art() -> void:
	if not ASSET_PATHS.exists(PLAYER_IDLE_SHEET_PATH):
		return
	player_idle_sprite = _create_idle_sheet_sprite(PLAYER_IDLE_SHEET_PATH, 2, 0.45)
	if player_idle_sprite == null:
		return
	player.add_child(player_idle_sprite)
	player_idle_sprite.position = Vector2.ZERO
	var body_visual := player.get_node_or_null("BodyVisual") as CanvasItem
	if body_visual != null:
		body_visual.visible = false
	var facing_dot := player.get_node_or_null("FacingDot") as CanvasItem
	if facing_dot != null:
		facing_dot.visible = false

func _apply_prop_sprite(sprite_node: Sprite2D, path: String, placeholders: Array) -> void:
	var loaded := _apply_sprite_texture(sprite_node, path)
	for placeholder in placeholders:
		if placeholder is CanvasItem:
			placeholder.visible = not loaded

func _apply_sprite_texture(sprite_node: Sprite2D, path: String) -> bool:
	sprite_node.visible = false
	sprite_node.texture = null
	var texture: Texture2D = ASSET_PATHS.load_texture_or_null(path)
	if texture == null:
		return false
	sprite_node.texture = texture
	sprite_node.visible = true
	return true

func _apply_animated_sprite_sheet(animated_sprite: AnimatedSprite2D, path: String, frame_count: int, frame_duration: float) -> bool:
	animated_sprite.visible = false
	animated_sprite.sprite_frames = null
	var texture: Texture2D = ASSET_PATHS.load_texture_or_null(path)
	if texture == null:
		return false
	var frame_total := maxi(frame_count, 1)
	var frame_width := maxi(int(texture.get_width() / frame_total), 1)
	var frame_height := maxi(texture.get_height(), 1)
	var frames := SpriteFrames.new()
	frames.add_animation("flicker")
	frames.set_animation_loop("flicker", true)
	frames.set_animation_speed("flicker", 1.0 / maxf(frame_duration, 0.05))
	for index in range(frame_total):
		var atlas := AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = Rect2(index * frame_width, 0, frame_width, frame_height)
		frames.add_frame("flicker", atlas)
	animated_sprite.sprite_frames = frames
	animated_sprite.animation = "flicker"
	animated_sprite.visible = true
	animated_sprite.play("flicker")
	return true

func _set_children_visible(parent_node: Node, visible: bool) -> void:
	for child in parent_node.get_children():
		if child is CanvasItem:
			child.visible = visible

func _start_cabinet_glow_pulse() -> void:
	if cabinet_glow_tween and cabinet_glow_tween.is_valid():
		cabinet_glow_tween.kill()
	if not cabinet_07_flicker_sprite.visible and not cabinet_07_sprite.visible:
		return
	var glow_target: CanvasItem = cabinet_07_flicker_sprite if cabinet_07_flicker_sprite.visible else cabinet_07_sprite
	glow_target.modulate = Color(1, 1, 1, 0.75)
	cabinet_glow_tween = create_tween()
	cabinet_glow_tween.set_loops()
	cabinet_glow_tween.tween_property(glow_target, "modulate:a", 1.0, 0.42)
	cabinet_glow_tween.tween_property(glow_target, "modulate:a", 0.45, 0.28)
	cabinet_glow_tween.tween_property(glow_target, "modulate:a", 0.8, 0.55)

func _create_idle_sheet_sprite(path: String, frame_count: int, frame_duration: float) -> AnimatedSprite2D:
	var texture: Texture2D = ASSET_PATHS.load_texture_or_null(path)
	if texture == null:
		return null
	var frame_total := maxi(frame_count, 1)
	var frame_width := maxi(int(texture.get_width() / frame_total), 1)
	var frame_height := maxi(texture.get_height(), 1)
	var frames := SpriteFrames.new()
	frames.add_animation("idle")
	frames.set_animation_loop("idle", true)
	frames.set_animation_speed("idle", 1.0 / maxf(frame_duration, 0.05))
	for index in range(frame_total):
		var atlas := AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = Rect2(index * frame_width, 0, frame_width, frame_height)
		frames.add_frame("idle", atlas)
	var animated_sprite := AnimatedSprite2D.new()
	animated_sprite.name = "OptionalIdleSprite"
	animated_sprite.sprite_frames = frames
	animated_sprite.animation = "idle"
	animated_sprite.play("idle")
	return animated_sprite
