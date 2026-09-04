extends SceneTree

class LandingHost:
	extends Node
	var current_world := "Kestra"

var failures := 0

func _assert(value: bool, message: String) -> void:
	if not value:
		failures += 1
		push_error(message)

func _init() -> void:
	var host := LandingHost.new()
	root.add_child(host)
	var tutorial := TutorialDirector.new()
	host.add_child(tutorial)
	tutorial.index = 10

	# A physically safe landing away from Tethys must not complete the authored
	# return-to-basin lesson.
	tutorial.event("touchdown", {"safe": true})
	_assert(tutorial.index == 10, "safe touchdown on Kestra must not complete the Tethys landing lesson")
	_assert(not tutorial.completed.has("landing"), "off-world touchdown must not fabricate tutorial completion")

	# Unsafe touchdowns on Tethys also remain failures; location never bypasses
	# the real landing envelope.
	host.current_world = "Tethys"
	tutorial.event("touchdown", {"safe": false})
	_assert(tutorial.index == 10, "unsafe touchdown on Tethys must not complete the landing lesson")

	# Only a safe physical touchdown after returning to Tethys qualifies.
	tutorial.event("touchdown", {"safe": true})
	_assert(tutorial.index == TutorialDirector.LESSONS.size(), "safe Tethys touchdown must complete the final tutorial lesson")
	_assert(tutorial.completed.has("landing"), "valid Tethys touchdown must mark landing complete")

	host.queue_free()
	if failures == 0:
		print("TUTORIAL LANDING CONTRACT: PASS")
		quit(0)
	else:
		push_error("TUTORIAL LANDING CONTRACT: %d FAILURE(S)" % failures)
		quit(1)
