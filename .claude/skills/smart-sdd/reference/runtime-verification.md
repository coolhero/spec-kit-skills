# Runtime Verification Strategy

> Defines the extensible, interface-aware runtime verification architecture.
> CLI is the primary browser backend. MCP supplements CLI when available (CLI+MCP complementary mode).
> Referenced by: `commands/verify-phases.md` (Pre-flight, Phase 3), `injection/implement.md` (runtime checks + implement-phase browser access), `reverse-spec/commands/analyze.md` (Phase 1.5), domain interface modules (S8).

---

## 1. Runtime Backend Registry

Available verification backends, detection method, and capabilities.

| Backend | Detection | Capability | Priority |
|---------|-----------|------------|----------|
| **Playwright CLI** | `npx playwright --version` → exit 0 | All Playwright capabilities via library mode (`node -e`) or test files (`demos/verify/F00N-name.spec.ts`) | 1 (preferred for gui) |
| **Playwright MCP** | `browser_snapshot` probe → tool exists + returns content | Navigate, Click, Fill, Verify, Wait-for, Snapshot, Console, JavaScript eval (session-persistent browser) | 2 (optional accelerator for gui) |
| **HTTP Client** | `curl --version` → exit 0 (always available) | HTTP request/response, status code, body verification, header inspection | 1 (preferred for http-api) |
| **Process Runner** | Shell availability (always true) | stdin/stdout/stderr capture, exit code, timing, signal handling | 1 (preferred for cli) |
| **Pipeline Runner** | Shell + project config (always true) | Input/output file comparison, schema validation, log inspection | 1 (preferred for data-io) |

---

## 2. Interface-to-Backend Mapping

Maps each interface type (from sdd-state.md Domain Profile → Interfaces) to its runtime verification strategy.

| Interface | Start Method | Verify Method | Stop Method | Primary Backend | Fallback |
|-----------|-------------|---------------|-------------|-----------------|----------|
| **gui (web)** | Dev server: `npm run dev` / launch.json / quickstart.md | Navigate + SC verify + Console check | Kill dev server process | Playwright CLI | Playwright MCP → demo --ci |
| **gui (Electron)** | `_electron.launch()` (CLI) or App with CDP (MCP only) | SC verify + Console check | `app.close()` (CLI) or Kill process (MCP) | Playwright CLI (`_electron`) | Playwright MCP (CDP) → demo --ci |
| **http-api** | Server: `npm start` / quickstart.md / build tool | curl/supertest endpoints, verify status + body | Kill server process | HTTP Client | demo --ci health check |
| **cli** | N/A (per-invocation) | Execute command, capture stdout/stderr/exit code | N/A (process exits) | Process Runner | demo --ci |
| **data-io** | Pipeline prerequisite setup (data fixtures, configs) | Run pipeline with test data, compare output | Cleanup test artifacts | Pipeline Runner | demo --ci |

**Multi-interface projects**: When a project has multiple interfaces (e.g., `gui` + `http-api`), run detection for ALL applicable interfaces. Each Feature's SCs are verified using the backend matching the Feature's primary interface.

**Electron note**: CLI mode uses `_electron.launch()` which connects directly to Electron — no CDP port, no session restart, no `--remote-debugging-port` flag needed. CDP is only required when using Playwright MCP as the backend.

---

## 3. Backend Detection Protocol

### 3a. GUI Backend Detection

Run these steps in order (CLI first, MCP second):

```
1. Probe Playwright CLI (two-phase):
   a. Binary probe: Run `npx playwright --version` (timeout 5s)
      - If fails → PLAYWRIGHT_CLI = unavailable, skip to step 3
   b. Library import probe: Run `cd PROJECT_ROOT && node -e "require('playwright')"` (timeout 5s)
      (PROJECT_ROOT = the directory containing package.json and node_modules)
      - If succeeds → PLAYWRIGHT_CLI = available
      - If fails (ERR_MODULE_NOT_FOUND) → enter Recovery

   Recovery (binary found, library not importable):
   - reverse-spec context: Source project is NOT expected to have playwright.
     → Auto-install in CWD (output directory): `npm i -D @playwright/test`
     → Re-run library import probe from CWD
     → success → PLAYWRIGHT_CLI = available; fail → PLAYWRIGHT_CLI = unavailable
   - smart-sdd context: Target project SHOULD have playwright (installed during setup).
     → Check package.json for `playwright` or `@playwright/test` in devDependencies
     → If missing: `npm i -D @playwright/test` → re-probe
     → If present but probe fails: CWD mismatch — ensure Bash CWD is project root
     → success → PLAYWRIGHT_CLI = available; fail → PLAYWRIGHT_CLI = unavailable

2. Check VERIFY_STEPS test file:
   - Check if `demos/verify/F00N-name.spec.ts` (or equivalent) exists
   - Classify: exists / missing

3. Probe Playwright MCP (always, not optional):
   - Check if `browser_snapshot` tool exists in session tools
   - Classify: active / unavailable
   - **Record as `PLAYWRIGHT_MCP` flag** — this is independent of RUNTIME_BACKEND
```

