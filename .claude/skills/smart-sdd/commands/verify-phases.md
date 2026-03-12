# Verify Command — Phase Details

> Read after `/smart-sdd verify [FID]` is invoked. For Common Protocol (Checkpoint, Review), see `pipeline.md`.
> For per-command injection rules, see `reference/injection/verify.md`.
>
> **Adoption mode**: If `sdd-state.md` Origin is `adoption`, read `reference/injection/adopt-verify.md` instead of `reference/injection/verify.md`. Key differences: Phase 1 failures are **non-blocking** (pre-existing issues), Phase 3 is **skipped** (adoption has no per-Feature demos), and Feature status is `adopted` (not `completed`).

---

## Verify Command

Running `/smart-sdd verify [FID]` performs post-implementation verification. This step runs **after implement** to validate that the actual code works correctly and is consistent with the broader project.

### Bug Fix Severity Rule — verify is for FINDING, not REWRITING

When verify discovers a bug (or the user provides feedback during Review), classify its severity and **route to the correct pipeline stage**:

| Severity | Examples | Action |
|---|---|---|
| **Minor** | Missing import, typo, null check, off-by-one, missing CSS class, simple config fix | ✅ Fix inline during verify — commit as `fix:` |
| **Major-Implement** | Frozen object pattern change, missing component, state flow restructuring, new module needed | ❌ Return to **implement** — re-run affected tasks with issue context |
| **Major-Plan** | Wrong architecture pattern, missing data model field, API contract mismatch, component structure redesign needed | ❌ Return to **plan** — re-run speckit-plan with updated constraints |
| **Major-Spec** | Missing functional requirement, wrong acceptance criteria, scope gap, requirement misinterpretation | ❌ Return to **specify** — re-run speckit-specify with corrected requirements |

**How to classify**:
- **Minor**: Fix touches ≤2 files, no API/interface change, no architectural reasoning needed
- **Major-Implement**: Fix touches 3+ files OR needs a new component, but spec and plan are correct
- **Major-Plan**: The plan's architecture, data model, or contracts need revision (spec is correct, but the plan made wrong choices)
- **Major-Spec**: The requirements themselves are wrong or incomplete (everything downstream — plan, tasks, implement — is built on wrong assumptions)

**When any Major issue is found**:
1. Record the issue in the verify result report with full details and the recommended regression target
2. Display: `🔴 [Severity] issue detected — requires pipeline regression to [target stage]`
3. Set verify status to `failure` with the issue description and regression target
4. **HARD STOP** — Use AskUserQuestion:
   - "Return to [target stage] with issue context" — pipeline regression with preserved context
   - "Reclassify severity and fix now" — user overrides severity classification
   **If response is empty → re-ask** (per MANDATORY RULE 1)

**Pipeline regression handling** (when user confirms "Return to [stage]"):
1. Record regression reason in `sdd-state.md` Feature Detail Log: `↩️ REGRESSION to [stage] — [reason]`
2. Set Feature status to `regression-[stage]` (e.g., `regression-specify`, `regression-plan`)
3. Preserve current verify results as context — the re-run starts with knowledge of what went wrong
4. Display: `↩️ Returning to [stage] for [FID]. Verify results preserved as regression context.`
5. Resume pipeline from the selected stage — all subsequent steps (specify → plan → tasks → implement → verify) re-execute

**Rationale**: verify-phase fixes bypass spec/plan/tasks and have no checkpoint/review. Quick-patching a Major issue leads to suboptimal architecture — the kind of code that works but accumulates tech debt. Additionally, user feedback during verify Review often identifies issues that are not bugs but rather spec-level or plan-level problems. Without structured regression routing, these fixes happen ad-hoc, outside the pipeline's quality gates.

### Verify-time Change Recording — All Source Modifications

The Bug Fix Severity Rule above handles **bugs** (wrong behavior). But verify may also discover **implementation gaps** — missing behavior that falls within the scope of an existing FR-### or task but was not completed during implement. Unlike a bug, an implementation gap is *absent* behavior, not *wrong* behavior (e.g., missing i18n keys, unimplemented edge case within a documented SC, missing config entry referenced in tasks).

**Classification of ALL source modifications during verify**:

| Change Type | Scope Test | Action |
|-------------|-----------|--------|
| Bug Fix (Minor) | Wrong behavior, ≤2 files, no API change | Fix inline (per Bug Fix Severity Rule) |
| Implementation Gap | Missing behavior within existing FR/task scope, ≤2 files, no API change | Fix inline + record as gap fill |
| Design Change | New behavior beyond FR/task scope, OR 3+ files, OR API/contract change | Pipeline regression (per Bug Fix Severity Rule Major-*) |

**Decision flow** (when modifying source during verify):
1. Is this fixing **wrong** behavior? → Bug Fix → Apply Bug Fix Severity Rule
2. Is this adding **missing** behavior within an existing FR/task?
   - ≤2 files, no API/interface change → **Implementation Gap** — fix inline + record
   - 3+ files OR API change → **Major-Implement** regression
3. Is this adding behavior **beyond** existing FR/task scope? → **Design Change** → Major-* regression

**Recording requirement** (in sdd-state.md Notes after verify completes):
All inline changes (Minor bug fixes + Implementation gap fills) must be summarized in the Notes column. This recording ensures:
- **Transparency**: user sees what was changed during verify beyond the planned verification
- **Audit trail**: if a "gap fill" was actually a scope expansion, the record enables review
- **Pattern detection**: repeated gap fills in the same area suggest implement phase quality issues

Format: `Inline changes: [N] bug fix, [N] gap fill ([brief descriptions])`

### Source Modification Gate (MANDATORY — enforced before ANY source file change)

> **Why this gate exists**: The Bug Fix Severity Rule and Verify-time Change Classification above are reference rules. In practice, agents skip them due to "fix it now" bias — they discover an issue and immediately modify code without first evaluating severity. This gate is the enforcement mechanism that BLOCKS source modification until classification is completed and displayed.

**RULE: Before editing ANY source file (`.ts`, `.tsx`, `.vue`, `.py`, `.go`, `.rs`, `.java`, `.jsx`, `.svelte`, etc.) during verify, the agent MUST execute this gate. No exceptions.**

**Gate procedure**:

1. **STOP** — do NOT open any source file for editing yet.

2. **List ALL planned changes** in a visible table:
   ```
   🔍 Source Modification Gate — Pre-Fix Classification:
   | # | File | What changes | Why |
   |---|------|-------------|-----|
   | 1 | tools/index.ts | KB picker popover structure | SC-007a: picker doesn't open |
   | 2 | types/knowledge.ts | Add KnowledgeReference.name field | CitationBlock needs name for display |
   | 3 | KnowledgeService.ts | getKnowledgeReferences() return shape | Include name in returned data |
   | 4 | CitationBlock.tsx | Render name from reference | Display citation source name |
   ```

3. **Apply classification per change** (using Decision Flow above):
   - Each row: Bug Fix / Implementation Gap / Design Change
   - Each row: file count contribution

4. **AGGREGATE file count check**: Count TOTAL unique files across ALL planned changes.
   - Total ≤ 2 files, no API/interface change, no state restructure → **Minor/Gap — proceed inline**
   - Total ≥ 3 files → **Major-Implement** (regardless of individual change sizes)
   - ANY change involves API/contract change → **Major-Plan**
   - ANY change involves state flow restructure or new module → **Major-Implement**
   - ANY change adds behavior beyond existing FR/task scope → **Major-* regression**

   > **Critical**: Do NOT evaluate each change in isolation. Evaluate the AGGREGATE. Four "small" changes across 4 files = Major-Implement, not four Minor fixes.

5. **Display classification result**:
   ```
   ⚙️ Classification: [Minor — proceed inline] OR [🔴 Major-Implement — pipeline regression required]
     Total files: [N]
     API/interface change: [yes/no]
     State restructure: [yes/no]
   ```

6. **If Minor/Gap** → Proceed with inline fixes. Record all changes in Notes. **Then execute Post-Fix Runtime Verification** (step 8 below).

7. **If Major** → **HARD STOP**. Do NOT modify any source files. Trigger the "When any Major issue is found" flow (lines 31-38):
   - Display `🔴 [Severity] issue detected — requires pipeline regression to [target stage]`
   - **Use AskUserQuestion**:
     - "Return to [target stage] with issue context"
     - "Reclassify severity and fix now" — user overrides
   - **If response is empty → re-ask** (per MANDATORY RULE 1)

8. **Post-Fix Runtime Verification** (MANDATORY after every inline fix):

   > "Build passes + tests pass ≠ fix is correct." An inline fix during verify MUST be runtime-verified, not just statically validated. This catches the pattern where code compiles but the fix doesn't actually resolve the runtime issue (e.g., service exists but isn't wired in, type is correct but data doesn't flow).

   After applying an inline fix (Minor bug fix or Gap fill):
   1. **Build check**: Run build → confirm no errors introduced
   2. **Test check**: Run tests → confirm no regressions
   3. **Runtime verification of the specific fix**:
      - Identify the SC(s) affected by the fix
      - Re-run the affected SC verification using the appropriate backend (Playwright MCP/CLI, HTTP client, process runner)
      - The fix is NOT complete until the affected SC passes at its Required Depth (from SC Verification Matrix)
      - If runtime verification fails after the fix → the fix is insufficient. Re-evaluate: is this actually Minor, or has the scope grown to Major?
   4. **Display result**:
      ```
      🔧 Post-Fix Verification:
        Build: ✅ | Tests: ✅ | Runtime SC-022: ✅ Tier 2 reached
        Fix confirmed — recording in Notes.
      ```
      OR:
      ```
      🔧 Post-Fix Verification:
        Build: ✅ | Tests: ✅ | Runtime SC-022: ❌ still failing
        ⚠️ Fix did not resolve runtime issue. Re-evaluating severity...
      ```
   5. If runtime re-verification fails AND investigation reveals more files need changes → **re-run the Source Modification Gate** with the expanded scope. The aggregate file count may now push the fix to Major.

9. **Minor Fix Accumulator** (cross-gate tracking):

   The Source Modification Gate evaluates each fix batch independently. But a pattern of repeated Minor fixes in the same area indicates a deeper structural issue that should be handled by implement, not verify.

   **Rule**: Track all inline fixes applied during this verify session. If **3 or more Minor fixes** (bug fix or gap fill) accumulate in the **same module/component** (same directory or same logical boundary), auto-escalate to **Major-Implement**:
   ```
   🔴 Minor Fix Accumulator triggered:
     Module: src/services/knowledge/
     Fixes applied: 3 (Bug #1: loader path, Bug #4: PDF parser, Bug #5: pdf-parse API)
     → Auto-escalated to Major-Implement — this module needs redesign in implement, not patchwork in verify.
   ```
   After auto-escalation → trigger the Major HARD STOP flow (step 7 above).

   **Module boundary definition**: Files sharing the same parent directory OR the same service/component name (e.g., `KnowledgeService.ts`, `KnowledgeLoader.ts`, `KnowledgeStore.ts` = same `Knowledge` module even if in different directories).

