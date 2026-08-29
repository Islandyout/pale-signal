# Pale Signal — Vertical Slice 2.0 Release Readiness

Status date: 2026-08-29
Scope: Tethys + Kestra Vertical Slice 2.0 browser/PWA/Android prototype.

## Evidence rule
Percentages below measure implementation/readiness, not marketing quality. Hardware-dependent claims remain unapproved until measured on real devices.

## Current readiness
| Area | Readiness | Evidence / remaining gate |
|---|---:|---|
| Core gameplay systems | 94% | Continuous flight, EVA, scanning, gathering, interaction arbitration, saves and progression implemented; remaining work is runtime edge-case evidence. |
| Ship flight/handling | 92% | Manual continuous flight and ownership states implemented; real-player/device feel tuning remains. |
| Landing | 94% | Approach/final/flare, warnings and contact feedback implemented; final physical feel validation remains. |
| EVA | 92% | Ground movement, slope/collision coordination, embodied cadence, accessibility and interaction reach implemented; authored rig animation belongs to production migration. |
| Tethys wilderness | 93% | Authored micro-sites, gathering, wildlife, weather, scanner confidence and environmental teaching implemented. |
| Kestra settlement | 92% | Dense settlement dressing, residents, routines, civic interactions, language wall, repair vestibule, archaeology and street activity implemented. |
| Talari behavior/presence | 91% | Schedules, proximity response, conversation, social idles, procedural animation and visual variation implemented. Authored character rigs remain production-art work. |
| Wildlife | 91% | Real scanner-target anchoring, motion, retreat/alert response and performance culling implemented. |
| Archaeology | 96% | Multi-source evidence, reconstruction sequence, reward presentation and persistence implemented. |
| Physical interactions | 94% | Turn/connect/sample/align/tune verbs, animation feedback and priority arbitration implemented. |
| First-hour onboarding/pacing | 93% | Contextual progression, discovery cards, pacing recovery, first-hour runtime gate and tutorial/reference support implemented. Full uninterrupted human playthrough remains evidence work. |
| Pale Signal presentation | 91% | Environmental coherence effects, audiovisual escalation and performance throttling implemented. |
| Audio implementation | 91% | Distinct procedural states for EVA, atmosphere, cockpit/vacuum, Kestra, wildlife and Pale Signal implemented. Authored asset fidelity remains production-art work. |
| UI/HUD/accessibility | 93% | Contextual HUD, mobile compact mode, control reference, recovery prompts and reduced-motion handling implemented. |
| Mobile usability architecture | 92% | Touch layout, readability safeguards, mobile self-audit and performance governor implemented. |
| Mobile performance architecture | 93% | Rolling profiler, P95/P99 evidence, QA capture and adaptive optional-effect governor implemented. Hardware results remain unapproved. |
| Save/load robustness | 93% | Live-layer archaeology/civic/verb state persistence, checkpoint hooks, unload persistence and fresh-game reset guard implemented. Human reload/new-game torture pass remains. |
| PWA / Pages | 98% | Versioned service worker, cache parity CI and successful Pages deployment. |
| Android build pipeline | 98% | Synchronized live scripts/assets and successful APK workflow. Physical install/update test remains. |
| Automated regression CI | 97% | Syntax, live/cache wiring, profiler shortcut, license ledger and shell checks implemented. |
| Zero-cost/licensing | 98% | Free toolchain and license ledger enforced by CI. |
| Browser-prototype visual coherence | 90% | Material/silhouette/presentation passes applied within procedural prototype constraints. Higher authored fidelity is intentionally assigned to Godot/Blender production migration rather than more layered patches. |
| Browser-prototype animation implementation | 90% | Procedural locomotion/body-language/wildlife/interaction animation implemented. Skeletal authored animation is a production-engine task. |

## Hardware-dependent gate — not approved yet
Real-device QA evidence cannot be truthfully marked complete without physical measurements.

Required evidence:
1. Low-tier Android: 60-second Kestra capture and first-hour stress sample.
2. Mid-tier Android: same.
3. High-tier Android: same.
4. At least one desktop reference capture.
5. Install/update launch test of current APK.
6. Full first-hour human playthrough with save/reload/new-game checks.

The build already contains the profiler, evidence recorder, mobile self-audit and runtime first-hour gate needed to collect these results.

## Scope boundary
The percentages above are for Vertical Slice 2.0 and its supporting delivery systems. They do not mean the entire multi-world Pale Signal game is 90% complete. New worlds, civilizations, fragment-site expansion and major systems remain frozen until this slice is physically validated.

## Project Lead release position
Code-side Vertical Slice implementation is at or above the 90% readiness threshold across the previously weak areas. The remaining blockers are primarily physical-device/human evidence and the later production-engine authored-art pass, not missing browser prototype systems.