**Result classification**:

| CLI Status | Test File | MCP Status | RUNTIME_BACKEND | PLAYWRIGHT_MCP | Notes |
|-----------|-----------|------------|-----------------|----------------|-------|
| available | exists | active | `cli` | `supplement` | **Best: CLI automation + MCP supplement** |
| available | exists | unavailable | `cli` | `unavailable` | CLI-only, full verification via test files |
| available | missing | active | `cli-limited` | `supplement` | Library mode + MCP supplement |
| available | missing | unavailable | `cli-limited` | `unavailable` | Library mode only |
| unavailable | — | active | `mcp` | `primary` | MCP as sole backend |
| unavailable | — | unavailable | `demo-only` | `unavailable` | Only demo --ci health check available |
| unavailable | — | unavailable | `build-only` | `unavailable` | No runtime verification at all |

**CLI+MCP complementary mode**: When CLI is primary AND MCP is available, the agent uses CLI for automated verification (headful scripts) and then uses MCP for supplementary tasks that benefit from a session-persistent browser (browser console monitoring, interactive debugging, real-time DOM inspection). This is the **default behavior** — MCP is always probed and used if available, not skipped when CLI exists.

> **"available" means**: `npx playwright --version` succeeds AND `node -e "require('playwright')"` succeeds from the project root. Both conditions must hold. The library import probe ensures that `node -e` scripts (used in implement and verify library mode) can actually load Playwright. If only the binary probe passes, the Recovery step attempts auto-install before classifying as unavailable.

### 3b. HTTP-API Backend Detection

HTTP client (curl) is always available in shell environments.

```
Set RUNTIME_BACKEND = http-client
```

No HARD STOP, no session restart, no MCP dependency.

### 3c. CLI Backend Detection

Shell is always available.

```
Set RUNTIME_BACKEND = process-runner
```

No HARD STOP, no session restart, no MCP dependency.

### 3d. Data-IO Backend Detection

Shell is always available.

```
Set RUNTIME_BACKEND = pipeline-runner
```

No HARD STOP, no session restart, no MCP dependency.

---

## 4. Session Restart Messaging Rules

**CRITICAL**: Session restart is NEVER needed when Playwright CLI is available. CLI is session-independent.

| Condition | Message | Restart Needed? |
|-----------|---------|----------------|
| GUI + CLI + MCP | `ℹ️ CLI+MCP mode: Playwright CLI (primary) + MCP (supplement for console/interactive).` | ❌ No |
| GUI + CLI only | `ℹ️ Using Playwright CLI for runtime verification. MCP not available — console scan will be skipped.` | ❌ No |
| GUI + CLI-limited + MCP | `ℹ️ CLI-limited+MCP mode: library mode + MCP supplement.` | ❌ No |
| GUI + CLI-limited only | `ℹ️ Using Playwright CLI (no test file yet — library mode available).` | ❌ No |
| GUI + RUNTIME_BACKEND = `mcp` | `ℹ️ CLI not available. Using Playwright MCP for runtime verification.` | ❌ No |
| GUI + RUNTIME_BACKEND = `demo-only` | `⚠️ No Playwright backend available. Runtime verification limited to demo --ci.` Offer: "Install Playwright CLI" / "Continue with demo-only" | ❌ No |
| GUI + RUNTIME_BACKEND = `build-only` | `⚠️ No runtime verification backend available.` Offer: "Install Playwright CLI" / "Configure MCP and restart session" / "Continue build-only" | Only if user specifically chooses MCP |
| Non-GUI interface | No message about session restart — EVER | ❌ Never |

