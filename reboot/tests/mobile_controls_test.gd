extends SceneTree

var failures := 0

func _init() -> void:
	var controls := MobileControls.new()
	root.add_child(controls)

	Input.action_press("throttle_up")
	Input.action_press("brake")
	Input.action_press("roll_left")
	controls.left_touch = 7
	controls.left_origin = Vector2(100, 100)
	controls.left_position = Vector2(140, 80)
	controls.set_mode("eva")

	_assert(not Input.is_action_pressed("throttle_up"), "ship throttle must release when switching to EVA")
	_assert(not Input.is_action_pressed("brake"), "ship brake must release when switching to EVA")
	_assert(not Input.is_action_pressed("roll_left"), "ship roll must release when switching to EVA")
	_assert(controls.left_touch == -1, "mode switch must invalidate the previous virtual-stick touch")

	Input.action_press("scan")
	Input.action_press("move_forward")
	controls.left_touch = 8
	controls.set_mode("ship")
	_assert(not Input.is_action_pressed("scan"), "EVA scan hold must release when switching to ship mode")
	_assert(not Input.is_action_pressed("move_forward"), "EVA movement must release when switching to ship mode")
	_assert(controls.left_touch == -1, "ship transition must start with a fresh virtual-stick touch")

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
