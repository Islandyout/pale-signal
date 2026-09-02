class_name CampaignState
extends RefCounted

# Authoring data for later worlds is retained, but production remains hard-locked
# to the Tethys/Kestra vertical slice until that first hour passes its quality gates.
const PRODUCTION_WORLDS := ["Tethys"]
const WORLD_ORDER := ["Tethys", "Cinder", "Vell", "Ossuary", "Hollow", "Nemesis"]

const WORLD_DATA := {
	"Tethys": {
		"anchor": Vector3(0, 0, 0),
		"color": Color("#445e51"),
		"sky": Color("#6f8894"),
		"resources": ["Pale Reed", "Lantern Cap", "Banded Ironstone", "Clathrate Pocket"],
	},
	"Cinder": {
		"anchor": Vector3(0, 0, -5200),
		"color": Color("#6d392c"),
		"sky": Color("#8d5a43"),
		"resources": ["Vitrous Slag", "Sulphur Bloom", "Ember Lichen"],
	},
	"Vell": {
		"anchor": Vector3(4400, 0, -8200),
		"color": Color("#8fa9b6"),
		"sky": Color("#668394"),
		"resources": ["Blue Ice Column", "Impact Regolith", "Rime Frond"],
	},
	"Ossuary": {
		"anchor": Vector3(-5200, 0, -12300),
		"color": Color("#766f63"),
		"sky": Color("#79756f"),
		"resources": ["Chalk Spar", "Ferric Dust", "Grey Stalk"],
	},
	"Hollow": {
		"anchor": Vector3(5600, 0, -16800),
		"color": Color("#304d5c"),
		"sky": Color("#31596a"),
		"resources": ["Deeplight Bulb", "Pressure Vine", "Abyssal Crystal"],
	},
	"Nemesis": {
		"anchor": Vector3(0, 0, -22600),
		"color": Color("#171a20"),
		"sky": Color("#05070b"),
		"resources": ["Null Shard"],
	},
}

const FRAGMENTS := {
	"tethys_1": {"world":"Tethys", "name":"Kneeling Array Fragment", "offset":Vector3(155, 0.8, -210)},
	"tethys_2": {"world":"Tethys", "name":"Reed Sink Fragment", "offset":Vector3(-245, 0.8, -165)},
	"cinder_3": {"world":"Cinder", "name":"The Anvil Fragment", "offset":Vector3(180, 0.8, 145)},
	"vell_4": {"world":"Vell", "name":"Under-Ice Relay Fragment", "offset":Vector3(-170, 0.8, -205)},
	"ossuary_5": {"world":"Ossuary", "name":"Ossuary Spine Fragment", "offset":Vector3(215, 0.8, -150)},
	"ossuary_6": {"world":"Ossuary", "name":"Silent Foundry Fragment", "offset":Vector3(-230, 0.8, 185)},
	"hollow_7": {"world":"Hollow", "name":"Drowned Choir Fragment", "offset":Vector3(190, 0.8, -220)},
}

const UPGRADE_ORDER := ["thrust", "fuel", "scan", "hull", "life", "heat", "rcs"]
const UPGRADE_COSTS := {
	"thrust": {"Banded Ironstone":2, "Vitrous Slag":1},
	"fuel": {"Clathrate Pocket":2, "Blue Ice Column":1},
	"scan": {"Pale Reed":2, "Deeplight Bulb":1},
	"hull": {"Banded Ironstone":2, "Ferric Dust":2},
	"life": {"Pale Reed":1, "Rime Frond":2},
	"heat": {"Sulphur Bloom":2, "Vitrous Slag":2},
	"rcs": {"Chalk Spar":2, "Abyssal Crystal":1},
}

var inventory: Dictionary = {}
var fragments: Dictionary = {}
var collected_sites: Dictionary = {}
var upgrades: Dictionary = {}
var evidence_notes: Dictionary = {}
var selected_world := "Tethys"
var ending_complete := false

func _init() -> void:
	for id in UPGRADE_ORDER:
		upgrades[id] = 0

func fragment_count() -> int:
	return fragments.size()

func collect_resource(resource_name: String, site_id: String, amount := 1) -> bool:
	if collected_sites.has(site_id): return false
	collected_sites[site_id] = true
	inventory[resource_name] = int(inventory.get(resource_name, 0)) + amount
	return true

func collect_fragment(fragment_id: String) -> bool:
	if fragments.has(fragment_id): return false
	if not FRAGMENTS.has(fragment_id): return false
	fragments[fragment_id] = true
	collected_sites["fragment|" + fragment_id] = true
	return true

