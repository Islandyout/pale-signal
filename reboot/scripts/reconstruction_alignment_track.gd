extends Control

var alignment := 0.0
var target := 0.67
var tolerance := 0.065
var lock_ready := false
var evidence_scanned := false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(480, 34)
	queue_redraw()

func set_state(value: float, target_value: float, tolerance_value: float, ready: bool, scanned: bool) -> void:
	alignment = clampf(value, 0.0, 1.0)
	target = clampf(target_value, 0.0, 1.0)
	tolerance = clampf(tolerance_value, 0.01, 0.25)
	lock_ready = ready
	evidence_scanned = scanned
	queue_redraw()

func _draw() -> void:
	var track := Rect2(0.0, 10.0, size.x, 14.0)
	var track_color := Color(0.10, 0.14, 0.15, 0.96)
	var zone_color := Color(0.26, 0.66, 0.58, 0.36) if evidence_scanned else Color(0.43, 0.48, 0.49, 0.26)
	var target_color := Color(0.50, 0.92, 0.80, 0.92)
	var cursor_color := Color(0.55, 1.0, 0.84, 1.0) if lock_ready else Color(0.91, 0.95, 0.94, 1.0)

	draw_rect(track, track_color, true)
	var left := clampf(target - tolerance, 0.0, 1.0) * track.size.x
	var right := clampf(target + tolerance, 0.0, 1.0) * track.size.x
	draw_rect(Rect2(left, track.position.y, maxf(3.0, right - left), track.size.y), zone_color, true)

	var target_x := target * track.size.x
	draw_line(Vector2(target_x, 5.0), Vector2(target_x, 29.0), target_color, 2.0)
	var cursor_x := alignment * track.size.x
	draw_line(Vector2(cursor_x, 2.0), Vector2(cursor_x, 32.0), cursor_color, 4.0)

	if lock_ready:
		draw_rect(Rect2(0.0, 7.0, track.size.x, 20.0), Color(0.50, 1.0, 0.83, 0.62), false, 2.0)
