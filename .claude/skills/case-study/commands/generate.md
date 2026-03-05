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
| `case-study-log.md` | `{BASE_PATH}/case-study-log.md` | Qualitative observations (M1-M8) |
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
- Extract Strategy Decisions table
- Extract Per-Category Stack Choices table (if new stack)
- Extract Architecture Decisions table

### 3-8. From SBI Coverage (if exists in sdd-state.md)
- Parse Source Behavior Coverage table
- Count per priority: P1 total/verified, P2 total/verified, P3 total/verified
- Overall coverage percentage
- List of unmapped (❌) and deferred (🔒) entries

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

Auto-generated from aggregated metrics:

```markdown
# Case Study: {Project Name}

## {Section 1 Header}

**Project**: {name} | **Domain**: {domain} | **Origin**: {greenfield/rebuild/adoption}
**Scope**: {core/full} | **Stack**: {same/new} | **Features**: {total count} ({completed+adopted}/{total})

{1-3 sentence summary of the project and key outcomes}

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
```

### Section 2 — Project Background

- From case-study-log.md M1 entry (if exists): project description, why SDD, goals, anticipated challenges
- From roadmap.md: project overview section
- From history.md: strategy decisions table
- If no qualitative data: show project overview from roadmap.md only

### Section 3 — Source Analysis

- From coverage-baseline.md: Surface Metrics table
- Entity/API/Business rule counts from registries
- From roadmap.md: Feature catalog (ID, name, Tier, description)
- Exclusion summary from coverage-baseline.md (if exists)

### Section 4 — Architecture & Strategy

- From history.md: strategy decisions (scope, stack, identity)
- From history.md: stack migration choices (if new stack)
- From history.md: architecture decisions (granularity, tier adjustments)
- From constitution-seed.md: key principles (list top 5-7 principles)
- From case-study-log.md M3/M5 entries (if exist): qualitative observations

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
- From case-study-log.md M6 entries (if exist): per-Feature observations

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
- If no qualitative data: show only structural issues (failed/limited steps, restructures)

### Section 8 — Outcomes & Lessons Learned

- Summary metrics comparison (planned vs actual)
- From case-study-log.md M8 entry (if exists): overall assessment, key learnings, recommendations
- Auto-generated insights:
  - Features with most restructuring or re-execution
  - Registry growth pattern (entities/APIs added over time from Global Evolution Log)
  - Average FR/SC per Feature

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
