# Context Injection: Verify

> Per-command injection rules for `/smart-sdd verify [FID]`.
> For shared patterns (HARD STOP, Checkpoint, Missing/Sparse Content Handling), see [context-injection-rules.md](../context-injection-rules.md).
> For the full verification workflow (Phase 1-4 execution details), see [verify-phases.md](../../commands/verify-phases.md).

---

> **Note**: `speckit-analyze` is NOT used in this step. Cross-artifact consistency (spec ↔ plan ↔ tasks) was already verified in step 4 (Analyze) before implementation. This step focuses on post-implementation validation.

> **Greenfield/add note**: For greenfield or add-origin projects, cross-Feature verification points in pre-context.md may be limited to dependency-based checks only (no source-code-derived verification points). The verify command works the same way — it just has fewer pre-defined verification items.

## Read Targets

| File | Section | Filtering |
|------|---------|-----------|
| `BASE_PATH/features/[FID]-[name]/pre-context.md` | "For /speckit.analyze" section | Cross-Feature verification points (entity compatibility, API contracts) |
| `BASE_PATH/features/[FID]-[name]/pre-context.md` | "Source Behavior Inventory" section | **If present (rebuild mode)** — for behavior completeness check |
| `BASE_PATH/entity-registry.md` | Entities modified by the Feature | Change tracking |
| `BASE_PATH/api-registry.md` | APIs modified by the Feature | Change tracking |
| `SPEC_PATH/[NNN-feature]/spec.md` | FR-### list | For behavior completeness cross-reference |
| `SPEC_PATH/[NNN-feature]/quickstart.md` | Entire file | **If exists** — authoritative run instructions for demo verification |
| `SPEC_PATH/[NNN-feature]/` | data-model.md, contracts/ | Actual implementation results |

## Injected Content

- **Cross-Feature verification points**: Cross-verification checklist from pre-context (entity compatibility, API contract compatibility, business rule consistency)
- **Source behavior completeness**: If Source Behavior Inventory exists in pre-context, cross-reference P1/P2 behaviors against FR-### in spec.md to detect uncovered functionality
- **Impact scope analysis**: List of other Features referencing the modified entities/APIs
- **Implementation consistency verification**: Whether entity-registry/api-registry matches the actual implemented code

## Checkpoint Display Content

**Before displaying Checkpoint**: Read sdd-state.md for this Feature's Verify Progress table. If a Verify Progress section exists with pending phases that should have been completed (i.e., an earlier Phase shows `⏳ pending` but later Phases show `✅ complete`), STOP and execute the skipped Phase first. If the Verify Progress shows a `⚠️ RESUME FROM` line, follow the Resumption Protocol in `commands/verify-phases.md` before continuing.

Show the **actual verification checklist** so the user can see what will be checked:

```
📋 Verify execution: [FID] - [Feature Name]

── Phase 1: Execution Verification ───────────────
  - Test command: [actual test command]
  - Build command: [actual build command]
  - Lint command: [actual lint command | "not configured" | "⚠️ not installed — skipped per Toolchain Pre-flight"]

── Phase 2: Cross-Feature Verification ───────────
[List each cross-verification point from pre-context]
  - [ ] Entity compatibility: [specific check]
  - [ ] API contract compatibility: [specific check]
  - [ ] Business rule consistency: [specific check]
  - [ ] Source behavior completeness: [P1: N behaviors, P2: N behaviors] (rebuild only)
  - [ ] Interaction chain completeness: [list each chain to verify] (UI Features only)
  - [ ] UX behavior contract: [list each temporal scenario to verify] (async UI Features only)
  - [ ] Enablement interfaces: [list each "Enables →" entry to verify]
  - [ ] Blocked-by prerequisites: [list each "Blocked by ←" status]
  - [ ] API compatibility matrix: [list each provider to verify — auth, endpoints, headers] (if plan.md has API Compat Matrix)

── Phase 3: Demo-Ready Verification ──────────────
[Only if VI. Demo-Ready Delivery is in the constitution. Omit this section otherwise.]
  SC Verification Matrix ([N] SCs from spec.md):
    cdp-auto: [N] SCs — [list SC-### to verify via CDP]
    test-covered: [N] SCs — [list SC-### covered by Phase 1 tests]
    external-dep: [N] SCs — [list SC-### + skip reason]
    manual: [N] SCs
    Planned coverage: [cdp-auto + test-covered]/[total] = [N]%
  - [ ] Executable demo script exists (demos/F00N-name.sh or .ts/.py/etc.)
  - [ ] Demo script is NOT markdown and NOT a test-only script
  - [ ] Demo launches a real, working Feature environment (not just assertions)
  - [ ] Demo prints concrete "Try it" instructions (URLs, commands) for the user (≥ 2)
  - [ ] --ci flag works: health check passes and exits cleanly
  - [ ] FR/SC Coverage header maps spec.md FR-###/SC-### to what the user can try
  - [ ] Coverage ≥ 50% of FR/SC items (warn if below)
  - [ ] Demo Components header comment with Category and Fate
  - [ ] Component markers (@demo-only / @demo-scaffold)
  - [ ] VERIFY_STEPS functional verification: [list each SC with VERIFY_STEPS block]
  - [ ] Visual fidelity check: [source screenshot vs current] (rebuild only)

── Phase 3b: Bug Prevention Verification ──────────
[Applies to all Features with implementation]
  - [ ] Empty state smoke test: app starts with no user data → no crash
  - [ ] Smoke launch criteria met (app loads within timeout)

── Phase 4: Global Evolution Consistency ─────────
[List entities/APIs to verify against registry]
  - entity-registry: [entities to check]
  - api-registry: [APIs to check]

── Impact Scope ──────────────────────────────────
[List of other Features potentially affected by changes]

──────────────────────────────────────────────────
Review the verification plan. You can:
  - Approve as-is to proceed
  - Add or remove verification items

Note: If Phase 1 or Phase 3 cannot pass due to external
dependencies (e.g., requires another Feature's code), you may
"Acknowledge limited verification" — recorded as ⚠️ in state.
```

