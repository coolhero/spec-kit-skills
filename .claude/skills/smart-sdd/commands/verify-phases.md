# Verify Command — Phase Details

> Read after `/smart-sdd verify [FID]` is invoked. For Common Protocol (Checkpoint, Review), see `pipeline.md`.
> For per-command injection rules, see `reference/injection/verify.md`.
>
> **Adoption mode**: If `sdd-state.md` Origin is `adoption`, read `reference/injection/adopt-verify.md` instead of `reference/injection/verify.md`. Key differences: Phase 1 failures are **non-blocking** (pre-existing issues), Phase 3 is **skipped** (adoption has no per-Feature demos), and Feature status is `adopted` (not `completed`).

---

## Verify Command

Running `/smart-sdd verify [FID]` performs post-implementation verification. This step runs **after implement** to validate that the actual code works correctly and is consistent with the broader project.

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

**Step 2b — UI Verification Hook** (MCP required):
> **App Session Management**: Demo script starts the app → all SC verifications in the same session → shut down after Phase completes. See [MCP-GUIDE.md](../../../../MCP-GUIDE.md) for MCP Capability Map.

- **MCP Detection**: Check availability of Playwright MCP (or corresponding tools from MCP Capability Map)
- **If MCP not available**: Display warning and HARD STOP:
  ```
  ⚠️ Playwright MCP가 설치되어 있지 않습니다. UI 검증을 수행할 수 없습니다.
  MCP 설치: MCP-GUIDE.md 참조
  ```
  **Use AskUserQuestion** with options:
  - "Playwright MCP 설치 후 재시도"
  - "UI 검증 Skip"
  **If response is empty → re-ask** (per MANDATORY RULE 1)

- **Electron CDP Check** (if project type is Electron — detected from `constitution-seed.md` or `pre-context.md` tech stack info):
  Electron apps require CDP (Chrome DevTools Protocol) for Playwright to connect. Standard Playwright opens a separate Chromium browser and cannot interact with the Electron window.

  1. **Probe**: Call `browser_snapshot` to check current Playwright connection state:
     - If snapshot shows the Electron app content (e.g., matching the Feature's UI) → CDP is active, proceed
     - If snapshot shows a blank page / default browser tab → CDP is NOT configured
     - If the tool call fails → Playwright MCP is not functional

  2. **If CDP not configured**: Display notice and **HARD STOP with user choice**:
     ```
     ⚠️ Electron 앱은 CDP 모드가 필요합니다.
        현재 Playwright MCP가 표준 브라우저 모드로 연결되어 있어 Electron 앱 UI를 검증할 수 없습니다.

        CDP 설정 방법:
        1. 앱을 --remote-debugging-port=9222 로 실행
        2. claude mcp remove playwright -s user
        3. claude mcp add --scope user playwright -- npx @playwright/mcp@latest --cdp-endpoint http://localhost:9222
        4. Claude Code 재시작
     ```
     **Use AskUserQuestion** with options:
     - "CDP 설정 후 재시도" — user configures CDP, then re-run verify
     - "UI 검증 Skip — health check만 수행" — skip Playwright UI verification, proceed with demo script health check only
     **If response is empty → re-ask** (per MANDATORY RULE 1)

  3. **If CDP active**: Proceed to SC-level UI verification below.

  > **Tip**: If `/reverse-spec` was run with CDP for the same Electron stack, Playwright MCP may already be in CDP mode. Start the new app with `--remote-debugging-port=9222` and it will connect automatically.

- **If MCP available** (and CDP check passed for Electron) — perform SC-level UI verification:
  1. Parse demo script Coverage header → extract FR-###/SC-### + UI Action list
  2. Start app (demo script `--ci` or directly)
  3. Verify each SC-###:
     - ✅-marked SC: Execute UI Action sequence
       - `navigate /path` → move via Navigate capability
       - `fill selector` → input via Type capability
       - `click selector` → click via Click capability
       - `verify selector visible` → confirm element existence via Snapshot capability
     - ⬜-marked SC: Skip (record reason)
  4. Collect JS errors from Console logs (TypeError, ReferenceError, etc.)
  5. Detect page load failures
  6. Result report:
  ```
  📊 UI Verification Report for [FID]:
    SC-001: ✅ navigate → fill → click → verify OK
    SC-002: ✅ navigate → click → verify OK
    SC-003: ⬜ skipped (WebSocket)
    SC-004: ⚠️ FAIL — verify .result not found after click
    Console errors: [N] (TypeError: 2, ReferenceError: 1)
  ```

- **Result classification** (all warnings, NOT blocking):
  - SC interaction failure: ⚠️ warning (false positive possible — selector changes, etc.)
  - JS console errors (TypeError/ReferenceError): ⚠️ warning + highlighted
  - Page load failure: ⚠️ warning
- **UI verification failures are NOT blocking since health check already passed** — results included in Review
- See [reference/ui-testing-integration.md](../reference/ui-testing-integration.md) for full guide

**Step 3 — Check coverage mapping and demo components**:
- The demo script must include a **Coverage** header comment mapping FR-###/SC-### from spec.md to what the user can try/see in the demo
  - Each FR/SC should be either ✅ (demonstrated) or ⬜ (not demoed with reason)
  - **Aim for maximum coverage** — every functional requirement should be experienceable in the demo unless genuinely impossible
  - If coverage is below 50% of the Feature's FR count, **WARN** the user and suggest expanding the demo
- The demo script must include a **Demo Components** header comment listing each component as Demo-only or Promotable
- Demo-only components are marked with `// @demo-only` (removed after all Features complete)
- Promotable components are marked with `// @demo-scaffold — will be extended by F00N-[feature]`

**Step 4 — Validate CI/Interactive path convergence**:
Before running the demo, **read the demo script source** and verify:
- The `if [ "$CI_MODE" = true ]` exit point comes **AFTER** the actual Feature startup command (e.g., `npm run dev`, `tauri dev`, server start), not before
- CI mode and interactive mode use the **same startup commands** — CI must not take a shortcut path (e.g., only checking build without starting the Feature)
- **REJECT if**: the CI branch exits before the Feature's main process is started — this means CI can pass while the actual demo fails

> **Why this matters**: A demo that passes CI but fails for the user is worse than no CI check at all. Example: CI checks "frontend build" → passes. User runs the demo → `tauri: command not found`. The CI check gave false confidence.

**Step 5 — Execute the demo in CI mode (`--ci`)**:
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