func record_evidence(note_id: String, title: String, detail: String) -> bool:
	if note_id.is_empty() or evidence_notes.has(note_id): return false
	evidence_notes[note_id] = {"title": title, "detail": detail}
	return true

func evidence_count() -> int:
	return evidence_notes.size()

# This describes dormant campaign progression data only. Production routing and
# world construction are separately constrained by PRODUCTION_WORLDS.
func world_unlocked(world: String) -> bool:
	match world:
		"Tethys": return true
		"Cinder": return fragments.has("tethys_1") and fragments.has("tethys_2")
		"Vell": return fragments.has("cinder_3")
		"Ossuary": return fragments.has("vell_4")
		"Hollow": return fragments.has("ossuary_5") and fragments.has("ossuary_6")
		"Nemesis": return fragment_count() >= 7
	return false

func available_worlds() -> Array[String]:
	var worlds: Array[String] = []
	for world in PRODUCTION_WORLDS:
		if world_unlocked(world): worlds.append(world)
	return worlds

func select_next_world() -> String:
	var available := available_worlds()
	if available.is_empty():
		selected_world = "Tethys"
		return selected_world
	var index := available.find(selected_world)
	if index < 0: index = 0
	else: index = (index + 1) % available.size()
	selected_world = available[index]
	return selected_world

func select_objective_world() -> String:
	for world in PRODUCTION_WORLDS:
		if not world_unlocked(world): continue
		var complete := true
		for fragment_id in FRAGMENTS:
			var data: Dictionary = FRAGMENTS[fragment_id]
			if str(data["world"]) == world and not fragments.has(fragment_id):
				complete = false
				break
		if not complete:
			selected_world = world
			return selected_world
	selected_world = "Tethys"
	return selected_world

func next_upgrade() -> String:
	for id in UPGRADE_ORDER:
		if int(upgrades.get(id, 0)) <= 0: return id
	return ""

func can_buy_upgrade(id: String) -> bool:
	if not UPGRADE_COSTS.has(id): return false
	if int(upgrades.get(id, 0)) > 0: return false
	var cost: Dictionary = UPGRADE_COSTS[id]
	for resource_name in cost:
		if int(inventory.get(resource_name, 0)) < int(cost[resource_name]): return false
	return true

func buy_upgrade(id: String) -> bool:
	if not can_buy_upgrade(id): return false
	var cost: Dictionary = UPGRADE_COSTS[id]
	for resource_name in cost:
		inventory[resource_name] = int(inventory.get(resource_name, 0)) - int(cost[resource_name])
	upgrades[id] = 1
	return true

func upgrade_cost_text(id: String) -> String:
	if not UPGRADE_COSTS.has(id): return ""
	var parts: Array[String] = []
	var cost: Dictionary = UPGRADE_COSTS[id]
	for resource_name in cost:
		parts.append("%s x%d" % [str(resource_name), int(cost[resource_name])])
	return ", ".join(parts)

func snapshot() -> Dictionary:
	return {
		"inventory": inventory.duplicate(true),
		"fragments": fragments.duplicate(true),
		"collected_sites": collected_sites.duplicate(true),
		"upgrades": upgrades.duplicate(true),
		"evidence_notes": evidence_notes.duplicate(true),
		"selected_world": selected_world,
		"ending_complete": ending_complete,
	}

func restore(data: Dictionary) -> void:
	if data.has("inventory") and data["inventory"] is Dictionary: inventory = (data["inventory"] as Dictionary).duplicate(true)
	if data.has("fragments") and data["fragments"] is Dictionary: fragments = (data["fragments"] as Dictionary).duplicate(true)
	if data.has("collected_sites") and data["collected_sites"] is Dictionary: collected_sites = (data["collected_sites"] as Dictionary).duplicate(true)
	if data.has("upgrades") and data["upgrades"] is Dictionary:
		var restored: Dictionary = data["upgrades"]
		for id in UPGRADE_ORDER: upgrades[id] = int(restored.get(id, 0))
	if data.has("evidence_notes") and data["evidence_notes"] is Dictionary: evidence_notes = (data["evidence_notes"] as Dictionary).duplicate(true)
	selected_world = str(data.get("selected_world", selected_world))
	if not PRODUCTION_WORLDS.has(selected_world): selected_world = "Tethys"
	ending_complete = bool(data.get("ending_complete", false))