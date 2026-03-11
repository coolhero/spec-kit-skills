# Context Injection: Tasks

> Per-command injection rules for `/smart-sdd tasks [FID]`.
> For shared patterns (HARD STOP, Checkpoint, Missing/Sparse Content Handling), see [context-injection-rules.md](../context-injection-rules.md).

---

## Read Targets

| File | Section | Filtering |
|------|---------|-----------|
| `SPEC_PATH/[NNN-feature]/plan.md` | Entire file | Current Feature |
| `BASE_PATH/features/[FID]-[name]/pre-context.md` | "Source Reference" section | **Rebuild/adoption mode only** — for Source Complexity Annotation. Resolve file paths per `injection/specify.md` Source Reference Path Resolution rules |

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

> **⚠️ SUPPRESS spec-kit output**: `speckit-tasks` prints navigation messages like "Ready for /speckit.implement" — **never show these to the user**. Suppress ALL spec-kit navigation messages. Immediately proceed to the Review Display below. If context limit prevents continuing, show instead: `✅ speckit-tasks executed for [FID] - [Feature Name].\n💡 Type "continue" to review the results.`

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

**Integration wiring task injection check** (if Feature has cross-boundary data flow):

Detect cross-boundary flow: scan plan.md / tasks.md / pre-context.md for patterns indicating multi-layer data flow:
- Renderer → IPC → Main process (Electron/Tauri keywords: "ipcRenderer", "ipcMain", "invoke", "handle", "preload")
- Frontend → Backend API (keywords: "fetch", "axios", "API call", "endpoint", "REST", "GraphQL")
- Service → External API (keywords: "embeddings", "OpenAI", "external API", "third-party", "webhook")
- File I/O across process boundaries (keywords: "file upload", "file picker", "drag and drop", "file processing")
- Multi-stage pipeline (keywords: "pipeline", "processing chain", "transform", "loader → embedder → store")

If cross-boundary flow detected, scan tasks.md for integration wiring tasks (keywords: "end-to-end", "e2e", "wire", "connect", "integration flow", "data flow", "full path", "pipeline test"). If **no integration wiring tasks are found**, append:

```
── ⚠️ Integration Wiring Task Missing ─────────────
This Feature has cross-boundary data flow but tasks.md has no
end-to-end wiring task. Module-level tasks build each component
independently, but nobody verifies the full data path works together.

Without an explicit wiring task, implement will produce modules that
individually "work" but are never connected end-to-end. This was the
root cause of 12 bugs in F007 Knowledge Base.

Recommended tasks to add:
  1. E2E data flow wiring: verify data passes through ALL layers
     (e.g., file upload → processing → storage → retrieval → display)
  2. API contract cross-check: verify function names, argument formats,
     and return types match across module boundaries (caller ↔ callee)

Add these tasks now or add them during the "I've finished editing" step.
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

**Visual verification task injection check** (only if Feature has UI components AND rebuild mode — detected from plan.md architecture or pre-context tech stack):
After reading tasks.md, scan the task list for visual verification tasks (keywords: "visual verif", "screenshot", "playwright", "visual comparison", "visual check", "UI comparison", "layout verif", "visual fidelity"). If **no visual verification tasks are found**, append:

```
── ⚠️ Visual Verification Task Missing ─────────────
This Feature has UI components (rebuild mode) but tasks.md has no
visual verification task. Without explicit visual checks, the rebuilt
UI may diverge from the original (wrong layout, missing elements,
incorrect spacing/colors).

Recommended task to add (insert after main UI implementation tasks):
  1. Visual fidelity check: compare key screens against visual-references/
     screenshots. Verify layout structure, element count (tabs, buttons),
     and spacing match the original.

Add this task now or add it during the "I've finished editing" step.
────────────────────────────────────────────────────
```

**Source complexity annotation** (rebuild/adoption mode — skip if greenfield):
After reading tasks.md, if pre-context.md has a "Source Reference" section with original files:
1. Read the original file sizes (line counts) from the Source Reference list
2. If tasks seem significantly under-scoped relative to original complexity, append:

```
── ℹ️ Source Complexity Reference ───────────────────
Original source files for this Feature:
  [filename.tsx]: [N] lines → estimated [M] tasks
  [filename.tsx]: [N] lines → estimated [M] tasks
  Total original: ~[N] lines across [M] files

Current tasks.md: [T] tasks
If tasks seem under-scoped, consider adding more granular
implementation tasks for complex source files.
────────────────────────────────────────────────────
```

> **Estimation heuristic**: ~100 lines of original source ≈ 1 implementation task (varies by complexity). Files over 300 lines typically need 3+ tasks.

**Interaction Chain task injection check** (only if plan.md contains an `## Interaction Chains` section):
After reading tasks.md, scan for tasks that address the full chain propagation (keywords: "interaction chain", "DOM effect", "store mutation", "visual result", "propagation", "classList", "style."). If tasks only mention handlers (e.g., "implement onThemeChange") but NOT the DOM/visual steps, append:

