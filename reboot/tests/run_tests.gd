extends SceneTree

var failures := 0

func _init() -> void:
	_test_scanning_does_not_collect()
	_test_archaeology_requires_scan_and_alignment()
	_test_archaeology_preserves_pre_scan()
	_test_archaeology_has_recovery_contract()
	_test_tutorial_mechanics_cannot_be_skipped()
	_test_tutorial_nav_requires_full_cue_set()
	_test_tutorial_save_restore_contract()
	_test_first_hour_world_state_restore_contract()
	_test_vtol_is_pitch_independent_contract()
	_test_camera_steering_contract()
	_test_campaign_fragment_unlock_chain()
	_test_nemesis_requires_all_fragments()
	_test_world_surface_contract()
	_test_disembark_contract()
	_test_save_round_trip_shape()
	if failures == 0:
		print("PALE SIGNAL REBOOT TESTS: PASS")
		quit(0)
	else:
		push_error("PALE SIGNAL REBOOT TESTS: %d FAILURE(S)" % failures)
		quit(1)

func _assert(value: bool, message: String) -> void:
	if not value:
		failures += 1
		push_error(message)

func _test_scanning_does_not_collect() -> void:
	var item := Interactable.new()
	item.requires_scan = true
	_assert(not item.can_use(), "unscanned resource must not be collectible")
	item.scanned = true
	_assert(item.can_use(), "scanned resource should become collectible")
	_assert(not item.completed, "scanning must not silently collect")
	item.free()

func _test_archaeology_requires_scan_and_alignment() -> void:
	var a := ArchaeologySystem.new()
	a.begin()
	_assert(not a.evidence_scanned, "archaeology must begin without fabricated evidence")
	_assert(not a.completed, "archaeology cannot auto-complete")
	_assert(a.lock_tolerance >= 0.05, "archaeology lock zone must be readable, not pixel-precision")
	a.free()

func _test_archaeology_preserves_pre_scan() -> void:
	var a := ArchaeologySystem.new()
	a.mark_scanned()
	a.begin()
	_assert(a.evidence_scanned, "starting reconstruction must preserve a scan completed before interaction")
	a.cancel()
	_assert(not a.evidence_scanned, "reset/cancel must clear archaeology evidence state")
	a.free()

func _test_archaeology_has_recovery_contract() -> void:
	var archaeology_source := FileAccess.get_file_as_string("res://scripts/archaeology_system.gd")
	var tutorial_source := FileAccess.get_file_as_string("res://scripts/tutorial_director.gd")
	var input_source := FileAccess.get_file_as_string("res://scripts/input_bootstrap.gd")
	_assert(archaeology_source.contains("tutorial_reset"), "archaeology must release active state on tutorial reset")
	_assert(not archaeology_source.contains("tutorial_skip"), "cinematic skip must not cancel or bypass archaeology")
	_assert(tutorial_source.contains("reset_current"), "tutorial must expose reset recovery")
	_assert(input_source.contains("tutorial_reset"), "tutorial reset action must be bound")
	_assert(input_source.contains("cutscene_skip"), "cutscenes must retain an explicit skip action")

func _test_tutorial_mechanics_cannot_be_skipped() -> void:
	var t := TutorialDirector.new()
	var before := t.index
	var skipped := t.skip_current()
	_assert(not skipped, "tutorial mechanic skip must be rejected")
	_assert(t.index == before, "skip request must not advance a production mechanic lesson")
	_assert(t.completed.is_empty(), "skip request must not fabricate mechanic completion")
	var tutorial_source := FileAccess.get_file_as_string("res://scripts/tutorial_director.gd")
	var input_source := FileAccess.get_file_as_string("res://scripts/input_bootstrap.gd")
	var hud_source := FileAccess.get_file_as_string("res://scripts/production_hud.gd")
	_assert(not tutorial_source.contains("Input.is_action_just_pressed(\"tutorial_skip\")"), "tutorial director must not consume a gameplay skip action")
	_assert(not input_source.contains("_bind_key(\"tutorial_skip\""), "F4 must not bind a mechanic-skip action")
	_assert(hud_source.contains("SKIP CUTSCENE"), "HUD skip control must be labeled for cinematics only")
	t.free()

func _test_tutorial_nav_requires_full_cue_set() -> void:
	var t := TutorialDirector.new()
	t.index = 9
	for state in ["TURN", "BURN", "COAST", "BRAKE"]:
		t.event("nav_state", state)
	_assert(t.index == 9, "navigation lesson must not complete before all five production cues are observed")
	_assert(not t.completed.has("nav"), "partial navigation cue coverage must not fabricate lesson completion")
	t.event("nav_state", "APPROACH")
	_assert(t.index == 10, "navigation lesson must complete after TURN/BURN/COAST/BRAKE/APPROACH are all observed")
	_assert(t.completed.has("nav"), "full navigation cue coverage should complete the navigation lesson")
	t.free()

