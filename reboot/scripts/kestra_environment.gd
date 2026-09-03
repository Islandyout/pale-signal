class_name KestraEnvironment
extends Node3D

# Authored first-hour Kestra layer. CampaignWorld owns collision/progression;
# this node gives the second field site a distinct archaeological identity and
# mounts the audited Kestra GLB only as presentation.

const KESTRA_ANCHOR := Vector3(0, 0, -1800)
const HERO_OFFSET := Vector3(-120, 0, -95)

var _ash_mat: StandardMaterial3D
var _stone_mat: StandardMaterial3D
var _survey_mat: StandardMaterial3D
var _signal_mat: StandardMaterial3D

func _ready() -> void:
	_make_materials()
	_build_approach_terraces()
	_build_excavation_site()
	call_deferred("_replace_fragment_visual")

func _material(color: Color, roughness: float, metallic := 0.0) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = roughness
	mat.metallic = metallic
	return mat

func _make_materials() -> void:
	_ash_mat = _material(Color("#555957"), 0.97)
	_stone_mat = _material(Color("#727773"), 0.86, 0.08)
	_survey_mat = _material(Color("#a7a18d"), 0.72, 0.12)
	_signal_mat = _material(Color("#9bc7c5"), 0.34, 0.24)
	_signal_mat.emission_enabled = true
	_signal_mat.emission = Color("#4b9996")
	_signal_mat.emission_energy_multiplier = 0.62

func _build_approach_terraces() -> void:
	for i in range(9):
		var terrace := MeshInstance3D.new()
		terrace.name = "KestraTerrace%02d" % i
		var mesh := BoxMesh.new()
		mesh.size = Vector3(32.0 + float(i % 3) * 11.0, 0.18 + float(i % 2) * 0.10, 16.0 + float((i + 1) % 3) * 8.0)
		mesh.material = _ash_mat if i % 3 else _stone_mat
		terrace.mesh = mesh
		var angle := float(i) * 0.77
		var radius := 42.0 + float((i * 29) % 95)
		terrace.position = KESTRA_ANCHOR + Vector3(cos(angle) * radius, mesh.size.y * 0.5, sin(angle) * radius)
		terrace.rotation_degrees.y = -18.0 + float(i) * 13.0
		add_child(terrace)

func _build_excavation_site() -> void:
	var site := Node3D.new()
	site.name = "KestraFoundationContradiction"
	site.position = KESTRA_ANCHOR + HERO_OFFSET
	add_child(site)

	# The imported module is source material: surround and partially bury it in
	# custom survey geometry so the hero read is not a raw asset drop.
	var fallback := Node3D.new()
	var fallback_mesh := MeshInstance3D.new()
	var block := BoxMesh.new()
	block.size = Vector3(7.5, 2.2, 5.0)
	block.material = _stone_mat
	fallback_mesh.mesh = block
	fallback_mesh.position.y = 0.75
	fallback.add_child(fallback_mesh)
	var module := AssetLoader.instantiate_or_fallback("kestra", fallback)
	module.name = "ExcavatedKestraModule"
	module.position = Vector3(0, -0.45, 0)
	module.rotation_degrees.y = 17.0
	site.add_child(module)

	for i in range(6):
		var rib := MeshInstance3D.new()
		rib.name = "SurveyRib%02d" % i
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.22, 1.15 + float(i % 2) * 0.35, 4.6)
		mesh.material = _survey_mat
		rib.mesh = mesh
		rib.position = Vector3(-5.2 + float(i) * 2.05, mesh.size.y * 0.5, 0.0)
		rib.rotation_degrees.y = 6.0 + float(i) * 2.0
		site.add_child(rib)

	for i in range(4):
		var seam := MeshInstance3D.new()
		seam.name = "ContradictionSeam%02d" % i
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.07, 0.045, 2.4 + float(i % 2) * 0.8)
		mesh.material = _signal_mat
		seam.mesh = mesh
		seam.position = Vector3(-1.7 + float(i) * 1.15, 0.18, -2.3 + float(i % 2) * 0.35)
		seam.rotation_degrees.y = -13.0 + float(i) * 8.0
		site.add_child(seam)

