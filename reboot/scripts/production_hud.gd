extends CanvasLayer

const AlignmentTrack = preload("res://scripts/reconstruction_alignment_track.gd")

var root: Node
var tutorial: TutorialDirector
var scanner: ScannerSystem
var archaeology: ArchaeologySystem
var campaign: CampaignState
var ship: ShipController

var objective_panel: PanelContainer
var objective_title: Label
var objective_detail: Label
var objective_progress: ProgressBar
var recovery_row: HBoxContainer
var reset_button: Button
var skip_button: Button
var campaign_label: Label
var ship_status_label: Label
var context_panel: PanelContainer
var context_label: Label
var scan_panel: PanelContainer
var scan_label: Label
var scan_bar: ProgressBar
var reconstruction_panel: PanelContainer
var reconstruction_stage: Label
var reconstruction_instruction: Label
var alignment_track
var _bound := false

func _ready() -> void:
	layer = 5
	_build_hud()
	call_deferred("_bind_systems")

func _process(_delta: float) -> void:
	if not _bound:
		return
	_update_context()
	_update_campaign_summary()

func _build_hud() -> void:
	objective_panel = PanelContainer.new()
	objective_panel.offset_left = 22.0
	objective_panel.offset_top = 22.0
	objective_panel.offset_right = 442.0
	objective_panel.offset_bottom = 162.0
	objective_panel.add_theme_stylebox_override("panel", _panel_style(0.82))
	add_child(objective_panel)
	var objective_box := VBoxContainer.new()
	objective_box.add_theme_constant_override("separation", 4)
	objective_panel.add_child(objective_box)

	objective_title = Label.new()
	objective_title.add_theme_font_size_override("font_size", 17)
	objective_box.add_child(objective_title)
	objective_detail = Label.new()
	objective_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	objective_detail.add_theme_font_size_override("font_size", 13)
	objective_detail.custom_minimum_size = Vector2(390, 42)
	objective_box.add_child(objective_detail)
	objective_progress = ProgressBar.new()
	objective_progress.max_value = 1.0
	objective_progress.show_percentage = false
	objective_progress.custom_minimum_size = Vector2(390, 7)
	objective_box.add_child(objective_progress)

	recovery_row = HBoxContainer.new()
	recovery_row.add_theme_constant_override("separation", 8)
	objective_box.add_child(recovery_row)
	reset_button = Button.new()
	reset_button.text = "RESET STEP"
	reset_button.flat = true
	recovery_row.add_child(reset_button)
	skip_button = Button.new()
	skip_button.text = "SKIP LESSON"
	skip_button.flat = true
	recovery_row.add_child(skip_button)

	campaign_label = Label.new()
	campaign_label.anchor_left = 1.0
	campaign_label.anchor_right = 1.0
	campaign_label.offset_left = -500.0
	campaign_label.offset_right = -22.0
	campaign_label.offset_top = 22.0
	campaign_label.offset_bottom = 50.0
	campaign_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	campaign_label.add_theme_font_size_override("font_size", 14)
	add_child(campaign_label)

	ship_status_label = Label.new()
	ship_status_label.anchor_left = 1.0
	ship_status_label.anchor_right = 1.0
	ship_status_label.offset_left = -500.0
	ship_status_label.offset_right = -22.0
	ship_status_label.offset_top = 50.0
	ship_status_label.offset_bottom = 76.0
	ship_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	ship_status_label.add_theme_font_size_override("font_size", 13)
	add_child(ship_status_label)

	context_panel = PanelContainer.new()
	context_panel.anchor_left = 0.5
	context_panel.anchor_right = 0.5
	context_panel.anchor_top = 1.0
	context_panel.anchor_bottom = 1.0
	context_panel.offset_left = -390.0
	context_panel.offset_right = 390.0
	context_panel.offset_top = -60.0
	context_panel.offset_bottom = -18.0
	context_panel.add_theme_stylebox_override("panel", _panel_style(0.74))
	add_child(context_panel)
	context_label = Label.new()
	context_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	context_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	context_label.add_theme_font_size_override("font_size", 14)
	context_panel.add_child(context_label)

	scan_panel = PanelContainer.new()
	scan_panel.anchor_left = 0.5
	scan_panel.anchor_right = 0.5
	scan_panel.anchor_top = 1.0
	scan_panel.anchor_bottom = 1.0
	scan_panel.offset_left = -185.0
	scan_panel.offset_right = 185.0
	scan_panel.offset_top = -118.0
	scan_panel.offset_bottom = -72.0
	scan_panel.add_theme_stylebox_override("panel", _panel_style(0.76))
	scan_panel.visible = false
	add_child(scan_panel)
	var scan_box := VBoxContainer.new()
	scan_box.add_theme_constant_override("separation", 3)
	scan_panel.add_child(scan_box)
	scan_label = Label.new()
	scan_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	scan_label.add_theme_font_size_override("font_size", 12)
	scan_box.add_child(scan_label)
	scan_bar = ProgressBar.new()
	scan_bar.max_value = 1.0
	scan_bar.show_percentage = false
	scan_bar.custom_minimum_size = Vector2(340, 8)
	scan_box.add_child(scan_bar)

	reconstruction_panel = PanelContainer.new()
	reconstruction_panel.anchor_left = 0.5
	reconstruction_panel.anchor_right = 0.5
	reconstruction_panel.anchor_top = 1.0
	reconstruction_panel.anchor_bottom = 1.0
	reconstruction_panel.offset_left = -270.0
	reconstruction_panel.offset_right = 270.0
	reconstruction_panel.offset_top = -224.0
	reconstruction_panel.offset_bottom = -76.0
	reconstruction_panel.add_theme_stylebox_override("panel", _panel_style(0.90))
	reconstruction_panel.visible = false
	add_child(reconstruction_panel)
	var reconstruction_box := VBoxContainer.new()
	reconstruction_box.add_theme_constant_override("separation", 4)
	reconstruction_panel.add_child(reconstruction_box)
	var reconstruction_title := Label.new()
	reconstruction_title.text = "ARCHAEOLOGY  //  RECONSTRUCTION"
	reconstruction_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	reconstruction_title.add_theme_font_size_override("font_size", 14)
	reconstruction_box.add_child(reconstruction_title)
	reconstruction_stage = Label.new()
	reconstruction_stage.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	reconstruction_stage.add_theme_font_size_override("font_size", 18)
	reconstruction_box.add_child(reconstruction_stage)
	alignment_track = AlignmentTrack.new()
	alignment_track.custom_minimum_size = Vector2(500, 34)
	reconstruction_box.add_child(alignment_track)
	reconstruction_instruction = Label.new()
	reconstruction_instruction.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	reconstruction_instruction.add_theme_font_size_override("font_size", 12)
	reconstruction_box.add_child(reconstruction_instruction)

