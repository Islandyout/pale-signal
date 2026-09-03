class_name PaleSignalSystem
extends Node

# Player-facing Pale Signal phenomenon layer for the Tethys/Kestra first hour.
# This system is observational only: it reads campaign/site state and never
# mutates progression, tutorial completion, saves, controller state, or physics.

const MAX_VISUAL_RANGE := 130.0
const BASE_LIGHT_ENERGY := 0.42
const ESCALATED_LIGHT_ENERGY := 0.78

var _campaign_world: CampaignWorld
var _eva: EVAController
var _ship: ShipController
var _phenomenon_root: Node3D
var _pulse_light: OmniLight3D
var _rings: Array[MeshInstance3D] = []
var _receiver_vanes: Array[MeshInstance3D] = []
var _signal_spine: MeshInstance3D
var _phase := 0.0

func _ready() -> void:
	call_deferred("_bind_world")

func _bind_world() -> void:
	var world_candidate := get_tree().root.find_child("CampaignWorld", true, false)
	if world_candidate is CampaignWorld:
		_campaign_world = world_candidate as CampaignWorld
	var eva_candidate := get_tree().root.find_child("EVA", true, false)
	if eva_candidate is EVAController:
		_eva = eva_candidate as EVAController
	var ship_candidate := get_tree().root.find_child("Ship", true, false)
	if ship_candidate is ShipController:
		_ship = ship_candidate as ShipController
	if _phenomenon_root == null or not is_instance_valid(_phenomenon_root):
		_install_visuals()

