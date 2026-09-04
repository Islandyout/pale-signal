extends Node

# Restores optional physical runtime context after the production scene has
# finished constructing its canonical EVA/ship controllers. Campaign/tutorial
# progression remains owned by SaveSystem + CampaignState/TutorialDirector.

func _ready() -> void:
	call_deferred("_restore_runtime_state")

func _restore_runtime_state() -> void:
	var saved := SaveSystem.load_state()
	if not saved.has("runtime") or not (saved["runtime"] is Dictionary):
		return
	var runtime: Dictionary = saved["runtime"]
	var root := get_tree().root.get_node_or_null("PaleSignalReboot")
	if root == null:
		return
	var ship := root.get_node_or_null("Ship")
	var eva := root.get_node_or_null("EVA")
	if ship == null or eva == null:
		return

	var restore_mode := str(runtime.get("mode", "eva"))
	if restore_mode != "ship":
		restore_mode = "eva"
	if root.has_method("_set_mode"):
		root.call("_set_mode", restore_mode)

	ship.global_position = _array_to_vector3(runtime.get("ship_position", []), ship.global_position)
	ship.rotation = _array_to_vector3(runtime.get("ship_rotation", []), ship.rotation)
	ship.velocity = Vector3.ZERO if bool(runtime.get("ship_landed", ship.landed)) else _array_to_vector3(runtime.get("ship_velocity", []), ship.velocity)
	ship.throttle = clampf(float(runtime.get("ship_throttle", ship.throttle)), 0.0, 1.0)
	ship.fuel = clampf(float(runtime.get("ship_fuel", ship.fuel)), 0.0, ship.max_fuel)
	ship.hull = clampf(float(runtime.get("ship_hull", ship.hull)), 0.0, ship.max_hull)
	ship.landed = bool(runtime.get("ship_landed", ship.landed))

	eva.global_position = _array_to_vector3(runtime.get("eva_position", []), eva.global_position)
	eva.rotation = _array_to_vector3(runtime.get("eva_rotation", []), eva.rotation)

	# Re-apply mode after transforms so controller/camera ownership matches the
	# restored physical context without teleporting the active controller.
	if restore_mode == "ship":
		eva.global_position = ship.global_position + Vector3(0, 0.4, 0)
	ship.throttle_changed.emit(ship.throttle)
	ship.fuel_changed.emit(ship.fuel, ship.max_fuel)
	ship.hull_changed.emit(ship.hull, ship.max_hull)

func _array_to_vector3(value, fallback: Vector3) -> Vector3:
	if not value is Array or value.size() != 3:
		return fallback
	return Vector3(float(value[0]), float(value[1]), float(value[2]))
