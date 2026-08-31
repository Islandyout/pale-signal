class_name ShipController
extends CharacterBody3D

signal throttle_changed(value: float)
signal launched
signal crossed_atmosphere
signal touchdown(vertical_speed: float, lateral_speed: float, safe: bool)
signal nav_state_changed(state: String)

@export var max_forward_thrust := 28.0
@export var max_vtol_thrust := 22.0
@export var steering_rate := 0.9
@export var roll_rate := 1.0
@export var atmosphere_ceiling := 520.0
@export var gravity_strength := 9.0

var enabled := false
var throttle := 0.0
var landed := true
var nav_enabled := false
var nav_target := Vector3(0, 540, -780)
var nav_state := "MANUAL"
var _space_announced := false
var _ship_camera_pivot: Node3D
var camera: Camera3D
var _look_yaw := 0.0
var _look_pitch := -0.12

func _ready() -> void:
	collision_layer = 1
	collision_mask = 1
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(2.2, 1.1, 4.2)
	shape.shape = box
	add_child(shape)
	_ship_camera_pivot = Node3D.new()
	_ship_camera_pivot.position = Vector3(0, 1.6, 0)
	add_child(_ship_camera_pivot)
	camera = Camera3D.new()
	camera.position = Vector3(0, 2.2, 8.5)
	camera.fov = 72.0
	_ship_camera_pivot.add_child(camera)

func _unhandled_input(event: InputEvent) -> void:
	if not enabled: return
	# Camera look is deliberately independent of ship steering.
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_look_yaw -= event.relative.x * 0.002
		_look_pitch = clamp(_look_pitch - event.relative.y * 0.002, -0.8, 0.55)
		_ship_camera_pivot.rotation = Vector3(_look_pitch, _look_yaw, 0.0)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	if not enabled: return
	var old_throttle := throttle
	if Input.is_action_pressed("throttle_up"): throttle = min(1.0, throttle + 0.55 * delta)
	if Input.is_action_pressed("throttle_down"): throttle = max(0.0, throttle - 0.65 * delta)
	if Input.is_action_pressed("brake"): throttle = move_toward(throttle, 0.0, 1.8 * delta)
	if absf(throttle - old_throttle) > 0.001: throttle_changed.emit(throttle)

	var yaw := Input.get_axis("yaw_left", "yaw_right")
	var pitch := Input.get_axis("pitch_down", "pitch_up")
	var roll := Input.get_axis("roll_left", "roll_right")
	rotate_object_local(Vector3.UP, -yaw * steering_rate * delta)
	rotate_object_local(Vector3.RIGHT, pitch * steering_rate * delta)
	rotate_object_local(Vector3.FORWARD, -roll * roll_rate * delta)

	var altitude := maxf(0.0, global_position.y)
	var atmosphere := clampf(1.0 - altitude / atmosphere_ceiling, 0.0, 1.0)
	var forward := -global_transform.basis.z.normalized()
	var vtol_factor := clampf(1.0 - velocity.length() / 42.0, 0.0, 1.0)
	var thrust := forward * max_forward_thrust * throttle
	# VTOL lift is independent of nose pitch, preventing forced vertical pitch during launch.
	thrust += Vector3.UP * max_vtol_thrust * throttle * vtol_factor * atmosphere
	velocity += thrust * delta
	velocity.y -= gravity_strength * (0.22 + 0.78 * atmosphere) * delta
	velocity *= 1.0 - (0.19 * atmosphere * delta)

	if nav_enabled: _update_nav()
	if landed and throttle > 0.42 and velocity.y > 0.35:
		landed = false
		launched.emit()

	var before_y := velocity.y
	var before_lateral := Vector2(velocity.x, velocity.z).length()
	move_and_slide()
	if global_position.y <= 1.0 and velocity.y <= 0.0:
		global_position.y = 1.0
		var safe := absf(before_y) <= 9.5 and before_lateral <= 8.0
		if not landed:
			landed = true
			throttle = 0.0
			touchdown.emit(absf(before_y), before_lateral, safe)
		velocity = Vector3.ZERO

	if not _space_announced and altitude >= atmosphere_ceiling:
		_space_announced = true
		crossed_atmosphere.emit()
	elif _space_announced and altitude < atmosphere_ceiling * 0.85:
		_space_announced = false

	if Input.is_action_just_pressed("nav_toggle"):
		nav_enabled = not nav_enabled
		_update_nav()

func _update_nav() -> void:
	if not nav_enabled:
		_set_nav_state("MANUAL")
		return
	var to_target := nav_target - global_position
	var distance := to_target.length()
	var forward := -global_transform.basis.z.normalized()
	var align := forward.dot(to_target.normalized()) if distance > 0.1 else 1.0
	var closing := velocity.dot(to_target.normalized()) if distance > 0.1 else 0.0
	if align < 0.90: _set_nav_state("TURN")
	elif distance > 260.0 and closing < 38.0: _set_nav_state("BURN")
	elif distance > 170.0: _set_nav_state("COAST")
	elif closing > 15.0: _set_nav_state("BRAKE")
	else: _set_nav_state("APPROACH")

func _set_nav_state(value: String) -> void:
	if nav_state == value: return
	nav_state = value
	nav_state_changed.emit(value)

func set_active(value: bool) -> void:
	enabled = value
	camera.current = value
	visible = true
