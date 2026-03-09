# Context Injection: Tasks

> Per-command injection rules for `/smart-sdd tasks [FID]`.
> For shared patterns (HARD STOP, Checkpoint, Missing/Sparse Content Handling), see [context-injection-rules.md](../context-injection-rules.md).

---

## Read Targets

| File | Section | Filtering |
|------|---------|-----------|
| `SPEC_PATH/[NNN-feature]/plan.md` | Entire file | Current Feature |

## Injected Content

- Automatically executes `speckit-tasks` based on plan.md
- No additional context injection (all information is already included in the plan)

## Checkpoint

Only a simplified checkpoint is displayed:
```
📋 Tasks generation: [FID] - [Feature Name]
speckit-tasks will be executed based on plan.md. Do you want to proceed?
```

## Review Display Content

After `speckit-tasks` completes:

**Files to read**:
1. `specs/{NNN-feature}/tasks.md` — Read the **entire file** and extract the task list

**Demo task injection check** (only if VI. Demo-Ready Delivery is in the constitution; see [demo-standard.md](../demo-standard.md) for full demo requirements):
After reading tasks.md, scan the task list for demo-related tasks (keywords: "demo", "demo script", "demo data", "demo route", "demo page", "demo fixture", "demos/"). If **no demo tasks are found**, append a warning block to the Review display:

```
── ⚠️ Demo Tasks Missing ──────────────────────────
Demo-Ready Delivery is active but tasks.md has no demo tasks.
Deferring demo work causes "batch-at-the-end" anti-pattern.

Recommended tasks to add (insert after the last implementation task):
  1. Create demo data fixtures (seed data for the demo)
  2. Create demo surface (demo route/page/CLI wrapper that launches the Feature)
  3. Write executable demo script (demos/F00N-name.sh)

Add these tasks now or add them during the "I've finished editing" step.
────────────────────────────────────────────────────
```

> **Rationale**: Demo surfaces (routes, pages, data fixtures) should be built incrementally during `implement`, not deferred until all Features are complete. Injecting demo tasks into `tasks.md` at this stage prevents the "batch-at-the-end" anti-pattern where demo code is rushed or skipped.

**Pattern Audit task injection check** (only if plan.md contains a `## Pattern Constraints` section):
After reading tasks.md, scan the task list for pattern-audit-related tasks (keywords: "pattern constraint", "pattern audit", "selector", "reference equality", "layout effect", "error boundary", "anti-pattern"). If **no pattern audit tasks are found**, append:

```
── ⚠️ Pattern Audit Task Missing ──────────────────
Pattern Constraints are defined in plan.md but tasks.md has no audit task.
Without an explicit task, pattern constraints may be forgotten during implement.

Recommended task to add (insert before the last implementation phase):
  1. Pattern Audit: verify all components comply with Pattern Constraints
     - Check selector reference stability (no new array/object per call)
     - Check DOM measurement effect timing (useLayoutEffect, not useEffect)
     - Check Error Boundary coverage (every route/page wrapped)

Add this task now or add it during the "I've finished editing" step.
────────────────────────────────────────────────────
```

**Integration test task injection check** (only if Feature has UI components — detected from plan.md architecture or pre-context tech stack):
After reading tasks.md, scan for integration/render test tasks (keywords: "render test", "integration test", "component test", "mount test", "smoke test", "rendering test"). If **no integration test tasks are found**, append:

```
── ⚠️ Integration Test Task Missing ───────────────
This Feature has UI components but tasks.md has no render/integration test.
Unit tests with mocked stores cannot catch selector instability, layout
timing bugs, or infinite re-render loops.

Recommended task to add (insert after main implementation tasks):
  1. Integration smoke test: mount key components with real store state,
     verify renders without infinite loops, console errors, or layout flicker

Add this task now or add it during the "I've finished editing" step.
────────────────────────────────────────────────────
```

**Feature size warning** (always checked):
After reading tasks.md, count the total number of tasks. Also read plan.md to estimate file count from architecture/phases:

```
── ⚠️ Feature Size Warning ────────────────────────
[Only shown if thresholds exceeded]

Task count: [N] tasks (threshold: 100)
  ⚠️ Features with 100+ tasks risk inconsistent patterns across parallel
  agents and are hard to verify. Consider splitting into sub-Features
  via /smart-sdd add.

Estimated file count: [N] files (threshold: 50)
  ⚠️ Features touching 50+ files are hard to review and test holistically.
  Consider splitting along module boundaries.

These are recommendations, not blockers. Proceed if the Feature is inherently large.
────────────────────────────────────────────────────
```

**Display format**:
```
📋 Review: tasks.md for [FID] - [Feature Name]
📄 File: specs/{NNN-feature}/tasks.md

── Task List ────────────────────────────────────
[List each task with:
 - Task number and name
 - Description
 - Dependencies (which tasks must complete first)
 - Estimated complexity (if available)]

── ⚠️ Demo Tasks Missing ──────────────────────────
[Only if Demo-Ready Delivery active AND no demo tasks found in tasks.md]

── ⚠️ Pattern Audit Task Missing ─────────────────
[Only if plan.md has a Pattern Constraints section AND tasks.md has no
 pattern-audit-related task (keywords: "pattern constraint", "pattern audit",
 "selector", "reference equality", "layout effect", "error boundary", "anti-pattern")]

── ⚠️ Integration Test Task Missing ──────────────
[Only if Feature has UI components (detected from plan.md architecture or
 pre-context tech stack) AND tasks.md has no render/integration test task
 (keywords: "render test", "integration test", "component test", "mount test",
  "smoke test", "rendering test")]

── ⚠️ Feature Size Warning ───────────────────────
[Only if task count > 100 OR estimated file count > 50]

── Files You Can Edit ─────────────────────────
  📄 specs/{NNN-feature}/tasks.md
You can open and edit this file directly, then select
"I've finished editing" to continue.
──────────────────────────────────────────────────
```

**HARD STOP** (ReviewApproval): Options: "Approve", "Request modifications", "I've finished editing"

---

## Post-Step Update Rules

Update `sdd-state.md` per generic step-completion rules in [state-schema.md](../state-schema.md). No Global Evolution Layer artifact updates.
