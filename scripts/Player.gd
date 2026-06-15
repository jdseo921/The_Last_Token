extends CharacterBody2D

signal interaction_prompt_changed(text: String)

@export var speed: float = 120.0

var can_control := true
var nearby_interactables: Array = []
var active_dialogue_box: Node = null

@onready var interaction_area: Area2D = $InteractionArea

func _ready() -> void:
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
	move_and_slide()

	if Input.is_action_just_pressed("interact"):
		_interact_with_nearest()

func set_control_enabled(enabled: bool) -> void:
	can_control = enabled
	if not enabled:
		velocity = Vector2.ZERO
	_set_prompt()

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
		target.interact(self)

func _set_prompt() -> void:
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
