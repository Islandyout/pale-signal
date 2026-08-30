# Master Backlog

## Milestone: Vertical Slice 2.0 — Tethys / Kestra

Status reflects the current browser/PWA/Android vertical-slice implementation. Checked items mean the implementation target exists in the build or production contract. Hardware/human validation remains separate and is not implied by a checked box.

### P0 — Must be solved before content expansion
- [x] Define final production engine recommendation with migration plan from browser prototype. See `GODOT_MIGRATION_PLAN.md`.
- [x] Establish measurable 60 FPS desktop target and realistic mobile target/device tiers. Profiler/evidence capture and tier thresholds exist; physical measurements are still required.
- [x] Rebuild ship handling around feel-first manual/stabilized/NAV states.
- [x] Rebuild EVA controller with robust grounding, slopes, collision, animation hooks, and interaction reach.
- [x] Create contextual HUD information architecture.
- [x] Design physical resource gathering loop for one Tethys fuel resource.
- [x] Build first-hour onboarding that teaches by interaction rather than text walls.
- [x] Replace the reference-only Survey Academy with playable lessons completed through real gameplay mechanics.
- [x] Establish audio pipeline and first-pass Tethys/ship soundscape.
- [x] Establish animation pipeline and EVA locomotion set for the prototype; authored skeletal animation is assigned to production migration.
- [x] Define Tethys/Kestra visual bible with authored silhouette/material/lighting targets. See `TETHYS_KESTRA_VISUAL_BIBLE.md`.
- [x] Build one dense Kestra district rather than broadening to more settlements.
- [x] Implement one complete archaeology reconstruction sequence.
- [ ] Independent human QA pass for frustration that is not technically a bug. Automated instrumentation/recovery systems exist, but this gate requires an uninterrupted human playthrough.

### P1 — Vertical slice polish
- [x] Weather event on Tethys with gameplay consequences.
- [x] Wildlife behavior with readable reactions to player and ship.
- [x] Ship landing feedback: suspension/settle, warnings, audio and contact response.
- [x] Contextual scanner interactions beyond hold-to-complete.
- [x] Settlement life: schedules, ambient conversations, visible jobs, vestibule/interior presentation.
- [x] One Talari language-learning interaction with partial translation.
- [x] One historical contradiction resolved through multiple evidence sources.
- [x] Authored Kestra collision proxies implemented for solid hero geometry.
- [x] Authored Kestra terrain-conformance pass implemented.
- [ ] Fix first-hour director sample beat so pre-existing inventory cannot count as a newly collected Tethys sample.
- [ ] Mobile-specific HUD and touch layout validated on low/mid/high physical device tiers. Self-audit and profiler are implemented; hardware evidence is still required.

### Code-side finalization
- [x] Live-script syntax regression CI.
- [x] PWA script/cache parity regression CI.
- [x] License ledger enforcement.
- [x] Save-state persistence for live archaeology/civic/physical-verb state.
- [x] Fresh-game live-state reset guard.
- [x] First-hour runtime quality-gate validator.
- [x] Mobile performance governor that cuts optional simulation/presentation before render clarity.
- [x] Mobile touch-target/usability self-audit.
- [x] Contextual recovery/control reference.
- [x] Pacing dead-air recovery.
- [x] Pages delivery pipeline passing.
- [x] Android APK build pipeline passing.

### Remaining validation blockers
1. Low/mid/high Android physical profiling captures.
2. Desktop reference profiling capture.
3. Current APK physical install/update/launch test.
4. Full first-hour human playthrough including save/reload/new-game and frustration notes.
5. Physical Kestra traversal/approach check confirming authored collision and terrain conformance behave visually as intended.

### Frozen until slice validation passes
- New planets
- New civilizations
- New major upgrade trees
- New survival meters
- New navigation subsystems
- Large-scale city generation
- Additional fragment sites beyond what the slice requires
