# Context Injection Rules — Shared Patterns

This document defines shared patterns that apply to ALL per-command context injection rules. For per-command details (Read Targets, Injected Content, Checkpoint/Review Display, Post-Step Update Rules), read the corresponding file in `injection/`.

## Per-Command Injection Rules

| Command | Injection Rules File |
|---------|---------------------|
| `constitution` | [`injection/constitution.md`](injection/constitution.md) |
| `specify` + `clarify` | [`injection/specify.md`](injection/specify.md) |
| `plan` | [`injection/plan.md`](injection/plan.md) |
| `tasks` | [`injection/tasks.md`](injection/tasks.md) |
| `analyze` | [`injection/analyze.md`](injection/analyze.md) |
| `implement` | [`injection/implement.md`](injection/implement.md) |
| `verify` | [`injection/verify.md`](injection/verify.md) |
| `parity` | [`injection/parity.md`](injection/parity.md) |
| `adopt` — specify | [`injection/adopt-specify.md`](injection/adopt-specify.md) |
| `adopt` — plan | [`injection/adopt-plan.md`](injection/adopt-plan.md) |
| `adopt` — verify | [`injection/adopt-verify.md`](injection/adopt-verify.md) |

---

## Shared Patterns

The following patterns apply to ALL commands:

**HARD STOP pattern**: Every Review section ends with a HARD STOP. The canonical procedure is defined in `commands/pipeline.md` Step 3 (PROCEDURE ReviewApproval). Per-command sections only specify the **options** — the LOOP/re-ask/empty-response handling is always the same.

**"Files You Can Edit" block**: Every Review display includes a "Files You Can Edit" block listing the exact artifact paths. The user can edit these files externally, then select "I've finished editing" to continue.

**Checkpoint pattern**: All Checkpoints are HARD STOPs per `commands/pipeline.md` Step 2 (PROCEDURE CheckpointApproval). Even simplified Checkpoints (single-line message) require AskUserQuestion and WAIT.

**Post-Execution Output Suppression**: After ANY spec-kit command completes, **suppress ALL spec-kit navigation messages** — never show them to the user. spec-kit prints its own next-step guidance (e.g., `"Ready for /speckit.plan"`, `"Ready for /speckit.clarify or /speckit.plan"`, `"Next phase: ..."`, `"Suggested commit: ..."`), but smart-sdd controls the workflow, not spec-kit. After suppressing the output, immediately proceed to the Review Display + HARD STOP. **If context limit prevents continuing in the same response**, display the fallback message instead of spec-kit's output:
```
✅ [command] executed for [FID] - [Feature Name].

💡 Type "continue" to review the results.
```

---

## Domain Module Loading Protocol (5 axes + 1 modifier)

Every pipeline command that uses Domain Profile rules (specify, plan, tasks, implement, verify) must load active modules **once per command session**. If modules are already cached from a previous step in the same session, skip reloading.

```
1. Read sdd-state.md header → extract 5 axes + 1 modifier:
   Axis 1 — **Interfaces**: [comma-separated list]
   Axis 2 — **Concerns**: [comma-separated list]
   Axis 3 — **Archetype**: [name or "none"]
   Axis 4 — **Framework**: [name or "none"] (Foundation)
   Axis 5 — **Scenario**: [greenfield | rebuild | incremental | adoption]
   Modifier — **Project Maturity**: [prototype | mvp | production]
   Modifier — **Team Context**: [solo | small-team | large-team]

2. Resolve via domains/_resolver.md Steps 1–5:
   - Load _core.md (always)
   - Load Axis 1: interfaces/{name}.md for each Interface
   - Load Axis 2: concerns/{name}.md for each Concern
   - Load Axis 3: archetypes/{name}.md if Archetype ≠ "none"
   - Load Axis 4: foundations/{framework}.md § F2 + _foundation-core.md § F3
   - Load org convention if specified
   - Load Axis 5: scenarios/{scenario}.md
   - Apply Step 3.5: Cross-Concern Integration Rules
   - Apply Step 4: Scale Modifier (adjusts rule depth per maturity/team)

3. Cache merged profile (5 axes + modifier) in working memory.

4. Sections available to injection files:
   - S1 SC Rules → specify (SC compliance check), verify (SC verification)
     └ Scale: prototype=functional-only, mvp=+error-paths, production=full
   - S5 Elaboration Probes → add (Brief elaboration)
     └ Scale: large-team adds collaboration/ownership probes
   - S6 Pattern Rules → plan (Pattern Constraints), implement (patterns)
   - S7 Bug Prevention → plan (prevention), implement (anti-patterns), verify (regression)
     └ Scale: prototype=disabled, production=all+observability
   - S9 Brief Completion → add (completeness criteria)
   - A4 Constitution → constitution (archetype principles)
   - A5 Brief Completion → add (archetype completeness criteria)
   - F2 Foundation Items → pipeline (T0 Feature generation)
   - F3 T0 Rules → pipeline (Foundation ordering + verification gate)
```

