# Verify Command — Phase Details

> Read after `/smart-sdd verify [FID]` is invoked. For Common Protocol (Checkpoint, Review), see `pipeline.md`.
> For per-command injection rules, see `reference/injection/verify.md`.
>
> **Adoption mode**: If `sdd-state.md` Origin is `adoption`, read `reference/injection/adopt-verify.md` instead of `reference/injection/verify.md`. Key differences: Phase 1 failures are **non-blocking** (pre-existing issues), Phase 3 is **skipped** (adoption has no per-Feature demos), and Feature status is `adopted` (not `completed`).

---

## Verify Command

Running `/smart-sdd verify [FID]` performs post-implementation verification. This step runs **after implement** to validate that the actual code works correctly and is consistent with the broader project.

### Bug Fix Severity Rule — verify is for FINDING, not REWRITING

When verify discovers a bug, classify its severity before fixing:

| Severity | Examples | Action |
|---|---|---|
| **Minor** | Missing import, typo, null check, off-by-one, missing CSS class, simple config fix | ✅ Fix inline during verify — commit as `fix:` |
| **Major** | Frozen object pattern change, service communication architecture, data flow restructuring, new component/module needed, API contract change | ❌ Do NOT fix inline. **Report and BLOCK** — return to implement (or plan if architectural) |

**How to distinguish**: If the fix touches **3+ files**, changes a **public API/interface**, or requires **architectural reasoning** (not just "add the missing line"), it is Major.

**When Major issue is found**:
1. Record the issue in the verify result report with full details
2. Display: `🔴 Major issue detected — requires re-implementation, not a quick fix`
3. Set verify status to `failure` with the issue description
4. **HARD STOP** — Use AskUserQuestion:
   - "Return to implement with fixes" — return to implement step with the issue context
   - "Reclassify as Minor and fix now" — user overrides severity classification
   **If response is empty → re-ask** (per MANDATORY RULE 1)

**Rationale**: verify-phase fixes bypass spec/plan/tasks and have no checkpoint/review. Quick-patching a Major issue leads to suboptimal architecture — the kind of code that works but accumulates tech debt.

---

### Phase 0: Runtime Environment Readiness (UI Features only)

> Run BEFORE Pre-flight MCP check. Ensures the app can be reached by Playwright.
> Skip for non-UI Features (backend-only, library, CLI — detected from constitution-seed.md or pre-context.md).

**0-1. Build**: Run the project's build command (from `quickstart.md` or constitution).
- Build failure → BLOCK (same as Phase 1 build gate). Do NOT proceed to MCP check.
- Display: `🔨 Building project for runtime verification...`

**0-2. Start App with CDP** (Electron projects):
- Read build tool from pre-context/constitution tech stack
- Start app with CDP: per MCP-GUIDE.md Electron build tool table
  (e.g., `npx electron-vite preview -- --remote-debugging-port=9222` or `npx electron out/main/index.js --remote-debugging-port=9222`)
- Record PID for cleanup after verify completes
- Display: `🚀 Starting Electron app with CDP on port 9222...`

**0-2 alt. Start Dev Server** (Web projects):
- Start dev server (from `quickstart.md` or `launch.json`)
- Wait for port readiness (poll health endpoint or port, max 30s)
- Display: `🚀 Starting dev server...`

**0-3. Verify CDP Connection** (Electron only):
- Run `curl -s http://localhost:9222/json/version`
- Retry: 3 attempts, 3s interval
- All fail → HARD STOP: `CDP connection failed after app start. Check app startup logs.`
  Use AskUserQuestion: "Retry" / "Continue without UI verification"
  **If response is empty → re-ask** (per MANDATORY RULE 1)

**0-4. Note**: After Phase 0, the app is running. Pre-flight MCP check (next) can now detect tools correctly.
If Pre-flight still fails → the CDP Endpoint Diagnostic (in the Pre-flight section below) provides specific guidance.

---

### Pre-flight: MCP Availability Check