```
── ⚠️ Interaction Chain Tasks Incomplete ────────────
Interaction Chains are defined in plan.md but tasks.md only covers handlers —
DOM effects and visual results are missing as explicit tasks.

Each chain row should generate tasks for the FULL propagation:
  Handler → Store Mutation → DOM Effect → Visual Result

Missing chain steps:
  FR-012 (theme toggle): ❌ No task for body.classList.add('dark')
  FR-015 (font size):    ❌ No task for body.style.fontSize assignment

Add DOM/visual tasks now or during the "I've finished editing" step.
────────────────────────────────────────────────────
```

**UX Behavior Contract task injection check** (only if plan.md contains a `## UX Behavior Contract` section):
After reading tasks.md, scan for async UX behavior tasks (keywords: "auto-scroll", "loading state", "spinner", "error recovery", "cleanup", "unmount", "streaming", "loading indicator", "abort"). If **no UX behavior tasks are found**, append:

```
── ⚠️ UX Behavior Tasks Missing ───────────────────
UX Behavior Contract is defined in plan.md but tasks.md has no
explicit tasks for temporal UX patterns.

Each contract row should generate implementation tasks:
  - Streaming auto-scroll → task: "Implement auto-scroll during streaming"
  - Loading state → task: "Implement loading spinner show/hide"
  - Error recovery → task: "Implement error toast + input re-enable"
  - Cleanup on unmount → task: "Implement stream abort on component unmount"

Without explicit tasks, the agent implements the function but not the experience.
Add UX behavior tasks now or during the "I've finished editing" step.
────────────────────────────────────────────────────
```

**API Compatibility Matrix task injection check** (only if plan.md contains an `## API Compatibility Matrix` section):
After reading tasks.md, scan for per-provider tasks (keywords: provider names from the matrix, "provider adapter", "auth method", "per-provider", "API compatibility"). If tasks only mention one provider or use generic "API integration", append:

```
── ⚠️ Per-Provider Tasks Missing ──────────────────
API Compatibility Matrix is defined in plan.md with [N] providers
but tasks.md does not have per-provider implementation tasks.

Each provider should have explicit tasks:
  - OpenAI: auth (Bearer), endpoints (/v1/chat/completions), response parsing
  - Anthropic: auth (x-api-key + version header), endpoints (/v1/messages), response parsing
  - Ollama: no-auth local mode, endpoints (/api/chat), response parsing

Without per-provider tasks, one provider's pattern gets applied to all.
Add provider-specific tasks now or during the "I've finished editing" step.
────────────────────────────────────────────────────
```

**SDK Migration task injection check** (only if plan.md contains an `## SDK Migration Awareness` section or mentions SDK version upgrade):
After reading tasks.md, scan for SDK migration tasks (keywords: "SDK migration", "breaking change", "API rename", "version upgrade", "deprecated"). If **no SDK migration tasks are found**, append:

```
── ⚠️ SDK Migration Tasks Missing ─────────────────
SDK version upgrade detected in plan.md but tasks.md has no
"SDK API contract verification" task.

Recommended task: verify each breaking change was handled:
  - API renames applied (e.g., textDelta → text)
  - Default behavior changes accounted for
  - Deprecated APIs replaced

Add this task now or during the "I've finished editing" step.
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

── ⚠️ Visual Verification Task Missing ─────────────
[Only if Feature has UI components (rebuild mode) AND tasks.md has no
 visual verification task (keywords: "visual verif", "screenshot",
 "playwright", "visual comparison", "visual check", "UI comparison",
 "layout verif", "visual fidelity")]

── ℹ️ Source Complexity Reference ───────────────────
[Only if rebuild/adoption mode AND pre-context has Source Reference files.
 Shows original file sizes and estimated task count comparison]

── ⚠️ Interaction Chain Tasks Incomplete ──────────
[Only if plan.md has Interaction Chains AND tasks.md only covers
 handlers without DOM effect/visual result tasks]

── ⚠️ UX Behavior Tasks Missing ──────────────────
[Only if plan.md has UX Behavior Contract AND tasks.md has no
 explicit tasks for temporal UX patterns (auto-scroll, loading,
 error recovery, cleanup)]

── ⚠️ Per-Provider Tasks Missing ─────────────────
[Only if plan.md has API Compatibility Matrix AND tasks.md has
 no per-provider implementation tasks]

── ⚠️ SDK Migration Tasks Missing ────────────────
[Only if plan.md mentions SDK version upgrade AND tasks.md has
 no SDK migration verification task]

── ⚠️ Feature Size Warning ───────────────────────
[Only if task count > 100 OR estimated file count > 50]

── Files You Can Edit ─────────────────────────
  📄 specs/{NNN-feature}/tasks.md
You can open and edit this file directly, then select
"I've finished editing" to continue.
──────────────────────────────────────────────────
```

**HARD STOP** (ReviewApproval): Options: "Approve", "Request modifications", "I've finished editing". **If response is empty → re-ask** (per MANDATORY RULE 1).

---

## Post-Step Update Rules

Update `sdd-state.md` per generic step-completion rules in [state-schema.md](../state-schema.md). No Global Evolution Layer artifact updates.