func _test_tutorial_save_restore_contract() -> void:
	var t := TutorialDirector.new()
	t.restore({"index": 5, "completed": {"move": true, "look": true, "air": true, "scan": true, "collect": true}, "skipped": {}})
	_assert(t.index == 5, "tutorial restore must resume at the saved lesson boundary")
	_assert(t.completed.has("collect"), "tutorial restore must preserve completed real-mechanic lessons")
	var snap := t.snapshot()
	_assert(int(snap.get("index", -1)) == 5, "tutorial snapshot must retain restored lesson index")
	t.restore({"index": 999, "completed": {}, "skipped": {}})
	_assert(t.index == TutorialDirector.LESSONS.size(), "tutorial restore must clamp invalid future indices")
	t.free()

func _test_first_hour_world_state_restore_contract() -> void:
	var source := FileAccess.get_file_as_string("res://scripts/game_root.gd")
	_assert(source.contains("tutorial.start()\n\t_restore_first_hour_progress()"), "first-hour physical state must restore after tutorial progress loads")
	_assert(source.contains("tutorial.completed.has(\"scan\")"), "saved specimen identification must restore from completed scan progress")
	_assert(source.contains("tutorial.completed.has(\"collect\")"), "saved specimen collection must restore from completed collection progress")
	_assert(source.contains("sample.monitorable = not value"), "collected specimen must leave scanner collision queries")
	_assert(source.contains("_set_sample_collected(true)"), "live collection and restored collection must use the same physical-state path")

func _test_vtol_is_pitch_independent_contract() -> void:
	var source := FileAccess.get_file_as_string("res://scripts/ship_controller.gd")
	_assert(source.contains("Vector3.UP * max_vtol_thrust"), "VTOL lift must use world-up lift")
	_assert(source.contains("independent of nose pitch"), "VTOL pitch-independence contract missing")

func _test_camera_steering_contract() -> void:
	var source := FileAccess.get_file_as_string("res://scripts/ship_controller.gd")
	_assert(source.contains("Camera look is deliberately independent of ship steering"), "camera/steering separation contract missing")
	_assert(not source.contains("rotate_y(-event.relative.x"), "mouse-look must not rotate the ship")

func _test_campaign_fragment_unlock_chain() -> void:
	var c := CampaignState.new()
	_assert(c.world_unlocked("Tethys"), "Tethys must always be available")
	_assert(not c.world_unlocked("Cinder"), "Cinder must require both Tethys fragments")
	c.collect_fragment("tethys_1")
	_assert(not c.world_unlocked("Cinder"), "one Tethys fragment must not unlock Cinder")
	c.collect_fragment("tethys_2")
	_assert(c.world_unlocked("Cinder"), "both Tethys fragments must unlock Cinder")
	c.collect_fragment("cinder_3")
	_assert(c.world_unlocked("Vell"), "Cinder fragment must unlock Vell")
	c.collect_fragment("vell_4")
	_assert(c.world_unlocked("Ossuary"), "Vell fragment must unlock Ossuary")
	c.collect_fragment("ossuary_5")
	_assert(not c.world_unlocked("Hollow"), "Hollow must require both Ossuary fragments")
	c.collect_fragment("ossuary_6")
	_assert(c.world_unlocked("Hollow"), "both Ossuary fragments must unlock Hollow")

func _test_nemesis_requires_all_fragments() -> void:
	var c := CampaignState.new()
	for fragment_id in CampaignState.FRAGMENTS:
		if str(fragment_id) != "hollow_7": c.collect_fragment(str(fragment_id))
	_assert(c.fragment_count() == 6, "campaign should hold six fragments before final Hollow fragment")
	_assert(not c.world_unlocked("Nemesis"), "Nemesis must stay hidden before seven fragments")
	c.collect_fragment("hollow_7")
	_assert(c.fragment_count() == 7, "campaign must contain seven fragments")
	_assert(c.world_unlocked("Nemesis"), "seven fragments must unlock Nemesis")

func _test_world_surface_contract() -> void:
	var source := FileAccess.get_file_as_string("res://scripts/ship_controller.gd")
	_assert(source.contains("surface_query.call(global_position)"), "ship must query the local planetary surface")
	_assert(source.contains("valid_surface and global_position.y <= ground_y"), "ship must not land on an invisible global plane between worlds")
	var world_source := FileAccess.get_file_as_string("res://scripts/campaign_world.gd")
	_assert(world_source.contains("SURFACE_RADIUS"), "campaign worlds need bounded physical landing zones")
	_assert(world_source.contains("approach_target"), "campaign worlds need physical approach targets")

func _test_disembark_contract() -> void:
	var source := FileAccess.get_file_as_string("res://scripts/game_root.gd")
	_assert(source.contains("elif ship.landed: _disembark()"), "player must be able to exit after a physical landing")
	_assert(source.contains("LAND THE SHIP BEFORE EXITING"), "disembark must reject in-flight exits")

func _test_save_round_trip_shape() -> void:
	var state := {"campaign": {"fragments": {"tethys_1": true}}, "tutorial": {"index": 3, "completed": {"move": true}}}
	_assert(SaveSystem.save_state(state), "save should succeed")
	var loaded := SaveSystem.load_state()
	_assert(loaded.has("tutorial"), "save should load tutorial state")
	_assert(loaded.has("campaign"), "save should load campaign state")
