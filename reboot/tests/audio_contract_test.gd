extends SceneTree

var failures := 0

func _init() -> void:
	var source := FileAccess.get_file_as_string("res://scripts/audio_director.gd")
	_assert(not source.is_empty(), "audio director source must be readable")

	# Audio must observe mechanics, never own progression or persistence.
	_assert(not source.contains("SaveSystem."), "audio must never write or read canonical save state")
	_assert(not source.contains("tutorial.event("), "audio must never fabricate tutorial mechanic evidence")
	_assert(not source.contains("collect_fragment("), "audio must never mutate fragment progression")
	_assert(not source.contains("collect_resource("), "audio must never mutate resource progression")

	# Player-facing feedback must stay tied to real controller/mechanic state.
	_assert(source.contains("_eva.enabled and Input.is_action_pressed(\"scan\")"), "scanner audio must require active EVA plus the real scan action")
	_assert(source.contains("_archaeology.active"), "reconstruction guide must require an active archaeology reconstruction")
	_assert(source.contains("_eva.enabled and _eva.movement_enabled and grounded and speed > 0.35"), "EVA footsteps must require active grounded physical movement")
	_assert(source.contains("site == null or not is_instance_valid(site) or not site.visible or site.completed"), "Pale Signal motif must ignore resolved or unavailable fragment anchors")
	_assert(source.contains("fragment_count = _campaign_world.campaign.fragment_count()"), "signal motif escalation must observe earned evidence rather than inventing a parallel state")

	if failures == 0:
		print("PALE SIGNAL AUDIO CONTRACT: PASS")
		quit(0)
	else:
		push_error("PALE SIGNAL AUDIO CONTRACT: %d FAILURE(S)" % failures)
		quit(1)

func _assert(value: bool, message: String) -> void:
	if not value:
		failures += 1
		push_error(message)
