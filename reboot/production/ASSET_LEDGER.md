# Approved GLB / glTF asset pool

The reboot uses local imported assets only after their source and license are recorded. Godot recommends glTF 2.0 and supports both `.gltf` and `.glb`; GLB is the preferred shipping format.

| Use | Source | Candidate pack | Format | License | Reboot policy |
|---|---|---|---|---|---|
| Ship / orbital props | Kenney | Space Kit | GLB | CC0 | approved |
| Ship/station modules | Kenney | Modular Space Kit | GLB | CC0 | approved |
| Interior props | Kenney | Space Station Kit | GLB | CC0 | approved |
| Kestra modular architecture | Quaternius | Modular Sci-Fi MegaKit | glTF → GLB | CC0 | approved |
| Sci-fi props/screens | Quaternius | Sci-Fi Essentials Kit | glTF → GLB | CC0 | approved |
| EVA/Talari animation base | Quaternius | Universal Animation Library / Library 2 | GLB | CC0 | approved for retargeting |
| Terrain materials | Poly Haven | Rocky Terrain / Rock Ground families | glTF/PBR | CC0 | approved |

## Required local filenames

- `res://assets/imported/ship_player.glb`
- `res://assets/imported/eva_suit.glb`
- `res://assets/imported/talari_civilian.glb`
- `res://assets/imported/kestra_module.glb`
- `res://assets/imported/flat_grazer.glb`
- `res://assets/imported/humanoid_animations.glb`

During mechanic development, procedural fallback meshes keep the game playable when binaries are absent. Production/release CI will later switch approved production entries from optional to required and fail when they are missing.

## Source pages

- https://kenney.nl/assets/space-kit
- https://kenney.nl/assets/modular-space-kit
- https://kenney.nl/assets/space-station-kit
- https://quaternius.com/packs/modularscifimegakit.html
- https://quaternius.com/packs/scifiessentialskit.html
- https://quaternius.com/packs/universalanimationlibrary.html
- https://quaternius.com/packs/universalanimationlibrary2.html
- https://polyhaven.com/
