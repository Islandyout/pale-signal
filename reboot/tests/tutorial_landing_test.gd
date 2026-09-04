extends SceneTree

class LandingWorld:
	extends Node
	func landing_target(_world: String) -> Vector3:
		return Vector3(0, 1, 60)

class LandingHost:
	extends Node
	var current_world := "Kestra"
	var ship: Node3D
	var campaign_world: LandingWorld

	func _init() -> void:
		ship = Node3D.new()
		add_child(ship)
		campaign_world = LandingWorld.new()
		add_child(campaign_world)

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
	host.ship.position = Vector3(0, 1, 60)
	tutorial.event("touchdown", {"safe": true})
	_assert(tutorial.index == 10, "safe touchdown on Kestra must not complete the Tethys landing lesson")
	_assert(not tutorial.completed.has("landing"), "off-world touchdown must not fabricate tutorial completion")

	# Being on Tethys is still insufficient if the ship landed outside the
	# authored training basin.
	host.current_world = "Tethys"
	host.ship.position = Vector3(240, 1, 60)
	tutorial.event("touchdown", {"safe": true})
	_assert(tutorial.index == 10, "safe touchdown outside the Tethys training basin must not complete the landing lesson")
	_assert(not tutorial.completed.has("landing"), "Tethys surface-zone touchdown must not substitute for the authored basin")

	# Unsafe touchdowns inside the training basin remain failures; location never
	# bypasses the real landing envelope.
	host.ship.position = Vector3(0, 1, 60)
	tutorial.event("touchdown", {"safe": false})
	_assert(tutorial.index == 10, "unsafe touchdown in the Tethys basin must not complete the landing lesson")

	# Only a safe physical touchdown after returning to the authored basin qualifies.
	tutorial.event("touchdown", {"safe": true})
	_assert(tutorial.index == TutorialDirector.LESSONS.size(), "safe Tethys basin touchdown must complete the final tutorial lesson")
	_assert(tutorial.completed.has("landing"), "valid Tethys basin touchdown must mark landing complete")

	host.queue_free()
	if failures == 0:
		print("TUTORIAL LANDING CONTRACT: PASS")
		quit(0)
	else:
		push_error("TUTORIAL LANDING CONTRACT: %d FAILURE(S)" % failures)
		quit(1)
