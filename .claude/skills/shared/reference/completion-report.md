# Completion Analysis Report — Shared Template

> Used by both reverse-spec (Phase 4 completion) and smart-sdd adopt (post-pipeline).
> Each mode fills in mode-specific sections; shared sections use identical format.

## Template Structure

### § 1. Project Profile (shared)
```
| Field | Value |
|-------|-------|
| **Project** | [name] |
| **Mode** | [reverse-spec / adoption] |
| **Date** | [timestamp] |
| **Language Composition** | [from Phase 1-2a] |
| **Scale** | [Micro/Small/Medium/Large] |
| **Domain Profile** | [5 axes + Scale modifier summary] |
| **Module Structure** | [monorepo/single-package, N modules/packages] |
```

### § 2. Feature Catalog (shared)
- Total Features: [N]
- Release Groups: [list with Feature counts]
- Tier distribution: T1 [N] / T2 [N] / T3 [N]
- Dependency highlights: [key cross-Feature dependencies]

### § 3. Source Behavior Inventory (shared structure, mode-specific content)
```
| Metric | Count |
|--------|-------|
| Total SBI entries | [N] |
| P1 (critical) | [N] |
| P2 (important) | [N] |
| P3 (minor) | [N] |
| Languages covered | [list] |
```

**[reverse-spec only]** SBI Extraction Confidence:
- Fully analyzed modules: [N/total] ([%])
- Estimated coverage: [%] of exported functions/methods

**[adopt only]** SBI → FR Mapping:
- P1 mapped: [X/Y] ([%])
- P2 mapped: [X/Y] ([%])
- Unmapped P1/P2 entries: [list if any]

### § 4. Entity & API Summary (shared)
- Entities: [N] total, [N] cross-Feature shared
- APIs: [N] total, [N] internal / [N] external
- Top shared entities: [list top 3-5]

### § 5. Quality & Risk Assessment (mode-specific)

**[reverse-spec]**:
| Phase | Confidence | Notes |
|-------|-----------|-------|
| Phase 1 (Scan) | ✅/⚠️ | [coverage note] |
| Phase 1.5 (Runtime) | ✅/⚠️/skipped | [reason if skipped] |
| Phase 2 (Deep) | ✅/⚠️ | [any modules with low confidence] |
| Phase 3 (Classify) | ✅/⚠️ | [boundary ambiguities] |
| Phase 4 (Generate) | ✅/⚠️ | [completeness] |

**[adopt]**:
| Feature | Specify | Plan | Analyze | Verify | Status |
|---------|---------|------|---------|--------|--------|
| [FID] | ✅/⚠️ | ✅/⚠️ | ✅/⚠️ | ✅/⚠️/skipped | adopted |

### § 6. Recommendations (mode-specific)

**[reverse-spec]**:
- Recommended next step: [adopt / rebuild / explore further]
- Areas needing deeper exploration: [list]
- Potential Feature boundary adjustments: [list]

**[adopt]**:
- Pre-existing issues to address: [list with severity]
- Recommended improvements: [list]
- Features needing deeper specification: [list]

### § 7. Artifact Inventory (shared)
| Artifact | Path | Status |
|----------|------|--------|
| roadmap.md | specs/_global/ | ✅ |
| entity-registry.md | specs/_global/ | ✅ |
| ... | ... | ... |

---

## Generation Protocol

### For reverse-spec (Phase 4 completion):
After Phase 4-4 (Completion Report display), generate `specs/_global/completion-report.md`:
1. Read all Phase artifacts to populate sections
2. Mode = "reverse-spec"
3. Fill §1-§4 from generated artifacts
4. Fill §5 with per-phase confidence assessment
5. Fill §6 with recommended next steps
6. Fill §7 with artifact inventory
7. Display summary in Phase 4-4 Completion Report
8. Save to `specs/_global/completion-report.md`

### For smart-sdd adopt (post-pipeline):
After Post-Pipeline Coverage Verification, generate `specs/_global/adoption-report.md`:
1. Read all Feature artifacts (spec.md, plan.md, verify results)
2. Mode = "adoption"
3. Fill §1-§4 from sdd-state.md + registries
4. Fill §5 with per-Feature adoption status table
5. Fill §6 with recommendations
6. Fill §7 with artifact inventory
7. Display summary in Post-Pipeline Summary
8. Save to `specs/_global/adoption-report.md`

### Relationship between reports:
- If both exist: `adoption-report.md` references `completion-report.md` as "pre-adoption analysis"
- `adoption-report.md` §3 SBI→FR section compares against `completion-report.md` §3 SBI totals
- Enables: "reverse-spec found 450 SBI entries → adoption mapped 420 to FRs (93% coverage)"
