# Context Injection: Analyze

> Per-command injection rules for `/smart-sdd analyze [FID]`.
> For shared patterns (HARD STOP, Checkpoint, Missing/Sparse Content Handling), see [context-injection-rules.md](../context-injection-rules.md).

---

## Read Targets

| File | Section | Filtering |
|------|---------|-----------|
| `SPEC_PATH/[NNN-feature]/spec.md` | Entire file | Current Feature |
| `SPEC_PATH/[NNN-feature]/plan.md` | Entire file | Current Feature |
| `SPEC_PATH/[NNN-feature]/tasks.md` | Entire file | Current Feature |

## Injected Content

- `speckit-analyze` reads all three core artifacts (spec.md, plan.md, tasks.md) automatically
- No additional context injection needed (analyze operates on spec-kit's own artifacts)

## Checkpoint

```
📋 Analyze execution: [FID] - [Feature Name]
speckit-analyze will check consistency across spec.md, plan.md, and tasks.md.
Do you want to proceed?
```

## Coverage Severity Rules

FR→Task coverage gaps are classified by the following severity rules:

| Situation | Severity | Blocking? |
|-----------|----------|-----------|
| FR has **zero** mapped tasks | **CRITICAL** | ✅ BLOCKS implement — requirement will be entirely missed |
| FR has task(s) but a **functionally distinct sub-behavior** is entirely missing | **HIGH** | ❌ Non-blocking — strongly recommended to fix, user can override |
| FR has task(s) covering **core behavior** but **implementation detail** not explicit in task description | **MEDIUM** | ❌ Non-blocking — nice to have, can be resolved during implement |
| All FRs fully covered | — | — |

**Zero-task CRITICAL rule**: If any FR-### has no task mapped to it at all, this is a CRITICAL issue. The analyze step MUST block implementation until the user either:
- Adds a task covering the requirement, or
- Removes/merges the FR into another requirement

**HIGH rule**: If an FR has task(s) but a functionally distinct sub-behavior (user-visible action, state transition, or output) is entirely missing from all task descriptions. Example: FR says "export data with format selection" but no task mentions format selection — only export.

**MEDIUM rule**: If an FR has task(s) that cover the core behavioral intent but the task description doesn't specify implementation approach (e.g., visual preview method, data source, rendering technique). The agent can resolve these details during implement. Example: FR says "avatar style with visual previews" and a task covers avatar style, but doesn't specify how previews are rendered — this is MEDIUM, not HIGH.

---

## Review Display Content

> **⚠️ SUPPRESS spec-kit output**: `speckit-analyze` prints navigation messages — **never show these to the user**. Suppress ALL spec-kit navigation messages. Immediately proceed to the Review Display below. If context limit prevents continuing, show instead: `✅ speckit-analyze executed for [FID] - [Feature Name].\n💡 Type "continue" to review the results.`

After `speckit-analyze` completes:

**Files to read**:
1. `specs/{NNN-feature}/spec.md` — Re-read to cross-reference requirements coverage
2. `specs/{NNN-feature}/plan.md` — Re-read to cross-reference architecture alignment
3. `specs/{NNN-feature}/tasks.md` — Re-read to cross-reference task coverage
4. The analyze output itself (displayed by speckit-analyze during execution)

> Note: `speckit-analyze` produces its report as console output, not as a file. Capture and display the analysis results from the command execution output.

**Display format**:
```
📋 Review: Analysis report for [FID] - [Feature Name]
📄 Analyzed: specs/{NNN-feature}/spec.md, plan.md, tasks.md

── Analysis Summary ─────────────────────────────
[Show key metrics: total requirements, total tasks, coverage %,
 critical issues count, high/medium/low counts]

── CRITICAL Issues (if any) ─────────────────────
[List each CRITICAL finding with location and recommendation.
 These MUST be resolved before proceeding to implement.
 Includes: FR with zero mapped tasks, constitution violations, etc.]

── HIGH Issues (if any) ─────────────────────────
[List HIGH findings. Strongly recommended to address before proceeding.
 Includes: FR with partial task coverage.]

── MEDIUM/LOW Issues (if any) ──────────────────
[List remaining findings. User may proceed but should consider addressing.]

── Coverage Gaps ────────────────────────────────
[Requirements with no tasks (CRITICAL), partial coverage (HIGH),
 tasks with no requirements]

── Constitution Alignment ───────────────────────
[Any violations of constitution principles]

──────────────────────────────────────────────────
```

**If CRITICAL issues exist** (including FR with zero tasks):
- Display: "❌ CRITICAL issues found. These must be resolved before implementation."
- Do NOT allow proceeding to implement until CRITICAL issues are addressed

**Display for all cases** (append after the analysis summary):
```
── Files You Can Edit ─────────────────────────
  📄 specs/{NNN-feature}/spec.md
  📄 specs/{NNN-feature}/plan.md
  📄 specs/{NNN-feature}/tasks.md
If issues were found, you can edit the source artifacts
directly, then select "I've finished editing" to re-analyze.
──────────────────────────────────────────────────
```

**HARD STOP** (ReviewApproval):
- If CRITICAL issues: Options: "Resolve now", "I've finished editing", "View full report"
- If no CRITICAL issues: Options: "Approve", "Address issues first", "I've finished editing"

**If response is empty → re-ask** (per MANDATORY RULE 1).

---

## Bug Prevention Checks (B-2)

> Pre-detect cross-Feature potential bugs at the analyze stage.
> Verify items below in addition to speckit-analyze results.
> **Result classification**: ⚠️ warning (NOT blocking) — findings are included in the Review Display as recommendations. They do not block implementation.

### Cross-Feature Data Flow

- **Inter-Feature Data Dependencies**: Verify data flow direction from entity-registry "Used by Features" relationships
- **Initialization Order**: When Feature A depends on Feature B's data, confirm A safely handles absence of B's data in initial state
- **Event Propagation**: Check handling of missing sender / unregistered receiver cases in cross-Feature event propagation

### Nullable Field Tracking

- **Shared Interface Optional Fields**: Confirm optional fields in shared entities (entity-registry) are safely accessed by consuming Features
- **Type Narrowing**: Verify type guard / optional chaining strategy for nullable field access

---

## Post-Step Update Rules

Update `sdd-state.md` per generic step-completion rules in [state-schema.md](../state-schema.md). Record analysis results (issue count, severity) in Feature Detail Log. No Global Evolution Layer artifact updates.