**Rule**: If Playwright CLI is available, NEVER recommend session restart. This applies to both web apps and Electron apps (`_electron.launch()` eliminates CDP session ordering issues).

---

## 5. Workaround Prohibition — Clarified

The prohibition targets **unauthorized browser automation tools** that bypass Playwright's infrastructure:

**⛔ PROHIBITED**:
- Raw CDP WebSocket scripts (node scripts using `ws` to connect to CDP directly)
- Direct puppeteer usage (bypassing Playwright)
- Custom fetch-based CDP calls (manual JSON-RPC over HTTP)
- Any browser automation scripts not using Playwright API

**✅ PERMITTED** (first-class verification backends):
- Playwright CLI library mode (`node -e "const { chromium } = require('playwright'); ..."`) — implement-phase ad-hoc checks
- Playwright CLI test runner (`npx playwright test`) — verify-phase SC verification
- Playwright Electron API (`_electron.launch()`) — direct Electron connection without CDP
- Playwright MCP (`browser_snapshot`, `browser_click`, etc.) — GUI verification (accelerator)
- HTTP client tools (`curl`, `supertest`, `httpie`) — API verification
- Process execution (`bash`, shell commands) — CLI verification
- Standard shell commands for data pipeline verification

**Rationale**: The prohibition prevents fragile, unmaintainable browser automation hacks. All Playwright invocation methods (library, test runner, MCP) use the same engine and are equally reliable. `node -e` with Playwright API is first-party Playwright, not a workaround.

---

## 6. Per-Interface Verification Protocol

### 6a. GUI Verification Protocol

**When RUNTIME_BACKEND = `cli`** (primary path):

For **verify** (structured verification):
- Execute `npx playwright test demos/verify/F00N-name.spec.ts --reporter=list`
- Parse test results: pass/fail per test case
- Map test cases back to SC-### identifiers (test names should include SC IDs)
- Report in same format as MCP verification

For **implement** (ad-hoc checks):
- Use library mode scripts (see §7 for patterns)
- Snapshot → check rendering, CSS → check computed values, Console → check errors

**When RUNTIME_BACKEND = `mcp`** (accelerator / sole backend):
- Navigate to Feature pages using `browser_navigate`
- Execute SC actions: click, fill, select via MCP tools
- Verify presence (Tier 1): `browser_snapshot` → check element exists
- Verify state change (Tier 2): action → snapshot → verify attribute/text changed
- Verify side effect (Tier 3): action → verify downstream element/state updated
- Read console logs via `browser_console_messages` → scan for errors

**When RUNTIME_BACKEND = `cli-limited` or `demo-only`**:
- Run `demos/F00N-name.sh --ci` for health check
- Parse stdout/stderr for error patterns
- Limited SC coverage — report what was verifiable

### 6b. HTTP-API Verification Protocol

After server start:
1. For each SC classified as `api-auto`:
   - Execute: `curl -s -w "\n%{http_code}" [method] [endpoint] [-d data] [-H headers]`
   - Verify status code matches SC expectation
   - Verify response body shape (pipe to `jq` for JSON validation)
2. For mutation endpoints (POST/PUT/DELETE):
   - Send mutation request → verify response
   - Send follow-up GET → verify side effect persists
3. For auth-protected endpoints:
   - Without auth → verify 401
   - With valid auth → verify 200 + correct response
4. Error scan: grep server stderr for error patterns (TypeError, unhandled, FATAL)

### 6c. CLI Verification Protocol

For each SC classified as `cli-auto`:
1. Execute command with test arguments (from spec.md examples or demo fixtures)
2. Capture: stdout, stderr, exit code
3. Verify exit code matches expectation (0 for success, non-zero for expected errors)
4. Verify stdout content: substring match, regex match, or JSON shape validation
5. Verify error handling: invalid args → non-zero exit code + helpful error message (not stack trace)

### 6d. Data-IO Verification Protocol

For each SC classified as `pipeline-auto`:
1. Prepare test input data (from demo fixtures directory)
2. Execute pipeline command/script
3. Compare output against expected output:
   - Schema match (column names, types)
   - Row/record count (within ±10% tolerance)
   - Key value spot checks (first row, last row, aggregate values)
