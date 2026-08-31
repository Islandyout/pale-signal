class_name ShipController
extends CharacterBody3D

signal throttle_changed(value: float)
signal launched
signal crossed_atmosphere
signal touchdown(vertical_speed: float, lateral_speed: float, safe: bool)
signal nav_state_changed(state: String)
signal fuel_changed(value: float, maximum: float)
signal hull_changed(value: float, maximum: float)

@export var max_forward_thrust := 28.0
@export var max_vtol_thrust := 22.0
@export var steering_rate := 0.9
@export var roll_rate := 1.0
@export var atmosphere_ceiling := 520.0
@export var gravity_strength := 9.0
@export var max_fuel := 1400.0
@export var fuel_burn_rate := 1.15
@export var max_hull := 100.0

var enabled := false
var throttle := 0.0
var landed := true
var nav_enabled := false
var nav_target := Vector3(0, 540, -780)
var nav_state := "MANUAL"
var fuel := 1400.0
var hull := 100.0
var surface_query: Callable
var _space_announced := false
var _ship_camera_pivot: Node3D
var camera: Camera3D
var _look_yaw := 0.0
var _look_pitch := -0.12

func _ready() -> void:
	fuel = max_fuel
	hull = max_hull
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
		apply_camera_look(event.relative)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func apply_camera_look(delta_pixels: Vector2) -> void:
	if not enabled: return
	_look_yaw -= delta_pixels.x * 0.002
	_look_pitch = clamp(_look_pitch - delta_pixels.y * 0.002, -0.8, 0.55)
	_ship_camera_pivot.rotation = Vector3(_look_pitch, _look_yaw, 0.0)

func _physics_process(delta: float) -> void:
	if not enabled: return
	var surface := _surface_state()
	var atmosphere := float(surface.get("atmosphere", 0.0))
	var local_gravity := float(surface.get("gravity", 0.0))
	var old_throttle := throttle
	if Input.is_action_pressed("throttle_up"): throttle = min(1.0, throttle + 0.55 * delta)
	if Input.is_action_pressed("throttle_down"): throttle = max(0.0, throttle - 0.65 * delta)
	if Input.is_action_pressed("brake"): throttle = move_toward(throttle, 0.0, 1.8 * delta)
	if fuel <= 0.0: throttle = 0.0
	if absf(throttle - old_throttle) > 0.001: throttle_changed.emit(throttle)

	var yaw := Input.get_axis("yaw_left", "yaw_right")
	var pitch := Input.get_axis("pitch_down", "pitch_up")
	var roll := Input.get_axis("roll_left", "roll_right")
	rotate_object_local(Vector3.UP, -yaw * steering_rate * delta)
	rotate_object_local(Vector3.RIGHT, pitch * steering_rate * delta)
	rotate_object_local(Vector3.FORWARD, -roll * roll_rate * delta)

	var forward := -global_transform.basis.z.normalized()
	var vtol_factor := clampf(1.0 - velocity.length() / 42.0, 0.0, 1.0)
	var thrust := forward * max_forward_thrust * throttle
	# VTOL lift is independent of nose pitch, preventing forced vertical pitch during launch.
	thrust += Vector3.UP * max_vtol_thrust * throttle * vtol_factor * atmosphere
	velocity += thrust * delta
	velocity.y -= local_gravity * (0.22 + 0.78 * atmosphere) * delta
	velocity *= maxf(0.0, 1.0 - (0.19 * atmosphere * delta))

	if throttle > 0.01 and fuel > 0.0:
		fuel = maxf(0.0, fuel - fuel_burn_rate * throttle * delta)
		fuel_changed.emit(fuel, max_fuel)

	if nav_enabled: _update_nav()
	if landed and throttle > 0.42 and velocity.y > 0.35:
		landed = false
		launched.emit()

	var before_y := velocity.y
	var before_lateral := Vector2(velocity.x, velocity.z).length()
	move_and_slide()
	var valid_surface := bool(surface.get("valid", false))
	var ground_y := float(surface.get("height", 0.0)) + 1.0
	if valid_surface and global_position.y <= ground_y and velocity.y <= 0.0:
		global_position.y = ground_y
		var safe := absf(before_y) <= 9.5 and before_lateral <= 8.0
		if not landed:
			landed = true
			throttle = 0.0
			if not safe:
				var damage := maxf(0.0, absf(before_y) - 8.0) * 1.7 + maxf(0.0, before_lateral - 6.0) * 1.2
				hull = maxf(0.0, hull - damage)
				hull_changed.emit(hull, max_hull)
			touchdown.emit(absf(before_y), before_lateral, safe)
		velocity = Vector3.ZERO

	var altitude := global_position.y - float(surface.get("height", 0.0)) if valid_surface else atmosphere_ceiling + 1.0
	if not _space_announced and (not valid_surface or altitude >= atmosphere_ceiling):
		_space_announced = true
		crossed_atmosphere.emit()
	elif _space_announced and valid_surface and altitude < atmosphere_ceiling * 0.85:
		_space_announced = false

	if Input.is_action_just_pressed("nav_toggle"):
		nav_enabled = not nav_enabled
		_update_nav()

func _surface_state() -> Dictionary:
	if surface_query.is_valid():
		var result = surface_query.call(global_position)
		if result is Dictionary: return result
	return {"valid":false, "world":"", "height":0.0, "atmosphere":0.0, "gravity":0.0}

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

func add_fuel(amount: float) -> void:
	fuel = minf(max_fuel, fuel + maxf(0.0, amount))
	fuel_changed.emit(fuel, max_fuel)

func repair_hull(amount: float) -> void:
	hull = minf(max_hull, hull + maxf(0.0, amount))
	hull_changed.emit(hull, max_hull)

func apply_campaign_upgrades(upgrades: Dictionary) -> void:
	max_forward_thrust = 28.0 * (1.22 if int(upgrades.get("thrust", 0)) > 0 else 1.0)
	max_vtol_thrust = 22.0 * (1.12 if int(upgrades.get("thrust", 0)) > 0 else 1.0)
	steering_rate = 0.9 * (1.25 if int(upgrades.get("rcs", 0)) > 0 else 1.0)
	roll_rate = 1.0 * (1.25 if int(upgrades.get("rcs", 0)) > 0 else 1.0)
	var old_max_fuel := max_fuel
	max_fuel = 1900.0 if int(upgrades.get("fuel", 0)) > 0 else 1400.0
	if max_fuel > old_max_fuel: fuel += max_fuel - old_max_fuel
	fuel = minf(fuel, max_fuel)
	fuel_changed.emit(fuel, max_fuel)
