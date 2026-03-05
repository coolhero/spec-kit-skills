# Context Injection: Analyze

> Per-command injection rules for `/smart-sdd analyze [FID]`.
> For shared patterns (HARD STOP, Checkpoint, --auto, Missing/Sparse Content Handling), see [context-injection-rules.md](../context-injection-rules.md).

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

## Review Display Content

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
 These MUST be resolved before proceeding to implement.]

── HIGH/MEDIUM Issues (if any) ──────────────────
[List significant findings. User may proceed but should consider addressing.]

── Coverage Gaps ────────────────────────────────
[Requirements with no tasks, tasks with no requirements]

── Constitution Alignment ───────────────────────
[Any violations of constitution principles]

──────────────────────────────────────────────────
```

**If CRITICAL issues exist**:
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

---

## Post-Step Update Rules

Update `sdd-state.md` per generic step-completion rules in [state-schema.md](../state-schema.md). Record analysis results (issue count, severity) in Feature Detail Log. No Global Evolution Layer artifact updates.