4. Verify no error logs during execution (grep stderr for error patterns)
5. Cleanup test artifacts after verification

---

## 7. Implement-Phase Browser Access Protocol (GUI Features)

> During implement, the agent can reference the source app visually and verify
> the built app renders correctly. This resolves the gap where implement only
> had code-level source reference but no runtime visual reference.
> See also: `injection/implement.md` "Source App Visual Reference" section.

### Two CLI Usage Modes

| Mode | Phase | Invocation | Purpose |
|------|-------|-----------|---------|
| **Library mode** | implement | `node -e "const { chromium } = require('playwright'); ..."` | Ad-hoc snapshot, CSS extraction, element check |
| **Test runner mode** | verify | `npx playwright test demos/verify/F00N-name.spec.ts` | Structured SC verification, regression |

Library mode is used during implement because it requires no pre-written test files — the agent composes scripts on-the-fly based on the current task context.

### CLI Script Patterns (Library Mode)

Agents execute these via Bash tool. Each pattern is self-contained and exits cleanly.

**CWD Requirement**: All library mode scripts MUST be executed from the project root directory (where `package.json` and `node_modules/` reside). This ensures `require('playwright')` resolves correctly via Node.js module resolution.

When invoking via Bash tool, always use: `cd PROJECT_ROOT && node -e "..."` (where `PROJECT_ROOT` is the absolute path to the project root, typically CWD or from sdd-state.md).

**Anti-pattern**: NEVER write library mode scripts to temporary files in `/tmp/` and execute them from there. `require()` resolves modules from the script's working directory, not from where the playwright binary is installed globally. Running `node /tmp/my-script.mjs` will fail with `ERR_MODULE_NOT_FOUND` unless `/tmp/node_modules/playwright` exists.

**Headful by default**: All CLI patterns use `chromium.launch({ headless: false })` so the user can see the browser window during exploration and verification. This aids debugging and gives visual confidence that the right pages are being tested. For CI-only contexts where no display is available, the agent may switch to `headless: true`.

**Pattern 1: snapshot(url)** — accessibility tree capture:
```js
node -e "
const { chromium } = require('playwright');
(async () => {
  const b = await chromium.launch({ headless: false });
  const p = await b.newPage();
  await p.goto('URL');
  const snap = await p.accessibility.snapshot();
  console.log(JSON.stringify(snap, null, 2));
  await b.close();
})().catch(e => { console.error(e.message); process.exit(1); });
"
```

**Pattern 2: css-extract(url, selector, properties[])** — computed styles:
```js
node -e "
const { chromium } = require('playwright');
(async () => {
  const b = await chromium.launch({ headless: false });
  const p = await b.newPage();
  await p.goto('URL');
  const styles = await p.evaluate((s) => {
    const el = document.querySelector(s.sel);
    if (!el) return { error: 'selector not found: ' + s.sel };
    const cs = getComputedStyle(el);
    return s.props.reduce((a, k) => ({...a, [k]: cs[k]}), {});
  }, { sel: 'SELECTOR', props: ['color','padding','fontSize'] });
  console.log(JSON.stringify(styles, null, 2));
  await b.close();
})().catch(e => { console.error(e.message); process.exit(1); });
"
```

**Pattern 3: element-check(url, selector)** — existence + attributes:
```js
node -e "
const { chromium } = require('playwright');
(async () => {
  const b = await chromium.launch({ headless: false });
  const p = await b.newPage();
  await p.goto('URL');
  const info = await p.evaluate((sel) => {
    const el = document.querySelector(sel);
    if (!el) return { exists: false };
    return { exists: true, tag: el.tagName, text: el.textContent?.slice(0,100), classes: el.className };
  }, 'SELECTOR');
  console.log(JSON.stringify(info, null, 2));
  await b.close();
})().catch(e => { console.error(e.message); process.exit(1); });
"
```

**Pattern 4: compare(sourceUrl, builtUrl)** — structural diff:
```js
node -e "
const { chromium } = require('playwright');
(async () => {
  const b = await chromium.launch({ headless: false });
  const p = await b.newPage();
  await p.goto('SOURCE_URL');
  const src = await p.accessibility.snapshot();
  await p.goto('BUILT_URL');
  const built = await p.accessibility.snapshot();
  console.log(JSON.stringify({ source: src, built: built }, null, 2));
  await b.close();
})().catch(e => { console.error(e.message); process.exit(1); });
"
```

