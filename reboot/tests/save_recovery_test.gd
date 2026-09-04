extends SceneTree

const SaveSystemScript = preload("res://scripts/save_system.gd")
const CampaignStateScript = preload("res://scripts/campaign_state.gd")
const PRIMARY := "user://pale_signal_reboot.save"
const BACKUP := "user://pale_signal_reboot.save.bak"
const TEMP := "user://pale_signal_reboot.save.tmp"

func _init() -> void:
	_cleanup()
	var campaign_source := FileAccess.get_file_as_string("res://scripts/campaign_state.gd")
	var hud_source := FileAccess.get_file_as_string("res://scripts/production_hud.gd")
	var save_source := FileAccess.get_file_as_string("res://scripts/save_system.gd")
	var runtime_source := FileAccess.get_file_as_string("res://scripts/runtime_persistence.gd")
	var checkpoint_source := FileAccess.get_file_as_string("res://scripts/runtime_checkpoint.gd")
	var project_source := FileAccess.get_file_as_string("res://project.godot")
	if not campaign_source.contains("\"evidence_notes\": evidence_notes.duplicate(true)"):
		_fail("campaign snapshot must persist archaeology evidence notes")
		return
	if not campaign_source.contains("data.has(\"evidence_notes\")"):
		_fail("campaign restore must recover archaeology evidence notes")
		return
	if not hud_source.contains("_reconstruction_is_tutorial_site = str(root.get(\"active_campaign_fragment\")).is_empty()"):
		_fail("archaeology evidence payoff must capture reconstruction provenance")
		return
	if not hud_source.contains("if not _reconstruction_is_tutorial_site:"):
		_fail("Kestra contradiction must not leak into later fragment reconstructions")
		return
	if not save_source.contains("serialized[\"runtime\"] = runtime"):
		_fail("progression saves must include optional physical runtime context when the production scene exists")
		return
	if not save_source.contains("if bool(ship.landed):\n\t\tship_velocity = Vector3.ZERO"):
		_fail("landed runtime snapshots must not preserve pre-touchdown velocity")
		return
	if not runtime_source.contains("call_deferred(\"_restore_runtime_state\")"):
		_fail("physical runtime restore must wait until production controllers are constructed")
		return
	if not runtime_source.contains("ship.global_position = _array_to_vector3") or not runtime_source.contains("eva.global_position = _array_to_vector3"):
		_fail("runtime restore must recover both ship and EVA physical position")
		return
	if not runtime_source.contains("ship.velocity = Vector3.ZERO if bool(runtime.get(\"ship_landed\""):
		_fail("landed reloads must restart physically settled instead of replaying stale touchdown velocity")
		return
	if not project_source.contains("RuntimePersistence=\"*res://scripts/runtime_persistence.gd\""):
		_fail("runtime persistence must be enabled in the production Godot project")
		return
	if not project_source.contains("RuntimeCheckpoint=\"*res://scripts/runtime_checkpoint.gd\""):
		_fail("controller-mode checkpoint persistence must be enabled in the production Godot project")
		return
	if not checkpoint_source.contains("if current_mode == _last_mode:") or not checkpoint_source.contains("_root.call_deferred(\"_save_game\")"):
		_fail("boarding and disembark mode transitions must checkpoint through the canonical save path")
		return

	# The two authored first-hour reconstructions must award persistent, distinct
	# conclusions through the same fragment collection path used by gameplay.
	var evidence_campaign = CampaignStateScript.new()
	if not evidence_campaign.collect_fragment("tethys_1"):
		_fail("Tethys reconstruction fixture must collect")
		return
	if not evidence_campaign.collect_fragment("tethys_2"):
		_fail("Kestra reconstruction fixture must collect")
		return
	var tethys_evidence: Dictionary = evidence_campaign.evidence_for_fragment("tethys_1")
	var kestra_evidence: Dictionary = evidence_campaign.evidence_for_fragment("tethys_2")
	if tethys_evidence.is_empty() or kestra_evidence.is_empty():
		_fail("first-hour fragment collection must create authored evidence")
		return
	if str(tethys_evidence.get("detail", "")) == str(kestra_evidence.get("detail", "")):
		_fail("Tethys and Kestra evidence must preserve conflicting authored conclusions")
		return
	if evidence_campaign.evidence_count() != 2:
		_fail("first-hour evidence ledger must contain both reconstruction conclusions")
		return
	if evidence_campaign.collect_fragment("tethys_1"):
		_fail("recollecting an existing fragment must remain idempotent")
		return
	if evidence_campaign.evidence_count() != 2:
		_fail("duplicate fragment collection must not duplicate evidence")
		return

	var previous := {
		"tutorial": {"index": 4},
		"campaign": {
			"fragments": {"tethys_1": true},
			"evidence_notes": {
				"kestra_foundation_contradiction": {
					"title": "Kestra Foundation Contradiction",
					"detail": "Talari survey and buried inscription disagree."
				}
			}
		}
	}
	var current := {
		"tutorial": {"index": 6},
		"campaign": {
			"fragments": {"tethys_1": true, "tethys_2": true},
			"evidence_notes": {
				"kestra_foundation_contradiction": {
					"title": "Kestra Foundation Contradiction",
					"detail": "Talari survey and buried inscription disagree."
				}
			}
		}
	}
	var expected_previous = JSON.parse_string(JSON.stringify(previous))
	if not expected_previous is Dictionary:
		_fail("could not normalize recovery fixture through JSON")
		return
	if not SaveSystemScript.save_state(previous):
		_fail("initial recovery fixture save failed")
		return
	if not SaveSystemScript.save_state(current):
		_fail("second recovery fixture save failed")
		return

	var corrupt := FileAccess.open(PRIMARY, FileAccess.WRITE)
	if corrupt == null:
		_fail("could not open primary save to simulate interrupted/corrupt write")
		return
	corrupt.store_string("{ interrupted")
	corrupt.close()

	var recovered := SaveSystemScript.load_state()
	if recovered != expected_previous:
		_fail("invalid primary save must recover the previous serialized known-good backup, including archaeology evidence")
		return

	_cleanup()
	print("PALE SIGNAL SAVE RECOVERY TEST: PASS")
	quit(0)

func _cleanup() -> void:
	var dir := DirAccess.open("user://")
	if dir == null:
		return
	for name in ["pale_signal_reboot.save", "pale_signal_reboot.save.bak", "pale_signal_reboot.save.tmp"]:
		if dir.file_exists(name):
			dir.remove(name)

func _fail(message: String) -> void:
	_cleanup()
	push_error(message)
	quit(1)
