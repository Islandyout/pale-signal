class_name TutorialDirector
extends Node

signal objective_changed(title: String, detail: String, progress: float)
signal lesson_completed(id: String)
signal lesson_reset(id: String)
signal lesson_skipped(id: String)
signal tutorial_completed
signal request_intro_cutscene
signal request_reveal_cutscene

const TETHYS_TRAINING_BASIN_RADIUS := 95.0
const LESSONS := [
	{"id":"move", "title":"EVA MOVEMENT", "detail":"Move through the marked basin. Reach 8 m of real displacement."},
	{"id":"look", "title":"CAMERA / BODY SEPARATION", "detail":"Look around at least 90 degrees. Looking does not move or steer you."},
	{"id":"air", "title":"VERIFY THE AIR", "detail":"Look into open sky and hold SCAN until the atmospheric spectrum resolves."},
	{"id":"scan", "title":"SCAN A SPECIMEN", "detail":"Centre the field specimen and hold SCAN. Scanning identifies; it does not collect."},
	{"id":"collect", "title":"PHYSICAL COLLECTION", "detail":"Walk to the identified sample and interact to physically collect it."},
	{"id":"archaeology", "title":"RECONSTRUCT EVIDENCE", "detail":"Scan the foundation. Shift the evidence left/right until the lock zone is reached, then USE. RESET restarts this step."},
	{"id":"board", "title":"BOARD THE SHIP", "detail":"Return to the ship and interact within boarding range."},
	{"id":"launch", "title":"MANUAL VTOL LAUNCH", "detail":"Raise throttle. Lift is independent of nose pitch; no cutscene moves the ship."},
	{"id":"space", "title":"ATMOSPHERE TO SPACE", "detail":"Climb continuously through the atmosphere ceiling using the real flight model."},
	{"id":"nav", "title":"NAVIGATION ASSIST", "detail":"Toggle NAV and fly the route yourself. Experience departure, transfer, and approach guidance without surrendering control."},
	{"id":"landing", "title":"MANUAL LANDING", "detail":"Return to the Tethys training basin and touch down inside the safe vertical/lateral envelope."}
]

var index := 0
var completed := {}
var skipped := {}
var _move_distance := 0.0
var _look_degrees := 0.0
var _nav_seen := {}

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("tutorial_reset"):
		reset_current()

func start() -> void:
	_restore_saved_progress()
	if index <= 0:
		request_intro_cutscene.emit()
	if index >= LESSONS.size():
		objective_changed.emit("FIELD QUALIFICATION COMPLETE", "The production mechanics are proven. Continue investigating the Tethys/Kestra vertical slice; wider campaign systems remain locked until quality gates pass.", 1.0)
		return
	_emit_current()

func _restore_saved_progress() -> void:
	var saved := SaveSystem.load_state()
	if not saved.has("tutorial") or not (saved["tutorial"] is Dictionary):
		return
	restore(saved["tutorial"] as Dictionary)

func restore(data: Dictionary) -> void:
	index = clampi(int(data.get("index", 0)), 0, LESSONS.size())
	completed.clear()
	if data.has("completed") and data["completed"] is Dictionary:
		completed = (data["completed"] as Dictionary).duplicate(true)
	skipped.clear()
	if data.has("skipped") and data["skipped"] is Dictionary:
		skipped = (data["skipped"] as Dictionary).duplicate(true)
	# Lesson-local analog progress is intentionally reset. Saves are written at
	# completed lesson boundaries, so a loaded lesson must still be performed.
	_move_distance = 0.0
	_look_degrees = 0.0
	_nav_seen.clear()

func event(name: String, payload = null) -> void:
	if index >= LESSONS.size(): return
	var id: String = LESSONS[index].id
	match id:
		"move":
			if name == "eva_moved":
				_move_distance += float(payload)
				_emit_current(clampf(_move_distance / 8.0, 0.0, 1.0))
				if _move_distance >= 8.0: _complete()
		"look":
			if name == "eva_looked":
				_look_degrees += float(payload)
				_emit_current(clampf(_look_degrees / 90.0, 0.0, 1.0))
				if _look_degrees >= 90.0: _complete()
		"air":
			if name == "atmosphere_verified": _complete()
		"scan":
			if name == "subject_scanned": _complete()
		"collect":
			if name == "sample_collected": _complete()
		"archaeology":
			if name == "archaeology_complete":
				request_reveal_cutscene.emit()
				_complete()
		"board":
			if name == "boarded": _complete()
		"launch":
			if name == "launched": _complete()
		"space":
			if name == "crossed_atmosphere": _complete()
		"nav":
			if name == "nav_state":
				# Guidance states are situational: a well-aligned pilot can legitimately
				# bypass TURN, and a conservative approach can bypass BRAKE. Require one
				# real cue from each navigation phase instead of forcing every branch.
				var state := str(payload)
				if state in ["TURN", "BURN"]: _nav_seen["departure"] = true
				elif state in ["COAST", "BRAKE"]: _nav_seen["transfer"] = true
				elif state == "APPROACH": _nav_seen["approach"] = true
				var score := 0
				for phase in ["departure", "transfer", "approach"]:
					if _nav_seen.has(phase): score += 1
				_emit_current(float(score) / 3.0)
				if score >= 3: _complete()
		"landing":
			if name == "touchdown" and payload is Dictionary and payload.get("safe", false):
				# Completion requires the authored Tethys basin, not merely any safe
				# touchdown inside Tethys' much larger surface/collision footprint.
				var host := get_parent()
				if host != null and str(host.get("current_world")) == "Tethys":
					var ship_node := host.get("ship") as Node3D
					var world_node = host.get("campaign_world")
					if ship_node != null and world_node != null and world_node.has_method("landing_target"):
						var basin_target: Vector3 = world_node.call("landing_target", "Tethys")
						var offset := ship_node.global_position - basin_target
						var planar_distance := Vector2(offset.x, offset.z).length()
						if planar_distance <= TETHYS_TRAINING_BASIN_RADIUS:
							_complete()

func reset_current() -> void:
	if index >= LESSONS.size(): return
	var id: String = LESSONS[index].id
	match id:
		"move": _move_distance = 0.0
		"look": _look_degrees = 0.0
		"nav": _nav_seen.clear()
	lesson_reset.emit(id)
	_emit_current(0.0)

func skip_current() -> bool:
	# Production mechanic lessons are intentionally non-skippable. Keep this
	# compatibility method safe for old callers; only cinematic framing is
	# skippable through the separate cutscene_skip action owned by GameRoot.
	if index < LESSONS.size():
		_emit_current()
	return false

func _complete() -> void:
	var id: String = LESSONS[index].id
	completed[id] = true
	lesson_completed.emit(id)
	index += 1
	if index >= LESSONS.size():
		objective_changed.emit("FIELD QUALIFICATION COMPLETE", "The production mechanics are proven. Continue investigating the Tethys/Kestra vertical slice; wider campaign systems remain locked until quality gates pass.", 1.0)
		tutorial_completed.emit()
		return
	_emit_current()

func _emit_current(progress := 0.0) -> void:
	if index >= LESSONS.size(): return
	var lesson: Dictionary = LESSONS[index]
	objective_changed.emit(lesson.title, lesson.detail, progress)

func snapshot() -> Dictionary:
	return {"index": index, "completed": completed.duplicate(true), "skipped": skipped.duplicate(true)}