func _bind_systems() -> void:
	root = get_parent()
	if root == null:
		return
	tutorial = root.get("tutorial") as TutorialDirector
	scanner = root.get("scanner") as ScannerSystem
	archaeology = root.get("archaeology") as ArchaeologySystem
	campaign = root.get("campaign") as CampaignState
	ship = root.get("ship") as ShipController
	if tutorial == null or scanner == null or archaeology == null or campaign == null or ship == null:
		call_deferred("_bind_systems")
		return

	var old_title := root.get("hud_title") as Label
	var old_detail := root.get("hud_detail") as Label
	var old_progress := root.get("hud_progress") as ProgressBar
	if old_title != null and old_detail != null and old_progress != null:
		_on_objective_changed(old_title.text, old_detail.text, old_progress.value)

	_hide_legacy_hud()
	tutorial.objective_changed.connect(_on_objective_changed)
	tutorial.tutorial_completed.connect(_on_tutorial_completed)
	scanner.scan_progress.connect(_on_scan_progress)
	archaeology.reconstruction_state.connect(_on_reconstruction_state)
	archaeology.reconstruction_complete.connect(_on_reconstruction_complete)
	reset_button.pressed.connect(_reset_step)
	skip_button.pressed.connect(_skip_step)
	_bound = true
	_update_context()
	_update_campaign_summary()

