class_name TalariInstructor
extends Node

# Presentation-only authored NPC routine for the first-hour Talari instructor.
# The routine never owns progression, collision, tutorial completion, or player input.

@export var attention_range := 9.0
@export var patrol_radius := 1.65
@export var patrol_speed := 0.42
@export var turn_speed := 2.6

var body: Node3D
var observer: Node3D
var origin := Vector3.ZERO
var _phase := 0.0
var _initialized := false

func setup(character_body: Node3D, player_observer: Node3D) -> void:
	body = character_body
	observer = player_observer
	origin = body.position
	_phase = 0.0
	_initialized = true

func _process(delta: float) -> void:
	if not _initialized or not is_instance_valid(body) or not is_instance_valid(observer):
		return
	_phase += delta * patrol_speed
	var planar_distance := Vector2(body.global_position.x - observer.global_position.x, body.global_position.z - observer.global_position.z).length()
	if planar_distance <= attention_range:
		_face_observer(delta)
		body.position = body.position.lerp(origin, clampf(delta * 2.0, 0.0, 1.0))
	else:
		_patrol(delta)

func _face_observer(delta: float) -> void:
	var offset := observer.global_position - body.global_position
	offset.y = 0.0
	if offset.length_squared() < 0.0001:
		return
	var target_yaw := atan2(-offset.x, -offset.z)
	body.rotation.y = lerp_angle(body.rotation.y, target_yaw, clampf(delta * turn_speed, 0.0, 1.0))

func _patrol(delta: float) -> void:
	var offset := Vector3(cos(_phase) * patrol_radius, 0.0, sin(_phase * 0.72) * patrol_radius * 0.55)
	var target := origin + offset
	var motion := target - body.position
	if motion.length_squared() > 0.0001:
		var target_yaw := atan2(-motion.x, -motion.z)
		body.rotation.y = lerp_angle(body.rotation.y, target_yaw, clampf(delta * turn_speed * 0.65, 0.0, 1.0))
	body.position = body.position.lerp(target, clampf(delta * 0.8, 0.0, 1.0))
