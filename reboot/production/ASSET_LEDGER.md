# Approved GLB / glTF asset pool

The reboot uses local imported assets only after their source and license are recorded. Godot recommends glTF 2.0 and supports both `.gltf` and `.glb`; GLB is preferred for shipping when the audited source is available in that form. Do not rename or transcode an audited source merely to satisfy the preference without updating its integrity record.

| Use | Source | Candidate pack | Format | License | Reboot policy |
|---|---|---|---|---|---|
| Ship / orbital props | Kenney | Space Kit | GLB | CC0 | approved |
| Ship/station modules | Kenney | Modular Space Kit | GLB | CC0 | approved |
| Interior props | Kenney | Space Station Kit | GLB | CC0 | approved |
| Kestra modular architecture | Quaternius | Modular Sci-Fi MegaKit | glTF → GLB | CC0 | approved |
| Sci-fi props/screens | Quaternius | Sci-Fi Essentials Kit | glTF → GLB | CC0 | approved |
| EVA/Talari animation base | Quaternius | Universal Animation Library / Library 2 | GLB | CC0 | approved for retargeting / base motion only |
| Terrain materials | Poly Haven | Rocky Terrain / Rock Ground families | glTF/PBR | CC0 | approved |

## Current audited local import paths

These paths reflect the binaries currently fetched and verified by `tools/fetch_cc0_assets.py` and Godot CI. They must stay synchronized with `ASSET_LICENSES.md`, the fetch script, `AssetLoader`, and CI integrity/import checks.

- `res://assets/imported/ship_player.gltf`
- `res://assets/imported/eva_suit.glb`
- `res://assets/imported/talari_civilian.glb`
- `res://assets/imported/kestra_module.glb`
- `res://assets/imported/humanoid_animations.glb`

`flat_grazer.glb` is deliberately **not** listed as a current imported binary because the production Flat Grazer identity is custom-authored in-project today. A future external or custom binary must receive its own provenance/integrity entry before it can replace or augment that presentation.

During mechanic development, procedural fallback meshes keep the game playable when binaries are absent. Production/release CI may promote approved entries from fetched/verified dependencies to bundled required release assets only when their provenance, integrity, and final-art treatment are all recorded.

## Identity transformation record

- The expedition hero ship now uses the audited Kenney source only as a base. `HeroShipArt` adds an offset dorsal science spine, asymmetric sensor boom, four physically legible VTOL housings, belly science pallet, restrained survey index lights, and unequal rear field vanes. The presentation layer is isolated beneath the existing `ShipController`, so collision, camera, thrust, save, and tutorial contracts are unchanged. These authored components are generated in-project and add no third-party license obligation.
- The Talari civilian GLB is an animation/scale source, not the final Talari presentation. `WorldArt._decorate_talari()` adds the authored cranial sensory fan, asymmetric survey mantle, restrained luminous survey bars, and field transceiver around the imported base. These elements are generated in-project and therefore do not add a third-party license obligation.
- The Flat Grazer fallback now establishes the authored species morphology rather than a stock quadruped placeholder: a low browsing disk, overlapping dorsal plates, offset sensory sail, three-tooth grazing rake, six short stilt legs, and restrained paired field sensors. These elements are generated in-project and therefore add no third-party license obligation. A future verified `flat_grazer.glb` may replace or augment source geometry, but it must preserve this substantially transformed identity rather than becoming the final presentation unchanged.
- The Tethys tutorial foundation is now a custom in-project hero archaeology presentation layered over the unchanged interaction/collision anchor. `WorldArt.decorate_training_foundation()` adds asymmetric load ribs, paired restraint shoes, interrupted evidence traces, and a survey datum so the two reconstruction evidence layers have a readable physical basis instead of presenting as a generic box. These elements are generated in-project and add no third-party license obligation.
- The Kestra first-hour Pale Signal fragment now has a custom in-project hero presentation attached directly to the canonical `fragment|tethys_2` interactable. `KestraEnvironment._build_pale_fragment_artifact()` replaces the hidden generic glowing cylinder with an offset dark core, fractured ceramic shell, asymmetric luminous seams, and a field needle. This keeps scanner, collection, save, and tutorial state unchanged while giving the Pale Signal object a distinct authored identity. The presentation uses only Godot primitives and adds no third-party license obligation.
- Kestra hero archaeology is custom-layered around the audited module base, but final site treatment and final Talari body/face treatment remain subject to the same rule: source assets may accelerate production, but their final presentation must be custom or substantially transformed.

## Source pages

- https://kenney.nl/assets/space-kit
- https://kenney.nl/assets/modular-space-kit
- https://kenney.nl/assets/space-station-kit
- https://quaternius.com/packs/modularscifimegakit.html
- https://quaternius.com/packs/scifiessentialskit.html
- https://quaternius.com/packs/universalanimationlibrary.html
- https://quaternius.com/packs/universalanimationlibrary2.html
- https://polyhaven.com/
