# Auto-Report Template — Unified Completion Report

> Generates a full report automatically from existing artifacts — no external log file needed.
>
> **3 generation modes**: `reverse-spec`, `adoption`, `rebuild-pipeline`
> **Data sources**: history.md, sdd-state.md, roadmap.md, registries, constitution-seed.md, per-Feature artifacts

---

## Generation Modes

| Mode | Trigger | Output Path | Sections Included |
|------|---------|-------------|-------------------|
| `reverse-spec` | After Phase 4-5 completion | `specs/_global/completion-report.md` | §1-§5, §8-§10 (no pipeline data) |
| `adoption` | After smart-sdd adopt pipeline end | `specs/_global/adoption-report.md` | §1-§10 (full, adoption-specific) |
| `rebuild-pipeline` | After smart-sdd pipeline completion | `specs/_global/pipeline-report.md` | §1-§10 (full, rebuild-specific) |

**Mode determines which sections are active.** Each section below is annotated with `[all]`, `[adoption | rebuild-pipeline]`, or `[mode-specific]`.

---

## Step 1 — Artifact Discovery

Scan for available artifacts. Classify each as found or missing.

### Required artifacts (ERROR if missing):

| Artifact | Path | Data Extracted |
|----------|------|---------------|
| `roadmap.md` | `specs/_global/roadmap.md` | Feature list, Tier distribution, dependencies, project overview |

**Additional required for `adoption` / `rebuild-pipeline` modes:**

| Artifact | Path | Data Extracted |
|----------|------|---------------|
| `sdd-state.md` | `specs/_global/sdd-state.md` | Pipeline progress, timestamps, test results, parity logs |

If required artifacts are missing:
```
❌ Cannot generate report. Missing required artifacts:
  - {missing file path}

Complete the pipeline first, then retry.
```

### Optional artifacts (graceful degradation if missing):

| Artifact | Path | Data Extracted |
|----------|------|---------------|
| `entity-registry.md` | `specs/_global/entity-registry.md` | Entity count, relationships |
| `api-registry.md` | `specs/_global/api-registry.md` | API count, contracts |
| `business-logic-map.md` | `specs/_global/business-logic-map.md` | Business rule count per Feature |
| `coverage-baseline.md` | `specs/_global/coverage-baseline.md` | Source coverage metrics, exclusions |
| `constitution-seed.md` | `specs/_global/constitution-seed.md` | Architecture principles, archetype, F7 philosophy |
| `history.md` | `specs/history.md` | Strategy/architecture/per-Feature decisions |
| `stack-migration.md` | `specs/_global/stack-migration.md` | Stack migration decisions |

For each missing optional artifact, note it internally. The corresponding report section will show "Data not available" or the subsection is omitted.

### Spec-kit feature artifacts:

Glob for `specs/[0-9]*/spec.md`, `specs/[0-9]*/tasks.md` to extract per-Feature metrics.

---

## Step 2 — Data Extraction

### 2-1. From roadmap.md
- Project name and description (from Project Overview section)
- Source path (from `**Source**:` field)
- Strategy: Scope (`core`/`full`) and Stack (`same`/`new`)
- Feature Catalog table: Feature ID, name, Tier (if core), status
- Dependency count per Feature

### 2-2. From sdd-state.md [adoption | rebuild-pipeline]
- Origin (`greenfield`/`rebuild`/`adoption`)
- Domain profile used
- Constitution: status, version, update count
- Feature Progress table: per-step status icons and dates (include `adopted` status alongside `completed`)
- Feature Detail Log: per-step timestamps, notes (FR/SC counts, test results)
- Source Behavior Coverage (if exists): P1/P2/P3 counts and verified percentages
- Demo Group Progress (if exists): per-group completion status
- Parity Check Log: structural/logic parity %, gaps, new Features created
- Global Evolution Log: registry update history
- Restructure Log: merge/split operations

