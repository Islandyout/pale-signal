extends CanvasLayer

const FIRST_HOUR_NOTES := ["tethys_1", "tethys_2"]
const DISPLAY_SECONDS := 8.0

var _panel: PanelContainer
var _title: Label
var _detail: Label
var _seen_notes: Dictionary = {}
var _campaign_ready := false
var _campaign_instance_id := 0
var _hide_timer := 0.0

func _ready() -> void:
	layer = 30
	_build_ui()

func _process(delta: float) -> void:
	if _hide_timer > 0.0:
		_hide_timer = maxf(0.0, _hide_timer - delta)
		if _hide_timer <= 0.0:
			_panel.visible = false
	_poll_campaign_evidence()

func _build_ui() -> void:
	_panel = PanelContainer.new()
	_panel.name = "EvidenceOverlayPanel"
	_panel.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_panel.offset_left = -300.0
	_panel.offset_right = 300.0
	_panel.offset_top = 170.0
	_panel.offset_bottom = 292.0
	_panel.visible = false
	add_child(_panel)

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

func _poll_campaign_evidence() -> void:
	var scene := get_tree().current_scene
	if scene == null:
		return
	var campaign = scene.get("campaign")
	if campaign == null or not (campaign is Object):
		return
	var notes = campaign.get("evidence_notes")
	if not (notes is Dictionary):
		return
	var campaign_id := campaign.get_instance_id()
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
	_title.text = "EVIDENCE CORRELATED · %s" % str(note.get("title", "FIELD NOTE")).to_upper()
	_detail.text = str(note.get("detail", ""))
	_panel.visible = true
	_hide_timer = DISPLAY_SECONDS
