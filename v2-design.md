# spec-kit-skills v2 Redesign

> Design document consolidating all v2 redesign decisions.
> Status: **Design** (not yet implemented)
> Date: 2026-03-06

---

## 1. Design Motivation

v1 was designed from a **technical perspective** (greenfield / brownfield-incremental / brownfield-rebuild). v2 redesigns from a **user intent perspective**: what is the user trying to accomplish?

Key problems identified:
- Mode/option combinations (scope, stack) presented as independent choices but are actually determined by user intent
- No SDD adoption path (existing code + SDD documents, without rewriting)
- Incremental mode (`add`) lacks collaborative Feature definition process
- Feature-level demos don't produce convincing end-to-end demonstrations
- No continuous tracking from source behaviors (SBI) through to final implementation coverage
- Agent wastes context reading multiple large files for simple aggregation tasks

---

## 2. User Intent Model

### 2.1 Five User Journeys

All journeys converge to **incremental mode** as the steady state.

| Intent | Entry Point | scope | stack | Pipeline | Destination |
|--------|------------|:-----:|:-----:|----------|-------------|
| **New project** | `/smart-sdd init` | — | — | `pipeline` | → incremental |
| **SDD adoption** | `/reverse-spec` → `/smart-sdd adopt` | full (fixed) | same (fixed) | `adopt` | → incremental |
| **Rebuild (Core)** | `/reverse-spec` → `/smart-sdd pipeline` | core | same \| new | `pipeline` | → incremental |
| **Rebuild (Full)** | `/reverse-spec` → `/smart-sdd pipeline` | full | same \| new | `pipeline` | → incremental |
| **Add feature** | `/smart-sdd add` | — | — | `incremental` | (stays) |

### 2.2 Adoption vs Rebuild

| | Adoption | Rebuild |
|--|----------|---------|
| Intent | Keep existing code, wrap with SDD docs | Use existing code as reference, build new |
| Code change | None — existing code remains | New code written |
| Stack | Always same | same or new |
| Scope | Always full (must document everything) | core or full |
| Result | Existing code + SDD document layer | New codebase built from SDD specs |

### 2.3 Granularity in reverse-spec

Feature granularity selection (Coarse / Standard / Fine) occurs in reverse-spec Phase 3 and applies to **all intents** that go through reverse-spec (Adoption, Rebuild Core, Rebuild Full). The reverse-spec Phase 1-4 workflow is unchanged in v2 — only what happens *after* reverse-spec differs.

However, granularity has a different **semantic meaning** per intent:

| Granularity | Rebuild | Adoption |
|-------------|---------|----------|
| **Coarse** (domain-level) | Fewer large Features to **build** | Fewer large Features to **document** — faster SDD onboarding |
| **Standard** (module-level) | Balanced decomposition for **implementation** | Balanced decomposition for **documentation** — recommended default |
| **Fine** (capability-level) | Many small Features to **build** — more granular control | Many small Features to **document** — thorough but time-intensive |

The choice affects the number of pipeline/adopt iterations and the granularity of incremental `add` going forward. Finer granularity in adoption means each existing module gets its own spec.md/plan.md, making future incremental additions more precisely scoped.

---

## 3. New Command: `adopt`

### 3.1 Pipeline Comparison

```
pipeline (Rebuild):  constitution → [specify → plan → tasks → analyze → implement → verify] × N
adopt (Adoption):    constitution → [specify → plan → analyze → verify] × N
```

`tasks` and `implement` are removed — there is no code to write.

### 3.2 Step Behavior (Adoption-Specific Prompts)

| Step | Rebuild | Adoption |
|------|---------|----------|
| **specify** | "Define what to build" → new requirements | "Extract what exists" → document current behavior as FR/SC |
| **plan** | "Design new architecture" | "Document existing architecture as-is" |
| **analyze** | Cross-Feature analysis | Same (still valuable) |
| **verify** | Test new code → failure blocks merge | Run existing tests → **baseline only** (failure = pre-existing issue, not blocker) |

### 3.3 Adoption Injection Prompts

**specify (adoption):**
- Read source files for this Feature
- Generate FR/SC describing CURRENT behavior (not intent or improvement)
- Each SBI entry (P1/P2) must map to at least one FR
- Do NOT include unimplemented features or TODO comments as FR

**plan (adoption):**
- Document EXISTING architecture decisions
- Extract data models, API contracts, component structure as they are
- Record inferred rationale ("why it's built this way")
- Do NOT propose changes — describe current state only

