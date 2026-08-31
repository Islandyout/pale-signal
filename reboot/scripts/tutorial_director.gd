class_name TutorialDirector
extends Node

signal objective_changed(title: String, detail: String, progress: float)
signal lesson_completed(id: String)
signal lesson_reset(id: String)
signal lesson_skipped(id: String)
signal tutorial_completed
signal request_intro_cutscene
signal request_reveal_cutscene

const LESSONS := [
	{"id":"move", "title":"EVA MOVEMENT", "detail":"Move through the marked basin. Reach 8 m of real displacement."},
	{"id":"look", "title":"CAMERA / BODY SEPARATION", "detail":"Look around at least 90 degrees. Looking does not move or steer you."},
	{"id":"air", "title":"VERIFY THE AIR", "detail":"Look into open sky and hold SCAN until the atmospheric spectrum resolves."},
	{"id":"scan", "title":"SCAN A SPECIMEN", "detail":"Centre the field specimen and hold SCAN. Scanning identifies; it does not collect."},
	{"id":"collect", "title":"PHYSICAL COLLECTION", "detail":"Walk to the identified sample and interact to physically collect it."},
	{"id":"archaeology", "title":"RECONSTRUCT EVIDENCE", "detail":"Scan the foundation. Align left/right until the lock zone is reached, then press E. F3 resets this step."},
	{"id":"board", "title":"BOARD THE SHIP", "detail":"Return to the ship and interact within boarding range."},
	{"id":"launch", "title":"MANUAL VTOL LAUNCH", "detail":"Raise throttle. Lift is independent of nose pitch; no cutscene moves the ship."},
	{"id":"space", "title":"ATMOSPHERE TO SPACE", "detail":"Climb continuously through the atmosphere ceiling using the real flight model."},
	{"id":"nav", "title":"NAVIGATION ASSIST", "detail":"Toggle NAV and follow TURN / BURN / COAST / BRAKE / APPROACH cues without surrendering control."},
	{"id":"landing", "title":"MANUAL LANDING", "detail":"Return to the training basin and touch down inside the safe vertical/lateral envelope."}
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
	request_intro_cutscene.emit()
	_emit_current()

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
				_nav_seen[str(payload)] = true
				var score := 0
				for state in ["TURN", "BURN", "COAST", "BRAKE", "APPROACH"]:
					if _nav_seen.has(state): score += 1
				_emit_current(score / 3.0)
				if score >= 3: _complete()
		"landing":
			if name == "touchdown" and payload is Dictionary and payload.get("safe", false): _complete()

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
		objective_changed.emit("TRAINING COMPLETE", "Every lesson used the production mechanic. Continue into Tethys without a ruleset swap.", 1.0)
		tutorial_completed.emit()
		return
	_emit_current()

func _emit_current(progress := 0.0) -> void:
	if index >= LESSONS.size(): return
	var lesson: Dictionary = LESSONS[index]
	objective_changed.emit(lesson.title, lesson.detail, progress)

func snapshot() -> Dictionary:
	return {"index": index, "completed": completed.duplicate(true), "skipped": skipped.duplicate(true)}
