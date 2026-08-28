# Start Here — How to Run the Virtual Studio

1. Create one ChatGPT or Claude Project/chat called `Pale Signal — Project Lead` and paste `agents/00_PROJECT_LEAD.md` into its project instructions.
2. Create specialist Projects/chats for Agents 01–08 and paste each role prompt into the respective instructions.
3. Give every Project the same current `PROJECT_BRIEF.md`, baseline files and decision log.
4. The Project Lead writes one sprint brief and delegates only the parts relevant to each specialist.
5. Specialists browse the internet, research, produce their work, and return the standard AGENT_HANDOFF.
6. The Project Lead reviews all handoffs, rejects conflicting/weak/paid solutions, and issues a consolidated approved plan.
7. Only approved work is merged into the production baseline.
8. QA reviews the integrated result, including non-code friction and human mistakes.
9. Project Lead performs final milestone sign-off.

## Important practical limitation
ChatGPT/Claude chats do not automatically share state with one another unless you provide the shared files/context. Treat the repository and shared studio docs as the source of truth, not any agent's memory.

## First sprint recommendation
**Vertical Slice 2.0 — Tethys / Kestra**
- Gameplay: reduce flight/EVA interactions to the clearest premium-feeling core.
- Tech: create production-engine migration/profiling plan.
- Art: define Tethys/Kestra visual bible and hero-scene asset list.
- Animation: create locomotion + interaction animation target list.
- World: create first-hour beat map and density pass.
- UX: design contextual HUD and mobile-specific presentation.
- Audio: create ship/EVA/Tethys sonic bible and event list.
- QA: define acceptance criteria and benchmark test matrix.
- Lead: review all outputs, cut scope, approve one buildable milestone.
