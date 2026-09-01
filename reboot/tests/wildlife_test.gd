extends SceneTree

var failures := 0

func _init() -> void:
	var wildlife := WildlifeSystem.new()
	var near_alert := wildlife.alert_level_for_neighbor(3.0, 1.0)
	var edge_alert := wildlife.alert_level_for_neighbor(WildlifeSystem.HERD_ALERT_RADIUS - 0.1, 1.0)
	var outside_alert := wildlife.alert_level_for_neighbor(WildlifeSystem.HERD_ALERT_RADIUS + 0.1, 1.0)
	var calm_alert := wildlife.alert_level_for_neighbor(3.0, 0.0)

	_assert(near_alert > edge_alert, "herd alert must weaken with distance")
	_assert(near_alert > 0.0, "nearby startled grazers must transfer alert")
	_assert(is_zero_approx(outside_alert), "alert must not propagate beyond the local herd radius")
	_assert(is_zero_approx(calm_alert), "calm neighbors must not fabricate disturbance")

	wildlife.free()
	if failures == 0:
		print("PALE SIGNAL WILDLIFE TESTS: PASS")
		quit(0)
	else:
		push_error("PALE SIGNAL WILDLIFE TESTS: %d FAILURE(S)" % failures)
		quit(1)

func _assert(value: bool, message: String) -> void:
	if not value:
		failures += 1
		push_error(message)
