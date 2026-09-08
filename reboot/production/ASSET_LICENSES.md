# Pale Signal Reboot — Asset & License Ledger

This is the production reboot's asset provenance register. No external model enters a release build without an immutable source reference and a license record.

## Policy

- Zero paid runtime dependencies/assets.
- Prefer CC0 for redistributable production-base art.
- Free assets are **source material**, not Pale Signal's final identity.
- Hero ship, Talari appearance, Flat Grazer, Pale Signal artifacts, and hero archaeology require custom or substantially transformed art treatment before final release.
- CI downloads pinned third-party binaries before Godot import and verifies hashes.
- Procedural fallbacks remain available so a missing art file can never break core mechanics.

## Current imported production-base assets

| Local path | Upstream | Pinned revision | License | Integrity | Role / final-art status |
|---|---|---|---|---|---|
| `assets/imported/eva_suit.glb` | Quaternius Universal Base Characters, mirrored/audited in `Seyamalam/blood-league-kickoff` | `aa02a4e6d8337a0604d2da131bcbbeb1f01badf0` | CC0 1.0 | SHA-256 `a466828c67a4acc9b2413212ce6d9cde235e3aed9b675680c14fd9673858f118` | Humanoid rig/body foundation. Any production identity is supplied by authored in-project treatment rather than by this source binary alone. |
| `assets/imported/talari_civilian.glb` | Same audited Quaternius base-character binary as EVA | same | CC0 1.0 | same binary/hash | Animation/scale source only. The first-hour Talari identity is substantially transformed in-project by `WorldArt` and `TalariInstructor`; this stock binary is never accepted as final presentation by itself. |
| `assets/imported/humanoid_animations.glb` | Quaternius Universal Animation Library, mirrored/audited in `Seyamalam/blood-league-kickoff` | `aa02a4e6d8337a0604d2da131bcbbeb1f01badf0` | CC0 1.0 | SHA-256 `4c748767741a3e495d89667b9a218b690ba9810b9517a12e960780e3ca72c4e9` | Humanoid locomotion/interaction animation source. |
| `assets/imported/ship_player.gltf` | Quaternius Ultimate Spaceships — `Challenger`, mirrored/audited in `euuuuuuan/voidclad-public` | `440916aabc30abe014cb33ad90bd150bfbf22dd0` | CC0 1.0 | SHA-256 `c600b39fd587c323557c682e7aae2e976b62fff2984929163b7ee12a0e4323fd` | Survey-craft source mesh. `HeroShipArt` supplies the authored dorsal science spine, asymmetric sensor boom, VTOL housings, science pallet, survey lights, and unequal field vanes; the imported source is not treated as final identity by itself. |
| `assets/imported/kestra_module.glb` | Kenney CC0 environment/space module mirrored in `0xrise/cc0-assets-nft` | `4c16444b4133f4ffe7679b59d26b9565e3258be0` | CC0 1.0 | Git blob SHA-1 `48574011a86d5fccd6505417eb8402218b7689fe` | Support geometry for the Kestra architectural kitbash. Hero archaeology and Pale Signal presentation are custom-layered in-project; the module remains source geometry rather than final civic identity by itself. |

Bundled upstream license texts are downloaded to `assets/imported/licenses/` by `tools/fetch_cc0_assets.py` where supplied by the audited mirror.

## Deliberately not sourced from generic packs

- `flat_grazer.glb` — no external production binary is currently used; the first-hour Flat Grazer morphology is custom-authored in-project.
- Pale Signal fragment/artifact hero meshes — custom in-project presentation.
- Signature archaeology reconstruction hero pieces — custom/kitbashed beyond recognition in-project.

## Identity-treatment cross-check

The provenance entries above describe the third-party source binaries, not the complete rendered identity. The authoritative transformation record is maintained in `ASSET_LEDGER.md` and must remain synchronized with this file. A source binary may remain generic while the shipped presentation is accepted only when the authored in-project layer substantially changes its read. Removing those authored layers would regress the hero-art gate even though the source licenses remain valid.

## Build rule

`python3 tools/fetch_cc0_assets.py` must succeed before release import/export. Godot then imports the downloaded glTF/GLB files and CI verifies they resolve as valid imported resources before exporting a playable build.
