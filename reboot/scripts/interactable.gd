class_name Interactable
extends Area3D

signal used(interactable: Interactable)

@export var interaction_id := "interactable"
@export var display_name := "Interact"
@export_multiline var description := ""
@export var requires_scan := false
@export var one_shot := false
var scanned := false
var completed := false

func can_use() -> bool:
	return not (one_shot and completed) and (not requires_scan or scanned)

func use() -> bool:
	if not can_use(): return false
	completed = true
	used.emit(self)
	return true
