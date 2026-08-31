class_name ScannerSystem
extends Node

signal atmosphere_verified
signal subject_scanned(subject: Interactable)
signal scan_progress(value: float, label: String)

@export var atmosphere_time := 1.8
@export var subject_time := 1.25
@export var range := 8.0
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
		_progress += delta / subject_time
		scan_progress.emit(clampf(_progress, 0.0, 1.0), "SCANNING " + target.display_name.to_upper())
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

func _reset() -> void:
	_progress = 0.0
	_last_target = null
	scan_progress.emit(0.0, "")
