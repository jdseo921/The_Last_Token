extends CharacterBody2D

signal interaction_prompt_changed(text: String)

@export var speed: float = 120.0

const INTERACT_REENABLE_LOCKOUT_MSEC := 140
const PLAYER_SPRITE_PATH := "res://assets/art/characters/player/player_gameplay.png"
const PLAYER_GLITCH_SPRITE_PATH := "res://assets/art/characters/player/player_gameplay_glitch.png"
const PLAYER_WALK_SHEET_PATH := "res://assets/art/characters/player/player_walk_8dir_sheet.png"
const PLAYER_WALK_GLITCH_SHEET_PATH := "res://assets/art/characters/player/player_walk_8dir_glitch_sheet.png"
const WALK_FRAME_SIZE := Vector2i(32, 32)
const PLAYER_VISUAL_SCALE := Vector2(1.1, 1.1)
const WALK_DIRECTIONS := ["south", "southeast", "east", "northeast", "north", "northwest", "west", "southwest"]
const OUTLINE_OFFSETS := [
	Vector2(-1, 0),
	Vector2(1, 0),
	Vector2(0, -1),
	Vector2(0, 1),
]

var can_control := true
var nearby_interactables: Array = []
var active_dialogue_box: Node = null
var interact_locked_until_msec := 0
var movement_visual_frame := 0
var facing_direction := "south"
var outline_sprites: Array[AnimatedSprite2D] = []

@onready var interaction_area: Area2D = $InteractionArea
@onready var body_visual: Polygon2D = $BodyVisual
@onready var facing_dot: Polygon2D = $FacingDot
@onready var sprite: Sprite2D = $Sprite
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite
@onready var outline_root: Node2D = $OutlineRoot

func _ready() -> void:
	_apply_visual_scale()
	_apply_sprite_art()
	if interaction_area and interaction_area.has_signal("area_entered"):
		interaction_area.area_entered.connect(_on_interaction_area_area_entered)
		interaction_area.area_exited.connect(_on_interaction_area_area_exited)
		interaction_area.body_entered.connect(_on_interaction_area_body_entered)
		interaction_area.body_exited.connect(_on_interaction_area_body_exited)
	_set_prompt()

func _physics_process(delta: float) -> void:
	if not can_control:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_vector.normalized() * speed
	_update_movement_visual(input_vector)
	move_and_slide()

	if Input.is_action_just_pressed("interact") and Time.get_ticks_msec() >= interact_locked_until_msec:
		_interact_with_nearest()

func set_control_enabled(enabled: bool) -> void:
	var was_control_enabled := can_control
	can_control = enabled
	if not enabled:
		velocity = Vector2.ZERO
		_update_movement_visual(Vector2.ZERO)
	if enabled and not was_control_enabled:
		interact_locked_until_msec = Time.get_ticks_msec() + INTERACT_REENABLE_LOCKOUT_MSEC
	_set_prompt()

func _apply_visual_scale() -> void:
	sprite.scale = PLAYER_VISUAL_SCALE
	animated_sprite.scale = PLAYER_VISUAL_SCALE
	outline_root.scale = PLAYER_VISUAL_SCALE

func open_dialogue(dialogue_box: Node, lines: Array) -> void:
	active_dialogue_box = dialogue_box
	set_control_enabled(false)
	if active_dialogue_box and active_dialogue_box.has_method("start_dialogue"):
		active_dialogue_box.start_dialogue(lines)

func close_dialogue() -> void:
	active_dialogue_box = null
	set_control_enabled(true)

func _interact_with_nearest() -> void:
	if nearby_interactables.is_empty():
		return
	var target = nearby_interactables[0]
	if is_instance_valid(target) and target.has_method("interact"):
		_play_audio("play_interact")
		target.interact(self)

func _update_movement_visual(input_vector: Vector2) -> void:
	var is_moving := input_vector != Vector2.ZERO
	if is_moving:
		facing_direction = _get_direction_name(input_vector)
	if animated_sprite.visible:
		_update_sprite_animation(is_moving)
		return
	if not is_moving:
		movement_visual_frame = 0
		_get_active_visual().position = Vector2.ZERO
		if not sprite.visible:
			facing_dot.visible = true
		return
	movement_visual_frame = (movement_visual_frame + 1) % 2
	_get_active_visual().position.y = -1.0 if movement_visual_frame == 0 else 0.0
	if not sprite.visible:
		facing_dot.visible = movement_visual_frame == 0

func _apply_sprite_art() -> void:
	_setup_walk_animation()
	if animated_sprite.visible:
		body_visual.visible = false
		facing_dot.visible = false
		sprite.visible = false
		_update_outline_animation()
		return
	var sprite_path := PLAYER_GLITCH_SPRITE_PATH if GameState.post_reveal_roam_unlocked else PLAYER_SPRITE_PATH
	var texture := _load_texture_or_null(sprite_path)
	sprite.texture = texture
	sprite.visible = texture != null
	body_visual.visible = texture == null
	facing_dot.visible = texture == null
	_create_static_outline(texture)

