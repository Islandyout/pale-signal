class_name WildlifeSystem
extends Node3D

# Tethys-first ecology. This system is intentionally isolated from EVA, scanner,
# tutorial, save and ship state so wildlife can add presence without fabricating
# mechanic completion or changing progression.
const GRAZER_COUNT := 5
const PLAYER_AVOID_RADIUS := 8.0
const HERD_ALERT_RADIUS := 14.0
const HERD_ALERT_GAIN := 0.82
const GRAZER_SPEED := 0.85
const TETHYS_BOUNDS := 46.0

var _grazers: Array[Dictionary] = []
var _time := 0.0

func _ready() -> void:
	_build_tethys_flat_grazers()

func _physics_process(delta: float) -> void:
	_time += delta
	var eva := get_parent().get_node_or_null("EVA") as Node3D
	var player_position := eva.global_position if eva != null else Vector3(9999.0, 0.0, 9999.0)
	for i in range(_grazers.size()):
		_update_grazer(i, delta, player_position)

func _build_tethys_flat_grazers() -> void:
	var homes := [
		Vector3(-20.0, 0.55, -24.0),
		Vector3(18.0, 0.55, -30.0),
		Vector3(-31.0, 0.55, -9.0),
		Vector3(29.0, 0.55, -12.0),
		Vector3(8.0, 0.55, -38.0),
	]
	for i in range(GRAZER_COUNT):
		# Wildlife uses the same scanner-facing Area3D contract as other field
		# subjects, but remains non-collectible and does not own tutorial state.
		var grazer := Interactable.new()
		grazer.name = "FlatGrazer%02d" % (i + 1)
		grazer.interaction_id = "wildlife|flat_grazer|%02d" % (i + 1)
		grazer.display_name = "Flat Grazer"
		grazer.requires_scan = false
		grazer.position = homes[i]

		var fallback := _make_flat_grazer_fallback(i)
		var visual := AssetLoader.instantiate_or_fallback("wildlife", fallback)
		visual.name = "Visual"
		grazer.add_child(visual)

		var collision := CollisionShape3D.new()
		collision.name = "ScannerBody"
		var shape := BoxShape3D.new()
		shape.size = Vector3(2.5, 1.15, 1.55)
		collision.shape = shape
		collision.position.y = 0.35
		grazer.add_child(collision)

		add_child(grazer)
		_grazers.append({
			"node": grazer,
			"home": homes[i],
			"phase": float(i) * 1.37,
			"fear": 0.0,
		})

func _make_flat_grazer_fallback(index: int) -> Node3D:
	# The Flat Grazer is intentionally authored from inexpensive primitives rather
	# than presented as a stock quadruped. Its silhouette language is a low armored
	# browsing disk, six weight-bearing stilts, a forward grazing rake and a lateral
	# sensory sail. This remains cheap enough for mobile while establishing species
	# identity that can later wrap a verified GLB source without changing gameplay.
	var root := Node3D.new()
	root.name = "FlatGrazerIdentity"

	var hide_mat := StandardMaterial3D.new()
	hide_mat.albedo_color = Color("#6d8f78").lightened(float(index % 3) * 0.035)
	hide_mat.roughness = 0.92

	var shell_mat := StandardMaterial3D.new()
	shell_mat.albedo_color = Color("#7e9377").lightened(float(index % 2) * 0.025)
	shell_mat.roughness = 0.86

	var fan_mat := StandardMaterial3D.new()
	fan_mat.albedo_color = Color("#a8b58b")
	fan_mat.roughness = 0.74

	var sense_mat := StandardMaterial3D.new()
	sense_mat.albedo_color = Color("#9fd2bd")
	sense_mat.emission_enabled = true
	sense_mat.emission = Color("#386f62")
	sense_mat.emission_energy_multiplier = 0.55
	sense_mat.roughness = 0.62

	var body := MeshInstance3D.new()
	body.name = "BrowsingDisk"
	var body_mesh := BoxMesh.new()
	body_mesh.size = Vector3(2.45, 0.28, 1.28)
	body_mesh.material = hide_mat
	body.mesh = body_mesh
	body.position.y = 0.40
	root.add_child(body)

	# Overlapping dorsal plates make the animal read as a naturally armored,
	# ground-hugging browser instead of a rectangular placeholder.
	for plate_index in range(3):
		var plate := MeshInstance3D.new()
		plate.name = "DorsalPlate%02d" % (plate_index + 1)
		var plate_mesh := BoxMesh.new()
		plate_mesh.size = Vector3(0.72, 0.12, 1.18 - float(plate_index) * 0.08)
		plate_mesh.material = shell_mat
		plate.mesh = plate_mesh
		plate.position = Vector3(-0.72 + float(plate_index) * 0.72, 0.59 + absf(float(plate_index) - 1.0) * 0.02, 0.0)
		plate.rotation_degrees.z = -4.0 + float(plate_index) * 4.0
		root.add_child(plate)

	# The offset sensory sail is the species' most readable non-terrestrial cue.
	var fan := MeshInstance3D.new()
	fan.name = "LateralSensorySail"
	var fan_mesh := PrismMesh.new()
	fan_mesh.size = Vector3(1.05, 0.76, 0.14)
	fan_mesh.material = fan_mat
	fan.mesh = fan_mesh
	fan.position = Vector3(-0.18, 0.72, -0.67)
	fan.rotation_degrees = Vector3(-18.0, 0.0, -8.0)
	root.add_child(fan)

	# Three forward rake teeth imply a scraping/grazing niche and give the head end
	# a functional read without adding a conventional face.
	for tooth_index in range(3):
		var tooth := MeshInstance3D.new()
		tooth.name = "GrazingRake%02d" % (tooth_index + 1)
		var tooth_mesh := BoxMesh.new()
		tooth_mesh.size = Vector3(0.14, 0.13, 0.52)
		tooth_mesh.material = shell_mat
		tooth.mesh = tooth_mesh
		tooth.position = Vector3(-0.32 + float(tooth_index) * 0.32, 0.29, -0.78)
		tooth.rotation_degrees.x = 13.0
		root.add_child(tooth)

	# Six short stilts keep the body unusually close to the terrain and distinguish
	# locomotion from a stock four-legged animal while retaining simple animation.
	for leg_index in range(6):
		var leg := MeshInstance3D.new()
		leg.name = "StiltLeg%02d" % (leg_index + 1)
		var leg_mesh := BoxMesh.new()
		leg_mesh.size = Vector3(0.18, 0.42, 0.18)
		leg_mesh.material = hide_mat
		leg.mesh = leg_mesh
		var column := leg_index / 2
		var x := -0.78 + float(column) * 0.78
		var z := -0.38 if leg_index % 2 == 0 else 0.38
		leg.position = Vector3(x, 0.09, z)
		leg.rotation_degrees.z = -6.0 + float(column) * 6.0
		root.add_child(leg)

	# Restrained paired sensory nodes provide a scanner-visible focal detail without
	# turning the animal into a glowing effect source.
	for side in [-1.0, 1.0]:
		var sensor := MeshInstance3D.new()
		sensor.name = "FieldSensorL" if side < 0.0 else "FieldSensorR"
		var sensor_mesh := SphereMesh.new()
		sensor_mesh.radius = 0.07
		sensor_mesh.height = 0.14
		sensor_mesh.material = sense_mat
		sensor.mesh = sensor_mesh
		sensor.position = Vector3(0.94, 0.49, 0.36 * side)
		root.add_child(sensor)

	return root

