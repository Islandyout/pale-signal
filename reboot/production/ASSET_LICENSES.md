# Pale Signal Reboot — Asset & License Ledger

This is the production reboot's asset provenance register. No external model enters a release build without an immutable source reference and a license record.

## Policy

- Zero paid runtime dependencies/assets.
- Prefer CC0 for redistributable production-base art.
- Free assets are **source material**, not Pale Signal's final identity.
- Hero ship, Talari appearance, Flat Grazer, Pale Signal artifacts, and hero archaeology receive custom or substantially transformed art treatment before final release.
- CI downloads pinned third-party binaries before Godot import and verifies hashes.
- Procedural fallbacks remain available so a missing art file can never break core mechanics.

## Current imported production-base assets

| Local path | Upstream | Pinned revision | License | Integrity | Role / final-art status |
|---|---|---|---|---|---|
| `assets/imported/eva_suit.glb` | Quaternius Universal Base Characters, mirrored/audited in `Seyamalam/blood-league-kickoff` | `aa02a4e6d8337a0604d2da131bcbbeb1f01badf0` | CC0 1.0 | SHA-256 `a466828c67a4acc9b2413212ce6d9cde235e3aed9b675680c14fd9673858f118` | Temporary humanoid rig/body foundation. EVA suit exterior must be remodeled. |
| `assets/imported/talari_civilian.glb` | Same audited Quaternius base-character binary as EVA | same | CC0 1.0 | same binary/hash | Temporary retargetable rig proxy only. Talari proportions, head, clothing, materials and silhouette must become custom. |
| `assets/imported/humanoid_animations.glb` | Quaternius Universal Animation Library, mirrored/audited in `Seyamalam/blood-league-kickoff` | `aa02a4e6d8337a0604d2da131bcbbeb1f01badf0` | CC0 1.0 | SHA-256 `4c748767741a3e495d89667b9a218b690ba9810b9517a12e960780e3ca72c4e9` | Humanoid locomotion/interaction animation source. |
| `assets/imported/ship_player.gltf` | Quaternius Ultimate Spaceships — `Challenger`, mirrored/audited in `euuuuuuan/voidclad-public` | `440916aabc30abe014cb33ad90bd150bfbf22dd0` | CC0 1.0 | SHA-256 `c600b39fd587c323557c682e7aae2e976b62fff2984929163b7ee12a0e4323fd` | Temporary survey-craft remodeling base. Final ship requires altered proportions, nacelles/RCS/gear/equipment, materials and weathering. |
| `assets/imported/kestra_module.glb` | Kenney CC0 environment/space module mirrored in `0xrise/cc0-assets-nft` | `4c16444b4133f4ffe7679b59d26b9565e3258be0` | CC0 1.0 | Git blob SHA-1 `48574011a86d5fccd6505417eb8402218b7689fe` | Temporary support geometry for the training/Kestra architectural kitbash; not final civic visual identity. |

Bundled upstream license texts are downloaded to `assets/imported/licenses/` by `tools/fetch_cc0_assets.py` where supplied by the audited mirror.

## Deliberately not sourced from generic packs

- `flat_grazer.glb` — custom creature required.
- Pale Signal fragment/artifact hero meshes — custom.
- Signature archaeology reconstruction hero pieces — custom/kitbashed beyond recognition.

## Build rule

`python3 tools/fetch_cc0_assets.py` must succeed before release import/export. Godot then imports the downloaded glTF/GLB files and CI verifies they resolve as valid imported resources before exporting a playable build.