func _setup_walk_animation() -> void:
	animated_sprite.visible = false
	animated_sprite.sprite_frames = null
	var sheet_path := PLAYER_WALK_GLITCH_SHEET_PATH if GameState.post_reveal_roam_unlocked else PLAYER_WALK_SHEET_PATH
	var texture := _load_texture_or_null(sheet_path)
	if texture == null:
		return
	var frames := SpriteFrames.new()
	for direction_index in range(WALK_DIRECTIONS.size()):
		var direction_name: String = WALK_DIRECTIONS[direction_index]
		var idle_name := "idle_%s" % direction_name
		var walk_name := "walk_%s" % direction_name
		frames.add_animation(idle_name)
		frames.set_animation_loop(idle_name, true)
		frames.set_animation_speed(idle_name, 1.0)
		frames.add_animation(walk_name)
		frames.set_animation_loop(walk_name, true)
		frames.set_animation_speed(walk_name, 6.0)
		for frame_index in range(2):
			var atlas := AtlasTexture.new()
			atlas.atlas = texture
			atlas.region = Rect2(direction_index * WALK_FRAME_SIZE.x, frame_index * WALK_FRAME_SIZE.y, WALK_FRAME_SIZE.x, WALK_FRAME_SIZE.y)
			if frame_index == 0:
				frames.add_frame(idle_name, atlas)
			frames.add_frame(walk_name, atlas)
	animated_sprite.sprite_frames = frames
	animated_sprite.visible = true
	animated_sprite.play("idle_south")
	_create_animated_outline(frames)

func _update_sprite_animation(is_moving: bool) -> void:
	var animation_name := "%s_%s" % ["walk" if is_moving else "idle", facing_direction]
	if animated_sprite.animation != animation_name:
		animated_sprite.play(animation_name)
	_update_outline_animation()

func _create_animated_outline(frames: SpriteFrames) -> void:
	_clear_outline()
	for offset in OUTLINE_OFFSETS:
		var outline := AnimatedSprite2D.new()
		outline.sprite_frames = frames
		outline.position = offset
		outline.modulate = Color(0.02, 0.04, 0.06, 0.95)
		outline.z_index = -1
		outline_root.add_child(outline)
		outline_sprites.append(outline)
	_update_outline_animation()

func _create_static_outline(texture: Texture2D) -> void:
	_clear_outline()
	if texture == null:
		return
	for offset in OUTLINE_OFFSETS:
		var outline := Sprite2D.new()
		outline.texture = texture
		outline.position = offset
		outline.modulate = Color(0.02, 0.04, 0.06, 0.95)
		outline.z_index = -1
		outline_root.add_child(outline)

func _update_outline_animation() -> void:
	for outline in outline_sprites:
		outline.animation = animated_sprite.animation
		outline.frame = animated_sprite.frame
		if not outline.is_playing():
			outline.play(animated_sprite.animation)

func _clear_outline() -> void:
	outline_sprites.clear()
	for child in outline_root.get_children():
		child.queue_free()

func _get_direction_name(input_vector: Vector2) -> String:
	var angle := input_vector.angle()
	if angle >= -PI * 0.125 and angle < PI * 0.125:
		return "east"
	if angle >= PI * 0.125 and angle < PI * 0.375:
		return "southeast"
	if angle >= PI * 0.375 and angle < PI * 0.625:
		return "south"
	if angle >= PI * 0.625 and angle < PI * 0.875:
		return "southwest"
	if angle >= PI * 0.875 or angle < -PI * 0.875:
		return "west"
	if angle >= -PI * 0.875 and angle < -PI * 0.625:
		return "northwest"
	if angle >= -PI * 0.625 and angle < -PI * 0.375:
		return "north"
	return "northeast"

func _load_texture_or_null(path: String) -> Texture2D:
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	var resource := load(path)
	if resource is Texture2D:
		return resource
	return null

func _get_active_visual() -> Node2D:
	if sprite.visible:
		return sprite
	return body_visual

func _set_prompt() -> void:
	if not can_control:
		interaction_prompt_changed.emit("")
		return
	if nearby_interactables.is_empty():
		interaction_prompt_changed.emit("")
	else:
		interaction_prompt_changed.emit("Press E to interact")

func _register_interactable(interactable: Node) -> void:
	if interactable not in nearby_interactables:
		nearby_interactables.append(interactable)
	_set_prompt()

func _unregister_interactable(interactable: Node) -> void:
	nearby_interactables.erase(interactable)
	_set_prompt()

func _on_interaction_area_area_entered(area: Area2D) -> void:
	if area.has_method("interact"):
		_register_interactable(area)

func _on_interaction_area_area_exited(area: Area2D) -> void:
	_unregister_interactable(area)

func _on_interaction_area_body_entered(body: Node) -> void:
	if body.has_method("interact"):
		_register_interactable(body)

func _on_interaction_area_body_exited(body: Node) -> void:
	_unregister_interactable(body)

func _play_audio(method_name: String) -> void:
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager and audio_manager.has_method(method_name):
		audio_manager.call(method_name)