### Electron Library Mode

For Electron apps, use `_electron.launch()` instead of `chromium.launch()`:

```js
node -e "
const { _electron } = require('playwright');
(async () => {
  const app = await _electron.launch({ args: ['./out/main/index.js'] });
  const win = await app.firstWindow();
  const snap = await win.accessibility.snapshot();
  console.log(JSON.stringify(snap, null, 2));
  await app.close();
})().catch(e => { console.error(e.message); process.exit(1); });
"
```

No CDP port, no MCP configuration, no session restart required.

**Electron Console Noise**: When Playwright's `evaluate()` injects code into an Electron renderer, the Chromium DevTools Console may display an anti-self-XSS warning ("Don't paste code into the DevTools Console that you don't understand..."). This is normal Chromium security behavior triggered by CDP code injection — it does NOT block `evaluate()` execution and is NOT an application error. During console error scans (verify Phase 3), filter out this warning along with other platform noise: `"Electron Security Warning"`, `[DEP0` deprecation notices, and DevTools internal messages. If the user sees this warning while manually inspecting DevTools, inform them it is a Playwright automation artifact, not an app issue.

### Source + Built App Dual Lifecycle (Rebuild Mode)

During implement in rebuild mode, the agent manages two app instances:

```
implement begin (rebuild mode, GUI Feature)
  → Start source app (port A, e.g., project default 3000)
  → [Task 1] CLI snapshot source for reference → Implement → Build → Start built app (port B) → CLI snapshot built app → Compare
  → [Task 2] CLI snapshot source screen → Implement → Build → CLI snapshot built app → Compare
  → ...
  → Review complete → Stop both apps
```

Port convention:
- **Source app**: project's default port (from package.json scripts or launch.json)
- **Built app**: source port + 1000 (e.g., 3000 → 4000) or explicit override in sdd-state.md

### When to Use

| Situation | Action | Required? |
|-----------|--------|-----------|
| Before first UI task (rebuild) | Start source app, CLI snapshot key screens | SHOULD |
| After each UI task (any mode) | Build → CLI snapshot built app → check rendering | MUST (when CLI available) |
| CSS value unclear during coding | CLI css-extract on source app | SHOULD (rebuild) |
| Layout mismatch suspected | CLI compare source vs built | SHOULD |
| Interaction pattern ambiguous | CLI snapshot source after manual interaction | MAY |
| Non-GUI Feature | Skip all browser access | N/A |
| Source app cannot start | Skip source reference, proceed code-only | Log in sdd-state.md |

### Performance Budget

- Max 10 seconds per library mode script
- If script times out, skip and log: `⚠️ CLI script timeout — skipping browser check`
- Do not block implement progress on browser access failures

---

## 8. GUI Verification Execution Detail

> Absorbed from verify-sc-verification.md. This section provides the HOW for GUI SC verification.
> verify-sc-verification.md Step 3 delegates here for GUI-specific execution detail.
> For the WHAT (what to verify, SC classification, depth tracking), see verify-sc-verification.md Steps 0 and 3.

### 8a. Runtime Degradation Flag Check

Read sdd-state.md Feature Progress for this Feature. If Detail column shows `⚠️ RUNTIME-DEGRADED`:
- Display: `⚠️ This Feature was implemented without runtime verification. Runtime bugs (selector instability, layout timing, infinite re-renders) may exist undetected.`
- If `RUNTIME_BACKEND` is now `mcp`, `cli`, or `cli-limited`: proceed with full UI verification (this is the **recovery path** — extra scrutiny)
- If `RUNTIME_BACKEND` is STILL `build-only`: **BLOCKING HARD STOP** — this Feature has NEVER had any runtime verification. Use AskUserQuestion:
  - "Install Playwright CLI and retry verify"
  - "Acknowledge NO runtime verification" — requires reason via "Other" input. Sets verify to `limited` status with `⚠️ NEVER-RUNTIME-VERIFIED — [reason]`
- **If response is empty → re-ask** (per MANDATORY RULE 1)

### 8b. Runtime Backend Check

