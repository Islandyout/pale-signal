extends SceneTree

var failures := 0
var captured_snapshot := {}

func _assert(value: bool, message: String) -> void:
	if not value:
		failures += 1
		push_error(message)

func _init() -> void:
	var tutorial := TutorialDirector.new()
	root.add_child(tutorial)
	tutorial.lesson_completed.connect(func(_id: String): captured_snapshot = tutorial.snapshot())

	# Completing the first real mechanic must expose the *next* lesson index to
	# persistence listeners. GameRoot saves from lesson_completed; an old ordering
	# emitted that signal before incrementing index, causing reloads to replay the
	# lesson that had just been completed.
	tutorial.event("eva_moved", 8.0)
	_assert(tutorial.completed.has("move"), "move lesson must be recorded complete")
	_assert(tutorial.index == 1, "runtime lesson cursor must advance after completion")
	_assert(int(captured_snapshot.get("index", -1)) == 1, "lesson_completed listeners must snapshot the next lesson index")
	var completed_state = captured_snapshot.get("completed", {})
	_assert(completed_state is Dictionary and (completed_state as Dictionary).has("move"), "completion flag and advanced cursor must be serialized together")

	# Restoring the captured boundary must resume at CAMERA / BODY SEPARATION, not
	# replay EVA MOVEMENT.
	var restored := TutorialDirector.new()
	root.add_child(restored)
	restored.restore(captured_snapshot)
	_assert(restored.index == 1, "restored tutorial must resume on the next unfinished lesson")
	_assert(restored.completed.has("move"), "restored tutorial must retain the completed lesson flag")

	tutorial.queue_free()
	restored.queue_free()
	if failures == 0:
		print("TUTORIAL PERSISTENCE CONTRACT: PASS")
		quit(0)
	else:
		push_error("TUTORIAL PERSISTENCE CONTRACT: %d FAILURE(S)" % failures)
		quit(1)