**This gate applies to ALL verify phases**: Phase 1 re-fixes, Phase 2 fixes, Phase 3 SC failure fixes, Phase 3b fixes, and post-Review user-requested fixes. There are NO exceptions.

---

### Verify Initialization — Compaction-Safe Checkpoint

Before any Phase execution, write the Verify Progress table AND Process Rules Checklist to sdd-state.md:

1. Read sdd-state.md → Feature Detail Log for this Feature
2. **Check for existing Verify Progress**:
   - If exists with pending phases → **Resumption Protocol** (see below)
   - If not exists → write fresh Verify Progress table with all phases as `⏳ pending`
3. Set `⚠️ RESUME FROM: Phase 0` line
4. **Write Process Rules Checklist** (survives context compaction — agent re-reads sdd-state.md after compaction):
   ```
   #### Verify Process Rules (re-read after compaction)
   - [ ] Source Modification Gate: BEFORE editing ANY source file → list changes → classify → aggregate file count → if ≥3 files or API change → Major HARD STOP
   - [ ] Minor Accumulator: 3+ Minor fixes in same module → auto-escalate to Major
   - [ ] Post-Fix Runtime Verification: after inline fix → build + test + runtime SC re-verify at Required Depth
   - [ ] SC Decomposition: mixed SCs → split into sub-SCs (auto + user-assisted)
   - [ ] Per-SC Depth Tracking: record Reached Depth vs Required Depth for each SC
   - [ ] Inline changes recording: all source modifications during verify → Notes column
   ```
   This checklist is written to sdd-state.md as plain text, ensuring it persists across context compaction boundaries. The Resumption Protocol (below) includes re-reading this checklist as step 1.

**After each Phase completes**: Update the Phase's Status to `✅ complete` and write Result summary.
Update `⚠️ RESUME FROM` to point to the next pending Phase.

**On verify completion** (success or failure):
- Delete the `#### Verify Progress` section from sdd-state.md
- Delete the `#### Verify Process Rules` section from sdd-state.md
- Write final result to Notes column as before

---

### Resumption Protocol — After Context Compaction

If sdd-state.md contains `#### Verify Progress` with pending phases:

1. **Re-read this file** (commands/verify-phases.md) — MANDATORY
2. **Re-read reference/injection/verify.md** — for Checkpoint/Review display format
3. **Re-read `#### Verify Process Rules`** from sdd-state.md — MANDATORY. These rules survive compaction and MUST be followed for the remainder of the verify session. Pay special attention to the Source Modification Gate and Minor Accumulator.
4. **Identify resume point**: First phase with `⏳ pending` or `🔄 in_progress` status
5. **Re-establish prerequisites**:
   - If Phase 3 pending and MCP needed → re-run Phase 0 (app start + CDP check)
   - If Phase 1 already complete → do NOT re-run tests/build/lint
6. **Continue from resume point** through remaining phases
7. **Display resume notice**:
   ```
   🔄 Verify resumed from Phase [N] (context compaction detected)
   Previously completed: Phase 0 ✅, Phase 1 ✅, Phase 2 ✅
   Continuing: Phase 3, Phase 3b, Phase 4
   ```

---

### Phase 0: Runtime Environment Readiness (UI Features only)

> Run BEFORE Pre-flight MCP check. Ensures the app can be reached by Playwright.
> Skip for non-UI Features (backend-only, library, CLI — detected from constitution-seed.md or pre-context.md).

**0-1. Build**: Run the project's build command (from `quickstart.md` or constitution).
- Build failure → BLOCK (same as Phase 1 build gate). Do NOT proceed to MCP check.
- Display: `🔨 Building project for runtime verification...`

**0-2. Start Electron App** (Electron projects):
- Read build tool from pre-context/constitution tech stack
- **Primary path (CLI backend)**: Use Playwright `_electron.launch()` API — no CDP needed. The Playwright test runner launches the Electron app directly via the `electron` binary path.
  (e.g., `const app = await _electron.launch({ args: ['out/main/index.js'] })`)
- **Alternative path (MCP backend)**: Start app with CDP: per PLAYWRIGHT-GUIDE.md Electron build tool table
  (e.g., `npx electron-vite preview -- --remote-debugging-port=9222` or `npx electron out/main/index.js --remote-debugging-port=9222`)
  > **Note**: CDP configuration is only required when using Playwright MCP as the backend. CLI mode uses `_electron.launch()` which connects directly without CDP.
- Record PID for cleanup after verify completes
- Display: `🚀 Starting Electron app...` (CLI mode) or `🚀 Starting Electron app with CDP on port 9222...` (MCP mode)

**0-2 alt. Start Dev Server** (Web projects):
- Start dev server (from `quickstart.md` or `launch.json`)
- Wait for port readiness (poll health endpoint or port, max 30s)
- Display: `🚀 Starting dev server...`

**0-2c. Dev Mode Stability Probe** (GUI projects with distinct dev command):

> Production builds and dev mode follow different code paths — module bundling vs native ESM, static env injection vs runtime loading, pre-compiled vs HMR-driven. Bugs that only manifest under one path (e.g., module-scope side effects that depend on initialization order) are invisible if verify only exercises the other. This probe catches startup-time crashes in the path NOT covered by 0-2/0-2alt.

**Skip if**: No dev command detected, or dev command is identical to the production start path already tested above.

**Detection**: Read `package.json` scripts for a `dev` entry (or `start:dev`, `serve`, etc.). Compare with the production start command used in 0-2/0-2alt. If they invoke different tooling (e.g., `electron-vite dev` vs `electron-vite build && electron .`, or `vite dev` vs `vite build && vite preview`), proceed.

**Procedure**:
1. Run the dev command in background (e.g., `pnpm run dev &`)
2. Monitor stderr for ~10 seconds (stability window)
3. Scan for crash patterns: `TypeError`, `ReferenceError`, `SyntaxError`, `Uncaught exception`, `Unhandled rejection`, `panic:`, `FATAL`, `segfault`, process exit with non-zero code
4. Kill the dev process (cleanup)
5. **If crash detected**: `⚠️ Dev mode startup crash — [error pattern]. Production build may mask initialization-order or environment-dependent bugs.`
   - Result: ⚠️ WARNING (NOT blocking) — included in Phase 3b Bug Prevention results
6. **If clean**: `✅ Dev mode startup stable`
7. Display result and continue to 0-3

> **Note**: This probe tests startup stability only — it does NOT replace the full runtime verification in Phase 3, which uses the production build. The purpose is to surface environment-dependent crashes (module-scope side effects, lifecycle-dependent initialization, missing runtime prerequisites) that differ between dev and production code paths.

**0-3. Verify CDP Connection** (Electron only — MCP backend path):
- Skip this step if `RUNTIME_BACKEND = cli` or `cli-limited` (CLI uses `_electron.launch()`, no CDP needed)
- Run `curl -s http://localhost:9222/json/version`
- Retry: 3 attempts, 3s interval
- All fail → HARD STOP: `CDP connection failed after app start. Check app startup logs.`
  Use AskUserQuestion: "Retry" / "Continue without UI verification"
  **If response is empty → re-ask** (per MANDATORY RULE 1)

**0-4. Note**: After Phase 0, the app is running. Pre-flight MCP check (next) can now detect tools correctly.
If Pre-flight still fails → the CDP Endpoint Diagnostic (in the Pre-flight section below) provides specific guidance.

---

### Pre-flight: Runtime Verification Backend Detection

**Run this BEFORE Phase 1.** (After Phase 0 if applicable.) Determines which runtime verification backends are available for Phase 3.

> For the full backend registry, detection order, and interface mapping, see [reference/runtime-verification.md](../reference/runtime-verification.md).
> For the user cooperation pattern used in HARD STOPs below, see [reference/user-cooperation-protocol.md](../reference/user-cooperation-protocol.md).

**Step 1 — Determine active interface** (from sdd-state.md Domain Profile → Interfaces):
- If `gui` in interfaces → GUI detection path (Step 2a)
- If `http-api` in interfaces → API detection path (Step 2b)
- If `cli` in interfaces → CLI detection path (Step 2c)
- If `data-io` in interfaces → Data-IO detection path (Step 2d)
- Multiple interfaces → run ALL applicable detection paths

**Step 2a — GUI Backend Detection**:

Execute the full detection protocol defined in [runtime-verification.md §3a](../reference/runtime-verification.md):

1. **Probe Playwright CLI** (two-phase: binary + library import + recovery) → `PLAYWRIGHT_CLI = available / unavailable`
2. **Check VERIFY_STEPS test file** (`demos/verify/F00N-name.spec.ts`) → `VERIFY_TEST = exists / missing`
3. **Probe Playwright MCP** (optional) → `MCP_STATUS = active / configured / unavailable`

   > **MCP probe note**: "Target page, context or browser has been closed" = `configured`, NOT `unavailable`. MCP IS installed, CDP IS configured, but app is not running. Agent starts it in Phase 3 Step 3 (Case B).

4. **Classify RUNTIME_BACKEND** per [runtime-verification.md §3a table](../reference/runtime-verification.md):
   `cli` (best) → `cli-limited` → `mcp` → `demo-only` → `build-only` (worst).
   If demo script also doesn't exist → `build-only`.

**Step 2b — API Backend Detection**:
HTTP client (curl) is always available. Set `RUNTIME_BACKEND = http-client` for this interface. No HARD STOP needed.

**Step 2c — CLI Backend Detection**:
Shell is always available. Set `RUNTIME_BACKEND = process-runner` for this interface. No HARD STOP needed.

**Step 2d — Data-IO Backend Detection**:
Shell is always available. Set `RUNTIME_BACKEND = pipeline-runner` for this interface. No HARD STOP needed.

---

**⛔ Workaround Prohibition** (clarified scope — see [runtime-verification.md](../reference/runtime-verification.md) §5):
- **PROHIBITED**: Raw CDP WebSocket scripts, puppeteer, custom fetch-based CDP calls
- **PERMITTED**: Playwright CLI (`npx playwright test`), HTTP client (curl/supertest), process execution, standard shell commands — these are first-class verification backends, not workarounds

---

**HARD STOP conditions for GUI interface**:

**If `RUNTIME_BACKEND = cli` or `cli-limited` or `mcp`**: No HARD STOP. Display informational message:
- `cli`: `ℹ️ Runtime verification: Playwright CLI (standard path)`
- `cli-limited`: `ℹ️ Runtime verification: Playwright CLI (limited — no test file yet)`
- `mcp`: `ℹ️ Runtime verification: Playwright MCP (accelerator mode)`

**If `RUNTIME_BACKEND = demo-only`**: Display warning, no HARD STOP:
`⚠️ Neither Playwright MCP nor CLI available. Runtime verification limited to demo --ci.`

**If `RUNTIME_BACKEND = build-only`** — run CDP Diagnostic (Electron only), then HARD STOP:

**CDP Diagnostic** (Electron projects only — detected from constitution-seed.md or pre-context.md tech stack):
1. Run `curl -s http://localhost:9222/json/version` (timeout 3s)
2. **If curl succeeds** (returns JSON): CDP is active but Playwright tools are not loaded.
   - Diagnosis: `CDP endpoint is running at localhost:9222. Playwright MCP tools are not loaded in this session.`
   - Likely cause: Claude Code session was started before the app, or MCP is not configured with `--cdp-endpoint`. If Playwright CLI is available, this is not blocking — CLI backend can be used without MCP.
