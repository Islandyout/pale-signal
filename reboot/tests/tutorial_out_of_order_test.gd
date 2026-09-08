extends SceneTree

const TutorialDirectorScript = preload("res://scripts/tutorial_director.gd")

func _init() -> void:
	var tutorial = TutorialDirectorScript.new()
	root.add_child(tutorial)
	var reveal_count := 0
	tutorial.request_reveal_cutscene.connect(func(): reveal_count += 1)

	# These production mechanics are possible before the tutorial cursor reaches
	# them. They are one-shot, so valid early evidence must be retained rather
	# than forcing an impossible repeat later.
	tutorial.event("atmosphere_verified")
	tutorial.event("subject_scanned", null)
	tutorial.event("sample_collected")
	tutorial.event("archaeology_complete")
	if tutorial.index != 0:
		_fail("early one-shot evidence must not skip the active movement lesson")
		return

	# Perform the two repeatable opening lessons in order. Reaching the air lesson
	# should consume the previously observed irreversible evidence chain and stop
	# at BOARD SHIP, not soft-lock on a scan/collection that cannot be repeated.
	tutorial.event("eva_moved", 8.0)
	if tutorial.index != 1:
		_fail("movement lesson did not advance normally")
		return
	tutorial.event("eva_looked", 90.0)
	if tutorial.index != 6:
		_fail("queued one-shot evidence must advance air/scan/collect/archaeology and stop at board")
		return
	for id in ["move", "look", "air", "scan", "collect", "archaeology"]:
		if not tutorial.completed.has(id):
			_fail("expected completed lesson missing after out-of-order reconciliation: %s" % id)
			return
	if reveal_count != 1:
		_fail("early archaeology completion must preserve exactly one observational reveal")
		return

	# Repeatable flight evidence is intentionally not queued. Launching before the
	# launch lesson must not silently satisfy it later.
	var flight_tutorial = TutorialDirectorScript.new()
	root.add_child(flight_tutorial)
	flight_tutorial.event("launched")
	flight_tutorial.index = 7
	flight_tutorial.event("unrelated")
	if flight_tutorial.index != 7:
		_fail("repeatable flight evidence must not be deferred across lessons")
		return

	print("PALE SIGNAL TUTORIAL OUT-OF-ORDER TEST: PASS")
	quit(0)

func _fail(message: String) -> void:
	push_error(message)
	quit(1)
