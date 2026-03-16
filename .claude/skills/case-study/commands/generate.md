# Case Study Generate

Generates a structured Case Study report by aggregating quantitative metrics from project artifacts and qualitative observations from the case study log.

---

## Step 1 — Argument Parsing

- `target-directory`: Path to the project root (default: CWD)
- `--lang en|ko`: Output language (default: `en`)

Set `BASE_PATH` = `{target-directory}/specs/reverse-spec/`
Set `SPEC_PATH` = `{target-directory}/specs/`

---

## Step 2 — Artifact Discovery

Scan for available artifacts. Classify each as found or missing.

### Required artifacts (ERROR if missing):

| Artifact | Path | Data Extracted |
|----------|------|---------------|
| `roadmap.md` | `{BASE_PATH}/roadmap.md` | Feature list, Tier distribution, dependencies, project overview |
| `sdd-state.md` | `{BASE_PATH}/sdd-state.md` | Pipeline progress, timestamps, test results, parity logs |

If either is missing:
```
❌ Cannot generate Case Study. Missing required artifacts:
  - {missing file path}

Run /reverse-spec and /smart-sdd pipeline first, then retry.
```

### Optional artifacts (graceful degradation if missing):

| Artifact | Path | Data Extracted |
|----------|------|---------------|
| `entity-registry.md` | `{BASE_PATH}/entity-registry.md` | Entity count, relationships |
| `api-registry.md` | `{BASE_PATH}/api-registry.md` | API count, contracts |
| `business-logic-map.md` | `{BASE_PATH}/business-logic-map.md` | Business rule count per Feature |
| `coverage-baseline.md` | `{BASE_PATH}/coverage-baseline.md` | Source coverage metrics, exclusions |
| `constitution-seed.md` | `{BASE_PATH}/constitution-seed.md` | Key governance principles |
| `case-study-log.md` | `{target-directory}/case-study-log.md` | Qualitative observations (M1-M8) |
| `history.md` | `{SPEC_PATH}/history.md` | Strategic and architecture decisions |
| `stack-migration.md` | `{BASE_PATH}/stack-migration.md` | Stack migration decisions |

For each missing optional artifact, note it internally. The corresponding report section will show "Data not available" or be omitted.

### Spec-kit feature artifacts:

Glob for `{SPEC_PATH}/[0-9]*/spec.md`, `{SPEC_PATH}/[0-9]*/tasks.md` to extract per-Feature metrics.

---

## Step 3 — Data Extraction

### 3-1. From roadmap.md
- Project name and description (from Project Overview section)
- Source path (from `**Source**:` field)
- Strategy: Scope (`core`/`full`) and Stack (`same`/`new`)
- Feature Catalog table: Feature ID, name, Tier (if core), status
- Dependency count per Feature

### 3-2. From sdd-state.md
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

### 3-3. From registries
- entity-registry.md: Count entities, count cross-Feature shared entities
- api-registry.md: Count endpoints, count cross-Feature API dependencies
- business-logic-map.md: Count business rules per Feature

### 3-4. From coverage-baseline.md
- Surface Metrics table (source total, mapped, coverage %)
- Intentional exclusion count and reasons
- Unmapped items summary

### 3-5. From spec-kit artifacts
For each Feature directory (`specs/{NNN-name}/`):
- `spec.md`: Count `FR-###` patterns (functional requirements), count `SC-###` patterns (success criteria)
- `tasks.md`: Count `T###` patterns (tasks)

### 3-6. From case-study-log.md (if exists)
Parse milestone entries (M1-M8):
- Extract `## [date] M{N}` sections
- Parse Observations, Challenges, Key Decisions subsections
- Map to corresponding report sections

### 3-7. From history.md (if exists)
- **Project Context block** (if exists — rebuild/adoption mode):
  - Mode (Rebuild/Adoption), Original project name + path, Target project name + path
  - Stack strategy (Same Stack / New Stack), Identity mapping (original-name → new-name)
  - **What it does** (user-perspective description of the system)