3. **If curl fails** (connection refused / timeout): CDP endpoint is not running.
   - Diagnosis: `CDP endpoint not running.`

**Non-Electron projects**: Skip CDP probe.

Display the diagnostic result (if applicable), then **HARD STOP**:
```
⚠️ No runtime verification backend available for GUI Features.

[If Electron + CDP diagnostic ran]:
  📋 CDP Diagnostic: [diagnosis from above]

How to enable runtime verification:
  Option 1 (Recommended): Install Playwright CLI
    npm install -D @playwright/test && npx playwright install
  Option 2: Configure Playwright MCP (requires session restart to load MCP tools)
    claude mcp add playwright -- npx @playwright/mcp@latest
    For Electron: claude mcp add playwright -- npx @playwright/mcp@latest --cdp-endpoint http://localhost:9222
```
**Use AskUserQuestion**:
- "Install Playwright CLI now" (Recommended) — run `npm install -D @playwright/test && npx playwright install`, re-probe, set RUNTIME_BACKEND
- "Configure Playwright MCP" — requires session restart for MCP tools (see [runtime-verification.md §4](../reference/runtime-verification.md))
- "Continue without UI verification" — proceed, Phase 3 Step 3 runtime verification will use demo --ci only
**If response is empty → re-ask** (per MANDATORY RULE 1)

**For non-GUI interfaces**: No HARD STOP. Display:
`ℹ️ Runtime verification: [backend name] for [interface type]`

**Record the detection result.** Phase 3 will use `RUNTIME_BACKEND` — do NOT re-detect or re-ask.

---

### Phase 1: Execution Verification (BLOCKING)

Run each check and record results. **If any check fails, verification is BLOCKED — do not proceed to Phase 2/3/4.**

1. **Test check**: Detect and execute the project's test command (from `package.json` scripts, `pyproject.toml`, `Makefile`, etc.)
2. **Build check**: Run the build command and confirm no errors
3. **Lint check**: Detect and execute the lint tool per domain detection rules.

   **Step 3a — Check Toolchain state** (from Foundation Gate):
   Read `sdd-state.md` → `## Toolchain` section → Lint row Status:
   - `⚠️ not installed` → **skip lint entirely**. Display:
     `⏭️ Lint: skipped — tool not installed (detected in Foundation Gate). Install [command] to enable.`
     This is NOT a Phase 1 failure. Record lint result as `skipped (not installed)`.
   - `✅ available` → proceed to Step 3b (execute lint)
   - `ℹ️ not configured` → **skip**. Display: `ℹ️ Lint: not configured`. Record as `not configured`.
   - Toolchain section absent (legacy sdd-state.md or Foundation Gate not yet run) → fall through to Step 3b (detect on-the-fly for backward compatibility)

   **Step 3b — Execute lint** (when tool is available or status unknown):
   1. Detect the lint command per `domains/_core.md` § S3b (Lint Tool Detection Rules)
   2. Run the detected lint command
   3. **Distinguish failure types**:
      - **Tool not found** (exit code 127 / "command not found"): This is a **toolchain issue**, NOT a code quality issue.
        Display: `⚠️ Lint: tool not found ([command]). This is a toolchain issue, not a code problem.`
        **Offer auto-install** via AskUserQuestion:
        - "Install now" — run the install command from `domains/_core.md` § S3b (e.g., `npm install --save-dev eslint`). After install, re-run lint. If lint passes → record `✅ available` + `✅ Lint: passed`. If lint finds errors → record `✅ available` + report lint errors as normal Phase 1 failure.
        - "Skip — proceed without lint" — record `⚠️ not installed` in `sdd-state.md` Toolchain. Treat as skipped, do NOT block.
        **If response is empty → re-ask** (per MANDATORY RULE 1).
      - **Lint errors found** (exit code 1 with lint output): This is a **code quality issue**.
        Display: `❌ Lint: [N] errors found`
        This IS a Phase 1 failure — **BLOCKS** per normal rules.
      - **Lint passes** (exit code 0): Display: `✅ Lint: passed`

4. **i18n coverage check** (skip if project has no i18n / translation framework):

   Detect i18n framework: search for `i18next`, `react-intl`, `vue-i18n`, `@angular/localize`, `gettext` in config/package files. If none found → skip entirely.

   **Step 4a — Collect used keys**: Grep source files (`src/**/*.{ts,tsx,js,jsx,vue,svelte}`) for translation call patterns:
   - `t('key')`, `t("key")`, `$t('key')`, `i18n.t('key')`, `useTranslation` + `t('key')`
   - Extract the key strings into a deduplicated list

   **Step 4b — Collect defined keys**: For each locale JSON/YAML file (e.g., `en.json`, `ko.json`, `messages_en.properties`):
   - Extract all key paths (flattened dot-notation for nested JSON)

   **Step 4c — Cross-check**:
   | Check | Severity |
   |-------|----------|
   | Key used in code but missing in ANY locale file | ❌ ERROR — UI will show raw key string |
   | Key in locale A but missing in locale B | ⚠️ WARNING — incomplete translation |
   | Key defined but never used in code | ℹ️ INFO — dead key (not blocking) |

   **Display**:
   ```
   🌐 i18n Coverage:
     Keys used in code: [N]
     Locale files: [list e.g., en.json, ko.json]
     Missing keys (code → locale): [N] ❌
       [key1] — missing in: ko.json
       [key2] — missing in: en.json, ko.json
     Incomplete translations: [N] ⚠️
     Dead keys: [N] ℹ️
   ```

   **Blocking**: Missing keys (code references a key that exists in NO locale file) → Phase 1 FAILURE. Incomplete translations (key in one locale but not another) → ⚠️ WARNING (not blocking, but reported).

