# Runtime Verification Strategy

> Defines the extensible, interface-aware runtime verification architecture.
> Replaces the Playwright-MCP-only pre-flight with a multi-backend detection protocol.
> Referenced by: `commands/verify-phases.md` (Pre-flight, Phase 3), `injection/implement.md` (runtime checks), domain interface modules (S8).

---

## 1. Runtime Backend Registry

Available verification backends, detection method, and capabilities.

| Backend | Detection | Capability | Priority |
|---------|-----------|------------|----------|
| **Playwright MCP** | `browser_snapshot` probe → tool exists + returns content | Navigate, Click, Fill, Verify, Wait-for, Snapshot, Console, JavaScript eval | 1 (preferred for gui) |
| **Playwright CLI** | `npx playwright --version` → exit 0 | All Playwright capabilities via test files (`demos/verify/F00N-name.spec.ts`) | 2 (co-equal for gui) |
| **HTTP Client** | `curl --version` → exit 0 (always available) | HTTP request/response, status code, body verification, header inspection | 1 (preferred for http-api) |
| **Process Runner** | Shell availability (always true) | stdin/stdout/stderr capture, exit code, timing, signal handling | 1 (preferred for cli) |
| **Pipeline Runner** | Shell + project config (always true) | Input/output file comparison, schema validation, log inspection | 1 (preferred for data-io) |

---

## 2. Interface-to-Backend Mapping

Maps each interface type (from sdd-state.md Domain Profile → Interfaces) to its runtime verification strategy.

| Interface | Start Method | Verify Method | Stop Method | Primary Backend | Fallback |
|-----------|-------------|---------------|-------------|-----------------|----------|
| **gui (web)** | Dev server: `npm run dev` / launch.json / quickstart.md | Navigate + SC verify + Console check | Kill dev server process | Playwright MCP | Playwright CLI → demo --ci |
| **gui (Electron)** | App with CDP: `[build-tool] -- --remote-debugging-port=9222` | CDP connect + SC verify + Console check | Kill app process | Playwright MCP (CDP) | Playwright CLI → demo --ci |
| **http-api** | Server: `npm start` / quickstart.md / build tool | curl/supertest endpoints, verify status + body | Kill server process | HTTP Client | demo --ci health check |
| **cli** | N/A (per-invocation) | Execute command, capture stdout/stderr/exit code | N/A (process exits) | Process Runner | demo --ci |
| **data-io** | Pipeline prerequisite setup (data fixtures, configs) | Run pipeline with test data, compare output | Cleanup test artifacts | Pipeline Runner | demo --ci |

**Multi-interface projects**: When a project has multiple interfaces (e.g., `gui` + `http-api`), run detection for ALL applicable interfaces. Each Feature's SCs are verified using the backend matching the Feature's primary interface.

---

## 3. Backend Detection Protocol

### 3a. GUI Backend Detection

Replaces the MCP-only pre-flight probe. Run these steps in order:

```
1. Probe Playwright MCP:
   - Attempt `browser_snapshot` tool call
   - Classify: active / configured / unavailable (same as current probe)

2. Probe Playwright CLI:
   - Run `npx playwright --version` (timeout 5s)
   - Classify: available / unavailable

3. Check VERIFY_STEPS test file:
   - Check if `demos/verify/F00N-name.spec.ts` (or equivalent) exists
   - Classify: exists / missing
```

**Result classification**:

| MCP Status | CLI Status | Test File | RUNTIME_BACKEND | Notes |
|------------|-----------|-----------|-----------------|-------|
| active | — | — | `mcp` | Best: full interactive verification |
| configured | — | — | `mcp` | MCP works, app not running yet (start in Phase 0/3) |
| unavailable | available | exists | `cli` | Full verification via Playwright test files |
| unavailable | available | missing | `cli-limited` | Can generate test files; SC coverage from demo --ci only until then |
| unavailable | unavailable | — | `demo-only` | Only demo --ci health check available |
| unavailable | unavailable | — | `build-only` | No runtime verification at all (if demo also missing) |

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

**CRITICAL**: "Restart session" is a disruptive recommendation. Only suggest it when truly necessary.

| Condition | Message | Restart Needed? |
|-----------|---------|----------------|
| GUI + RUNTIME_BACKEND = `mcp` | No message needed | ❌ No |
| GUI + RUNTIME_BACKEND = `cli` | `ℹ️ Playwright MCP not available. Using Playwright CLI for runtime verification.` | ❌ No |
| GUI + RUNTIME_BACKEND = `cli-limited` | `ℹ️ Playwright MCP not available. Using Playwright CLI (limited — no test file yet).` | ❌ No |
| GUI + RUNTIME_BACKEND = `demo-only` | `⚠️ Neither Playwright MCP nor CLI available. Runtime verification limited to demo --ci.` Offer: "Install Playwright CLI" / "Continue with demo-only" | ❌ No |
| GUI + RUNTIME_BACKEND = `build-only` | `⚠️ No runtime verification backend available.` Offer: "Install Playwright CLI" / "Configure MCP and restart session" / "Continue build-only" | Only if user specifically chooses MCP |
| GUI + Electron + Case A (CDP not configured) | `⚠️ Electron apps require CDP mode for MCP.` Offer: "Retry after CDP config" / "Use Playwright CLI instead" / "Skip UI verification" | Only if MCP chosen AND CDP needs config |
| Non-GUI interface | No message about session restart — EVER | ❌ Never |

**Rule**: If Playwright CLI is available, NEVER recommend session restart. CLI provides equivalent verification capability without session disruption.

---

## 5. Workaround Prohibition — Clarified

The prohibition targets **unauthorized browser automation tools** that bypass Playwright's test infrastructure:

**⛔ PROHIBITED**:
- Raw CDP WebSocket scripts (node scripts using `ws` to connect to CDP directly)
- Direct puppeteer usage (bypassing Playwright)
- Custom fetch-based CDP calls (manual JSON-RPC over HTTP)
- Any ad-hoc browser automation scripts not using Playwright

**✅ PERMITTED** (first-class verification backends):
- Playwright MCP (`browser_snapshot`, `browser_click`, etc.) — GUI verification
- Playwright CLI (`npx playwright test`) — GUI verification via test files
- HTTP client tools (`curl`, `supertest`, `httpie`) — API verification
- Process execution (`bash`, shell commands) — CLI verification
- Standard shell commands for data pipeline verification

**Rationale**: The prohibition exists to prevent fragile, unmaintainable browser automation hacks. Playwright CLI is Playwright — same engine, same reliability, different invocation method. HTTP clients and shell commands are standard tools for their respective interface types.

---

## 6. Per-Interface Verification Protocol

### 6a. GUI Verification Protocol

**When RUNTIME_BACKEND = `mcp`**:
- Navigate to Feature pages using `browser_navigate`
- Execute SC actions: click, fill, select via MCP tools
- Verify presence (Tier 1): `browser_snapshot` → check element exists
- Verify state change (Tier 2): action → snapshot → verify attribute/text changed
- Verify side effect (Tier 3): action → verify downstream element/state updated
- Read console logs via `browser_console_messages` → scan for errors

**When RUNTIME_BACKEND = `cli`**:
- Execute `npx playwright test demos/verify/F00N-name.spec.ts --reporter=list`
- Parse test results: pass/fail per test case
- Map test cases back to SC-### identifiers (test names should include SC IDs)
- Report in same format as MCP verification

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