### 2-3. From registries
- entity-registry.md: Count entities, count cross-Feature shared entities
- api-registry.md: Count endpoints, count cross-Feature API dependencies
- business-logic-map.md: Count business rules per Feature

### 2-4. From coverage-baseline.md
- Surface Metrics table (source total, mapped, coverage %)
- Intentional exclusion count and reasons
- Unmapped items summary

### 2-5. From spec-kit artifacts [adoption | rebuild-pipeline]
For each Feature directory (`specs/{NNN-name}/`):
- `spec.md`: Count `FR-###` patterns (functional requirements), count `SC-###` patterns (success criteria)
- `tasks.md`: Count `T###` patterns (tasks)

### 2-6. From history.md
> **history.md is the richest source of decision context.** The report should reflect all significant decisions recorded here.

- **Project Context block** (if exists — rebuild/adoption mode):
  - Mode (Rebuild/Adoption), Original project name + path, Target project name + path
  - Stack strategy (Same Stack / New Stack), Identity mapping (original-name → new-name)
  - **What it does** (user-perspective description of the system)
- Extract Strategy Decisions table (Scope, Stack, Name)
- Extract Per-Category Stack Choices table (if new stack)
- Extract Architecture Decisions table (Granularity, Tier adjustments, Demo Groups)
- Extract Constitution decisions (version, modifications)
- **Extract per-Feature Implementation Decisions** (if recorded): spec deviations, architecture choices, trade-offs, limited verifications, **Philosophy Adherence entries** (see §9 note)
- Extract restructure/expand/parity decisions (if any)
- Extract dated session entries — each `/reverse-spec` and `/smart-sdd` session records specific decisions with rationale

### 2-7. From stack-migration.md (if exists)
- Migration strategy (same stack vs new stack)
- Per-category stack choices table: Category, Original, Chosen, Rationale
- Dependency chain analysis (if documented)
- Migration risks and mitigations

> **Note**: Some stack migration data also appears in history.md (Strategy Decisions, Per-Category Stack Choices). If both sources exist, stack-migration.md provides the detailed per-category breakdown while history.md provides decision rationale. Use both for §5.

### 2-8. From SBI Coverage [adoption | rebuild-pipeline]
- Parse Source Behavior Coverage table from sdd-state.md
- Count per priority: P1 total/verified, P2 total/verified, P3 total/verified
- Overall coverage percentage
- List of unmapped and deferred entries

### 2-9. From constitution-seed.md — Philosophy Data (if exists)

Parse philosophy sections from constitution-seed.md:

**Archetype-Specific Principles** (section header: `## Archetype-Specific Principles`):
- Archetype name (subsection header, e.g., "### AI Assistant Domain")
- Per-principle: Name (bold text), Observed Trait, Implication

**Framework Philosophy** (section header: `## Framework Philosophy`):
- Framework name (subsection header, e.g., "### Electron Framework Principles")
- Per-principle: Name (bold text), Description, Implication (if present)

**Extracted Architecture Principles** (section header: `## Extracted Architecture Principles`):
- Per-principle: Name, Rule, Rationale/Evidence

If constitution-seed.md is missing or does not contain these sections, these fields are empty — corresponding report subsections will be omitted (graceful degradation).

### 2-10. Domain/Archetype/Framework metadata

Extract from available sources (in priority order):
1. sdd-state.md: domain profile, archetype, framework
2. constitution-seed.md: archetype name from Archetype-Specific Principles header, framework from Framework Philosophy header
3. roadmap.md: project description for synthesis

Use in §1 Executive Summary.

---

## Step 3 — Report Structure

### Section Overview

