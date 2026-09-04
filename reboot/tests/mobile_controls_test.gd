extends SceneTree

var failures := 0

func _init() -> void:
	# Standalone --script tests do not instantiate GameRoot, so mirror the
	# production startup contract explicitly before exercising virtual input.
	InputBootstrap.ensure_actions()

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

	# Contract-level behavior: the ship touch stick owns explicit steering only.
	# Screen-right + screen-up must map to yaw-right + pitch-up, while roll stays
	# on its dedicated buttons and camera look is not synthesized as steering.
	controls.left_origin = Vector2(200, 200)
	controls.left_position = Vector2(260, 140)
	controls._update_left_actions()
	_assert(Input.is_action_pressed("yaw_right"), "ship touch stick right must drive explicit yaw-right")
	_assert(not Input.is_action_pressed("yaw_left"), "ship touch stick right must release yaw-left")
	_assert(Input.is_action_pressed("pitch_up"), "ship touch stick up must drive explicit pitch-up")
	_assert(not Input.is_action_pressed("pitch_down"), "ship touch stick up must release pitch-down")
	_assert(not Input.is_action_pressed("roll_left") and not Input.is_action_pressed("roll_right"), "ship touch stick must not synthesize roll")

	controls.left_position = controls.left_origin
	controls._update_left_actions()
	_assert(not Input.is_action_pressed("yaw_left") and not Input.is_action_pressed("yaw_right"), "centered ship touch stick must release yaw")
	_assert(not Input.is_action_pressed("pitch_up") and not Input.is_action_pressed("pitch_down"), "centered ship touch stick must release pitch")

	Input.action_press("nav_toggle")
	Input.action_press("cutscene_skip")
	controls.set_mode("eva")
	_assert(not Input.is_action_pressed("nav_toggle"), "ship NAV tap must release when switching to EVA")
	_assert(not Input.is_action_pressed("cutscene_skip"), "cinematic skip tap must release during control-state cleanup")

	var source := FileAccess.get_file_as_string("res://scripts/mobile_controls.gd")
	_assert(source.contains("_add_tap_button(\"tutorial_reset\", \"RESET\""), "mobile EVA must expose tutorial/reconstruction recovery")
	_assert(source.contains("\"scan\",\"interact\",\"tutorial_reset\""), "mobile recovery control must be available in EVA mode")
	_assert(source.contains("_tap_action(\"cutscene_skip\")"), "mobile cinematic skip parity must remain intact")
	_assert(source.contains("look_delta.emit(delta_pixels)"), "camera-look region must emit look deltas instead of steering actions")
	_assert(not source.contains("look_delta.connect(func(delta_pixels): Input.action_press"), "camera-look signal must never be converted into virtual steering actions")

	var tutorial_source := FileAccess.get_file_as_string("res://scripts/tutorial_director.gd")
	_assert(tutorial_source.contains("Shift the evidence left/right"), "archaeology lesson must describe the shared alignment mechanic without requiring keyboard keys")
	_assert(tutorial_source.contains("then USE. RESET restarts this step"), "archaeology lesson must use labels present on the touch control layer")
	_assert(not tutorial_source.contains("F3 or touch RESET"), "shared tutorial copy must not present keyboard-first recovery instructions to touch players")

	var game_root_source := FileAccess.get_file_as_string("res://scripts/game_root.gd")
	_assert(game_root_source.contains("LEFT STICK · SHIFT LEFT"), "mobile reconstruction state must name the actual touch alignment control")
	_assert(game_root_source.contains("HOLD · USE LOCK"), "mobile reconstruction state must name the actual touch lock control")
	_assert(game_root_source.contains("var use_label := \"USE\" if _is_touch_input() else \"E\""), "world interaction hints must select touch or desktop action labels")
	_assert(game_root_source.contains("var exit_hint := \"USE TO EXIT\" if _is_touch_input() else \"E TO EXIT\""), "landing and surface exit hints must remain touch-aware")

	var project_source := FileAccess.get_file_as_string("res://project.godot")
	_assert(project_source.contains("window/handheld/orientation=4"), "mobile build must allow either landscape rotation while keeping the touch HUD out of portrait")

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