## Review Display Content

> **⚠️ SUPPRESS spec-kit output**: Verification prints navigation messages — **never show these to the user**. Suppress ALL spec-kit navigation messages. Immediately proceed to the Review Display below. If context limit prevents continuing, show instead: `✅ Verification executed for [FID] - [Feature Name].\n💡 Type "continue" to review the results.`

After verification execution completes:

**Display format**:
```
📋 Review: Verification results for [FID] - [Feature Name]

── Phase 1: Execution Verification ───────────────
  Tests: [passed count]/[total count] passed
  Build: [success/failure]
  Lint: [success/failure/not configured/skipped (not installed)]

── Phase 2: Cross-Feature Consistency ─────────────
[Results for each cross-verification point]
  - ✅/❌ Entity compatibility: [result]
  - ✅/❌ API contract compatibility: [result]
  - ✅/❌ Business rule consistency: [result]
  - Source behavior coverage: P1 [N]/[N] ([%]), P2 [N]/[N] ([%])
    [⚠️ Uncovered P1: funcA, funcB (if any)]
  - Interaction chains: [N]/[N] complete [⚠️ Broken: FR-015 DOM Effect missing (if any)]
  - UX behavior contract: [N]/[N] scenarios verified
    [⚠️ Missing: auto-scroll not implemented, cleanup on unmount missing (if any)]
  - Enablement interfaces: [N]/[N] verified
    [⚠️ Failed: provider settings panel not interactive (if any)]
  - Blocked-by prerequisites: [N]/[N] verified
    [⚠️ F001-shell not verified yet (if any)]
  - API compatibility matrix: [N]/[N] providers verified
    [⚠️ Provider X: auth method mismatch (if any)]

── Phase 3: Demo-Ready Verification ───────────────
[Only if Demo-Ready Delivery is in the constitution]
  - ✅/❌ Executable demo script exists (demos/F00N-name.sh)
  - ✅/❌ Demo script launches a real Feature environment (not test-only)
  - ✅/❌ Demo prints concrete "Try it" instructions for the user (≥ 2)
  - ✅/❌ --ci health check passed
  - ✅/❌ FR/SC Coverage mapping present (≥ 50% of spec FR/SC items)
  - ✅/❌ Demo Components header comment present
  - ✅/❌ Component markers present
  - VERIFY_STEPS: [N]/[N] SC functional tests passed
    [⚠️ SC-003 wait-for timeout (if any)]
  - Visual fidelity: [match/differences found] (rebuild only)
  - SC Verification Coverage: [verified]/[total] = [N]%
    ✅ cdp-auto: [N] verified [⚠️ SC-### failed: reason (if any)]
    ✅ test-covered: [N]
    ⚠️ external-dep: [N] ([list SC + skip reason])
    ⚠️ manual: [N]
    [⚠️ Coverage < 50% — most SCs lack runtime verification (if applicable)]

── Phase 3b: Bug Prevention Verification ───────────
  - ✅/❌ Empty state smoke test: [result]
  - ✅/❌ Smoke launch criteria: [result — load time]

── Phase 4: Global Evolution Consistency ───────────
  - entity-registry: [match/discrepancies found]
  - api-registry: [match/discrepancies found]

── Limited Verification (if applicable) ────────────
[Only shown if user acknowledged limited verification in Phase 1 or Phase 3]
  ⚠️ Phase 1: [reason] (or "N/A — passed normally")
  ⚠️ Phase 3: [reason] (or "N/A — passed normally")
  Overall status: limited (merge allowed with reminder)

── Verify-time Changes (if applicable) ─────────────
[Only shown if source was modified during verify]
  Bug fixes (Minor): [count] — [brief list]
  Gap fills: [count] — [brief list]
  Total files modified: [count]

──────────────────────────────────────────────────
```

