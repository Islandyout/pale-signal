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
	archaeology.free()
	print("ARCHAEOLOGY EVIDENCE TEST: PASS")
	quit(0)
