class_name InputBootstrap
extends RefCounted

static func ensure_actions() -> void:
	_bind_key("move_forward", KEY_W)
	_bind_key("move_backward", KEY_S)
	_bind_key("move_left", KEY_A)
	_bind_key("move_right", KEY_D)
	_bind_key("jump", KEY_SPACE)
	_bind_key("interact", KEY_E)
	_bind_key("scan", KEY_F)
	_bind_key("throttle_up", KEY_W)
	_bind_key("throttle_down", KEY_S)
	_bind_key("yaw_left", KEY_A)
	_bind_key("yaw_right", KEY_D)
	_bind_key("pitch_up", KEY_UP)
	_bind_key("pitch_down", KEY_DOWN)
	_bind_key("roll_left", KEY_Z)
	_bind_key("roll_right", KEY_C)
	_bind_key("brake", KEY_X)
	_bind_key("nav_toggle", KEY_N)
	_bind_key("tutorial", KEY_F2)
	_bind_key("cutscene_skip", KEY_ESCAPE)
	_bind_mouse("scan", MOUSE_BUTTON_RIGHT)

static func _bind_key(action: StringName, keycode: Key) -> void:
	if not InputMap.has_action(action): InputMap.add_action(action)
	for event in InputMap.action_get_events(action):
		if event is InputEventKey and event.physical_keycode == keycode: return
	var e := InputEventKey.new()
	e.physical_keycode = keycode
	InputMap.action_add_event(action, e)

static func _bind_mouse(action: StringName, button: MouseButton) -> void:
	if not InputMap.has_action(action): InputMap.add_action(action)
	for event in InputMap.action_get_events(action):
		if event is InputEventMouseButton and event.button_index == button: return
	var e := InputEventMouseButton.new()
	e.button_index = button
	InputMap.action_add_event(action, e)
