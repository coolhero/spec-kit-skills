# Context Injection: Verify

> Per-command injection rules for `/smart-sdd verify [FID]`.
> For shared patterns (HARD STOP, Checkpoint, Missing/Sparse Content Handling), see [context-injection-rules.md](../context-injection-rules.md).
> For the full verification workflow (Phase 1-4 execution details), see [verify-phases.md](../../commands/verify-phases.md).
>
> **Conditional loading**: Read [verify-preflight.md](../../commands/verify-preflight.md) ONLY when Domain Profile includes `gui` interface. For non-GUI projects (http-api, cli, data-io only), skip preflight entirely — Playwright probe is unnecessary.

---

## Scale & Cross-Concern Adjustments (🚫 BLOCKING)

> Apply [`context-injection-rules.md`](../context-injection-rules.md) § Scale Modifier Enforcement + § Cross-Concern Integration Enforcement before proceeding. If not applied → output will not match project maturity/team context.

**verify-specific adjustments**:
- `prototype` → accept build-only verification, relaxed SC coverage threshold
- `production` → strict SC coverage (≥80%), mandatory edge-case verification, performance baselines
- Cross-Concern: verify combined behavior patterns are tested at integration boundaries (e.g., `gui` + `realtime` → verify reconnection UI behavior, not just component existence)

```
❌ WRONG: Run build-only check for production project → edge cases and SC coverage skipped
✅ RIGHT: Read Scale → enforce SC coverage threshold → verify cross-concern integration tests present
```

> **Note**: `speckit-analyze` is NOT used in this step. Cross-artifact consistency (spec ↔ plan ↔ tasks) was already verified in step 4 (Analyze) before implementation. This step focuses on post-implementation validation.

> **Greenfield/add note**: For greenfield or add-origin projects, cross-Feature verification points in pre-context.md may be limited to dependency-based checks only (no source-code-derived verification points). The verify command works the same way — it just has fewer pre-defined verification items.

## Domain Module Filtering (per _resolver.md Step 5)

After domain modules are merged (Steps 1-4), retain ONLY these sections for `verify`:

| Active (retain) | Skipped (discard from context) |
|-----------------|-------------------------------|
| S1 (SC compliance check), S3, S7 (B-4), S8, Foundation F8 | S0, S2, S5, S6, S9 |

Display in Checkpoint: `📊 Domain: [N] modules → S1+S3+S7(B-4)+S8+F8 active | [K] skipped`

🚫 Do NOT retain skipped sections. Verify checks SC compliance (S1), verification strategy (S3), bug prevention (S7), and runtime (S8).

---

## Read Targets

| File | Section | Filtering |
|------|---------|-----------|
| `SPEC_PATH/[NNN-feature]/pre-context.md` | "For /speckit.analyze" section | Cross-Feature verification points (entity compatibility, API contracts) |
| `SPEC_PATH/[NNN-feature]/pre-context.md` | "Source Behavior Inventory" section | **If present (rebuild mode)** — for behavior completeness check |
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
  - i18n check: [locale files to cross-check | "skipped — no i18n framework detected"]

── Phase 2: Cross-Feature Verification ───────────
[List each cross-verification point from pre-context]
  - [ ] Entity compatibility: [specific check]
  - [ ] API contract compatibility: [specific check]
  - [ ] Business rule consistency: [specific check]
  - [ ] Source behavior completeness: [P1: N behaviors, P2: N behaviors] (rebuild only)
  - [ ] Data dependency verification: [list each "Blocked by ←" data source to probe at runtime] (Step 1c)
  - [ ] Interaction chain completeness: [list each chain to verify] (UI Features only)
  - [ ] UX behavior contract: [list each temporal scenario to verify] (async UI Features only)
  - [ ] Enablement interfaces: [list each "Enables →" entry to verify]
  - [ ] Blocked-by prerequisites: [list each "Blocked by ←" status]
  - [ ] API compatibility matrix: [list each provider to verify — auth, endpoints, headers] (if plan.md has API Compat Matrix)
  - [ ] Integration contracts: [list each cross-Feature boundary — interface, shapes, bridge] (if plan.md has Integration Contracts)
  - [ ] Foundation regression: [check Foundation decisions not overridden] (all Features)

