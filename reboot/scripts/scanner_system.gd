class_name ScannerSystem
extends Node

signal atmosphere_verified
signal subject_scanned(subject: Interactable)
signal scan_progress(value: float, label: String)

@export var atmosphere_time := 1.8
@export var subject_time := 1.25
@export var range := 8.0
@export var subject_min_lock_range := 1.4
@export var subject_max_lock_range := 5.75
@export var lock_decay_rate := 0.8
var atmosphere_done := false
var _progress := 0.0
var _last_target: Object

func tick(delta: float, camera: Camera3D, enabled: bool) -> void:
	if not enabled or not Input.is_action_pressed("scan"):
		_reset()
		return
	var space := camera.get_world_3d().direct_space_state
	var from := camera.global_position
	var to := from + -camera.global_transform.basis.z * range
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	var hit := space.intersect_ray(query)
	if hit.has("collider") and hit.collider is Interactable:
		var target: Interactable = hit.collider
		if _last_target != target:
			_progress = 0.0
			_last_target = target
		var target_distance := from.distance_to(hit.position)
		var lock_state := subject_lock_state(target_distance)
		if lock_state == "LOCKED":
			_progress += delta / subject_time
			scan_progress.emit(clampf(_progress, 0.0, 1.0), "SIGNAL LOCK %.1fM • %s" % [target_distance, target.display_name.to_upper()])
		else:
			_progress = maxf(0.0, _progress - delta * lock_decay_rate)
			var cue := "BACK OFF" if lock_state == "TOO_CLOSE" else "MOVE CLOSER"
			scan_progress.emit(clampf(_progress, 0.0, 1.0), "%s %.1fM • %s" % [cue, target_distance, target.display_name.to_upper()])
		if _progress >= 1.0:
			target.scanned = true
			subject_scanned.emit(target)
			_reset()
		return
	var look_up := (-camera.global_transform.basis.z).dot(Vector3.UP)
	if not atmosphere_done and look_up > 0.38:
		if _last_target != self:
			_progress = 0.0
			_last_target = self
		_progress += delta / atmosphere_time
		scan_progress.emit(clampf(_progress, 0.0, 1.0), "ATMOSPHERIC SPECTRUM")
		if _progress >= 1.0:
			atmosphere_done = true
			atmosphere_verified.emit()
			_reset()
		return
	_reset()

func subject_lock_state(distance: float) -> String:
	if distance < subject_min_lock_range:
		return "TOO_CLOSE"
	if distance > subject_max_lock_range:
		return "TOO_FAR"
	return "LOCKED"

func _reset() -> void:
	_progress = 0.0
	_last_target = null
	scan_progress.emit(0.0, "")
