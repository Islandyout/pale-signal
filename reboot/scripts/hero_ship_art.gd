extends Node

# Presentation-only identity layer for the expedition ship. The imported CC0
# model remains a source/base asset; these authored parts live directly under
# the ShipController so collision, flight forces, cameras, saves and tutorial
# mechanic completion remain untouched.

func _ready() -> void:
	call_deferred("_install")

func _install() -> void:
	var scene := get_tree().current_scene
	if scene == null:
		return
	var ship := scene.get_node_or_null("Ship") as Node3D
	if ship == null or ship.has_node("PaleSignalHeroShipIdentity"):
		return

	var identity := Node3D.new()
	identity.name = "PaleSignalHeroShipIdentity"
	ship.add_child(identity)

	var hull := StandardMaterial3D.new()
	hull.albedo_color = Color("#26343b")
	hull.metallic = 0.62
	hull.roughness = 0.34

	var ceramic := StandardMaterial3D.new()
	ceramic.albedo_color = Color("#c5c9bd")
	ceramic.metallic = 0.22
	ceramic.roughness = 0.48

	var signal_material := StandardMaterial3D.new()
	signal_material.albedo_color = Color("#77bdb2")
	signal_material.emission_enabled = true
	signal_material.emission = Color("#356f68")
	signal_material.emission_energy_multiplier = 1.05
	signal_material.roughness = 0.28

	# Offset dorsal instrument spine: the ship reads as a field-science vessel,
	# not a symmetric fighter, and preserves a recognizable silhouette in orbit.
	_add_box(identity, "SurveySpine", Vector3(0.22, 0.24, 2.75), Vector3(-0.42, 0.63, -0.18), Vector3(0.0, -5.0, -3.0), ceramic)
	_add_box(identity, "SensorBoom", Vector3(0.15, 0.12, 1.35), Vector3(0.82, 0.34, -1.35), Vector3(0.0, 17.0, 0.0), ceramic)
	_add_box(identity, "BoomHead", Vector3(0.62, 0.18, 0.42), Vector3(0.95, 0.37, -1.92), Vector3(0.0, 17.0, 0.0), hull)

	# Four separated VTOL housings make world-up lift visually legible without
	# changing the existing pitch-independent thrust mechanic.
	for x in [-1.08, 1.08]:
		for z in [-0.95, 1.08]:
			var side_name := "L" if x < 0.0 else "R"
			var fore_name := "F" if z < 0.0 else "A"
			_add_cylinder(identity, "VTOL%s%s" % [side_name, fore_name], 0.24, 0.38, Vector3(x, -0.36, z), hull)
			_add_box(identity, "LiftMark%s%s" % [side_name, fore_name], Vector3(0.24, 0.025, 0.07), Vector3(x, -0.565, z), Vector3.ZERO, signal_material)

	# Asymmetric belly science pallet and restrained luminous index bars carry the
	# same survey language used by Talari field equipment without copying it.
	_add_box(identity, "SciencePallet", Vector3(1.28, 0.18, 0.82), Vector3(-0.30, -0.54, 0.18), Vector3(0.0, 8.0, 0.0), ceramic)
	for i in range(3):
		_add_box(identity, "SignalIndex%d" % i, Vector3(0.055, 0.05, 0.42 + float(i) * 0.13), Vector3(0.52 + float(i) * 0.13, 0.52, 0.78 - float(i) * 0.16), Vector3(0.0, -9.0 + float(i) * 5.0, 0.0), signal_material)

	# Rear field vanes break the stock source outline and give the craft a clear
	# nose/tail read during manual approach and landing.
	_add_box(identity, "FieldVaneL", Vector3(0.10, 0.78, 0.72), Vector3(-0.72, 0.34, 1.55), Vector3(-7.0, 0.0, -12.0), hull)
	_add_box(identity, "FieldVaneR", Vector3(0.10, 0.58, 0.72), Vector3(0.74, 0.24, 1.55), Vector3(-7.0, 0.0, 9.0), hull)

func _add_box(parent: Node3D, node_name: String, size: Vector3, position_: Vector3, rotation_: Vector3, material: Material) -> void:
	var part := MeshInstance3D.new()
	part.name = node_name
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.material = material
	part.mesh = mesh
	part.position = position_
	part.rotation_degrees = rotation_
	parent.add_child(part)

func _add_cylinder(parent: Node3D, node_name: String, radius: float, height: float, position_: Vector3, material: Material) -> void:
	var part := MeshInstance3D.new()
	part.name = node_name
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius * 0.82
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.material = material
	part.mesh = mesh
	part.position = position_
	parent.add_child(part)