**Run this BEFORE Phase 1.** (After Phase 0 if applicable.) Determines whether UI verification is possible for Phase 3 Step 3.

**Detection method** — check if Playwright MCP tools exist in the current session:
1. Attempt to call `browser_snapshot` (the most reliable probe)
2. Alternatively, check if any tool matching `browser_navigate` or `mcp__playwright__browser_snapshot` exists in your available tools

**Result classification**:

| Probe result | MCP Status | Set variable |
|---|---|---|
| Tool exists and returns content (page snapshot) | ✅ Active + connected | `MCP_STATUS = active` |
| Tool exists but fails with connection error (ECONNREFUSED) | ✅ Configured but app not running | `MCP_STATUS = configured` |
| Tool does not exist / "unknown tool" error | ❌ Not installed | `MCP_STATUS = unavailable` |

**If `MCP_STATUS = unavailable`** — run CDP Endpoint Diagnostic before HARD STOP:

**CDP Diagnostic** (Electron projects only — detected from constitution-seed.md or pre-context.md tech stack):
1. Run `curl -s http://localhost:9222/json/version` (timeout 3s)
2. **If curl succeeds** (returns JSON): CDP is active but Playwright tools are not loaded.
   - Diagnosis: `CDP endpoint is running at localhost:9222. Playwright MCP tools are not loaded in this session.`
   - Likely cause: Claude Code session was started before the app, or MCP is not configured with `--cdp-endpoint`.
   - Solution: `Restart Claude Code session (the app is already running with CDP).`
3. **If curl fails** (connection refused / timeout): CDP endpoint is not running.
   - Diagnosis: `CDP endpoint not running.`
   - Solution: `Start the Electron app with --remote-debugging-port=9222, then restart Claude Code session.`

**Non-Electron projects**: Skip CDP probe. Show standard install instructions.

Display the diagnostic result (if applicable), then **HARD STOP**:
```
⚠️ Playwright MCP is not installed. UI verification (Phase 3 Step 3) will be skipped.

[If Electron + CDP diagnostic ran]:
  📋 CDP Diagnostic: [diagnosis from above]
  💡 Solution: [solution from above]

Installation: claude mcp add playwright -- npx @playwright/mcp@latest
For Electron apps: claude mcp add playwright -- npx @playwright/mcp@latest --cdp-endpoint http://localhost:9222
See MCP-GUIDE.md for details.
```
**Use AskUserQuestion**:
- "Restart session after setup" — user follows diagnostic instructions, restarts
- "Continue without UI verification" — proceed, Phase 3 Step 3 will be skipped
**If response is empty → re-ask** (per MANDATORY RULE 1)

**Record the user's choice.** Phase 3 Step 3 will use this result — do NOT re-detect or re-ask.

---

### Phase 1: Execution Verification (BLOCKING)

Run each check and record results. **If any check fails, verification is BLOCKED — do not proceed to Phase 2/3/4.**

1. **Test check**: Detect and execute the project's test command (from `package.json` scripts, `pyproject.toml`, `Makefile`, etc.)
2. **Build check**: Run the build command and confirm no errors
3. **Lint check**: Run the lint tool if configured

**If ANY check fails**, display and STOP:
```
❌ Execution Verification failed for [FID] - [Feature Name]:
  Tests: [PASS/FAIL — pass count/total, failure details]
  Build: [PASS/FAIL — error summary]
  Lint:  [PASS/FAIL — critical issue count]

Fix the failing checks before verification can continue.
Verification is BLOCKED — merge will not be allowed until all checks pass.
```

**Use AskUserQuestion** with options:
- "Fix and re-verify" — user will fix, then re-run `/smart-sdd verify`
- "Show failure details" — display full test/build/lint output
- "Acknowledge limited verification" — proceed with ⚠️ limited-verify (requires reason)

**If response is empty → re-ask** (per MANDATORY RULE 1). **Do NOT proceed to Phase 2** until all three checks pass **OR** the user explicitly acknowledges limited verification.