> Per-command injection files reference sections like "active modules' S1 rules" — this protocol defines exactly how those modules are loaded. Each injection file does NOT need to repeat the loading steps; they reference this protocol.

---

## Scale Modifier Enforcement (🚫 BLOCKING — must apply)

After domain modules are loaded (Step 3 + 3.5), read `Project Maturity` and `Team Context` from sdd-state.md and apply adjustments. **This is NOT optional** — Scale affects how rules are enforced at every pipeline step.

### Reading Scale Values

```
1. Read sdd-state.md header:
   **Project Maturity**: prototype | mvp | production  (default: mvp if absent)
   **Team Context**: solo | small-team | large-team     (default: solo if absent)

2. Record values for use in all subsequent steps.
```

### Per-Command Scale Adjustments

| Command | Maturity Effect | Team Context Effect |
|---------|----------------|---------------------|
| **specify** | `prototype`: SC depth = functional-only (skip performance/edge-case SCs). `mvp`: +key error-path SCs. `production`: full SC coverage including concurrency, performance, observability | No effect |
| **add** (Brief) | `prototype`: S9 completion criteria relaxed (endpoints optional for API, screens optional for GUI). `mvp`/`production`: full S9 | `large-team`: add S5 probes for code ownership, API contract review process |
| **plan** | `prototype`: S7 B-1 over-engineering guard active (warn if production-scale patterns in prototype). `production`: +observability requirements in architecture | `large-team`: add module ownership verification |
| **implement** | `prototype`: S7 B-3 checks = warning only (not blocking). `production`: all B-3 checks blocking + observability instrumentation required | No effect |
| **verify** | `prototype`: S3 tests = optional (encourage but don't block). `mvp`: tests required for critical paths only. `production`: comprehensive tests + performance benchmarks required | `large-team`: require PR review documentation in verify evidence |

### Checkpoint Display

Every Checkpoint MUST display Scale context:

```
📊 Scale: {maturity} / {team_context}
   → SC depth: {functional-only | +error-paths | full}
   → Test enforcement: {optional | critical-paths | comprehensive}
```

### Anti-Patterns

```
❌ WRONG: Load all S1 rules and enforce equally for prototype and production
   → prototype gets "must handle concurrent writes with optimistic locking" = over-engineering

✅ RIGHT: Load all S1 rules, but mark non-functional SCs as "(optional for prototype)"
   → user sees the rule exists but it won't block progress

❌ WRONG: Skip Scale reading because sdd-state.md doesn't have the fields
   → Default to mvp/solo and note in Checkpoint: "Scale: mvp/solo (default)"
```

---

## Cross-Concern Integration Enforcement

After individual modules are loaded (Step 3), check for active concern combinations that trigger emergent patterns. These patterns inject **additional** S1/S5/S7 rules beyond what individual modules provide.

### Procedure

```
1. Read active Interfaces, Concerns, and Archetype from merged profile.

2. FOR EACH row in _resolver.md § Step 3.5 table:
   IF ALL modules in the row's "Active Combination" are present in active profile:
     → Extract "Injected Rule" column
     → Append S1 rules to merged S1
     → Append S5 probes to merged S5
     → Append S7 rules to merged S7
     → Record activated pattern name

3. Display in Checkpoint:
   "🔗 Cross-Concern: {N} integration rules active: {pattern names}"
   If N = 0: "🔗 Cross-Concern: no emergent patterns for current profile"
```

### Per-Command Application

| Command | How Integration Rules Apply |
|---------|---------------------------|
| **specify** | Injected S1 rules → additional SC patterns. Example: `gui+realtime` → "SC must cover optimistic update + reconnection UI" |
| **add** (Brief) | Injected S5 probes → additional questions. Example: `gui+async-state+realtime` → "How does remote state sync with local store?" |
| **plan** | Injected S7 B-1 rules → additional architecture checks. Example: `microservice+message-queue` → "cross-service message schema drift prevention" |
| **implement** | Injected S7 B-3 rules → additional code checks. Example: `gui+realtime` → "stale UI after reconnect prevention" |
| **verify** | Injected S1 rules → SC compliance check includes integration SCs |

### Anti-Patterns

```
❌ WRONG: Load gui.md S1 + realtime.md S1 separately but skip Step 3.5
   → User gets WebSocket reconnection SCs AND UI interaction SCs
   → But MISSES "optimistic update during reconnection" = the emergent pattern

✅ RIGHT: Load gui.md + realtime.md + Step 3.5 integration
   → Merged S1 includes both individual AND combination rules
```

---

**BASE_PATH**: `./specs/_global/` relative to CWD (project-wide GEL artifacts: roadmap, registries, state)
**SPEC_PATH**: `./specs/` relative to CWD (per-Feature artifacts. Format: `specs/{NNN-feature}/` — contains ALL Feature artifacts: pre-context, spec-draft, spec, plan, tasks)

---

## Dependency Stub Resolution Injection

When a Feature enters the pipeline (specify, plan, or tasks step), scan **all preceding Features' `stubs.md`** for stubs that depend on the current Feature:

1. **Scan**: For each preceding Feature that has `SPEC_PATH/[NNN-feature]/stubs.md`, read the file and filter rows where `Dependent Feature` matches the current FID
2. **Inject**: If matching stubs are found, inject them into the current Feature's context assembly (see per-command injection files for exact placement):
   - `injection/specify.md` — Checkpoint Display: show stubs in a dedicated block so the user sees them before spec review
   - `injection/plan.md` — Injected Content: include stubs as architectural input so plan accounts for stub resolution
   - `injection/tasks.md` — Review Display: warn if no stub resolution tasks are generated
3. **No matches**: If no preceding Features have stubs depending on the current FID, skip injection silently (no message needed)

> **Stub file format and generation rules**: See `injection/implement.md` § Post-Step Update Rules #2 (Dependency Stub Registry).
> **Stub completeness verification at verify time**: See `injection/verify.md` § Post-Step Update Rules (Stub Resolution Completeness Check).

---

## Missing/Sparse Content Handling

When artifacts were generated by `/smart-sdd init` (greenfield) or `/smart-sdd add` (brownfield incremental) rather than `/reverse-spec`, some files may be missing or contain minimal content. The injection rules handle this gracefully:

| File | If Missing/Empty | Behavior |
|------|-----------------|----------|
| `business-logic-map.md` | Expected for greenfield/add | Skip business logic injection for specify |
| `stack-migration.md` | Expected for greenfield/same-stack | No impact |
| `entity-registry.md` empty index | Expected for early greenfield Features | Skip entity injection for plan; note in Checkpoint: "No pre-existing entities — defining from scratch" |
| `api-registry.md` empty index | Expected for early greenfield Features | Skip API injection for plan; note in Checkpoint: "No pre-existing APIs — defining from scratch" |
| `tasks.md` absent | Expected for adoption mode | Analyze degrades to two-artifact mode (spec.md + plan.md only). CRITICAL issues are informational, not blocking |
| `pre-context.md` Source Reference = N/A | Expected for greenfield | Skip source reference display in Checkpoint |
| `sdd-state.md` Source Path = N/A | Expected for greenfield | No source resolution needed |
| `sdd-state.md` Source Path = `.` | Expected for add (incremental) | Resolve source files relative to CWD |
| `sdd-state.md` Source Path = absolute path | Expected for reverse-spec (rebuild) | Resolve source files relative to this path; verify path exists during Pipeline Initialization |
| `pre-context.md` Draft Requirements empty | Expected for greenfield/add | Note in Checkpoint: "No draft requirements — define during specify" |
| `pre-context.md` Draft Success Criteria empty | Expected for greenfield/add | Note in Checkpoint: "No draft criteria — define during specify" |
| `pre-context.md` Owned Entities empty | Expected for greenfield/add | Note in Checkpoint: "No entity drafts — define during plan" |
| `pre-context.md` APIs Provided empty | Expected for greenfield/add | Note in Checkpoint: "No API drafts — define during plan" |
| `sdd-state.md` Origin = `adoption` | Expected for adopt pipeline | Use adopt-specific injection rules (adopt-specify, adopt-plan, adopt-verify). Test failures are non-blocking. Feature status → `adopted` |
| `sdd-state.md` Source Behavior Coverage | Expected for rebuild/adoption | Track SBI → FR mapping. Updated after specify (scan for `[source: B###]` tags) and after verify (confirm coverage) |
| `sdd-state.md` Demo Group Progress | Expected when Demo Groups defined | Track per-group completion. Integration Demo triggers when all Features in a group are verified |
| `business-logic-map.md` | Available for adoption/rebuild | Use for specify: inject business rules to guide FR extraction from existing code |
| `sdd-state.md` Project Maturity | absent | Default to `mvp`. Note in Checkpoint: "Project Maturity: mvp (default)" |
| `sdd-state.md` Team Context | absent | Default to `solo`. Note in Checkpoint: "Team Context: solo (default)" |
| `sdd-state.md` Foundation Decisions | empty or absent | Skip Foundation injection, note "No Foundation decisions — framework-agnostic mode" |
| `sdd-state.md` Framework field | "custom" or "none" | Skip Foundation injection entirely |
| `sdd-state.md` T0 Features | absent | Skip T0 ordering, proceed with T1 as first tier |
| `micro-interactions.md` | absent (greenfield/add) | Skip micro-interaction injection for plan/implement/verify. For specify: prompt user to define interactions instead |
| `pre-context.md` Interaction Behavior Inventory | empty or "N/A" | Skip micro-interaction injection, note "No micro-interactions inventoried — define during specify or implement as needed" |
| `pre-context.md` Brief Summary | absent (legacy projects) | Skip Brief↔Spec Alignment Check in specify. Note: "No Brief Summary — alignment check skipped" |
| `sdd-state.md` Org Convention | "none" or absent | Skip org convention loading in resolver. No impact on other modules |
| `pre-context.md` UI Component Features | empty or absent | Skip UI component feature injection; proceed with FR-only specify |
| `pre-context.md` Runtime Exploration Results | "Skipped" | Proceed without runtime data; rely on static analysis only |
| `pre-context.md` Naming Remapping | empty or absent | Use original names from source code; no name translation applied |
| `pre-context.md` Component Tree | empty or absent | Skip component-level structure injection; greenfield/add mode default |
| `pre-context.md` Data Lifecycle Patterns | empty or absent | Skip data lifecycle injection; greenfield/add mode default |
| `pre-context.md` Static Resources | empty or absent | Skip static resource injection for implement |
| `pre-context.md` Environment Variables | empty or absent | Skip environment variable injection for implement |
| `plan.md` Build Changes | absent | No build system modifications needed for this Feature. implement uses existing build configuration. |
| `plan.md` Pattern Constraints | absent | No pattern constraints applied during implement; use framework defaults |
| `plan.md` Interaction Chains | absent | Skip interaction chain verification; UI-only Feature marker |
| `plan.md` UX Behavior Contract | absent | Skip UX behavior contract enforcement; no async UI constraints |
| `plan.md` API Compatibility Matrix | absent | Skip cross-provider API compatibility check; single-provider assumed |
| Preceding Feature `stubs.md` | absent | No stub dependencies; Feature is self-contained or first in order |
| Preceding Feature `interaction-surfaces.md` | absent | Skip interaction surface injection; non-GUI or first Feature |
| `quickstart.md` | absent | Skip quickstart-based verification; use standard SC verification only |
| `visual-references/manifest.md` | absent | Skip visual reference injection; rebuild mode only artifact |
| `visual-references/style-tokens.md` | absent | Skip style token injection; rebuild mode only artifact |
| entity/api-registry staleness | detected during Assemble | Auto-repair attempted → if failed, 🚫 BLOCKING gate (see pipeline.md § Post-Repair Verification) |
| `coverage-baseline.md` | absent | Skip coverage parity check; greenfield origin or not yet generated |
| `pre-context.md` UI Flow Specifications | absent (greenfield/add, or rebuild without Runtime Exploration) | Skip UI Flow Spec injection. Agent generates FR/SC from SBI and code analysis only. Note in Checkpoint: "⚠️ No UI Flow Specs — FR/SC will lack interaction detail. Consider running reverse-spec Phase 1.5 Runtime Exploration." |
| `features/[FID]/spec-draft.md` | absent (greenfield/add) | No spec seed — speckit-specify generates from pre-context drafts. Expected for non-rebuild modes |
| `features/[FID]/spec-draft.md` | absent (rebuild — Runtime Exploration was skipped) | ⚠️ WARNING in Checkpoint: "No spec-draft — specify will generate from scratch, UI detail loss likely. Consider re-running reverse-spec with Runtime Exploration." |

**General rule**: When any section referenced by the injection rules is absent or contains only placeholder text (e.g., "N/A", "none yet", "to be defined"), that section is **skipped** in context assembly. The Checkpoint display notes the omission with a brief explanation. The remaining available content is still injected normally. spec-kit handles the creative/definition work that reverse-spec would have pre-populated.

---

## Context Budget Protocol

When assembled context for a pipeline step approaches the agent's usable context window, sections must be triaged. This protocol defines the priority ordering and overflow behavior.

### Priority Tiers

Every injected section falls into one of three tiers:

| Tier | Label | Rule |
|------|-------|------|
| **P1** | Must-Inject | Always injected in full. Omission breaks the command. |
| **P2** | Inject-if-budget | Injected when budget allows. Summarizable to ≤30% of original if space is tight. |
| **P3** | Skip-safe | Skipped first when over budget. Agent re-reads on demand if needed during execution. |

### P1 Sections per Command

| Command | P1 (never skip) |
|---------|-----------------|
| specify | Pre-context §FR drafts, §SC drafts, §SBI (rebuild), Foundation Decisions (T0) |
| plan | spec.md (full), entity-registry (owned), api-registry (provided), Foundation Constraints |
| tasks | plan.md (full) |
| implement | tasks.md (full), plan.md §Pattern Constraints, plan.md §Interaction Chains (UI) |
| verify | spec.md §FR list, pre-context §cross-Feature points, registries (modified entries) |
| analyze | spec.md + plan.md (both full) |

P2 includes: business-logic-map, stack-migration, referenced entities/APIs, preceding Feature results, source reference file list, pre-context draft sections.
P3 includes: naming remapping, environment variables (presence check only), static resources, CSS value map, visual reference manifest.

### Overflow Protocol

When total assembled context exceeds approximately 80% of the usable window (reserve 20% for command execution and agent reasoning):

```
Step 1: SUMMARIZE P2 sections
  → Replace with 3-5 bullet point summary
  → Mark in Checkpoint: "⚠️ {Section} summarized due to context budget"

Step 2: SKIP P3 sections
  → Omit entirely
  → Mark in Checkpoint: "ℹ️ {Section} skipped (re-readable on demand)"

Step 2.5: RE-READ GATE for skipped P2/P3 sections
  → After command execution completes (before Review), check if any skipped/summarized section
    is relevant to the generated artifact's content:
    - If spec.md references an entity that was in a summarized registry section → re-read that entity
    - If plan.md defines architecture touching a skipped business rule → re-read business-logic-map.md
    - If implement touches files listed in a skipped source reference → re-read those entries
  → Display in Review: "📖 Re-read [N] sections that were initially skipped/summarized:
    [list of sections re-read and why]"
  → If NO skipped sections were relevant → display: "📖 Skipped sections verified — none relevant to generated output"

Step 3: SPLIT if still over budget
  → implement: reduce parallel task batch (8 → 4 → 2 → 1)
  → specify/plan with large pre-context: split into 2 injection rounds
  → Mark in Checkpoint: "⚠️ Context split: {N} rounds needed"
```

### Size Heuristics

The agent does NOT perform exact token counting. Use these thresholds to trigger budget triage:

| Signal | Action |
|--------|--------|
| plan.md > 15 KB | Watch — summarize referenced entities |
| Pre-context > 15 KB (after reverse-spec) | Summarize P2 draft sections |
| Entity registry > 3 owned entities | Summarize referenced (non-owned) entities to name + key fields only |
| Source reference > 30 files (rebuild) | Summarize to top-10 most relevant + count |
| Source Reference > 30 files per Feature | Apply Tier A/B/C prioritization (see reverse-spec Phase 1-4a) |
| SBI > 500 entries (Large project) | Use domain-prefixed B### IDs; P3 entries summarized to one-line |
| Modules > 60 | Use hierarchical domain grouping in all displays and Checkpoint summaries |
| Implement with 8+ parallel tasks | Reduce batch size preemptively |

### Checkpoint Budget Indicator

At every Checkpoint display, include a one-line budget status:

```
📊 Context: {P1 count}/{total sections} must-inject | {N} summarized | {M} skipped
```

This gives the user visibility into what context the agent is working with and whether any sections were trimmed.
