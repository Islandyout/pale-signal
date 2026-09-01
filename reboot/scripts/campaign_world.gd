class_name CampaignWorld
extends Node3D

signal world_changed(world: String)

const SURFACE_RADIUS := 620.0
const ATMOSPHERE_CEILING := 520.0

var current_world := "Tethys"
var campaign: CampaignState
var sites: Dictionary = {}
var world_labels: Dictionary = {}
var nemesis_surface: Node3D

func setup(state: CampaignState) -> void:
	campaign = state
	_build_worlds()
	_apply_progress_visibility()

func _build_worlds() -> void:
	# Production intentionally constructs only the Tethys/Kestra vertical slice.
	# Later-world authoring data remains in CampaignState without becoming playable breadth.
	for world in CampaignState.PRODUCTION_WORLDS:
		var data: Dictionary = CampaignState.WORLD_DATA[world]
		var anchor: Vector3 = data["anchor"]
		var surface := _make_surface(world, anchor, data["color"])
		add_child(surface)
		var label := Label3D.new()
		label.text = world.to_upper()
		label.font_size = 42
		label.outline_size = 8
		label.position = anchor + Vector3(0, 48, 0)
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		add_child(label)
		world_labels[world] = label
		_build_landmarks(world, anchor, data["color"])
		_build_resources(world, anchor, data["resources"])
	_build_fragments()

func _make_surface(world: String, anchor: Vector3, color: Color) -> Node3D:
	var root := Node3D.new()
	root.name = world + "Surface"
	var body := StaticBody3D.new()
	body.name = "Collision"
	body.position = anchor
	var mesh_i := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(SURFACE_RADIUS * 2.0, 1.0, SURFACE_RADIUS * 2.0)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.94
	mesh.material = mat
	mesh_i.mesh = mesh
	mesh_i.position.y = -0.5
	body.add_child(mesh_i)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(SURFACE_RADIUS * 2.0, 1.0, SURFACE_RADIUS * 2.0)
	collision.shape = shape
	collision.position.y = -0.5
	body.add_child(collision)
	root.add_child(body)
	return root

func _build_landmarks(world: String, anchor: Vector3, color: Color) -> void:
	for i in range(9):
		var tower := MeshInstance3D.new()
		var mesh := CylinderMesh.new()
		mesh.top_radius = 0.8 + float(i % 3) * 0.35
		mesh.bottom_radius = 1.1 + float(i % 2) * 0.45
		mesh.height = 8.0 + float((i * 7) % 18)
		var mat := StandardMaterial3D.new()
		mat.albedo_color = color.lightened(0.08 + float(i % 3) * 0.05)
		mat.roughness = 0.8
		mesh.material = mat
		tower.mesh = mesh
		var angle := float(i) * TAU / 9.0
		var radius := 120.0 + float((i * 43) % 150)
		tower.position = anchor + Vector3(cos(angle) * radius, mesh.height * 0.5, sin(angle) * radius)
		add_child(tower)

func _build_resources(world: String, anchor: Vector3, resources: Array) -> void:
	var index := 0
	for resource_name in resources:
		for copy in range(3):
			var angle := float(index * 5 + copy * 2) * 0.79
			var radius := 65.0 + float((index * 77 + copy * 51) % 250)
			var position_ := anchor + Vector3(cos(angle) * radius, 0.65, sin(angle) * radius)
			var site_id := "resource|%s|%s|%d" % [world, str(resource_name), copy]
			var site := _make_site(site_id, str(resource_name), position_, Color("#8fb9a7"), 0.48)
			sites[site_id] = site
			add_child(site)
		index += 1

func _build_fragments() -> void:
	for fragment_id in CampaignState.FRAGMENTS:
		var data: Dictionary = CampaignState.FRAGMENTS[fragment_id]
		var world := str(data["world"])
		if not CampaignState.PRODUCTION_WORLDS.has(world): continue
		var anchor: Vector3 = CampaignState.WORLD_DATA[world]["anchor"]
		var offset: Vector3 = data["offset"]
		var site_id := "fragment|" + str(fragment_id)
		var site := _make_site(site_id, str(data["name"]), anchor + offset, Color("#d9eef0"), 0.85)
		var mesh_i := site.get_node("Visual") as MeshInstance3D
		if mesh_i:
			var mesh := CylinderMesh.new()
			mesh.top_radius = 0.28
			mesh.bottom_radius = 0.62
			mesh.height = 1.7
			var mat := StandardMaterial3D.new()
			mat.albedo_color = Color("#cddcdf")
			mat.emission_enabled = true
			mat.emission = Color("#7bd7e2") * 1.5
			mat.roughness = 0.22
			mesh.material = mat
			mesh_i.mesh = mesh
		sites[site_id] = site
		add_child(site)