**If ANY check fails** (test, build, lint errors, or missing i18n keys), display and STOP:
```
❌ Execution Verification failed for [FID] - [Feature Name]:
  Tests: [PASS/FAIL — pass count/total, failure details]
  Build: [PASS/FAIL — error summary]
  Lint:  [PASS/FAIL/skipped (not installed)/not configured]
  i18n:  [PASS/FAIL/skipped (no i18n) — missing key count]

Fix the failing checks before verification can continue.
Verification is BLOCKED — merge will not be allowed until all checks pass.
⚠️ Source Modification Gate applies — before fixing ANY source file, run the Pre-Fix Classification gate.
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

**Step 1b — Plan Deviation Quick Check**:
Lightweight sanity check to catch structural drift between plan artifacts and implementation:
1. **Entity count**: Count entities in `data-model.md` (or plan.md data model section) → compare to actual model/type/schema files. Flag if actual count differs by ±30% or more.
2. **API/IPC channel count**: Count endpoints/channels in `contracts/` → compare to actual route/handler definitions. Flag if mismatch.
3. **Tasks completion rate**: Read `tasks.md` checkbox states → report completion rate. If uncompleted tasks exist, list them with a note: `⚠️ [N] tasks not marked complete — verify if intentionally deferred or missed.`
4. Report:
   ```
   📋 Plan Deviation Quick Check:
     Entities: plan [N] / actual [N] — ✅ match (or ⚠️ ±[N] drift)
     API channels: plan [N] / actual [N] — ✅ match (or ⚠️ ±[N] drift)
     Tasks: [N]/[total] complete ([%])
   ```
5. Any flag → ⚠️ warning (NOT blocking). Helps reviewer spot gaps before Phase 3.
6. **Skip if**: No data-model.md, no contracts/, or Feature has < 5 tasks (too small to drift)

**Step 1c — Data Dependency Verification** (cross-Feature runtime data):

> Addresses the case where a Feature depends on data from another Feature (e.g., AI model embeddings, shared database entries, cached state) and that data source is not available at verify time.
> Beyond structural type compatibility (Step 1/Step 6) — checks runtime data availability.

1. Read `pre-context.md` → "Functional Enablement Chain" → "Blocked by ←" entries. Identify each cross-Feature data dependency.
2. For each data dependency:
   a. **Structural check** (always — grep-based):
      - Verify the data source exists in code (store, API endpoint, database table/model)
      - Verify the data shape is compatible (per Step 6 Integration Contract verification)
   b. **Runtime data check** (when `RUNTIME_BACKEND` is not `build-only`):
      - Start app (reuse Phase 0 instance if running)
      - Navigate to the screen/endpoint that consumes the data:
        - For GUI: snapshot → check for data elements (list items, table rows, rendered content)
        - For API: curl endpoint → verify response body is not empty/default
        - For CLI: run command → verify output contains expected data
      - **Empty data = WARNING** (not blocking):
        `⚠️ Data dependency: [source Feature] → [this Feature] — runtime data is EMPTY. This may indicate [source Feature] model/service is not running or populated.`
   c. **External model/service check** (if dependency involves AI models, external services):
      - Probe the service endpoint (`curl` with timeout 5s)
      - If unreachable: `⚠️ External dependency [service name] not reachable. SCs depending on it will be classified as user-assisted or external-dep.`
3. Report:
   ```
   📊 Data Dependency Verification for [FID]:
     F001-auth → session store: (code) ✅ (runtime) ✅ data present
     F003-ai → embedding model: (code) ✅ (runtime) ❌ model not responding
       ⚠️ SCs requiring embeddings reclassified to user-assisted
   ```
4. **Result**: ⚠️ warnings (NOT blocking) — prominently displayed in Review. Downstream impact: SCs whose data dependencies are unavailable are reclassified from auto categories to `user-assisted` or `external-dep` in the SC Verification Matrix.
5. **Skip if**: No "Blocked by ←" entries in pre-context.md, or Feature has no cross-Feature dependencies.

**Step 1d — Service Integration Verification** (import graph check):

> Catches "orphaned service" pattern: a service/module is implemented and tested in isolation but never imported by its runtime consumer. Phase 1 (test/build/lint) does not detect orphaned code — tests pass, build succeeds, lint is clean. This step verifies that new services are actually wired into the application.

1. **Scope**: Use `git diff --name-only main...HEAD` to identify files created/modified by this Feature. Filter to service/module files (exclude tests, types, configs):
   - Include: `*.service.ts`, `*.store.ts`, `*.composable.ts`, `*.hook.ts`, `*.provider.ts`, `*Service.ts`, `*Store.ts`, `*Repository.ts`, `*Manager.ts`, `*Helper.ts`, `*Util.ts`
   - Include any file that exports a class or function with `Service`, `Store`, `Repository`, `Manager`, `Provider` in the name
   - Exclude: `*.test.*`, `*.spec.*`, `*.d.ts`, `*.config.*`, `*.mock.*`

2. **For each service/module file**, check import graph:
   ```bash
   # Find all non-test files that import this module
   grep -r "import.*from.*[module-path]" src/ --include="*.ts" --include="*.tsx" --include="*.vue" --include="*.js" --include="*.jsx" \
     | grep -v ".test." | grep -v ".spec." | grep -v "__tests__" | grep -v "__mocks__"
   ```
   - Count non-test consumers (files that import this module)

3. **Classification**:
   - **0 non-test consumers** → `⚠️ WARNING: Orphaned service — [ServiceName] has no runtime consumers`
   - **0 non-test consumers AND plan.md lists this service as consumed by a component/route** → `⚠️ HIGH WARNING: [ServiceName] is planned as runtime dependency of [Consumer] but has 0 imports — likely missing wire-up`
   - **≥1 non-test consumer** → ✅ Service is integrated

4. Report:
   ```
   📊 Service Integration Verification for [FID]:
     KnowledgeChatService: ⚠️ ORPHANED — 0 runtime imports (test-only: knowledge-chat.test.ts)
       → Plan.md: consumed by InputBar.tsx (knowledge base picker)
       → Suggested fix: import KnowledgeChatService in InputBar.tsx
     AssistantStore: ✅ 3 runtime consumers (ChatPanel.tsx, InputBar.tsx, SettingsPanel.tsx)
     ThemeService: ✅ 1 runtime consumer (App.tsx)
   ```
5. **Result**: ⚠️ warnings (NOT blocking) — prominently displayed in Review. Orphaned services are strong indicators of incomplete implementation wiring.
6. **Skip if**: No new service/module files in Feature diff, or Feature is test-only/docs-only.

**Step 1e — Cross-Module API Contract Verification** (intra-Feature boundary check):

> Catches function name mismatches, argument format incompatibilities, and return type mismatches across module boundaries WITHIN the same Feature. Step 3 (Interaction Chain) checks handler names exist. Step 6 checks cross-Feature data shapes. Step 1d checks import existence. But NONE verify that the caller's arguments match the callee's parameters, or that the caller uses the correct function name.
>
> F007 bugs caught by this step: #2 (loadDocument vs loadItem), #8 (select({extensions}) vs select(filters, multiple)), #9 (webUtils.getPathForFile missing).

1. **Identify API boundaries** in the Feature's code (use `git diff --name-only main...HEAD`):
   - **IPC boundaries** (Electron/Tauri): `ipcRenderer.invoke('channel', args)` ↔ `ipcMain.handle('channel', (event, args) => ...)`
   - **Preload bridge**: renderer calls via `window.api.method(args)` ↔ preload exposes `method: (args) => ipcRenderer.invoke(...)`
   - **Service layer**: component imports `ServiceName` and calls `service.method(args)` ↔ service defines `method(params)`
   - **External API**: service constructs URL and sends `fetch(url, {body})` ↔ API expects specific URL format and body schema

2. **For each boundary**, verify contract compatibility:
   ```
   Caller side:                          Callee side:
   ─────────────────────                  ─────────────────────
   Function name match?                   Function/method name exists?
   Argument count match?                  Parameter count matches?
   Argument types compatible?             Parameter types expected?
   Return value used correctly?           Return type documented/typed?
   ```

   **Verification method** (grep + AST-lite):
   - Grep caller file for the call expression → extract function name + argument pattern
   - Grep callee file for the function definition → extract parameter pattern
   - Compare:
     - Function name exact match (case-sensitive)
     - Argument count: caller passes N args, callee expects M params → if N ≠ M: `❌ Argument count mismatch`
     - Argument shape: if caller passes `{extensions: [...]}` but callee expects `(filters, multiple)` → `❌ Argument shape mismatch`

3. **Report**:
   ```
   📊 Cross-Module API Contract Verification for [FID]:
     Renderer → Preload (window.api):
       selectFiles({extensions: ['.pdf']}) ↔ selectFiles(filters, multiple)
       ❌ Argument shape mismatch — caller passes object, callee expects positional args
     Preload → IPC Handler:
       invoke('kb:loadDocument', path) ↔ handle('kb:loadItem', (event, path))
       ❌ Channel name mismatch — 'kb:loadDocument' vs 'kb:loadItem'
     KBService → EmbeddingService:
       embed(text, model) ↔ embed(text, options)
       ⚠️ Second argument shape may differ (string vs object)
     EmbeddingService → External API:
       POST /embeddings ↔ API expects /v1/embeddings
       ❌ URL path mismatch
   ```

4. **Result classification**:
   - Function/channel name mismatch → `❌ HIGH WARNING` — will cause runtime TypeError or "no handler" error
   - Argument count/shape mismatch → `❌ HIGH WARNING` — will cause undefined parameters or wrong behavior
   - URL path mismatch → `⚠️ WARNING` — will cause 404 at runtime
   - All contracts match → `✅ API contracts verified`
5. **Result**: ⚠️ warnings (NOT blocking) — prominently displayed in Review. Contract mismatches are strong indicators of integration bugs.
6. **Skip if**: Feature has no cross-module boundaries (single-file Feature, pure UI component, or utility library).

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
   - **Migration-strategy-aware coverage** (read `migration_strategy` from sdd-state.md Rebuild Configuration):
     - `big-bang`: P1 coverage must be 100% across ALL Features before first merge. If any P1 is uncovered in ANY Feature, escalate to ⚠️ HIGH WARNING
     - `incremental` / `strangler-fig`: P1 coverage required for current Feature only. Cross-Feature P1 coverage tracked but not blocking per-Feature
6. If no Source Behavior Inventory exists (greenfield/add), skip this step

**Step 3 — Interaction Chain Completeness** (UI Features with Interaction Chains in plan.md):

If `plan.md` contains an `## Interaction Chains` section:

1. Parse each row: FR | User Action | **Handler** | **Store Mutation** | **DOM Effect** | Visual Result | Verify Method
2. For each chain, verify the key implementation steps exist in the Feature's code (use `git diff --name-only` to scope to changed files):
   - **Handler**: grep for the function name (e.g., `onThemeChange`, `handleFontSize`)
   - **Store Mutation**: grep for the store field assignment (e.g., `settings.theme`, `setTheme`, `theme =`)
   - **DOM Effect**: grep for the DOM manipulation (e.g., `classList.add`, `classList.toggle`, `style.fontSize`)
3. Report (tag each check `(code)` for grep-based, `(runtime)` for MCP/Playwright-verified):
   ```
   📊 Interaction Chain Completeness (code):
     FR-012 (theme toggle): Handler ✅ → Store ✅ → DOM ✅ — Full chain
     FR-015 (font size):    Handler ✅ → Store ✅ → DOM ❌ — Chain broken at DOM Effect
       ⚠️ Store mutation `settings.fontSize` found, but no corresponding `style.fontSize` assignment
   ```
4. **Async-flow rows**: If Interaction Chains contain `async-flow:` rows, additionally verify:
   - **Loading state**: grep for loading state management (e.g., `loading = true`, `setLoading`, `isLoading`)
   - **Error recovery**: grep for error handler + UI recovery (e.g., `catch`, `onError`, error state → enabled input)
   - **Cleanup**: grep for subscription/listener cleanup (e.g., `unsubscribe`, `abort`, `removeEventListener`, `cleanup`)
5. Broken chains → ⚠️ warning (NOT blocking) — but highlighted in Review as likely runtime failure
6. **Skip if**: No Interaction Chains section in plan.md, or Feature is backend-only

**Step 3b — UX Behavior Contract Verification** (UI Features with UX Behavior Contract in plan.md):

If `plan.md` contains a `## UX Behavior Contract` section:

1. Parse each row: Scenario | Expected Behavior | Failure Behavior | Verify Method
2. For each scenario, verify the implementation exists:
   - **Code check** (grep-based, no MCP needed):
     - Scroll behavior: grep for `scrollTop`, `scrollIntoView`, `scrollTo` in Feature's UI files
     - Loading states: grep for loading/spinner state management
     - Error recovery: grep for error state + input re-enable pattern
     - Cleanup on unmount: grep for cleanup in `useEffect` return / `onUnmounted` / `componentWillUnmount`
   - **Runtime check** (if MCP or Playwright CLI available):
     - Execute the Verify Method from the contract row (same verb syntax as Interaction Chains)
3. Report (each check tagged `(code)` or `(runtime)` to distinguish verification depth):
   ```
   📋 UX Behavior Contract Verification:
     Streaming auto-scroll:  (code) ✅ scrollIntoView found | (runtime) ✅ verify-scroll passed
     Loading state:          (code) ✅ isLoading state found | (runtime) ✅ wait-for .spinner passed
     Error recovery:         (code) ✅ error handler found   | (runtime) ⬜ requires API error — skip
     Cleanup on unmount:     (code) ❌ no cleanup in useEffect return
       ⚠️ Missing cleanup may cause memory leak or "setState on unmounted component" warning
   ```
4. Missing implementations → ⚠️ warning (NOT blocking) — but highlighted in Review
5. **Skip if**: No UX Behavior Contract in plan.md, or Feature is backend-only / sync-only UI

**Step 4 — Enablement Interface Smoke Test** (if Functional Enablement Chain exists):

If `pre-context.md` contains a "Functional Enablement Chain" section with "Enables →" entries:

> This Feature provides runtime interfaces that downstream Features depend on.
> Verify these interfaces actually work BEFORE downstream Features are built.

1. Parse "Enables →" rows: Target Feature | Functional Dependency | Failure Impact
2. For each enablement interface:
   a. **Code existence check** (always — no MCP needed):
      - Grep for the interface (function, component, API endpoint) in the Feature's code
      - If not found → ❌ "Enablement interface not implemented"
   b. **Runtime smoke test** (if MCP or Playwright CLI available):
      - Navigate to the relevant screen and verify the interface element is visible/interactive
      - For API endpoints: `curl` the endpoint and verify non-error response
3. Report (each check tagged `(code)` or `(runtime)` to distinguish verification depth):
   ```
   🔗 Enablement Interface Smoke Test:
     Enables → F005-chat: Provider settings panel
       (code) ✅ SettingsPanel component exists
       (runtime) ✅ /settings renders, provider dropdown visible
     Enables → F006-export: Export API endpoint
       (code) ✅ /api/export handler exists
       (runtime) ✅ curl /api/export → 200 OK
   ```
4. **Failed enablement** → ⚠️ **HIGH warning** — downstream Features will likely fail
   Display: `⚠️ Enablement interface for [target] not working — [target Feature] will be blocked at runtime`
5. **Skip if**: No "Enables →" entries in Functional Enablement Chain

