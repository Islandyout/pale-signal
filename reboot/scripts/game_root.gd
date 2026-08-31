extends Node3D

var eva: EVAController
var ship: ShipController
var scanner: ScannerSystem
var archaeology: ArchaeologySystem
var tutorial: TutorialDirector
var sample: Interactable
var ruin: Interactable
var hud_title: Label
var hud_detail: Label
var hud_progress: ProgressBar
var hint_label: Label
var scan_label: Label
var scan_bar: ProgressBar
var mode := "eva"
var sample_collected := false
var intro_camera: Camera3D
var cutscene_active := false
var boarding_range := 5.0
var _intro_tween: Tween

func _ready() -> void:
	InputBootstrap.ensure_actions()
	_build_environment()
	_build_world()
	_build_ui()
	_connect_systems()
	_set_mode("eva")
	tutorial.start()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("cutscene_skip") and cutscene_active:
		_finish_cutscene()
	if mode == "eva" and not cutscene_active:
		scanner.tick(delta, eva.camera, true)
		archaeology.tick(delta)
		_update_interaction_hint()
	else:
		scanner.tick(delta, eva.camera, false)
	if Input.is_action_just_pressed("tutorial"):
		hud_title.visible = not hud_title.visible
		hud_detail.visible = hud_title.visible
		hud_progress.visible = hud_title.visible
	if Input.is_action_just_pressed("interact") and mode == "eva" and not cutscene_active:
		_handle_interaction()

func _build_environment() -> void:
	var env_node := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("#6f8894")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#9fb8bb")
	env.ambient_light_energy = 0.75
	env.fog_enabled = true
	env.fog_light_color = Color("#70888d")
	env.fog_density = 0.0025
	env_node.environment = env
	add_child(env_node)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-52, -34, 0)
	sun.light_energy = 1.25
	sun.shadow_enabled = true
	add_child(sun)

func _build_world() -> void:
	var ground := StaticBody3D.new()
	ground.name = "TethysGround"
	var mesh_i := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(1200, 1, 1200)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("#445e51")
	mat.roughness = 0.95
	mesh.material = mat
	mesh_i.mesh = mesh
	mesh_i.position.y = -0.5
	ground.add_child(mesh_i)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(1200, 1, 1200)
	shape.shape = box
	shape.position.y = -0.5
	ground.add_child(shape)
	add_child(ground)

	for i in range(26):
		var reed := MeshInstance3D.new()
		var reed_mesh := CylinderMesh.new()
		reed_mesh.top_radius = 0.04
		reed_mesh.bottom_radius = 0.07
		reed_mesh.height = 1.1 + float(i % 5) * 0.16
		reed.mesh = reed_mesh
		reed.position = Vector3(-18 + (i * 7) % 42, reed_mesh.height * 0.5, -16 - (i * 11) % 40)
		add_child(reed)

	eva = EVAController.new()
	eva.name = "EVA"
	eva.position = Vector3(0, 1.0, 5.5)
	add_child(eva)

	ship = ShipController.new()
	ship.name = "Ship"
	ship.position = Vector3(0, 1.0, 0)
	add_child(ship)
	var ship_fallback := MeshInstance3D.new()
	var ship_mesh := BoxMesh.new()
	ship_mesh.size = Vector3(2.0, 1.0, 4.0)
	var ship_mat := StandardMaterial3D.new()
	ship_mat.albedo_color = Color("#2a3945")
	ship_mat.metallic = 0.55
	ship_mat.roughness = 0.38
	ship_mesh.material = ship_mat
	ship_fallback.mesh = ship_mesh
	ship.add_child(AssetLoader.instantiate_or_fallback("ship", ship_fallback))

	sample = _make_interactable("field_sample", "Pale Reed Sample", Vector3(6, 0.8, -7), true)
	ruin = _make_interactable("foundation", "Buried Foundation Seam", Vector3(-8, 0.8, -14), false)
	var ruin_mesh := ruin.get_node("Visual") as MeshInstance3D
	if ruin_mesh:
		var b := BoxMesh.new()
		b.size = Vector3(4.2, 0.55, 2.1)
		ruin_mesh.mesh = b

	scanner = ScannerSystem.new()
	add_child(scanner)
	archaeology = ArchaeologySystem.new()
	add_child(archaeology)
	tutorial = TutorialDirector.new()
	add_child(tutorial)

	intro_camera = Camera3D.new()
	intro_camera.position = Vector3(14, 9, 18)
	intro_camera.look_at_from_position(intro_camera.position, Vector3(0, 1, -5), Vector3.UP)
	add_child(intro_camera)

func _make_interactable(id: String, label: String, position_: Vector3, scan_required: bool) -> Interactable:
	var area := Interactable.new()
	area.interaction_id = id
	area.display_name = label
	area.requires_scan = scan_required
	area.position = position_
	var visual := MeshInstance3D.new()
	visual.name = "Visual"
	var sphere := SphereMesh.new()
	sphere.radius = 0.55
	sphere.height = 1.1
	visual.mesh = sphere
	area.add_child(visual)
	var collision := CollisionShape3D.new()
	var cshape := SphereShape3D.new()
	cshape.radius = 0.75
	collision.shape = cshape
	area.add_child(collision)
	add_child(area)
	return area

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var panel := PanelContainer.new()
	panel.position = Vector2(18, 18)
	panel.size = Vector2(470, 150)
	layer.add_child(panel)
	var box := VBoxContainer.new()
	panel.add_child(box)
	hud_title = Label.new()
	hud_title.add_theme_font_size_override("font_size", 18)
	box.add_child(hud_title)
	hud_detail = Label.new()
	hud_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(hud_detail)
	hud_progress = ProgressBar.new()
	hud_progress.max_value = 1.0
	box.add_child(hud_progress)
	hint_label = Label.new()
	hint_label.position = Vector2(18, 680)
	layer.add_child(hint_label)
	scan_label = Label.new()
	scan_label.position = Vector2(510, 610)
	layer.add_child(scan_label)
	scan_bar = ProgressBar.new()
	scan_bar.position = Vector2(510, 636)
	scan_bar.size = Vector2(260, 18)
	scan_bar.max_value = 1.0
	layer.add_child(scan_bar)
	var footer := Label.new()
	footer.position = Vector2(18, 650)
	footer.text = "WASD MOVE/THROTTLE · MOUSE LOOK (never steers ship) · F/RMB SCAN · E INTERACT · N NAV · X BRAKE · F2 TUTORIAL"
	layer.add_child(footer)