| # | Section | Modes | Primary Sources |
|---|---------|-------|-----------------|
| §1 | Executive Summary | all | roadmap, sdd-state, registries, history |
| §2 | Project Background | all | history, roadmap |
| §3 | Source Analysis | all | coverage-baseline, registries, roadmap |
| §4 | Feature Catalog | all | roadmap, sdd-state |
| §5 | Architecture & Strategy | all | history, constitution-seed, stack-migration |
| §6 | Pipeline Execution | adoption, rebuild-pipeline | sdd-state, per-Feature artifacts, history |
| §7 | Quality & Parity | adoption, rebuild-pipeline | sdd-state, coverage-baseline |
| §8 | Challenges & Solutions | all | history, sdd-state |
| §9 | Outcomes & Lessons Learned | all | history, sdd-state, registries |
| §10 | Artifact Inventory | all | filesystem scan |

---

## Step 4 — Report Generation

### § 1. Executive Summary [all]

```markdown
# {Report Title}: {Project Name}

## § 1. Executive Summary

**Project**: {name} | **Domain**: {domain} | **Archetype**: {archetype or "—"} | **Framework**: {framework or "—"}
**Mode**: {reverse-spec / adoption / rebuild-pipeline}
**Origin**: {greenfield/rebuild/adoption} | **Scope**: {core/full} | **Stack**: {same/new}
**Date**: {generation timestamp}
```

**System Overview** (1-3 sentences, user perspective):
> Source priority: history.md "What it does" (in Project Context) > roadmap.md "Project Overview". If neither provides a user-perspective description, synthesize from Feature names and descriptions.

```markdown
### System Overview
{What the system does — user perspective, not tech stack}
```

**Key Metrics** (adapt based on mode — `reverse-spec` omits pipeline/SBI mapping rows):

```markdown
### Key Metrics
| Metric | Value |
|--------|-------|
| Features | {total} (T1: {N}, T2: {N}, T3: {N}) |
| Features completed/adopted | {N}/{total} | ← [adoption | rebuild-pipeline only]
| Source coverage | {% from coverage-baseline} |
| Entities defined | {count from registry} |
| API endpoints | {count from registry} |
| Total requirements (FR) | {sum} | ← [adoption | rebuild-pipeline only]
| Total success criteria (SC) | {sum} | ← [adoption | rebuild-pipeline only]
| Total tasks | {sum} | ← [adoption | rebuild-pipeline only]
| SBI coverage | {P1: X/Y (Z%), P2: X/Y (Z%)} | ← [adoption | rebuild-pipeline only]
| Parity (structural/logic) | {%/%} | ← [adoption | rebuild-pipeline only]
| Demo Groups | {completed}/{total} | ← [adoption | rebuild-pipeline only]
| Archetype principles | {N adopted / N total, or "—"} |
| Framework (F7) principles | {N adopted / N total, or "—"} |
```

**[reverse-spec mode]** — Omit rows marked `[adoption | rebuild-pipeline only]`. Add instead:
```markdown
| SBI entries extracted | {total} (P1: {N}, P2: {N}, P3: {N}) |
| Extraction confidence | {% of exported functions/methods analyzed} |
| Modules fully analyzed | {N}/{total} |
```

---

### § 2. Project Background [all]

**Primary sources** (in priority order):
1. **history.md Project Context block** (if exists): Mode, Original → Target mapping, Stack strategy, Identity
2. **history.md Strategy Decisions table**: Scope/Stack/Name decisions with rationale
3. **roadmap.md Project Overview section**: project description, source path

**Content structure**:

