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

	_assert(wildlife.activity_for_state(0.0, 0.0, 0.0) == "GRAZE", "calm Flat Grazers must enter a stationary feeding beat")
	_assert(wildlife.activity_for_state(0.0, 5.0, 0.0) == "BROWSE", "calm Flat Grazers must alternate from feeding into browsing movement")
	_assert(wildlife.activity_for_state(WildlifeSystem.FLEE_THRESHOLD, 0.0, 0.0) == "FLEE", "fear must interrupt the feeding cycle immediately")

	var identity := wildlife._make_flat_grazer_fallback(0)
	_assert(identity.name == "FlatGrazerIdentity", "Flat Grazer fallback must retain its authored species identity root")
	_assert(identity.get_node_or_null("BrowsingDisk") != null, "Flat Grazer must retain its low browsing-disk silhouette")
	_assert(identity.get_node_or_null("LateralSensorySail") != null, "Flat Grazer must retain its asymmetric sensory sail")
	_assert(identity.get_node_or_null("GrazingRake01") != null, "Flat Grazer must retain a functional grazing-rake head cue")
	_assert(identity.get_node_or_null("StiltLeg06") != null, "Flat Grazer must retain six-leg locomotion identity")
	_assert(identity.get_node_or_null("FieldSensorL") != null and identity.get_node_or_null("FieldSensorR") != null, "Flat Grazer must retain restrained paired field sensors")
	identity.free()

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
