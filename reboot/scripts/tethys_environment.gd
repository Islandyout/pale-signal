class_name TethysEnvironment
extends Node3D

# Authored first-hour environment layer. Gameplay collision/progression remain owned
# by CampaignWorld/GameRoot; this node replaces the flat test-field read with a
# distinctive Tethys basin and a hero archaeology silhouette.

var _ground_mat: StandardMaterial3D
var _silt_mat: StandardMaterial3D
var _water_mat: StandardMaterial3D
var _stone_mat: StandardMaterial3D
var _reed_mat: StandardMaterial3D
var _signal_mat: StandardMaterial3D

func _ready() -> void:
	_make_materials()
	_build_basin()
	_build_ridges()
	_build_silt_pools()
	_build_reed_bands()
	_build_archaeology_site()
	call_deferred("_replace_tutorial_ruin_visual")

func _make_materials() -> void:
	_ground_mat = _material(Color("#536f68"), 0.95)
	_silt_mat = _material(Color("#6f8178"), 0.91)
	_water_mat = _material(Color("#547b7d"), 0.28, 0.08)
	_water_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_water_mat.albedo_color.a = 0.68
	_stone_mat = _material(Color("#6d7772"), 0.84, 0.12)
	_reed_mat = _material(Color("#91a879"), 0.92)
	_signal_mat = _material(Color("#b7d7d0"), 0.38, 0.22)
	_signal_mat.emission_enabled = true
	_signal_mat.emission = Color("#4f9f97")
	_signal_mat.emission_energy_multiplier = 0.75

func _material(color: Color, roughness: float, metallic := 0.0) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = roughness
	mat.metallic = metallic
	return mat

func _build_basin() -> void:
	# Layered, low relief shapes create an authored basin without changing the
	# production collision plane used by EVA/ship contracts.
	for i in range(11):
		var patch := MeshInstance3D.new()
		patch.name = "BasinPatch%02d" % i
		var mesh := CylinderMesh.new()
		mesh.top_radius = 12.0 + float((i * 7) % 9)
		mesh.bottom_radius = mesh.top_radius * 1.08
		mesh.height = 0.08 + float(i % 3) * 0.025
		mesh.radial_segments = 20
		mesh.material = _ground_mat if i % 3 else _silt_mat
		patch.mesh = mesh
		var angle := float(i) * 1.73
		var radius := 6.0 + float((i * 13) % 36)
		patch.position = Vector3(cos(angle) * radius, 0.018 + float(i % 2) * 0.012, -18.0 + sin(angle) * radius * 0.65)
		patch.scale = Vector3(1.35 + float(i % 4) * 0.18, 1.0, 0.72 + float((i + 1) % 3) * 0.16)
		add_child(patch)

func _build_ridges() -> void:
	var ridge_data := [
		[Vector3(-34, 2.3, -33), Vector3(20, 4.8, 7), -12.0],
		[Vector3(30, 1.9, -38), Vector3(17, 3.9, 6), 18.0],
		[Vector3(-29, 1.4, 4), Vector3(15, 2.8, 5), 11.0],
		[Vector3(34, 1.25, -4), Vector3(13, 2.5, 4), -16.0],
	]
	for i in range(ridge_data.size()):
		var ridge := MeshInstance3D.new()
		ridge.name = "WeatheredRidge%02d" % i
		var mesh := PrismMesh.new()
		mesh.size = ridge_data[i][1]
		mesh.material = _stone_mat
		ridge.mesh = mesh
		ridge.position = ridge_data[i][0]
		ridge.rotation_degrees.y = ridge_data[i][2]
		ridge.rotation_degrees.z = -4.0 + float(i) * 2.4
		add_child(ridge)