**Append to all cases** (after the verification results):
```
── Files You Can Edit ─────────────────────────
  📄 Source files in the Feature branch (fix failing tests/build)
  📄 specs/{NNN-feature}/data-model.md  (fix entity discrepancies)
  📄 specs/{NNN-feature}/contracts/*.md  (fix API discrepancies)
  📄 demos/{FID}-{name}.sh  (fix demo issues, if applicable)
If issues were found, you can fix them directly, then select
"I've finished editing" to re-verify.
──────────────────────────────────────────────────
```

**If any Phase fails**:
- Display: "❌ Verification failed. Issues must be resolved before merge."

**If all Phases pass**:
- Display: "✅ All verification checks passed."

**If limited verification was acknowledged** (Phase 1 or Phase 3):
- Display: "⚠️ Verification completed with limitations. Merge allowed — re-verify when limitations are resolved."

**HARD STOP** (ReviewApproval):
- If any phase failed: Options: "Fix issues and re-verify", "Return to implement", "Return to plan", "Return to specify", "I've finished editing", "Acknowledge limited verification"
- If all phases passed: Options: "Approve", "I've finished editing", "Re-run verification"
- If limited verification: Options: "Approve (with ⚠️ limited status)", "Fix issues and re-verify", "I've finished editing"

**If response is empty → re-ask** (per MANDATORY RULE 1).

**Pipeline regression handling** (when user selects "Return to [stage]"):
1. Record regression reason in `sdd-state.md` Feature Detail Log with timestamp
2. Set Feature status to `regression-[stage]` (e.g., `regression-plan`)
3. Preserve verify results as context for re-run after regression fixes
4. Display: `↩️ Returning to [stage] for [FID]. Verify results preserved as regression context.`
5. Resume pipeline from the selected stage (specify → plan → tasks → implement → verify)

**Regression classification guide** (see verify-phases.md Bug Fix Severity Rule for details):
- **Return to implement**: 3+ files OR new component needed, but spec and plan are correct
- **Return to plan**: Architecture/data-model/contracts need revision (spec is correct)
- **Return to specify**: Requirements themselves are wrong or incomplete

---

## Post-Step Update Rules

### After Verify Completion

1. Verify entity-registry.md and api-registry.md match the actual implementation:
   - Compare `SPEC_PATH/[NNN-feature]/data-model.md` with `BASE_PATH/entity-registry.md`
   - Compare `SPEC_PATH/[NNN-feature]/contracts/` with `BASE_PATH/api-registry.md`
   - Update registries if discrepancies are found
2. Record the verification results in `BASE_PATH/sdd-state.md`:
   - Test results (pass/fail, execution time)
   - Build results
   - Cross-Feature verification results
   - Overall verification status (`success` / `limited` / `failure`)
   - If limited: record `⚠️ LIMITED — [reason]` and/or `⚠️ DEMO-LIMITED — [reason]` in Notes
   - **Verify-time changes**: If source was modified during verify, record in Notes: `Inline changes: [N] bug fix, [N] gap fill ([brief descriptions])` (see verify-phases.md § Verify-time Change Recording)
3. **SBI Coverage Update** (rebuild/adoption only):
   - Run `scripts/sbi-coverage.sh <project-root>` to get current coverage
   - Update `sdd-state.md` Source Behavior Coverage: matched SBI entries → `✅ verified`
   - If P1 coverage < 100% after this Feature: display warning:
     ```
     ⚠️ P1 SBI coverage is [X]% — some core behaviors are still unmapped.
     ```
4. **Demo Group Progress Update**:
   - Check if this Feature belongs to any Demo Group in `sdd-state.md`
   - Update the Completed count for that group
   - Run `scripts/demo-status.sh <project-root>` to display current group status
   - **Integration Demo Trigger**: If this Feature was the last pending Feature in a group → display HARD STOP:
     ```
     🎯 All Features in [DG-0N: Scenario] are now verified!
     Run Integration Demo to verify the end-to-end scenario?
     ```
     Options: "Run Integration Demo", "Defer Integration Demo". **If response is empty → re-ask** (per MANDATORY RULE 1).
     For execution procedure, see [demo-standard.md § 7](../demo-standard.md).

### After Merge Completion

1. Update `BASE_PATH/sdd-state.md`:
   - Record the merge step as completed in Feature Progress and Feature Detail Log
   - Update Feature Mapping: record the Branch name and mark Merged as ✅
   - Change the Feature Status to `completed` (or `adopted` if adoption mode — see adopt-verify.md)
   - Record in Global Evolution Log: "Branch {NNN}-{short-name} merged to main"
2. Verify that main branch is clean after merge (`git status`)
3. The next Feature's `specify` step can now be started from the main branch