Use the `RUNTIME_BACKEND` from the Pre-flight detection (run before Phase 1).
- If `RUNTIME_BACKEND = build-only` AND user chose "Continue without UI verification": skip to Step 4. Display: `⏭️ UI verification skipped (no runtime backend available — acknowledged in Pre-flight)`
- If `RUNTIME_BACKEND = demo-only`: skip to Step 6 (demo --ci only). Display: `⏭️ Interactive UI verification skipped — using demo --ci for runtime check.`
- If `RUNTIME_BACKEND = cli` or `cli-limited`:
  - **Playwright CLI verification (standard path)**: If `demos/verify/F00N-name.spec.ts` exists, run SC verification via CLI:
    ```
    npx playwright test demos/verify/F00N-name.spec.ts --reporter=list
    ```
  - If test file does not exist → use library mode (compose `node -e` scripts per SC — see § 7 CLI Script Patterns)
  - **Both modes verify the same SCs** — test file is preferred because it's reproducible; library mode is fallback
- If `RUNTIME_BACKEND = mcp`:
  - Use Playwright MCP tools (`browser_navigate`, `browser_click`, `browser_snapshot`, etc.) for SC verification
  - Navigate to Feature pages, execute SC actions, verify states via snapshots

### 8c. Electron CDP Configuration Check

**Case A — Playwright CLI available** (preferred):
- Use `_electron.launch()` — connects directly to Electron, NO CDP port needed
- No `--remote-debugging-port` flag, no port configuration
- Launch: `_electron.launch({ args: ['./out/main/index.js'] })`
- This eliminates ALL CDP session ordering issues

**Case B — Playwright MCP only** (fallback):
- Electron must be started with `--remote-debugging-port=9222`
- The app must be started BEFORE the MCP session connects
- Start app: modify the dev script or start command to include the CDP flag
- Verify CDP is accessible: `curl -s http://localhost:9222/json/version` → should return JSON
- If CDP is not accessible → see § 9b for recovery

### 8d. App Launch Protocol

> **App Session Management**: The agent manages the entire app lifecycle — start, verify, shut down.
> Do NOT ask the user to start or restart the app manually.

1. Determine app type from sdd-state.md Domain Profile:
   - Web app → start dev server (`npm run dev` / quickstart.md command)
   - Electron app → use `_electron.launch()` (CLI) or start with CDP flag (MCP)
2. Wait for app to be ready:
   - Web: health check on dev server URL (max 30s)
   - Electron: `firstWindow()` resolves (max 30s)
3. If app fails to start → see § 9d for recovery
4. After all verification complete → shut down:
   - Web: kill dev server process
   - Electron CLI: `app.close()`
   - Electron MCP: kill process

### 8e. SC-Level UI Verification Execution

For each `cdp-auto` SC in the SC Verification Matrix:

**Tier 1 — Presence verification**:
- Navigate to the page containing the SC's UI element
- Snapshot → check element exists (by selector, role, or text)
- Record: `✅ Tier 1 — element present` or `❌ Tier 1 — element not found`

**Tier 2 — State change verification**:
- Perform the user action (click button, fill input, toggle switch)
- Wait for DOM update (max 5s)
- Snapshot → check attribute/text/class changed to expected value
- Record: `✅ Tier 2 — state changed to [value]` or `❌ Tier 2 — state unchanged after action`

**Tier 3 — Side effect verification**:
- After action, navigate to or check downstream element
- Verify propagation: did the change reach the target? (different component, storage, API call)
- Record: `✅ Tier 3 — side effect confirmed` or `❌ Tier 3 — side effect not observed`

**Console error scan** (after each SC flow):
- Read console logs for errors that occurred during the flow
- Filter out platform noise (see § 7 Electron Console Noise)
- Any `TypeError`, `ReferenceError`, unhandled rejection → record as `⚠️ Console error during SC-### verification`

### 8f. CSS Theme Token Rendering Check

When the Feature involves theming (dark mode, custom colors, font settings):
1. Identify theme-related SCs from the SC Verification Matrix
2. For each theme SC:
   - Apply the theme change (toggle dark mode, change accent color)
   - Extract computed CSS values for key elements:
     - Background color, text color, border color
     - Font size, font family
   - Verify values match the theme token definitions (from spec.md or design system)
