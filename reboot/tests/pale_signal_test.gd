extends SceneTree

var failures := 0

func _init() -> void:
	var source := FileAccess.get_file_as_string("res://scripts/pale_signal_system.gd")
	_assert(not source.is_empty(), "Pale Signal production system must be present")
	_assert(source.contains("fragment_count()"), "Pale Signal escalation must read earned fragment evidence")
	_assert(source.contains("_nearest_unresolved_fragment"), "Pale Signal must stay anchored to physical unresolved evidence sites")
	_assert(source.contains("pulse_rate()"), "Pale Signal must escalate the same phenomenon rather than substitute a new mechanic")
	for forbidden_mutator in [
		"collect_fragment(",
		"collect_resource(",
		"record_evidence(",
		"buy_upgrade(",
		"tutorial.event(",
		"SaveSystem.save_state(",
		"campaign.restore(",
	]:
		_assert(not source.contains(forbidden_mutator), "Pale Signal observational layer must not mutate gameplay state via %s" % forbidden_mutator)

	if failures == 0:
		print("PALE SIGNAL PHENOMENON CONTRACT: PASS")
		quit(0)
	else:
		push_error("PALE SIGNAL PHENOMENON CONTRACT: %d FAILURE(S)" % failures)
		quit(1)

func _assert(value: bool, message: String) -> void:
	if not value:
		failures += 1
		push_error(message)
