class_name ArchaeologySystem
extends Node

signal reconstruction_progress(value: float)
signal reconstruction_complete

var active := false
var alignment := 0.0
var target_alignment := 0.67
var evidence_scanned := false
var completed := false

func begin() -> void:
	if completed: return
	active = true
	alignment = 0.15
	reconstruction_progress.emit(0.0)

func mark_scanned() -> void:
	evidence_scanned = true

func tick(delta: float) -> void:
	if not active or completed: return
	var axis := Input.get_axis("move_left", "move_right")
	alignment = clampf(alignment + axis * delta * 0.38, 0.0, 1.0)
	var error := absf(alignment - target_alignment)
	var progress := clampf(1.0 - error / 0.24, 0.0, 1.0)
	reconstruction_progress.emit(progress)
	if evidence_scanned and progress > 0.92 and Input.is_action_just_pressed("interact"):
		completed = true
		active = false
		reconstruction_progress.emit(1.0)
		reconstruction_complete.emit()
