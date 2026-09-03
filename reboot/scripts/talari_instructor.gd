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
	_install_authored_face_identity()
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

func _install_authored_face_identity() -> void:
	# The imported Quaternius humanoid remains an animation/scale source only.
	# This presentation-only layer gives the Talari a specific non-human face
	# language without changing skeletons, interaction, collision, or tutorial state.
	if not is_instance_valid(body) or body.has_node("TalariFaceIdentity"):
		return

	var face := Node3D.new()
	face.name = "TalariFaceIdentity"
	body.add_child(face)

	var shell := StandardMaterial3D.new()
	shell.albedo_color = Color("#6f9189")
	shell.metallic = 0.06
	shell.roughness = 0.76

	var ceramic := StandardMaterial3D.new()
	ceramic.albedo_color = Color("#d9d1b9")
	ceramic.metallic = 0.17
	ceramic.roughness = 0.46

	var sensory := StandardMaterial3D.new()
	sensory.albedo_color = Color("#8de1d4")
	sensory.emission_enabled = true
	sensory.emission = Color("#4f9e95")
	sensory.emission_energy_multiplier = 1.25
	sensory.roughness = 0.28

	# A shallow brow mask removes the stock-human facial read while preserving
	# enough open space beneath the existing cranial fan for a clear silhouette.
	var brow := MeshInstance3D.new()
	brow.name = "TalariBrowMask"
	var brow_mesh := BoxMesh.new()
	brow_mesh.size = Vector3(0.50, 0.16, 0.08)
	brow_mesh.material = ceramic
	brow.mesh = brow_mesh
	brow.position = Vector3(0.0, 1.78, -0.31)
	brow.rotation_degrees.z = -3.5
	face.add_child(brow)

	# Paired lateral sensory nodes replace a conventional two-eye focal point.
	# Their unequal heights reinforce the asymmetry already established by the
	# survey mantle and cranial sensory fan.
	for side in [-1.0, 1.0]:
		var node := MeshInstance3D.new()
		node.name = "SensoryNodeL" if side < 0.0 else "SensoryNodeR"
		var node_mesh := SphereMesh.new()
		node_mesh.radius = 0.055 if side < 0.0 else 0.045
		node_mesh.height = node_mesh.radius * 2.0
		node_mesh.material = sensory
		node.mesh = node_mesh
		node.position = Vector3(0.20 * side, 1.79 + (0.035 if side < 0.0 else -0.015), -0.365)
		face.add_child(node)

	# Split jaw rails make the lower face read as a resonant/sensory structure
	# rather than a human mouth. They remain deliberately restrained in scale.
	for side in [-1.0, 1.0]:
		var rail := MeshInstance3D.new()
		rail.name = "JawRailL" if side < 0.0 else "JawRailR"
		var rail_mesh := BoxMesh.new()
		rail_mesh.size = Vector3(0.075, 0.28, 0.065)
		rail_mesh.material = shell
		rail.mesh = rail_mesh
		rail.position = Vector3(0.135 * side, 1.57, -0.29)
		rail.rotation_degrees.z = 9.0 * side
		face.add_child(rail)

	var resonator := MeshInstance3D.new()
	resonator.name = "ThroatResonator"
	var resonator_mesh := CylinderMesh.new()
	resonator_mesh.top_radius = 0.075
	resonator_mesh.bottom_radius = 0.095
	resonator_mesh.height = 0.22
	resonator_mesh.material = sensory
	resonator.mesh = resonator_mesh
	resonator.position = Vector3(0.02, 1.42, -0.27)
	resonator.rotation_degrees.x = 90.0
	face.add_child(resonator)

	# Unequal temple vanes bridge the authored face into the existing cranial fan.
	for i in range(2):
		var vane := MeshInstance3D.new()
		vane.name = "TempleVane%d" % i
		var vane_mesh := BoxMesh.new()
		vane_mesh.size = Vector3(0.06, 0.24 + float(i) * 0.08, 0.16)
		vane_mesh.material = shell
		vane.mesh = vane_mesh
		vane.position = Vector3(-0.27 + float(i) * 0.53, 1.88 + float(i) * 0.04, -0.08)
		vane.rotation_degrees = Vector3(-8.0, 0.0, -18.0 + float(i) * 31.0)
		face.add_child(vane)
