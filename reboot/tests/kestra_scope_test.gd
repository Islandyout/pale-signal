extends SceneTree

var failures := 0

func _init() -> void:
	var state := CampaignState.new()
	_assert(CampaignState.PRODUCTION_WORLDS == ["Tethys", "Kestra"], "production scope must remain exactly Tethys/Kestra")
	_assert(not state.world_unlocked("Kestra"), "Kestra must remain gated until the first Tethys signal fragment is reconstructed")
	_assert(state.available_worlds() == ["Tethys"], "new saves must expose only Tethys before first-hour evidence is recovered")
	state.collect_fragment("tethys_1")
	_assert(state.world_unlocked("Kestra"), "Tethys evidence must unlock Kestra")
	_assert(state.available_worlds() == ["Tethys", "Kestra"], "first-hour route must expose Kestra after Tethys evidence")
	_assert(state.select_objective_world() == "Kestra", "objective routing must advance from completed Tethys evidence to Kestra")
	state.collect_fragment("tethys_2")
	_assert(state.world_unlocked("Cinder"), "dormant campaign progression data must preserve the existing post-slice unlock chain")
	_assert(not state.available_worlds().has("Cinder"), "later worlds must remain physically unreachable during the production freeze")
	var world_source := FileAccess.get_file_as_string("res://scripts/campaign_world.gd")
	_assert(world_source.contains("CampaignState.PRODUCTION_WORLDS"), "physical world construction must remain driven by the production allow-list")
	var root_source := FileAccess.get_file_as_string("res://scripts/game_root.gd")
	_assert(not root_source.contains("U FABRICATOR"), "production controls must not advertise the frozen upgrade tree")
	_assert(not root_source.contains("Input.is_action_just_pressed(\"fabricator\")"), "production runtime must not expose the frozen fabricator action")
	_assert(not root_source.contains("func _use_fabricator()"), "production root must not retain a reachable fabricator interaction")
	_assert(not root_source.contains("campaign.next_upgrade()"), "production HUD must not surface later-world upgrade progression")
	_assert(not root_source.contains("THE FULL ASTER SYSTEM IS NOW YOUR MISSION"), "tutorial completion must not imply later worlds are production-ready")
	_assert(root_source.contains("TETHYS/KESTRA INVESTIGATION ACTIVE"), "tutorial completion must hand off explicitly to the current vertical slice")
	_assert(root_source.contains("FIRST-HOUR EVIDENCE %d / 2"), "production HUD must frame progress around the two authored first-hour evidence sites")
	var kestra_source := FileAccess.get_file_as_string("res://scripts/kestra_environment.gd")
	_assert(kestra_source.contains("instantiate_or_fallback(\"kestra\""), "Kestra hero site must use the audited imported module with a fallback")
	_assert(kestra_source.contains("fragment|tethys_2"), "authored Kestra presentation must remain attached to the save-compatible archaeology interaction")
	_test_talari_instructor_contract()
	if failures == 0:
		print("KESTRA PRODUCTION SCOPE TEST: PASS")
		quit(0)
	else:
		push_error("KESTRA PRODUCTION SCOPE TEST: %d FAILURE(S)" % failures)
		quit(1)

func _test_talari_instructor_contract() -> void:
	var world_art_source := FileAccess.get_file_as_string("res://scripts/world_art.gd")
	var talari_source := FileAccess.get_file_as_string("res://scripts/talari_instructor.gd")
	_assert(world_art_source.contains("TalariInstructor.new()"), "the authored Talari instructor routine must remain mounted in the playable Tethys scene")
	_assert(world_art_source.contains("talari_behavior.setup(talari_anchor, eva)"), "Talari behavior must observe the real EVA actor rather than a tutorial proxy")
	_assert(talari_source.contains("attention_range"), "Talari instructor must retain a readable player-attention radius")
	_assert(talari_source.contains("_face_observer(delta)"), "Talari instructor must visibly acknowledge a nearby player")
	_assert(talari_source.contains("_patrol(delta)"), "Talari instructor must retain an authored idle patrol when the player is distant")
	_assert(not talari_source.contains("Input."), "Talari presentation behavior must never consume player input")
	_assert(not talari_source.contains("SaveSystem"), "Talari presentation behavior must never own save/progression state")
	_assert(not talari_source.contains("tutorial.event"), "Talari presentation behavior must never fabricate tutorial completion")

func _assert(value: bool, message: String) -> void:
	if not value:
		failures += 1
		push_error(message)
