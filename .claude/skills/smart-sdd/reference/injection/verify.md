# Context Injection: Verify

> Per-command injection rules for `/smart-sdd verify [FID]`.
> For shared patterns (HARD STOP, Checkpoint, --auto, Missing/Sparse Content Handling), see [context-injection-rules.md](../context-injection-rules.md).
> For the full verification workflow (Phase 1-4 execution details), see [pipeline.md](../../commands/pipeline.md) § Verify Command.

**BASE_PATH**: `./specs/reverse-spec/` relative to CWD (or the path specified with `--from`)
**SPEC_PATH**: `./specs/` relative to CWD (spec-kit feature output path. Format: `specs/{NNN-feature}/`)

---

> **Note**: `speckit-analyze` is NOT used in this step. Cross-artifact consistency (spec ↔ plan ↔ tasks) was already verified in step 5 (Analyze) before implementation. This step focuses on post-implementation validation.

> **Greenfield/add note**: For greenfield or add-origin projects, cross-Feature verification points in pre-context.md may be limited to dependency-based checks only (no source-code-derived verification points). The verify command works the same way — it just has fewer pre-defined verification items.

## Read Targets

| File | Section | Filtering |
|------|---------|-----------|
| `BASE_PATH/features/[FID]-[name]/pre-context.md` | "For /speckit.analyze" section | Cross-Feature verification points (entity compatibility, API contracts) |
| `BASE_PATH/features/[FID]-[name]/pre-context.md` | "Source Behavior Inventory" section | **If present (rebuild mode)** — for behavior completeness check |
| `BASE_PATH/entity-registry.md` | Entities modified by the Feature | Change tracking |
| `BASE_PATH/api-registry.md` | APIs modified by the Feature | Change tracking |
| `SPEC_PATH/[NNN-feature]/spec.md` | FR-### list | For behavior completeness cross-reference |
| `SPEC_PATH/[NNN-feature]/` | data-model.md, contracts/ | Actual implementation results |

## Injected Content

- **Cross-Feature verification points**: Cross-verification checklist from pre-context (entity compatibility, API contract compatibility, business rule consistency)
- **Source behavior completeness**: If Source Behavior Inventory exists in pre-context, cross-reference P1/P2 behaviors against FR-### in spec.md to detect uncovered functionality
- **Impact scope analysis**: List of other Features referencing the modified entities/APIs
- **Implementation consistency verification**: Whether entity-registry/api-registry matches the actual implemented code

## Checkpoint Display Content

Show the **actual verification checklist** so the user can see what will be checked:

```
📋 Verify execution: [FID] - [Feature Name]

── Phase 1: Execution Verification ───────────────
  - Test command: [actual test command]
  - Build command: [actual build command]
  - Lint command: [actual lint command or "not configured"]

── Phase 2: Cross-Feature Verification ───────────
[List each cross-verification point from pre-context]
  - [ ] Entity compatibility: [specific check]
  - [ ] API contract compatibility: [specific check]
  - [ ] Business rule consistency: [specific check]
  - [ ] Source behavior completeness: [P1: N behaviors, P2: N behaviors] (rebuild only)

── Phase 3: Demo-Ready Verification ──────────────
[Only if VI. Demo-Ready Delivery is in the constitution. Omit this section otherwise.]
  - [ ] Executable demo script exists (demos/F00N-name.sh or .ts/.py/etc.)
  - [ ] Demo script is NOT markdown and NOT a test-only script
  - [ ] Demo launches a real, working Feature environment (not just assertions)
  - [ ] Demo prints concrete "Try it" instructions (URLs, commands) for the user (≥ 2)
  - [ ] --ci flag works: health check passes and exits cleanly
  - [ ] FR/SC Coverage header maps spec.md FR-###/SC-### to what the user can try
  - [ ] Coverage ≥ 50% of FR/SC items (warn if below)
  - [ ] Demo Components header comment with Category and Fate
  - [ ] Component markers (@demo-only / @demo-scaffold)

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

After verification execution completes:

**Display format**:
```
📋 Review: Verification results for [FID] - [Feature Name]

── Phase 1: Execution Verification ───────────────
  Tests: [passed count]/[total count] passed
  Build: [success/failure]
  Lint: [success/failure/not configured]

── Phase 2: Cross-Feature Consistency ─────────────
[Results for each cross-verification point]
  - ✅/❌ Entity compatibility: [result]
  - ✅/❌ API contract compatibility: [result]
  - ✅/❌ Business rule consistency: [result]
  - Source behavior coverage: P1 [N]/[N] ([%]), P2 [N]/[N] ([%])
    [⚠️ Uncovered P1: funcA, funcB (if any)]

── Phase 3: Demo-Ready Verification ───────────────
[Only if Demo-Ready Delivery is in the constitution]
  - ✅/❌ Executable demo script exists (demos/F00N-name.sh)
  - ✅/❌ Demo script launches a real Feature environment (not test-only)
  - ✅/❌ Demo prints concrete "Try it" instructions for the user (≥ 2)
  - ✅/❌ --ci health check passed
  - ✅/❌ FR/SC Coverage mapping present (≥ 50% of spec FR/SC items)
  - ✅/❌ Demo Components header comment present
  - ✅/❌ Component markers present

── Phase 4: Global Evolution Consistency ───────────
  - entity-registry: [match/discrepancies found]
  - api-registry: [match/discrepancies found]

── Limited Verification (if applicable) ────────────
[Only shown if user acknowledged limited verification in Phase 1 or Phase 3]
  ⚠️ Phase 1: [reason] (or "N/A — passed normally")
  ⚠️ Phase 3: [reason] (or "N/A — passed normally")
  Overall status: limited (merge allowed with reminder)

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
- If any phase failed: Options: "Fix issues and re-verify", "I've finished editing", "Acknowledge limited verification"
- If all phases passed: Options: "Approve", "I've finished editing", "Re-run verification"
- If limited verification: Options: "Approve (with ⚠️ limited status)", "Fix issues and re-verify", "I've finished editing"

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
     Options: "Run Integration Demo", "Defer Integration Demo"

### After Merge Completion

1. Update `BASE_PATH/sdd-state.md`:
   - Record the merge step as completed in Feature Progress and Feature Detail Log
   - Update Feature Mapping: record the Branch name and mark Merged as ✅
   - Change the Feature Status to `completed` (or `adopted` if adoption mode — see adopt-verify.md)
   - Record in Global Evolution Log: "Branch {NNN}-{short-name} merged to main"
2. Verify that main branch is clean after merge (`git status`)
3. The next Feature's `specify` step can now be started from the main branch