func _build_silt_pools() -> void:
	var pools := [Vector3(-14, 0.045, -25), Vector3(15, 0.04, -18), Vector3(2, 0.035, -39)]
	for i in range(pools.size()):
		var pool := MeshInstance3D.new()
		pool.name = "MineralPool%02d" % i
		var mesh := CylinderMesh.new()
		mesh.top_radius = 4.8 + float(i) * 1.4
		mesh.bottom_radius = mesh.top_radius
		mesh.height = 0.025
		mesh.radial_segments = 24
		mesh.material = _water_mat
		pool.mesh = mesh
		pool.position = pools[i]
		pool.scale.z = 0.58 + float(i) * 0.09
		add_child(pool)

func _build_reed_bands() -> void:
	# Reed placement follows curved bands instead of the previous uniform primitive
	# scatter, giving the landing basin readable ecological edges and sight lines.
	for i in range(54):
		var angle := -1.1 + float(i) * 0.085
		var radius := 24.0 + sin(float(i) * 0.73) * 4.5
		var base := Vector3(cos(angle) * radius, 0.0, -20.0 + sin(angle) * radius * 0.72)
		for blade_index in range(2):
			var blade := MeshInstance3D.new()
			blade.name = "PaleReed_%02d_%d" % [i, blade_index]
			var mesh := PrismMesh.new()
			mesh.size = Vector3(0.09, 1.15 + float((i + blade_index) % 5) * 0.16, 0.045)
			mesh.material = _reed_mat
			blade.mesh = mesh
			blade.position = base + Vector3(float(blade_index) * 0.16, mesh.size.y * 0.5, float(blade_index) * 0.08)
			blade.rotation_degrees.z = -7.0 + float((i + blade_index) % 7) * 2.0
			add_child(blade)

func _build_archaeology_site() -> void:
	var site := Node3D.new()
	site.name = "FoundationSeamHeroSite"
	site.position = Vector3(-8.0, 0.0, -14.0)
	add_child(site)

	# Broken partial ring: reads as an excavated engineered structure rather than
	# a crate while leaving the actual interactable/collision anchor untouched.
	for i in range(7):
		var angle := -2.35 + float(i) * 0.50
		var pylon := MeshInstance3D.new()
		pylon.name = "BuriedArc%02d" % i
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.48, 0.68 + float(i % 3) * 0.15, 2.2)
		mesh.material = _stone_mat
		pylon.mesh = mesh
		pylon.position = Vector3(cos(angle) * 3.15, mesh.size.y * 0.5 - 0.22, sin(angle) * 2.15)
		pylon.rotation.y = -angle + PI * 0.5
		pylon.rotation_degrees.z = -5.0 + float(i % 3) * 4.0
		site.add_child(pylon)

	# Signal seams provide a restrained alignment reference that becomes visually
	# meaningful during reconstruction without becoming a neon billboard.
	for i in range(5):
		var seam := MeshInstance3D.new()
		seam.name = "SignalSeam%02d" % i
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.055, 0.035, 1.2 + float(i % 2) * 0.35)
		mesh.material = _signal_mat
		seam.mesh = mesh
		seam.position = Vector3(-1.25 + float(i) * 0.62, 0.16, -0.05 + sin(float(i)) * 0.22)
		seam.rotation_degrees.y = -9.0 + float(i) * 4.5
		site.add_child(seam)

	var marker := MeshInstance3D.new()
	marker.name = "ExcavationMarker"
	var marker_mesh := CylinderMesh.new()
	marker_mesh.top_radius = 0.05
	marker_mesh.bottom_radius = 0.08
	marker_mesh.height = 1.65
	marker_mesh.material = _signal_mat
	marker.mesh = marker_mesh
	marker.position = Vector3(2.7, 0.82, 1.6)
	site.add_child(marker)

func _replace_tutorial_ruin_visual() -> void:
	var root := get_parent()
	if root == null:
		return
	for child in root.get_children():
		if child is Interactable:
			var target := child as Interactable
			if target.interaction_id != "foundation":
				continue
			var visual := target.get_node_or_null("Visual") as MeshInstance3D
			if visual != null:
				visual.visible = false
			return
