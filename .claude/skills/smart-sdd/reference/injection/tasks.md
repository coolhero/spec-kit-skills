# Context Injection: Tasks

> Per-command injection rules for `/smart-sdd tasks [FID]`.
> For shared patterns (HARD STOP, Checkpoint, --auto, Missing/Sparse Content Handling), see [context-injection-rules.md](../context-injection-rules.md).

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
