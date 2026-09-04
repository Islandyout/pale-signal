extends CanvasLayer

const FIRST_HOUR_NOTES := ["tethys_1", "tethys_2"]
const DISPLAY_SECONDS := 8.0
const PANEL_MARGIN := 16.0
const PANEL_MAX_WIDTH := 600.0
const PANEL_HEIGHT := 122.0

var _panel: PanelContainer
var _title: Label
var _detail: Label
var _seen_notes: Dictionary = {}
var _campaign_ready := false
var _campaign_instance_id := 0
var _archaeology_instance_id := 0
var _hide_timer := 0.0
var _pending_cards: Array[Dictionary] = []

func _ready() -> void:
	layer = 30
	_build_ui()
	get_viewport().size_changed.connect(_layout_panel)

func _process(delta: float) -> void:
	if _hide_timer > 0.0:
		_hide_timer = maxf(0.0, _hide_timer - delta)
		if _hide_timer <= 0.0:
			_show_next_card()
	_poll_archaeology()
	_poll_campaign_evidence()

func _build_ui() -> void:
	_panel = PanelContainer.new()
	_panel.name = "EvidenceOverlayPanel"
	_panel.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_panel.visible = false
	add_child(_panel)
	_layout_panel()

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	_panel.add_child(margin)

	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 7)
	margin.add_child(stack)

	_title = Label.new()
	_title.add_theme_font_size_override("font_size", 18)
	_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stack.add_child(_title)

	_detail = Label.new()
	_detail.add_theme_font_size_override("font_size", 14)
	_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stack.add_child(_detail)

func _layout_panel() -> void:
	if _panel == null:
		return
	var viewport_size := get_viewport_rect().size
	var panel_width := minf(PANEL_MAX_WIDTH, maxf(260.0, viewport_size.x - PANEL_MARGIN * 2.0))
	var top := 96.0 if viewport_size.y < 500.0 else 170.0
	_panel.offset_left = -panel_width * 0.5
	_panel.offset_right = panel_width * 0.5
	_panel.offset_top = top
	_panel.offset_bottom = top + PANEL_HEIGHT

func _poll_archaeology() -> void:
	var scene := get_tree().current_scene
	if scene == null:
		return
	var archaeology = scene.get("archaeology")
	if archaeology == null or not (archaeology is Object):
		return
	var archaeology_object := archaeology as Object
	var archaeology_id := archaeology_object.get_instance_id()
	if _archaeology_instance_id == archaeology_id:
		return
	_archaeology_instance_id = archaeology_id
	if archaeology_object.has_signal("evidence_pass_locked"):
		archaeology_object.connect("evidence_pass_locked", _on_archaeology_evidence_pass)

func _on_archaeology_evidence_pass(layer_name: String, finding: String, pass_number: int, total_passes: int) -> void:
	_queue_card(
		"EVIDENCE %d / %d · %s" % [pass_number, total_passes, layer_name],
		finding
	)

func _poll_campaign_evidence() -> void:
	var scene := get_tree().current_scene
	if scene == null:
		return
	var campaign = scene.get("campaign")
	if campaign == null or not (campaign is Object):
		return
	var campaign_object := campaign as Object
	var notes = campaign_object.get("evidence_notes")
	if not (notes is Dictionary):
		return
	var campaign_id: int = campaign_object.get_instance_id()
	if not _campaign_ready or _campaign_instance_id != campaign_id:
		_campaign_instance_id = campaign_id
		_seen_notes.clear()
		for note_id in FIRST_HOUR_NOTES:
			if notes.has(note_id):
				_seen_notes[note_id] = true
		_campaign_ready = true
		return
	for note_id in FIRST_HOUR_NOTES:
		if _seen_notes.has(note_id) or not notes.has(note_id):
			continue
		_seen_notes[note_id] = true
		var note = notes[note_id]
		if note is Dictionary:
			_show_note(note as Dictionary)
		return

func _show_note(note: Dictionary) -> void:
	_queue_card(
		"EVIDENCE CORRELATED · %s" % str(note.get("title", "FIELD NOTE")).to_upper(),
		str(note.get("detail", ""))
	)

func _queue_card(title: String, detail: String) -> void:
	# Archaeology can publish its final physical inference in the same completion
	# sequence that campaign state adds a broader evidence note. Never let the
	# later card overwrite a finding before the player has had time to read it.
	var card := {"title": title, "detail": detail}
	if _panel.visible and _hide_timer > 0.0:
		_pending_cards.append(card)
		return
	_present_card(card)

func _present_card(card: Dictionary) -> void:
	_title.text = str(card.get("title", "EVIDENCE"))
	_detail.text = str(card.get("detail", ""))
	_panel.visible = true
	_hide_timer = DISPLAY_SECONDS

func _show_next_card() -> void:
	if not _pending_cards.is_empty():
		_present_card(_pending_cards.pop_front())
		return
	_panel.visible = false
