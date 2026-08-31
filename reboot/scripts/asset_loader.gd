class_name AssetLoader
extends RefCounted

const CATALOG := {
	"ship": "res://assets/imported/ship_player.glb",
	"eva": "res://assets/imported/eva_suit.glb",
	"talari": "res://assets/imported/talari_civilian.glb",
	"kestra": "res://assets/imported/kestra_module.glb",
	"wildlife": "res://assets/imported/flat_grazer.glb",
	"humanoid_anims": "res://assets/imported/humanoid_animations.glb",
}

static func instantiate_or_fallback(key: String, fallback: Node3D) -> Node3D:
	var path: String = CATALOG.get(key, "")
	if not path.is_empty() and ResourceLoader.exists(path):
		var packed := load(path)
		if packed is PackedScene:
			var instance := packed.instantiate()
			fallback.queue_free()
			return instance
	return fallback

static func missing_assets() -> PackedStringArray:
	var missing := PackedStringArray()
	for key in CATALOG:
		if not ResourceLoader.exists(CATALOG[key]): missing.append(key)
	return missing
