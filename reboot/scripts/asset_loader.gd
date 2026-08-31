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
	var path: String = str(CATALOG.get(key, ""))
	if not path.is_empty() and ResourceLoader.exists(path):
		var resource: Resource = load(path)
		if resource is PackedScene:
			var packed_scene: PackedScene = resource as PackedScene
			var node: Node = packed_scene.instantiate()
			if node is Node3D:
				fallback.queue_free()
				return node as Node3D
	return fallback

static func missing_assets() -> PackedStringArray:
	var missing := PackedStringArray()
	for key in CATALOG:
		var path: String = str(CATALOG[key])
		if not ResourceLoader.exists(path): missing.append(str(key))
	return missing
