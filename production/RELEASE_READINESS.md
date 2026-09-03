# Pale Signal — Godot Reboot Release Readiness

Status date: 2026-09-03
Scope: canonical Godot 4.7.2 production reboot on `reboot-godot`, focused exclusively on the Tethys / Kestra first hour.

The legacy browser prototype is preserved on `legacy-prototype` and is not a production target. Legacy browser/PWA readiness percentages, live-layer quality claims, and WebView Android evidence must not be used to approve the Godot reboot.

## Evidence rule
Automated tests and successful exports prove parser/import/build health only. They do not prove visual quality, player feel, touch usability, hardware performance, thermals, accessibility in practice, or uninterrupted human-play quality. Those gates remain open until measured in the relevant environment.

## Current code/build position
- Godot 4.7.2 stable remains the pinned production engine.
- `reboot-godot` is the canonical implementation branch.
- Continuous manual flight is implemented as the traversal foundation.
- Camera look remains independent from ship steering.
- VTOL lift remains independent from nose pitch.
- EVA, flight, interaction, scanner, archaeology, wildlife, NPC, tutorial, save, Pale Signal, audio, mobile controls, and presentation responsibilities are isolated rather than collapsed into one controller.
- Tutorial progression depends on real mechanics rather than scripted substitution.
- Scanner gameplay includes distance and sweep-stability judgment instead of passive hold-to-complete scanning.
- Hero archaeology uses multi-pass evidence correlation and requires prior scanning before reconstruction can complete.
- Save corruption recovery has dedicated regression coverage.
- Purpose-built mobile controls map onto the same mechanics as desktop.
- Web, native Android, and Windows x86_64 exports are part of the reboot CI pipeline.
- Imported production-base assets are governed by explicit provenance/license records and CI import policy.
- First-hour HUD scope is guarded so unfinished multi-world fragment progression is not presented as current slice completion.

## Current automated evidence
Current checked reboot head before this documentation correction: `179de892b8d6e962f8b97143832a9aa3ac64d06d` (`Guard first-hour HUD scope in regression tests`).

Reboot Godot CI run #181 completed successfully on that head. The pipeline covers parser/import validation, mechanic/regression contracts, and export/artifact generation. This document update does not promote any human, visual, touch, performance, or hardware gate.

## Production readiness by gate
| Gate | Status | Evidence / remaining requirement |
|---|---|---|
| Engine / architecture | IMPLEMENTED | Godot 4.7.2 project, isolated systems, CI and export architecture exist. Continue regression coverage as critical mechanics change. |
| Continuous flight controls | IMPLEMENTED; feel validation pending | Manual flight, independent look/steering and independent VTOL lift are contractual requirements. Final tuning requires measured play evidence. |
| Tutorial / onboarding mechanics | IMPLEMENTED; human validation pending | Tutorial uses real mechanics. Needs uninterrupted first-hour comprehension/friction evidence. |
| Scanner skill | IMPLEMENTED; human validation pending | Distance-window and sweep-stability lock requirements exist. Needs player-readability and frustration evidence. |
| Archaeology / reconstruction | IMPLEMENTED; human validation pending | Multi-pass evidence alignment and conflicting-history presentation exist. Needs human legibility/engagement evidence. |
| Tethys / Kestra authored first hour | IN PROGRESS | This remains the strongest production target. Do not expand to another world until the slice is exceptional and validated. |
| Talari / wildlife / ecology | IN PROGRESS | Authored behavior and reactive ecology exist but presentation and human-readability quality remain first-hour work. |
| Audio identity | IN PROGRESS | State-aware audio implementation exists; authored identity and final mix quality remain first-hour work. |
| Hero art identity | IN PROGRESS | Generic zero-cost assets are source material only. Hero ship, Talari, Flat Grazer, Pale Signal artifacts and hero archaeology still require custom or substantially transformed presentation before final art approval. |
| Contextual UI / accessibility | IMPLEMENTED; physical/human validation pending | Contextual HUD and mobile control architecture exist. Touch/readability/accessibility approval requires real use evidence. |
| Save/load continuity | IMPLEMENTED; human validation pending | Persistence and corruption recovery coverage exist. Full first-hour save/reload/new-game continuity still requires uninterrupted human testing. |
| Web export | BUILD GATE ACTIVE | Successful CI export proves Web build health only. Browser runtime quality remains separate. |
| Android export | BUILD GATE ACTIVE | Native Godot APK export exists. Physical install/update/launch, sustained performance, thermals and touch behavior remain unapproved. |
| Windows export | BUILD GATE ACTIVE | Native Windows x86_64 artifact generation exists. Runtime/player-feel quality still requires real execution evidence. |
| Zero-cost / licensing | ACTIVE / ENFORCED | Asset provenance and license ledger remain mandatory. No paid dependency is approved. |
| Scope control | PASS | No new planets, civilizations, major upgrade trees, HUD subsystems, broad survival systems or unrelated breadth until the first hour is proven. |

## Highest-priority unfinished production work
1. Finish one exceptional authored Tethys/Kestra first hour rather than increase world breadth.
2. Strengthen the weakest player-facing quality inside that hour: flight feel, scanner judgment/readability, archaeology legibility, Talari presence, wildlife ecology, contextual UI, audio identity, and hero presentation.
3. Add or strengthen regression contracts whenever a critical mechanic gap is fixed.
4. Keep Web, Android and Windows exports healthy as gameplay/content changes land.
5. Stop cosmetic churn when only physical-device or human validation remains; record exact evidence requirements instead.

## Physical / human evidence still required
1. Install the current native Godot APK on a real Android device, launch it, update over an existing installation, relaunch, and verify expected save/progression continuity.
2. Capture sustained Android performance and thermal behavior on representative hardware while playing the authored Tethys/Kestra slice; record device, OS, quality settings, charging/thermal state, frame-time/FPS data and observed hitches.
3. Run a desktop reference performance capture against a native build.
4. Complete an uninterrupted first-hour human playthrough covering tutorial, launch, continuous flight, landing, EVA, scanning, gathering, archaeology, Kestra interaction, Pale Signal escalation, save, reload and continued play.
5. Validate touch controls, readability, contextual UI, accessibility behavior, scanner judgment, landing feel and archaeology comprehension with real players/devices.

## Scope boundary
This readiness record applies only to the Tethys/Kestra first-hour production slice and its delivery infrastructure. It does not mean the full multi-world Pale Signal game is near completion. Additional worlds, civilizations and broad systems remain frozen until this slice passes its implementation and validation gates.

## Project Lead release position
The reboot has a healthy production foundation and multi-platform export pipeline, but the product is not release-approved. The strongest unfinished task remains first-hour authored quality, followed by physical-device and uninterrupted human validation. No legacy browser-prototype readiness claim may be used as substitute evidence.