# Master Backlog

## Milestone: Godot Production Reboot — Tethys / Kestra First Hour

Status reflects the canonical Godot production work on branch `reboot-godot`. The legacy browser prototype is preserved for reference only and is not the production target. Checked items mean a production implementation or enforceable contract exists; physical-device and human validation remain separate and are never implied by CI success.

### P0 — Must be solved before content expansion
- [x] Establish Godot 4.7.2 stable production project and CI.
- [x] Preserve continuous manual flight as the core traversal model.
- [x] Keep camera look independent from ship steering.
- [x] Keep VTOL lift independent from nose pitch.
- [x] Isolate EVA, flight, interaction, scanner, archaeology, tutorial, save and supporting production systems.
- [x] Make tutorial completion depend on real mechanics rather than scripted substitution.
- [x] Establish purpose-built mobile controls mapped to the same mechanics.
- [x] Establish explicit save/persistence handling and corruption-recovery regression coverage.
- [x] Establish Web export pipeline.
- [x] Establish native Android export pipeline.
- [x] Establish asset provenance/license ledgers and pinned zero-cost source policy.
- [ ] Complete an exceptional authored Tethys/Kestra first hour before expanding to another world.
- [ ] Independent human QA pass for frustration, readability, onboarding comprehension and mechanic feel.

### P1 — First-hour quality
- [ ] Flight feel: tune manual atmospheric/VTOL/vacuum handling from measurable play evidence without collapsing look and steering into one control.
- [ ] Scanner skill: ensure scanning involves readable player judgment rather than passive hold-to-complete repetition.
- [ ] Archaeology/reconstruction: deepen the hero sequence so evidence assembly and conflicting history are mechanically legible.
- [ ] Talari behavior: strengthen authored routines, reactions and conflicting historical perspective inside the first-hour slice.
- [ ] Wildlife ecology: make Flat Grazer and supporting fauna behavior readable, ecological and reactive without becoming a combat system.
- [ ] Audio: build a strong authored Tethys/Kestra sound identity with state-aware ship, EVA, settlement, wildlife and Signal layers.
- [ ] Art identity: substantially transform or replace temporary CC0 foundations for the hero ship, Talari, Flat Grazer, Pale Signal artifacts and hero archaeology.
- [ ] Contextual UI/accessibility: keep information situational, readable and touch-safe without adding a new HUD subsystem.
- [ ] Save/load first-hour continuity: preserve tutorial, investigation and progression state through reload/new-game boundaries.

### Engineering / regression
- [x] Godot parser/import validation in CI.
- [x] Mechanic contracts for critical controller/tutorial invariants.
- [x] Save corruption recovery regression test.
- [x] Web export artifact generation.
- [x] Android APK export artifact generation.
- [ ] Add regression contracts whenever a critical mechanic gap is fixed, before expanding related scope.
- [ ] Preserve desktop export/support as the slice hardens.

### Asset / licensing
- [x] Production asset ledger exists under `reboot/production/`.
- [x] Imported zero-cost assets have source, revision, license and integrity records.
- [x] CI fetch/import policy rejects untracked production-base binaries.
- [ ] Replace/substantially transform temporary hero-identity source assets before final release presentation approval.

### Validation still requiring real evidence
- [ ] Android physical install/update/launch test.
- [ ] Android sustained performance/thermal/touch capture on representative hardware.
- [ ] Desktop reference performance capture.
- [ ] Uninterrupted first-hour human playthrough including save/reload/new-game behavior.
- [ ] Physical/readable validation of flight, landing, scanner, archaeology, touch controls and contextual UI.

### Frozen until first-hour quality is proven
- New planets
- New civilizations
- Major upgrade trees
- New HUD subsystems
- Broad survival systems
- Large-scale city generation
- Additional world breadth that does not directly improve the Tethys/Kestra first hour

## Decision rule
Work the strongest player-facing Tethys/Kestra gap next. Do not broaden scope merely to stay busy. If only genuine physical-device or human validation remains, stop cosmetic churn, record the exact evidence required, and wait for that evidence.