- Extract Strategy Decisions table (Scope, Stack, Name)
- Extract Per-Category Stack Choices table (if new stack)
- Extract Architecture Decisions table (Granularity, Tier adjustments, Demo Groups)
- Extract Constitution decisions (version, modifications)
- **Extract per-Feature Implementation Decisions** (if recorded): spec deviations, architecture choices, trade-offs, limited verifications
- Extract restructure/expand/parity decisions (if any)
- Extract dated session entries — each `/reverse-spec` and `/smart-sdd` session records specific decisions with rationale

> **history.md is the richest source of decision context**. The case-study report should reflect all significant decisions recorded here. Section 2 uses strategy/Project Context, Section 4 uses architecture/stack/constitution, Section 5 uses per-Feature decisions, Section 7 uses decisions that resolved challenges, Section 8 uses pivotal decisions that shaped outcomes.

### 3-8. From stack-migration.md (if exists)
- Migration strategy (same stack vs new stack)
- Per-category stack choices table: Category, Original, Chosen, Rationale
- Dependency chain analysis (if documented)
- Migration risks and mitigations

> **Note**: Some stack migration data also appears in history.md (Strategy Decisions, Per-Category Stack Choices). If both sources exist, stack-migration.md provides the detailed per-category breakdown while history.md provides decision rationale. Use both for Section 4.

### 3-9. From SBI Coverage (if exists in sdd-state.md)
- Parse Source Behavior Coverage table
- Count per priority: P1 total/verified, P2 total/verified, P3 total/verified
- Overall coverage percentage
- List of unmapped (❌) and deferred (🔒) entries

### 3-10. From case-study-log.md header
- Extract `**Domain**:` field (e.g., `app`, `data-science`)
- Extract `**Archetype**:` field (e.g., `ai-assistant`, `public-api`, `microservice`, or `none`)
- Extract `**Framework**:` field (e.g., `electron`, `express`, or `none`)
- Fallback: read domain/archetype from sdd-state.md if not in log header; framework from constitution-seed.md
- Use in Section 1 Executive Summary

### 3-11. From constitution-seed.md — Philosophy Data (if exists)

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

### 3-12. From case-study-log.md — Philosophy Adherence Data (if exists)

Parse philosophy-related data from milestone entries:

**From M6 entries** — `### Philosophy Adherence` subsections:
- Per-Feature: list of `{Principle name}: {Application description}`
- Aggregate: count of Features per principle, total principle applications across all Features

**From M4 entry** — Archetype/F7 detection results:
- Archetype detected (name(s) or "none"), principle count
- Framework philosophy (name), F7 principle count

**From M5 entry** — Constitution adoption data:
- Archetype principles adopted (list)
- Framework philosophy adopted (list)
- Principles modified from seed (list with change descriptions)

If no M4/M5/M6 Philosophy Adherence entries exist, skip — philosophy report subsections will be omitted.

---

## Step 4 — Report Generation

Assemble the report following the Case Study Agenda. Use `--lang` to determine section headers and descriptive text.

### Section Headers by Language

| # | English | Korean |
|---|---------|--------|
| 1 | Executive Summary | 요약 |
| 2 | Project Background | 프로젝트 배경 |
| 3 | Source Analysis | 소스 분석 |
| 4 | Architecture & Strategy | 아키텍처 및 전략 |
| 5 | Pipeline Execution | 파이프라인 실행 |
| 6 | Quality & Parity | 품질 및 패리티 |
| 7 | Challenges & Solutions | 도전과 해결 |
| 8 | Outcomes & Lessons Learned | 성과 및 교훈 |

### Section 1 — Executive Summary

Auto-generated from aggregated metrics + qualitative context:

```markdown
# Case Study: {Project Name}

## {Section 1 Header}

**Project**: {name} | **Domain**: {domain} | **Archetype**: {archetype or "—"} | **Framework**: {framework or "—"}
**Origin**: {greenfield/rebuild/adoption} | **Scope**: {core/full} | **Stack**: {same/new} | **Features**: {total count} ({completed+adopted}/{total})
```

**System Overview** (from M1 "What it does" + roadmap.md Project Overview):
- What the system does from a user's perspective (1-3 sentences)
- If rebuild/adoption: what was the original system, and what is the target

> **Source priority**: history.md "What it does" (in Project Context) > M1 "What it does" > roadmap.md "Project Overview". If none provides a user-perspective description, synthesize from Feature names and descriptions.

