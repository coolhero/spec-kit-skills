# Case Study Recording Protocol

> **Execution reference** — Workflow files trigger recording by referencing `§ M{N}` of this document. The agent reads the corresponding section and appends an entry to `case-study-log.md` (project root).

Recording is **automatic** at each milestone — the agent composes observations from available context. No user interaction is needed.

---

## Entry Format

Every entry follows this structure. Append to `case-study-log.md` chronologically.

```markdown
## [YYYY-MM-DD] M{N} — {Milestone Name}

**Context**: {What phase/step was just completed}

### Observations
- {What you noticed, impressions, scale assessment}

### Challenges
- {Problems encountered and how they were resolved, or "None"}

### Key Decisions
- {Decisions made and their rationale, or "None"}
```

---

## Milestones

### M1 — Project Background

**Trigger**: After case-study-log initialization, before `/reverse-spec` Phase 0 strategy questions.

**Data Sources**: Target directory structure, file counts, README, package.json (or equivalent).

**What to record**:
- Project name, detected language/framework (first impression)
- Approximate scale (file count, directory depth)
- Structure type (monorepo, monolith, micro-service, library, etc.)
- Why SDD is being applied (rebuild, adoption, etc.)
- Anticipated challenges based on initial observation

**Template**:
```markdown
## [YYYY-MM-DD] M1 — Project Background

**Context**: Before starting /reverse-spec analysis on {target-directory}

### Observations
- Project: {name}, Tech stack: {first impression of languages/frameworks}
- Scale: {N} source files, Structure: {monorepo/monolith/etc.}

### Anticipated Challenges
- {Based on source structure — e.g., "tightly coupled modules", "no tests", "undocumented APIs"}
```

---

### M2 — Phase 1 Complete

**Trigger**: After `/reverse-spec` Phase 1 report (tech stack detection, project structure scan, static resources).

**Data Sources**: Phase 1 scan results — detected tech stack, file counts, static resource inventory.

**What to record**:
- Confirmed tech stack (vs. first impression)
- Actual scale and complexity
- Unexpected findings (unusual file structures, legacy code patterns, mixed languages)
- Static resource inventory highlights

**Template**:
```markdown
## [YYYY-MM-DD] M2 — Phase 1 Complete

**Context**: After Phase 1 — scanning, tech stack detection, static resources

### Observations
- Tech stack: {confirmed stack details}
- Source files: {N}, Scale assessment: {small/medium/large}
- {Any unexpected findings — e.g., "mixed Python 2/3", "vendored dependencies"}

### Challenges
- {Scanning difficulties or unusual project structure, or "None"}
```

---

### M3 — Deep Analysis & Feature Classification

**Trigger**: After `/reverse-spec` Phase 2 (deep analysis) and Phase 3 (Feature classification, Demo Groups) complete.

**Data Sources**: Entity/API/SBI counts from Phase 2, Feature list and Tier distribution from Phase 3, Demo Group definitions.

**What to record**:
- Entity, API, business rule, SBI behavior counts
- Number of Features identified, Tier distribution (T1/T2/T3)
- Demo Group count and strategy
- Feature boundary decisions and rationale
- Tier classification reasoning (if core scope)

**Template**:
```markdown
## [YYYY-MM-DD] M3 — Deep Analysis & Feature Classification

**Context**: After Phase 2 (deep analysis) and Phase 3 (feature classification)

### Observations
- Entities: {N}, APIs: {N}, Business rules: {N}, SBI behaviors: {N}
- Features: {N} identified — {Tier distribution if core scope}
- Demo Groups: {N} defined

### Key Decisions
- {Feature boundary rationale, Tier classification reasoning, Demo Group strategy}
```

---

### M4 — Artifact Generation Complete

**Trigger**: After `/reverse-spec` Phase 4 (artifact generation, coverage baseline), before 4-4 Completion Report.

**Data Sources**: Generated artifact list, SBI coverage baseline, user corrections during coverage review.

**What to record**:
- Artifact completeness (all expected files generated?)
- SBI coverage baseline numbers
- Coverage gaps and manual corrections
- Any items classified as unclassified/excluded

**Template**:
```markdown
## [YYYY-MM-DD] M4 — Artifact Generation Complete

**Context**: After Phase 4 — pre-context generation, coverage baseline

### Observations
- Artifacts: {list of key deliverables generated}
- SBI coverage baseline: {N}/{total} behaviors mapped to Features
- {Coverage gap details if any}

### Challenges
- {Unmapped items, ambiguous code, coverage classification difficulties, or "None"}
```

---

### M5 — Constitution Finalized

**Trigger**: After `/smart-sdd` constitution finalization (Phase 0-4 Update), before proceeding to Feature pipeline.

