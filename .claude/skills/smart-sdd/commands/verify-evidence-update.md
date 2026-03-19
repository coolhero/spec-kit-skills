# Verify Evidence Gate + Phase 4-5: Global Update + Integration Demo

> Part of verify-phases.md split. For common gates (Bug Fix Severity, Source Modification Gate), see [verify-phases.md](verify-phases.md).

---

> **⚠️ Source Modification Gate reminder** — Between Phase 3b and Phase 4 (Global Evolution Update), the pipeline displays Review results to the user. If the user requests fixes based on Review, or if the agent identifies issues to fix before committing results, the **Source Modification Gate MUST be executed** before touching ANY source file. This is the most common point where agents violate the Bug Fix Severity Rule — user feedback triggers a "fix it now" bias that bypasses severity classification. **STOP → List changes → Classify → Aggregate file count → If Major: HARD STOP regression, not inline fix.**

### SC Verification Evidence Gate (BLOCKING — before Review)

> **Why this gate exists (SKF-068)**: Agents exhibit a 3-stage verification evasion pattern: (1) code review → "code path exists" → SC ✅, (2) surface UI check → "button renders" → SC ✅, (3) only after user complaint → actual data flow verification. This gate BLOCKS Review approval unless runtime evidence is submitted for each SC.

**Level 1 (code review) alone CANNOT pass any SC. This is absolute.**

Before assembling the verify Review, check the SC Verification Matrix for evidence:

1. **Evidence requirement per SC category**:

| Category | Required Evidence | Example |
|----------|------------------|---------|
| `cdp-auto` | Playwright execution log: action → state change → assertion result | `click KB button → popover.visible=true → select KB → store.knowledge_bases.length=1` |
| `api-auto` | HTTP request/response log: method, URL, status, response body snippet | `POST /api/users → 201 {id:5,name:"test"}` |
| `cli-auto` | Command + stdout/stderr + exit code | `myapp --config test.yml → exit 0, output: "3 items processed"` |
| `pipeline-auto` | Pipeline execution log + output comparison | `pipeline.run(test.csv) → output 50 rows, schema matches expected` |
| `test-covered` | Test name + pass/fail result from Phase 1 | `test_user_creation (PASSED)` |
| `user-assisted` | User's response recorded via AskUserQuestion | `user-verified: "KB search returns relevant results"` |
| `os-native` | User's response recorded via AskUserQuestion | `user-verified: "drag&drop adds file, status → processing"` |
| `external-dep` | Explicit skip reason | `Production-only API, no local mock available` |

2. **Evidence audit**: For each SC in the matrix:
   - If category is auto (`cdp-auto`, `api-auto`, `cli-auto`, `pipeline-auto`) but **no runtime execution log exists** → BLOCKING
   - Display: `SC-### has no runtime evidence. Category is [cdp-auto] but only code review was performed. Run Playwright/HTTP verification before Review.`
   - If category is `user-assisted` or `os-native` but **no AskUserQuestion response recorded** → BLOCKING
   - Display: `SC-### requires user verification but user was never asked. Call AskUserQuestion now.`

3. **Anti-patterns (verification evasion patterns — all are BLOCKING violations)**:
   ```
   ❌ WRONG (Level 1 — code review):
     "Checked useChatStore.ts via Explore agent → knowledge:search function exists → SC-002 ✅"
     → Code existing and code executing are different things. Cannot detect missing hydrate or parameter mismatch.

   ❌ WRONG (Level 2 — surface UI):
     "Playwright snapshot → KB button visible → SC-002 ✅"
     → UI being visible and data flowing are different things. Whether actual IPC call occurs after button click is unverified.

   ✅ RIGHT (Level 3 — data flow):
     "Playwright: Create KB → add file → link KB to assistant → send message
      → interceptor: knowledge:search called=true, results.length=3
      → Confirmed AI response contains KB reference → SC-002 ✅"
   ```

