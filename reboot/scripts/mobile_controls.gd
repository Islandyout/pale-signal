class_name MobileControls
extends Control

signal look_delta(delta_pixels: Vector2)

var mode := "eva"
var left_touch := -1
var look_touch := -1
var left_origin := Vector2.ZERO
var left_position := Vector2.ZERO
var look_last := Vector2.ZERO
var stick_radius := 74.0
var _buttons := []
var _cutscene_skip_button: Button

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = DisplayServer.is_touchscreen_available()
	if visible:
		_build_buttons()
		_build_cutscene_skip_button()

func _process(_delta: float) -> void:
	# GameRoot intentionally hides the normal touch layer while a framing
	# cutscene owns the camera. Keep one independent touch target alive so the
	# same cutscene_skip action available on desktop remains reachable on mobile.
	if _cutscene_skip_button:
		_cutscene_skip_button.visible = DisplayServer.is_touchscreen_available() and not visible

func _exit_tree() -> void:
	if is_instance_valid(_cutscene_skip_button):
		_cutscene_skip_button.queue_free()

func set_mode(value: String) -> void:
	_release_left_actions()
	mode = value
	for item in _buttons:
		var button: Button = item.button
		button.visible = _button_visible(item.id)

func _unhandled_input(event: InputEvent) -> void:
	if not visible: return
	var size: Vector2 = get_viewport_rect().size
	if event is InputEventScreenTouch:
		if event.pressed:
			if event.position.x < size.x * 0.43 and event.position.y > size.y * 0.38 and left_touch < 0:
				left_touch = event.index
				left_origin = event.position
				left_position = event.position
				queue_redraw()
			elif event.position.x >= size.x * 0.43 and event.position.x < size.x * 0.80 and look_touch < 0:
				look_touch = event.index
				look_last = event.position
		else:
			if event.index == left_touch:
				left_touch = -1
				_release_left_actions()
				queue_redraw()
			if event.index == look_touch: look_touch = -1
	elif event is InputEventScreenDrag:
		if event.index == left_touch:
			left_position = event.position
			_update_left_actions()
			queue_redraw()
		elif event.index == look_touch:
			var delta_pixels: Vector2 = event.position - look_last
			look_last = event.position
			look_delta.emit(delta_pixels)

func _update_left_actions() -> void:
	var v: Vector2 = (left_position - left_origin) / stick_radius
	if v.length() > 1.0: v = v.normalized()
	if mode == "eva":
		_set_axis_actions("move_left", "move_right", v.x)
		_set_axis_actions("move_forward", "move_backward", v.y)
	else:
		_set_axis_actions("yaw_left", "yaw_right", v.x)
		# Screen-up pitches the nose up.
		_set_axis_actions("pitch_up", "pitch_down", v.y)

func _set_axis_actions(negative: StringName, positive: StringName, value: float) -> void:
	if value < -0.08:
		Input.action_press(negative, absf(value))
		Input.action_release(positive)
	elif value > 0.08:
		Input.action_press(positive, absf(value))
		Input.action_release(negative)
	else:
		Input.action_release(negative)
		Input.action_release(positive)

func _release_left_actions() -> void:
	for action in ["move_left","move_right","move_forward","move_backward","yaw_left","yaw_right","pitch_up","pitch_down"]:
		Input.action_release(action)

func _build_buttons() -> void:
	_add_hold_button("scan", "SCAN", Vector2(-108, -178), "scan")
	_add_tap_button("interact", "USE", Vector2(-208, -106), "interact")
	_add_hold_button("throttle_up", "THR +", Vector2(-108, -250), "throttle_up")
	_add_hold_button("throttle_down", "THR -", Vector2(-108, -178), "throttle_down")
	_add_hold_button("brake", "BRAKE", Vector2(-108, -106), "brake")
	_add_tap_button("nav", "NAV", Vector2(-108, -322), "nav_toggle")
	_add_tap_button("route", "NEXT", Vector2(-208, -250), "route_next")
	_add_tap_button("fabricator", "FAB", Vector2(-208, -178), "fabricator")
	# Mobile flight keeps the same explicit roll mechanic as desktop instead of hiding it behind camera look.
	_add_hold_button("roll_left", "ROLL L", Vector2(-308, -250), "roll_left")
	_add_hold_button("roll_right", "ROLL R", Vector2(-308, -178), "roll_right")
	set_mode(mode)

func _build_cutscene_skip_button() -> void:
	var button := Button.new()
	button.name = "MobileCutsceneSkip"
	button.text = "SKIP"
	button.custom_minimum_size = Vector2(112, 58)
	button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	button.position = Vector2(-132, 20)
	button.visible = false
	button.pressed.connect(func(): _tap_action("cutscene_skip"))
	# Keep the skip target outside this Control's visibility tree. GameRoot hides
	# MobileControls during cinematics; the viewport-root button remains usable.
	get_tree().root.add_child.call_deferred(button)
	_cutscene_skip_button = button

func _new_button(label: String, offset: Vector2) -> Button:
	var b := Button.new()
	b.text = label
	b.custom_minimum_size = Vector2(92, 56)
	b.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	b.position = offset
	b.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(b)
	return b

func _add_hold_button(id: String, label: String, offset: Vector2, action: StringName) -> void:
	var b := _new_button(label, offset)
	b.button_down.connect(func(): Input.action_press(action))
	b.button_up.connect(func(): Input.action_release(action))
	_buttons.append({"id":id,"button":b})

func _add_tap_button(id: String, label: String, offset: Vector2, action: StringName) -> void:
	var b := _new_button(label, offset)
	b.pressed.connect(func(): _tap_action(action))
	_buttons.append({"id":id,"button":b})

func _tap_action(action: StringName) -> void:
	Input.action_press(action)
	await get_tree().process_frame
	Input.action_release(action)

func _button_visible(id: String) -> bool:
	if mode == "eva": return id in ["scan","interact"]
	return id in ["throttle_up","throttle_down","brake","nav","route","fabricator","interact","roll_left","roll_right"]

func _draw() -> void:
	if left_touch < 0: return
	draw_circle(left_origin, stick_radius, Color(0.2,0.7,0.9,0.12))
	var knob: Vector2 = left_position
	var stick_delta: Vector2 = knob - left_origin
	if stick_delta.length() > stick_radius: knob = left_origin + stick_delta.normalized() * stick_radius
	draw_circle(knob, 28.0, Color(0.55,0.9,1.0,0.34))
