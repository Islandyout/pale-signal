extends SceneTree

var failures := 0

func _init() -> void:
	_test_scanning_does_not_collect()
	_test_archaeology_requires_scan_and_alignment()
	_test_vtol_is_pitch_independent_contract()
	_test_camera_steering_contract()
	_test_save_round_trip_shape()
	if failures == 0:
		print("PALE SIGNAL REBOOT TESTS: PASS")
		quit(0)
	else:
		push_error("PALE SIGNAL REBOOT TESTS: %d FAILURE(S)" % failures)
		quit(1)

func _assert(value: bool, message: String) -> void:
	if not value:
		failures += 1
		push_error(message)

func _test_scanning_does_not_collect() -> void:
	var item := Interactable.new()
	item.requires_scan = true
	_assert(not item.can_use(), "unscanned resource must not be collectible")
	item.scanned = true
	_assert(item.can_use(), "scanned resource should become collectible")
	_assert(not item.completed, "scanning must not silently collect")
	item.free()

func _test_archaeology_requires_scan_and_alignment() -> void:
	var a := ArchaeologySystem.new()
	a.begin()
	_assert(not a.evidence_scanned, "archaeology must begin without fabricated evidence")
	_assert(not a.completed, "archaeology cannot auto-complete")
	a.free()

func _test_vtol_is_pitch_independent_contract() -> void:
	var source := FileAccess.get_file_as_string("res://scripts/ship_controller.gd")
	_assert(source.contains("Vector3.UP * max_vtol_thrust"), "VTOL lift must use world-up lift")
	_assert(source.contains("independent of nose pitch"), "VTOL pitch-independence contract missing")

func _test_camera_steering_contract() -> void:
	var source := FileAccess.get_file_as_string("res://scripts/ship_controller.gd")
	_assert(source.contains("Camera look is deliberately independent of ship steering"), "camera/steering separation contract missing")
	_assert(not source.contains("rotate_y(-event.relative.x"), "mouse-look must not rotate the ship")

func _test_save_round_trip_shape() -> void:
	var state := {"tutorial": {"index": 3, "completed": {"move": true}}}
	_assert(SaveSystem.save_state(state), "save should succeed")
	var loaded := SaveSystem.load_state()
	_assert(loaded.has("tutorial"), "save should load tutorial state")
