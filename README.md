# Pale Signal

Pale Signal is a planetary exploration, archaeology, first-contact and spaceflight game project.

This repository is the canonical source of truth for the game's production work, virtual AAA studio roles, design decisions, quality gates, zero-cost toolchain, prototype baseline, and Vertical Slice 2.0 development.

## Current production focus

**Vertical Slice 2.0: Tethys / Kestra**

The project is currently feature-frozen outside the vertical slice. The goal is not to add more systems. The goal is to make ten uninterrupted minutes of Pale Signal look, sound, control and feel competitive with a strong 2026 game while preserving its core identity:

- manual seamless surface-to-space flight
- planetary exploration
- xenoarchaeology and historical reconstruction
- first contact and deep civilizations
- the Pale Signal mystery
- no travel cutscenes or teleporting between worlds

## Studio structure

See [`studio/START_HERE.md`](studio/START_HERE.md).

The virtual studio uses one Project Lead and eight specialist departments:

1. Core Gameplay
2. Technical / Engine
3. Art / Technical Art
4. Character / Animation
5. World / Narrative
6. UX / UI / Mobile
7. Audio
8. QA / Production

All major work is reviewed by the Project Lead before it becomes canonical.

## Cost rule

The project is designed around a **$0 production-tool budget** other than ChatGPT and Claude subscriptions the owner already chooses to pay for. Paid assets, paid plugins, paid middleware, paid hosting dependencies, and free trials that later require payment are not approved dependencies.

See [`production/FREE_TOOLCHAIN.md`](production/FREE_TOOLCHAIN.md) and [`production/LICENSE_LEDGER.csv`](production/LICENSE_LEDGER.csv).

## Important rule

The current browser/Three.js build is a **prototype and systems reference**, not automatically the final production engine. Any migration must preserve proven gameplay and be approved through the Technical Director and Project Lead.
