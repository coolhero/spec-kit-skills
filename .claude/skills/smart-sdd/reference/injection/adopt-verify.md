# Context Injection: Adopt — Verify

> Per-command injection rules for the **verify** step within `/smart-sdd adopt`.
> This is a variant of the standard `verify` injection — test failures are non-blocking (pre-existing issues), and Feature status is set to `adopted` instead of `completed`.
> For shared patterns (HARD STOP, Checkpoint, Missing/Sparse Content Handling), see [context-injection-rules.md](../context-injection-rules.md).

---

## Key Difference from Standard Verify

Standard verify: Test/build failures **BLOCK** the merge step. Feature status → `completed`.
Adopt verify: Test failures are recorded as **"pre-existing issues" (non-blocking)**. Feature status → `adopted`.

---

## Read Targets

Same as standard verify:

| File | Section | Filtering |
|------|---------|-----------|
| `BASE_PATH/features/[FID]-[name]/pre-context.md` | "For /speckit.analyze" section | Cross-Feature verification points |
| `BASE_PATH/features/[FID]-[name]/pre-context.md` | "Source Behavior Inventory" section | For SBI coverage check |
| `BASE_PATH/entity-registry.md` | Entities modified by the Feature | Change tracking |
| `BASE_PATH/api-registry.md` | APIs modified by the Feature | Change tracking |
| `SPEC_PATH/[NNN-feature]/spec.md` | FR-### list | For SBI → FR mapping verification |
| `SPEC_PATH/[NNN-feature]/` | data-model.md, contracts/ | Actual documentation results |

---

## Injected Content

Same structure as standard verify, with adoption-specific behavior overrides:

- **Cross-Feature verification points**: Same as standard
- **Source behavior completeness**: Cross-reference P1/P2 SBI entries against FR-### with `[source: B###]` tags
- **Impact scope analysis**: Same as standard
- **Implementation consistency**: Same as standard

---

## Checkpoint Display Content

```
📋 Verify execution: [FID] - [Feature Name]
Mode: ADOPTION — Non-blocking verification

── Phase 1: Execution Verification (NON-BLOCKING) ──
  ⚠️ ADOPTION MODE: Test/build failures are recorded as
  pre-existing issues, NOT blockers.
  - Test command: [actual test command]
  - Build command: [actual build command]
  - Lint command: [actual lint command or "not configured"]

── Phase 2: Cross-Feature Verification ───────────
[Same as standard — cross-verification points from pre-context]
  - [ ] Entity compatibility: [specific check]
  - [ ] API contract compatibility: [specific check]
  - [ ] SBI coverage: [P1: N entries, P2: N entries]

── Phase 3: Demo-Ready Verification ──────────────
⏭️ SKIP — Adoption mode does not create per-Feature demos.
  (Project-level demo is created in Post-Pipeline: Final Demo instead)

── Phase 4: Global Evolution Consistency ─────────
[Same as standard — entity/API registry consistency]

──────────────────────────────────────────────────
```

---

## Phase 1 — Adoption-Specific Behavior

### Test Failures

| Situation | Standard Verify | Adopt Verify |
|-----------|----------------|--------------|
| Tests fail | ❌ BLOCKS merge | ⚠️ Record as "pre-existing issue" — **non-blocking** |
| No tests exist | ❌ BLOCKS merge (Test-First) | 📝 Record as "no tests" — **non-blocking** |
| Build fails | ❌ BLOCKS merge | ⚠️ Record as "pre-existing build issue" — **non-blocking** |
| Lint fails | ⚠️ Warning | ⚠️ Record as "pre-existing lint issue" — **non-blocking** |

### Recording Format

For each non-blocking issue, record in `sdd-state.md` Feature Detail Log notes:
```
⚠️ PRE-EXISTING: [N] test failures, [M] lint warnings
📝 NO TESTS: No test suite found for this Feature
```

---

## Review Display Content

> **⚠️ SUPPRESS spec-kit output**: Verification prints navigation messages — **never show these to the user**. Suppress ALL spec-kit navigation messages. Immediately proceed to the Review Display below. If context limit prevents continuing, show instead: `✅ Verification executed for [FID] - [Feature Name].\n💡 Type "continue" to review the results.`

After verification execution completes:

```
📋 Review: Verification results for [FID] - [Feature Name] (Adoption)

── Phase 1: Execution Verification (NON-BLOCKING) ──
  Tests: [passed]/[total] passed
    [If failures]: ⚠️ [N] failures recorded as pre-existing issues
    [If no tests]: 📝 No test suite — recorded as baseline
  Build: [success/failure]
    [If failure]: ⚠️ Build failure recorded as pre-existing issue
  Lint: [success/failure/not configured]

── Phase 2: Cross-Feature Consistency ─────────────
  - ✅/❌ Entity compatibility: [result]
  - ✅/❌ API contract compatibility: [result]
  - SBI coverage: P1 [N]/[N] ([%]), P2 [N]/[N] ([%])
    [⚠️ Unmapped P1: B### — funcName (if any)]

── Phase 3: Demo-Ready Verification ───────────────
Skipped — Adoption mode does not create per-Feature demos (existing code verified as-is).

── Phase 4: Global Evolution Consistency ───────────
  - entity-registry: [match/discrepancies]
  - api-registry: [match/discrepancies]

── Adoption Summary ─────────────────────────────────
  Status: adopted (NOT completed)
  Pre-existing issues: [N] test failures, [M] build issues
  SBI coverage: P1 [%], P2 [%]
  ℹ️ This Feature's code is wrapped with SDD docs but may have
  pre-existing issues. Use standard pipeline to resolve them later.

──────────────────────────────────────────────────
```

**HARD STOP** (ReviewApproval):
- Options: "Approve (status: adopted)", "Fix issues and re-verify", "I've finished editing"
- Note: "Approve" sets status to `adopted`, NOT `completed`

**If response is empty → re-ask** (per MANDATORY RULE 1).

---

## Post-Step Update Rules

### After Verify Completion

1. Same registry verification as standard verify
2. Record verification results in `sdd-state.md`:
   - Test results with pre-existing issue annotations
   - Build results
   - Cross-Feature verification results
   - Verify step result: `success` / `limited` / `failure` (same as standard verify)
   - Feature Progress Status: `adopted` (NOT `completed` — set after merge, per state-schema.md)
   - Notes: `⚠️ PRE-EXISTING: [details]` or `📝 NO TESTS`
3. Update Source Behavior Coverage in `sdd-state.md`:
   - For each FR-### with `[source: B###]` tag that passed cross-reference:
     - Status: `✅ verified`
   - For unmapped SBI entries: Status remains `❌ unmapped`

### After Merge Completion

1. Update `sdd-state.md`:
   - Record merge step as completed
   - **Feature Status → `adopted`** (NOT `completed`)
   - Record in Global Evolution Log: "Branch {NNN}-{short-name} merged to main (adopted)"
2. Update Demo Group Progress in `sdd-state.md`:
   - If this Feature belongs to a Demo Group, update the Completed count
   - Check Integration Demo trigger: if all Features in the group are `completed` or `adopted`, trigger Integration Demo HARD STOP
3. Verify main branch is clean after merge
