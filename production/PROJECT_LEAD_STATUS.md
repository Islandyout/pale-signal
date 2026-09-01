# Project Lead Status

Status date: 2026-09-01

The canonical production target is the clean Godot reboot on branch `reboot-godot`, rooted at `reboot/`. The legacy browser prototype is preserved only as historical/reference material and must not be used as the production architecture or implementation target.

## Current phase
Tethys / Kestra production reboot — first-hour vertical slice implementation and hardening.

The reboot currently provides an exportable Godot 4.7.2 project with isolated gameplay systems, mechanic contracts, save recovery coverage, a Web export, and a native Android export pipeline. The immediate objective remains one exceptional Tethys/Kestra first hour before any breadth expansion.

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
Current `reboot-godot` head: `4669a3d910396ee869fd25c740d4acf906f837ab` (`Fix save recovery test JSON normalization`).

Reboot Godot CI run #71 completed successfully on that head after the standalone save-recovery regression was corrected. The pipeline currently gates parser/import checks, mechanic/regression checks, Web export, Android export, and artifact publication. Successful CI proves build/export health only; it does not prove visual quality, device performance, touch usability, or human-playtest quality.

## Asset / license position
The reboot asset ledger is authoritative under `reboot/production/`. Imported production-base assets have explicit source, pinned revision, license, and integrity records. Generic CC0 assets remain source material rather than final identity, and the designated hero assets remain scheduled for custom/substantially transformed treatment.

## Strongest remaining player-facing priorities
1. Deepen the authored Tethys/Kestra first-hour experience rather than expand to another world.
2. Continue improving flight feel, scanning skill, archaeology/reconstruction depth, Talari behavior, wildlife ecology, contextual UI, and audio only where those changes strengthen the existing first hour.
3. Add or strengthen mechanic regression contracts before broadening any critical system.
4. Keep Web, Android, and desktop exports healthy as gameplay changes land.
5. When implementation reaches a state where only physical-device or human validation remains, stop cosmetic churn and record exact validation requirements instead.

## Scope freeze
Do not add new planets, civilizations, major upgrade trees, HUD subsystems, broad survival systems, large-scale city generation, or other breadth expansion merely to create work. The Tethys/Kestra first hour is the product quality benchmark.

## Evidence rule
Do not claim visual, performance, device, thermal, touch-usability, or human-playtest gates without measurable evidence from the relevant environment. CI/export success is not a substitute for those gates.
