# Scenario Catalog — spec-kit-skills

> Exhaustive catalog of user scenarios. Used as a verification checklist during full-file reviews (see CLAUDE.md § Review Protocol).
> Each scenario specifies the command flow, preconditions, and expected outcome.

---

## How to Read This Catalog

| Column | Meaning |
|--------|---------|
| **ID** | `S{category}{number}` — unique, stable reference |
| **Flow** | Command sequence the user runs |
| **Precondition** | What must exist before starting |
| **Outcome** | What the user gets when done |
| **Status** | ✅ Fully supported · 🟡 Partial · ❌ Not yet supported |

---

## Category A: Learning & Exploration (code-explore)

| ID | Scenario | Flow | Precondition | Outcome | Status |
|----|----------|------|-------------|---------|--------|
| SA01 | Study unfamiliar codebase | `code-explore [path]` → traces → synthesis | Source code exists | Architecture map + trace docs | ✅ |
| SA02 | Study specific module only | `code-explore [path] --scope src/auth` | Source code exists | Scoped orientation + traces | ✅ |
| SA03 | Quick single-flow trace | `code-explore [path]` → `trace "login flow"` | Source code exists | Single trace document | ✅ |
| SA04 | Onboard new team member | `code-explore .` → traces → synthesis | Team project | Architecture docs for onboarding | ✅ |
| SA05 | Compare two projects | `code-explore A` → `code-explore B` → synthesis (comparison mode) | Two source dirs | Comparison table + architectural diff | ✅ |
| SA06 | Post-adopt deep exploration | `adopt` → `code-explore .` (Context-Aware) | sdd-state.md exists | Exploration enriched by existing SDD context | ✅ |
| SA07 | Mid-pipeline investigation | During pipeline → `code-explore . --scope src/module --no-branch` | Active pipeline | Understanding of specific area without disrupting pipeline | ✅ |
| SA08 | Post-pipeline architecture docs | Pipeline complete → `code-explore .` (Context-Aware) | All Features completed | Architecture docs cross-referenced with specs | ✅ |
| SA09 | Debug investigation | Bug found → `code-explore . --scope src/buggy` → trace → fix | Running project | Trace of buggy flow with observations | ✅ |
| SA10 | Security audit exploration | `code-explore .` → traces focusing on auth/crypto flows | Source code exists | 🔒 Security observations catalog | ✅ |

## Category B: Greenfield Projects (smart-sdd init + add + pipeline)

| ID | Scenario | Flow | Precondition | Outcome | Status |
|----|----------|------|-------------|---------|--------|
| SB01 | New project from idea | `init "Build a chat app"` → auto-chains add → pipeline | Nothing | Full project with Features implemented | ✅ |
| SB02 | New project after studying existing code | `code-explore A` → `init B --from-explore` → add → pipeline | Source A studied | New project B informed by A's architecture | ✅ |
| SB03 | New project with specific profile | `init --profile grpc-service` → add → pipeline | Nothing | Project with pre-set domain profile | ✅ |
| SB04 | Add single Feature | `add "user authentication"` → pipeline | init completed | One Feature specified + implemented | ✅ |
| SB05 | Add multiple Features batch | `add` → define F001-F005 → `pipeline` | init completed | Multiple Features in sequence | ✅ |
| SB06 | Add Feature from exploration | `code-explore` → synthesis → `add --from-explore` → pipeline | Exploration done | Feature candidates from traces | ✅ |
| SB07 | T1-only MVP pipeline | `pipeline --tier 1` | Features defined | Only Tier 1 Features built | ✅ |
| SB08 | Single Feature pipeline | `pipeline F003` | F003 defined | Only F003 built | ✅ |
| SB09 | Resume interrupted pipeline | `pipeline --continue` | Pipeline interrupted | Resumes from last checkpoint | ✅ |
| SB10 | Re-init failed project | Delete specs/ → `init` again | Failed previous attempt | Fresh start | ✅ |