func _hide_legacy_hud() -> void:
	for child in root.get_children():
		if child is CanvasLayer and child != self:
			for ui in child.get_children():
				if ui is PanelContainer or ui is Label or ui is ProgressBar:
					ui.visible = false

func _on_objective_changed(title: String, detail: String, progress: float) -> void:
	objective_title.text = title
	objective_detail.text = detail
	objective_progress.value = clampf(progress, 0.0, 1.0)

func _on_tutorial_completed() -> void:
	recovery_row.visible = false
	reconstruction_panel.visible = false

func _on_scan_progress(value: float, label: String) -> void:
	if archaeology != null and archaeology.active:
		scan_panel.visible = false
		return
	scan_label.text = label
	scan_bar.value = clampf(value, 0.0, 1.0)
	scan_panel.visible = not label.is_empty() and value > 0.0

func _on_reconstruction_state(stage: String, alignment: float, target: float, lock_ready: bool) -> void:
	if archaeology == null or not archaeology.active:
		reconstruction_panel.visible = false
		return
	reconstruction_panel.visible = true
	scan_panel.visible = false
	reconstruction_stage.text = stage
	alignment_track.set_state(alignment, target, archaeology.lock_tolerance, lock_ready, archaeology.evidence_scanned)
	if not archaeology.evidence_scanned:
		reconstruction_instruction.text = "HOLD SCAN ON THE FOUNDATION TO RESOLVE THE EVIDENCE"
	elif lock_ready:
		reconstruction_instruction.text = "LOCK ZONE ACQUIRED  ·  PRESS E"
	else:
		reconstruction_instruction.text = "A / D  ·  ALIGN THE WHITE CURSOR WITH THE TARGET BAND"

func _on_reconstruction_complete() -> void:
	reconstruction_panel.visible = false

func _reset_step() -> void:
	if archaeology != null and archaeology.active:
		archaeology.cancel()
	if tutorial != null:
		tutorial.reset_current()

func _skip_step() -> void:
	if archaeology != null and archaeology.active:
		archaeology.cancel()
	if tutorial != null:
		tutorial.skip_current()

func _update_context() -> void:
	var old_hint := root.get("hint_label") as Label
	if old_hint == null:
		return
	context_label.text = old_hint.text
	context_panel.visible = not context_label.text.is_empty() and not reconstruction_panel.visible

func _update_campaign_summary() -> void:
	var location := str(root.get("current_world"))
	if location.is_empty():
		location = "DEEP SPACE"
	campaign_label.text = "%s  ·  SIGNAL %d/7  ·  ROUTE %s" % [location.to_upper(), campaign.fragment_count(), campaign.selected_world.to_upper()]
	var mode := str(root.get("mode"))
	ship_status_label.visible = mode == "ship"
	if ship_status_label.visible:
		ship_status_label.text = "FUEL %.0f/%.0f   ·   HULL %.0f/%.0f" % [ship.fuel, ship.max_fuel, ship.hull, ship.max_hull]

func _panel_style(alpha: float) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.025, 0.045, 0.050, alpha)
	style.border_color = Color(0.45, 0.68, 0.66, 0.36)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 7
	style.corner_radius_top_right = 7
	style.corner_radius_bottom_left = 7
	style.corner_radius_bottom_right = 7
	style.content_margin_left = 12.0
	style.content_margin_right = 12.0
	style.content_margin_top = 8.0
	style.content_margin_bottom = 8.0
	return style
