# Project Lead Status

Status date: 2026-09-05

The canonical production target is the clean Godot reboot on branch `reboot-godot`, rooted at `reboot/`. The legacy browser prototype is preserved only as historical/reference material and must not be used as the production architecture or implementation target.

## Current phase
Tethys / Kestra production reboot — first-hour vertical slice implementation and hardening.

The reboot currently provides an exportable Godot 4.7.2 project with isolated gameplay systems, mechanic contracts, save recovery coverage, and Web, native Android, and Windows x86_64 export pipelines. The immediate objective remains one exceptional Tethys/Kestra first hour before any breadth expansion.

## Current production direction
- Continuous manual flight remains the core traversal language.
- Camera look stays independent from ship steering.
- VTOL lift stays independent from nose pitch.
- Tutorial progression must be earned through the real mechanics; cutscenes may frame or reveal but cannot substitute for launch, flight, landing, scanning, gathering, archaeology, or other mechanic completion.
- Mobile uses a purpose-built touch layer mapped onto the same mechanics rather than a simplified alternate game.
- Gameplay systems remain isolated across EVA, flight, interaction, scanner, archaeology, wildlife, NPCs, tutorial, save, Signal, and audio.
- Hero ship, Talari identity, Flat Grazer, Pale Signal artifacts, and hero archaeology require custom or substantially transformed presentation.
- Zero-cost policy and explicit asset/license provenance remain mandatory.

## Build and CI position
Current checked `reboot-godot` head: `926e1c6bf808db3e529f929cf59db059aae64be8` (`Fix mobile safe-area parser regression`).

Reboot Godot CI run #245 completed successfully on that head after the mobile safe-area parser regression was corrected. The gated pipeline passed parser/import checks, real GLB/glTF validation, mechanic/regression tests, Web export, native Android debug export, Windows x86_64 export, artifact publication, and isolated preview publication.

Current artifacts from that verified head:
- `pale-signal-reboot-web`: 25,238,444 bytes
- `pale-signal-reboot-android-debug`: 43,001,826 bytes
- `pale-signal-reboot-windows`: 38,922,478 bytes

Successful CI proves build/export health only; it does not prove visual quality, device performance, thermals, touch usability, accessibility in practice, or human-playtest quality.

## Asset / license position
The reboot asset ledger is authoritative under `reboot/production/`. Imported production-base assets have explicit source, pinned revision, license, and integrity records. Generic CC0 assets remain source material rather than final identity, and the designated hero assets remain subject to the custom/substantially transformed presentation rule.

## Project Lead decision this cycle
No new product-code or cosmetic patch is justified solely from repository/CI evidence. The latest code-bearing change is green across parser/import, mechanics, Web, Android, Windows, and preview publication. The remaining strongest gaps are now evidence-dependent: first-hour feel/readability, physical Android install/update/touch/performance/thermal behavior, desktop runtime performance, and uninterrupted human save/reload playthrough quality.

Resume implementation immediately if measured validation exposes a concrete reproducible defect. Otherwise avoid speculative tuning or cosmetic churn that cannot be justified without the missing evidence.

## Strongest remaining player-facing priorities
1. Complete uninterrupted human validation of the authored Tethys/Kestra first hour, including tutorial comprehension, flight/landing feel, scanner judgment, archaeology legibility, Talari/wildlife readability, audio identity, contextual UI, and save/reload continuity.
2. Validate the native Android build on physical hardware: clean install, update-over-install, launch/relaunch, touch safe areas, sustained performance, and thermals.
3. Capture a native desktop reference performance run.
4. Keep Web, Android, and Windows export health green while validation proceeds.
5. Only resume code changes when evidence identifies a concrete regression or missing production requirement.

## Scope freeze
Do not add new planets, civilizations, major upgrade trees, HUD subsystems, broad survival systems, large-scale city generation, or other breadth expansion merely to create work. The Tethys/Kestra first hour is the product quality benchmark.

## Evidence rule
Do not claim visual, performance, device, thermal, touch-usability, accessibility-in-practice, or human-playtest gates without measurable evidence from the relevant environment. CI/export success is not a substitute for those gates.
