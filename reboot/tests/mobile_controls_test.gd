extends SceneTree

var failures := 0

func _init() -> void:
	var controls := MobileControls.new()
	root.add_child(controls)

	Input.action_press("throttle_up")
	Input.action_press("brake")
	Input.action_press("roll_left")
	controls.left_touch = 7
	controls.look_touch = 17
	controls.left_origin = Vector2(100, 100)
	controls.left_position = Vector2(140, 80)
	controls.look_last = Vector2(520, 220)
	controls.set_mode("eva")

	_assert(not Input.is_action_pressed("throttle_up"), "ship throttle must release when switching to EVA")
	_assert(not Input.is_action_pressed("brake"), "ship brake must release when switching to EVA")
	_assert(not Input.is_action_pressed("roll_left"), "ship roll must release when switching to EVA")
	_assert(controls.left_touch == -1, "mode switch must invalidate the previous virtual-stick touch")
	_assert(controls.look_touch == -1, "mode switch must invalidate the previous camera-look touch")
	_assert(controls.look_last == Vector2.ZERO, "mode switch must clear stale camera-look coordinates")

	Input.action_press("scan")
	Input.action_press("move_forward")
	Input.action_press("interact")
	Input.action_press("tutorial_reset")
	controls.left_touch = 8
	controls.look_touch = 18
	controls.look_last = Vector2(640, 280)
	controls.set_mode("ship")
	_assert(not Input.is_action_pressed("scan"), "EVA scan hold must release when switching to ship mode")
	_assert(not Input.is_action_pressed("move_forward"), "EVA movement must release when switching to ship mode")
	_assert(not Input.is_action_pressed("interact"), "EVA interact tap must release when switching to ship mode")
	_assert(not Input.is_action_pressed("tutorial_reset"), "EVA recovery tap must release when switching to ship mode")
	_assert(controls.left_touch == -1, "ship transition must start with a fresh virtual-stick touch")
	_assert(controls.look_touch == -1, "ship transition must require a fresh camera-look touch")
	_assert(controls.look_last == Vector2.ZERO, "ship transition must not inherit stale camera-look deltas")

	Input.action_press("nav_toggle")
	Input.action_press("cutscene_skip")
	controls.set_mode("eva")
	_assert(not Input.is_action_pressed("nav_toggle"), "ship NAV tap must release when switching to EVA")
	_assert(not Input.is_action_pressed("cutscene_skip"), "cinematic skip tap must release during control-state cleanup")

	var source := FileAccess.get_file_as_string("res://scripts/mobile_controls.gd")
	_assert(source.contains("_add_tap_button(\"tutorial_reset\", \"RESET\""), "mobile EVA must expose tutorial/reconstruction recovery")
	_assert(source.contains("\"scan\",\"interact\",\"tutorial_reset\""), "mobile recovery control must be available in EVA mode")
	_assert(source.contains("_tap_action(\"cutscene_skip\")"), "mobile cinematic skip parity must remain intact")

	controls.free()
	if failures == 0:
		print("PALE SIGNAL MOBILE CONTROLS TEST: PASS")
		quit(0)
	else:
		push_error("PALE SIGNAL MOBILE CONTROLS TEST: %d FAILURE(S)" % failures)
		quit(1)

func _assert(value: bool, message: String) -> void:
	if not value:
		failures += 1
		push_error(message)