**Data Sources**: Constitution version, principles from generated constitution.md, modifications from constitution-seed.

**What to record**:
- Constitution version
- Top principles summarized
- Modifications made from seed (if any)
- Reasoning for key principle choices

**Template**:
```markdown
## [YYYY-MM-DD] M5 — Constitution Finalized

**Context**: After constitution finalization (v{version})

### Observations
- Constitution version: {version}
- Key principles: {top 3-5 principles summarized}

### Key Decisions
- {Modifications from constitution-seed, or "Accepted as-is"}
```

---

### M6 — Feature Complete

**Trigger**: After each Feature's merge step completes (per Feature — repeatable).

**Data Sources**: Feature's spec.md (FR/SC counts), tasks.md (task count), verify results (test/build), sdd-state.md Feature Detail Log.

**What to record**:
- FR, SC, task counts for this Feature
- Test and build results from verify
- Implementation difficulties or spec ambiguities resolved
- Architecture or API design decisions made
- **Adoption mode**: Pre-existing issues discovered, how existing code mapped to SDD

Use format: `M6 — Feature [FID]-[name]` (or `M6 — Feature [FID]-[name] (adopted)` for adoption).

**Template (standard)**:
```markdown
## [YYYY-MM-DD] M6 — Feature {FID}-{name}

**Context**: After {FID}-{name} completed and merged to main

### Observations
- FR: {N}, SC: {N}, Tasks: {N}
- Test/Build: {results from verify}

### Challenges
- {Spec ambiguities, analyze findings, implementation difficulties, or "None"}

### Key Decisions
- {Architecture choices, entity/API design decisions, or "None"}
```

**Template (adoption)**:
```markdown
## [YYYY-MM-DD] M6 — Feature {FID}-{name} (adopted)

**Context**: After {FID}-{name} adoption merge to main

### Observations
- FR: {N} extracted, SC: {N} documented
- Pre-existing issues: {test/build status}
- SBI mapping: {how well existing code mapped to Feature}

### Challenges
- {Difficulty extracting behavior from existing code, or "None"}
```

---

### M7 — Parity Check Complete

**Trigger**: After `/smart-sdd parity` completes (rebuild only, if applicable).

**Data Sources**: parity-report.md, SBI coverage from sdd-state.md.

**What to record**:
- Parity results (structural/logic gap counts)
- SBI coverage status (P1/P2/P3 percentages)
- Gap resolution strategy
- Remaining gaps and their classification

**Template**:
```markdown
## [YYYY-MM-DD] M7 — Parity Check Complete

**Context**: After parity verification against original source

### Observations
- Structural gaps: {N}, Logic gaps: {N}
- SBI Coverage: P1 {%}, P2 {%}, P3 {%}

### Key Decisions
- {Gap resolution strategy — fix, defer, or accept}
```

---

### M8 — Pipeline Complete

**Trigger**: After all Features are completed/adopted and pipeline ends.

**Data Sources**: sdd-state.md final state, registry counts, pipeline execution history, Demo Group results.

**What to record**:
- Total Features completed/adopted
- Constitution version and update count
- Registry growth (entity/API counts)
- Demo Group completion status
- Overall assessment and key learnings
- **Adoption mode**: SBI coverage post-gap-resolution, pre-existing issue summary, final demo result

**Template (standard pipeline)**:
```markdown
## [YYYY-MM-DD] M8 — Pipeline Complete

**Context**: All {N} Features completed and merged

### Observations
- Features: {N}/{total} completed
- Constitution: v{version}, {N} updates during pipeline
- Registries: {entity count} entities, {API count} endpoints
- Demo Groups: {completed}/{total}

### Key Decisions
- {Major pivots, restructuring events, or "None"}
```

**Template (adoption pipeline)**:
```markdown
## [YYYY-MM-DD] M8 — Adoption Pipeline Complete

**Context**: All Features adopted, coverage verified, final demo created

### Observations
- Features adopted: {N}/{total}
- SBI Coverage: P1 {%}, P2 {%}, P3 {%}
- Pre-existing issues: {summary}
- Final demo: {result}

### Challenges
- {Hardest Features to document, coverage gaps resolved, or "None"}
```

---

## Tips

- **M6 entries are repeatable** — one per Feature.
- Keep observations concise but specific — they feed into the Case Study's "Challenges & Solutions" and "Outcomes & Lessons Learned" sections.
- Quantitative data (FR/SC counts, test results) is also extracted automatically from artifacts by `/case-study generate`. Focus on **qualitative** observations that artifacts cannot capture.
- If a milestone has no meaningful observations (e.g., everything went smoothly), still record the entry with "None" for Challenges/Key Decisions — the quantitative data in Observations is still valuable.
