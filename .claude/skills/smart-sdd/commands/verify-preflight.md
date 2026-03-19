# Verify Phase 0 + Pre-flight: Runtime Environment Readiness

> Part of verify-phases.md split. For common gates (Bug Fix Severity, Source Modification Gate), see [verify-phases.md](verify-phases.md).

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
- Record PID in the Verify PID Registry (see Process Lifecycle Protocol above)
- Display: `🚀 Starting Electron app...` (CLI mode) or `🚀 Starting Electron app with CDP on port 9222...` (MCP mode)

**0-2 alt. Start Dev Server** (Web projects):
- Start dev server (from `quickstart.md` or `launch.json`)
- Wait for port readiness (poll health endpoint or port, max 30s)
- Record PID in the Verify PID Registry (see Process Lifecycle Protocol above)
- Display: `🚀 Starting dev server...`

**0-2c. Dev Mode Stability Probe** (GUI projects with distinct dev command):

> Production builds and dev mode follow different code paths — module bundling vs native ESM, static env injection vs runtime loading, pre-compiled vs HMR-driven. Bugs that only manifest under one path (e.g., module-scope side effects that depend on initialization order) are invisible if verify only exercises the other. This probe catches startup-time crashes in the path NOT covered by 0-2/0-2alt.

**Skip if**: No dev command detected, or dev command is identical to the production start path already tested above.

**Detection**: Read the project's script configuration (e.g., `package.json` scripts, `Makefile`, `pyproject.toml`) for a `dev` entry (or `start:dev`, `serve`, etc.). Compare with the production start command used in 0-2/0-2alt. If they invoke different tooling (e.g., `electron-vite dev` vs `electron-vite build && electron .`, or `vite dev` vs `vite build && vite preview`), proceed.

**Procedure**:
1. Run the dev command in background (e.g., `pnpm run dev &`). Record PID.
2. Monitor stderr for ~10 seconds (stability window)
3. **Active survival check**: After the stability window, verify `kill -0 $PID` succeeds. Some crashes (segfault, OOM kill, silent abort) produce no stderr output — the process simply disappears. Passive stderr scanning alone misses these.
4. Scan stderr for crash patterns: `TypeError`, `ReferenceError`, `SyntaxError`, `Uncaught exception`, `Unhandled rejection`, `panic:`, `FATAL`, `segfault`, process exit with non-zero code
5. Kill the dev process (cleanup). Add PID to the Verify PID Registry (see Process Lifecycle Protocol above).
6. **If process gone (kill -0 fails) OR crash pattern detected**: `⚠️ Dev mode startup crash — [error pattern or "process exited silently"]. Production build may mask initialization-order or environment-dependent bugs.`
   - Result: ⚠️ WARNING (NOT blocking) — included in Phase 3b Bug Prevention results
7. **If process alive AND no crash patterns**: `✅ Dev mode startup stable`
8. Display result and continue to 0-3

> **Note**: This probe tests startup stability only — it does NOT replace the full runtime verification in Phase 3, which uses the production build. The purpose is to surface environment-dependent crashes (module-scope side effects, lifecycle-dependent initialization, missing runtime prerequisites) that differ between dev and production code paths.

**0-3. Verify CDP Connection** (Electron only — MCP backend path):
- Skip this step if `RUNTIME_BACKEND = cli` or `cli-limited` (CLI uses `_electron.launch()`, no CDP needed)
- Run `curl -s http://localhost:9222/json/version`
- Retry: 3 attempts, 3s interval
- All fail → HARD STOP: `CDP connection failed after app start. Check app startup logs.`
  Use AskUserQuestion: "Retry" / "Continue without UI verification"
  **If response is empty → re-ask** (per MANDATORY RULE 1)

**0-4. Test State Isolation** (all Features with persistent state):

> Prevents false positive/negative test results caused by state persisted from previous sessions (localStorage, electron-store, SQLite, config files, cookies, etc.).

**Skip if**: Feature has no persistent state (pure stateless API, library, CLI with no config).

Apply ONE of these strategies (in priority order):
1. **Clean user data directory**: Launch the app with an isolated/temporary user data path (e.g., `--user-data-dir=/tmp/verify-clean-{FID}` for Electron, fresh browser profile for web). This guarantees pristine default state
2. **Reset API**: If the app provides a config reset mechanism (IPC `config:reset`, API `POST /reset`, CLI `--factory-reset`), invoke it at verify start before any test execution
3. **State-aware test pattern**: If neither 1 nor 2 is possible, every test scenario MUST follow the **read-before-act** pattern:
   - Read current value first (`const before = await getCurrentTheme()`)
   - Set to the **opposite** of desired test value (ensure a real change happens)
   - Then set to desired value and verify the change
   - Never assume the starting state matches defaults

**Display**: `🧹 Test State Isolation: [strategy used] — [clean data dir | config reset | state-aware tests]`

**0-4b. Feature Reachability Gate** (GUI Features only):

> Prevents "Feature implemented but unreachable" — the Feature's UI exists but no navigation path leads to it from the home screen.

**Skip if**: Feature has no GUI interface, or Feature IS the home/shell Feature (F001-shell, F000-* bootstrap).

1. From the app's home screen (initial state after launch), attempt to navigate to the current Feature's primary screen using **only UI interactions** (click navigation items, menu entries, buttons, icons)
2. **Do NOT use direct URL navigation** (`page.goto('/settings')`) — users don't type URLs in desktop/mobile apps
3. Navigation path sources (check in order):
   a. `interaction-surfaces.md` — if exists, look for entry point mapping for this Feature
   b. `pre-context.md` → Source Reference or SBI — look for navigation hints (e.g., "gear icon in navbar")
   c. Common patterns: sidebar menu, top nav tabs, settings gear icon, user menu dropdown
4. **If reachable** → record navigation path: `✅ Reachable: Home → Sidebar → Settings icon → Settings page`
5. **If NOT reachable** within 3 attempts → **CRITICAL BLOCK**:
   ```
   🚫 Feature Reachability BLOCKED for [FID]:
     No UI path from home screen to [Feature] screen.
     The Feature exists but users cannot access it.
   ```
   → Regression to implement: add navigation entry point (icon, button, menu item) in the appropriate existing UI component

**0-5. Note**: After Phase 0 (including State Isolation and Reachability Gate), the app is running. Pre-flight MCP check (next) can now detect tools correctly.
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
- `cli-limited`: `ℹ️ Runtime verification: Playwright CLI (ad-hoc — no test file, will use inline exploration)`
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