```markdown
## § 2. Project Background

### Why This Project
{From roadmap.md + history.md — what the project is and why SDD was applied}

### Stack Profile (optional — include when primary language is NOT JavaScript/TypeScript)
| Dimension | Value |
|-----------|-------|
| Primary Language | {detected} |
| Framework | {detected} |
| Build System | {detected} |
| Foundation File | {Foundation file used, or "Generic (Case B)"} |

> Include Stack Profile only for non-JS/TS projects where ecosystem context helps readers understand framework-specific decisions.

### Project Context (rebuild/adoption only)
| | Details |
|---|---------|
| Mode | {from history.md Project Context} |
| Original | {name} (`{path}`) |
| Target | {name} (`{path}`) |
| Stack | {Same Stack / New Stack: old → new} |
| Identity | {original-name → new-name, or "Same"} |

### Strategic Decisions
{From history.md Strategy Decisions table — Scope, Stack, Name choices with rationale}

### Scale & Module Structure
| Field | Value |
|-------|-------|
| Scale | {Micro/Small/Medium/Large} |
| Domain Profile | {5 axes + Scale modifier summary} |
| Module Structure | {monorepo/single-package, N modules/packages} |
| Language Composition | {from Phase 1-2a} |
```

- If no history.md Project Context: omit the Project Context subsection
- If reverse-spec mode: Strategic Decisions shows only analysis-time observations

---

### § 3. Source Analysis [all]

```markdown
## § 3. Source Analysis

### Surface Metrics
{From coverage-baseline.md — Surface Metrics table}

### Entity & API Summary
- Entities: {N} total, {N} cross-Feature shared
- APIs: {N} total, {N} internal / {N} external
- Business rules: {N} total
- Top shared entities: {list top 3-5}

### Exclusion Summary (if coverage-baseline.md has exclusions)
- Intentional exclusions: {N} ({reasons summary})
- Unmapped items: {summary}
```

---

### § 4. Feature Catalog [all]

```markdown
## § 4. Feature Catalog

- Total Features: {N}
- Release Groups: {list with Feature counts}
- Tier distribution: T1 {N} / T2 {N} / T3 {N}
- Dependency highlights: {key cross-Feature dependencies}

### Feature Table
| Feature ID | Name | Tier | RG | Dependencies | Status |
|------------|------|------|----|--------------|--------|
| F001 | ... | T1 | RG1 | — | ... |
```

**[reverse-spec]** — Status column shows extraction confidence (✅/⚠️)
**[adoption | rebuild-pipeline]** — Status column shows pipeline status (completed/adopted/in-progress)

---

### § 5. Architecture & Strategy [all]

Structured in 3 subsections. §5.2 and §5.3 only appear when philosophy data is available from constitution-seed.md; if no philosophy data exists, Section 5 contains only §5.1.

#### §5.1 Strategic Decisions

```markdown
## § 5. Architecture & Strategy

### §5.1 Strategic Decisions
```

- From history.md: strategy decisions (scope, stack, identity) — with rationale
- From history.md: stack migration choices — per-category Original → Chosen with reasons (if new stack)
- From stack-migration.md (if present): migration strategy, per-category decisions, dependency chain analysis
- From history.md: architecture decisions — granularity, tier adjustments, Demo Group definitions with rationale
- From history.md: constitution decisions — version, key modifications
- From constitution-seed.md: key principles (list top 5-7 extracted architecture principles)

#### §5.2 Architecture Philosophy (conditional)

> **Condition**: Only include when constitution-seed.md contains `## Archetype-Specific Principles` and/or `## Framework Philosophy` sections. Omit this entire subsection otherwise.

**Domain Philosophy** (if archetype detected — from Archetype-Specific Principles):

```markdown
### §5.2 Architecture Philosophy

#### Domain Philosophy — {Archetype Name}

| Principle | Observed Trait | Constitution Status |
|-----------|---------------|-------------------|
| {name} | {observed trait summary} | ✅ Adopted |
| {name} | {observed trait summary} | ✅ Adopted (modified) |
| {name} | {observed trait summary} | ❌ Rejected |
```

**Constitution Status** values — determined by comparing constitution-seed.md principles against the finalized `.specify/memory/constitution.md` content (if available):
- `✅ Adopted` — principle appears in finalized constitution unchanged
- `✅ Adopted (modified)` — principle appears with modifications
- `❌ Rejected` — principle was in seed but removed during finalization
- `⚠️ Added` — not in seed but added during constitution finalization

