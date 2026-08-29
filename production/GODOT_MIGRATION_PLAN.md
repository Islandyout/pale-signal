# Pale Signal Production Engine Decision

## Decision
Godot 4.x is the production engine recommendation for Pale Signal after the browser vertical slice is accepted.

The current Three.js single-file prototype remains the playable specification and regression reference until the Tethys/Kestra Vertical Slice 2.0 quality gates are verified. Migration must not interrupt the existing playable build.

## Why Godot
- Free and open source with no paid runtime, seat, or marketplace dependency.
- Strong desktop and Android export paths.
- Appropriate scene, animation, audio, physics, input, profiling, and asset-import pipelines for the quality gaps that are now difficult to solve cleanly in layered browser patches.
- GDScript/C# support without requiring a paid service.
- Better long-term fit for authored character animation, dense settlements, interiors, wildlife state machines, environmental audio, and continuous ground-to-space flight.

## Non-negotiable gameplay preserved during migration
1. No cutscene or scene-swap replacement for normal planetary launch/flight/landing.
2. Player manually lifts off, crosses atmosphere, flies through system space, approaches, and lands.
3. Camera look does not steer the ship.
4. Atmospheric VTOL lift does not require a forced 90-degree pitch.
5. Keyboard/mouse and touch handedness remain internally consistent.
6. Navigation stays GPS-like and contextual rather than becoming an autopilot-only marker system.
7. Save/progression semantics and physical resource collection remain compatible with the prototype design.
8. Mobile clarity is reduced only after optional simulation/presentation cost is cut.

## Migration sequence
### Phase 0 — Freeze contract
Use the browser build as the behavioral reference. Record first-hour progression, controls, interaction priorities, landing envelope, save state, performance reports, and visual references.

### Phase 1 — Core shell
Create Godot project, input map, save schema, world/scene coordinate conventions, deterministic settings, Android export preset, and CI export job. Do not add content.

### Phase 2 — Flight and EVA parity
Port manual/stabilized/NAV ownership, ship forces, camera separation, landing radar/contact logic, EVA grounding/slopes/collision, and interaction reach. Acceptance is behavioral parity with the browser reference before art expansion.

### Phase 3 — Tethys data/content
Port Tethys terrain/material rules, scanner/resource data, wildlife data, Kestra site coordinates, civic records, archaeology evidence, weather event, and first-hour progression as data-driven resources.

### Phase 4 — Presentation pipeline
Replace procedural stand-ins with authored meshes/rigs/animations, AudioStream buses, environment effects, particles, materials, LODs, and animation state machines. This is where the largest current art/animation ceiling is addressed.

### Phase 5 — Mobile tier validation
Profile low/mid/high Android targets, set device-tier budgets, validate touch layout and thermal/frame pacing, and preserve a readable minimum render scale.

### Phase 6 — Slice sign-off
Run Gate A–G acceptance. Only after the Tethys/Kestra slice passes may content expansion resume for the remaining worlds.

## Zero-cost toolchain
- Godot 4.x — engine/export
- Blender — modeling/rigging/animation
- Krita — texture/concept work
- Material Maker — procedural materials
- Audacity — audio editing
- GitHub Free — source control and CI
- Poly Haven / Kenney only when individual asset licenses are recorded in `LICENSE_LEDGER.csv`

## Migration rule
Do not rewrite functioning systems merely to be more elegant. Port the observable player-facing contract first. Replace complexity only when it improves feel, reliability, authoring speed, performance, or maintainability.