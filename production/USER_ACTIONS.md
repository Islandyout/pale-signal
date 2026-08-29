# User Actions Required

Only tasks that genuinely require a physical human/device are listed here.

## 1. Android device-tier performance captures
**Task** → Run the built-in 60-second Kestra QA capture on representative Android hardware, ideally one low-tier, one mid-tier and one high-tier device.

**Why AI cannot do it** → CI and browser sandboxes cannot reproduce the actual phone GPU, thermal throttling, touch latency, browser/WebView scheduling or sustained frame pacing of the user's physical devices.

**Why needed** → Gate D requires measured mobile evidence and explicitly forbids claiming universal locked 60 FPS without hardware data.

**Free tool/resource** → Current Pale Signal PWA or current GitHub Actions APK; built-in `PALE_QA_PROFILER`, `PALE_QA_EVIDENCE` and mobile self-audit.

**Exact instructions** →
1. Open the current Pale Signal build on the phone.
2. Reach Tethys/Kestra and remain in a representative busy area with residents, wildlife and settlement geometry visible.
3. On touch, press and hold the extreme top-left corner for about 1.8 seconds to start the 60-second QA capture.
4. During the capture, walk, look around, interact with at least one Kestra object and rotate the camera through the dense settlement view.
5. Let the capture finish without backgrounding the app.
6. Copy the displayed report using `COPY REPORT`.
7. Record phone model and whether the build was PWA or APK.
8. Repeat on each available device tier.

**Expected output** → Copied text report(s) containing duration, estimated FPS, average/P95/P99 frame time, worst frame, long-frame counts, renderer calls/triangles/textures/programs, viewport and DPR.

**Acceptance criteria** →
- Preferred tier: roughly 50+ FPS with P95 ≤ 24 ms and no sustained stalls.
- Lower-device tier may pass at roughly 40+ FPS with P95 ≤ 30 ms if optional effects are reduced before image clarity.
- Report duration must be approximately 60 seconds and marked valid.

**Effort** → Moderate.

## 2. Current APK install/update/launch validation
**Task** → Install the latest successful Android artifact over a previous Pale Signal install if available, then launch and enter gameplay.

**Why AI cannot do it** → Physical Android package installation, OS permission behavior and update-over-existing-app behavior require a real Android device.

**Why needed** → Confirms the CI artifact is not only buildable but actually installable and launchable on-device.

**Free tool/resource** → GitHub Actions `Build Android APK` artifact.

**Exact instructions** →
1. Open the `Islandyout/pale-signal` repository on GitHub.
2. Open **Actions** → **Build Android APK**.
3. Choose the newest successful run from `main`.
4. Download its APK artifact and extract it if GitHub provides a ZIP.
5. If an older Pale Signal APK is installed, try installing the new APK over it first.
6. Launch Pale Signal.
7. Confirm the starting screen loads, controls respond and the game enters the playable Tethys flow.
8. If Android refuses an update-over-install, record the exact message before trying a clean install.

**Expected output** → A short note: device model, Android version, update install PASS/FAIL, clean install PASS/FAIL if attempted, launch PASS/FAIL, and exact error text if any.

**Acceptance criteria** → Current APK installs and launches without a package/signature/runtime failure; if update-over-install is intended, it also succeeds.

**Effort** → Quick.

## 3. First-hour human friction + save/reload pass
**Task** → Play the opening sequence without developer shortcuts and record friction that is not necessarily a software bug.

**Why AI cannot do it** → The remaining gate depends on human comprehension, impatience, perceived control quality, pacing, readability and whether instructions are understandable without prior project knowledge.

**Why needed** → Gates A/E require a new player to complete the opening loop without external explanation and require common mistakes to have recoverable paths.

**Free tool/resource** → Current PWA or APK; built-in control reference, pacing recovery, first-hour gate and QA profiler.

**Exact instructions** →
1. Start a fresh game.
2. Do not use project notes or developer explanations.
3. Play normally through atmosphere verification, first scan, physical sample, Talari/Kestra discovery, civic/archaeology interaction, return to ship, manual launch, Kestra overflight and landing.
4. At least once during the run, save/checkpoint after archaeology or a physical interaction, reload, and confirm the completed interaction does not grant the reward again.
5. Start a new game afterward and confirm old live-layer archaeology/civic/verb completion does not carry into the fresh start.
6. Write down every moment where the next action was unclear for more than about 20 seconds, every control that felt backwards/ambiguous, every accidental interaction, every unreadable mobile element, and every section that felt empty or repetitive.
7. If possible, run the built-in 60-second QA capture during one dense Kestra segment.

**Expected output** → Short friction notes plus PASS/FAIL for save/reload reward duplication, fresh-game reset, continuous manual launch/flight/landing, and control consistency.

**Acceptance criteria** → The player can complete the opening loop without external instructions; no duplicate progression reward appears after reload; fresh game starts clean; no inverted/ambiguous primary control remains; no unrecoverable interaction dead-end occurs.

**Effort** → Substantial.

## 4. Desktop reference performance capture
**Task** → Capture one representative 60-second desktop Kestra performance report.

**Why AI cannot do it** → Gate D needs a designated real reference machine rather than a container/browser approximation.

**Why needed** → Establishes the desktop reference baseline against the 60 FPS target.

**Free tool/resource** → Current browser build and built-in QA profiler.

**Exact instructions** →
1. On desktop, open the current Pale Signal build and reach a dense Kestra scene.
2. Press `Ctrl+F9` or `Cmd+F9` to start the dedicated 60-second QA capture. Plain `F9` remains the visual-quality control and should not be used for this capture.
3. Walk/turn/interact during the capture.
4. Let it complete and copy the report.
5. Record CPU, GPU, RAM, operating system, browser and viewport resolution.

**Expected output** → One valid 60-second desktop report plus machine/browser specification.

**Acceptance criteria** → Meets the agreed desktop reference target near 60 FPS without sustained long-frame spikes; if not, the report identifies the measured gap for a concrete optimization pass.

**Effort** → Quick.