func _replace_fragment_visual() -> void:
	var root := get_parent()
	if root == null:
		return
	var world := root.get_node_or_null("CampaignWorld")
	if world == null:
		return
	for child in world.get_children():
		if child is Interactable:
			var target := child as Interactable
			if target.interaction_id != "fragment|tethys_2":
				continue
			var visual := target.get_node_or_null("Visual") as MeshInstance3D
			if visual != null:
				visual.visible = false
			if target.get_node_or_null("HeroPaleArtifact") == null:
				target.add_child(_build_pale_fragment_artifact())
			return

func _build_pale_fragment_artifact() -> Node3D:
	# The fragment remains parented to the canonical Interactable so scanner,
	# collection, save visibility and tutorial evidence keep one state owner.
	# Presentation deliberately avoids a stock glowing cylinder: layered ceramic
	# shards surround a dark impossible core and offset signal seams imply that
	# the object was assembled around a field phenomenon rather than manufactured
	# as a conventional device.
	var artifact := Node3D.new()
	artifact.name = "HeroPaleArtifact"
	artifact.position = Vector3(0.0, 0.28, 0.0)
	artifact.rotation_degrees = Vector3(-7.0, 18.0, 5.0)

	var shell_mat := _material(Color("#c3cbc5"), 0.58, 0.18)
	var core_mat := _material(Color("#11181b"), 0.24, 0.42)
	var seam_mat := _material(Color("#8fd8d3"), 0.26, 0.28)
	seam_mat.emission_enabled = true
	seam_mat.emission = Color("#4ca8a2")
	seam_mat.emission_energy_multiplier = 1.35

	var core := MeshInstance3D.new()
	core.name = "ImpossibleCore"
	var core_mesh := SphereMesh.new()
	core_mesh.radius = 0.31
	core_mesh.height = 0.62
	core_mesh.material = core_mat
	core.mesh = core_mesh
	core.scale = Vector3(0.78, 1.28, 0.62)
	artifact.add_child(core)

	for i in range(4):
		var shard := MeshInstance3D.new()
		shard.name = "CeramicShard%02d" % i
		var shard_mesh := BoxMesh.new()
		shard_mesh.size = Vector3(0.16 + float(i % 2) * 0.06, 0.88 - float(i) * 0.08, 0.31)
		shard_mesh.material = shell_mat
		shard.mesh = shard_mesh
		var angle := float(i) * TAU / 4.0 + 0.22
		shard.position = Vector3(cos(angle) * 0.43, 0.04 + float(i % 2) * 0.08, sin(angle) * 0.43)
		shard.rotation_degrees = Vector3(-14.0 + float(i) * 7.0, rad_to_deg(angle) + 24.0, 9.0 - float(i) * 5.0)
		artifact.add_child(shard)

	for i in range(3):
		var seam := MeshInstance3D.new()
		seam.name = "SignalSeam%02d" % i
		var seam_mesh := BoxMesh.new()
		seam_mesh.size = Vector3(0.035, 0.52 - float(i) * 0.07, 0.055)
		seam_mesh.material = seam_mat
		seam.mesh = seam_mesh
		var angle := 0.5 + float(i) * 2.04
		seam.position = Vector3(cos(angle) * 0.34, -0.02 + float(i) * 0.08, sin(angle) * 0.34)
		seam.rotation_degrees = Vector3(12.0 - float(i) * 9.0, rad_to_deg(angle), -7.0 + float(i) * 8.0)
		artifact.add_child(seam)

	var needle := MeshInstance3D.new()
	needle.name = "FieldNeedle"
	var needle_mesh := CylinderMesh.new()
	needle_mesh.top_radius = 0.025
	needle_mesh.bottom_radius = 0.045
	needle_mesh.height = 0.72
	needle_mesh.material = seam_mat
	needle.mesh = needle_mesh
	needle.position = Vector3(-0.15, 0.46, 0.12)
	needle.rotation_degrees = Vector3(19.0, 0.0, -13.0)
	artifact.add_child(needle)

	return artifact
