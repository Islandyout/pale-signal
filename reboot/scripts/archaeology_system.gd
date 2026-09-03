class_name ArchaeologySystem
extends Node

signal reconstruction_progress(value: float)
signal reconstruction_state(stage: String, alignment: float, target: float, lock_ready: bool)
signal reconstruction_complete

@export var alignment_speed := 0.28
@export var lock_tolerance := 0.065
@export var required_passes := 3

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
			reconstruction_state.emit("EVIDENCE CORRELATED", alignment, target_alignment, true)
			reconstruction_complete.emit()

func _advance_pass() -> void:
	pass_index += 1
	# Each evidence pass asks for a materially different correlation instead of
	# repeating one solved alignment. The third pass is intentionally asymmetric:
	# it reads alteration chronology, making the player test whether the restraint
	# traces were original construction or a later intervention.
	if pass_index == 1:
		alignment = 0.82 if target_alignment < 0.5 else 0.18
		target_alignment = clampf(1.0 - target_alignment, 0.18, 0.82)
	else:
		alignment = 0.78 if target_alignment < 0.5 else 0.22
		target_alignment = 0.31 if target_alignment > 0.5 else 0.72
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
	# Unit/headless contracts instantiate this node before it enters a SceneTree;
	# the runtime call is only meaningful once the node is actually inside one.
	if not is_inside_tree():
		return
	get_tree().call_group("eva_controller", "set_movement_enabled", value)

func evidence_layer_name() -> String:
	# Reconstruction is evidence work, not a generic lock puzzle. The layers move
	# from structural fact, to restraint evidence, to chronology. That final pass
	# is what lets the scene challenge the simple "storm damage" explanation.
	match pass_index:
		0:
			return "LOAD PATH"
		1:
			return "RESTRAINT TRACE"
		_:
			return "ALTERATION SEQUENCE"

func _stage_name(lock_ready: bool) -> String:
	if not evidence_scanned:
		return "SCAN REQUIRED"
	var layer := evidence_layer_name()
	return "LOCK %s" % layer if lock_ready else "%s ALIGNMENT" % layer

func _emit_state(lock_ready := false) -> void:
	reconstruction_state.emit(_stage_name(lock_ready), alignment, target_alignment, lock_ready)