**Limited-verify exception path**: If the user selects "Acknowledge limited verification":
1. Ask for the reason (e.g., "Tests require external service not available", "Build depends on Feature B not yet merged", "DB migration requires completed Feature C")
2. Record in `sdd-state.md` Feature Detail Log → verify row Notes: `⚠️ LIMITED — [reason]`
3. Set the verify step icon to `⚠️` (not ✅) in Feature Progress
4. **Proceed to Phase 2 AND Phase 3 sequentially** — Phase 1 limited-acknowledge does NOT skip subsequent phases. All phases (2, 3, 4) MUST still execute. The merge step will display a reminder that this Feature has limited verification.
5. **This is NOT a skip** — the limitation is tracked and visible in status reports

> **Build prerequisites**: If the build fails due to missing setup steps (e.g., `pnpm approve-builds`, native module compilation), include the specific prerequisite command in the error message so the user knows what to run.

### Phase 2: Cross-Feature Consistency + Behavior Completeness Verification

**Step 1 — Cross-Feature consistency**:
- Check the cross-verification points in the "For /speckit.analyze" section of `pre-context.md`
- Analyze whether shared entities/APIs changed by this Feature affect other Features
- Verify that entity-registry.md and api-registry.md match the actual implementation

**Step 2 — Source Behavior Completeness** (only for brownfield rebuild — Origin: `rebuild`):
If `pre-context.md` contains a "Source Behavior Inventory" section, perform a per-Feature mini-parity check:

1. Read the Source Behavior Inventory table (function/method list with P1/P2/P3 priorities)
2. Read the Feature's `spec.md` FR-### list
3. For each P1/P2 behavior, check if a corresponding FR-### exists that covers the behavior
4. Display a coverage summary:
   ```
   📊 Source Behavior Coverage for [FID]:
     P1 behaviors: [covered]/[total] ([%])
     P2 behaviors: [covered]/[total] ([%])
     P3 behaviors: [covered]/[total] (informational)
     Uncovered P1: [list function names]
     Uncovered P2: [list function names]
   ```
5. **If any P1 behavior is uncovered**: Display a warning — `⚠️ [N] P1 source behaviors not covered by FR-###. These may represent missing functionality.`
   - This is a **warning, not a blocker** — the user may proceed but should consider whether the omission is intentional
6. If no Source Behavior Inventory exists (greenfield/add), skip this step

### Phase 3: Demo-Ready Verification (BLOCKING — only if VI. Demo-Ready Delivery is in the constitution)

> **If VI. Demo-Ready Delivery is NOT in the constitution**: Skip this phase entirely.
> Demo standards referenced in this phase are defined in [reference/demo-standard.md](../reference/demo-standard.md).
> **quickstart.md reference**: If `specs/{NNN-feature}/quickstart.md` exists, use it as the authoritative source for how the Feature should be launched and verified. The demo script must follow quickstart.md's run instructions.

**⚠️ Phase 3 has 6 mandatory steps + Phase 3b. Do NOT skip any step or jump directly to demo execution.**

```
Phase 3 Checklist (must complete ALL in order):
  □ Step 1: Demo script exists and is executable
  □ Step 2: Demo launches the real Feature
  □ Step 3: UI Verification via Playwright MCP  ← MANDATORY, not optional
  □ Step 4: Coverage mapping and demo components
  □ Step 5: CI/Interactive path convergence
  □ Step 6: Execute demo --ci
  □ Phase 3b: Bug Prevention Verification
```

