extends SceneTree

class LandingWorld:
	extends Node
	var reported_world := "Kestra"
	func landing_target(_world: String) -> Vector3:
		return Vector3(0, 1, 60)
	func surface_info(_position: Vector3) -> Dictionary:
		return {"world": reported_world}

class LandingHost:
	extends Node3D
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

	# Being physically on Tethys is still insufficient if the ship landed outside
	# the authored training basin.
	host.campaign_world.reported_world = "Tethys"
	host.ship.position = Vector3(240, 1, 60)
	tutorial.event("touchdown", {"safe": true})
	_assert(tutorial.index == 10, "safe touchdown outside the Tethys training basin must not complete the landing lesson")
	_assert(not tutorial.completed.has("landing"), "Tethys surface-zone touchdown must not substitute for the authored basin")

	# Unsafe touchdowns inside the training basin remain failures; location never
	# bypasses the real landing envelope.
	host.ship.position = Vector3(0, 1, 60)
	tutorial.event("touchdown", {"safe": false})
	_assert(tutorial.index == 10, "unsafe touchdown in the Tethys basin must not complete the landing lesson")

	# GameRoot.current_world is frame-updated presentation context and can still be
	# stale when ShipController emits touchdown during a physics tick. The canonical
	# physical surface query must therefore win and allow a valid Tethys landing.
	host.current_world = "Kestra"
	host.campaign_world.reported_world = "Tethys"
	host.position = Vector3(500, 20, -300)
	host.ship.position = Vector3(0, 1, 60)
	tutorial.event("touchdown", {"safe": true})
	_assert(tutorial.index == TutorialDirector.LESSONS.size(), "physical Tethys surface state must complete landing even if cached current_world is stale")
	_assert(tutorial.completed.has("landing"), "stale presentation context must not block a valid physical Tethys basin touchdown")

	host.queue_free()
	if failures == 0:
		print("TUTORIAL LANDING CONTRACT: PASS")
		quit(0)
	else:
		push_error("TUTORIAL LANDING CONTRACT: %d FAILURE(S)" % failures)
		quit(1)