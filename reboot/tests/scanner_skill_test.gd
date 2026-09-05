extends SceneTree

var failures := 0

func _init() -> void:
	var scanner := ScannerSystem.new()
	_assert(scanner.subject_lock_state(scanner.subject_min_lock_range - 0.05) == "TOO_CLOSE", "scanner must reject an unreadably close subject lock")
	_assert(scanner.subject_lock_state(scanner.subject_max_lock_range + 0.05) == "TOO_FAR", "scanner must reject an unreadably distant subject lock")
	var midpoint := (scanner.subject_min_lock_range + scanner.subject_max_lock_range) * 0.5
	_assert(scanner.subject_lock_state(midpoint) == "LOCKED", "scanner must expose a usable distance band")
	_assert(scanner.subject_stability_state(scanner.subject_max_sweep_rate * 0.5) == "STEADY", "scanner must accept deliberate camera tracking")
	_assert(scanner.subject_stability_state(scanner.subject_max_sweep_rate + 0.05) == "SWEEPING", "scanner must reject rapid sensor sweeping")
	_assert(scanner.atmosphere_lock_state(scanner.atmosphere_min_up_dot - 0.01, 0.0) == "LOW", "atmospheric analysis must require the player to raise the sensor")
	_assert(scanner.atmosphere_lock_state(scanner.atmosphere_min_up_dot + 0.05, scanner.atmosphere_max_sweep_rate + 0.05) == "SWEEPING", "atmospheric analysis must reject rapid sweeping")
	_assert(scanner.atmosphere_lock_state(scanner.atmosphere_min_up_dot + 0.05, scanner.atmosphere_max_sweep_rate * 0.5) == "LOCKED", "atmospheric analysis must expose a deliberate stable lock state")
	var source := FileAccess.get_file_as_string("res://scripts/scanner_system.gd")
	_assert(source.contains("STEADY SENSOR"), "scanner must explain unstable aim instead of silently withholding progress")
	_assert(source.contains("RAISE SENSOR"), "atmospheric scan must explain insufficient elevation")
	_assert(source.contains("_progress = maxf(0.0, _progress - delta * lock_decay_rate)"), "invalid scan lock must decay partial analysis rather than completing passively")
	_assert(source.contains("lock_state == \"LOCKED\" and stability_state == \"STEADY\""), "subject analysis must require both readable range and sensor stability")
	_assert(source.contains("atmosphere_state == \"LOCKED\""), "atmospheric analysis must require a valid sensor lock before progressing")
	scanner.free()
	if failures == 0:
		print("SCANNER SKILL TEST: PASS")
		quit(0)
	else:
		push_error("SCANNER SKILL TEST: %d FAILURE(S)" % failures)
		quit(1)

func _assert(value: bool, message: String) -> void:
	if not value:
		failures += 1
		push_error(message)