```markdown
### System Overview
{What the system does — user perspective, not tech stack}

### Key Metrics
| Metric | Value |
|--------|-------|
| Features completed | {N}/{total} ({adopted} adopted) |
| Total requirements (FR) | {sum of FR counts} |
| Total success criteria (SC) | {sum of SC counts} |
| Total tasks | {sum of task counts} |
| Entities defined | {count from registry} |
| API endpoints | {count from registry} |
| Source coverage | {% from baseline} |
| SBI coverage | {P1: X/Y (Z%), P2: X/Y (Z%), or "N/A"} |
| Demo Groups | {completed}/{total} groups ({ready} ready for demo) |
| Parity (structural/logic) | {%/% from parity log, or "N/A"} |
| Archetype principles | {N adopted / N total, or "—"} |
| Framework (F7) principles | {N adopted / N total, or "—"} |
```

### Section 2 — Project Background

**Primary sources** (in priority order):
1. **history.md Project Context block** (if exists): Mode (rebuild/adoption/greenfield), Original → Target mapping, Stack strategy, Identity
2. **history.md Strategy Decisions table**: Scope/Stack/Name decisions with rationale
3. **case-study-log.md M1 entry** (if exists): "What it does" (business purpose), anticipated challenges, first impressions
4. **roadmap.md Project Overview section**: project description, source path

**Content structure**:
```markdown
### Why This Project
{From M1 observations + roadmap.md — what the project is and why SDD was applied}

### Stack Profile (optional — include when primary language is NOT JavaScript/TypeScript)
| Dimension | Value |
|-----------|-------|
| Primary Language | {detected from tech stack: Java, Python, Go, Rust, Ruby, PHP, Elixir, C#, Kotlin, etc.} |
| Framework | {detected framework: Spring Boot, Django, Rails, Flask, Actix-web, Chi, ASP.NET Core, Laravel, Phoenix, etc.} |
| Build System | {Maven, Gradle, Mix, Cargo, Go modules, Composer, Bundler, dotnet, etc.} |
| Foundation File | {Foundation file used, or "Generic (Case B)" if no Foundation file exists} |

> This subsection provides ecosystem context for case studies involving non-JS/TS backends. It helps readers understand framework-specific decisions and toolchain choices. Omit for JS/TS projects where the default context is already well-understood.

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

### Anticipated Challenges
{From M1 Anticipated Challenges + initial structure observations}
```

- If no history.md Project Context: omit the Project Context subsection
- If no M1 entry: synthesize from roadmap.md + history.md only

### Section 3 — Source Analysis

- From coverage-baseline.md: Surface Metrics table
- Entity/API/Business rule counts from registries
- From roadmap.md: Feature catalog (ID, name, Tier, description)
- Exclusion summary from coverage-baseline.md (if exists)

### Section 4 — Architecture & Strategy

Structured in 3 subsections. §4.2 and §4.3 only appear when philosophy data is available from constitution-seed.md and/or case-study-log.md milestones; if no philosophy data exists, Section 4 contains only §4.1 (identical to the previous behavior).

#### §4.1 Strategic Decisions

- From history.md: strategy decisions (scope, stack, identity) — with rationale from the Rationale column
- From history.md: stack migration choices — per-category Original → Chosen with reasons (if new stack)
- From history.md: architecture decisions — granularity, tier adjustments, Demo Group definitions with rationale
- From history.md: constitution decisions — version, key modifications
- From constitution-seed.md: key principles (list top 5-7 extracted architecture principles)
- From stack-migration.md (if present): migration strategy, per-category decisions, dependency chain analysis
- From case-study-log.md M3/M5 entries (if exist): qualitative observations

#### §4.2 Architecture Philosophy (conditional — only if philosophy data exists)

> Sources: constitution-seed.md (Steps 3-11), M4 entry (Step 3-12), M5 entry (Step 3-12).
> Omit this entire subsection if constitution-seed.md lacks both `## Archetype-Specific Principles` and `## Framework Philosophy` sections.

**Domain Philosophy** (if archetype detected — from Archetype-Specific Principles section):

