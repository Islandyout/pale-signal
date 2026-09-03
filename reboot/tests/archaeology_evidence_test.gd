extends SceneTree

func _init() -> void:
	var archaeology := ArchaeologySystem.new()
	archaeology.mark_scanned()
	archaeology.begin()
	if archaeology.required_passes != 3:
		push_error("hero archaeology must require three distinct evidence correlations")
		quit(1)
		return
	if archaeology.evidence_layer_name() != "LOAD PATH":
		push_error("first archaeology pass must expose the load-path evidence layer")
		quit(1)
		return
	archaeology.pass_index = 1
	if archaeology.evidence_layer_name() != "RESTRAINT TRACE":
		push_error("second archaeology pass must expose the restraint-trace evidence layer")
		quit(1)
		return
	archaeology.pass_index = 2
	if archaeology.evidence_layer_name() != "ALTERATION SEQUENCE":
		push_error("third archaeology pass must expose chronology that can challenge the storm-damage reading")
		quit(1)
		return
	var source := FileAccess.get_file_as_string("res://scripts/archaeology_system.gd")
	if not source.contains("EVIDENCE CORRELATED"):
		push_error("completed reconstruction must report evidence correlation rather than a generic lock")
		quit(1)
		return
	if not source.contains("storm damage"):
		push_error("hero archaeology must connect physical chronology to the conflicting-history premise")
		quit(1)
		return
	var game_root_source := FileAccess.get_file_as_string("res://scripts/game_root.gd")
	if not game_root_source.contains("FIRST-HOUR EVIDENCE %d / 2 RECOVERED"):
		push_error("campaign archaeology feedback must stay inside the authored first-hour evidence scope")
		quit(1)
		return
	if game_root_source.contains("PALE SIGNAL FRAGMENT %d / 7 RECOVERED"):
		push_error("campaign archaeology feedback must not expose dormant seven-fragment progression during the first hour")
		quit(1)
		return
	if not game_root_source.contains("WorldArt.decorate_training_foundation(ruin)"):
		push_error("hero tutorial archaeology must use the authored presentation layer")
		quit(1)
		return
	var world_art_source := FileAccess.get_file_as_string("res://scripts/world_art.gd")
	for authored_marker in ["HeroArchaeologyLanguage", "LoadRib", "RestraintShoe", "EvidenceTrace", "SurveyDatum"]:
		if not world_art_source.contains(authored_marker):
			push_error("hero archaeology presentation lost authored marker: %s" % authored_marker)
			quit(1)
			return
	var overlay_source := FileAccess.get_file_as_string("res://scripts/evidence_overlay.gd")
	if not overlay_source.contains("_campaign_instance_id"):
		push_error("evidence overlay must track campaign identity across scene/save transitions")
		quit(1)
		return
	if not overlay_source.contains("_campaign_instance_id != campaign_id") or not overlay_source.contains("_seen_notes.clear()"):
		push_error("evidence overlay must reseed seen evidence instead of replaying loaded notes as new discoveries")
		quit(1)
		return
	archaeology.free()
	print("ARCHAEOLOGY EVIDENCE TEST: PASS")
	quit(0)
