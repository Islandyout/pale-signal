class_name SaveSystem
extends RefCounted

const PATH := "user://pale_signal_reboot.save"
const TEMP_PATH := "user://pale_signal_reboot.save.tmp"
const BACKUP_PATH := "user://pale_signal_reboot.save.bak"
const FILE_NAME := "pale_signal_reboot.save"
const TEMP_NAME := "pale_signal_reboot.save.tmp"
const BACKUP_NAME := "pale_signal_reboot.save.bak"

static func save_state(state: Dictionary) -> bool:
	var serialized := state.duplicate(true)
	var runtime := _capture_runtime_state()
	if not runtime.is_empty():
		serialized["runtime"] = runtime

	var file := FileAccess.open(TEMP_PATH, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(serialized))
	file.flush()
	file.close()

	var dir := DirAccess.open("user://")
	if dir == null:
		return false

	if dir.file_exists(BACKUP_NAME):
		if dir.remove(BACKUP_NAME) != OK:
			dir.remove(TEMP_NAME)
			return false

	var had_previous := dir.file_exists(FILE_NAME)
	if had_previous and dir.rename(FILE_NAME, BACKUP_NAME) != OK:
		dir.remove(TEMP_NAME)
		return false

	if dir.rename(TEMP_NAME, FILE_NAME) != OK:
		if had_previous:
			dir.rename(BACKUP_NAME, FILE_NAME)
		return false

	return true

static func load_state() -> Dictionary:
	var primary := _load_dictionary(PATH)
	if not primary.is_empty():
		return primary
	return _load_dictionary(BACKUP_PATH)

static func _load_dictionary(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	return parsed if parsed is Dictionary else {}

static func _capture_runtime_state() -> Dictionary:
	# Progression saves also preserve the physical first-hour context. Older saves
	# remain valid because this top-level payload is optional and restored only
	# when the production scene and its canonical controller nodes exist.
	var loop := Engine.get_main_loop()
	if not loop is SceneTree:
		return {}
	var tree := loop as SceneTree
	if tree.root == null:
		return {}
	var root := tree.root.get_node_or_null("PaleSignalReboot")
	if root == null:
		return {}
	var ship := root.get_node_or_null("Ship")
	var eva := root.get_node_or_null("EVA")
	if ship == null or eva == null:
		return {}
	var ship_velocity: Vector3 = ship.velocity
	if bool(ship.landed):
		ship_velocity = Vector3.ZERO
	return {
		"mode": str(root.get("mode")),
		"ship_position": _vector3_to_array(ship.global_position),
		"ship_rotation": _vector3_to_array(ship.rotation),
		"ship_velocity": _vector3_to_array(ship_velocity),
		"ship_throttle": float(ship.throttle),
		"ship_fuel": float(ship.fuel),
		"ship_hull": float(ship.hull),
		"ship_landed": bool(ship.landed),
		"eva_position": _vector3_to_array(eva.global_position),
		"eva_rotation": _vector3_to_array(eva.rotation),
	}

static func _vector3_to_array(value: Vector3) -> Array:
	return [value.x, value.y, value.z]
