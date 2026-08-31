class_name SaveSystem
extends RefCounted

const PATH := "user://pale_signal_reboot.save"

static func save_state(state: Dictionary) -> bool:
	var file := FileAccess.open(PATH, FileAccess.WRITE)
	if file == null: return false
	file.store_string(JSON.stringify(state))
	return true

static func load_state() -> Dictionary:
	if not FileAccess.file_exists(PATH): return {}
	var file := FileAccess.open(PATH, FileAccess.READ)
	if file == null: return {}
	var parsed = JSON.parse_string(file.get_as_text())
	return parsed if parsed is Dictionary else {}
