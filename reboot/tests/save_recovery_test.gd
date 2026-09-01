extends SceneTree

const PRIMARY := "user://pale_signal_reboot.save"
const BACKUP := "user://pale_signal_reboot.save.bak"
const TEMP := "user://pale_signal_reboot.save.tmp"

func _init() -> void:
	_cleanup()
	var previous := {"tutorial": {"index": 4}, "campaign": {"fragments": {"tethys_1": true}}}
	var current := {"tutorial": {"index": 6}, "campaign": {"fragments": {"tethys_1": true, "tethys_2": true}}}
	if not SaveSystem.save_state(previous):
		_fail("initial recovery fixture save failed")
		return
	if not SaveSystem.save_state(current):
		_fail("second recovery fixture save failed")
		return

	var corrupt := FileAccess.open(PRIMARY, FileAccess.WRITE)
	if corrupt == null:
		_fail("could not open primary save to simulate interrupted/corrupt write")
		return
	corrupt.store_string("{ interrupted")
	corrupt.close()

	var recovered := SaveSystem.load_state()
	if recovered != previous:
		_fail("invalid primary save must recover the previous known-good backup")
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