```markdown
#### Domain Philosophy — {Archetype Name}

| Principle | Observed Trait | Constitution Status |
|-----------|---------------|-------------------|
| {name} | {observed trait summary} | ✅ Adopted |
| {name} | {observed trait summary} | ✅ Adopted (modified) |
| {name} | {observed trait summary} | ❌ Rejected |
```

**Constitution Status** values — determined by comparing constitution-seed.md principles against the finalized `.specify/memory/constitution.md` content (if available) or M5 adoption data:
- `✅ Adopted` — principle appears in finalized constitution unchanged
- `✅ Adopted (modified)` — principle appears with modifications (note from M5)
- `❌ Rejected` — principle was in seed but removed during finalization (note from M5)
- `⚠️ Added` — not in seed but added during constitution finalization

**Framework Philosophy** (if F7 principles exist — from Framework Philosophy section):

```markdown
#### Framework Philosophy — {Framework Name}

| Principle | Description | Constitution Status |
|-----------|-------------|-------------------|
| {name} | {description} | ✅ Adopted |
| {name} | {description} | ✅ Adopted |
```

Same status determination as Domain Philosophy.

#### §4.3 Principle-to-Decision Mapping (conditional — only if both §4.1 decisions and §4.2 principles exist)

> Correlates architecture decisions from history.md to the principles that motivated them.
> Source: history.md Architecture Decisions + constitution principles from §4.2.

```markdown
#### Principle-to-Decision Mapping

| Decision | Driving Principle | Source | Rationale |
|----------|-------------------|--------|-----------|
| {decision from history.md} | {principle name} | Archetype / F7 / Extracted | {rationale from history.md} |
| {decision} | {principle name} | Archetype | {rationale} |
| {decision} | — | Engineering judgment | {rationale} |
```

For each significant architecture decision in history.md:
1. Check if the decision's rationale references or aligns with a known principle from §4.2
2. If yes: map to that principle with source (Archetype, F7, or Extracted)
3. If no clear principle alignment: mark as "Engineering judgment"

This mapping shows how architecture philosophy translated into concrete implementation decisions.

### Section 5 — Pipeline Execution

- Feature Progress matrix from sdd-state.md (reproduce the step status table)
- Per-Feature metrics table:

```markdown
| Feature | FR | SC | Tasks | Tests | Build | Status |
|---------|----|----|-------|-------|-------|--------|
| F001-auth | 5 | 8 | 12 | 24/24 ✅ | ✅ | completed |
| F002-product | 8 | 12 | 18 | 30/30 ✅ | ✅ | adopted |
```

- Constitution evolution: version history from Constitution Update Log
- Global Evolution Log summary: which registries were updated, by which Features
- Demo Group Progress (if exists): per-group completion status, Integration Demo results
- From case-study-log.md M6 entries (if exist): per-Feature observations — especially "Delivers" (what user can now do)
- From history.md: per-Feature architecture decisions recorded during pipeline execution (e.g., granularity changes, dependency adjustments, restructuring rationale)

### Section 6 — Quality & Parity

- From sdd-state.md Feature Detail Log: verify step results (tests, build, lint, cross-Feature)
- SBI Coverage (if exists): P1/P2/P3 mapping percentages, unmapped behavior list, deferred behaviors
- From sdd-state.md Parity Check Log (if exists): structural/logic parity %
- Exclusion audit from coverage-baseline.md (if exists)
- From case-study-log.md M7 entry (if exists): parity observations

### Section 7 — Challenges & Solutions

- Aggregated from case-study-log.md: all "Challenges" subsections across M2-M8
- From sdd-state.md: any ❌ (failed) or ⚠️ (limited) steps with their notes
- From sdd-state.md: Restructure Log entries (if any Feature restructuring occurred)
- From history.md: per-Feature Implementation Decisions that resolved challenges (spec deviations, architecture trade-offs, limited verification decisions with rationale)
- From history.md: restructure/parity decisions that addressed structural issues
- If no qualitative data: show only structural issues (failed/limited steps, restructures)

