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

**Trigger**: After case-study-log initialization, before `/reverse-spec` Phase 0.

**What to record**: Project name/stack (first impression), approximate scale, structure type, anticipated challenges.

```markdown
## [YYYY-MM-DD] M1 — Project Background
**Context**: Before starting /reverse-spec analysis on {target-directory}
### Observations
- Project: {name}, Tech stack: {first impression}, Scale: {N} files, Structure: {type}
### Anticipated Challenges
- {e.g., "tightly coupled modules", "no tests"}
```

---

### M2 — Phase 1 Complete

**Trigger**: After `/reverse-spec` Phase 1 report.

**What to record**: Confirmed tech stack vs first impression, actual scale, unexpected findings.

```markdown
## [YYYY-MM-DD] M2 — Phase 1 Complete
**Context**: After Phase 1 — scanning, tech stack detection, static resources
### Observations
- Tech stack: {confirmed}, Source files: {N}, Scale: {small/medium/large}
### Challenges
- {Scanning difficulties or unusual structure, or "None"}
```

---

### M3 — Deep Analysis & Feature Classification

**Trigger**: After `/reverse-spec` Phase 2-3 complete.

**What to record**: Entity/API/SBI counts, Feature count and Tier distribution, Feature boundary rationale.

```markdown
## [YYYY-MM-DD] M3 — Deep Analysis & Feature Classification
**Context**: After Phase 2 (deep analysis) and Phase 3 (feature classification)
### Observations
- Entities: {N}, APIs: {N}, SBI behaviors: {N}
- Features: {N} identified, Demo Groups: {N}
### Key Decisions
- {Feature boundary rationale, Tier classification reasoning}
```

---

### M4 — Artifact Generation Complete

**Trigger**: After `/reverse-spec` Phase 4, before 4-4 Completion Report.

**What to record**: Artifact completeness, SBI coverage baseline, coverage gaps.

```markdown
## [YYYY-MM-DD] M4 — Artifact Generation Complete
**Context**: After Phase 4 — pre-context generation, coverage baseline
### Observations
- Artifacts: {key deliverables}, SBI coverage: {N}/{total} mapped
### Challenges
- {Unmapped items, coverage gaps, or "None"}
```

---

### M5 — Constitution Finalized

**Trigger**: After `/smart-sdd` constitution finalization (Phase 0-4 Update).

**What to record**: Constitution version, top principles, modifications from seed.

```markdown
## [YYYY-MM-DD] M5 — Constitution Finalized
**Context**: After constitution finalization (v{version})
### Observations
- Constitution version: {version}, Key principles: {top 3-5 summarized}
### Key Decisions
- {Modifications from constitution-seed, or "Accepted as-is"}
```

---

### M6 — Feature Complete

**Trigger**: After each Feature's merge step (repeatable per Feature).

**What to record**: FR/SC/task counts, verify results, implementation difficulties, architecture decisions. Use `M6 — Feature [FID]-[name]` (or `(adopted)` for adoption).

```markdown
## [YYYY-MM-DD] M6 — Feature {FID}-{name}
**Context**: After {FID}-{name} completed and merged
### Observations
- FR: {N}, SC: {N}, Tasks: {N}, Test/Build: {results}
### Challenges
- {Spec ambiguities, implementation difficulties, or "None"}
### Key Decisions
- {Architecture choices, or "None"}
```

For adoption, replace Observations with: `FR: {N} extracted, SC: {N} documented, Pre-existing issues: {status}, SBI mapping: {quality}`.

---

### M7 — Parity Check Complete

**Trigger**: After `/smart-sdd parity` completes (rebuild only).

**What to record**: Structural/logic gap counts, SBI coverage percentages, gap resolution strategy.

```markdown
## [YYYY-MM-DD] M7 — Parity Check Complete
**Context**: After parity verification against original source
### Observations
- Structural gaps: {N}, Logic gaps: {N}, SBI Coverage: P1 {%}, P2 {%}, P3 {%}
### Key Decisions
- {Gap resolution strategy — fix, defer, or accept}
```

---

### M8 — Pipeline Complete

**Trigger**: After all Features completed/adopted and pipeline ends.

**What to record**: Total Features, constitution version/updates, registry counts, Demo Group status, key learnings. For adoption: add SBI coverage and pre-existing issue summary.

```markdown
## [YYYY-MM-DD] M8 — Pipeline Complete
**Context**: All {N} Features completed and merged
### Observations
- Features: {N}/{total}, Constitution: v{version} ({N} updates)
- Registries: {entity count} entities, {API count} endpoints, Demo Groups: {completed}/{total}
### Key Decisions
- {Major pivots, restructuring events, or "None"}
```

---

## Tips

- **M6 entries are repeatable** — one per Feature.
- Keep observations concise but specific — they feed into the Case Study's "Challenges & Solutions" and "Outcomes & Lessons Learned" sections.
- Quantitative data (FR/SC counts, test results) is also extracted automatically from artifacts by `/case-study generate`. Focus on **qualitative** observations that artifacts cannot capture.
- If a milestone has no meaningful observations (e.g., everything went smoothly), still record the entry with "None" for Challenges/Key Decisions — the quantitative data in Observations is still valuable.