func _make_site(id: String, label: String, position_: Vector3, color: Color, radius: float) -> Interactable:
	var area := Interactable.new()
	area.interaction_id = id
	area.display_name = label
	area.requires_scan = true
	area.position = position_
	var visual := MeshInstance3D.new()
	visual.name = "Visual"
	var sphere := SphereMesh.new()
	sphere.radius = radius
	sphere.height = radius * 2.0
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.56
	sphere.material = mat
	visual.mesh = sphere
	area.add_child(visual)
	var collision := CollisionShape3D.new()
	var cshape := SphereShape3D.new()
	cshape.radius = maxf(0.75, radius + 0.25)
	collision.shape = cshape
	area.add_child(collision)
	return area

func surface_info(position_: Vector3) -> Dictionary:
	var nearest := ""
	var best := INF
	for world in CampaignState.PRODUCTION_WORLDS:
		var anchor: Vector3 = CampaignState.WORLD_DATA[world]["anchor"]
		var planar := Vector2(position_.x - anchor.x, position_.z - anchor.z).length()
		if planar <= SURFACE_RADIUS and planar < best:
			nearest = world
			best = planar
	if nearest.is_empty(): return {"valid":false, "world":"", "height":0.0, "atmosphere":0.0, "gravity":0.0}
	var altitude := maxf(0.0, position_.y)
	var atmosphere := clampf(1.0 - altitude / ATMOSPHERE_CEILING, 0.0, 1.0)
	return {"valid":true, "world":nearest, "height":0.0, "atmosphere":atmosphere, "gravity":9.0}

func approach_target(world: String) -> Vector3:
	if not CampaignState.PRODUCTION_WORLDS.has(world): return Vector3.ZERO
	var anchor: Vector3 = CampaignState.WORLD_DATA[world]["anchor"]
	return anchor + Vector3(0, 155, 185)

func landing_target(world: String) -> Vector3:
	if not CampaignState.PRODUCTION_WORLDS.has(world): return Vector3.ZERO
	var anchor: Vector3 = CampaignState.WORLD_DATA[world]["anchor"]
	return anchor + Vector3(0, 1, 60)

func nearest_site(position_: Vector3, max_range := 3.2) -> Interactable:
	var best_site: Interactable
	var best := max_range
	for site_id in sites:
		var site := sites[site_id] as Interactable
		if not is_instance_valid(site) or not site.visible: continue
		var distance := position_.distance_to(site.global_position)
		if distance < best:
			best = distance
			best_site = site
	return best_site

func mark_site_collected(site_id: String) -> void:
	if sites.has(site_id):
		var site := sites[site_id] as Interactable
		if is_instance_valid(site):
			site.completed = true
			site.visible = false
	_apply_progress_visibility()

func restore_collected_sites() -> void:
	if campaign == null: return
	for site_id in campaign.collected_sites:
		if sites.has(site_id):
			var site := sites[site_id] as Interactable
			if is_instance_valid(site): site.visible = false
	_apply_progress_visibility()

func update_context(position_: Vector3, environment: Environment) -> String:
	var info := surface_info(position_)
	var world := str(info.get("world", ""))
	if world.is_empty():
		environment.background_color = Color("#03060b")
		environment.fog_density = 0.0
	else:
		var data: Dictionary = CampaignState.WORLD_DATA[world]
		environment.background_color = data["sky"]
		environment.fog_light_color = data["sky"]
		environment.fog_density = 0.0025 if float(info.get("atmosphere", 0.0)) > 0.02 else 0.0
	if world != current_world and not world.is_empty():
		current_world = world
		world_changed.emit(world)
	return world

func _apply_progress_visibility() -> void:
	if campaign == null: return
	for fragment_id in CampaignState.FRAGMENTS:
		var data: Dictionary = CampaignState.FRAGMENTS[fragment_id]
		if not CampaignState.PRODUCTION_WORLDS.has(str(data["world"])): continue
		var site_id := "fragment|" + str(fragment_id)
		if sites.has(site_id) and campaign.fragments.has(fragment_id):
			(sites[site_id] as Interactable).visible = false