## Category C: Adopt Existing Code (smart-sdd adopt)

| ID | Scenario | Flow | Precondition | Outcome | Status |
|----|----------|------|-------------|---------|--------|
| SC01 | Adopt existing codebase | `adopt --lang ko` | Source code, no SDD artifacts | reverse-spec auto-chained → all Features documented (adopted) | ✅ |
| SC02 | Adopt with prior exploration | `code-explore` → `adopt --from-explore` | Exploration done | Adoption enriched by traces | ✅ |
| SC03 | Adopt → add new Feature | `adopt` → `add "new feature"` → `pipeline` | Source code | Existing code wrapped + new Feature built | ✅ |
| SC04 | Adopt → fix existing issues | `adopt` → `pipeline` | Source code | Existing Features re-implemented with fixes | ✅ |
| SC05 | Adopt → explore → add | `adopt` → `code-explore` (Context-Aware) → `add` → `pipeline` | Source code | Deep understanding → targeted new Feature | ✅ |
| SC06 | Adopt monorepo service | `adopt --scope services/api` | Monorepo | Single service documented | ✅ |
| SC07 | Adopt with migration intent | `adopt` → identify migration targets → `pipeline --migration` | Legacy code | Modernization plan + execution | ✅ |

## Category D: Rebuild (reverse-spec + pipeline)

| ID | Scenario | Flow | Precondition | Outcome | Status |
|----|----------|------|-------------|---------|--------|
| SD01 | Full rebuild same stack | `reverse-spec . --adopt` → `pipeline` | Source code | Complete rewrite with same tech | ✅ |
| SD02 | Rebuild different stack | `reverse-spec .` → `init --stack new` → `pipeline` | Source code | Rewrite with new tech stack | ✅ |
| SD03 | Rebuild after exploration | `code-explore` → `reverse-spec --from-explore` → `pipeline` | Source studied | Informed rebuild | ✅ |
| SD04 | Partial rebuild (T1 only) | `reverse-spec` → `pipeline --tier 1` | Source code | Core Features rebuilt, others deferred | ✅ |
| SD05 | Cross-project rebuild | `reverse-spec A` (from dir B) → `pipeline` | Source A, target dir B | Rebuild A's Features in B | ✅ |

## Category E: Pipeline Iteration & Revision

| ID | Scenario | Flow | Precondition | Outcome | Status |
|----|----------|------|-------------|---------|--------|
| SE01 | Reject spec → revise | HARD STOP "reject" at specify → re-specify | Feature in specify | Revised spec.md | ✅ |
| SE02 | Go back specify → plan | At plan HARD STOP → "back to specify" | Feature in plan | Re-specify with new understanding | ✅ |
| SE03 | Go back plan → implement | At implement → "back to plan" | Feature in implement | Revised plan.md | ✅ |
| SE04 | Verify failure → fix → re-verify | verify finds bug → fix → re-verify | Feature in verify | Bug fixed, verify passes | ✅ |
| SE05 | Supplement existing Feature | Feature completed → `pipeline F001 --step specify` | F001 completed | Re-open F001 for enhancement | ✅ |
| SE06 | Split oversized Feature | During add → realize too big → split into F001a + F001b | Feature too large | Two smaller Features | ✅ |
| SE07 | Merge related Features | `pipeline merge F003 F004` | Two overlapping Features | Single consolidated Feature | ✅ |
| SE08 | Skip implement (spec-only) | `pipeline F001 --step specify,plan` | Feature defined | Spec + plan without implementation | ✅ |
| SE09 | Augment existing Feature | `add --to F001 "add OAuth"` → `pipeline F001` | F001 defined or completed | F001 pre-context augmented → re-specify with SC preservation | ✅ |
| SE10 | Augment from file | `add --to F001 oauth-spec.md` | F001 exists + file | Same as SE09 but from document | ✅ |

## Category F: Multi-Feature Coordination