**Framework Philosophy** (if F7 principles exist):

```markdown
#### Framework Philosophy — {Framework Name}

| Principle | Description | Constitution Status |
|-----------|-------------|-------------------|
| {name} | {description} | ✅ Adopted |
```

Same status determination as Domain Philosophy.

#### §5.3 Principle-to-Decision Mapping (conditional)

> **Condition**: Only include when both §5.1 has architecture decisions AND §5.2 has principles. Omit otherwise.

```markdown
### §5.3 Principle-to-Decision Mapping

| Decision | Driving Principle | Source | Rationale |
|----------|-------------------|--------|-----------|
| {decision from history.md} | {principle name} | Archetype / F7 / Extracted | {rationale} |
| {decision} | — | Engineering judgment | {rationale} |
```

For each significant architecture decision in history.md:
1. Check if the decision's rationale references or aligns with a known principle from §5.2
2. If yes: map to that principle with source (Archetype, F7, or Extracted)
3. If no clear principle alignment: mark as "Engineering judgment"

---

### § 6. Pipeline Execution [adoption | rebuild-pipeline]

> **Not included in `reverse-spec` mode** — there is no pipeline data to report.

```markdown
## § 6. Pipeline Execution

### Feature Progress
{Reproduce the step status table from sdd-state.md}

### Per-Feature Metrics
| Feature | FR | SC | Tasks | Tests | Build | Status |
|---------|----|----|-------|-------|-------|--------|
| F001-auth | 5 | 8 | 12 | 24/24 ✅ | ✅ | completed |
| F002-product | 8 | 12 | 18 | 30/30 ✅ | ✅ | adopted |

### Constitution Evolution
{Version history from Constitution Update Log in sdd-state.md}

### Global Evolution Log
{Which registries were updated, by which Features}

### Demo Group Progress (if exists)
{Per-group completion status, Integration Demo results}

### Per-Feature Implementation Decisions
{From history.md per-Feature sections: architecture choices, spec deviations, trade-offs}
```

---

### § 7. Quality & Parity [adoption | rebuild-pipeline]

> **Not included in `reverse-spec` mode.**

```markdown
## § 7. Quality & Parity

### Verification Results
{From sdd-state.md Feature Detail Log: verify step results (tests, build, lint, cross-Feature)}

### SBI Coverage
| Priority | Total | Verified | Coverage |
|----------|-------|----------|----------|
| P1 (critical) | {N} | {N} | {%} |
| P2 (important) | {N} | {N} | {%} |
| P3 (minor) | {N} | {N} | {%} |

Unmapped behaviors: {list}
Deferred behaviors: {list}

### Parity Assessment (if parity data exists)
- Structural parity: {%}
- Logic parity: {%}
- Gaps: {list}
- New Features created from parity gaps: {list}

### Exclusion Audit
{From coverage-baseline.md}
```

**[reverse-spec mode]** uses a different quality section in §3 (Source Analysis) with per-phase confidence:

```markdown
### Phase Confidence (reverse-spec only — included in §3)
| Phase | Confidence | Notes |
|-------|-----------|-------|
| Phase 1 (Scan) | ✅/⚠️ | {coverage note} |
| Phase 1.5 (Runtime) | ✅/⚠️/skipped | {reason if skipped} |
| Phase 2 (Deep) | ✅/⚠️ | {any modules with low confidence} |
| Phase 3 (Classify) | ✅/⚠️ | {boundary ambiguities} |
| Phase 4 (Generate) | ✅/⚠️ | {completeness} |
```

---

### § 8. Challenges & Solutions [all]

```markdown
## § 8. Challenges & Solutions
```

**Sources**:
- From history.md: per-Feature Implementation Decisions that resolved challenges (spec deviations, architecture trade-offs, limited verification decisions with rationale)
- From history.md: restructure/parity decisions that addressed structural issues
- From sdd-state.md: any failed or limited steps with their notes [adoption | rebuild-pipeline]
- From sdd-state.md: Restructure Log entries [adoption | rebuild-pipeline]

