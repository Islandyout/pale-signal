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
	var kestra_source := FileAccess.get_file_as_string("res://scripts/kestra_environment.gd")
	_assert(kestra_source.contains("instantiate_or_fallback(\"kestra\""), "Kestra hero site must use the audited imported module with a fallback")
	_assert(kestra_source.contains("fragment|tethys_2"), "authored Kestra presentation must remain attached to the save-compatible archaeology interaction")
	if failures == 0:
		print("KESTRA PRODUCTION SCOPE TEST: PASS")
		quit(0)
	else:
		push_error("KESTRA PRODUCTION SCOPE TEST: %d FAILURE(S)" % failures)
		quit(1)

func _assert(value: bool, message: String) -> void:
	if not value:
		failures += 1
		push_error(message)
