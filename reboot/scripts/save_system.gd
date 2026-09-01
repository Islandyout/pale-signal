class_name SaveSystem
extends RefCounted

const PATH := "user://pale_signal_reboot.save"
const TEMP_PATH := "user://pale_signal_reboot.save.tmp"
const BACKUP_PATH := "user://pale_signal_reboot.save.bak"
const FILE_NAME := "pale_signal_reboot.save"
const TEMP_NAME := "pale_signal_reboot.save.tmp"
const BACKUP_NAME := "pale_signal_reboot.save.bak"

static func save_state(state: Dictionary) -> bool:
	var file := FileAccess.open(TEMP_PATH, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(state))
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