**Also check "Blocked by ←" entries** (this Feature's prerequisites):
1. For each "Blocked by ←" row, check if the source Feature has verify status = `success` in sdd-state.md
2. If source Feature is NOT verified: display warning:
   `⚠️ Blocked by F00N-[feature] which has NOT passed verify yet. This Feature's runtime may be affected.`
3. If source Feature IS verified AND app is running: run source Feature's demo in `--ci` mode to confirm it still works
   - If demo fails → ⚠️ warning: `Source Feature F00N-[feature] demo --ci failed — may affect this Feature`

**Step 5 — API Compatibility Matrix Verification** (if plan.md has API Compatibility Matrix):

If `plan.md` contains an `## API Compatibility Matrix` section with 2+ providers:

1. For each provider row in the matrix, verify the implementation handles provider-specific details:
   - **Auth method**: grep for each provider's auth pattern (e.g., `Bearer`, `x-api-key`, `anthropic-version`)
   - **Endpoint URLs**: grep for each provider's base URL or endpoint paths
   - **Response parsing**: grep for each provider's response format (e.g., `choices[0].message`, `content[0].text`)
2. Report:
   ```
   📊 API Compatibility Matrix Verification:
     OpenAI:    Auth ✅ (Bearer found) | Endpoint ✅ | Response ✅
     Anthropic: Auth ✅ (x-api-key found) | Endpoint ✅ | Response ❌ — using OpenAI response format
       ⚠️ Response parsing uses choices[0].message but Anthropic returns content[0].text
     Ollama:    Auth ✅ (no-auth) | Endpoint ✅ | Response ✅
   ```
3. Provider-specific mismatch → ⚠️ **HIGH warning** — will cause runtime auth/parsing failures
4. **Skip if**: No API Compatibility Matrix in plan.md, or < 2 providers

**Step 6 — Integration Contract Data Shape Verification** (if plan.md has Integration Contracts):

> **Skip if**: No `## Integration Contracts` section in plan.md, or no Functional Enablement Chain entries.

Verifies that the data shape contracts defined in plan.md are actually implemented with compatible types and that required bridges exist.

1. Read `SPEC_PATH/[NNN-feature]/plan.md` → `## Integration Contracts` section
2. For each row in the contracts table:
   a. **Interface existence check**: Grep for the Interface (function/API/store method) in the Feature's code
      - If not found → ❌ "Integration interface not implemented"
   b. **Shape compatibility check**: Read the actual type/interface definition from source code
      - Compare the implemented return type/parameter type against the documented Provider/Consumer Shape
      - Check field names, nesting structure, and type compatibility
      - If shapes are structurally incompatible → ❌ "Shape mismatch"
   c. **Bridge implementation check** (if Bridge column specifies an adapter/transform):
      - Grep for the bridge function/adapter in the Feature's code
      - If Bridge is specified but code not found → ❌ "Bridge adapter NOT FOUND"
      - If Bridge is `—` (shapes directly compatible): skip bridge check
3. Report (each check tagged `(code)` or `(runtime)` to distinguish verification depth):
   ```
   🔗 Integration Contract Verification:
     Provides → F005-chat: getActiveTools()
       (code) Interface: ✅ found in src/stores/mcp-store.ts
       (code) Shape: ✅ returns Tool[] matching consumer expectation
     Consumes ← F003-chat-core: ParameterBuilder.build(assistant)
       (code) Interface: ✅ found in src/services/parameter-builder.ts
       (code) Consumer expects: {mcpMode, mcpServers}
       (code) Bridge: ❌ mapMCPStoreToAssistant() NOT FOUND
       ⚠️ No adapter transforms useMCPStore state → assistant.mcpServers format
   ```
4. **Result classification**:
   - Missing interface → ⚠️ **HIGH warning** (enablement interface not implemented)
   - Shape mismatch → ⚠️ **HIGH warning** (will cause runtime TypeError or undefined access)
   - Missing bridge → ⚠️ **HIGH warning** (data will not flow between Features)
   - All checks pass → ✅ Integration contracts verified
5. **If Integration Contracts section missing in plan.md** but Feature has Enablement Chain:
   Display: `⚠️ Integration Contracts not defined in plan.md — cross-Feature data shape compatibility not verified. Consider running /smart-sdd plan [FID] to add contracts.`

### Phase 3: Demo-Ready Verification (BLOCKING — only if VI. Demo-Ready Delivery is in the constitution)

> **Interface conditional**: Phase 3 UI verification only executes when `gui` is in the active Interfaces (from sdd-state.md Domain Profile).
> For pure API/CLI/data-io projects, skip Phase 3 entirely and proceed to Phase 3b.

> **If VI. Demo-Ready Delivery is NOT in the constitution**: Skip this phase entirely.
> Demo standards referenced in this phase are defined in [reference/demo-standard.md](../reference/demo-standard.md).
> **quickstart.md reference**: If `specs/{NNN-feature}/quickstart.md` exists, use it as the authoritative source for how the Feature should be launched and verified. The demo script must follow quickstart.md's run instructions.

**⚠️ Phase 3 has 10 mandatory steps + Phase 3b. Do NOT skip any step or jump directly to demo execution.**

```
Phase 3 Checklist (must complete ALL in order):
  □ Step 0: SC Verification Planning (classify ALL SCs from spec.md — extended categories)
  □ Step 1: Demo script exists and is executable
  □ Step 2: Demo launches the real Feature
  □ Step 3: UI Verification via Playwright (CLI = standard, MCP = accelerator)  ← MANDATORY, not optional
  □ Step 3b: Visual Fidelity Check (rebuild mode only)
  □ Step 3c: Navigation Transition Sanity Check (GUI only)
  □ Step 3d: Interactive Runtime Verification (all interfaces — core runtime check)
  □ Step 3e: Source App Comparative Verification (rebuild mode only)
  □ Step 4: Coverage mapping and demo components
  □ Step 5: CI/Interactive path convergence
  □ Step 6: Execute demo --ci
  □ Step 6b: Execute VERIFY_STEPS (functional verification)
  □ Phase 3b: Bug Prevention Verification (includes Empty State ≠ PASS)
```

**Step 0 — SC Verification Planning** (classify ALL SCs — not just those in demo Coverage header):

Phase 3 Steps 3/6b currently only verify SCs mapped in the demo script's Coverage header. If coverage is low, most SCs get no runtime verification. This step ensures ALL SCs are classified and tracked.

1. Read `SPEC_PATH/[NNN-feature]/spec.md` → extract ALL SC-### items
2. For each SC, classify the verification method:

| Category | Criteria | Where Verified |
|----------|----------|---------------|
| `cdp-auto` | UI interaction with no external dependency (GUI Features) | Step 3/3d — Playwright MCP or CLI |
| `api-auto` | API endpoint test with no external dependency (http-api Features) | Step 3d — HTTP client |
| `cli-auto` | CLI command test with no external dependency (cli Features) | Step 3d — Process runner |
| `pipeline-auto` | Pipeline test with sample data (data-io Features) | Step 3d — Pipeline runner |
| `test-covered` | Behavior already verified by unit/integration tests in Phase 1 | Reference passing test name |
| `user-assisted` | Automatable AFTER user provides a dependency (API key, local service, config) | Step 3d — after user cooperation (see [user-cooperation-protocol.md](../reference/user-cooperation-protocol.md) §3) |
| `external-dep` | Truly inaccessible — production-only API, specific hardware, rate-limited service | Skip with explicit reason |
| `manual` | Requires visual/subjective judgment that automation cannot evaluate | Skip as manual-only |

   > **`user-assisted` vs `external-dep`**: If the user CAN provide the dependency locally (API key in .env, start a local service, test credentials), classify as `user-assisted`. If truly inaccessible (production-only, hardware, rate-limited quota), classify as `external-dep`. See [user-cooperation-protocol.md](../reference/user-cooperation-protocol.md) §3.

   > **SC Decomposition Rule**: When a single SC contains BOTH auto-verifiable steps AND user-dependent steps, SPLIT into sub-SCs at classification time:
   > - `SC-NNNa` (auto category): The portion that can be verified without external dependencies (UI interaction, state mutation, local data)
   > - `SC-NNNb` (`user-assisted`): The portion that requires user-provided dependency (API key, external service)
   >
   > **When to split**: SC description contains a multi-step flow where early steps are local (no external dependency) but later steps require an external service.
   > **When NOT to split**: The external dependency is needed from the first step (e.g., "login via OAuth" — cannot start without OAuth provider).
   >
   > Example: SC-007 "Knowledge base search integrates into chat with citations"
   > → SC-007a (`cdp-auto`): KB button click → picker opens → select KB → `assistant.knowledge_bases` updated in store
   > → SC-007b (`user-assisted`): Chat with KB attached → RAG injection → citation block rendered (requires API key)
   >
   > Sub-SCs appear as separate rows in the SC Verification Matrix and are verified independently: SC-007a in Step 3/3d (auto), SC-007b in Step 3d (after user cooperation) + Step 3f gate.

3. **Verification boundary** — what each runtime backend can automate (see [runtime-verification.md](../reference/runtime-verification.md) §6 for full protocols):

   **GUI (Playwright MCP/CLI)**:
   - ✅ CAN: Navigate pages, click buttons/links, fill forms, select options
   - ✅ CAN: Check element visibility, text content, attributes, CSS classes
   - ✅ CAN: Read console logs, detect JS errors, take screenshots
   - ✅ CAN: Interact with local/built-in functionality (in-memory data, local storage, static UI)
   - ⚠️ LIMITED: IPC calls (Electron main process) — verify indirectly via UI state changes after action
   - ❌ CANNOT: Provide API keys or authentication credentials
   - ❌ CANNOT: Start external server processes or connect to remote services
   - ❌ CANNOT: Evaluate subjective quality (design aesthetics, UX feel)

   **HTTP-API (curl/supertest)**:
   - ✅ CAN: Send requests, verify status codes, check response body shape
   - ✅ CAN: Test mutation side effects (POST then GET to verify)
   - ✅ CAN: Test auth-protected endpoints (401 without auth, 200 with)
   - ❌ CANNOT: Provide API keys or credentials for external services

   **CLI (process runner)**:
   - ✅ CAN: Execute commands, capture stdout/stderr/exit code
   - ✅ CAN: Test error handling (invalid args → non-zero exit + helpful message)

   **Data-IO (pipeline runner)**:
   - ✅ CAN: Run pipeline with test data, compare output schema and values
   - ✅ CAN: Verify no error logs during execution

4. Write the SC Verification Matrix (sub-SCs from Decomposition Rule appear as separate rows):
   ```
   SC Verification Matrix for [FID]:
   | SC | Category | Planned Method | Skip Reason |
   |----|----------|---------------|-------------|
   | SC-022 | cdp-auto | Navigate settings → add server → verify status | — |
   | SC-023a | cdp-auto | Navigate settings → open tool panel → verify tool list renders | — |
   | SC-023b | user-assisted | Execute tool → verify response | Requires OPENAI_API_KEY in .env |
   | SC-024 | cdp-auto | Enable built-in server → verify tool list loads | — |
   | SC-028 | api-auto | GET /api/config → verify 200 + response shape | — |
   | SC-031 | external-dep | — | Requires production MCP server (not locally available) |
   ```

5. **SC Minimum Depth Rule**: After classification, check each auto-category SC (`cdp-auto`, `api-auto`, `cli-auto`, `pipeline-auto`) for verification depth and assign a **Required Depth**:
   - Tier 1 (Presence): Element/response exists — `verify .settings-panel visible`
   - Tier 2 (State Change): Interaction produces expected state — `click toggle → verify-state .theme "dark"`
   - Tier 3 (Side Effect): State change propagates downstream — `verify-effect body class "dark-mode"`

   **Depth Assignment Rules**:
   - **Pure presence SC** (description uses "should be visible", "should exist", "should show", "should render"): Required Depth = Tier 1. Tier 1 is sufficient.
   - **Behavioral SC** (description uses "should change", "should update", "should display after", "should respond with", "should save", "should select", "should toggle", "should open", "should close"): Required Depth = **Tier 2 MANDATORY**. Agent MUST plan verification that includes a state change, not just presence.
   - **Flow SC** (description implies multi-step flow with downstream effects, e.g., "should update and reflect in..."): Required Depth = Tier 3 recommended, Tier 2 minimum.

   If an SC's planned verification is ONLY Tier 1 (presence) but Required Depth is Tier 2: `⚠️ SC-### verification is presence-only but SC requires behavioral verification — upgrading to Tier 2`. Agent MUST auto-upgrade to Tier 2. Record the Required Depth in the SC Verification Matrix for enforcement in Step 3d.

   Add `Required Depth` column to SC Verification Matrix:
   ```
   | SC | Category | Planned Method | Required Depth | Skip Reason |
   |----|----------|---------------|----------------|-------------|
   | SC-022 | cdp-auto | Navigate settings → add server → verify status | Tier 2 | — |
   | SC-023a | cdp-auto | Navigate settings → open tool panel → verify list | Tier 2 | — |
   | SC-024 | cdp-auto | Enable built-in server → verify tool list loads | Tier 1 | — |
   ```

6. **Coverage assessment**:
   - Auto-verifiable (`cdp-auto` + `api-auto` + `cli-auto` + `pipeline-auto`): [N] SCs → will be verified in Step 3/3d
   - User-assisted: [N] SCs → will be verified in Step 3d after user cooperation (gate enforced in Step 3f)
   - Test-covered: [N] SCs → already verified in Phase 1
   - External-dep: [N] SCs → skipped with explicit reason
   - Manual: [N] SCs → skipped
   - **Effective coverage**: (auto + user-assisted + test-covered) / total = [N]%
   - If effective coverage < 50%: display `⚠️ SC verification coverage is [N]% — most SCs cannot be automatically verified for this Feature`

7. **Auto-category SCs drive Step 3/3d/3f**: In Step 3 SC-level UI verification, verify ALL `cdp-auto` SCs — not just those in the demo Coverage header. In Step 3d Interactive Runtime Verification, verify ALL interface-appropriate auto SCs (`api-auto`, `cli-auto`, `pipeline-auto`) plus `user-assisted` SCs (after cooperation). **Step 3f is a mandatory gate** that blocks progression to Step 4 until all `user-assisted` SCs are resolved (verified or explicitly skipped by user via AskUserQuestion).

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

**Step 3 — UI Verification via Playwright** (MANDATORY — do NOT skip):
> **App Session Management**: The agent manages the entire app lifecycle — start, verify, shut down. Do NOT ask the user to start or restart the app manually. The agent starts the app itself (with CDP flags for Electron), runs all SC verifications, then shuts down the app when done.

- **Runtime Degradation Flag Check**: Read sdd-state.md Feature Progress for this Feature. If Detail column shows `⚠️ RUNTIME-DEGRADED`:
  - Display: `⚠️ This Feature was implemented without runtime verification. Runtime bugs (selector instability, layout timing, infinite re-renders) may exist undetected.`
  - If `RUNTIME_BACKEND` is now `mcp`, `cli`, or `cli-limited`: proceed with full UI verification (this is the **recovery path** — extra scrutiny)
  - If `RUNTIME_BACKEND` is STILL `build-only`: **BLOCKING HARD STOP** — this Feature has NEVER had any runtime verification. Use AskUserQuestion:
    - "Install Playwright CLI and retry verify"
    - "Acknowledge NO runtime verification" — requires reason via "Other" input. Sets verify to `limited` status with `⚠️ NEVER-RUNTIME-VERIFIED — [reason]`
  - **If response is empty → re-ask** (per MANDATORY RULE 1)

- **Runtime Backend Check**: Use the `RUNTIME_BACKEND` from the Pre-flight detection (run before Phase 1).
  - If `RUNTIME_BACKEND = build-only` AND user chose "Continue without UI verification": skip to Step 4. Display: `⏭️ UI verification skipped (no runtime backend available — acknowledged in Pre-flight)`
  - If `RUNTIME_BACKEND = demo-only`: skip to Step 6 (demo --ci only). Display: `⏭️ Interactive UI verification skipped — using demo --ci for runtime check.`
  - If `RUNTIME_BACKEND = cli` or `cli-limited`:
    - **Playwright CLI verification (standard path)**: If `demos/verify/F00N-name.spec.ts` exists, run SC verification via CLI:
      1. Ensure app is running (from demo `--ci` or start it)
      2. For Electron: use `_electron.launch()` in test files (no CDP needed)
      3. Run: `npx playwright test demos/verify/F00N-name.spec.ts --reporter=json`
      4. Map test results back to SC-### coverage (Tier 1/2/3 results reported normally)
      5. Display: `ℹ️ SC verification via Playwright CLI (standard path)`
    - If no test file exists and `RUNTIME_BACKEND = cli-limited`: limited to demo --ci only for this Feature.
  - If `RUNTIME_BACKEND = mcp` → **MCP accelerator path**: proceed with Electron CDP check below (if Electron) or directly to SC verification (if web). MCP enables interactive, step-by-step verification without pre-written test files.
  - **If Pre-flight was somehow skipped**: Call `browser_snapshot` NOW. If the tool does not exist, run `npx playwright --version` as fallback. If neither exists, display the HARD STOP from Pre-flight and wait for user response. **Do NOT silently skip.**

- **Electron CDP Configuration Check** (MCP backend only — if project type is Electron AND `RUNTIME_BACKEND = mcp`):
  When using Playwright MCP as the backend, Electron apps require CDP (Chrome DevTools Protocol) for Playwright to connect. Standard Playwright MCP opens a separate Chromium browser and cannot interact with the Electron window.
  > **Note**: This check is SKIPPED when `RUNTIME_BACKEND = cli` or `cli-limited`. CLI mode uses `_electron.launch()` which connects directly to the Electron process without CDP.

  1. **Probe**: Call `browser_snapshot` to check current Playwright MCP configuration. There are FOUR possible outcomes:

     | Probe result | Meaning | Action |
     |---|---|---|
     | Snapshot shows Electron app content | CDP active + app already running | → Proceed directly to SC-level UI verification |
     | Snapshot shows a default new tab / Chrome start page | Standard mode (no `--cdp-endpoint` configured) | → **Case A**: CDP not configured — HARD STOP |
     | Tool call fails with ECONNREFUSED / connection refused | CDP IS configured but app is NOT running on the CDP port | → **Case B**: CDP configured — agent will start the app |
     | Tool call fails with "Target page, context or browser has been closed" or similar runtime error | CDP IS configured, was connected, but target is lost (app crashed/closed) | → **Case B**: Same as above — agent will (re)start the app |

     **CRITICAL**: Do NOT confuse Case B with "standard mode." When Playwright MCP has `--cdp-endpoint` configured but nothing is listening on that port, `browser_snapshot` will fail with a connection error (`ECONNREFUSED`) or "Target closed" error. This means CDP IS set up correctly — the app just needs to be started. **Do NOT use raw CDP/WebSocket scripts as a workaround — follow the Case B protocol.**

  2. **Case A — CDP not configured (standard mode detected)**: This is a **MANDATORY HARD STOP**.
     This is the ONLY case that requires user action — the user must reconfigure Playwright MCP itself.
     Display notice:
     ```
     ⚠️ Electron apps require CDP mode for Playwright MCP to connect.
        Playwright MCP is currently in standard browser mode.

        CDP setup (MCP mode):
        1. claude mcp remove playwright -s user
        2. claude mcp add --scope user playwright -- npx @playwright/mcp@latest --cdp-endpoint http://localhost:9222
        3. Restart Claude Code (ONLY required for MCP — if Playwright CLI is available, consider switching to CLI backend instead)

        Alternative — switch to CLI backend (no restart needed):
        npm install -D @playwright/test && npx playwright install
        CLI uses _electron.launch() and does not need CDP configuration.
     ```
     **Use AskUserQuestion** — this is NOT optional, NOT skippable:
     - "Switch to Playwright CLI backend" (Recommended) — install CLI, re-probe, no restart needed
     - "Retry after CDP configuration" — user configures CDP for MCP, then re-run verify. Session restart ONLY needed if user chose MCP AND CLI is not available
     - "Skip UI verification — health check only" — skip Playwright UI verification, proceed with demo script health check only
     **If response is empty → re-ask** (per MANDATORY RULE 1)
     **NEVER auto-skip this step.** The agent must wait for user's explicit choice.

  3. **Case B — CDP configured, app not running**: No user action needed. The agent starts the app itself.
     **If app was started in Phase 0**: Reuse the running instance — do NOT start a second app. Check if the Phase 0 process is still alive (`kill -0 $PID`), and if so, proceed directly to SC-level UI verification.
     **Otherwise**: Display: `ℹ️ CDP mode confirmed. Starting the app automatically.`
     Proceed to the App Launch step below.

  4. **If CDP active and app already connected**: Skip app launch, proceed directly to SC-level UI verification.

  > **Tip**: If `/reverse-spec` was run with CDP for the same Electron stack, Playwright MCP is already in CDP mode.

- **If MCP available** (MCP accelerator path — and CDP check passed for Electron) — perform App Launch + SC-level UI verification:

  **App Launch** (agent-managed — do NOT ask the user to start/restart the app):
  > **Electron note**: `_electron.launch()` for CLI mode, CDP only for MCP mode.
  1. Detect the project's dev start command from `package.json` scripts or project config (e.g., `npx electron-vite dev`, `npm run dev`)
  2. For Electron with CDP (MCP mode only): Append `-- --remote-debugging-port=9222` to the start command
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
  1. Build the verification target list from TWO sources:
     a. Parse demo script Coverage header → extract FR-###/SC-### + UI Action list
     b. Include ALL `cdp-auto` SCs from Step 0's SC Verification Matrix that are NOT in the Coverage header
     For (b), generate UI Action sequences based on the SC description and spec.md context
  2. Verify each SC-###:
     - ✅-marked SC: Execute UI Action sequence
       - `navigate /path` → move via Navigate capability
       - `fill selector` → input via Type capability
       - `click selector` → click via Click capability
       - `verify selector visible` → confirm element existence via Snapshot capability
       - `wait-for selector visible [timeout]` → wait until element appears (use Playwright `toBeVisible({ timeout })` or MCP poll loop)
       - `wait-for selector gone [timeout]` → wait until element disappears (use Playwright `toBeHidden({ timeout })` or MCP poll loop)
       - `wait-for selector textContent "pattern" [timeout]` → wait until element text matches (use Playwright `toHaveText` or MCP text poll)
       - `verify-scroll selector "bottom"` → evaluate `scrollTop + clientHeight >= scrollHeight - 5` via JavaScript execution
       - `trigger selector event` → dispatch event via JavaScript execution
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

  **Tier 2/3 Functional Verification** (after Tier 1 Presence verification):

  After Tier 1 (`verify selector visible`) completes for each SC, extend verification for SCs that have `verify-state` or `verify-effect` verbs in the Coverage header:

  **Tier 2 — State Change**: For SCs with `verify-state` in their UI Action sequence:
  - Execute the full UI Action sequence (navigate, fill, click) then check the specified attribute/class/text change
  - `verify-state selector attribute expected` → check DOM attribute after interaction
  - Examples: checkbox `checked` attribute, class toggled (`.active`, `.dark`), text content updated, `aria-expanded` changed
  - Wait 1 second between interaction and verification to allow state propagation

  **Tier 3 — Side Effect**: For SCs with `verify-effect` in their UI Action sequence:
  - After Tier 2 passes, check the downstream propagation on a DIFFERENT element
  - `verify-effect target-selector property expected` → check DOM property/style on the downstream target
  - Examples: theme change → `body` class contains `"dark"`, font size change → `body` style.fontSize is `"18px"`, setting save → `.toast` is visible
  - Wait 1 second between interaction and verification

  **Extended result report** (replaces the basic report above when Tier 2/3 are present):
  ```
  📊 UI Verification Report for [FID]:
    SC-001: ✅T1 ✅T2 ✅T3 — Full pass
    SC-002: ✅T1 ❌T2 (click did not toggle .active) — State change failed
    SC-003: ✅T1 ✅T2 ❌T3 (theme not applied to body) — Side effect not propagated
    SC-004: ✅T1 (no T2/T3 — presence-only SC)
    SC-005: ⬜ skipped (WebSocket)
    Console errors: [N] (TypeError: 2, ReferenceError: 1)
  ```

  If no `verify-state` or `verify-effect` verbs exist in any SC's Coverage header, skip Tiers 2/3 entirely and use the basic Tier 1 report format.

  **App Shutdown**: After all SC verifications (including Tier 2/3) complete, terminate the app process started above. Do NOT leave it running.

- **Result classification** (all warnings, NOT blocking):
  - SC Tier 1 (presence) failure: ⚠️ warning (false positive possible — selector changes, etc.)
  - SC Tier 2 (state change) failure: ⚠️ warning — indicates interaction doesn't produce expected state change
  - SC Tier 3 (side effect) failure: ⚠️ warning — indicates state change doesn't propagate to downstream DOM
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
4. **Result severity** varies by `preservation_level` (read from sdd-state.md Rebuild Configuration — see `domains/scenarios/rebuild.md` §S3):
   - `exact`: Visual deviations are ⚠️ HIGH WARNING (pixel-level match expected)
   - `equivalent`: Structural deviations are ⚠️ WARNING; minor spacing/color differences informational
   - `functional`: Visual fidelity check is informational only (UI may be intentionally redesigned)
5. User can acknowledge intentional deviations ("redesigned on purpose") vs. unintentional gaps during Review

If visual references don't exist or no screens match this Feature: skip silently.

**Step 3c — Navigation Transition Sanity Check** (GUI Features only):

> Addresses the case where Feature B adds pages that share layout with Feature A, but the layout breaks on transition (e.g., header height changes, navigation shifts, content area cramped).

**Skip if**: Non-GUI Feature, or this is the first Feature (no prior Feature to transition from), or `RUNTIME_BACKEND` is `build-only` or `demo-only`.

1. **Identify transition points**:
   a. Read this Feature's routes/pages from spec.md or plan.md
   b. Read preceding Features' routes/pages from their demo scripts or spec.md
   c. Identify shared layout elements (header, navigation, sidebar — from constitution-seed.md or plan.md layout section)

2. **Execute transition verification** (when `RUNTIME_BACKEND` supports navigation — `mcp` or `cli`):
   a. Navigate to a preceding Feature's page (e.g., F001's main route)
   b. Snapshot: capture layout state (header height, nav width, content area dimensions)
   c. Navigate to this Feature's page
   d. Snapshot: capture layout state
   e. Compare shared layout elements:
      - Header: same height, same elements visible
      - Navigation: same width, same items (plus this Feature's new items)
      - Content area: proper dimensions within layout

3. **Detect layout regressions**:
   - Header height changed → `⚠️ Header layout inconsistent between [Feature A] and [Feature B] pages`
   - Navigation shifted → `⚠️ Navigation layout changed on transition`
   - Content area cramped/overflowing → `⚠️ Content area dimension mismatch`

4. Report:
   ```
   🔗 Navigation Transition Check:
     F001 /dashboard → F003 /settings: ✅ Layout consistent
     F001 /dashboard → F003 /chat: ⚠️ Header height differs (48px → 64px)
   ```

5. **Result**: ⚠️ warnings (NOT blocking) — highlighted in Review.
6. **Without runtime backend**: Skip with notice: `ℹ️ Navigation transition check requires runtime backend — skipped.`

**Step 3d — Interactive Runtime Verification** (all interfaces):

> The core fix for "verify checks code but doesn't run the app." Exercises the Feature's actual runtime behavior using the interface-appropriate backend from Pre-flight detection.
> See [runtime-verification.md](../reference/runtime-verification.md) §6 for full per-interface protocol.

**Skip if**: `RUNTIME_BACKEND = build-only` (no runtime verification possible).

**GUI Features** (`RUNTIME_BACKEND = mcp` or `cli`):
1. Group `cdp-auto` SCs from SC Verification Matrix by user flow (from spec.md FR grouping)
2. Execute each flow as a complete interaction sequence:
   - Navigate to starting page
   - Perform user actions (click, fill, select) per SC definition
   - Verify intermediate states (Tier 2: state changes)
   - Verify end states (Tier 3: side effects, downstream propagation)
   - Verify NO console errors occurred during the flow
3. This extends Step 3 SC-level verification with flow-level verification — Step 3 verifies individual SCs, Step 3d verifies connected flows

**HTTP-API Features** (`RUNTIME_BACKEND = http-client`):
1. Group `api-auto` SCs by endpoint
2. For each endpoint:
   - Send request with test data (from demo fixtures or spec.md examples)
   - Verify response status code matches SC expectation
   - Verify response body shape (key fields present, correct types)
   - For mutation endpoints: send mutation → verify response → send follow-up GET → verify side effect persists
   - For auth-protected: verify 401 without auth, 200 with auth (if test credentials available)

**CLI Features** (`RUNTIME_BACKEND = process-runner`):
1. Group `cli-auto` SCs by command
2. For each command:
   - Execute with test arguments (from spec.md examples)
   - Capture stdout, stderr, exit code
   - Verify exit code matches expectation
   - Verify stdout matches expected pattern (substring, regex, or JSON shape)
   - Verify error handling (invalid args → non-zero exit + helpful message, not stack trace)

**Data-IO Features** (`RUNTIME_BACKEND = pipeline-runner`):
1. Group `pipeline-auto` SCs by pipeline stage
2. For each stage:
   - Prepare test input data (from demo fixtures)
   - Execute pipeline
   - Compare output: schema match, row/record counts, key value spot checks
   - Verify no error logs during execution

**`user-assisted` SCs** (all interfaces):
> See [user-cooperation-protocol.md](../reference/user-cooperation-protocol.md) §3.
1. Before verifying `user-assisted` SCs, batch ALL user preparation requests into one prompt:
   ```
   📋 User-Assisted Verification for [FID]:
     SC-023: Requires OPENAI_API_KEY in .env
     SC-031: Requires MCP server running on localhost:3001

   Please prepare these dependencies, then confirm.
   ```
2. **Use AskUserQuestion**:
   - "Dependencies ready — proceed with verification"
   - "Skip user-assisted SCs"
   **If response is empty → re-ask** (per MANDATORY RULE 1)
3. If "Dependencies ready": re-verify each dependency (probe API key presence, service endpoint) → run automated verification (same as auto categories)
4. If "Skip": record as `⚠️ user-assisted — skipped`

**Per-SC Depth Tracking** (MANDATORY — enforces SC Minimum Depth Rule from Step 0):

After executing each SC's verification, record the **Reached Depth** and compare against the **Required Depth** from the SC Verification Matrix:
- If Reached Depth ≥ Required Depth → ✅ Depth satisfied
- If Reached Depth < Required Depth → `⚠️ SC-### depth shortfall: required Tier [N] but only reached Tier [M]`
  - For behavioral SCs (Required Depth = Tier 2): This means the agent only confirmed element presence but did NOT verify the state change. **Agent MUST retry with a Tier 2 verification** (perform the action, check state mutation) before marking the SC as verified.
  - If retry still cannot reach Required Depth (e.g., action triggers an error, state mutation path is broken): record as `⚠️ SC-### Tier 2 unreachable — [reason]` in the report. This is a strong indicator of a runtime bug — **do NOT attempt to fix the code inline**. Record the failure and let it surface in Review. If a fix is needed, the Source Modification Gate applies (run Pre-Fix Classification before touching any source file).

**Result report** (appended to SC Verification report):
```
📊 Interactive Runtime Verification for [FID]:
  Flow 1 (Settings → Theme): ✅ All 3 SCs passed (2 state changes, 1 side effect)
    SC-022: ✅ Tier 2 reached (required: Tier 2) — server added, status verified
    SC-023a: ✅ Tier 2 reached (required: Tier 2) — tool panel opened, list rendered
    SC-024: ✅ Tier 1 reached (required: Tier 1) — tool list visible
  Flow 2 (Chat → Send): ⚠️ SC-025 timeout (loading state did not clear within 10s)
    SC-025: ⚠️ Tier 2 unreachable — timeout during state change verification
  API /api/settings: ✅ GET 200, POST 200, invalid POST 422
  user-assisted: 2/3 verified (1 skipped — external API unavailable)

  Depth Compliance: 4/5 SCs met required depth (1 shortfall)
```

**Step 3e — Source App Comparative Verification** (rebuild mode only):

> In rebuild mode, compare the rebuilt app against the original running app for behavioral parity.
> Only when Origin=`rebuild` AND `source_available: running` in sdd-state.md scenario config.
> See [user-cooperation-protocol.md](../reference/user-cooperation-protocol.md) § Source App Access.

**Skip if**: Not rebuild mode, OR `source_available` is not `running`, OR Source Path is N/A.

**Prerequisite**: Source app must be running. Detection:
1. Read Source Path from sdd-state.md
2. Probe source app (curl health endpoint or process check)
3. If not running → User Cooperation Protocol:
   ```
   📋 Source App Comparison requires the original app running.
   Source Path: [path]
   Expected at: http://localhost:[port]
   ```
   **Use AskUserQuestion**:
   - "Source app is running — proceed with comparison"
   - "Skip source comparison"
   **If response is empty → re-ask** (per MANDATORY RULE 1)

**Comparison procedure** (when both apps are running):

Comparison criteria vary by `preservation_level` (read from sdd-state.md Rebuild Configuration — see `domains/scenarios/rebuild.md` §S3):
- `exact`: Byte-level response comparison (API), pixel-level screenshot comparison (UI). Any deviation = ⚠️ WARNING
- `equivalent`: Data shape and semantic comparison. Format differences (JSON key order, whitespace) ignored. Same data values required
- `functional`: Goal-level comparison. Same user flow produces same outcome. UI appearance and API format may differ

1. For each page/route in this Feature:
   a. Navigate to the page in the REBUILT app → Snapshot A
   b. Navigate to the equivalent page in the SOURCE app → Snapshot B (requires separate browser context or port)
   c. Compare (apply criteria above):
      - Layout structure: element positions, container hierarchy
      - Data presentation: same data shape displayed
      - Interaction behavior: same click targets produce same outcomes
2. For API endpoints (if http-api interface):
   a. Send same request to both apps
   b. Compare response status codes and body shapes (apply criteria above)
3. Report:
   ```
   📊 Source App Comparison for [FID]:
     /settings page: ✅ Layout match, ✅ Data match
     /chat page: ⚠️ Layout deviation — sidebar width differs (240px vs 200px)
     GET /api/config: ✅ Response shape match
   ```

**Result**: ⚠️ warnings (NOT blocking). User can acknowledge intentional deviations during Review.

**Note on dual-app management**: The agent manages both apps. Source app port must differ from rebuilt app port. If both are Electron, they need different CDP ports.

**Step 3f — User-Assisted SC Completion Gate** (MANDATORY — cannot skip):

> **Why this separate gate exists**: The `user-assisted` SCs block in Step 3d is a subsection among several auto-category subsections. Agents tend to process the auto categories and skip the user-assisted block entirely. This gate is a safety net that BLOCKS progression to Step 4 until user-assisted SCs are explicitly resolved.

1. **Read SC Verification Matrix from Step 0**: Count SCs classified as `user-assisted`.
2. **If count = 0**: No user-assisted SCs → proceed to Step 4.
3. **If count > 0**: Check whether ALL user-assisted SCs have been resolved (verified ✅ or explicitly skipped via AskUserQuestion in Step 3d).
4. **If any user-assisted SCs remain unresolved** (neither verified nor explicitly skipped by user choice):
   - Batch ALL unresolved user-assisted SCs into one cooperation request:
     ```
     📋 User-Assisted Verification for [FID]:
       SC-023: Requires OPENAI_API_KEY in .env
       SC-031: Requires MCP server running on localhost:3001

     These SCs can be verified if you provide the dependencies above.
     Please prepare them, then confirm — or choose to skip.
     ```
   - **Use AskUserQuestion**:
     - "Dependencies ready — proceed with verification"
     - "Skip user-assisted SCs — record as ⚠️"
     **If response is empty → re-ask** (per MANDATORY RULE 1)
   - If "Dependencies ready": re-verify each dependency (probe API key presence, service endpoint) → run automated verification (same as auto categories)
   - If "Skip": record each as `⚠️ user-assisted — skipped (user chose to skip)`
5. **`external-dep` re-classification check**: Review `external-dep` SCs from Step 0. If any could realistically be provided by the user (API key the user likely has, local service the user can start), reclassify as `user-assisted` and include in the cooperation request above. See [user-cooperation-protocol.md](../reference/user-cooperation-protocol.md) §3 for classification criteria.

> **BLOCKING**: Do NOT proceed to Step 4 until this gate is passed. Marking `user-assisted` SCs as `⚠️` without presenting AskUserQuestion to the user is a protocol violation.

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
- **Browser console error scan (MCP supplement)**: After demo --ci passes the stdout/stderr scan above, if `PLAYWRIGHT_MCP` is `supplement` or `primary` (i.e., MCP tools available in session):
  1. Navigate to the app's main URL (from demo script's "Try it" output or health check URL)
  2. Wait 5 seconds for the page to stabilize
  3. Read browser Console logs for: `TypeError`, `ReferenceError`, `Maximum update depth exceeded`, `unhandled rejection`, infinite render warnings
  4. **If browser console errors detected**: Demo is FAILED even if health endpoint returned 200 and stdout was clean — these are client-side-only bugs (infinite re-renders, selector instability, DOM timing) that never appear in server output
  5. Display: `❌ Browser console errors detected: [N] errors — [first error message]`
  6. If `PLAYWRIGHT_MCP = unavailable`: Skip browser console scan. Display: `ℹ️ Browser console scan skipped (Playwright MCP not available in this session)`

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