**[reverse-spec mode]**: Challenges are limited to analysis-phase observations (e.g., modules with low extraction confidence, ambiguous Feature boundaries, runtime analysis gaps).

**Challenge categorization hint** (apply when meaningful):
- **Language/Runtime**: Challenges specific to the programming language or runtime
- **Framework Convention**: Challenges from framework-specific patterns
- **Ecosystem Tooling**: Challenges from build/test/lint tooling
- **Domain Complexity**: Challenges from business logic regardless of tech stack
- **Foundation Gap**: Challenges from missing or incomplete Foundation files

> This categorization is a guideline, not a required format. Apply when the project's challenges have a meaningful relationship to its tech stack.

---

### § 9. Outcomes & Lessons Learned [all]

```markdown
## § 9. Outcomes & Lessons Learned
```

#### Impact Assessment [adoption | rebuild-pipeline]

```markdown
### Impact Assessment
| Aspect | Before | After |
|--------|--------|-------|
| Documentation | {none/partial/existing} | {FR/SC/entity/API counts} |
| Test coverage | {pre-existing or unknown} | {from verify results} |
| Architecture visibility | {unknown/undocumented} | {entity-registry + api-registry + constitution} |
| Behavior traceability | {none} | {SBI coverage P1/P2/P3 %} |
```

#### Summary Metrics [adoption | rebuild-pipeline]

```markdown
### Planned vs Actual
- Planned Features vs completed/adopted Features
- Planned scope (core/full) vs actual delivery
- Key decisions from history.md that shaped the outcome
```

#### Auto-generated Insights [all]

```markdown
### Insights
```
- Features with most restructuring or re-execution [adoption | rebuild-pipeline]
- Registry growth pattern (entities/APIs added over time from Global Evolution Log) [adoption | rebuild-pipeline]
- Average FR/SC per Feature [adoption | rebuild-pipeline]
- Key decisions from history.md that had the most impact on the final architecture
- Recommendations for next steps

**[reverse-spec mode]** insights focus on:
- Recommended next step: adopt / rebuild / explore further
- Areas needing deeper exploration
- Potential Feature boundary adjustments
- Modules with low analysis confidence

#### Philosophy Assessment (conditional) [adoption | rebuild-pipeline]

> **Condition**: Only include when per-Feature Philosophy Adherence data exists in history.md per-Feature Implementation Decisions. Omit entirely otherwise.
>
> **NOTE**: Philosophy Adherence per-Feature is recorded in **history.md per-Feature Implementation Decisions**. The pipeline records which architecture principles guided each Feature's implementation decisions directly in history.md.

```markdown
### Philosophy Assessment

#### Principle Application Coverage
| Principle | Source | Features Applied | Examples |
|-----------|--------|-----------------|----------|
| {name} | Archetype | {N}/{total completed} ({FID list}) | {brief example from history.md} |
| {name} | F7 | {N}/{total completed} ({FID list}) | {brief example} |
| {name} | Extracted | {N}/{total completed} ({FID list}) | {brief example} |

#### Principle Gaps
{List principles from the constitution that were never referenced in any per-Feature Implementation Decision}
- {principle}: Aspirational — may not have been applicable to implemented Features
- {principle}: Implicit — likely followed but not explicitly recorded

#### Module Feedback
{Auto-generated suggestions for domain module improvement}
```

Module Feedback logic:
- If archetype was active and some principles had zero Feature applications: "Consider whether `{principle}` should be refined or marked optional for `{archetype}` projects"
- If all F7 principles were applied across Features: "F7 principles for `{framework}` provided effective architectural guidance across the project"
- If no archetype was active but domain-specific decisions were frequent in history.md: "This project's decision patterns suggest a potential new archetype module for `{inferred domain pattern}`"

