class_name EVAController
extends CharacterBody3D

signal moved(distance: float)
signal looked(delta_degrees: float)
signal interact_requested

@export var walk_speed := 5.2
@export var acceleration := 18.0
@export var mouse_sensitivity := 0.0022
@export var gravity := 18.0

var enabled := true
var movement_enabled := true
var total_distance := 0.0
var total_look_degrees := 0.0
var _head: Node3D
var camera: Camera3D
var _last_position := Vector3.ZERO

func _ready() -> void:
	add_to_group("eva_controller")
	collision_layer = 1
	collision_mask = 1
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.38
	capsule.height = 1.8
	shape.shape = capsule
	add_child(shape)
	_head = Node3D.new()
	_head.position.y = 0.72
	add_child(_head)
	camera = Camera3D.new()
	camera.fov = 76.0
	_head.add_child(camera)
	_last_position = global_position

func _unhandled_input(event: InputEvent) -> void:
	if not enabled: return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		apply_look(event.relative)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func apply_look(delta_pixels: Vector2) -> void:
	if not enabled: return
	rotate_y(-delta_pixels.x * mouse_sensitivity)
	_head.rotation.x = clamp(_head.rotation.x - delta_pixels.y * mouse_sensitivity, -1.35, 1.35)
	var amount := delta_pixels.length() * mouse_sensitivity * 57.2958
	total_look_degrees += amount
	looked.emit(amount)

func _physics_process(delta: float) -> void:
	if not enabled:
		velocity = Vector3.ZERO
		return
	var input := Vector2.ZERO
	if movement_enabled:
		input = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var local := Vector3(input.x, 0.0, input.y)
	var desired := global_transform.basis * local
	desired.y = 0.0
	if desired.length_squared() > 1.0: desired = desired.normalized()
	desired *= walk_speed
	velocity.x = move_toward(velocity.x, desired.x, acceleration * delta)
	velocity.z = move_toward(velocity.z, desired.z, acceleration * delta)
	if not is_on_floor(): velocity.y -= gravity * delta
	else: velocity.y = min(velocity.y, 0.0)
	move_and_slide()
	var step_distance := global_position.distance_to(_last_position)
	if step_distance > 0.0001:
		total_distance += step_distance
		moved.emit(step_distance)
	_last_position = global_position
	if Input.is_action_just_pressed("interact"): interact_requested.emit()

func set_movement_enabled(value: bool) -> void:
	movement_enabled = value
	if not value:
		velocity.x = 0.0
		velocity.z = 0.0

func set_active(value: bool) -> void:
	enabled = value
	camera.current = value
	visible = value