**Step 6b — Execute VERIFY_STEPS** (if runtime backend supports interactive verification and VERIFY_STEPS block exists):

After demo `--ci` passes, check for a `# VERIFY_STEPS:` comment block in the demo script:

1. Parse the demo script for a `# VERIFY_STEPS:` comment block (lines starting with `#   ` after `# VERIFY_STEPS:`)
2. If block exists AND `RUNTIME_BACKEND` is `mcp`:
   - Keep the app running (from the demo `--ci --verify` invocation)
   - Execute each step via Playwright MCP using the same verbs as SC-level verification:
     - `navigate /path` → Navigate to URL
     - `click selector` → Click element
     - `fill selector value` → Fill input field
     - `verify selector visible` → Tier 1: confirm element exists
     - `verify-state selector attribute "expected"` → Tier 2: check DOM attribute after interaction
     - `verify-effect target-selector property "expected"` → Tier 3: check downstream DOM propagation
     - `wait-for selector visible [timeout]` → wait until element appears (poll with timeout, default 10s)
     - `wait-for selector gone [timeout]` → wait until element disappears (poll with timeout)
     - `wait-for selector textContent "pattern" [timeout]` → wait until element text matches pattern
     - `verify-scroll selector "bottom"` → evaluate `scrollTop + clientHeight >= scrollHeight - 5` via JavaScript
     - `trigger selector event` → dispatch event via JavaScript execution
   - Wait 1 second between interaction and verification steps (temporal verbs handle their own timeouts)
   - Report per-step results:
     ```
     📊 VERIFY_STEPS Functional Verification:
       Step 1: navigate /settings → ✅
       Step 2: click button#theme-toggle → ✅
       Step 3: verify-state html class "dark" → ❌ (class is still "light")
       Step 4: navigate /settings/display → ✅
       Step 5: fill input#font-size 18 → ✅
       Step 6: verify-effect body style.fontSize "18px" → ✅
       Result: 5/6 passed, 1 failed
     ```
   - `verify-state`/`verify-effect` failures → ⚠️ **warning** (NOT blocking)
