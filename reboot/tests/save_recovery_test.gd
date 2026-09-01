extends SceneTree

const SaveSystemScript = preload("res://scripts/save_system.gd")
const PRIMARY := "user://pale_signal_reboot.save"
const BACKUP := "user://pale_signal_reboot.save.bak"
const TEMP := "user://pale_signal_reboot.save.tmp"

func _init() -> void:
	_cleanup()
	var previous := {"tutorial": {"index": 4}, "campaign": {"fragments": {"tethys_1": true}}}
	var current := {"tutorial": {"index": 6}, "campaign": {"fragments": {"tethys_1": true, "tethys_2": true}}}
	var expected_previous = JSON.parse_string(JSON.stringify(previous))
	if not expected_previous is Dictionary:
		_fail("could not normalize recovery fixture through JSON")
		return
	if not SaveSystemScript.save_state(previous):
		_fail("initial recovery fixture save failed")
		return
	if not SaveSystemScript.save_state(current):
		_fail("second recovery fixture save failed")
		return

	var corrupt := FileAccess.open(PRIMARY, FileAccess.WRITE)
	if corrupt == null:
		_fail("could not open primary save to simulate interrupted/corrupt write")
		return
	corrupt.store_string("{ interrupted")
	corrupt.close()

	var recovered := SaveSystemScript.load_state()
	if recovered != expected_previous:
		_fail("invalid primary save must recover the previous serialized known-good backup")
		return

	_cleanup()
	print("PALE SIGNAL SAVE RECOVERY TEST: PASS")
	quit(0)

func _cleanup() -> void:
	var dir := DirAccess.open("user://")
	if dir == null:
		return
	for name in ["pale_signal_reboot.save", "pale_signal_reboot.save.bak", "pale_signal_reboot.save.tmp"]:
		if dir.file_exists(name):
			dir.remove(name)

func _fail(message: String) -> void:
	_cleanup()
	push_error(message)
	quit(1)