**Step 1 — Check demo script exists AND is a real demo (NOT markdown, NOT test-only)**:
- Verify `demos/F00N-name.sh` (or `.ts`/`.py`/etc. matching the project's language) exists
- **REJECT if**: the file is `.md`, contains `## Demo Steps`, or consists of prose instructions instead of executable commands
- **REJECT if**: the file lacks a shebang line (`#!/usr/bin/env bash` or equivalent) for `.sh` files
- **REJECT if**: the script only runs test assertions and exits (that's a test suite, not a demo) — a demo must launch the real Feature for the user to experience

- If a markdown demo file or test-only script was generated instead, **delete it** and create a proper demo script

**Step 2 — Check the demo launches the real Feature**:
- The demo script's default behavior must **start the Feature** and keep it running for the user to interact with
- The script must print concrete "Try it" instructions: real URLs to open, real curl commands to run, real CLI invocations to try (at least 2)
- The `--ci` flag must be supported for automated verification: runs setup + health check, then exits cleanly
- **REJECT if**: the script has no interactive experience (i.e., only runs assertions and exits with no live Feature)

**Step 3 — UI Verification via Playwright MCP** (MANDATORY — do NOT skip):
> **App Session Management**: The agent manages the entire app lifecycle — start, verify, shut down. Do NOT ask the user to start or restart the app manually. The agent starts the app itself (with CDP flags for Electron), runs all SC verifications, then shuts down the app when done.

- **Runtime Degradation Flag Check**: Read sdd-state.md Feature Progress for this Feature. If Detail column shows `⚠️ RUNTIME-DEGRADED`:
  - Display: `⚠️ This Feature was implemented without runtime verification (MCP was unavailable during implement). Runtime bugs (selector instability, layout timing, infinite re-renders) may exist undetected.`
  - If `MCP_STATUS` is now `active` or `configured`: proceed with full UI verification (this is the **recovery path** — extra scrutiny)
  - If `MCP_STATUS` is STILL `unavailable`: **BLOCKING HARD STOP** — this Feature has NEVER had any runtime verification. Use AskUserQuestion:
    - "Install MCP and retry verify"
    - "Acknowledge NO runtime verification" — requires reason via "Other" input. Sets verify to `limited` status with `⚠️ NEVER-RUNTIME-VERIFIED — [reason]`
  - **If response is empty → re-ask** (per MANDATORY RULE 1)

- **MCP Status Check**: Use the `MCP_STATUS` from the Pre-flight check (run before Phase 1).
  - If `MCP_STATUS = unavailable` AND user chose "Continue without UI verification" → skip to Step 4. Display: `⏭️ UI verification skipped (Playwright MCP not available — acknowledged in Pre-flight)`
  - If `MCP_STATUS = active` or `MCP_STATUS = configured` → proceed with Electron CDP check below
  - **If Pre-flight was somehow skipped**: Call `browser_snapshot` NOW. If the tool does not exist, display the HARD STOP from Pre-flight and wait for user response. **Do NOT silently skip.**

- **Electron CDP Configuration Check** (if project type is Electron — detected from `constitution-seed.md` or `pre-context.md` tech stack info):
  Electron apps require CDP (Chrome DevTools Protocol) for Playwright to connect. Standard Playwright opens a separate Chromium browser and cannot interact with the Electron window.

  1. **Probe**: Call `browser_snapshot` to check current Playwright MCP configuration. There are THREE possible outcomes:

     | Probe result | Meaning | Action |
     |---|---|---|
     | Snapshot shows Electron app content | CDP active + app already running | → Proceed directly to SC-level UI verification |
     | Snapshot shows a default new tab / Chrome start page | Standard mode (no `--cdp-endpoint` configured) | → **Case A**: CDP not configured — HARD STOP |
     | Tool call fails / connection refused / empty result | CDP IS configured but app is NOT running on the CDP port | → **Case B**: CDP configured — agent will start the app |

     **CRITICAL**: Do NOT confuse Case B with "standard mode." When Playwright MCP has `--cdp-endpoint` configured but nothing is listening on that port, `browser_snapshot` will fail with a connection error (`ECONNREFUSED`). This means CDP IS set up correctly — the app just needs to be started.

  2. **Case A — CDP not configured (standard mode detected)**: This is a **MANDATORY HARD STOP**.
     This is the ONLY case that requires user action — the user must reconfigure Playwright MCP itself.
     Display notice:
     ```
     ⚠️ Electron apps require CDP mode for Playwright to connect.
        Playwright MCP is currently in standard browser mode.

        CDP setup:
        1. claude mcp remove playwright -s user
        2. claude mcp add --scope user playwright -- npx @playwright/mcp@latest --cdp-endpoint http://localhost:9222
        3. Restart Claude Code
     ```
     **Use AskUserQuestion** — this is NOT optional, NOT skippable:
     - "Retry after CDP configuration" — user configures CDP, then re-run verify
     - "Skip UI verification — health check only" — skip Playwright UI verification, proceed with demo script health check only
     **If response is empty → re-ask** (per MANDATORY RULE 1)
     **NEVER auto-skip this step.** The agent must wait for user's explicit choice.

  3. **Case B — CDP configured, app not running**: No user action needed. The agent starts the app itself.
     **If app was started in Phase 0**: Reuse the running instance — do NOT start a second app. Check if the Phase 0 process is still alive (`kill -0 $PID`), and if so, proceed directly to SC-level UI verification.
     **Otherwise**: Display: `ℹ️ CDP mode confirmed. Starting the app automatically.`
     Proceed to the App Launch step below.

  4. **If CDP active and app already connected**: Skip app launch, proceed directly to SC-level UI verification.

  > **Tip**: If `/reverse-spec` was run with CDP for the same Electron stack, Playwright MCP is already in CDP mode.

- **If MCP available** (and CDP check passed for Electron) — perform App Launch + SC-level UI verification:

  **App Launch** (agent-managed — do NOT ask the user to start/restart the app):
  1. Detect the project's dev start command from `package.json` scripts or project config (e.g., `npx electron-vite dev`, `npm run dev`)
  2. For Electron with CDP: Append `-- --remote-debugging-port=9222` to the start command
  3. Start the app in background via Bash (e.g., `npx electron-vite dev -- --remote-debugging-port=9222 &`)
  4. Wait for the app to be ready: poll health endpoint or wait ~10 seconds
  5. Probe with `browser_snapshot` to confirm CDP connection:
     - If connected (app content visible) → proceed to SC verification
     - If still failing after app started → display error and HARD STOP:
       ```
       ⚠️ App started but CDP connection failed.
       ```
       **Use AskUserQuestion**:
       - "Retry" — retry the connection probe
       - "Skip UI verification — health check only"
       **If response is empty → re-ask** (per MANDATORY RULE 1)

  **SC-level UI Verification**:
  1. Parse demo script Coverage header → extract FR-###/SC-### + UI Action list
  2. Verify each SC-###:
     - ✅-marked SC: Execute UI Action sequence
       - `navigate /path` → move via Navigate capability
       - `fill selector` → input via Type capability
       - `click selector` → click via Click capability
       - `verify selector visible` → confirm element existence via Snapshot capability
     - ⬜-marked SC: Skip (record reason)
  3. Collect JS errors from Console logs (TypeError, ReferenceError, etc.)
  4. Detect page load failures
  5. Result report:
  ```
  📊 UI Verification Report for [FID]:
    SC-001: ✅ navigate → fill → click → verify OK
    SC-002: ✅ navigate → click → verify OK
    SC-003: ⬜ skipped (WebSocket)
    SC-004: ⚠️ FAIL — verify .result not found after click
    Console errors: [N] (TypeError: 2, ReferenceError: 1)
  ```

  **App Shutdown**: After all SC verifications complete, terminate the app process started above. Do NOT leave it running.

- **Result classification** (all warnings, NOT blocking):
  - SC interaction failure: ⚠️ warning (false positive possible — selector changes, etc.)
  - JS console errors (TypeError/ReferenceError): ⚠️ warning + highlighted
  - Page load failure: ⚠️ warning
- **UI verification failures do NOT block the overall verify result** — they are included as warnings in Review. However, this does NOT mean UI verification can be skipped without user consent. The Case A CDP HARD STOP must always be presented to the user.
- See [reference/ui-testing-integration.md](../reference/ui-testing-integration.md) for full guide

**Step 3b — Visual Fidelity Check** (rebuild mode only — skip for greenfield/add):

If `specs/reverse-spec/visual-references/manifest.md` exists AND this Feature covers screens listed in the manifest:

1. Read the manifest to identify which reference screenshots apply to this Feature (match by screen name, route, or Feature coverage from pre-context)
2. For each matching screen:
   a. Navigate to the equivalent screen in the rebuilt app (use demo URL or route from spec.md)
   b. Take a screenshot of the current rebuilt state
   c. Read BOTH the reference screenshot and current screenshot
   d. Compare: layout structure, key element presence, obvious visual regressions
3. Report per screen:
   - `✅ Visual match` — layout structure and key elements consistent
   - `⚠️ Visual deviation` — describe specific differences (missing elements, layout shift, style mismatch, color/spacing drift)
   - `❌ Major regression` — screen fundamentally different or broken
4. **Result**: ⚠️ warnings (NOT blocking) — deviations documented in Review
5. User can acknowledge intentional deviations ("redesigned on purpose") vs. unintentional gaps during Review

If visual references don't exist or no screens match this Feature: skip silently.

**Step 4 — Check coverage mapping and demo components**:
- The demo script must include a **Coverage** header comment mapping FR-###/SC-### from spec.md to what the user can try/see in the demo
  - Each FR/SC should be either ✅ (demonstrated) or ⬜ (not demoed with reason)
  - **Aim for maximum coverage** — every functional requirement should be experienceable in the demo unless genuinely impossible
  - If coverage is below 50% of the Feature's FR count, **WARN** the user and suggest expanding the demo
- The demo script must include a **Demo Components** header comment listing each component as Demo-only or Promotable
- Demo-only components are marked with `// @demo-only` (removed after all Features complete)
- Promotable components are marked with `// @demo-scaffold — will be extended by F00N-[feature]`

**Step 5 — Validate CI/Interactive path convergence**:
Before running the demo, **read the demo script source** and verify:
- The `if [ "$CI_MODE" = true ]` exit point comes **AFTER** the actual Feature startup command (e.g., `npm run dev`, `tauri dev`, server start), not before
- CI mode and interactive mode use the **same startup commands** — CI must not take a shortcut path (e.g., only checking build without starting the Feature)
- **REJECT if**: the CI branch exits before the Feature's main process is started — this means CI can pass while the actual demo fails

> **Why this matters**: A demo that passes CI but fails for the user is worse than no CI check at all. Example: CI checks "frontend build" → passes. User runs the demo → `tauri: command not found`. The CI check gave false confidence.

**Step 6 — Execute the demo in CI mode (`--ci`)**:
- Run `demos/F00N-name.sh --ci` and verify it completes without errors
- The demo script's CI mode MUST include a **stability window** (~10 seconds) between the initial health check and exit — verify the script includes this (see demo-standard.md template)
- If the demo script lacks a stability window (exits immediately after first health check), **WARN** and recommend updating the script to include one
- Capture the demo output (stdout/stderr) for the Review display
- **Runtime error scan (BLOCKING)**: After demo execution, scan the captured stdout/stderr for runtime error patterns:
  - `"level":"error"` or `"level":"fatal"` (structured log errors)
  - `Error occurred`, `Unhandled rejection`, `Uncaught exception`
  - `TypeError`, `ReferenceError`, `SyntaxError` (JS runtime errors)
  - `No handler registered`, `ECONNREFUSED`, `ENOENT` (service initialization failures)
  - `panic:`, `FATAL`, `segfault` (system-level crashes)
  - Process exit with non-zero code
- **If runtime errors are detected**: The demo is considered **FAILED** even if the health check (HTTP 200) passed — a healthy port does not mean the application is functioning correctly (e.g., Vite dev server may respond while Electron main process has fatal errors)
- Display each detected error with its source line for user review
- **Browser console error scan (when MCP available)**: After demo --ci passes the stdout/stderr scan above, if `MCP_STATUS = active`:
  1. Navigate to the app's main URL (from demo script's "Try it" output or health check URL)
  2. Wait 5 seconds for the page to stabilize
  3. Read browser Console logs for: `TypeError`, `ReferenceError`, `Maximum update depth exceeded`, `unhandled rejection`, infinite render warnings
  4. **If browser console errors detected**: Demo is FAILED even if health endpoint returned 200 and stdout was clean — these are client-side-only bugs (infinite re-renders, selector instability, DOM timing) that never appear in server output
  5. Display: `❌ Browser console errors detected: [N] errors — [first error message]`
  6. If `MCP_STATUS ≠ active`: Skip browser console scan. Display: `ℹ️ Browser console scan skipped (MCP not active)`

**If any check fails**, display and BLOCK:
```
❌ Demo-Ready verification failed for [FID] - [Feature Name]:
  - [Missing: demos/F00N-name.sh | --ci health check failed: <error> | Demo is test-only (no live Feature) | Missing: Demo Components header | Missing: component markers]

"Tests pass" alone does not satisfy Demo-Ready Delivery.
A demo must launch the real, working Feature so the user can experience it.
Please create a demo script at demos/F00N-name.sh that:
  - Starts the Feature and prints "Try it" instructions (default)
  - Supports --ci for automated health check (verify phase)
  - Includes Demo Components with appropriate category markers
```

**Use AskUserQuestion** with options:
- "Fix and re-verify" — user will fix, then re-run `/smart-sdd verify`
- "Show failure details" — display full demo script output
- "Acknowledge limited verification" — proceed with ⚠️ limited-verify (requires reason)

**If response is empty → re-ask** (per MANDATORY RULE 1). **Do NOT proceed to Phase 4** until the demo passes **OR** the user explicitly acknowledges limited verification.

**Limited-verify exception path** (same as Phase 1): If the user selects "Acknowledge limited verification":
1. Ask for the reason (e.g., "Demo requires Feature B's UI not yet built", "No frontend in this Feature — pure library")
2. Append to `sdd-state.md` Feature Detail Log → verify Notes: `⚠️ DEMO-LIMITED — [reason]`
3. If Phase 1 already passed normally, set verify icon to `⚠️` (limited) instead of ✅
4. Proceed to Phase 4

- Update `demos/README.md` (Demo Hub) with the Feature's demo and what the user can experience:
  - `./demos/F00N-name.sh` — launches [brief description of the live demo experience]

### Phase 3b: Bug Prevention Verification (B-4)

> Additional checks to automatically verify basic stability of code written during implement.
> Runs after Phase 3 Demo-Ready, before Phase 4 Update.

**Empty State Smoke Test**:
- Start app with all stores/state set to initial (empty) state
- Confirm main screen renders without crashes (Error Boundary not triggered)
- Confirm no critical JS errors in Console (TypeError, ReferenceError, etc.)
- **When MCP available**: Auto-verify via Navigate → Snapshot
- **Without MCP**: Substitute with build + server start success check

**Smoke Launch Criteria** (basic app stability):
1. Process starts — no immediate exit with non-zero exit code
2. Main screen renders — not a blank page or error screen
3. Error Boundary not triggered — React/Vue/Svelte error boundaries not activated
4. No JS errors — Console free of TypeError, ReferenceError, SyntaxError

**Result classification**: ⚠️ warning (NOT blocking) — results included in Review

---

### Phase 4: Global Evolution Update
- entity-registry.md: Verify that the actually implemented entity schemas match the registry; update if discrepancies are found
- api-registry.md: Verify that the actually implemented API contracts match the registry; update if discrepancies are found
- sdd-state.md: Record verification results — **status MUST be one of `success`, `limited`, or `failure`**, plus test pass/fail counts, build result, and verification timestamp. The merge step checks this status as a gate condition.
  - `success`: All phases passed normally
  - `limited`: User acknowledged limited verification in Phase 1 or Phase 3 (⚠️ marker). Merge is allowed with a reminder
  - `failure`: One or more phases failed without acknowledgment. Merge is blocked