── Micro-Interaction Completeness (frontend/fullstack) ─
  - If Interaction Behavior Inventory exists in pre-context: cross-reference P1/P2 interactions against implemented code
  - Check: Are tooltip components rendered? Are keyboard shortcuts registered? Are CSS transitions/animations present? Are focus traps working? Are drag-and-drop handlers wired?
  - Use the extended verify vocabulary (hover, press-key, drag-to, focus, verify-tooltip, right-click, verify-animation) in SC verification
  - Missing P1 interactions: classify as Major-Implement (interaction contract broken)
  - Missing P2 interactions: classify as Minor (can fix inline, ≤2 files)
  - If no Interaction Behavior Inventory exists: skip this check

── Foundation Regression Check ───────────────────
  (All Features, not just T0):
  - Check: Does this Feature's implementation break any Foundation decision?
  - For T0 Features: verify Foundation items in this category are correctly implemented
  - For T1+ Features: verify Foundation constraints are respected (not overridden)
  - Foundation regressions are classified as Major-Implement (not Minor)
  - If no Foundation decisions apply: skip this section

── Phase 3: Demo-Ready Verification ──────────────
[Only if Demo-Ready Delivery is active (constitution OR existing demos/). Omit this section otherwise.]
  SC Verification Matrix ([N] SCs from spec.md):
    cdp-auto: [N] SCs — [list SC-### to verify via browser automation]
    api-auto: [N] SCs — [list SC-### to verify via HTTP client] (if http-api interface)
    cli-auto: [N] SCs — [list SC-### to verify via process execution] (if cli interface)
    pipeline-auto: [N] SCs — [list SC-### to verify via pipeline runner] (if data-io interface)
    test-covered: [N] SCs — [list SC-### covered by Phase 1 tests]
    user-assisted: [N] SCs — [list SC-### + what user must provide]
    external-dep: [N] SCs — [list SC-### + skip reason]
    manual: [N] SCs
    Planned coverage: [auto + test-covered]/[total] = [N]%
  Runtime backend: [RUNTIME_BACKEND value from Pre-flight] ([cli = standard / mcp = accelerator])
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
  - [ ] Navigation transition sanity check: [layout consistency across Feature pages] (Step 3c, GUI only)
  - [ ] Interactive runtime verification: [SCs to verify via RUNTIME_BACKEND] (Step 3d)
  - [ ] Source app comparative verification: [side-by-side comparison] (Step 3e, rebuild only)
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

**Execution Evidence Requirement** (🚫 BLOCKING — Review without evidence is invalid):

Every verify Review MUST contain **execution evidence, not agent claims**. The distinction:
- ❌ **Claim**: "Cross-Feature: No regressions" (agent's assertion without proof)
- ✅ **Evidence**: "Cross-Feature: ran `vitest --filter F001` — 12/12 passed (exit code 0)"
- ❌ **Claim**: "Smoke Launch ✅" (may be `pnpm run dev & sleep; kill`)
- ✅ **Evidence**: "Playwright `_electron.launch()` → `accessibility.snapshot()` returned 47 nodes, ChatHeader element found"
- ❌ **Claim**: "Demo ✅" (may be file creation only)
- ✅ **Evidence**: "Demo `--ci` exit code 0, 12s elapsed, 3/3 checks passed"

If a Phase was **actually executed**, the Review entry MUST include:
1. **What command/API was called** (Playwright launch, vitest, bash script)
2. **What the result was** (exit code, element count, pass/fail count)
3. **How long it took** (establishes that it actually ran, not instant-returned)

If a Phase was **skipped**, the Review entry MUST include `Skip Reason` (not just omitted).

**Display format**:
```
📋 Review: Verification results for [FID] - [Feature Name]

── Phase 1: Execution Verification ───────────────
  Tests: [passed count]/[total count] passed
  Build: [success/failure]
  Lint: [success/failure/not configured/skipped (not installed)]
  i18n: [N keys checked, N missing ❌ / all present ✅ / skipped (no i18n)]

── Phase 2: Cross-Feature Consistency ─────────────
[Results for each cross-verification point]
  - ✅/❌ Entity compatibility: [result]
  - ✅/❌ API contract compatibility: [result]
  - ✅/❌ Business rule consistency: [result]
  - Source behavior coverage: P1 [N]/[N] ([%]), P2 [N]/[N] ([%])
    [⚠️ Uncovered P1: funcA, funcB (if any)]
  - Data dependency verification: [N]/[N] data sources available at runtime (Step 1c)
    [⚠️ Empty data: embedding model not running — SCs reclassified to user-assisted (if any)]
  - Interaction chains: [N]/[N] complete [⚠️ Broken: FR-015 DOM Effect missing (if any)]
  - UX behavior contract: [N]/[N] scenarios verified
    [⚠️ Missing: auto-scroll not implemented, cleanup on unmount missing (if any)]
  - Enablement interfaces: [N]/[N] verified
    [⚠️ Failed: provider settings panel not interactive (if any)]
  - Blocked-by prerequisites: [N]/[N] verified
    [⚠️ F001-shell not verified yet (if any)]
  - API compatibility matrix: [N]/[N] providers verified
    [⚠️ Provider X: auth method mismatch (if any)]
  - Integration contracts: [N]/[N] boundaries verified
    [⚠️ F003-chat-core: bridge adapter NOT FOUND — useMCPStore → assistant format (if any)]

── Phase 3: Demo-Ready Verification ───────────────
[Only if Demo-Ready Delivery is active (constitution OR existing demos/)]
  - ✅/❌ Executable demo script exists (demos/F00N-name.sh)
  - ✅/❌ Demo script launches a real Feature environment (not test-only)
  - ✅/❌ Demo prints concrete "Try it" instructions for the user (≥ 2)
  - ✅/❌ --ci health check passed
  - ✅/❌ FR/SC Coverage mapping present (≥ 50% of spec FR/SC items)
  - ✅/❌ Demo Components header comment present
  - ✅/❌ Component markers present
  - VERIFY_STEPS: [N]/[N] SC functional tests passed
    [⚠️ SC-003 wait-for timeout (if any)]
  - Navigation transitions: [✅ consistent / ⚠️ layout deviation found] (Step 3c, GUI only)
  - Interactive runtime verification: [N]/[N] SCs verified via [RUNTIME_BACKEND] (Step 3d)
    [⚠️ SC-### failed: reason (if any)]
    [user-assisted: [N] SCs verified after user cooperation (if any)]
  - Source app comparison: [match/deviations found] (Step 3e, rebuild only)
  - Visual fidelity: [match/differences found] (rebuild only)
  - SC Verification Coverage: [verified]/[total] = [N]%
    ✅ cdp-auto: [N] verified [⚠️ SC-### failed: reason (if any)]
    ✅ api-auto: [N] verified (if http-api interface)
    ✅ cli-auto: [N] verified (if cli interface)
    ✅ pipeline-auto: [N] verified (if data-io interface)
    ✅ test-covered: [N]
    ✅ user-assisted: [N] verified after cooperation
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

⚠️ Source Modification Gate: ALL source modifications (Minor AND
Major) require user approval via HARD STOP before any files are edited.
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
4. **Stub Resolution Completeness Check**:
   - Scan all preceding Features' `SPEC_PATH/[NNN-feature]/stubs.md` for rows where `Dependent Feature` = current FID
   - For each matching stub, check if the stub location (`File:Line`) has been modified — compare the current code against the `Current (Stub)` description
   - Report results:
     - Resolved: `✅ Stub resolved: [File:Line] — [previous FID] stub replaced with real implementation`
     - Unresolved: `⚠️ Stub NOT resolved: [File:Line] — [Current (Stub)] still present (expected: [Target (Real)])`
   - If any stubs are unresolved and the Feature's spec/tasks included resolving them, flag as a verification gap (non-blocking — display warning, do not fail verify):
     ```
     ⚠️ [N] dependency stubs from preceding Features remain unresolved.
     These may need to be addressed in a follow-up task or the next Feature.
     ```
   - If no preceding stubs target this Feature: skip this check silently
5. **Interaction Surface Inventory Verification** (GUI Features only):
   - Read `SPEC_PATH/[NNN-feature]/interaction-surfaces.md` for the current Feature (generated at implement completion)
   - If Playwright was available during Phase 3, verify each Critical/High surface exists at runtime:
     - **Drag regions**: Check element with `-webkit-app-region: drag` exists and has expected dimensions
     - **Window controls**: Check minimize/maximize/close buttons are visible and clickable
     - **Navigation elements**: Check sidebar/tabs/breadcrumbs are present and functional
     - **Theme toggle**: Check toggle button exists and cycles themes
   - Report results:
     ```
     🎯 Interaction Surface Verification:
       ✅ Titlebar drag region: visible, 100% × 36px
       ✅ Window controls: 3 buttons visible
       ⚠️ Theme toggle: NOT FOUND at expected location (Titlebar.tsx)
     ```
   - If any Critical surface is missing: flag as a **blocking** verification failure (same severity as build failure)
   - If no `interaction-surfaces.md` exists: skip this check silently
6. **Demo Group Progress Update**:
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
