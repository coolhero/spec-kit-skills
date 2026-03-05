# Case Study Recording Protocol

This document defines what observations to record at each milestone during `/reverse-spec` and `/smart-sdd` execution. Recorded observations are stored in `specs/reverse-spec/case-study-log.md` and aggregated by `/case-study generate`.

---

## Milestone Reference

| ID | When | What to Record |
|----|------|---------------|
| **M1** | Before `/reverse-spec` (rebuild/adoption) | Project background, why SDD redevelopment/adoption, expected goals, anticipated challenges |
| **M2** | After `/reverse-spec` Phase 1 | First impressions of codebase, scale/complexity assessment, unexpected findings |
| **M3** | After `/reverse-spec` Phase 2-3 | Entity/API complexity observations, Feature decomposition rationale, Tier adjustment reasons, Demo Group selection rationale |
| **M4** | After `/reverse-spec` Phase 4-5 | Artifact completeness assessment, SBI coverage baseline, coverage gap observations, manual corrections made |
| **M5** | After `/smart-sdd` constitution | Key constitution principles chosen, modifications made, reasoning |
| **M6** | After each Feature completion | Per-Feature challenges, key decisions, perceived time investment, improvement ideas. **Adoption mode**: Record adopt results (pre-existing issues, test baseline, documentation coverage) |
| **M7** | After Parity Check (if applicable) | Parity results assessment, SBI coverage status (P1/P2/P3 percentages), gap resolution strategy |
| **M8** | After full completion | Overall assessment, key learnings, workflow improvement suggestions, Demo Group Integration Demo results |

---

## Entry Format

Each entry follows this format. Append to `case-study-log.md` chronologically.

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

## Tips

- **M6 entries are repeatable** — create one per Feature. Use `M6 — Feature F001-auth` format.
- Keep observations concise but specific — they feed directly into the Case Study's "Challenges & Solutions" and "Outcomes & Lessons Learned" sections.
- Quantitative data (FR/SC counts, test results, entity counts) is extracted automatically from artifacts — focus on **qualitative** observations that artifacts cannot capture.
- If running with `--auto` or `--dangerously-skip-permissions`, record observations after the run completes (M4/M8).