func _connect_systems() -> void:
	eva.moved.connect(func(d): tutorial.event("eva_moved", d))
	eva.looked.connect(func(d): tutorial.event("eva_looked", d))
	scanner.atmosphere_verified.connect(func(): tutorial.event("atmosphere_verified"))
	scanner.subject_scanned.connect(_on_subject_scanned)
	scanner.scan_progress.connect(func(value, label): scan_bar.value = value; scan_label.text = label)
	archaeology.reconstruction_progress.connect(func(value): scan_bar.value = value; scan_label.text = "RECONSTRUCTION ALIGNMENT" if archaeology.active else scan_label.text)
	archaeology.reconstruction_complete.connect(func(): tutorial.event("archaeology_complete"))
	ship.launched.connect(func(): tutorial.event("launched"))
	ship.crossed_atmosphere.connect(func(): tutorial.event("crossed_atmosphere"))
	ship.nav_state_changed.connect(func(state): tutorial.event("nav_state", state); hint_label.text = "NAV: " + state)
	ship.touchdown.connect(func(v, l, safe): tutorial.event("touchdown", {"vertical":v, "lateral":l, "safe":safe}); hint_label.text = "TOUCHDOWN %s · V %.1f · L %.1f" % ["SAFE" if safe else "HARD", v, l])
	tutorial.objective_changed.connect(func(title, detail, progress): hud_title.text = title; hud_detail.text = detail; hud_progress.value = progress)
	tutorial.lesson_completed.connect(func(_id): SaveSystem.save_state({"tutorial": tutorial.snapshot()}))
	tutorial.request_intro_cutscene.connect(_play_intro_cutscene)
	tutorial.request_reveal_cutscene.connect(_play_reveal_cutscene)

func _on_subject_scanned(target: Interactable) -> void:
	if target == sample: tutorial.event("subject_scanned", target)
	elif target == ruin: archaeology.mark_scanned()

func _handle_interaction() -> void:
	if eva.global_position.distance_to(ship.global_position) <= boarding_range:
		_set_mode("ship")
		tutorial.event("boarded")
		return
	if eva.global_position.distance_to(sample.global_position) <= 2.2:
		if sample.scanned and not sample_collected:
			sample_collected = true
			sample.completed = true
			sample.visible = false
			tutorial.event("sample_collected")
			hint_label.text = "PHYSICAL SAMPLE SECURED"
		elif not sample.scanned:
			hint_label.text = "IDENTIFY THE SAMPLE WITH THE SCANNER FIRST"
		return
	if eva.global_position.distance_to(ruin.global_position) <= 3.0:
		if not archaeology.active and not archaeology.completed:
			archaeology.begin()
			hint_label.text = "SCAN FOUNDATION, THEN A/D ALIGN · E LOCK"
		return

func _update_interaction_hint() -> void:
	if eva.global_position.distance_to(ship.global_position) <= boarding_range:
		hint_label.text = "E · BOARD SHIP"
	elif eva.global_position.distance_to(sample.global_position) <= 2.2 and not sample_collected:
		hint_label.text = "E · COLLECT SAMPLE" if sample.scanned else "SCAN BEFORE COLLECTION"
	elif eva.global_position.distance_to(ruin.global_position) <= 3.0 and not archaeology.completed:
		hint_label.text = "E · INSPECT FOUNDATION"

func _set_mode(value: String) -> void:
	mode = value
	var ship_active := value == "ship"
	eva.set_active(not ship_active)
	ship.set_active(ship_active)
	if ship_active: eva.position = ship.position + Vector3(0, 1.1, 0)
	else: eva.position = ship.position + Vector3(0, 1.0, 4.8)

func _play_intro_cutscene() -> void:
	cutscene_active = true
	intro_camera.current = true
	eva.camera.current = false
	ship.camera.current = false
	intro_camera.global_position = Vector3(14, 10, 18)
	intro_camera.look_at(Vector3(0, 1, -5), Vector3.UP)
	_intro_tween = create_tween()
	_intro_tween.tween_property(intro_camera, "global_position", Vector3(-10, 6, 10), 3.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_intro_tween.tween_callback(_finish_cutscene)

func _play_reveal_cutscene() -> void:
	cutscene_active = true
	intro_camera.current = true
	eva.camera.current = false
	intro_camera.global_position = ruin.global_position + Vector3(6, 4, 7)
	intro_camera.look_at(ruin.global_position, Vector3.UP)
	_intro_tween = create_tween()
	_intro_tween.tween_property(intro_camera, "global_position", ruin.global_position + Vector3(-5, 3, 5), 1.8)
	_intro_tween.tween_callback(_finish_cutscene)

func _finish_cutscene() -> void:
	if _intro_tween and _intro_tween.is_running(): _intro_tween.kill()
	cutscene_active = false
	intro_camera.current = false
	if mode == "eva": eva.camera.current = true
	else: ship.camera.current = true
