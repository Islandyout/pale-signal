# First-Hour QA + Performance Profile

This document defines the evidence required before the Project Lead can approve the Tethys/Kestra first-hour pacing and mobile performance gates.

## Instrumentation
The live build exposes `globalThis.PALE_QA_METRICS` from `live/interaction-qa-v10.js` after approximately 10 seconds of play. Metrics include:
- rolling FPS
- average frame time
- P95 frame time
- P99 frame time
- worst observed frame time
- count of frames above 34 ms
- touch/mobile detection
- current first-hour stage
- stage transition timeline
- physical interaction timeline

On desktop, F8 toggles the lightweight QA overlay. Mobile profiling remains hidden to protect screen space and runs in the background.

## First-hour pacing acceptance
A clean new-game run should progress without external instructions through:
1. Arrival / EVA orientation
2. Atmosphere verification
3. First scan/identification
4. First physical sample
5. Kestra discovery and inhabited-space interaction
6. Archaeology contradiction reconstruction
7. Return to manual flight

Acceptance requirements:
- No stage requires opening the manual to understand the next critical action.
- No critical stage remains stalled for more than 10 minutes due only to unclear direction.
- At least one meaningful observation, interaction, discovery, or decision occurs during each major stage.
- Physical interaction prompts do not block boarding, gathering, NPC interaction, or archaeology interaction.
- Reward/discovery cards never obscure flight-critical controls or remain permanently on screen.

## Mobile performance acceptance
Device-specific evidence is mandatory. Do not claim universal 60 FPS.

### Preferred target
- rolling FPS: >= 50 FPS during normal first-hour exploration
- P95 frame time: <= 24 ms
- P99 frame time: <= 34 ms
- sustained frames above 34 ms: uncommon and not clustered during ordinary walking or Kestra street activity

### Minimum acceptable fallback tier
- rolling FPS: >= 40 FPS
- P95 frame time: <= 30 ms
- P99 frame time: <= 45 ms
- no multi-second sustained stalls
- adaptive systems must reduce optional NPC/VFX/audio flourish before sacrificing protected mobile clarity

## Interaction feedback acceptance
- Each physical verb produces visible motion, audio response, journal/research consequence, and completion feedback.
- Interaction animation must complete without moving the underlying gameplay target or breaking its interaction range.
- Repeated interactions clearly report their completed state.

## Regression checks
- resource scan -> approach -> collect still works
- E still boards ship when boarding is valid
- E still interacts with Talari/civic stations/archaeology when those are nearest and valid
- mobile action button still routes to the same interaction chain
- Reduce Shake still suppresses camera interference
- PWA and Android package the same live scripts

## Gate status
Instrumentation: IMPLEMENTED
Static syntax QA: PASSED for `interaction-qa-v10.js`
GitHub Pages deployment: PASSED
Android APK workflow: PASSED
Real-device performance evidence: PENDING
Project Lead performance gate: NOT YET APPROVED