**verify (adoption):**
- Test failure → record as "pre-existing issue" in sdd-state (not a blocker)
- No tests → record as "no tests" + recommend adding via incremental
- Build/lint failure → record only (adopt's purpose is documentation)

### 3.4 Feature Status

- `status: adopted` — distinct from `completed` (Rebuild/Greenfield)
- Enables incremental mode to know: "this Feature has code but may have legacy patterns"

---

## 4. State Tracking Extensions

### 4.1 Project-Level Origin (sdd-state.md)

```markdown
## Project Info
- Origin: adoption | rebuild | greenfield
- Source Path: /path/to/original
- Domain: app
```

### 4.2 Injection Branching by Origin

| Origin | Existing Code Character | Injection Context |
|--------|------------------------|-------------------|
| `greenfield` | Written from scratch in this project | — |
| `rebuild` | Written from SDD specs (clean) | Assume clean code, constitution-compliant |
| `adoption` | Legacy code as-is | Respect existing patterns, apply constitution gradually |

### 4.3 Adopt → Incremental Transition

**No explicit transition step required.** Artifacts are structurally compatible:

| Artifact | After adopt | `add` needs | Compatible? |
|----------|------------|-------------|:-----------:|
| roadmap.md | ✅ from reverse-spec | Feature list, dependencies | ✅ |
| entity-registry.md | ✅ from reverse-spec | Existing entities | ✅ |
| api-registry.md | ✅ from reverse-spec | Existing APIs | ✅ |
| constitution.md | ✅ from adopt | Project conventions | ✅ |
| sdd-state.md | ✅ from adopt | Feature mapping, IDs | ✅ |
| Feature spec.md | ✅ from adopt | Cross-Feature reference | ✅ |
| Feature plan.md | ✅ from adopt | Architecture reference | ✅ |

---

## 5. Source Behavior Coverage Tracking

### 5.1 End-to-End Tracing Chain

```
reverse-spec SBI (B###) → specify FR (FR-###) → implement → verify → coverage update
```

### 5.2 SBI Enhancement

Source Behavior Inventory gets unique IDs (already has P1/P2/P3 priority):

```markdown
| ID | File | Behavior | Priority |
|----|------|----------|----------|
| B001 | auth/login.ts | Email+password login | P1 |
| B002 | auth/login.ts | OAuth social login | P2 |
| B003 | auth/password.ts | Password change | P2 |
```

### 5.3 FR ↔ SBI Mapping

In spec.md, each FR includes source tag:

```markdown
- FR-001: Email+password login [source: B001]
- FR-002: OAuth social login [source: B002]
```

### 5.4 Coverage Dashboard (sdd-state.md)

```markdown
## Source Behavior Coverage
| SBI | Priority | FR | Feature | Status |
|-----|----------|----|---------|--------|
| B001 | P1 | FR-001 | F001-auth | ✅ verified |
| B002 | P2 | FR-002 | F001-auth | ✅ verified |
| B003 | P2 | — | — | ❌ unmapped |
```

Summary:
```
P1: 15/15 (100%) ✅
P2: 22/28 (79%) ⚠️
P3:  5/12 (42%)
Overall: 42/55 (76%)
```

### 5.5 Core Mode Coverage Policy

- **P1 behaviors: 100% coverage mandatory** (Core or Full)
- P2/P3 not in T1 → `deferred` status
- Core completion → deferred items become incremental candidates

---

## 6. Demo Layering System

### 6.1 Three Demo Layers

| Layer | Trigger | Scope |
|-------|---------|-------|
| **Feature Demo** | Each Feature verify | Single Feature functionality |
| **Integration Demo** | All Features in demo group verified | User scenario — multi-Feature integration |
| **Application Demo** | Tier completion / full completion | End-to-end app demonstration |

### 6.2 Feature Demo Types

| Type | Feature Demo | Example |
|------|:---:|---------|
| `standalone` | ✅ Solo demo | Auth, Product CRUD |
| `infrastructure` | ⏭️ Skip | DB models, middleware, utilities |
| `enhancement` | ✅ Combined with parent Feature | Search filter, pagination |

Infrastructure Features are verified by tests only; their demo happens within the first dependent Feature's Integration Demo.

### 6.3 Demo Groups

**Definition**: reverse-spec Phase 3 (alongside Feature classification)

**Storage**: `roadmap.md` new section

```markdown
## Demo Groups

### DG-01: User Purchase Flow
- Scenario: Login → Browse products → Add to cart → Checkout
- Features: F001-auth, F002-product, F003-cart, F005-checkout
- SBI: B001, B010, B011, B015, B020, B025

### DG-02: Admin Dashboard
- Scenario: Admin login → View analytics → Manage products
- Features: F001-auth, F004-admin, F006-analytics
- SBI: B001, B030, B031, B035
```

**Tracking**: `sdd-state.md` new section

```markdown
## Demo Group Progress
| Group | Features | Completed | Status | Last Demo |
|-------|----------|-----------|--------|-----------|
| DG-01 | 4 | 3/4 | ⏳ F005 pending | — |
| DG-02 | 3 | 1/3 | ⏳ F004,F006 pending | — |
```

### 6.4 Integration Demo Invalidation

When a Feature is added to an existing demo group (via incremental):
- Previous Integration Demo result is **invalidated**
- Status changes to `🔄 re-run needed (F007 added)`
- Re-triggered when all Features (including new one) are verified

---

## 7. Incremental Feature Consultation Process

### 7.1 Six-Step Workflow

Replaces current simple `add` (name + description → pipeline):

```
Step 1: Explore       — Clarify user's intent through conversation
Step 2: Impact        — Analyze connections to existing Features (script-assisted)
Step 3: Scope         — Negotiate single vs multiple Features
Step 4: SBI Match     — Match to unmapped source behaviors (conditional, script-assisted)
Step 5: Demo Group    — Assign to user scenario group (script-assisted)
Step 6: Finalize      — Generate pre-context, update artifacts, start pipeline
```

### 7.2 Step Details

**Step 1 — Explore** (conversation, no script, no HARD STOP)
- Pure dialogue to clarify vague requests
- Agent asks specific questions about scope, constraints, user expectations
- Transitions to Step 2 when sufficiently concrete

**Step 2 — Impact Analysis** (script + agent, HARD STOP)
- Agent runs `context-summary.sh` → gets compact Feature/Entity/API summary
- Identifies related Features, shared entities, affected APIs
- Presents analysis to user for confirmation

**Step 3 — Scope Negotiation** (agent, HARD STOP)
- Based on complexity, propose single Feature vs split
- Present concrete options with estimated FR/SC counts
- User selects

**Step 4 — SBI Match** (script + agent, HARD STOP, conditional)
- **Only when origin = adoption | rebuild** (greenfield has no SBI)
- Agent runs `sbi-coverage.sh --filter <keywords>` → finds related unmapped behaviors
- User decides which SBI entries to cover in this Feature

**Step 5 — Demo Group Assignment** (script + agent, HARD STOP)
- Agent runs `demo-status.sh` → shows current groups
- Auto-suggests group based on entity/API dependencies
- Options: join existing group / create new / none (infrastructure)

**Step 6 — Definition Finalization** (agent, HARD STOP)
- Generate pre-context.md with all Step 1-5 decisions
- Update roadmap.md (Feature Catalog + Demo Group)
- Update sdd-state.md
- Show summary for final approval
- On approval → pipeline execution

---

## 8. Script Architecture

### 8.1 Design Principle

**Agent judges, scripts aggregate.** The agent never counts numbers or reads multiple files just to summarize.

### 8.2 Script Inventory

| Script | Purpose | Context Savings |
|--------|---------|:---:|
| `context-summary.sh` | Compact Feature/Entity/API/DemoGroup summary | ~500→40 lines (92%) |
| `sbi-coverage.sh` | SBI coverage dashboard + `--filter` search | ~800→10 lines (98%) |
| `demo-status.sh` | Demo group progress | ~200→10 lines |
| `pipeline-status.sh` | Pipeline progress overview | ~300→15 lines |
| `validate.sh` | Cross-file consistency check | Accuracy, not savings |

### 8.3 Script Properties

- **Read-only**: Never modify artifacts
- **Target path as argument**: Run from spec-kit-skills, not installed into target project
- **Deterministic output**: Same input → same output (no agent variability)
- **bash + grep/awk**: No external dependencies
- **Fixed markdown patterns**: Rely on known table/header formats for parsing

### 8.4 Invocation Points

| Timing | Scripts | Purpose |
|--------|---------|---------|
| Session start | `pipeline-status.sh` | Quick orientation |
| reverse-spec Phase 4 | `sbi-coverage.sh` | Initial baseline |
| Each Feature verify | `sbi-coverage.sh` + `demo-status.sh` | Coverage update + demo trigger check |
| `add` Step 2 | `context-summary.sh` | Impact analysis context |
| `add` Step 4 | `sbi-coverage.sh --filter` | Related SBI lookup |
| `add` Step 5 | `demo-status.sh` | Current demo groups |
| After any artifact update | `validate.sh` | Consistency check |

---

## 9. Artifact Changes Summary

| Artifact | Change | Type |
|----------|--------|:----:|
| `roadmap.md` | Add Demo Groups section | Section add |
| `sdd-state.md` | Add Origin field, Demo Group Progress, Source Coverage | Section add |
| `coverage-baseline.md` | Add B### IDs to SBI + FR mapping column | Column add |
| `pre-context.md` | Add demo group assignment + demo type | Field add |
| `spec.md` | Add `[source: B###]` tags to FR entries | Tag add |
| `commands/adopt.md` | Adopt workflow detail | **New file** |
| `injection/adopt-*.md` | Adoption-specific injection prompts | **New files** |
| `scripts/*.sh` | 5 aggregation/validation scripts | **New files** |

No new artifact files. Changes are additions to existing artifact schemas.

---

## 10. Not Yet Designed

| Item | Description |
|------|-------------|
| Application Demo structure | What form does the Tier-completion / full-completion demo take? |
| Deferred → incremental candidate presentation | How are unmapped P2/P3 SBI entries surfaced as Feature suggestions after Core completion? |
| Adopt injection prompt full text | Detailed prompt wording for each adoption step |
| Script implementations | Actual bash scripts (patterns defined, not yet coded) |
| README/SKILL.md updates | Documentation reflecting v2 changes |
| case-study skill updates | Origin field (`adoption \| rebuild`), `adopted` status handling, SBI coverage metrics, Demo Group progress, recording protocol (M1-M8) branching for adoption vs rebuild |
| greenfield `init` alignment | Does init need demo group / SBI concepts? (No SBI, but demo groups could be manually defined) |