**Challenge categorization hint** (for multi-language or non-JS/TS projects):
When reporting challenges, categorize by source where possible:
- **Language/Runtime**: Challenges specific to the programming language or runtime (e.g., Rust borrow checker, Go error handling verbosity, Elixir hot code reloading, JVM startup time)
- **Framework Convention**: Challenges from framework-specific patterns (e.g., Rails convention compliance, Spring auto-configuration conflicts, Django migration ordering)
- **Ecosystem Tooling**: Challenges from build/test/lint tooling (e.g., Gradle configuration complexity, Mix/Hex ecosystem gaps, Cargo compile times)
- **Domain Complexity**: Challenges from business logic regardless of tech stack (e.g., workflow state machines, payment processing edge cases)
- **Foundation Gap**: Challenges from missing or incomplete Foundation files (when Generic Foundation Case B was used)

> This categorization is a guideline, not a required format. Apply when the project's challenges have a meaningful relationship to its tech stack.

### Section 8 — Outcomes & Lessons Learned

**What was delivered** (from M6 "Delivers" entries + Feature descriptions):
- Aggregate all M6 "Delivers" lines to build a user-facing narrative of what the completed system can do
- Group by Demo Group (if exists) to show end-to-end scenarios

**Impact Assessment** (auto-generated):
- Before vs After comparison table:
  ```markdown
  | Aspect | Before | After |
  |--------|--------|-------|
  | Documentation | {none/partial/existing} | {FR/SC/entity/API counts} |
  | Test coverage | {from M1 anticipated or sdd-state pre-existing} | {from verify results} |
  | Architecture visibility | {unknown/undocumented} | {entity-registry + api-registry + constitution} |
  | Behavior traceability | {none} | {SBI coverage P1/P2/P3 %} |
  ```

**Summary metrics comparison** (planned vs actual):
- Planned Features vs completed/adopted Features
- Planned scope (core/full) vs actual delivery
- From history.md: key decisions that shaped the outcome (strategy pivots, scope changes, restructuring)

**From case-study-log.md M8 entry** (if exists): overall assessment, key learnings, recommendations

**Auto-generated insights**:
- Features with most restructuring or re-execution
- Registry growth pattern (entities/APIs added over time from Global Evolution Log)
- Average FR/SC per Feature
- Key decisions from history.md that had the most impact on the final architecture

**Architecture Philosophy Assessment** (conditional — only if M6 Philosophy Adherence data exists from Step 3-12):

> This subsection evaluates how effectively the adopted architecture philosophy guided implementation decisions. Omit entirely if no M6 Philosophy Adherence entries exist.

**Principle Application Coverage**:

```markdown
#### Philosophy Assessment

| Principle | Source | Features Applied | Examples |
|-----------|--------|-----------------|----------|
| {name} | Archetype | {N}/{total completed} ({FID list}) | {brief example from M6 adherence} |
| {name} | F7 | {N}/{total completed} ({FID list}) | {brief example} |
| {name} | Extracted | {N}/{total completed} ({FID list}) | {brief example} |
```

**Principle Gaps** (auto-detected):
- List principles from the constitution that were never referenced in any M6 Philosophy Adherence entry
- Annotate each gap: "Aspirational — may not have been applicable to implemented Features" or "Implicit — likely followed but not explicitly recorded"

**Module Feedback** (auto-generated suggestions for domain module improvement):
- If archetype was active and some principles had zero Feature applications: "Consider whether `{principle}` should be refined or marked optional for `{archetype}` projects"
- If all F7 principles were applied across Features: "F7 principles for `{framework}` provided effective architectural guidance across the project"
- If no archetype was active but domain-specific decisions were frequent in history.md: "This project's decision patterns suggest a potential new archetype module for `{inferred domain pattern}`"
- If some principles were modified during constitution finalization (from M5): note which modifications proved effective based on Feature outcomes

---

## Step 5 — Output

Always write the report to a timestamped file in the target directory.

1. Generate output filename: `case-study-YYYYMMDD-HHMM.md` using the current local date/time
   - Example: `case-study-20260305-1430.md`
2. Output path: `{target-directory}/case-study-YYYYMMDD-HHMM.md`
3. Write the report using the Write tool
4. Display a summary in the conversation:
   ```
   ✅ Case Study report generated: {output path}

   {Section 1 — Executive Summary content}
   ```
