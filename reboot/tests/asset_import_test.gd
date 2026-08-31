extends SceneTree

const REQUIRED := [
	"res://assets/imported/ship_player.gltf",
	"res://assets/imported/eva_suit.glb",
	"res://assets/imported/talari_civilian.glb",
	"res://assets/imported/kestra_module.glb",
	"res://assets/imported/humanoid_animations.glb",
]

func _init() -> void:
	var failed := false
	for path in REQUIRED:
		if not ResourceLoader.exists(path):
			printerr("MISSING IMPORTED ASSET: ", path)
			failed = true
			continue
		var resource: Resource = load(path)
		if not resource is PackedScene:
			printerr("ASSET DID NOT IMPORT AS PACKED SCENE: ", path)
			failed = true
	if failed:
		quit(1)
	else:
		print("PALE SIGNAL REAL ASSET IMPORTS: PASS")
		quit(0)
