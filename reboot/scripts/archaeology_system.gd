class_name ArchaeologySystem
extends Node

signal reconstruction_progress(value: float)
signal reconstruction_state(stage: String, alignment: float, target: float, lock_ready: bool)
signal reconstruction_complete

@export var alignment_speed := 0.28
@export var lock_tolerance := 0.065
@export var required_passes := 2

var active := false
var alignment := 0.0
var target_alignment := 0.67
var evidence_scanned := false
var completed := false
var pass_index := 0

func begin() -> void:
	# Preserve evidence_scanned when the player scanned the target before
	# interacting with it. Tutorial reset explicitly clears state through cancel().
	active = true
	completed = false
	pass_index = 0
	alignment = 0.15
	target_alignment = 0.52 + randf() * 0.31
	_set_eva_movement(false)
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
	var local_progress := clampf(1.0 - error / 0.30, 0.0, 1.0)
	if lock_ready:
		local_progress = 1.0
	var overall_progress := (float(pass_index) + local_progress) / float(maxi(required_passes, 1))
	reconstruction_progress.emit(clampf(overall_progress, 0.0, 1.0))
	_emit_state(lock_ready)
	if lock_ready and Input.is_action_just_pressed("interact"):
		if pass_index + 1 < required_passes:
			_advance_pass()
		else:
			completed = true
			active = false
			_set_eva_movement(true)
			reconstruction_progress.emit(1.0)
			reconstruction_state.emit("RECONSTRUCTION LOCKED", alignment, target_alignment, true)
			reconstruction_complete.emit()

func _advance_pass() -> void:
	pass_index += 1
	# The second pass asks the player to correlate a different evidence layer
	# instead of confirming the same solved alignment twice.
	alignment = 0.82 if target_alignment < 0.5 else 0.18
	target_alignment = clampf(1.0 - target_alignment, 0.18, 0.82)
	reconstruction_progress.emit(float(pass_index) / float(maxi(required_passes, 1)))
	_emit_state(false)

func cancel() -> void:
	active = false
	evidence_scanned = false
	completed = false
	pass_index = 0
	_set_eva_movement(true)
	reconstruction_progress.emit(0.0)
	reconstruction_state.emit("RESET", alignment, target_alignment, false)

func _set_eva_movement(value: bool) -> void:
	# Group messaging preserves system isolation: reconstruction owns the lock
	# request without reaching into GameRoot or mutating EVA transform/state.
	get_tree().call_group("eva_controller", "set_movement_enabled", value)

func _stage_name(lock_ready: bool) -> String:
	if not evidence_scanned:
		return "SCAN REQUIRED"
	if pass_index <= 0:
		return "LOCK STRUCTURE" if lock_ready else "STRUCTURE ALIGNMENT"
	return "LOCK INSCRIPTION" if lock_ready else "INSCRIPTION PHASE"

func _emit_state(lock_ready := false) -> void:
	reconstruction_state.emit(_stage_name(lock_ready), alignment, target_alignment, lock_ready)
