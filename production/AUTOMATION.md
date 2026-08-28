# Pale Signal Automated Studio Runner

## Purpose
This repository is the canonical source of truth for the Pale Signal virtual AAA studio. Scheduled ChatGPT automations drive recurring production cycles while GitHub stores issues, decisions, handoffs, evidence, and USER ACTION REQUIRED items.

## Automation model

### Daily Studio Cycle
A scheduled ChatGPT task runs once per day and works through the specialist departments in sequence:
1. Core Gameplay
2. Technical / Engine / Performance
3. Art / Technical Art
4. Character / Creature / Animation
5. World / Narrative / Civilization
6. UX / UI / Mobile
7. Audio
8. QA / Production

The cycle reads the current repository state and open issues before doing work. Each specialist may browse current web sources when research improves quality. Current official and primary sources are preferred.

At the end of the daily cycle, the Project Lead reviews specialist output and records one of:
- ACCEPT
- REQUEST CHANGES
- CUT
- DEFER

No specialist may approve its own work.

### Weekly Project Lead Review
A separate scheduled review runs weekly. It audits:
- commits and issue changes;
- specialist handoffs;
- research sources;
- QA evidence;
- USER ACTION REQUIRED items;
- scope creep and over-engineering;
- performance claims;
- licensing and zero-budget compliance.

The Lead then defines the next approved priorities.

## Zero-budget rule
No production dependency may require payment beyond the user's existing ChatGPT and Claude subscriptions. Do not introduce paid APIs, paid AI inference, subscription SaaS, marketplace packs, premium plugins, paid hosting, or commercial asset libraries.

Free tools/assets still require license verification and must be recorded in the repository license ledger.

## Important limitation: Claude
The automated ChatGPT runner cannot spend or invoke the user's Claude subscription automatically. Claude is a separate product/account and subscription access is not an API credential. If Claude review is desired, add a USER ACTION REQUIRED item with an exact prompt and file/issue to review. The user can paste the resulting Claude review back into GitHub or ChatGPT.

Do not add a Claude API dependency because that would violate the project's no-extra-cost rule.

## User notifications
Normal internal progress should stay in GitHub. Notify the user only when:
- physical/device/manual work is required;
- a meaningful blocker exists;
- a major design decision requires owner approval;
- a milestone or quality gate is reached;
- the weekly executive review is ready.

## USER ACTION REQUIRED format
Every task the AI cannot complete but that materially benefits the project must specify:
1. Task
2. Why AI cannot complete it
3. Why it matters
4. Free tool/resource to use
5. Exact steps
6. Expected output/file
7. Acceptance criteria
8. Estimated effort category: quick / moderate / substantial

## Scope rule
Until the Project Lead explicitly changes the milestone, the studio remains focused on Vertical Slice 2.0: Tethys + Kestra. Additional planets, settlements, large systems, or feature trees are deferred unless they are required to prove the vertical slice.

## Owner responsibilities
The project owner should:
- keep the GitHub connection authorized for `Islandyout/pale-signal`;
- review USER ACTION REQUIRED items when notified;
- perform real-device playtests and physical/reference work when requested;
- avoid purchasing tools/assets without first updating the zero-budget policy;
- make final creative decisions when the Project Lead flags an owner-level choice.
