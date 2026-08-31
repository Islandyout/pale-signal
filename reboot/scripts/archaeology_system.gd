class_name ArchaeologySystem
extends Node

signal reconstruction_progress(value: float)
signal reconstruction_state(stage: String, alignment: float, target: float, lock_ready: bool)
signal reconstruction_complete

@export var alignment_speed := 0.28
@export var lock_tolerance := 0.065

var active := false
var alignment := 0.0
var target_alignment := 0.67
var evidence_scanned := false
var completed := false

func begin() -> void:
	# Preserve evidence_scanned when the player scanned the target before
	# interacting with it. Tutorial reset explicitly clears state through cancel().
	active = true
	completed = false
	alignment = 0.15
	target_alignment = 0.52 + randf() * 0.31
	reconstruction_progress.emit(0.0)
	_emit_state()

func mark_scanned() -> void:
	evidence_scanned = true
	_emit_state()

func tick(delta: float) -> void:
	if not active or completed:
		return
	if Input.is_action_just_pressed("tutorial_reset"):
		cancel()
		return
	var axis := Input.get_axis("move_left", "move_right")
	alignment = clampf(alignment + axis * delta * alignment_speed, 0.0, 1.0)
	var error := absf(alignment - target_alignment)
	var lock_ready := evidence_scanned and error <= lock_tolerance
	var progress := clampf(1.0 - error / 0.30, 0.0, 1.0)
	if lock_ready:
		progress = 1.0
	reconstruction_progress.emit(progress)
	_emit_state(lock_ready)
	if lock_ready and Input.is_action_just_pressed("interact"):
		completed = true
		active = false
		reconstruction_progress.emit(1.0)
		reconstruction_state.emit("LOCKED", alignment, target_alignment, true)
		reconstruction_complete.emit()

func cancel() -> void:
	active = false
	evidence_scanned = false
	completed = false
	reconstruction_progress.emit(0.0)
	reconstruction_state.emit("RESET", alignment, target_alignment, false)

func _emit_state(lock_ready := false) -> void:
	var stage := "SCAN REQUIRED"
	if evidence_scanned:
		stage = "PRESS E TO LOCK" if lock_ready else "ALIGN TO TARGET"
	reconstruction_state.emit(stage, alignment, target_alignment, lock_ready)
