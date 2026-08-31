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

	# A temporary Talari survey instructor proves the humanoid GLB/rig in the
	# actual scene. The final species mesh remains custom by design.
	var talari_anchor := Node3D.new()
	talari_anchor.name = "TalariSurveyInstructor"
	talari_anchor.position = Vector3(-11.5, 0.0, -18.5)
	var talari_fallback := _humanoid_fallback(Color("#8aa7a0"))
	var talari_visual := AssetLoader.instantiate_or_fallback("talari", talari_fallback)
	talari_visual.position.y = 0.0
	talari_anchor.add_child(talari_visual)
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
