extends SceneTree

func _init() -> void:
	var archaeology := ArchaeologySystem.new()
	archaeology.mark_scanned()
	archaeology.begin()
	if archaeology.evidence_layer_name() != "LOAD PATH":
		push_error("first archaeology pass must expose the load-path evidence layer")
		quit(1)
		return
	archaeology.pass_index = 1
	if archaeology.evidence_layer_name() != "RESTRAINT TRACE":
		push_error("second archaeology pass must expose the restraint-trace evidence layer")
		quit(1)
		return
	var source := FileAccess.get_file_as_string("res://scripts/archaeology_system.gd")
	if not source.contains("EVIDENCE CORRELATED"):
		push_error("completed reconstruction must report evidence correlation rather than a generic lock")
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
	archaeology.free()
	print("ARCHAEOLOGY EVIDENCE TEST: PASS")
	quit(0)