3. If VERIFY_STEPS block not found: `ℹ️ Functional verification not configured — VERIFY_STEPS block absent in demo script`
4. If `RUNTIME_BACKEND` is `cli` or `cli-limited` AND `demos/verify/F00N-name.spec.ts` (or `.spec.js`) exists:
   - Ensure app is running (from demo `--ci` execution in Step 6)
   - Run: `npx playwright test demos/verify/F00N-name.spec.ts --reporter=list`
   - Parse test results (pass/fail per test case)
   - Report in same format as MCP-driven VERIFY_STEPS above
   - Display: `ℹ️ Functional verification via Playwright CLI`
5. If `RUNTIME_BACKEND` is `demo-only` or `build-only` AND no test file exists: skip with notice:
   `⚠️ Functional verification skipped — no runtime backend available and no test file (demos/verify/F00N-name.spec.ts)`

**SC Verification Coverage Summary** (after Steps 3 + 6b complete):

Compile the final SC Verification Matrix by combining results from all verification sources:
- Phase 1 tests → `test-covered` SCs
- Step 3 SC-level UI verification → `cdp-auto` SCs (result: ✅/❌/⚠️)
- Step 6b VERIFY_STEPS → functional SCs (result: ✅/❌/⚠️)
- Step 0 classifications → `external-dep` / `manual` SCs (skip reason)

