extends SceneTree

const TutorialDirectorScript = preload("res://scripts/tutorial_director.gd")

func _init() -> void:
	var tutorial = TutorialDirectorScript.new()
	root.add_child(tutorial)

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

	# Cross an explicit save/reload boundary before the tutorial reaches those
	# irreversible mechanics. The restored director must preserve the observations
	# or a collected specimen/reconstructed site could become impossible to repeat.
	var saved := tutorial.snapshot()
	var restored := TutorialDirectorScript.new()
	root.add_child(restored)
	var reveal_observation := {"count": 0}
	restored.request_reveal_cutscene.connect(func(): reveal_observation["count"] += 1)
	restored.restore(saved)
	if restored.index != 0:
		_fail("restoring early evidence must keep the active movement lesson")
		return

	# Perform the two repeatable opening lessons in order. Reaching the air lesson
	# should consume the saved irreversible evidence chain and stop at BOARD SHIP,
	# not soft-lock on a scan/collection/reconstruction that cannot be repeated.
	restored.event("eva_moved", 8.0)
	if restored.index != 1:
		_fail("movement lesson did not advance normally after restore")
		return
	restored.event("eva_looked", 90.0)
	if restored.index != 6:
		_fail("saved one-shot evidence must advance air/scan/collect/archaeology and stop at board")
		return
	for id in ["move", "look", "air", "scan", "collect", "archaeology"]:
		if not restored.completed.has(id):
			_fail("expected completed lesson missing after restored out-of-order reconciliation: %s" % id)
			return
	if int(reveal_observation["count"]) != 1:
		_fail("restored early archaeology completion must preserve exactly one observational reveal")
		return

	# Consumed observations must not survive into later snapshots and replay.
	var reconciled_snapshot := restored.snapshot()
	var reconciled_observed = reconciled_snapshot.get("observed_one_shot", {})
	if reconciled_observed is Dictionary and not reconciled_observed.is_empty():
		_fail("consumed one-shot observations must be removed from persisted tutorial state")
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
