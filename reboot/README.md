# Pale Signal — Production Reboot

This is a clean Godot production reboot. The browser prototype is preserved as legacy reference; it is not the architecture for this version.

## First playable target

One authored Tethys training basin proves the whole game language before another planet is added:

**EVA → independent look → atmosphere scan → specimen scan → physical collection → archaeological reconstruction → board → manual VTOL launch → continuous atmosphere-to-space flight → NAV cues → manual landing.**

The tutorial uses the same production mechanics. Short camera cutscenes are allowed only for framing/reveals and are skippable.

## Architecture

- `EVAController`: embodied movement/look only.
- `ShipController`: throttle, explicit steering, atmosphere/vacuum behavior, landing and NAV cues.
- `ScannerSystem`: identification/analysis only.
- `Interactable`: physical-world interaction state.
- `ArchaeologySystem`: reconstruction skill mechanic.
- `TutorialDirector`: observes mechanic signals; it cannot fake completion.
- `AssetLoader`: local GLB/glTF adapter with development fallbacks.
- `SaveSystem`: small explicit persisted state.

See `production/MECHANIC_CONTRACTS.md` before changing any controller or tutorial logic.
