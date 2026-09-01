class_name WorldArt
extends RefCounted

static func install(root: Node3D, eva: EVAController) -> Dictionary:
	var created := {}

	# EVA body is hidden during first-person play to avoid camera clipping, but
	# becomes visible to cinematic/tutorial cameras.
	var eva_fallback := _humanoid_fallback(Color("#d8e0dc"))
	var eva_visual := AssetLoader.instantiate_or_fallback("eva", eva_fallback)
	eva_visual.name = "EVAVisual"
	eva_visual.position = Vector3(0, -0.90, 0)
	eva_visual.visible = false
	eva.add_child(eva_visual)
	created["eva_visual"] = eva_visual

	# The imported humanoid remains only an animation/scale base. Talari identity
	# is authored as a substantial kitbash around it so a free source asset never
	# becomes the final species silhouette.
	var talari_anchor := Node3D.new()
	talari_anchor.name = "TalariSurveyInstructor"
	talari_anchor.position = Vector3(-11.5, 0.0, -18.5)
	var talari_fallback := _humanoid_fallback(Color("#8aa7a0"))
	var talari_visual := AssetLoader.instantiate_or_fallback("talari", talari_fallback)
	talari_visual.position.y = 0.0
	talari_anchor.add_child(talari_visual)
	_decorate_talari(talari_anchor)
	root.add_child(talari_anchor)
	created["talari"] = talari_anchor

	# The first imported Kestra module is deliberately only a structural base.
	# It establishes scale and navigation landmarks without defining final art.
	var outpost := Node3D.new()
	outpost.name = "KestraTrainingOutpost"
	outpost.position = Vector3(18.0, 0.0, -34.0)
	outpost.rotation.y = -0.45
	var module_fallback := _module_fallback()
	var module := AssetLoader.instantiate_or_fallback("kestra", module_fallback)
	outpost.add_child(module)
	root.add_child(outpost)
	created["kestra_outpost"] = outpost

	return created

static func set_eva_cinematic_visible(visual: Node3D, value: bool) -> void:
	if is_instance_valid(visual):
		visual.visible = value

static func _decorate_talari(anchor: Node3D) -> void:
	var skin := StandardMaterial3D.new()
	skin.albedo_color = Color("#71958d")
	skin.roughness = 0.78

	var ceramic := StandardMaterial3D.new()
	ceramic.albedo_color = Color("#d7d0ba")
	ceramic.metallic = 0.18
	ceramic.roughness = 0.44

	var signal_mat := StandardMaterial3D.new()
	signal_mat.albedo_color = Color("#8de1d4")
	signal_mat.emission_enabled = true
	signal_mat.emission = Color("#54aa9f")
	signal_mat.emission_energy_multiplier = 1.55
	signal_mat.roughness = 0.3

	# Talari cranial fan: an asymmetrical three-fin sensory crown gives the
	# instructor a readable non-human profile even at training-basin distance.
	for i in range(3):
		var fin := MeshInstance3D.new()
		fin.name = "CranialFin%d" % i
		var fin_mesh := BoxMesh.new()
		fin_mesh.size = Vector3(0.10, 0.54 - float(i) * 0.07, 0.26)
		fin_mesh.material = skin
		fin.mesh = fin_mesh
		fin.position = Vector3(-0.16 + float(i) * 0.16, 1.92 + float(i) * 0.05, 0.02)
		fin.rotation_degrees = Vector3(-12.0, 0.0, -20.0 + float(i) * 18.0)
		anchor.add_child(fin)

	# A broad collar/mantle breaks the human shoulder line and provides a strong
	# cultural shape language distinct from the expedition EVA suit.
	var mantle := MeshInstance3D.new()
	mantle.name = "SurveyMantle"
	var mantle_mesh := BoxMesh.new()
	mantle_mesh.size = Vector3(1.22, 0.12, 0.50)
	mantle_mesh.material = ceramic
	mantle.mesh = mantle_mesh
	mantle.position = Vector3(0.0, 1.47, 0.02)
	mantle.rotation_degrees.z = -4.0
	anchor.add_child(mantle)

	# Twin chest bars act as restrained luminous survey insignia rather than a
	# neon costume. They are small enough to remain legible without dominating.
	for side in [-1.0, 1.0]:
		var bar := MeshInstance3D.new()
		bar.name = "SignalBarL" if side < 0.0 else "SignalBarR"
		var bar_mesh := BoxMesh.new()
		bar_mesh.size = Vector3(0.055, 0.34, 0.035)
		bar_mesh.material = signal_mat
		bar.mesh = bar_mesh
		bar.position = Vector3(0.17 * side, 1.26, -0.31)
		bar.rotation_degrees.z = 11.0 * side
		anchor.add_child(bar)

	# A compact field transceiver balances the silhouette and reinforces the
	# instructor's scientific role without adding a new gameplay subsystem.
	var pack := MeshInstance3D.new()
	pack.name = "TalariFieldTransceiver"
	var pack_mesh := BoxMesh.new()
	pack_mesh.size = Vector3(0.52, 0.56, 0.18)
	pack_mesh.material = ceramic
	pack.mesh = pack_mesh
	pack.position = Vector3(0.0, 1.10, 0.34)
	anchor.add_child(pack)

	var antenna := MeshInstance3D.new()
	antenna.name = "TalariAntenna"
	var antenna_mesh := CylinderMesh.new()
	antenna_mesh.top_radius = 0.018
	antenna_mesh.bottom_radius = 0.024
	antenna_mesh.height = 0.58
	antenna_mesh.material = signal_mat
	antenna.mesh = antenna_mesh
	antenna.position = Vector3(0.23, 1.66, 0.35)
	antenna.rotation_degrees.z = -7.0
	anchor.add_child(antenna)

static func _humanoid_fallback(color: Color) -> Node3D:
	var group := Node3D.new()
	var torso := MeshInstance3D.new()
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.32
	capsule.height = 1.45
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.72
	capsule.material = mat
	torso.mesh = capsule
	torso.position.y = 0.82
	group.add_child(torso)
	return group

static func _module_fallback() -> Node3D:
	var group := Node3D.new()
	var body := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(8.0, 3.2, 5.0)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("#455b5e")
	mat.metallic = 0.25
	mat.roughness = 0.66
	box.material = mat
	body.mesh = box
	body.position.y = 1.6
	group.add_child(body)
	return group