func alert_level_for_neighbor(distance: float, neighbor_fear: float) -> float:
	# Alert transfer is distance-weighted so a startled animal disturbs its local
	# herd instead of flipping every creature in the basin into the same state.
	if neighbor_fear <= 0.01 or distance >= HERD_ALERT_RADIUS:
		return 0.0
	return clampf(neighbor_fear * (1.0 - distance / HERD_ALERT_RADIUS) * HERD_ALERT_GAIN, 0.0, 1.0)

func _neighbor_alert(index: int, position: Vector3) -> float:
	var alert := 0.0
	for other_index in range(_grazers.size()):
		if other_index == index:
			continue
		var other: Dictionary = _grazers[other_index]
		var other_node := other["node"] as Node3D
		if not is_instance_valid(other_node):
			continue
		var offset := other_node.global_position - position
		offset.y = 0.0
		alert = maxf(alert, alert_level_for_neighbor(offset.length(), float(other["fear"])))
	return alert

func _update_grazer(index: int, delta: float, player_position: Vector3) -> void:
	var state: Dictionary = _grazers[index]
	var grazer := state["node"] as Node3D
	if not is_instance_valid(grazer):
		return
	var home: Vector3 = state["home"]
	var phase := float(state["phase"])
	var fear := maxf(0.0, float(state["fear"]) - delta * 0.55)
	var to_player := grazer.global_position - player_position
	to_player.y = 0.0
	if to_player.length() < PLAYER_AVOID_RADIUS:
		fear = 1.0
	else:
		fear = maxf(fear, _neighbor_alert(index, grazer.global_position))

	var desired := Vector3.ZERO
	if fear > 0.01 and to_player.length_squared() > 0.01:
		desired = to_player.normalized()
	else:
		var target := home + Vector3(
			sin(_time * 0.17 + phase) * 7.0,
			0.0,
			cos(_time * 0.13 + phase * 0.73) * 6.0
		)
		desired = target - grazer.position
		desired.y = 0.0
		if desired.length_squared() > 0.01:
			desired = desired.normalized()

	var speed := GRAZER_SPEED * lerpf(0.45, 1.85, fear)
	grazer.position += desired * speed * delta
	grazer.position.x = clampf(grazer.position.x, -TETHYS_BOUNDS, TETHYS_BOUNDS)
	grazer.position.z = clampf(grazer.position.z, -TETHYS_BOUNDS - 4.0, 8.0)
	grazer.position.y = 0.55
	if desired.length_squared() > 0.01:
		grazer.rotation.y = lerp_angle(grazer.rotation.y, atan2(desired.x, desired.z), minf(1.0, delta * 2.6))
	# Small body motion communicates grazing/alert state without an animation asset.
	grazer.scale.y = 1.0 + sin(_time * 2.2 + phase) * (0.018 + fear * 0.028)
	state["fear"] = fear
	_grazers[index] = state