---

### § 10. Artifact Inventory [all]

```markdown
## § 10. Artifact Inventory

### Global Artifacts
| Artifact | Path | Status |
|----------|------|--------|
| roadmap.md | specs/_global/ | ✅ / ❌ |
| entity-registry.md | specs/_global/ | ✅ / ❌ |
| api-registry.md | specs/_global/ | ✅ / ❌ |
| business-logic-map.md | specs/_global/ | ✅ / ❌ |
| coverage-baseline.md | specs/_global/ | ✅ / ❌ |
| constitution-seed.md | specs/_global/ | ✅ / ❌ |
| stack-migration.md | specs/_global/ | ✅ / ❌ |
| sdd-state.md | specs/_global/ | ✅ / ❌ |
| history.md | specs/ | ✅ / ❌ |

### Per-Feature Artifacts [adoption | rebuild-pipeline]
| Feature | spec.md | plan.md | tasks.md | Status |
|---------|---------|---------|----------|--------|
| F001-auth | ✅ | ✅ | ✅ | completed |
| ... | ... | ... | ... | ... |

### Report Metadata
| Field | Value |
|-------|-------|
| Generated by | Auto-Report (completion-report.md template) |
| Mode | {reverse-spec / adoption / rebuild-pipeline} |
| Timestamp | {ISO 8601} |
| Artifacts read | {count of artifacts successfully read} |
| Artifacts missing | {count of optional artifacts not found} |
```

---

## Generation Protocol

### Auto-trigger Points

#### 1. reverse-spec Phase 4-5 completion → `specs/_global/completion-report.md`

1. Mode = `reverse-spec`
2. Read all Phase artifacts to populate sections
3. Fill §1-§5, §8-§10 (skip §6, §7 — no pipeline data)
4. §3 includes per-phase confidence assessment
5. §9 focuses on analysis insights and recommended next steps
6. Save to `specs/_global/completion-report.md`
7. Display §1 Executive Summary in the conversation

#### 2. smart-sdd adopt pipeline end → `specs/_global/adoption-report.md`

1. Mode = `adoption`
2. Read all Feature artifacts (spec.md, plan.md, tasks.md, verify results)
3. Read sdd-state.md + registries + history.md
4. Fill §1-§10 (all sections)
5. §6 Pipeline Execution includes `adopted` status for Features
6. §7 Quality includes SBI → FR mapping coverage
7. Save to `specs/_global/adoption-report.md`
8. Display §1 Executive Summary in the conversation

#### 3. smart-sdd pipeline end → `specs/_global/pipeline-report.md`

1. Mode = `rebuild-pipeline`
2. Read all Feature artifacts + sdd-state.md + registries + history.md
3. Fill §1-§10 (all sections)
4. §6 Pipeline Execution includes full `completed` pipeline data
5. §7 Quality includes full verification results and parity assessment
6. Save to `specs/_global/pipeline-report.md`
7. Display §1 Executive Summary in the conversation

### Relationship Between Reports

- If both `completion-report.md` and `adoption-report.md`/`pipeline-report.md` exist:
  - The pipeline report references the completion report as "pre-pipeline analysis"
  - §7 SBI Coverage compares against completion-report §3 SBI extraction totals
  - Enables: "reverse-spec found 450 SBI entries → adoption mapped 420 to FRs (93% coverage)"
- Reports are cumulative — a pipeline report is a superset of a completion report, with pipeline execution data added

### Report Title Convention

| Mode | Title Format |
|------|-------------|
| `reverse-spec` | `Source Analysis Report: {Project Name}` |
| `adoption` | `Adoption Report: {Project Name}` |
| `rebuild-pipeline` | `Pipeline Report: {Project Name}` |

### Language

Reports follow the **Artifact Language** setting in `sdd-state.md` (default: `en`). Section headers and descriptive text adapt to the configured language.