Display:
```
📊 SC Verification Coverage for [FID]:
  Total SCs: [N]
  ✅ Verified (auto + test-covered): [N] ([%])
  ✅ Verified (user-assisted — after cooperation): [N] ([%])
  ⚠️ Skipped — user-assisted (user chose to skip): [N] ([list SC])
  ⚠️ Skipped — external dependency: [N] ([list SC + reason])
  ⚠️ Skipped — manual only: [N]
  ❌ Failed: [N] ([list SC + failure])
  Effective coverage: [verified / total] = [N]%
```

**Coverage gate**:
- Effective coverage ≥ 50%: Proceed normally
- Effective coverage < 50%: Display `⚠️ SC verification coverage is [N]% — most SCs lack runtime verification`. This is a WARNING, not a blocker — but it is prominently displayed in Review for user awareness. If `cdp-auto` SCs exist that were NOT verified (Step 3 skipped due to MCP unavailability), recommend installing MCP.

### Phase 3b: Bug Prevention Verification (B-4)

> Additional checks to automatically verify basic stability of code written during implement.
> Runs after Phase 3 Demo-Ready, before Phase 4 Update.

**Empty State Smoke Test** — "Empty State ≠ PASS":

> Principle: A Feature that renders an empty state without errors is NOT automatically passing.
> If the Feature is supposed to display data and the data area is empty with no intentional
> empty-state message, that is an INCOMPLETE state, not a PASS.

- Start app with all stores/state set to initial (empty) state
- Confirm main screen renders without crashes (Error Boundary not triggered)
- Confirm no critical JS errors in Console (TypeError, ReferenceError, etc.)
- **When runtime backend supports navigation** (`RUNTIME_BACKEND = mcp`): Auto-verify via Navigate → Snapshot
- **Without navigation capability**: Substitute with build + server start success check
- **Data presence check** (NEW):
  - Read spec.md FR-### to identify what data the Feature should display
  - If the Feature manages/displays data (list, table, form with defaults):
    - Check if the data area is populated OR shows an intentional empty state message
    - "No items yet" / "Add your first..." / "No results" / placeholder text = ✅ intentional empty state
    - Blank area with no content and no empty-state indicator = `⚠️ Empty State — data area has no content and no empty-state indicator. Possible missing data source or unimplemented empty state UI.`
  - This check helps catch cross-Feature data dependency issues (e.g., Feature depends on AI model data that isn't populated)

**Smoke Launch Criteria** (basic app stability):
1. Process starts — no immediate exit with non-zero exit code
2. Main screen renders — not a blank page or error screen
3. Error Boundary not triggered — React/Vue/Svelte error boundaries not activated
4. No JS errors — Console free of TypeError, ReferenceError, SyntaxError

**Result classification**: ⚠️ warning (NOT blocking) — results included in Review

---

> **⚠️ Source Modification Gate reminder** — Between Phase 3b and Phase 4 (Global Evolution Update), the pipeline displays Review results to the user. If the user requests fixes based on Review, or if the agent identifies issues to fix before committing results, the **Source Modification Gate MUST be executed** before touching ANY source file. This is the most common point where agents violate the Bug Fix Severity Rule — user feedback triggers a "fix it now" bias that bypasses severity classification. **STOP → List changes → Classify → Aggregate file count → If Major: HARD STOP regression, not inline fix.**

### Phase 4: Global Evolution Update
- entity-registry.md: Verify that the actually implemented entity schemas match the registry; update if discrepancies are found
- api-registry.md: Verify that the actually implemented API contracts match the registry; update if discrepancies are found
- sdd-state.md: Record verification results — **status MUST be one of `success`, `limited`, or `failure`**, plus test pass/fail counts, build result, and verification timestamp. The merge step checks this status as a gate condition.
  - `success`: All phases passed normally
  - `limited`: User acknowledged limited verification in Phase 1 or Phase 3 (⚠️ marker). Merge is allowed with a reminder
  - `failure`: One or more phases failed without acknowledgment. Merge is blocked