3. Report:
   ```
   🎨 Theme Token Rendering:
     Dark mode background: ✅ #1a1a2e (expected: #1a1a2e)
     Dark mode text: ✅ #e0e0e0 (expected: #e0e0e0)
     Accent color: ⚠️ #007bff (expected: #6366f1) — theme token mismatch
   ```

### 8g. Result Classification

After all GUI SC verification:
- Element not found: `❌ SC-### — element not found (selector: [selector])`
- State not changed: `❌ SC-### — interaction did not produce expected state change`
- Console error during verification: `⚠️ SC-### — console error detected during verification`
- Timeout: `⚠️ SC-### — verification timed out (element/state not ready within 10s)`
- Page load failure: `⚠️ SC-### — page failed to load`
- **UI verification failures do NOT block the overall verify result** — they are included as warnings in Review. However, this does NOT mean UI verification can be skipped without user consent.
- See [ui-testing-integration.md](ui-testing-integration.md) for full guide

---

## 9. Failure Recovery & User Cooperation Integration

> When runtime verification encounters failures, follow this escalation path before giving up.
> All recovery paths that reach "AskUserQuestion" follow the Canonical Flow from
> [user-cooperation-protocol.md](user-cooperation-protocol.md) §2.

### 9a. Playwright Installation Failure Recovery

1. `npx playwright install chromium` fails → check disk space, permissions
2. Still fails → AskUserQuestion: "Playwright installation failed: [error]. Can you install it manually? Run: `npx playwright install chromium`"
3. User confirms installed → re-probe (`npx playwright --version` + library import)
4. User cannot install → fall back to demo --ci only, record as `limited`

### 9b. CDP Connection Failure Recovery (Electron + MCP)

1. CDP port 9222 ECONNREFUSED → app not running, start it
2. CDP port 9222 already in use → `lsof -i :9222` → kill stale process → restart app
3. Still fails → AskUserQuestion: "CDP connection failed. Can you close any other Electron instances?"
4. User confirms → retry
5. All retries fail → fall back to Playwright CLI (`_electron.launch()` — no CDP needed)

### 9c. _electron.launch() Failure Recovery (CLI mode)

1. Launch fails → check if electron binary exists: `npx electron --version`
2. Not found → `npm install electron` → retry
3. Launch fails with "GPU process" → add `--disable-gpu` flag → retry:
   ```js
   _electron.launch({ args: ['./out/main/index.js', '--disable-gpu'] })
   ```
4. Still fails → fall back to MCP (if available) with CDP
5. All fallbacks fail → AskUserQuestion: "Cannot launch Electron programmatically. Can you start the app manually? I'll connect via CDP."
6. User starts app → agent connects via MCP CDP → proceed

### 9d. App Won't Start Recovery

1. Dev server fails → check port in use: `lsof -i :[port]` → kill if stale
2. Build required first → run build → retry dev start
3. Missing dependencies → `npm install` → retry
4. Still fails → AskUserQuestion: "App cannot be started: [error]. Can you start it manually and provide the URL?"
5. User provides URL → agent connects via Playwright navigate

### 9e. User Cooperation Integration

All recovery paths that reach "AskUserQuestion" follow these principles:

1. **Batch all pending requests into ONE prompt** — don't ask multiple times for related dependencies
2. **Provide concrete commands** the user can run (not generic "please fix this")
3. **After user confirms → verify the dependency is actually available** (re-probe, don't trust the claim)
4. **If still not available → provide specific next step**, not generic retry
5. **Record the recovery path taken** in the SC verification report:
   ```
   Recovery: Playwright CLI failed → MCP fallback → CDP connection established → SC verification via MCP
   ```

**Recovery escalation summary**:

```
GUI Verification Recovery Ladder:
  1. Playwright CLI (_electron.launch / chromium.launch)     ← preferred
  2. Playwright CLI library mode (node -e scripts)           ← no test file
  3. Playwright MCP (browser_* tools via CDP)                ← CLI unavailable
  4. AskUserQuestion (user starts app manually)              ← all auto-start failed
  5. demo --ci only (health check, no interactive verify)    ← no Playwright at all
  6. build-only (no runtime verification)                    ← last resort, requires user ack
```

Each level automatically falls to the next when it fails. The agent MUST attempt all applicable levels before asking the user for help. Jumping directly to "user starts app" when CLI is available is a protocol violation.
