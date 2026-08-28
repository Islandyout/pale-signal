# Quality Gates

No specialist can declare a milestone complete. Only the Project Lead can approve a gate after QA evidence is attached.

## Gate A — Player feel
- Ship controls are predictable within the first five minutes.
- EVA movement feels grounded and responsive.
- No input axis inversion or control ownership ambiguity.
- Interactions produce immediate audiovisual feedback.
- A new player can complete the opening loop without external instructions.

## Gate B — Content density
- The Tethys/Kestra slice provides a meaningful observation, interaction, discovery, or decision at a regular cadence.
- The environment contains authored storytelling rather than relying primarily on markers and procedural scatter.
- Kestra feels inhabited through visible routines and environmental evidence of daily life.

## Gate C — Presentation
- Ship, EVA, terrain, settlement, characters, and key props share a coherent art direction.
- Animation quality is sufficient that characters do not read as static procedural objects.
- Audio clearly distinguishes EVA, atmosphere, cockpit, vacuum, settlement, wildlife, and Pale Signal phenomena.
- HUD is contextual and does not obscure the play area.

## Gate D — Performance
- Desktop target: 60 FPS at the agreed reference settings on the designated reference machine.
- Mobile: device-tier targets are explicitly defined and measured. Do not claim universal locked 60 FPS without hardware evidence.
- No sustained frame pacing spikes from HUD, markers, physics, terrain streaming, NPC updates, or weather.
- Profiling evidence identifies the top CPU/GPU costs.

## Gate E — Accessibility and usability
- Keyboard/mouse and touch mappings are internally consistent.
- Critical actions have readable feedback.
- Tutorial information is available contextually and in a reference menu.
- Common human mistakes have recovery paths that do not trivialize gameplay.

## Gate F — Zero-cost compliance
- Every production tool is free for intended use.
- Every external asset has a verified license in `LICENSE_LEDGER.csv`.
- No paid plugin, marketplace dependency, SaaS requirement, or trial-only tool is accepted.

## Gate G — Anti-overengineering
Before accepting any new system, Project Lead must answer:
1. What does the player notice?
2. Can 80% of the benefit be achieved with a simpler solution?
3. What existing complexity can be removed?
4. Does this help Vertical Slice 2.0 now?
5. What is the maintenance/performance cost?

If answers are weak, cut or defer the system.
