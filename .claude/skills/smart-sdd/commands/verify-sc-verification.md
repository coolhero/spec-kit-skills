# Verify Phase 3 + 3b: Demo-Ready + SC Verification + Bug Prevention

> Part of verify-phases.md split. For common gates (Bug Fix Severity, Source Modification Gate), see [verify-phases.md](verify-phases.md).

---

### Phase 3: Demo-Ready Verification (BLOCKING — only if Demo-Ready Delivery is active)

🚫 **BLOCKING [G2]**: Phase 3 requires a RUNNING application. Before proceeding:
1. Confirm application is running (check health endpoint or process)
2. If not running → start it (`npm run start:dev`, `docker compose up -d`, etc.)
3. If infrastructure missing → ask user to configure (P2: Delegate, Don't Skip)
4. If application cannot start → this is a Phase 1 failure, return to implement

**Phase 3 is NOT unit test execution.** Unit tests run in Phase 1. Phase 3 is RUNTIME verification:
- Start the real server
- Call real endpoints with real (or seed) data
- Verify responses match SC definitions
- Record evidence (HTTP status codes, response bodies, screenshots)

❌ WRONG: "Unit tests cover SC-001 through SC-010 → Phase 3 complete"
✅ RIGHT: "Server running on :3000 → curl POST /auth/login → 200 → SC-001 ✅"

> 🚫 G2: Static ≠ Runtime — Level 3. Interactions produce correct state (functional
> verification via Playwright). Static checks + smoke launch are insufficient — Playwright
> SC verification confirms runtime behavior matches specification.
> See pipeline-integrity-guards.md § Guard 2.

> **Interface conditional**: Phase 3 UI verification only executes when `gui` is in the active Interfaces (from sdd-state.md Domain Profile).
> For pure API/CLI/data-io projects, skip Phase 3 entirely and proceed to Phase 3b.

> **Demo-Ready Delivery is active** when: VI. Demo-Ready Delivery is in the constitution, OR `demos/` directory already contains Feature demo scripts from previous pipeline runs.
> **If Demo-Ready Delivery is NOT active**: Skip this phase entirely.

**Greenfield check**: If Origin = greenfield → skip Phase 3e (Source App Comparative Verification). If Playwright is not available → fall back to code-level SC verification with warning.
> Demo standards referenced in this phase are defined in [reference/demo-standard.md](../reference/demo-standard.md).
> **quickstart.md reference**: If `specs/{NNN-feature}/quickstart.md` exists, use it as the authoritative source for how the Feature should be launched and verified. The demo script must follow quickstart.md's run instructions.

**⚠️ Phase 3 has mandatory steps + Phase 3b. Do NOT skip any step or jump directly to demo execution.**

> **🚫 GUI MANDATORY PLAYWRIGHT GATE** (enforced at Phase 3 entry):
> When `gui` is in the active Interfaces AND `RUNTIME_BACKEND` is not `build-only`:
> Playwright Pre-flight MUST have been completed in verify Phase 0 (see verify-preflight.md).
> If `RUNTIME_BACKEND` was not set → go back and run Pre-flight detection.
> Do NOT proceed with Phase 3 GUI verification without a classified RUNTIME_BACKEND.

Phase 3 Checklist (must complete ALL in order):
  □ Step 0: SC Verification Planning
  □ Step 1: Demo script check
  □ Step 2: Demo launches real Feature
  □ Step 3: Runtime SC Verification (→ runtime-verification.md per interface)
  □ Step 3c: Navigation Transition (GUI only)
  □ Step 3d: Interaction Chain Execution (GUI + plan.md chains)
  □ Step 3e: Demo TEST PLAN Execution
  □ Step 3f: User-Assisted SC Completion Gate
  □ Step 3g: User-Assisted Manual Verification
  □ Step 3-rebuild: Source comparison + Visual fidelity (→ verify-sc-rebuild.md, rebuild only)
  □ Step 4: Coverage mapping + demo components
  □ Step 5: CI/Interactive convergence
  □ Step 6: Demo --ci execution
  □ Step 6b: VERIFY_STEPS execution
  □ Phase 3b: Bug Prevention (B-4)

---

> 🚫 **NO UNIT TEST SUBSTITUTION [G2]**: Every SC MUST be verified at runtime against the running application. "Unit test covers this SC" is NOT acceptable evidence for Phase 3.
>
> If an SC genuinely cannot be verified at runtime (e.g., requires hardware, external paid API with no sandbox):
> 1. Mark it as `RUNTIME_BLOCKED` with specific reason
> 2. Report to user via AskUserQuestion: "SC-007 cannot be runtime-verified because [reason]. Manual verification needed."
> 3. Do NOT silently substitute a unit test and report ✅
>
> ❌ WRONG: "SC-007 (cross-tenant isolation) — unit test ✅"
> ❌ WRONG: "SC-009 (model scope) — skipped, model not registered"
> ✅ RIGHT: "SC-007 — RUNTIME_BLOCKED: requires second Organization in seed data. Asking user to create test org."
> ✅ RIGHT: "SC-009 — RUNTIME_BLOCKED: model 'claude-sonnet-4-20250514' not registered. Asking user to register test model."

#### SC Evidence Standard (🚫 BLOCKING)

Each SC in the verify-report MUST have one of exactly three statuses:

| Status | Meaning | Requirement |
|--------|---------|-------------|
| ✅ PASS | Complete SC behavior verified at runtime | Full end-to-end evidence (request → response matching SC definition) |
| ❌ FAIL | SC behavior does not match at runtime | Failure details + severity classification |
| ⚠️ PARTIAL | Part of SC verified, part blocked | Exact scope of what passed + what's blocked + why + action needed |

🚫 **NEVER report ⚠️ PARTIAL as ✅ PASS.** If any part of the SC's defined behavior was not verified, it is NOT ✅.

Example:
- SC-001: "Valid API Key → POST /v1/chat/completions → 200 + streamed LLM response"
- Auth middleware returns 200 ✅, but LLM Provider returns 400 (no API key configured) ❌
- Correct report: ⚠️ PARTIAL — "Auth layer ✅, LLM call ❌ (Provider API Key not in .env)"
- Wrong report: ✅ — "Authentication verified successfully"

**Step 0 — SC Verification Planning** (classify ALL SCs — not just those in demo Coverage header):

Phase 3 Steps 3/6b currently only verify SCs mapped in the demo script's Coverage header. If coverage is low, most SCs get no runtime verification. This step ensures ALL SCs are classified and tracked.

1. Read `SPEC_PATH/[NNN-feature]/spec.md` → extract ALL SC-### items
2. For each SC, classify the verification method:

| Category | Criteria | Where Verified |
|----------|----------|---------------|
| `cdp-auto` | UI interaction with no external dependency (GUI Features) | Step 3 — Playwright MCP or CLI |
| `api-auto` | API endpoint test with no external dependency (http-api Features) | Step 3 — HTTP client |
| `cli-auto` | CLI command test with no external dependency (cli Features) | Step 3 — Process runner |
| `pipeline-auto` | Pipeline test with sample data (data-io Features) | Step 3 — Pipeline runner |
| `test-covered` | Behavior already verified by unit/integration tests in Phase 1 | Reference passing test name |
| `user-assisted` | Automatable AFTER user provides a dependency (API key, local service, config) | Step 3 — after user cooperation (see [user-cooperation-protocol.md](../reference/user-cooperation-protocol.md) §3) |
| `external-dep` | Truly inaccessible — production-only API, specific hardware, rate-limited service | Skip with explicit reason |
| `os-native` | OS-level interaction that Playwright cannot simulate (drag&drop files, system dialogs, clipboard, tray menu, keyboard shortcuts conflicting with OS) | Step 3f — user performs action, reports result |
| `manual` | Requires visual/subjective judgment that automation cannot evaluate | User-assisted manual verification in Step 3g |

3. Build the **SC Verification Matrix** with **Specific Test Scenarios**:

   For each auto-category SC, derive a step-by-step test scenario from the SC description + plan.md Interaction Chains. Each step must be a concrete Playwright action or assertion — not a vague description.

```
SC Verification Matrix for [FID]:
| SC-### | Category | Depth | Specific Test Scenario |
|--------|----------|-------|----------------------|
| SC-001 | cdp-auto | Tier 2 | 1. Click "Create KB" button  2. Fill name="Test KB"  3. Select embedding model from dropdown  4. Click Create  5. ASSERT: KB appears in list with name "Test KB"  6. ASSERT: status icon shows ready |
| SC-002 | cdp-auto | Tier 3 | 1. Navigate to KB "Test KB"  2. Click "Add file"  3. Upload test.txt  4. ASSERT: file appears with status "processing"  5. Wait for status → "completed"  6. ASSERT: file count = 1 |
| SC-003 | user-assisted | Tier 3 | 1. [user sets API key]  2. Navigate to chat  3. Click KB button → select "Test KB"  4. Send message "what is in the file?"  5. ASSERT: response contains citation badge [1]  6. ASSERT: clicking [1] shows source preview |
| SC-004 | os-native | Tier 2 | 1. [user drags file to KB area]  2. ASSERT: file appears in list  3. ASSERT: status changes to "processing" |
```

   **🚫 VAGUE SCENARIOS ARE REJECTED**:
   ```
   ❌ "Click → verify state change" — what click? what state change?
   ❌ "Navigate KB page → verify" — verify what exactly?
   ❌ "Check button exists" — existence ≠ functionality

   ✅ "Click 'Create KB' → fill name → select model → click Create → ASSERT: KB in list"
   ✅ "Send message with KB attached → ASSERT: response has citation [1] → click [1] → ASSERT: tooltip shows source"
   ```

   **Scenario derivation sources** (in priority order):
   1. **ui-flows.md** (if exists) → Happy Path steps = test scenario. **This is the PRIMARY source for GUI Features.** Each flow step maps directly to a test action + assertion.
   2. spec.md SC description → Given/When/Then extraction
   3. plan.md Interaction Chains → User Action → Handler → DOM Effect → Visual Result
   4. Demo script "Try it" section → manual steps → automate each step
   5. Source app behavior (rebuild mode) → what does the source app do for this SC?

   **Each scenario MUST have**:
   - At least 2 user actions (click, fill, select — NOT just navigate)
   - At least 2 assertions (ASSERT — NOT just "verify" or "check")
   - The assertions must verify the SC's **described behavior**, not just page stability

4. **SC Minimum Depth Rule**: Every `cdp-auto`, `api-auto`, `cli-auto`, `pipeline-auto` SC must have a minimum Required Depth based on the SC's nature:
   - **Presence SCs** (element exists, page renders, data displays): Tier 1 minimum
   - **Behavioral SCs** (click triggers action, form submits, toggle changes state): **Tier 2 minimum** — verifying the element exists (Tier 1) is INSUFFICIENT for behavioral SCs. The interaction must be exercised AND the state change confirmed.
   - **Side-effect SCs** (action in A updates B, save persists across reload): Tier 3 minimum

5. **Semantic Check Classification**: For each SC, determine if it requires semantic verification:
   - **Semantic check needed**: SC verifies _content correctness_ (correct data displayed, correct calculation, correct order) — not just presence
   - **Structural check sufficient**: SC verifies _element existence_ or _type correctness_ (button exists, input accepts text)
   - Record in the matrix — semantic SCs need deeper verification even at Tier 1

6. **Manual Fallback Planning**: For each `cdp-auto` SC, identify the **manual fallback** if Playwright verification fails:
   - Which user action would verify this SC?
   - What should the user look for?
   - This planning prevents "Playwright failed → skip" patterns

7. **Test Environment Alignment**: Check if any SCs require specific test environment state:
   - Database seeded with test data
   - Environment variables set (non-secret)
   - External services mocked
   - Record prerequisites for Step 3 execution

8. **Early Cooperation Overview (🚫 BLOCKING — do NOT defer to Step 3f/3g)**:

   If ANY SC is classified as non-auto (`user-assisted`, `os-native`, `manual`), present the **full cooperation overview** to the user NOW — not later. This gives the user the complete picture of what they'll need to do, and lets them prepare in advance.

   **Display format** — group by timing:
   ```
   📋 User Cooperation Required for [FID] Verification:

   🔑 CONFIGURE NOW (needed before auto-tests can cover these SCs):
     SC-003: Embedding pipeline — requires API key
       → Go to Settings > Model Provider > [provider] > Enter API key
     SC-005: RAG search — requires API key + at least 1 embedded document
       → After API key: create KB, add file, wait for embedding completion

   🖱️ MANUAL ACTIONS (I'll ask you after auto-tests complete):
     SC-004: Drag & drop file to KB area
       → Action: drag a file onto the KB content area
       → Expected: file appears in list, status changes to "processing"
     SC-009: System tray menu
       → Action: right-click system tray icon
       → Expected: menu shows "Show/Hide" and "Quit" options

   👁️ VISUAL JUDGMENT (I'll ask you after auto-tests complete):
     SC-012: Animation smoothness
       → I'll trigger the animation, you judge if it's smooth

   First: please configure the items under "CONFIGURE NOW".
   Auto-tests will run after configuration. Manual items come last.
   ```

   **Use AskUserQuestion**:
   - **"Configuration done — start testing"** → Run ALL auto + user-assisted SCs
   - **"Skip configuration — test what you can"** → Record config-dependent SCs as `⚠️ user-skipped`, run remaining auto SCs
   - **"No manual items needed — skip all"** → Record ALL non-auto as `⚠️ user-skipped`
   **If response is empty → re-ask** (per MANDATORY RULE 1).

   **After auto-tests complete, present manual items one at a time**:
   For each `os-native` or `manual` SC, use AskUserQuestion:
   ```
   🖱️ Manual verification — SC-004: Drag & Drop
     Please drag a file onto the KB content area.
     Expected result: file appears in list, status → "processing"

     What happened?
   ```
   Options: "Works as expected ✅", "Failed — [describe]", "Cannot test right now"

   **🚫 Anti-patterns — ALL are BLOCKING violations**:
   ```
   ❌ Classify as "user-assisted" → never ask → report "⚠️ API key needed"
   ❌ Classify as "os-native" → skip silently → report "⚠️ Playwright limitation"
   ❌ Defer all cooperation to Step 3f/3g → agent skips to Review before reaching them
   ❌ Ask user to configure but don't re-test after configuration

   ✅ Show full cooperation overview at Step 0
   ✅ User configures API key → re-test with real API → PASS/FAIL
   ✅ After auto-tests → ask manual items one by one → record results
   ✅ Every non-auto SC has either user-verified result or explicit user-skip
   ```

   **Why early, not deferred**: Step 3f/3g exist as safety nets, but agents consistently skip to Review
   before reaching them. By presenting the full overview at Step 0, the user knows what's coming,
   can prepare configuration, and the agent has no excuse to skip cooperation.

9. **Coverage Assessment**: Calculate expected coverage:
   - `auto-verifiable` = count(`cdp-auto` + `api-auto` + `cli-auto` + `pipeline-auto` + `test-covered`)
   - `total` = count(all SCs)
   - If `auto-verifiable / total < 50%`: Display `⚠️ Less than 50% of SCs are auto-verifiable. Consider reclassifying some external-dep as user-assisted.`

---

**Step 1 — Check demo script exists** at `demos/F00N-name.sh`:
- Must exist and be executable
- Must include a Coverage header mapping FR-###/SC-### from spec.md

**Step 1b — Demo "Try It" → Test Scenario Cross-Reference** (🚫 BLOCKING):
If the demo script has a "Try it" / "📋 Try it" section with numbered manual steps:
1. Read each manual step from the demo script
2. Map each step to an SC in the SC Verification Matrix
3. For each step that CAN be automated (click, fill, navigate — not drag&drop or visual judgment):
   - The corresponding SC's Specific Test Scenario MUST include this step
   - If missing → add to the scenario
4. **BLOCKING if demo has 5+ manual steps but Matrix has 0 automated equivalents**
   ```
   🚫 Demo script has 12 manual "Try it" steps but SC Matrix automates 0 of them.
   The Matrix scenarios must automate at least the basic CRUD steps from the demo.
   ```

**Step 2 — Demo launches real Feature**:
- The demo must start the actual Feature (not a mock or test-only harness)
- Verify the startup command matches quickstart.md (if exists)
- If the demo is test-only (runs tests but doesn't launch the app): REJECT

---

### 🚫 SC MATRIX GATE (BLOCKING — structural, not trust-based)

Step 3 runtime verification CANNOT begin without the SC Verification Matrix from Step 0. If the Matrix has not been created and displayed, Phase 3 Steps 3/3f are structurally blocked.

**Structural check (L39 principle)**: Before proceeding to Step 3, verify the SC Verification Matrix exists by counting:
- **SC count**: How many SCs are in the Matrix? Must be > 0. If 0 → Step 0 was skipped.
- **Category distribution**: How many `cdp-auto`, `user-assisted`, `os-native`, `external-dep`? If ALL are `cdp-auto` → classification was likely skipped (real projects have mixed categories).
- **Required Depth column**: Does it exist? If absent → Step 0 item 5 (SC Minimum Depth Rule) was skipped.

If ANY structural check fails → **return to Step 0 and create the Matrix now**. Display: `"🚫 SC Verification Matrix missing or incomplete. Returning to Step 0."`

**Why this matters (SKF-053)**: Without the Matrix, no SCs are classified as `user-assisted` or `os-native`, so Step 3f (User-Assisted SC Completion Gate) never triggers. The agent treats everything as `cdp-auto`, runs shallow Tier 1 tests, and declares "all pass." The Matrix is the foundation for the entire Phase 3 execution.

---

**Step 3 — Runtime SC Verification** (MANDATORY):

Execute SC verification using the interface-appropriate backend. Read the verification protocol for your interface from [runtime-verification.md](../reference/runtime-verification.md):

| Interface | Protocol | Backend |
|-----------|----------|---------|
| GUI | § 6a GUI Verification Protocol + § 8 GUI Execution Detail | Playwright CLI (primary) or MCP (supplement) |
| HTTP-API | § 6b HTTP-API Verification Protocol | curl/supertest |
| CLI | § 6c CLI Verification Protocol | Process runner |
| Data-IO | § 6d Data-IO Verification Protocol | Pipeline runner |

For each SC in the SC Verification Matrix:
1. Identify the category (from Step 0)
2. Read the matching protocol section from runtime-verification.md
3. Execute the verification
4. Record evidence (runtime log, HTTP response, process output)
5. Record Reached Depth vs Required Depth (from Step 0)

**GUI-specific pre-checks** (read from runtime-verification.md § 8 for full detail):
- Runtime Degradation Flag Check (sdd-state.md `⚠️ RUNTIME-DEGRADED`)
- Runtime Backend Check (use `RUNTIME_BACKEND` from Pre-flight)
- For failure recovery during execution, see runtime-verification.md § 9

**HTTP-API Features** (`RUNTIME_BACKEND = http-client`):

> API verification is **fully automatable** — unlike GUI, every check produces deterministic evidence (status code + response body). There is NO excuse for "build passes so verify passes" on API Features.

1. **Server startup + health check**:
   - Start server (background process)
   - Wait for health check (`GET /health` or root endpoint → 200, max 30s)
   - If health check fails → 🚫 BLOCKING (server doesn't start = Feature doesn't work)

2. **Group `api-auto` SCs by endpoint, then execute ALL**:
   For each endpoint:
   - Send request with test data (from demo fixtures or spec.md examples)
   - Verify response status code matches SC expectation
   - Verify response body shape (key fields present, correct types)
   - **Evidence format** (MANDATORY in Review):
     ```
     GET /api/users → 200 [{id:1,name:"test",email:"test@example.com"}] (42ms)
     POST /api/users {name:""} → 422 {errors:[{field:"name",message:"required"}]} (15ms)
     GET /api/users/999 → 404 {error:"Not found"} (8ms)
     ```

3. **CRUD round-trip verification** (for entities with full CRUD):
   - POST (create) → verify 201 + response contains created resource
   - GET (read) → verify 200 + response matches what was created
   - PUT/PATCH (update) → verify 200 + response reflects changes
   - DELETE → verify 204 or 200
   - GET (re-read) → verify 404 (actually deleted)
   - If ANY step fails → the CRUD chain is broken → 🚫 BLOCKING

4. **Auth enforcement verification**:
   - Send request WITHOUT auth token → verify 401 + actionable error message
   - Send request WITH invalid/expired token → verify 401 + specific error
   - Send request WITH valid token → verify 200 + expected response
   - If auth endpoint exists: test login flow → receive token → use token
   - **BLOCKING** if auth-protected endpoint returns 200 without token

5. **Input validation verification**:
   - Send request with missing required fields → verify 400/422 + error specifies which field
   - Send request with wrong types → verify 400/422
   - Send request with boundary values (empty string, max length, negative number)
   - Verify error response format is **consistent** across all endpoints

6. **Error response consistency check**:
   - Collect all error responses from steps 2-5
   - Verify they all use the same envelope format (e.g., `{error, code, message}`)
   - Inconsistent error format = ⚠️ WARNING

7. **Integration Contract verification** (if Feature provides API for other Features):
   - For each "Provides →" in plan.md Integration Contracts:
     - Call the endpoint with the consumer's expected input
     - Verify response contains ALL fields the consumer needs
     - This is NOT just "endpoint returns 200" — it's "response has fields X, Y, Z"

8. **Server cleanup**:
   - Kill server process (graceful SIGTERM first, SIGKILL after 5s)
   - Verify port is released (`lsof -i :PORT` shows nothing)
   - If server process leaks → ⚠️ WARNING (future port conflicts)

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
1. **Check Phase 0-2b status first**: Read Feature Detail Log for `0-2b-configured` flag.
   - If `0-2b-configured: true` → filter out items already configured in Phase 0. Only ask for ADDITIONAL items not covered.
   - If `0-2b-configured` absent → ask for all user-assisted dependencies (Phase 0 was skipped or not applicable).
2. If remaining items exist, batch ALL user preparation requests into one prompt:
   ```
   📋 User-Assisted Verification for [FID]:
     SC-031: Requires MCP server running on localhost:3001
     (Note: API key already configured in Phase 0)

   Please prepare these dependencies, then confirm.
   ```
3. **Use AskUserQuestion**:
   - "Dependencies ready — proceed with verification"
   - "Skip user-assisted SCs"
   **If response is empty → re-ask** (per MANDATORY RULE 1)
4. If "Dependencies ready": re-verify each dependency (probe API key presence, service endpoint) → run automated verification (same as auto categories)
5. If "Skip": record as `⚠️ user-assisted — skipped`

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

- UI verification failures do NOT block the overall verify result — they are included as warnings in Review.
- See [reference/ui-testing-integration.md](../reference/ui-testing-integration.md) for full guide

---

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

---

**Step 3d — Interaction Chain Verify Method Execution** (GUI Features with plan.md Interaction Chains):

> Bridges the plan→verify gap: plan.md defines Verify Method for each Interaction Chain row, but without this step those definitions are dead columns.

**Skip if**: plan.md has no `## Interaction Chains` section, or Feature has no GUI interface.

1. Read `specs/{NNN-feature}/plan.md` → extract the Interaction Chains table
2. For each row with a non-empty `Verify Method` column:
   - Parse the verb: `verify-state selector attribute "expected"` → `expect(page.locator(selector)).toHaveAttribute(attribute, expected)`
   - Parse the verb: `verify-effect target property "expected"` → evaluate via `page.evaluate()` + assert
   - Parse the verb: `verify-state selector class "expected"` → `expect(page.locator(selector)).toHaveClass(/expected/)`
3. Execute the chain **in order**: User Action → wait for DOM Effect → run Verify Method assertion
4. Record result per chain row: PASS / FAIL with details
5. FAIL items → classify per Bug Fix Severity Rule (same as other verify failures)

**Result report** (appended after Step 3 report):
```
── Interaction Chain Verification ──────────────
  Chain 1 (FR-012 Theme toggle): ✅ verify-effect body class "dark" PASS
  Chain 2 (FR-015 Font size):    ✅ verify-effect body style.fontSize "18px" PASS
  Chain 3 (FR-018 Sidebar):      ❌ verify-state .sidebar class "hidden" FAIL — sidebar still visible
  Total: 2/3 PASS
────────────────────────────────────────────────
```

---

**Step 3e — Demo TEST PLAN Execution** (when demo script contains TEST PLAN block):

> Ensures that the TEST PLAN written in implement is not a dead document — each test scenario is actually executed and verified during verify.

**Skip if**: Demo script has no `# ── TEST PLAN` or `# ── Test N:` comment block.

1. Parse the demo script's TEST PLAN block → extract each test item (precondition, action, expected, confirmation)
2. Classify each test item:
   - **auto**: UI action + DOM state check → execute via Playwright
   - **semi-auto**: UI action possible but expected result requires visual judgment → Playwright screenshot + agent comparison against expected description
   - **manual-only**: OS-level action (file dialog, app restart, hardware), external dependency → routed to user-assisted manual verification in Step 3g
3. Execute auto and semi-auto items via Playwright:
   - Perform the action (click, fill, navigate, toggle)
   - Assert the expected result (DOM state, attribute, visual comparison)
   - Record PASS/FAIL per item
4. FAIL items → classify per Bug Fix Severity Rule
5. Manual-only items → accumulated for Step 3g (do NOT silently skip)
6. Display result in verify Review:
```
── Demo TEST PLAN Execution ─────────────────
  Total: 9 tests | Auto: 5 PASS | Semi-auto: 2 PASS | Manual: 2 → Step 3g
────────────────────────────────────────────────
```

---

**Step 3f — User-Assisted SC Completion Gate** (MANDATORY — cannot skip):

> **Why this separate gate exists**: The `user-assisted` SCs block in Step 3 is a subsection among several auto-category subsections. Agents tend to process the auto categories and skip the user-assisted block entirely. This gate is a safety net that BLOCKS progression to Step 4 until user-assisted SCs are explicitly resolved.

1. **Read SC Verification Matrix from Step 0**: Count SCs classified as `user-assisted`.
2. **If count = 0**: No user-assisted SCs → proceed to Step 3g.
3. **If count > 0**: Check whether ALL user-assisted SCs have been resolved (verified ✅ or explicitly skipped via AskUserQuestion in Step 3).
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

> **BLOCKING**: Do NOT proceed to Step 3g until this gate is passed. Marking `user-assisted` SCs as `⚠️` without presenting AskUserQuestion to the user is a protocol violation.

---

**Step 3g — User-Assisted Manual Verification** (MANDATORY when manual items exist):

> **Principle: "Automation impossible ≠ verification skip"**. Automation-impossible items must still be verified — through user cooperation, not silent omission. This gate ensures every verification item is either machine-verified, user-verified, or explicitly acknowledged as unverifiable.

**Sources** — accumulate all items that couldn't be auto-verified from prior steps:
- `manual` SCs from SC Verification Matrix (Step 0)
- `manual-only` TEST PLAN items from Step 3e
- Interaction Chain rows that failed Playwright execution and need visual confirmation (Step 3d)

**Skip if**: No manual/manual-only items accumulated from any source.

1. **Present manual verification checklist to user** via AskUserQuestion:
   ```
   📋 Manual Verification for [FID] — [N] items need your confirmation:

   From SC Matrix:
     SC-045: "Animation completes within 300ms" — visual timing judgment
     SC-052: "Print dialog opens with correct layout" — OS dialog interaction

   From TEST PLAN:
     Test 3: Settings persistence after app restart
     Test 7: File export opens OS save dialog

   For each item, please:
   1. Perform the action described
   2. Observe whether the expected result occurs
   3. Report PASS or FAIL (with what you observed if FAIL)
   ```
   - Options: "All PASS", "Some FAIL — [details]", "Cannot test now — defer"
   **If response is empty → re-ask** (per MANDATORY RULE 1)

2. **Record results**:
   - "All PASS" → record each as `✅ manual — user-verified`
   - "Some FAIL" → classify per Bug Fix Severity Rule (same as auto failures)
   - "Cannot test now" → record as `⚠️ manual — deferred (user unavailable)`. This does NOT block merge but is recorded in verify Notes as a limitation

3. **Display in verify Review**:
```
── User-Assisted Manual Verification ───────────
  SC Matrix: 2 items | 2 PASS (user-verified)
  TEST PLAN: 2 items | 1 PASS, 1 deferred (app restart — user unavailable)
  Total: 4 items | 3 verified, 1 deferred
────────────────────────────────────────────────
```

> **Why not just skip?** Silent skip creates a false sense of coverage — "verify passed" implies everything was checked. With this gate, unverified items are explicitly recorded, and the user has the opportunity to catch bugs that automation cannot.

---

**Step 3-rebuild — Source Comparison + Visual Fidelity** (rebuild mode only):

> **Read [verify-sc-rebuild.md](verify-sc-rebuild.md)** for the full rebuild-only verification protocol.
> This step only applies when Origin=`rebuild` (from sdd-state.md scenario config).
> Skip entirely for greenfield and add modes.

---

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
- The demo script's CI mode MUST include a **stability window** (15 seconds — 3 probes at 5s intervals per demo-standard.md) between the initial health check and exit — verify the script includes this (see demo-standard.md template)
- If the demo script lacks a stability window (exits immediately after first health check), **WARN** and recommend updating the script to include one
- Capture the demo output (stdout/stderr) for the Review display
- **Runtime error scan (BLOCKING)**: After demo execution, scan the captured stdout/stderr for runtime error patterns:
  - `"level":"error"` or `"level":"fatal"` (structured log errors)
  - `Error occurred`, `Unhandled rejection`, `Uncaught exception`
  - `TypeError`, `ReferenceError`, `SyntaxError` (JS runtime errors)
  - `No handler registered`, `ECONNREFUSED`, `ENOENT` (service initialization failures)
  - `panic:`, `FATAL`, `segfault` (system-level crashes)
  - Process exit with non-zero code
  > These patterns are JS/Node.js-centric. For other languages, scan for equivalent error indicators (e.g., Python `Traceback`, Go `goroutine panic`, Rust `thread panicked`).
- **If runtime errors are detected**: The demo is considered **FAILED** even if the health check (HTTP 200) passed — a healthy port does not mean the application is functioning correctly (e.g., Vite dev server may respond while Electron main process has fatal errors)
- Display each detected error with its source line for user review
- **Browser console error scan** (when Playwright is available): After demo --ci passes the stdout/stderr scan above, if runtime backend supports browser access:
  1. Navigate to the app's main URL (from demo script's "Try it" output or health check URL)
  2. Wait 5 seconds for the page to stabilize
  3. Read browser Console logs for: `TypeError`, `ReferenceError`, framework-specific infinite loop warnings (e.g., React `Maximum update depth exceeded`), `unhandled rejection`, infinite render warnings
     **Exclude platform noise**: Filter out Electron/Chromium system warnings (`"Don't paste code"`, `"Electron Security Warning"`, `[DEP0` deprecation, DevTools internal messages) — these are automation artifacts, not app errors
  4. **If browser console errors detected**: Demo is FAILED even if health endpoint returned 200 and stdout was clean — these are client-side-only bugs (infinite re-renders, selector instability, DOM timing) that never appear in server output
  5. Display: `❌ Browser console errors detected: [N] errors — [first error message]`
  6. If no browser access available: Skip browser console scan. Display: `ℹ️ Browser console scan skipped (no runtime backend available)`

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
2. If block exists AND runtime backend supports interactive verification:
   - Keep the app running (from the demo `--ci --verify` invocation)
   - Execute each step using the interface-appropriate backend:
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
   - Report in same format as above
   - Display: `ℹ️ Functional verification via Playwright CLI`
5. If `RUNTIME_BACKEND` is `demo-only` or `build-only` AND no test file exists: skip with notice:
   `⚠️ Functional verification skipped — no runtime backend available and no test file (demos/verify/F00N-name.spec.ts)`

**SC Verification Coverage Summary** (after Steps 3 + 6b complete):

Compile the final SC Verification Matrix by combining results from all verification sources:
- Phase 1 tests → `test-covered` SCs
- Step 3 SC-level verification → `cdp-auto`/`api-auto`/`cli-auto`/`pipeline-auto` SCs (result: ✅/❌/⚠️)
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
- Effective coverage < 50%: Display `⚠️ SC verification coverage is [N]% — most SCs lack runtime verification`. This is a WARNING, not a blocker — but it is prominently displayed in Review for user awareness. If `cdp-auto` SCs exist that were NOT verified (Step 3 skipped due to backend unavailability), recommend installing Playwright.

---

### Phase 3b: Bug Prevention Verification (B-4)

> Additional checks to automatically verify basic stability of code written during implement.
> Runs after Phase 3 Demo-Ready, before Phase 4 Update.

**CI Propagation Check (greenfield only)**: Read `CI Low-confidence` from sdd-state.md. If CI < 40%: add **empty-state checks for each low-CI area** — verify the Feature handles undefined/missing data gracefully for dimensions that were vague at project start. For example, if Scale & Scope was low-confidence and no scale decisions were made, verify the app doesn't crash under minimal load. If Constraints confidence ≤ 1: no additional checks (constraints clarify during implementation — per `reference/clarity-index.md` § 6).

**Empty State Smoke Test** — "Empty State ≠ PASS":

> Principle: A Feature that renders an empty state without errors is NOT automatically passing.
> If the Feature is supposed to display data and the data area is empty with no intentional
> empty-state message, that is an INCOMPLETE state, not a PASS.

- Start app with all stores/state set to initial (empty) state
- Confirm main screen renders without crashes (Error Boundary not triggered)
- Confirm no critical JS errors in Console (TypeError, ReferenceError, etc.)
- **When runtime backend supports navigation** (`RUNTIME_BACKEND = mcp` or `cli`): Auto-verify via Navigate → Snapshot
- **Without navigation capability**: Substitute with build + server start success check
- **Data presence check** (NEW):
  - Read spec.md FR-### to identify what data the Feature should display
  - If the Feature manages/displays data (list, table, form with defaults):
    - Check if the data area is populated OR shows an intentional empty state message
    - "No items yet" / "Add your first..." / "No results" / placeholder text = ✅ intentional empty state
    - Blank area with no content and no empty-state indicator = `⚠️ Empty State — data area has no content and no empty-state indicator. Possible missing data source or unimplemented empty state UI.`
  - This check helps catch cross-Feature data dependency issues (e.g., Feature depends on AI model data that isn't populated)

**Seeded State Verification** — "Dual-Mode: Clean + Seeded" (🚫 G5: Environment Parity. See pipeline-integrity-guards.md § Guard 5):

> Principle: Clean-state verification alone is INSUFFICIENT. Features that read from persistent
> storage pass in Playwright's isolated `_electron.launch()` environment but fail in the user's
> real environment with non-default settings and accumulated data.

- **BLOCKING** for Features that read from persistent storage (electron-store, SQLite, localStorage, IndexedDB)
- **⚠️ WARNING** for Features with no persistent storage dependency (included in Review but not blocking)

**Protocol — both A and B must pass**:

A. **Clean Environment** (already covered by Empty State Smoke Test above):
   - Playwright `_electron.launch()` with isolated userData
   - Baseline rendering + default-setting functionality

B. **Seeded Environment** (non-default, real-world state):
   - Launch with non-default settings: fontSize extremes (e.g., 12, 24), non-default language, non-default theme
   - Option 1: `_electron.launch()` with `--user-data-dir` pointing to a pre-seeded test profile
   - Option 2: Dev server + Playwright `browser_navigate(localhost:port)` with seeded localStorage/store
   - Option 3: Screenshot request to user (last resort — when programmatic seeding is infeasible)
   - Verify: UI renders correctly with non-default values, no layout overflow, no invisible text, no hardcoded defaults overriding persisted values

**Test State Isolation Rules** (mandatory for all seeded-state tests):
1. **Reset or detect**: Before each test, reset to a known state OR detect current state before asserting
2. **Toggle tests**: Read current value → change to opposite → verify change (NEVER assume initial state)
3. **Order-independent**: Each test scenario must be independent — no dependency on previous test's side effects

**Result**: If Feature has persistent storage dependency and Seeded Environment (B) is not verified → `❌ BLOCKING — Dual-Mode Verification incomplete. Seeded state not tested.`

**Smoke Launch Criteria** (basic app stability):
1. Process starts — no immediate exit with non-zero exit code
2. Main screen renders — not a blank page or error screen
3. Error Boundary not triggered — React/Vue/Svelte error boundaries not activated
4. No JS errors — Console free of TypeError, ReferenceError, SyntaxError

**Result classification**: ⚠️ warning (NOT blocking) — results included in Review
