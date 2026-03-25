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

## GEL Artifact Registry

The Global Evolution Layer (GEL) consists of 4 project-wide registries stored at BASE_PATH:

| Registry | File | Written By | Read By |
|----------|------|-----------|---------|
| State | `sdd-state.md` | All pipeline steps | All pipeline steps |
| Entity Registry | `entity-registry.md` | plan Post-Update, verify Post-Update | specify, plan, implement |
| API Registry | `api-registry.md` | plan Post-Update, verify Post-Update | specify, plan, implement |
| Domain Profile Instance | `domain-profile-instance.md` | add Brief (S5/A3 answers), specify Post-Update (cross-concern integrations, Feature summary) | specify Assemble (Feature 2+), plan Assemble |

> The Domain Profile Instance separates profiling RESULTS (user decisions) from profiling TOOLS (domain module S0/S1/S5/S7 rules). See `state-schema.md` § Domain Profile Instance for full schema.

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

## Domain Module Loading Protocol (5 axes)

Every pipeline command that uses Domain Profile rules (specify, plan, tasks, implement, verify) must load active modules **once per command session**. If modules are already cached from a previous step in the same session, skip reloading.

> **🚫 Per-Command Section Filtering (MANDATORY)**: After modules are loaded and merged, each command retains ONLY the S-sections it needs (per `_resolver.md` Step 5). Each injection file (`injection/specify.md`, `injection/plan.md`, etc.) contains a **"Domain Module Filtering"** section that specifies exactly which sections to retain and which to discard. Agents MUST follow this filtering — loading full modules without filtering wastes 40-95% of domain context per command.

```
1. Read sdd-state.md header → extract 5 axes:
   Axis 1 — **Interfaces**: [comma-separated list]
   Axis 2 — **Concerns**: [comma-separated list]
   Axis 3 — **Archetype**: [name or "none"]
   Axis 4 — **Framework**: [name or "none"] (Foundation)
   Axis 5 — **Context Mode**: [greenfield | rebuild | incremental | adoption]
           **Context Scale**: [project_maturity × team_context]
           **Context Modifiers**: [comma-separated list or "none"]

2. Resolve via domains/_resolver.md Steps 1–6b:
   - Load _core.md (always)
   - Load Axis 1: interfaces/{name}.md for each Interface
   - Load Axis 2: concerns/{name}.md for each Concern
   - Load Axis 3: archetypes/{name}.md if Archetype ≠ "none"
   - Load Axis 4: foundations/{framework}.md § F2 + _foundation-core.md § F3
   - Load org convention if specified
   - Load Axis 5: contexts/modes/{mode}.md
   - Load Step 6b: Project Module Overlay from `specs/domains/` (if exists — project-local modules extend/override skill-level)
   - Load Axis 5: contexts/modifiers/{modifier}.md for each Context Modifier (skill-level + project-level)
   - Apply Step 3.5: Cross-Concern Integration Rules
   - Apply Step 4: Context Scale (adjusts rule depth per maturity/team)

3. Cache merged profile (5 axes + project overlay) in working memory.

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

**BASE_PATH**: `./specs/_global/` relative to CWD (project-wide GEL artifacts: roadmap, registries, state, domain-profile-instance)
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

> **Lazy-loaded**: Full degradation table is in [`context-injection-degradation.md`](context-injection-degradation.md). Read it when an artifact is missing or sparse during context assembly.

**General rule**: When any section referenced by the injection rules is absent or contains only placeholder text (e.g., "N/A", "none yet", "to be defined"), that section is **skipped** in context assembly. The Checkpoint display notes the omission with a brief explanation. The remaining available content is still injected normally. spec-kit handles the creative/definition work that reverse-spec would have pre-populated.

---

## Context Budget Protocol

> **Lazy-loaded**: Full budget protocol (priority tiers, overflow steps, size heuristics) is in [`context-injection-budget.md`](context-injection-budget.md). Read it when assembled context approaches ~80% of the usable context window.