4. **Display Evidence Summary in Review (MANDATORY)**:
   ```
   📊 SC Verification Evidence Summary:
   | SC | Category | Depth | Evidence |
   |----|----------|-------|---------|
   | SC-001 | cdp-auto | Tier 2 | ✅ Playwright: click → state change verified |
   | SC-002 | cdp-auto | Tier 3 | ✅ Playwright: E2E flow + IPC interceptor |
   | SC-003 | user-assisted | Tier 2 | ✅ User confirmed: "drag&drop works" |
   | SC-004 | external-dep | — | ⏭️ Skip: production API only |

   Evidence coverage: 3/4 SCs verified (75%)
   ```
   **If any auto-category SC has no evidence → BLOCK ReviewApproval.** User cannot approve verify results that lack runtime evidence.

### Phase 4: Global Evolution Update

**Step 4a. Registry Consistency Verification**:
- entity-registry.md: Verify that the actually implemented entity schemas match the registry; update if discrepancies are found
- api-registry.md: Verify that the actually implemented API contracts match the registry; update if discrepancies are found
- **REGISTRY-DRIFT resolution**: If implement marked this Feature with `⚠️ REGISTRY-DRIFT` in sdd-state.md, this phase MUST resolve all flagged inconsistencies:
  - Read the REGISTRY-DRIFT details from Feature Detail Log
  - Cross-check each flagged item against the actual implementation
  - Update registry entries to match reality (implementation is the source of truth at this point)
  - Remove the `⚠️ REGISTRY-DRIFT` flag after resolution
  - Display: `✅ Registry drift resolved: [N] entity entries and [M] API entries updated to match implementation`

**Step 4b. Dependency Stub Status Check**:

> Guard 6c: Dependency Stub Resolution. Verify that stubs recorded during preceding
> Features' implement are resolved by this Feature's implementation.
> See pipeline-integrity-guards.md § Guard 6.

- If this Feature resolves stubs from a preceding Feature: verify the stubs are actually resolved (real implementation replaces placeholder)
- If this Feature has `⚠️ STUB-DEPENDENT` flag: verify the stubs it depends on are still present and compatible
- Update stubs.md of affected Features if resolution status changed

**Step 4c. State Update**:
- sdd-state.md: Record verification results — **status MUST be one of `success`, `limited`, or `failure`**, plus test pass/fail counts, build result, and verification timestamp. The merge step checks this status as a gate condition.
  - `success`: All phases passed normally
  - `limited`: User acknowledged limited verification in Phase 1 or Phase 3 (⚠️ marker). Merge is allowed with a reminder
  - `failure`: One or more phases failed without acknowledgment. Merge is blocked

**Process cleanup**: After Phase 4 update completes (or if verify exits early due to failure/regression), execute the Verify Process Lifecycle Protocol cleanup — kill all PIDs in the registry. This applies regardless of verify outcome (success, limited, failure, regression).

---

### Phase 5: Integration Demo Trigger (HARD STOP — conditional)

> This phase runs only when all Phases 0-4 complete with `success` or `limited` status. For detailed post-step update procedures (registry updates, SBI coverage, merge workflow), see [injection/verify.md](../reference/injection/verify.md) § Post-Step Update Rules.

After the Feature passes verification, check whether it completes a Demo Group:

1. Read `sdd-state.md` Demo Group Progress section
2. Identify which Demo Group(s) contain this Feature
3. For each group: check if all other Features are already `completed` or `adopted`
4. If this Feature is the **last pending Feature** in a Demo Group:
   - Run `scripts/demo-status.sh <project-root>` to confirm group completion status
   - **HARD STOP** — Use AskUserQuestion:
     ```
     🎯 All Features in [DG-0N: Scenario] are now verified!
     Run Integration Demo to verify the end-to-end scenario?
     ```
     Options: "Run Integration Demo", "Defer Integration Demo"
     **If response is empty → re-ask** (per MANDATORY RULE 1)
   - If "Run Integration Demo": execute per [demo-standard.md § 7](../reference/demo-standard.md)
   - If "Defer": record `⏳ deferred` in Demo Group Progress and continue to merge
5. If this Feature does NOT complete any Demo Group: skip this phase entirely