| ID | Scenario | Flow | Precondition | Outcome | Status |
|----|----------|------|-------------|---------|--------|
| SF01 | Dependent Features (F002 needs F001) | `pipeline F001` → `pipeline F002` | F002 depends on F001 | F002 built on F001's foundation | ✅ |
| SF02 | Independent parallel Features | `pipeline F001` → `pipeline F002` (no dependency) | No inter-dependency | Both built independently, merged to main | ✅ |
| SF03 | Return to earlier Feature | F001+F002 done → `pipeline F001 --step specify` | F001 needs enhancement | F001 re-opened on fresh branch from main | ✅ |
| SF04 | Cross-Feature entity sharing | F001 defines User → F002 uses User | Shared entity | entity-registry.md ensures consistency | ✅ |
| SF05 | Feature dependency chain | F001 → F002 → F003 (linear) | Chain dependency | Pipeline respects order | ✅ |

## Category G: Coverage & Status

| ID | Scenario | Flow | Precondition | Outcome | Status |
|----|----------|------|-------------|---------|--------|
| SG01 | Check SBI coverage | `coverage` | adopt completed | SBI coverage report | ✅ |
| SG02 | Check spec-code parity | `parity` | Features implemented | Parity report | ✅ |
| SG03 | Check pipeline status | `status` | Pipeline active | Status dashboard | ✅ |
| SG04 | Check exploration status | `code-explore status` | Exploration active | Coverage + trace index | ✅ |

## Category H: Special Modes & Advanced

| ID | Scenario | Flow | Precondition | Outcome | Status |
|----|----------|------|-------------|---------|--------|
| SH01 | Polyglot project | `init` with multiple languages detected | Multi-language codebase | polyglot + codegen concerns activated | ✅ |
| SH02 | Plugin/extension development | `init --profile sdk-library` → add → pipeline | Framework exists | Plugin with extension points | ✅ |
| SH04 | Migration/modernization | `adopt` → `pipeline --migration` | Legacy code | Modernized codebase | ✅ |
| SH05 | Different artifact language | `init --lang ko` or `adopt --lang ja` | Any | All artifacts in specified language | ✅ |
| SH06 | Large codebase (1000+ files) | `reverse-spec .` with parallel sub-agents | Large repo | Distributed analysis | ✅ |
| SH07 | Monorepo multi-service | `adopt --scope services/api` per service | Monorepo | Per-service SDD docs | ✅ |
| SH08 | CI/CD integration | `pipeline` in CI environment (no Playwright) | CI runner | Graceful degradation of verify | ✅ |

---

## Scenario Count Summary

| Category | Count | Description |
|----------|-------|-------------|
| A: Learning & Exploration | 10 | code-explore scenarios |
| B: Greenfield | 10 | init + add + pipeline |
| C: Adopt | 7 | Existing code documentation |
| D: Rebuild | 5 | Full rewrite |
| E: Pipeline Iteration | 10 | Revision, rollback, augmentation |
| F: Multi-Feature | 5 | Cross-Feature coordination |
| G: Coverage & Status | 4 | Monitoring |
| H: Special Modes | 7 | Advanced use cases |
| **Total** | **58** | |

### Coverage by Status

| Status | Count | Percentage |
|--------|-------|-----------|
| ✅ Fully supported | 58 | 100% |
| 🟡 Partial | 0 | 0% |
| ❌ Not yet supported | 0 | 0% |

---

## Usage in Reviews

This catalog is referenced during full-file reviews (CLAUDE.md § Review Protocol, Check 13).
For each change, verify that no scenario is broken by the modification:

1. Identify which scenarios touch the modified file
2. Trace the flow to confirm it still works
3. If a scenario would break, either fix the change or update the scenario status

## Changelog

| Date | Change |
|------|--------|
| 2026-03-22 | Initial creation — 57 scenarios across 8 categories |
| 2026-03-22 | Resolve 5 partial scenarios (SA05, SC06, SE07, SE08, SH07) → 57/57 fully supported |