func _signal_material(albedo: Color, emission: Color, alpha: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = albedo
	material.emission_enabled = true
	material.emission = emission
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color.a = alpha
	return material

func _install_visuals() -> void:
	var scene := get_tree().current_scene
	if scene == null:
		return
	_phenomenon_root = Node3D.new()
	_phenomenon_root.name = "PaleSignalPhenomenon"
	_phenomenon_root.visible = false
	scene.add_child(_phenomenon_root)

	_pulse_light = OmniLight3D.new()
	_pulse_light.omni_range = 14.0
	_pulse_light.light_color = Color("#8cecf2")
	_pulse_light.shadow_enabled = false
	_phenomenon_root.add_child(_pulse_light)

	# The rings describe the receiver field, but they are deliberately not the
	# hero silhouette. The asymmetric spine/vanes below give the Pale Signal a
	# recognizable physical grammar that is ours rather than a stock torus icon.
	for i in range(3):
		var ring := MeshInstance3D.new()
		var torus := TorusMesh.new()
		torus.inner_radius = 1.45 + float(i) * 0.46
		torus.outer_radius = torus.inner_radius + 0.045
		torus.rings = 24
		torus.ring_segments = 10
		torus.material = _signal_material(
			Color("#a7f4f7"),
			Color("#69dce7") * (1.45 - float(i) * 0.16),
			0.34 - float(i) * 0.06
		)
		ring.mesh = torus
		ring.rotation_degrees.x = 90.0
		_phenomenon_root.add_child(ring)
		_rings.append(ring)

	_signal_spine = MeshInstance3D.new()
	_signal_spine.name = "SignalSpine"
	var spine_mesh := BoxMesh.new()
	spine_mesh.size = Vector3(0.16, 2.65, 0.16)
	spine_mesh.material = _signal_material(Color("#d4ffff"), Color("#7de8ef") * 1.85, 0.82)
	_signal_spine.mesh = spine_mesh
	_signal_spine.position.y = 0.12
	_signal_spine.rotation_degrees = Vector3(7.0, 0.0, -11.0)
	_phenomenon_root.add_child(_signal_spine)

	for i in range(4):
		var vane := MeshInstance3D.new()
		vane.name = "ReceiverVane%d" % i
		var vane_mesh := BoxMesh.new()
		vane_mesh.size = Vector3(0.18, 1.05 + float(i % 2) * 0.22, 0.34)
		vane_mesh.material = _signal_material(Color("#b9f8fa"), Color("#55cfdb") * 1.55, 0.62)
		vane.mesh = vane_mesh
		var angle := float(i) * TAU / 4.0 + 0.36
		var radius := 0.98 + float(i % 2) * 0.14
		vane.position = Vector3(cos(angle) * radius, -0.08 + float(i % 2) * 0.18, sin(angle) * radius)
		vane.rotation.y = -angle
		vane.rotation.z = deg_to_rad(31.0 if i % 2 == 0 else -24.0)
		_phenomenon_root.add_child(vane)
		_receiver_vanes.append(vane)

func _process(delta: float) -> void:
	if _campaign_world == null or not is_instance_valid(_campaign_world) or _phenomenon_root == null or not is_instance_valid(_phenomenon_root):
		_bind_world()
		return
	var actor := _active_actor()
	var site := _nearest_unresolved_fragment(actor)
	if actor == null or site == null:
		_phenomenon_root.visible = false
		return
	var distance := actor.global_position.distance_to(site.global_position)
	if distance > MAX_VISUAL_RANGE:
		_phenomenon_root.visible = false
		return

	_phenomenon_root.visible = true
	_phenomenon_root.global_position = site.global_position + Vector3(0, 1.15, 0)
	_phase = fposmod(_phase + delta * pulse_rate(), TAU)
	var proximity := clampf(1.0 - distance / MAX_VISUAL_RANGE, 0.0, 1.0)
	var pulse := 0.5 + 0.5 * sin(_phase)
	var escalation := escalation_level()
	_pulse_light.light_energy = lerpf(BASE_LIGHT_ENERGY, ESCALATED_LIGHT_ENERGY, escalation) * (0.35 + proximity * 0.65) * (0.55 + pulse * 0.45)
	for i in range(_rings.size()):
		var ring := _rings[i]
		var offset := float(i) * 0.8
		var wave := 0.5 + 0.5 * sin(_phase - offset)
		var scale_value := 0.72 + wave * (0.22 + escalation * 0.12)
		ring.scale = Vector3.ONE * scale_value
		ring.rotation.y += delta * (0.12 + float(i) * 0.05) * (1.0 + escalation * 0.4)

	if _signal_spine != null and is_instance_valid(_signal_spine):
		_signal_spine.rotation.y = sin(_phase * 0.38) * (0.16 + escalation * 0.08)
		_signal_spine.scale.y = 0.92 + pulse * (0.08 + escalation * 0.05)

	for i in range(_receiver_vanes.size()):
		var vane := _receiver_vanes[i]
		if vane == null or not is_instance_valid(vane):
			continue
		var vane_wave := sin(_phase - float(i) * 0.72)
		vane.position.y = (-0.08 + float(i % 2) * 0.18) + vane_wave * (0.08 + escalation * 0.05)
		vane.rotation.x = vane_wave * (0.07 + escalation * 0.035)
		vane.scale = Vector3.ONE * (0.94 + (0.5 + 0.5 * vane_wave) * 0.08)

func _active_actor() -> Node3D:
	if _eva != null and is_instance_valid(_eva) and _eva.enabled:
		return _eva
	if _ship != null and is_instance_valid(_ship) and _ship.enabled:
		return _ship
	return null

func _nearest_unresolved_fragment(actor: Node3D) -> Interactable:
	if actor == null or _campaign_world == null:
		return null
	var best_site: Interactable
	var best_distance := INF
	for site_id in _campaign_world.sites:
		if not str(site_id).begins_with("fragment|"):
			continue
		var site := _campaign_world.sites[site_id] as Interactable
		if site == null or not is_instance_valid(site) or not site.visible or site.completed:
			continue
		var distance := actor.global_position.distance_to(site.global_position)
		if distance < best_distance:
			best_distance = distance
			best_site = site
	return best_site

func escalation_level() -> float:
	if _campaign_world == null or not is_instance_valid(_campaign_world) or _campaign_world.campaign == null:
		return 0.0
	return clampf(float(_campaign_world.campaign.fragment_count()) / 2.0, 0.0, 1.0)

func pulse_rate() -> float:
	# Evidence changes the same phenomenon rather than spawning a new mechanic:
	# the contradiction makes the geometry visibly more structured and urgent.
	return 1.15 + escalation_level() * 0.85
