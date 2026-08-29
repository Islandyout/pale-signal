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

The dedicated Kestra Gate D profiler is exposed as `globalThis.PALE_QA_PROFILER`. A valid production capture runs for at least 55 seconds, records at least 900 foreground frame samples and at least 90 renderer samples, and reports frame-time percentiles plus renderer calls/triangles/geometries/textures/programs.

`live/qa-evidence-v20.js` makes those captures practical on the actual target device instead of requiring a remote JavaScript console. Completed reports are retained in local storage (latest six captures) and shown in a copyable QA-only evidence panel.

### Desktop profiler shortcut isolation
The shipped game already uses plain **F9** to cycle visual quality. Gate D capture therefore uses **Ctrl+F9** on Windows/Linux and **Cmd+F9** on macOS. The QA evidence listener intercepts only that modified shortcut before the gameplay F9 handler, so starting or stopping a capture cannot also change the measured quality tier. Plain F9 remains the normal visual-quality control.

### USER ACTION REQUIRED — Gate D capture
Desktop:
1. Open the deployed Pale Signal build and reach Kestra.
2. Select and note the intended visual quality tier before measurement.
3. Press **Ctrl+F9** (Windows/Linux) or **Cmd+F9** (macOS) to start a 60-second capture. Do not press plain F9 during the run.
4. Traverse the ground/street area normally and include a landing-field/approach view if practical.
5. When the result panel appears, confirm it says `VALID 60s CAPTURE` and use **COPY REPORT**.
6. Preserve the copied report with the reference-machine model/specification and quality setting.

Target Android phone:
1. Open the installed current Android build and reach Kestra.
2. Press and hold the **top-left corner of the game view for 1.8 seconds** without moving the finger more than roughly 22 px. The game confirms that the 60-second capture started.
3. Traverse Kestra normally for the full capture while keeping the app foregrounded.
4. When the evidence panel appears, confirm it says `VALID 60s CAPTURE` and tap **COPY REPORT**.
5. Preserve the copied report together with phone model, Android version, thermal state, battery/charging state, and selected quality tier.

Do not infer a performance pass from CI, Pages deployment, Android compilation, or an invalid/incomplete capture.

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
- plain F9 still cycles visual quality; Ctrl/Cmd+F9 starts/stops the dedicated Gate D capture without changing quality
- PWA and Android package the same live scripts

## Gate status
Instrumentation: IMPLEMENTED
Static syntax QA: PASSED for the instrumented live layers through CI when the corresponding commit is green
GitHub Pages deployment: must be verified for the current commit
Android APK workflow: must be verified when runtime/package files change
Real-device performance evidence: PENDING
Project Lead performance gate: NOT YET APPROVED