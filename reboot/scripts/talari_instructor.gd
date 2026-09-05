class_name TalariInstructor
extends Node

signal attention_state_changed(state: String)
signal field_commentary(title: String, detail: String)

# Presentation-only authored NPC routine for the first-hour Talari instructor.
# The routine never owns progression, collision, tutorial completion, or player input.

@export var attention_range := 9.0
@export var engagement_range := 4.4
@export var personal_space_radius := 2.15
@export var patrol_radius := 1.65
@export var patrol_speed := 0.42
@export var turn_speed := 2.6

var body: Node3D
var observer: Node3D
var origin := Vector3.ZERO
var attention_state := "PATROL"
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
	var state := attention_state_for_distance(planar_distance)
	_set_attention_state(state)
	match state:
		"PERSONAL_SPACE":
			_face_observer(delta)
			_yield_personal_space(delta)
		"ENGAGED":
			_face_observer(delta)
			body.position = body.position.lerp(origin, clampf(delta * 2.0, 0.0, 1.0))
		"OBSERVING":
			_face_observer(delta)
			body.position = body.position.lerp(origin, clampf(delta * 1.2, 0.0, 1.0))
		_:
			_patrol(delta)
	_update_sensory_read(delta)

func attention_state_for_distance(distance: float) -> String:
	if distance <= personal_space_radius:
		return "PERSONAL_SPACE"
	if distance <= engagement_range:
		return "ENGAGED"
	if distance <= attention_range:
		return "OBSERVING"
	return "PATROL"

func observe_evidence_pass(layer_name: String, _finding: String, pass_number: int, total_passes: int) -> void:
	# The instructor contributes a competing historical reading without becoming
	# a dialogue gate or progression owner. The player's physical reconstruction
	# remains authoritative evidence; this commentary makes the dispute visible.
	var detail := evidence_response_for_layer(layer_name)
	if detail.is_empty():
		return
	field_commentary.emit(
		"TALARI FIELD RESPONSE · %d / %d" % [pass_number, maxi(total_passes, 1)],
		detail
	)

func evidence_response_for_layer(layer_name: String) -> String:
	match layer_name:
		"LOAD PATH":
			return "Talari archive: ground failure can preserve a load path. The instructor cautions that intact structure alone does not prove deliberate restraint."
		"RESTRAINT TRACE":
			return "Talari archive: the restraint pattern belongs to an evacuation retrofit. Your cross-joint scars agree it was added later, but not why."
		"ALTERATION SEQUENCE":
			return "Talari archive and your chronology now disagree. The site was altered before the final storm; the instructor records both accounts instead of declaring either complete."
		_:
			return ""

func _set_attention_state(value: String) -> void:
	if attention_state == value:
		return
	attention_state = value
	attention_state_changed.emit(value)

func _face_observer(delta: float) -> void:
	var offset := observer.global_position - body.global_position
	offset.y = 0.0
	if offset.length_squared() < 0.0001:
		return
	var target_yaw := atan2(-offset.x, -offset.z)
	body.rotation.y = lerp_angle(body.rotation.y, target_yaw, clampf(delta * turn_speed, 0.0, 1.0))

func _yield_personal_space(delta: float) -> void:
	# Talari acknowledge the player without behaving like a static quest marker.
	# If crowded, the instructor yields a small bounded step while maintaining
	# eye/sensory orientation. This is presentation only and cannot move the NPC
	# outside its authored survey station or advance any mechanic.
	var away := body.global_position - observer.global_position
	away.y = 0.0
	if away.length_squared() < 0.0001:
		away = Vector3.RIGHT
	else:
		away = away.normalized()
	var local_target := origin + away * minf(patrol_radius, 0.75)
	body.position = body.position.lerp(local_target, clampf(delta * 1.75, 0.0, 1.0))

func _patrol(delta: float) -> void:
	var offset := Vector3(cos(_phase) * patrol_radius, 0.0, sin(_phase * 0.72) * patrol_radius * 0.55)
	var target := origin + offset
	var motion := target - body.position
	if motion.length_squared() > 0.0001:
		var target_yaw := atan2(-motion.x, -motion.z)
		body.rotation.y = lerp_angle(body.rotation.y, target_yaw, clampf(delta * turn_speed * 0.65, 0.0, 1.0))
	body.position = body.position.lerp(target, clampf(delta * 0.8, 0.0, 1.0))

func _update_sensory_read(_delta: float) -> void:
	# A restrained throat-resonator pulse communicates attention state at a glance
	# without adding HUD, dialogue, quest, or interaction subsystems.
	if not is_instance_valid(body):
		return
	var resonator := body.get_node_or_null("TalariFaceIdentity/ThroatResonator") as MeshInstance3D
	if resonator == null:
		return
	var amplitude := 0.012
	var rate := 1.8
	match attention_state:
		"PERSONAL_SPACE":
			amplitude = 0.055
			rate = 5.0
		"ENGAGED":
			amplitude = 0.040
			rate = 3.6
		"OBSERVING":
			amplitude = 0.025
			rate = 2.5
	var pulse := 1.0 + sin(_phase * rate) * amplitude
	resonator.scale = Vector3(pulse, pulse, pulse)

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
