# spec-kit-skills Design Decision History

> Extracted from git history (201 commits, 2026-02-28 ~ 2026-03-08).
> Records key architectural and design decisions that shaped the project.

---

## [2026-03-21] SJ-Series: Spring/Java Enterprise Support + C/C++ Build System Stubs

### What Changed

**SJ-004+SJ-012: Spring Cloud Microservices Detection**
- Added Spring Cloud-specific code patterns (Eureka, Feign, Gateway, Config Server, Resilience4j) to shared microservice archetype

**SJ-006: Java SPI Plugin Mechanism**
- Added ServiceLoader, META-INF/services, spring.factories detection to shared plugin-system concern

**SJ-008: CQRS/Event Sourcing Concern (NEW)**
- Created shared concern module with S0/R1 detection signals (Axon Framework, EventStoreDB, generic patterns)
- Created reverse-spec concern module with R3 Feature boundary rules (Aggregate = Feature) and R4 data flow extraction (Command → Event → Projection)

**C/C++ Build System Foundation Stubs**
- Created cmake.md Foundation stub (CMakeLists.txt detection, target-based modules, preprocessor conditionals, Conan/vcpkg)
- Created makefile.md Foundation stub (plain Make, Autotools, Meson, Bazel detection with per-system toolchain commands)

### Why
- Spring Cloud is the dominant Java microservice framework; inter-service calls via @FeignClient were invisible to dependency mapping
- Java's ServiceLoader SPI is the native plugin mechanism, completely different from Node.js dynamic imports
- CQRS/Event Sourcing requires different Feature boundary strategy (Aggregate-based, not package-based)
- C/C++ projects use diverse build systems; Foundation stubs enable framework detection and correct toolchain commands

---

## [2026-03-21] N-Series Gap Fixes Part 2: Multi-Ecosystem + Patterns + Adoption Report

### What Changed

**N4: Python Package Manager Detection**
- Expanded adopt.md dependency install table from 7 entries to 15, covering all Python package managers (Poetry, uv, PDM, Pipenv), Bun, Ruby, and Java (Maven)
- Added multi-ecosystem project handling: install all detected ecosystems in order (backend first, frontend second)
- Added same multi-ecosystem detection cross-reference to analyze-runtime.md Phase 1.5-3

**N10: Multi-Language Build Orchestration**
- Added "Multi-Language Build Orchestration" section to adopt.md with build dependency ordering, parallel/sequential execution, per-ecosystem result recording, and partial build success handling
- Added multi-ecosystem build check note to pipeline.md Foundation Verification Gate

**N8: Repeating-Pattern Feature Decomposition**
- Added "Repeating-Pattern Feature Strategy" to analyze-classify.md — template Feature + framework Feature + variant instances pattern for N >= 5 similar modules, preventing Feature explosion while maintaining traceability

**N11: Container-as-Product SBI Classification**
- Added "Infrastructure-as-Product SBI Rule" to analyze-deep.md — when the project IS infrastructure management, lifecycle methods are P1 (not P3)

**N12: Instrumentation/Wrapper SDK Pattern**
- Added "Instrumentation/Wrapper Variant" section to shared sdk-framework.md — detection signals, SBI extraction rules, and Feature decomposition guidance for telemetry/observability wrapper SDKs

**N9: Micro Scale in Resolver**
- Added "Micro-project adjustment" block to _resolver.md Step 4 — forces prototype maturity, simplifies pipeline (optional constitution, minimal registries, single-Feature default), reduces specify/plan/verify depth

**N4 continuation: Browser Extension note**
- Added browser extension detection and runtime exploration guidance to analyze-runtime.md

**PART 2: Adoption Analysis Report**
- Added "Post-Pipeline: Adoption Analysis Report" section to adopt.md — generates `specs/_global/adoption-report.md` using shared completion-report.md template, with SBI coverage comparison against prior reverse-spec if available

### Why
- Python ecosystem has 5+ package managers; the old table only covered pip, missing Poetry/uv/PDM/Pipenv entirely
- Multi-language projects (Python + Node, Rust + Node) need coordinated dependency install and build orchestration
- SDK/instrumentation projects with 100+ provider modules need a decomposition strategy to avoid pipeline explosion
- Infrastructure-as-product projects had core lifecycle methods misclassified as P3 infrastructure
- Micro projects (<50 files) needed resolver-level pipeline simplification beyond just the scale tier
- Adoption pipeline lacked a structured analysis report, unlike reverse-spec which got completion-report in the prior batch

### Files
- `.claude/skills/smart-sdd/commands/adopt.md` (N4 + N10 + Adoption Report)
- `.claude/skills/smart-sdd/commands/pipeline.md` (N10 multi-ecosystem build check)
- `.claude/skills/reverse-spec/commands/analyze-classify.md` (N8 repeating-pattern)
- `.claude/skills/reverse-spec/commands/analyze-deep.md` (N11 infrastructure-as-product)
- `.claude/skills/shared/domains/archetypes/sdk-framework.md` (N12 instrumentation variant)
- `.claude/skills/smart-sdd/domains/_resolver.md` (N9 micro scale)
- `.claude/skills/reverse-spec/commands/analyze-runtime.md` (N4 multi-ecosystem + browser extension)

---

## [2026-03-21] N-Series Gap Fixes + Completion Analysis Report

### What Changed

**N1+N2+N3: Monorepo Detection for Python/Rust/Go**
- Added Python monorepo signals (pyproject.toml workspaces, uv, poetry, hatch, Pants/Bazel), Rust workspace signals (Cargo.toml [workspace]), and Go workspace signals (go.work, multiple go.mod) to `_foundation-core.md` F0 monorepo detection
- Updated `state-schema.md` Structure detection (step 6b) to include Python/Rust/Go workspace signals alongside existing JS signals

**N9: Micro Scale Tier**
- Added Micro tier (<50 files, <5 modules, <50 SBI) to the scale classification table in `analyze-scan.md`
- Added Micro-scale adaptations: simplified pipeline, single-Feature default, minimal artifact ceremony

**N5/N6/N7/N13: New Foundation and Concern Stubs**
- Created `chrome-extension.md` — Foundation stub for Manifest V3 Chrome extensions (F0 detection, architecture notes, runtime exploration guidance)
- Created `rust-cargo.md` — Foundation stub for standalone Rust/Cargo projects (F0 detection, crate-based architecture notes)
- Created `svelte.md` — Foundation stub for Svelte/SvelteKit projects (F0 detection, reactivity model notes)
- Created `hardware-io.md` — Concern stub for hardware I/O projects (S0 detection signals, SBI priority mapping)
- Added `.svelte` to Extension-to-Language Mapping table in `analyze-scan.md`
- Added Chrome Extension, Rust (Cargo), Svelte to F0 detection signals table and F4 FW codes in `_foundation-core.md`
- Added all 3 new Foundation stubs to F6 Framework Files table

**Completion Analysis Report (PART 2)**
- Created `shared/reference/completion-report.md` — shared template with 7 sections (Project Profile, Feature Catalog, SBI Summary, Entity & API, Quality Assessment, Recommendations, Artifact Inventory) usable by both reverse-spec and smart-sdd adopt
- Added Phase 4-5 "Completion Analysis Report Generation" step to `analyze-generate.md` — reads shared template, populates from Phase artifacts, writes to `specs/_global/completion-report.md`, displays key metrics summary
- Renumbered Phase 4-5 (Completion Checkpoint) to Phase 4-6

### Why
- Python/Rust/Go ecosystems have mature monorepo/workspace tooling that was undetected, causing misclassification as single-package
- Projects with <50 files were classified as "Small" but their pipeline overhead was disproportionate — Micro tier enables simplified processing
- Chrome extensions, standalone Rust, Svelte, and hardware I/O projects had no Foundation/Concern detection, falling through to generic handling
- reverse-spec Phase 4 produced individual artifacts but no aggregated analysis report, making it hard to assess extraction quality or decide next steps

### Files
- `.claude/skills/reverse-spec/domains/foundations/_foundation-core.md` (F0, F4, F6 updates)
- `.claude/skills/reverse-spec/commands/analyze-scan.md` (Micro tier, .svelte extension)
- `.claude/skills/reverse-spec/commands/analyze-generate.md` (Phase 4-5 Completion Report)
- `.claude/skills/smart-sdd/reference/state-schema.md` (monorepo detection)
- `.claude/skills/reverse-spec/domains/foundations/chrome-extension.md` (new)
- `.claude/skills/reverse-spec/domains/foundations/rust-cargo.md` (new)
- `.claude/skills/reverse-spec/domains/foundations/svelte.md` (new)
- `.claude/skills/shared/domains/concerns/hardware-io.md` (new)
- `.claude/skills/shared/reference/completion-report.md` (new)

---

## [2026-03-21] G1: --from-explore Implementation

### What Changed
- Added "Explore Step 1a: Synthesis Parsing Protocol" (BLOCKING gate) to `init.md` — verifies synthesis.md exists, parses 6 section types by heading detection (Domain Profile, Feature Candidates, Entity/API Maps, Insights, Handoff Readiness), warns on missing orientation.md, surfaces incomplete handoff criteria as Open Questions
- Added "Type 4 Step 1a: Synthesis Parsing Protocol" (BLOCKING gate) to `add.md` — verifies synthesis.md and Feature Candidates table exist, parses Entity/API Consolidation for Perspective 3/4 seeding, maps Accumulated Insights icons to elaboration perspectives, reads referenced trace files for per-candidate context
- Added `--from-explore <path>` argument to reverse-spec `SKILL.md` argument list and frontmatter hint
- Added "Explore-Enhanced Mode" section to `analyze.md` — Pre-Phase reads explore artifacts as supplementary context, per-phase enrichment table (Scan/Deep/Classify/Generate), advisory-not-authoritative principle (code analysis wins on contradiction)

### Why
- The `--from-explore` flag was accepted by init, add, and reverse-spec but had no concrete parsing protocol. Agents would accept the flag then ignore synthesis.md content, generating Proposals/Briefs from scratch. BLOCKING gates now enforce that synthesis.md must exist and be parsed, with anti-pattern examples preventing both "ignore" and "verbatim copy" failure modes.

### Files
- `.claude/skills/smart-sdd/commands/init.md`
- `.claude/skills/smart-sdd/commands/add.md`
- `.claude/skills/reverse-spec/SKILL.md`
- `.claude/skills/reverse-spec/commands/analyze.md`

---

## [2026-03-21] G6: add Type 1/Type 3 Parsing Protocols

### What Changed
- Added "Type 1 Step 1a: Document Parsing Protocol" to `add.md` — format detection (Markdown/plain text/PDF/other), heading-based Feature boundary extraction, candidate ID assignment (C###), fewer-than-2 Features AskUserQuestion with HARD STOP re-ask, entity/API hint propagation to Perspective 3/4
- Added "Type 3 Step 3a: Gap Clustering Algorithm" to `add.md` — 6-step heuristic: source file proximity grouping (depth ≤ 2), entity co-reference merging, naming pattern merging, minimum cluster size (3), cluster naming by dominant entity/directory, cross-cutting detection (3+ cluster appearances)

### Why
- Type 1 (Document-based) had no format detection or structured parsing — agents would read the PRD but extract candidates inconsistently. Type 3 (Gap-driven) described clustering informally ("by domain/function") with no reproducible algorithm. Both needed concrete, step-by-step protocols for consistent agent behavior.

### Files
- `.claude/skills/smart-sdd/commands/add.md`

---

## [2026-03-21] G3: Multi-Language Project Support

### What Changed
- Added Phase 1-2a "Language Composition Analysis" to `analyze-scan.md` — scans source files by extension, classifies languages as Primary (≥50%), Secondary (≥5%), Tertiary (<5%), and assigns per-language SBI extraction depth
- Added "Multi-Language SBI Extraction" to `analyze-deep.md` — language-specific scan patterns table (Python, JS/TS, C/C++, CUDA, Go, Rust, Java/Kotlin), cross-language call graph elevation (P2→P1 for FFI integration points), unified SBI table with Language column
- Added "Multi-Language Foundation" paragraph to `_core.md` § R7 — R3 extraction targets loaded per qualifying language, Foundation field stores comma-separated values
- Updated Foundation row in `_schema.md` Module Types table — clarified that Framework field supports comma-separated values for multi-language projects

### Why
- Projects like vLLM (Python 92% + CUDA 7% + C++ 4%) have multiple languages but the Foundation axis only detected a single language. SBI extraction had no language-specific strategy, causing secondary-language behaviors (e.g., CUDA kernels) to be missed or incorrectly parsed.

### Files
- `.claude/skills/reverse-spec/commands/analyze-scan.md`
- `.claude/skills/reverse-spec/commands/analyze-deep.md`
- `.claude/skills/reverse-spec/domains/_core.md`
- `.claude/skills/smart-sdd/domains/_schema.md`

---

## [2026-03-21] G4: Large-Scale Project Handling

### What Changed
- Added Phase 1-4a "Scale Detection + Adaptive Processing" to `analyze-scan.md` — 3-tier scale classification (Small/Medium/Large) based on file count, module count, and estimated SBI entries. Large-scale adaptations: hierarchical module grouping (max 8–12 domain groups), domain-prefixed SBI numbering (B-INF-001), batched Phase 2 processing, Source Reference prioritization (Tier A/B/C), P3 summary mode
- Added "Large-Scale SBI Processing" to `analyze-deep.md` — domain-prefixed IDs, per-domain-group processing, P3 summary mode, cross-domain integration point detection
- Added 3 large-project heuristic rows to `context-injection-rules.md` Size Heuristics table — Source Reference >30 files per Feature, SBI >500 entries, Modules >60

### Why
- Projects with 78+ modules, 500+ SBI entries, and 31K files overwhelm flat processing. No scale thresholds existed, no hierarchical grouping, and no Source Reference prioritization caused context overflow during deep analysis.

### Files
- `.claude/skills/reverse-spec/commands/analyze-scan.md`
- `.claude/skills/reverse-spec/commands/analyze-deep.md`
- `.claude/skills/smart-sdd/reference/context-injection-rules.md`

---

## [2026-03-21] G5: adopt Phase 1.5 Conditional Skip for GUI Projects

### What Changed
- Replaced unconditional "Skip entirely" adopt mode rule in `analyze-runtime.md` with conditional logic based on Interface axis
- If Interface axis includes `gui`: present HARD STOP AskUserQuestion letting user choose to run or skip Phase 1.5
- If Interface axis does NOT include `gui`: skip entirely (unchanged behavior)
- Added anti-pattern examples (WRONG: always skip / RIGHT: GUI gets optional HARD STOP)
- Updated Phase routing table in `analyze.md` with clarifying note about adopt mode behavior
- Updated section title from "Optional for adopt" to "Conditional for adopt"

### Why
- GUI projects in adopt mode were losing all UI structure information because Phase 1.5 was unconditionally skipped. GUI-heavy projects benefit from runtime exploration even in adoption mode to capture UI control types, interaction patterns, and visual layout that code analysis alone cannot reveal.

### Files
- `.claude/skills/reverse-spec/commands/analyze-runtime.md`
- `.claude/skills/reverse-spec/commands/analyze.md`

---

## [2026-03-21] G2: adopt-specify SBI Parsing Protocol

### What Changed
- Added "SBI Parsing Protocol" section (~45 lines) to `adopt-specify.md` between "Source File Reading" and "Injected Content"
- 4 concrete steps: Read SBI Table → Build Source Behavior Map → Generate FR with [source: B###] Tags → Coverage Validation
- Two 🚫 BLOCKING gates: missing SBI table blocks execution; unmapped P1/P2 entries block Review approval
- Anti-pattern examples (3 WRONG + 1 RIGHT) for agent behavior enforcement

### Why
- `adopt-specify.md` declared that B### SBI entries must map to FR-### with `[source: B###]` tags, but had NO concrete execution steps for HOW to read/parse the SBI table, iterate entries, and validate coverage. Agents would skip the parsing and produce generic FRs without source traceability.

### Files
- `.claude/skills/smart-sdd/reference/injection/adopt-specify.md`

---

## [2026-03-21] G8: Archetype multi-detection + G9: SC template expansion

### What Changed
- **G8 (Archetype Multi-Detection)**: Added multi-archetype support (comma-separated, merge-by-append) across 3 files:
  - `_schema.md` § Archetype Section Schema: clarification paragraph on multi-archetype merge semantics with `_resolver.md` cross-reference
  - `init.md` § Proposal Step 3: explicit multi-match instruction with example (`ai-assistant,sdk-framework`)
  - `synthesis.md` § Step 5: note that Archetype axis can be comma-separated
- **G9 (SC Template Expansion)**: Added "Additional SC Pattern Categories (activated by Scale modifier)" subsection to `_core.md` § S1 with 4 universal SC pattern categories (Performance, Resource, Build, Reliability), Scale guard rules, and anti-patterns

### Why
- G8: Archetype was implicitly single-value despite `_resolver.md` Step 2c supporting multi-archetype. Without explicit documentation, agents defaulted to picking one archetype even when multiple matched.
- G9: SC generation lacked non-functional pattern templates. Production-grade projects need measurable Performance/Resource/Build/Reliability SCs, but without templates agents produced vague criteria like "system is fast".

### Files
- `.claude/skills/smart-sdd/domains/_schema.md`
- `.claude/skills/smart-sdd/commands/init.md`
- `.claude/skills/code-explore/commands/synthesis.md`
- `.claude/skills/smart-sdd/domains/_core.md`

---

## [2026-03-20] Lean Scale & Cross-Concern sections in injection files

### What Changed
- Replaced duplicated procedural steps (read sdd-state.md, display in Checkpoint) in `injection/specify.md`, `injection/plan.md`, `injection/implement.md` with a single reference to `context-injection-rules.md` § Scale Modifier Enforcement + § Cross-Concern Integration Enforcement
- Kept only command-specific adjustment values and anti-patterns in each file
- Added `(🚫 BLOCKING)` gate marker to all 4 section headers
- Standardized `injection/verify.md`: promoted inline blockquote to proper `## Scale & Cross-Concern Adjustments (🚫 BLOCKING)` section header with the same lean structure as the other 3 files, plus its own anti-pattern example

### Why
All 4 injection files duplicated the procedural framework from `context-injection-rules.md` (Steps 1 and 4: read sdd-state.md, display in Checkpoint). This caused ~1,200 extra tokens of double-loading per command. The lean pattern keeps only what is unique to each command (the specific Scale thresholds and Cross-Concern examples) and delegates the shared procedure to the single source of truth. Aligns with P2 (Enforce, Don't Reference) by adding BLOCKING gates, and Single Source of Truth principle by removing duplication.

### Files
- `.claude/skills/smart-sdd/reference/injection/specify.md`
- `.claude/skills/smart-sdd/reference/injection/plan.md`
- `.claude/skills/smart-sdd/reference/injection/implement.md`
- `.claude/skills/smart-sdd/reference/injection/verify.md`

---

## [2026-03-20] Post-pull audit: Artifact Structure sync + File Map completeness

### What Changed
- README Artifact Structure section updated from stale `specs/reverse-spec/` to `specs/_global/` + per-Feature flat structure (matching Project Directory Structure section and actual directory restructure commit `2541bc8`)
- Added `spec-draft-template.md` to README File Map (both EN/KO) — template existed and was referenced from `analyze-generate.md` but missing from documentation
- Added `runtime/_index.md` to English README File Map (Korean already had it) — sync issue

### Why
Directory restructure (`specs/reverse-spec/` → `specs/_global/`) was reflected in the Project Directory Structure section (line 172) but not in the Artifact Structure section (line 1290). File Map entries were missing for 2 files added in recent commits. All are documentation consistency issues — no functional impact.

---

## [2026-03-20] spec-draft.md — reverse-spec generates initial spec for each Feature

### Design Decision

**Problem**: speckit-specify compresses UI details. "Dropdown with auto-fill" → "select model", "7-stage pipeline" → "process files". Two-step conversion (source → pre-context → spec.md) loses information at each step.

**Solution**: reverse-spec Phase 4 generates `spec-draft.md` per Feature — detailed FR/SC with explicit UI controls, error paths, data pipelines. speckit-specify refines this draft instead of generating from scratch.

**Name alignment**: "reverse-spec" now literally means "reverse-engineer the spec" — from source code to spec.md draft.

### Files

| File | Change |
|------|--------|
| `reverse-spec/templates/spec-draft-template.md` | NEW — template with FR groups, SC categories, conversion traceability |
| `reverse-spec/commands/analyze.md` | Phase 4: spec-draft generation logic with 5 conversion rules + completeness check |
| `smart-sdd/injection/specify.md` | Spec-Draft Seeding Protocol — refine instead of generate, UI control downgrade detection |
| `context-injection-rules.md` | Graceful degradation for absent spec-draft.md |

---

## [2026-03-20] Rebuild Fidelity — Runtime Exploration BLOCKING + UI Flow Spec + Artifact Separation

### Context

angdu-studio rebuild repeatedly failed on complex UI (51 SKF items). Root cause: reverse-spec analyzed code statically but never ran the source app. Agent guessed UI control types, interaction patterns, and data flows during implement — always producing simplified versions.

### Fixes

| Change | File |
|--------|------|
| Phase 1.5 → BLOCKING for rebuild | reverse-spec/analyze.md |
| Phase D Interactive Flow Execution (CRUD/config/pipeline flows) | reverse-spec/analyze.md |
| UI Flow Spec section in pre-context template | reverse-spec/templates/pre-context-template.md |
| Artifact Separation Principle (P1-b) | CLAUDE.md |
| specify reads UI Flow Spec as primary FR/SC source | smart-sdd/injection/specify.md |
| Graceful degradation for missing UI Flow Spec | context-injection-rules.md |

### Design Decision: Artifact Separation

Source analysis → reverse-spec artifacts only. smart-sdd artifacts (spec/plan/tasks) contain NO source code references. If smart-sdd discovers new source insights, it updates reverse-spec artifacts (pre-context.md).

---

## [2026-03-20] Post-pull Audit — 6 Issues Fixed (verify gate headings, ipc.md schema, README scripts)

Post-pull analysis of 30-commit update (36 files, +4559/-2073 lines). Found and fixed 6 issues:

| # | Issue | Severity | Fix |
|---|-------|----------|-----|
| 1 | README file tables missing `semantic-stub-check.sh` and `wiring-check.sh` | HIGH | Added to both README.md and README.ko.md |
| 2 | `ipc.md` IPC N-Layer was under S7 but `_schema.md` referenced it as S4 extension | MEDIUM | Added proper S4 section in ipc.md, S7 now cross-references S4 |
| 3 | `ipc.md` missing S3 (Verify Steps) — IPC channel verification steps needed | MEDIUM | Added S3 with 3 steps: channel-audit, n-layer-check, payload-shape |
| 4 | `ipc.md` missing S9 (Brief Completion Criteria) | LOW | Added S9 with IPC boundary, channel inventory, error handling criteria |
| 5 | verify-phases.md PHASE FILE READING GATE example headings didn't match actual file headings | LOW | Updated all 4 Phase heading examples to match actual first headings |
| 6 | README `Last updated` timestamps stale | LOW | Updated to 2026-03-20 06:20 KST |

Key finding: The 30-commit update itself (verify refactor, SKF-053 structural gates, agent behavioral rules, Korean→English translation, S4 Data Integrity, runtime-verification.md, ui-flow-spec.md, scripts) was well-executed overall. Issues were limited to propagation gaps (README tables, schema-implementation alignment).

---

## [2026-03-19] SKF-046~047 — Cosmetic Test Detection + Cross-Feature Wiring Runtime

| SKF | Fix | File |
|-----|-----|------|
| 046 | Cosmetic Test Detection Rule (BLOCKING): Tests checking only navigation/existence rejected. Min: 1 user action + 1 state change assertion per SC. | verify-evidence-update.md |
| 047 | Cross-Feature Wiring Runtime Confirmation: After static check, launch app and confirm element visible. | implement.md |

---

## [2026-03-19] SKF-053~056 — Structural Verification Gates + Semantic Stub Detection + Functional Smoke Test

### Context

SKF-053 identified 7 structural causes of shallow verification. SKF-054 found Integration Contract stubs pass static gates. SKF-055 found Foundation pattern enforcement gap. SKF-056 found 7 runtime bugs all passing build+tsc.

### Fixes

| SKF | Fix | File |
|-----|-----|------|
| 053-1 | Phase File Reading Gate: structural proof (quote first heading) | verify-phases.md |
| 053-2 | SC Matrix Gate: count-based structural check (SC count, category distribution, depth column) | verify-sc-verification.md |
| 053-3 | Verify Depth Structural Check: behavioral_count == 0 → BLOCKING | pipeline.md Gate #4 |
| 053-6 | Evidence-Based Completeness Gate: git diff cross-check for cross-feature tasks | pipeline.md Gate #5 |
| 054 | Integration Contract argument-level verification: trace apiKey/baseURL source | implement.md |
| 055 | Foundation Pattern Constraint Enforcement: platform bridge layer check | implement.md |
| 056 | Functional Smoke Test Gate V5: Integration + Library + Platform API tests | pipeline.md |

### Lessons Added

- L41: Semantic Stubs Pass All Static Gates — Only Argument Tracing Catches Them
- L42: Build ✅ + TypeScript ✅ ≠ Feature Works — The Runtime Gap Is Systematic

---

## [2026-03-19] SKF-053 — 7 Structural Causes of Shallow Verification (initial analysis)

### Fixes

| Cause | Fix | File |
|-------|-----|------|
| 1. Phase files not read | Phase File Reading Gate (BLOCKING) — `📖 Reading [file]...` required | verify-phases.md |
| 2. SC Matrix not created | SC Matrix Gate (BLOCKING) — Step 3 blocked without Matrix | verify-sc-verification.md |
| 3. Pipeline Completion Bias | Verify Depth Structural Check — 0 behavioral = BLOCKING | pipeline.md Gate V1 |
| 5. Smoke Launch = process check | Smoke Launch Minimum Bar — GUI content required | pipeline.md Gate V2 |
| 6. Completeness Gate self-report | Evidence-Based Task Verification — git diff cross-check | pipeline.md Gate V3 |
| 7. Checklist no evidence | Evidence Column mandatory | pipeline.md Gate V4 |

All gates are **structural** (count/file/diff-based), not trust-based (agent self-report).

---

## [2026-03-19] SKF-076 — Rebuild UX Equivalence + UI Screen Inventory + Source-First UI

### Context

Rebuild produced "functionally correct but visually unrecognizable" results — 857-line source components became 200-line simplified versions. Root cause: rebuild defined as "functional equivalence" not "UX equivalence", and no UI structure extraction procedure.

### Fixes

| Fix | File |
|-----|------|
| Rebuild definition: "UX equivalence, not just functional equivalence" | SKILL.md |
| UI Screen Inventory: screen-by-screen layout documentation in reverse-spec | analyze.md |
| Source→Target UI Pattern Summary column (BLOCKING for 300+ line components) | plan.md |
| Source-First UI Structure Extraction: checklist before coding (BLOCKING) | implement.md |

---

## [2026-03-19] Rule Extensibility Audit — Generalize React/Electron-specific rules to universal principles

### Context

Audit revealed 11 OVER-SPECIFIC rules hardcoded to React/Electron/Cherry Studio. Rules were extracted from real failures (valuable) but not abstracted to universal principles (problematic). A Django or Go project reading these rules would see React-specific instructions that don't apply.

### Fix Strategy

Separate **principle** (universal) from **implementation** (framework-specific):
- Principle in injection files: "stored data immutable, display-time transform only"
- Implementation examples: "React: useMemo, Vue: computed, Django: template filter"

### Changes

| File | Rules Generalized |
|------|------------------|
| implement.md | Content Immutability (useMemo→universal), Message Passing Layer (IPC→all architectures), Control Capability Audit (HTML→all interfaces) |
| verify-phases.md | Inline Fix Re-check (useStore/useEffect→universal state/effect patterns) |
| plan.md | Cross-Feature Integration rows (React component→all interfaces with per-interface examples) |
| CLAUDE.md | Added Review Protocol #12: Rule Extensibility Check |

---

## [2026-03-19] SKF-075 — Integration Architecture Extraction + Method Specificity + Architecture Pattern

### Context

Memory Feature (F006) implemented as "system message injection" when source app (Cherry Studio) uses "AI Tool via Plugin hook" — fundamentally different architecture producing different UX. Root cause: SBI extracts service files only, misses integration/orchestration layer.

### Fixes (3 new rules)

| Fix | File |
|-----|------|
| Integration Architecture Extraction — SBI `-INT` entries for plugin/hook/tool patterns | reverse-spec analyze.md |
| Integration Method Specificity (🚫 BLOCKING) — FR verbs must match source integration pattern | specify.md |
| Architecture column in Integration Contract (🚫 BLOCKING) — AI Tool vs Injection vs Plugin | plan.md |

---

## [2026-03-19] SKF-073~074 — AI Reference Pipeline + Source Parity + Cross-Feature Rendering + UX Flow

### Context

7 sequential citation UI failures (SKF-073) revealed "AI-generated text with dynamic references" as an uncovered category. SKF-074 identified 3 structural root causes: SBI stops at function signatures, implement reads Feature-local files only, rebuild SCs verify existence not quality.

### Fixes (7 new rules across 6 files)

| Fix | File |
|-----|------|
| AI-Generated Reference Pipeline (🚫 BLOCKING) — 8-stage pipeline for RAG/citation | plan.md |
| Message Block Immutability — no updateBlock on completed blocks; Portal for overlays | implement.md |
| Inline Fix Pattern Constraint Re-check — 4-item check before verify inline fix | verify-phases.md |
| Source Parity Clause (🚫 BLOCKING) — rebuild SCs must reference source pattern | specify.md |
| Cross-Feature Rendering Path (🚫 BLOCKING) — read consuming Feature's rendering files | implement.md |
| Source Behavior Depth Check (🚫 BLOCKING) — source 8 stages vs plan 3 = 5 missing = block | plan.md |
| SBI UX Flow Extension — trace function output to rendered UI + interaction | analyze.md |

---

## [2026-03-19] SKF-070~072 — Source Analysis + Tech Verification + Data Mapping + Agent Rules

### Fixes

| SKF | Fix | File |
|-----|-----|------|
| 070-1 | Tech Compatibility Pre-Research: Library Import Smoke Test 🚫 BLOCKING | plan.md |
| 070-2 | Agent Behavioral Rules: 4 rules (pipeline bias, automate don't delegate, investigate don't report, fix→verify→report) | pipeline.md |
| 071 | Data Mapping Pattern Audit 🚫 BLOCKING: source data-attr → target array index = instability | implement.md |
| 072-1 | Interaction Data Flow SC Check 🚫 BLOCKING: clickable references need mapping accuracy SC | specify.md |
| 072-2 | Inline reference/citation Interaction Chain rows with explicit ID lookup method | plan.md |

---

## [2026-03-19] Bug Fix Severity — Spec Coverage Pre-check Gate

### Context

F006 KB citation: verify가 "번호 불안정, tooltip 미동작"을 Major-Implement로 분류 → implement 돌려보냄 → spec에 SC 없어서 즉흥 구현 → 같은 루프 반복. SDD 원칙 위반: spec이 완료 기준을 정의하지 않으면 implement가 뭘 구현해야 하는지 모름.

### Fix

Bug Fix Severity Rule에 **Step A: Spec Coverage Pre-check** 추가. severity 분류 전에 "SC가 있나?" 먼저 체크. SC 없으면 파일 수 무관하게 Major-Spec.

---

## [2026-03-19] Verify Fix Degradation Loop Prevention

### Context

F006 citation UI implementation entered a fix → re-fix → re-re-fix loop during verify, ending with user declaring "start from scratch." Root cause: verify-time code modifications don't inherit implement's Source-First rules. Agent patches symptoms without reading the source app's working implementation.

### Changes

| File | Change |
|------|--------|
| `verify-phases.md` § Source Modification Gate step 7 | Added "Source Reference for Verify Fixes" (rebuild BLOCKING): before any verify fix, read the corresponding source app file. Anti-pattern example included. |
| `verify-phases.md` § Minor Fix Accumulator | Added "SC Re-Fix Loop Detection": same SC fails Post-Fix verification 2 times → auto-escalate to Major-Implement. Prevents patch-on-patch degradation. |

---

## [2026-03-19] Verify WHAT/HOW Separation + Context Budget Split + Implement Library Validation

### Context

verify-sc-verification.md (1030 lines) was too large — agents couldn't keep it in context. Additionally, Playwright-specific HOW content was mixed with verification logic WHAT, making it impossible for non-GUI projects to use the file efficiently.

### Architecture Change: WHAT/HOW Separation

| Before | After | Lines |
|--------|-------|-------|
| verify-sc-verification.md (monolith) | verify-sc-verification.md (WHAT: SC Matrix, orchestration, gates) | 1030 → 639 |
| (embedded in above) | verify-sc-rebuild.md (rebuild-only: Visual Fidelity, Source Comparison) | NEW: 114 |
| runtime-verification.md (partial HOW) | runtime-verification.md (complete HOW: § 8 GUI detail, § 9 Failure Recovery) | 387 → 577 |

### Other Changes

| File | Change |
|------|--------|
| pipeline.md | Added Verify Critical Gates inline (3 rules always in context) |
| implement.md | Added Step 1b New Library Validation (import probe after new dependency) |

### Design Decision: Why inline pipeline.md gates

Even after splitting verify into 6 files, the agent might not read the right phase file at the right time. Three most-violated rules are now in pipeline.md (always loaded): no code-review-only SC pass, source reference for rebuild fixes, SC re-fix loop detection.

---

## [2026-03-19] SKF-070 — Extensible Data Integrity Framework (S4) + Source Deep Analysis

### Context

SKF-070 documented 18 failures in F006 Knowledge-Memory pipeline. Instead of adding Electron-specific fixes, designed an extensible architecture: Universal rules (_core.md S4) for ALL projects, concern-specific rules (ipc.md) for IPC projects, scenario-specific rules (rebuild.md) for rebuild projects.

### Changes

| Layer | File | Rules Added |
|-------|------|-------------|
| Universal | `_core.md` § S4a-c | Data Authority, Empty Input, Pipeline Traceability |
| Concern | `ipc.md` § S7 | IPC N-Layer Completeness + Channel Audit |
| Scenario | `rebuild.md` § S4d | Source Feature Deep Analysis (3-level: pipeline, UI, rendering) |
| specify | `specify.md` | Data Pipeline Completeness Check (BLOCKING) |
| plan | `plan.md` | Technology Compatibility Pre-Research |
| implement | `implement.md` | Data Authority + Edge Case Completeness (Wiring Check #6-7) |

---

## [2026-03-19] Post-Pull Consistency Audit — 5-Axis Model Sync + llm-agents Module Completeness

| Change | File | Rationale |
|--------|------|-----------|
| **Domain Module System → 5-axis + modifier** | `README.md` L583-615 | Section still described old 4-axis model ("four questions"). Updated to 5-axis + 1 modifier with Foundation (Axis 4), Scale (Modifier), Cross-Concern Integration Rules |
| **Concern tree: add llm-agents** | `README.md` L586-602 | New concern added to _taxonomy.md and skill files but missing from README concern tree |
| **Domain Profile definition updated** | `README.md` L611 | Old "= Interface + Concern + Archetype + Scenario" → includes Foundation + Scale |
| **Same changes in Korean** | `README.ko.md` | Mirror all structural updates |
| **llm-agents in File Map** | `README.md`, `README.ko.md` | Added to all 3 sections: reverse-spec, smart-sdd, shared |
| **reverse-spec llm-agents module** | `reverse-spec/domains/concerns/llm-agents.md` | Created — was missing from reverse-spec (shared + smart-sdd had it). Follows authorization.md pattern with R1 cross-ref to shared/ |

---

## [2026-03-18] SKF-065~069 — Verification Evidence + Wiring Check + API Dependency Enforcement

### Context

5 new SKF items (065-069) identified a critical 3-stage verification evasion pattern: agents substitute code review for runtime verification, then surface UI checks, then only after user complaints perform actual data flow verification.

### Fixes

| SKF | Fix | File |
|-----|-----|------|
| 068 | **SC Verification Evidence Gate** (🚫 BLOCKING): Review cannot be approved without runtime evidence per SC. Level 1 (code review) alone cannot pass any SC. Anti-pattern examples added. | verify-phases.md |
| 069 | **App Lifecycle Wiring Check** (🚫 BLOCKING): 5-point checklist (store hydration, IPC 3-layer, UI entry point, parameter cross-check, external dependency config) blocks verify entry until wiring is confirmed. | implement.md |
| 066 | **External API Edge Cases** upgraded to BLOCKING: spec cannot be approved without FR/SC for API key missing, provider not activated, call failure. | specify.md |
| 065 | Already implemented: Test Environment Alignment in verify-phases.md Step 0 item 8. |  |
| 067 | Already implemented: Manual Verification Fallback Protocol in verify-phases.md Step 0 item 7. |  |

---

## [2026-03-18] Python/LLM/Data-Science Domain Support — Simulation-Driven Gap Analysis

### Context

Simulated code-explore → rebuild of `ai-data-science-team` (Python + LangChain + Streamlit + H2O). Discovered 6 structural gaps in the current framework for non-JS/TS project types.

### Changes

| Component | Change |
|-----------|--------|
| `concerns/llm-agents.md` | **NEW** — Full concern module for LLM agent projects: S0 (signal keywords), S1 (non-deterministic SC patterns), S3 (verify steps with structural/behavioral/threshold testing), S5 (8 probe categories), S7 (B-1/B-3/B-4 bug prevention: token budget, sandbox, infinite loop, prompt injection), S9 (Brief completion: provider, pattern, non-determinism strategy) |
| `shared/domains/concerns/llm-agents.md` | **NEW** — Signal keywords for init Proposal Mode detection |
| `shared/domains/_taxonomy.md` | Added `llm-agents` to concern registry |
| `domains/_resolver.md` | Added 4 Cross-Concern Integration Rules: llm-agents+gui, llm-agents+http-api, llm-agents+persistence, llm-agents+external-sdk |
| `domains/data-science.md` | Extended with LLM Agent Testing Patterns (§4), Streamlit Testing Patterns (§5), Python-Specific Implement Rules (§6). Cross-references llm-agents concern |

### Design Decision

`llm-agents` is a **concern** (not an archetype) because:
- Archetype = domain philosophy (ai-assistant: "streaming-first, model-agnostic")
- Concern = cross-cutting pattern (llm-agents: "non-deterministic output, sandbox execution, multi-agent coordination")
- A project can be archetype `ai-assistant` WITH concern `llm-agents` — they're orthogonal

---

## [2026-03-18] SKF-060~063: Semantic Stub Detection + Regression Protocol

### Context

SKF-060~063 revealed that build/type-passing code can contain completely non-functional implementations (Math.random() embeddings, keyword-only search, text inputs replacing dropdowns). Existing gates only caught syntactic stubs (return null, TODO).

### Fixes

| SKF | File | Fix |
|-----|------|-----|
| 060 | `injection/implement.md` | Semantic Stub Detection (BLOCKING): Math.random in business logic, external call bypass, comment-acknowledged placeholder, sort/filter substitution. Integration Contract Fulfillment Check: verify all "Consumes ←" entries have actual code calls |
| 061 | `verify-phases.md` | Semantic Correctness Sanity Check in SC Verification Matrix: deterministic embedding test, known-document search test, fact extraction test. BLOCKING when sanity fails |
| 062 | `pipeline.md` | Regression-Implement Protocol: when re-running from --start specify, implement MUST audit existing code (semantic stubs + integration contracts + UI control types) before applying delta. Scale modifier adjusts audit severity |
| 063 | `injection/implement.md` | UI Control Type Audit (BLOCKING for rebuild+GUI): Source Select → Target Input = UX downgrade = BLOCKING |

---

## [2026-03-18] Stop Hook — spec-kit Output Interception

### Context

Agents stop with spec-kit raw output ("Next Actions: Proceed to /speckit.implement") instead of continuing to the Review step. This is a MANDATORY RULE 3 violation — Execute+Review continuity is broken. The rule exists inline but agents still violate it.

### Solution

Claude Code Stop hook that detects spec-kit navigation patterns in `last_assistant_message` and forces continuation:

- **Hook script**: `.claude/hooks/stop-speckit-intercept.sh`
- **Settings**: `.claude/settings.json` registers the hook on Stop event
- **install.sh**: Updated to install hook in target projects (creates `.claude/settings.json` with hook config)
- **Mechanism**: If `last_assistant_message` matches spec-kit patterns AND no Review/AskUserQuestion is present → `{"decision": "block", "reason": "..."}` forces agent to continue to Review
- **Safety**: `stop_hook_active` check prevents infinite loops

### Design Note (P2 — Enforce, Don't Reference)

This is a concrete example of P2: the inline instruction "SUPPRESS spec-kit output" exists in 6+ locations, but agents still stop. The Stop hook is a **system-level enforcement** that operates below the instruction layer — the agent literally cannot stop when spec-kit output is the last thing shown.

---

## [2026-03-18] SKF Deep Verification — 5 Critical Enforcement Gaps Fixed

### Context

Re-verified all 55 SKF items. Found 5 items marked ✅ Reflected but with insufficient enforcement — rules existed but agents could bypass them.

### Fixes

| Gap | SKF Source | File | Fix |
|-----|-----------|------|-----|
| Agent Prompt Source Injection | SKF-053 | `injection/implement.md` | Added MANDATORY rule: background agent prompts MUST include source app code (not SBI summaries). Anti-pattern with ❌/✅ examples. |
| Verify mandatory read | SKF-051 | `pipeline.md` | Added 🚨 CRITICAL inline instruction: "verify-phases.md를 읽지 않고 build+TS만 수행하는 것은 verify가 아닙니다" |
| Verify Execution Checklist | SKF-046 | `pipeline.md` | Added 9-row checklist table — blank Required rows BLOCK Review approval |
| Entry Point BLOCKING gate | SKF-054 | `injection/specify.md` | Upgraded Reachability from ⚠️ warning to 🚫 BLOCKING. Each source entry point = separate FR required |
| Verify evidence format | SKF-049 | `injection/verify.md` | Added Execution Evidence Requirement: claims vs evidence distinction with concrete examples. BLOCKING. |

### Design Principle

**"Reflected" ≠ "Enforced"**. A rule that exists in documentation but has no BLOCKING gate is effectively optional for agents. Every critical rule must have:
1. Explicit inline instruction (not just file reference)
2. BLOCKING enforcement (not just ⚠️ warning)
3. Anti-pattern examples (❌ WRONG / ✅ RIGHT)

---

## [2026-03-18] Domain Profile Architecture: 4-axis → 5-axis + 1 modifier

### Context

MECE analysis revealed the original 4-axis model (Interface, Concern, Archetype, Scenario) was neither mutually exclusive (Archetype ↔ Concern overlap) nor collectively exhaustive (Foundation operating as de facto axis, Scale defined but unwired).

### Design Decision: 5 axes + 1 modifier

**5 Axes** (rule producers):
1. Interface — what the app exposes
2. Concern — cross-cutting patterns
3. Archetype — domain philosophy (clarified: extends Concern rules, not duplicates)
4. Foundation — framework-specific constraints (promoted from separate system to formal axis)
5. Scenario — project lifecycle context

**1 Modifier** (rule filter):
- Scale = project_maturity × team_context (adjusts enforcement depth, not rule content)

### Key Distinction
- **Axis**: produces rules ("check for IPC timeout handling")
- **Modifier**: adjusts depth ("in prototype mode, this SC is optional")
- **Archetype → Concern**: Archetype A2/A3 sections EXTEND Concern S1/S5, not duplicate

### Changes

| File | Change |
|------|--------|
| `_schema.md` | Rewrote Module Types with 5-axis + modifier model, Archetype↔Concern relationship |
| `_resolver.md` | Step 1 updated for 5-axis fields, Step 3 shows 5-axis loading, new Step 4 Scale modifier application |
| `context-injection-rules.md` | Domain Module Loading Protocol updated for 5+1 |
| `status.md` | Domain Profile display updated with Scale |
| `orient.md` | Step 3 updated for 5-axis + Scale detection |
| `synthesis.md` | Step 5 Target Domain Profile updated for 5-axis + Scale |
| `README.md/ko.md` | Domain Profile section rewritten with axis table + modifier explanation |

---

## [2026-03-18] Domain Profile First-Class Citizen Audit — 5 Gap Fixes

### Context

Full audit of Domain Profile as first-class citizen across all skills. Found that Domain Profile was deeply integrated in init/pipeline/reverse-spec but shallow or missing in status commands, trace guidance, injection resolver protocol, and constitution archetype extraction.

### Fixes

| # | Gap | Severity | Fix |
|---|-----|----------|-----|
| 1 | smart-sdd status omits Domain Profile | CRITICAL | Added Domain Profile section to both full/core scope output |
| 2 | code-explore trace has no Domain guidance | MAJOR | Added Domain-Guided Entry Point Discovery with module-specific search targets |
| 3 | code-explore status omits Domain Profile | MAJOR | Added Detected Domain Profile + per-axis exploration coverage |
| 4 | Injection files don't show how to load modules | MAJOR | Added Domain Module Loading Protocol to context-injection-rules.md as single source |
| 5 | Constitution doesn't explicitly extract Archetype A4 | MAJOR | Added explicit 5-step A4 extraction instructions to constitution.md |

### README Update

Expanded Domain Profile section in both READMEs to explain first-class citizen philosophy with per-skill bullet points showing how Domain Profile actively influences each step.

---

## [2026-03-18] Domain Profile Fusion — code-explore ↔ smart-sdd Full Integration

### Context

code-explore's Domain Profile analysis was disconnected from smart-sdd's Domain Profile system. orient detected tech stack and patterns, but there was no path to flow this into init → add → pipeline.

### Design Decision

Made Domain Profile a first-class citizen across the entire explore → init → add flow:

| Component | Change |
|-----------|--------|
| `orient.md` | Added Step 3 Domain Profile Analysis — detects source project's Interfaces, Concerns, Archetype, Foundation using same vocabulary as smart-sdd's `_resolver.md` |
| `synthesis.md` | Added Step 5 Target Domain Profile Derivation — combines source profile with user's differentiation decisions, checks Cross-Concern Integration Rules |
| `init.md` | Added Explore-Informed Mode (`--from-explore`) — reads synthesis Domain Profile, generates Proposal with explore-derived content, auto-chains to add |
| `SKILL.md` | Updated Relationship section with complete artifact flow table showing what each receiving skill reads and where it seeds |
| `synthesis.md` | Updated handoff readiness to include Domain Profile resolution status and primary flow recommendation |

### Key Insight

The `--from-explore` flag needed to exist on `init` (not just `add`) because init is where Domain Profile gets written to sdd-state.md. Without init support, the profile inference from code exploration was lost.

---

## [2026-03-18] code-explore Sample Artifacts + --from-explore Handoff

### Context

Created realistic sample code-explore artifacts simulating an opencode exploration, then implemented the `--from-explore` handoff protocol in smart-sdd add.

### Artifacts

- `samples/code-explore-opencode/specs/explore/orientation.md` — architecture map with Mermaid, module coverage
- `samples/code-explore-opencode/specs/explore/traces/001-context-assembly.md` — token window management flow
- `samples/code-explore-opencode/specs/explore/traces/002-priority-scoring.md` — priority scoring with LSP integration
- `samples/code-explore-opencode/specs/explore/traces/003-tool-execution.md` — tool dispatch and execution pipeline
- `samples/code-explore-opencode/specs/explore/synthesis.md` — Feature candidates (C001-C005), entity/API/rule consolidation

### Handoff Implementation

- `add.md`: Added Phase 1 Type 4 (Explore-Driven) — reads synthesis.md, converts C→F candidates, pre-populates elaboration context from entities/APIs/rules/observations. Phase 4 skip for explore-sourced Features.
- `SKILL.md`: Added `--from-explore <path>` to argument parsing and usage examples

---

## [2026-03-18] External Agent Analysis — Enforcement Upgrades

### Context

Re-evaluated 5 items from external agent analysis (1f, 1g, 2f, 2g, 3g). Found 2g (greenfield params) and 3g (Brief↔Spec alignment) already resolved. Implemented 3 remaining.

### Changes

| Item | Fix |
|------|-----|
| **1f** Entity schema consistency | Schema Drift Warning + Naming Collision Warning (edit distance ≤ 2) in plan Post-Step |
| **1g** Registry update atomicity | Step 3b Registry Freshness Verification — auto-repair stale registries per Feature |
| **2f** Domain rule enforcement | S1: BLOCKING when <50% coverage. S7: Bug Prevention Compliance Check in plan |

Also: inline Feature definition added to README first mention (EN/KO).

---

## [2026-03-17] Enforcement Gap Closure — 4 Fixes (from external analysis)

### Context

External agent analysis identified "trust-based vs guard-rail" enforcement gaps. Domain rules were loaded into context but never verified post-execution. Greenfield scenario parameters were defined but never collected. Registry updates had no atomicity guarantee. Brief↔Spec alignment was warning-only for capability gaps.

### Fixes

| # | Gap | Fix | File(s) |
|---|-----|-----|---------|
| 2f | Domain rule enforcement implicit | Added Domain Rule Compliance Check: S1→SC coverage in specify (warning), S7→Pattern Constraints in plan (blocking — auto-add missing rules) | `specify.md`, `plan.md` |
| 2g | greenfield params orphaned | Connected `project_maturity`/`team_context`: auto-inference in init.md Proposal Step 1, storage in state-schema.md, display in Proposal Step 3, modifiable in Step 3a, graceful degradation defaults | `init.md`, `state-schema.md`, `context-injection-rules.md` |
| 1g | Registry update atomicity | Added Registry Freshness Pre-check in Assemble step: verify preceding Feature's entities/APIs are in registry before context assembly, catch-up update if stale | `pipeline.md` |
| 3g | Brief↔Spec alignment too weak | Upgraded capability coverage gaps from Warning to BLOCKING (entity/interface/scope drift remain Warning). Added rationale for blocking | `specify.md` |

### Design Decision

- S1 compliance check is **warning** (specify output varies widely, false positives likely). S7 compliance check is **blocking** (Pattern Constraints section already blocking — extending completeness is natural).
- Brief capability gaps are **blocking** because they represent clear intent violation (user defined X, spec dropped X). Scope drift stays warning (spec may legitimately expand).

---

## [2026-03-17] Implementation Gap Analysis — 6 Structural Fixes

### Context

Analyzed whether the three README-claimed gaps (cross-Feature memory, project context understanding, user intent verification) were actually addressed by the implementation. Found 6 gaps and fixed all.

### Fixes

| # | Gap | File(s) Modified | Fix |
|---|-----|-----------------|-----|
| 1 | Greenfield pre-context empty | `commands/add.md` | Added Cross-Feature Awareness section to Phase 6 pre-context generation: Sibling Feature Summary, Dependency Context, Registry Snapshot |
| 2 | Entity ownership conflict undetected | `commands/pipeline.md`, `reference/injection/plan.md` | Added Entity Ownership Conflict Gate in Plan Execute+Review (BLOCKING). Added schema divergence protection in Post-Step Update Rules |
| 3 | Stub propagation silent failure | `reference/injection/implement.md`, `reference/injection/tasks.md` | Made stub scan mandatory (always runs, always reports). Made stub resolution task check BLOCKING in tasks Review |
| 4 | Adoption mode no intent verification | `commands/adopt.md` | Added Step 0.5 Feature Intent Verification (HARD STOP) before each Feature's adoption |
| 5 | Context Budget silent info loss | `reference/context-injection-rules.md` | Added Step 2.5 RE-READ GATE: post-execution relevance check for skipped/summarized sections |
| 6 | Concern integration knowledge missing | `domains/_resolver.md` | Added Step 3.5 Cross-Concern Integration Rules: 10 combination patterns (gui+realtime, microservice+auth, etc.) |

### Other

- Deleted `TODO.md` (all tasks completed, deferred items tracked in history)
- Removed TODO.md from README file tables

---

## [2026-03-17] Full Review Protocol Verification (11-point) — Integrity Fixes

### Context

Performed comprehensive 11-point Review Protocol verification (expanded from 5 to 11 items). Added 6 new review checks to CLAUDE.md: Cross-Reference Integrity, Numeric Consistency, Template↔Schema Alignment, Graceful Degradation Coverage, README File Table Completeness, Guard↔Pipeline Step Binding.

### Findings and Fixes (17 issues resolved)

| Category | Issue | Fix |
|----------|-------|-----|
| Protocol 5: Execute+Review | speckit-clarify, speckit-implement, speckit-constitution (incremental) missing inline sections | Added 3 inline Execute+Review sections to pipeline.md |
| Protocol 6: Broken links | ARCHITECTURE-EXTENSIBILITY.md wrong path depth; history.md dead v2-design.md link | Fixed 3 broken links across 4 files |
| Protocol 7: Numeric mismatch | Lessons count 22→33; Best Practice V/VI naming; _resolver.md merge rules incomplete | Updated READMEs, template, added _schema.md cross-reference |
| Protocol 9: Degradation table | 17 optional artifacts missing from graceful degradation table | Added 17 entries to context-injection-rules.md |
| Protocol 11: Guard binding | G3 completely unbound; G1/G2/G6/G7 partially bound | Added Guard cross-references to 5 injection/command files |

### Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Review Protocol expansion (5→11) | Added to CLAUDE.md permanently | Catches drift that manual review misses; numeric/link/guard gaps recur on every module change |
| Merge rules Single Source of Truth | _schema.md is authoritative; _resolver.md cross-references it | Prevents 2-file sync drift (was already out of sync: 5 vs 15 rules) |
| Guard attributions via `> Guard N:` blockquotes | Inline in injection files | Matches existing convention; enables grep-based binding verification |

---

## [2026-03-17] Self-Assessment Gap Resolution — Intent Verification, GEL Enforcement, Org Convention

### Context

Self-assessment revealed 3 core concepts had significant gaps:
- **Brief**: Solved completeness (40%) but not accuracy — no intent verification gate
- **GEL**: Solved visibility (60%) but not enforcement — warnings non-blocking, no consistency check
- **Domain Profile**: Solved project-type (75%) but not org-specific conventions

### Changes Made

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Brief Confirmation HARD STOP | Added Phase 1e to add.md — agent presents Brief Summary, user explicitly approves | Without this, misinterpretations propagate to specify unchecked |
| Elaboration Quality Guard | Added vague-answer warning (2x) + force-proceed-with-flag (3x) to add.md Phase 1c | Prevents agent from accepting "it handles data" as sufficient |
| Brief↔Spec Alignment Check | Added to specify.md — cross-checks Brief capabilities/entities/interfaces against generated FR/SC | Second-layer verification catches specify-time interpretation drift |
| Dependency Stub Enforcement | Added BLOCKING gate to pipeline.md implement Checkpoint — stubs from preceding Features that current Feature depends on | Prevents building on placeholder implementations that will break |
| Post-Update Consistency Verification | Added to implement.md Post-Step — cross-checks entity-registry and api-registry against actual implementation | Catches registry drift at implement time, not verify time |
| Registry Drift Resolution | Enhanced verify-phases.md Phase 4 — resolves REGISTRY-DRIFT flags and checks stub status | Ensures GEL artifacts match reality before merge |
| Org Convention Layer | Added to _resolver.md Step 2d, _schema.md Convention Hierarchy, state-schema.md header | Enables organization-level shared conventions across projects |
| Convention Hierarchy | 3-level: Skill → Org → Project (in loading order) | Later levels override earlier, org conventions reusable across projects |

### Assessment Impact

| Problem | Before | After | Key Change |
|---------|--------|-------|------------|
| Brief accuracy | ~40% | ~65% | Intent verification HARD STOP + Brief↔Spec cross-check |
| GEL enforcement | ~60% | ~75% | Dependency stub BLOCKING + registry consistency checks |
| Org convention | ~75% | ~85% | Organization-level convention loading support |

---

## [2026-03-17] Brief Implementation — S9/A5 Schema, Briefing Process, Pre-Context Template

### Changes Made

1. **S9 Brief Completion Criteria (domain module schema)**
   - Added `S9. Brief Completion Criteria` section to `_schema.md` (S0-S9, was S0-S8)
   - Added `A5. Brief Completion Criteria` for archetypes (A0-A5, was A0-A4)
   - Implemented S9 in `_core.md` (universal criteria: name, capability, entity, dependency)
   - Implemented S9 in all 5 interfaces: http-api (endpoints), gui (screens), cli (commands), data-io (sources/pipeline), tui (views/input)
   - Implemented S9 in 6 key concerns: auth, realtime, i18n, plugin-system, async-state, multi-tenancy
   - Implemented A5 in all 4 archetypes: ai-assistant (provider strategy), public-api (versioning), microservice (service boundary), sdk-framework (public API surface)
   - Updated merge rules in `_schema.md` to include S9 and A5

2. **add.md → "Feature Briefing" restructure**
   - Renamed "6-Phase Universal Feature Definition" → "Feature Briefing"
   - Renamed "Phase 1: Feature Definition" → "Phase 1: Briefing"
   - Connected Phase 1 header to Brief concept (README § Three Core Concepts)
   - Updated completion criteria to include 3 layers: base (6 perspectives) + S9 (domain) + A5 (archetype)
   - Added note about S9/A5 gap-filling using S5 probes

3. **feature-elaboration-framework.md → Brief quality gate**
   - Updated purpose to explicitly identify as the "quality gate for the Brief concept"
   - Added step 4: "Verify domain-specific Brief Completion Criteria (§ S9/A5)"
   - Extended Completion Criteria section with domain-specific table (S9/A5 checks)

4. **pre-context-template.md → Brief Summary section**
   - Added "Brief Summary" section at top (after header, before Runtime Exploration)
   - Fields: Description, User & Purpose, Capabilities, Data, Interfaces, Quality, Boundaries
   - Serves as single source of truth for the Feature definition agreed during Briefing

5. **SKILL.md → command description update**
   - Updated `add` command description: "Feature Briefing — structured intake + completeness validation"

6. **ARCHITECTURE-EXTENSIBILITY.md/ko.md → S9/A5 in section mapping**
   - Added S9 and A5 rows to the "Section → Pipeline Step" mapping table

7. **README.md/ko.md improvements (per user feedback)**
   - Gap 2: Added organization/project-specific characteristics to the problem framing
   - Gap 3: Changed from "accepts whatever input" to "doesn't verify intent understanding"
   - Pipeline: Full pipeline (specify → plan → tasks → analyze → implement → verify)
   - Workflow examples: Three concepts woven into all End-to-End scenarios with visual annotations
   - User Journeys: Added Brief/GEL/Domain Profile labels to each journey path

### Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| S9 numbering (not S10) | S9 | Keeps numbering compact; S4 was already scenario-specific, no collision |
| A5 for archetypes | Separate from S9 | Archetype criteria are philosophical (e.g., "provider strategy"), interface criteria are structural (e.g., "endpoint defined") |
| Universal S9 in _core | 4 universal criteria | Minimum bar for ALL projects regardless of domain |
| Brief Summary in pre-context | Top of template | Quick-reference for downstream steps; single source of truth |

---

## [2026-03-17] Three Core Concepts Framework — GEL, Domain Profile, Brief

Established a unified conceptual framework for spec-kit-skills built on three core concepts, each addressing a structural gap in agentic coding at scale.

### Design Decision

Consolidated the project's numerous internal concepts into three user-facing core concepts:

1. **Global Evolution Layer (GEL)** — Solves fragmented context management across agents. Each AI agent (Claude Code, Cursor, Windsurf) manages context differently; none track cross-Feature relationships systematically. GEL provides agent-agnostic structured context artifacts.

2. **Domain Profile** — Solves generic project-type treatment. Composable 4-axis module system (Interface × Concern × Archetype × Scenario) that loads project-type-specific rules for spec generation, bug prevention, and verification.

3. **Brief** — Solves unvalidated Feature intake. Structured Feature definition process that ensures completeness across key dimensions before spec generation, regardless of input source (PRD, conversation, code gap analysis).

### Key Terminology Decision

- Evaluated alternatives: "Expert" (rejected — names an actor, not an artifact), "Guru" (same issue), "Canvas" (close but Brief is more established), "Forge" (process name, not artifact name)
- **"Brief"** selected — matches industry precedent (design brief, project brief), works as both noun and verb, clearly sits above "Spec" in the resolution hierarchy

### Problem Framing

Reframed the core narrative from "spec-kit processes one Feature at a time" to three structural gaps:
- Agents manage context differently (not "stateless" — each has memory, but fragmented)
- Agents have no project-type awareness (domain-agnostic)
- Agents accept whatever input they get (no quality gate)

### Changes

- **README.md**: Rewrote "What It Solves" with problem-first framing (3 gaps → 3 concepts). Restructured "Architecture" around concept collaboration diagram instead of 3 pillars. Aligned Design Philosophy with concepts. Added concept framing to Domain Module System and Extensibility sections.
- **README.ko.md**: Synchronized all changes.
- **ARCHITECTURE-EXTENSIBILITY.md** + **.ko.md**: Added "Three Core Concepts" overview section at the top.

### Future Work

- B1 section schema for Brief completion criteria in domain modules
- add.md Phase 1 restructure as "Briefing" process
- pre-context-template.md Brief section format

---

## [2026-03-17] README.ko.md Structure Sync with README.md (c541674)

Synchronized README.ko.md structure with README.md changes from commit c541674.

### Changes
- **Section reordering**: Moved User Journeys + Quick Examples before Architecture (matching README.md)
- **E2E merge**: Merged standalone "End-to-End 워크플로우 예시" section into User Journeys as subsections
- **Architecture split**: Split monolithic Architecture section into 4 independent ## sections: 아키텍처, 도메인 모듈 시스템, 확장성 & 커스터마이징, 세션 복원력 & 에이전트 거버넌스
- **New content**: Added "Domain Profile 결정 방법" (Greenfield vs Brownfield detection paths) and "모듈 내부 구조 — Section 시스템" (S/A/R/F section tables) — translated from README.md

### Also in this session (earlier commit 9aa2d3b)
- Created ARCHITECTURE-EXTENSIBILITY.ko.md (Korean translation, 738 lines)
- Updated README.ko.md links to point to .ko.md version
- Added sync rules to CLAUDE.md
- Updated _resolver.md with Brownfield/Greenfield profile detection split

---

## [2026-03-17] Domain Module Expansion — 6 GAPs from OSS Project Analysis

Analyzed 4 open-source projects (OpenJarvis, open-trading-api, Feast, Vanna) against spec-kit-skills' domain coverage. Identified 6 structural gaps and implemented solutions.

### New Concern Modules (4)

| Module | Files Created | Key Patterns |
|--------|-------------|-------------|
| **polyglot** | shared + smart-sdd + reverse-spec | FFI bridges (PyO3, cgo, JNI), Protobuf/gRPC, WASM, build orchestration, type mapping |
| **codegen** | shared + smart-sdd + reverse-spec | IDL/schema source-of-truth, generated file tracking, repetitive pattern detection, Feature boundary rules |
| **multi-tenancy** | shared + smart-sdd + reverse-spec | Tenant isolation strategies, context propagation, cache isolation, cross-tenant leak prevention |
| **infra-as-code** | shared + smart-sdd + reverse-spec | Terraform/Helm/K8s as first-class, app-infra sync, secret management, IaC validation |

### New Archetype (1)

| Module | Files Created | Key Principles |
|--------|-------------|---------------|
| **sdk-framework** | shared + smart-sdd + reverse-spec | API Stability, Extension-First Design, Example-as-Contract, Documentation Parity, Backward Compatibility. Feature boundary guidance: extension-point scoping (interface Feature + implementation Features) |

### Data Science Domain Completion

| Change | File | What Changed |
|--------|------|-------------|
| **reverse-spec/data-science.md** | Filled all 9 TODO sections | Detection signals (feature store, vector DB, NL-to-SQL), 5 project types, 7 analysis axes, 4 registries, tier classification |
| **smart-sdd/data-science.md** | Filled all 3 TODO sections | Demo pattern (3 project types), parity dimensions (structural + logic), verify steps (6 steps with conditional gating) |

### New Profiles (2)

| Profile | Interfaces | Concerns | Archetype |
|---------|-----------|----------|-----------|
| **ml-platform** | http-api, cli, data-io | plugin-system, auth | — |
| **sdk-library** | cli | plugin-system | sdk-framework |

### Infrastructure Updates

| File | Change |
|------|--------|
| `shared/domains/_taxonomy.md` | Added 4 concerns, 1 archetype, 2 profiles with archetype column |
| `smart-sdd/domains/_resolver.md` | Profile can now specify archetype (e.g., sdk-library → sdk-framework) |
| `ARCHITECTURE-EXTENSIBILITY.md` | Added 4 concerns + 1 archetype to tables, 9 cross-reference entries, profile table with archetype column |

### Design Decisions

- **codegen concern**: Introduces explicit Feature boundary rule — repetitive generated code (e.g., 669 API wrappers in open-trading-api) is NOT split into individual Features. One Feature for the generation rule + one for generator infrastructure.
- **sdk-framework archetype**: Redefines Feature = "extension point boundary" instead of "user-facing feature". Each extension interface = 1 Feature, each implementation = 1 Feature.
- **data-science completion**: Added `nl-interface` and `platform` project types beyond original pipeline/modeling/analysis. Store Backend Map registry added for plugin-heavy ML platforms.
- **Profiles with archetype**: Resolver updated so profiles can declare an archetype field. This enables `sdk-library` profile to auto-activate `sdk-framework` archetype.

---

## [2026-03-16] Post-Pull Comprehensive Consistency Audit (17 fixes across 13 files)

### Foundation ID Prefix Fixes (Critical — ID collision prevention)

| Change | File | Rationale |
|--------|------|-----------|
| **Bun F2 IDs prefixed** | `reverse-spec/domains/foundations/bun.md` | 22 IDs: `BST-01` → `BU-BST-01` etc. F4 convention requires `{FW}-{CAT}-{NN}` |
| **Hono F2 IDs prefixed** | `reverse-spec/domains/foundations/hono.md` | 9 IDs: `BST-01` → `HO-BST-01` etc. |
| **Solid.js F2 IDs prefixed** | `reverse-spec/domains/foundations/solidjs.md` | 16 IDs: `RCT-01` → `SO-RCT-01` etc. |
| **F4 registry updated** | `reverse-spec/domains/foundations/_foundation-core.md` | Added BU, HO, SO to FW code table |

### Structural Consistency (Moderate)

| Change | File | Rationale |
|--------|------|-----------|
| **R1 section added** | `reverse-spec/domains/interfaces/http-api.md` | Missing R1 Detection Signals cross-ref to shared module |
| **R1 section added** | `reverse-spec/domains/interfaces/gui.md` | Same — aligns with cli.md/data-io.md pattern |
| **R4 → R3b renumbered** | `reverse-spec/domains/interfaces/tui.md` | R4 = "Registries (_core only)" per _schema.md; TUI patterns = R3b |
| **Stale Case B examples** | `reverse-spec/domains/foundations/_foundation-core.md` L130 | Django/Spring Boot → Remix/Svelte/Nuxt (former now have Foundation files) |
| **SKILL.md module list** | `smart-sdd/SKILL.md` L204-205 | Inline lists → `see shared/domains/_taxonomy.md` reference |

### Pipeline/Injection Fixes

| Change | File | Rationale |
|--------|------|-----------|
| **S0 path corrected** | `smart-sdd/commands/init.md` L32 | `domains/` → `shared/domains/` for signal keyword scan |
| **Foundation paths clarified** | `smart-sdd/commands/init.md` L184, L199 | Short name → full relative path matching _resolver.md |
| **§ ref fixed** | `smart-sdd/commands/init.md` L56 | `§ A0 Aggregation` → `§ S0/A0 Aggregation` |
| **Archetype field added** | `smart-sdd/reference/clarity-index.md` §7 | Proposal Format missing Archetype field required by init.md Step 3 |
| **Step 1b → 1c renumber** | `smart-sdd/reference/injection/implement.md` | i18n check renumbered to avoid collision with new native dependency check |
| **BLOCKING icons** | `smart-sdd/reference/injection/plan.md` | `⚠️` → `🚫 ... BLOCKING.` for 3 BLOCKING sections (Interaction Chains, Integration Contracts, API Compat) |
| **Arrow spacing** | `smart-sdd/reference/injection/tasks.md` | `Source→Target` → `Source → Target` consistent with plan.md |
| **Orphaned params → optional** | `smart-sdd/domains/scenarios/greenfield.md` | `project_maturity`/`team_context` marked optional with defaults (`mvp`/`solo`) |

---

## [2026-03-16] SKF-045 — Data Lifecycle Paradigm Mapping + Source Reference BLOCKING

| Change | File | Rationale |
|--------|------|-----------|
| **Data Lifecycle Pattern Extraction (Phase 2-7d)** | `reverse-spec/commands/analyze.md` | Source app의 데이터 진입 패러다임(opt-in/opt-out/curated/import-driven)을 pre-context에 추출. 컴포넌트 구조만으로는 비즈니스 로직 패러다임을 캡처할 수 없음 (SKF-045) |
| **Data Lifecycle Patterns template** | `reverse-spec/templates/pre-context-template.md` | pre-context에 `### Data Lifecycle Patterns` 섹션 추가. Entity별 Paradigm, CRUD Flow, Evidence Components 기록 |
| **Data Lifecycle Mapping (BLOCKING)** | `smart-sdd/reference/injection/plan.md` | plan.md에 Source→Target 패러다임 매핑 테이블 필수. 패러다임 변경 시 Justification 없으면 BLOCKING |
| **Source Reference Injection → BLOCKING** | `smart-sdd/reference/injection/implement.md` | rebuild+GUI에서 UI 태스크의 source 파일 읽기를 BLOCKING gate로 승격. 라이프사이클 준수 검증 추가 |
| **Guard 7 Fidelity Chain 확장** | `pipeline-integrity-guards.md` | Data Lifecycle Patterns/Mapping을 체인에 추가. 6개 artifact로 확장 |
| **Cross-Reference Map 확장** | `ARCHITECTURE-EXTENSIBILITY.md` | Data Lifecycle Paradigm Mapping, Source Reference BLOCKING Gate 항목 추가 |

**설계 원칙**: Guard 7의 Fidelity Chain이 UI 구조(Component Tree)만 커버하고 데이터 흐름 패러다임을 놓치는 문제 해결. "opt-in vs opt-out" 같은 패러다임 차이는 기능적으로는 정상이지만 UX적으로 완전히 다른 앱을 만듦. 패러다임 vocabulary(opt-in, opt-out, curated, import-driven)는 확장 가능하도록 설계.

---

## [2026-03-16] Pipeline Integrity Guards — Gap Closure (5 fixes)

| Change | File | Rationale |
|--------|------|-----------|
| **G5: Dual-Mode Verification integrated** | `verify-phases.md` Phase 3b | Clean + Seeded state 양쪽 통과 필수 (BLOCKING for persistent storage Features). Test State Isolation Rules 3개 추가. SKF-033/040 재발 방지 |
| **G7: Source Component Reference Tags** | `injection/tasks.md` | rebuild+GUI에서 각 UI task에 `Source: [Component] (file)` 태그 필수 (BLOCKING). plan.md Mapping → tasks.md 연결 끊김 방지 |
| **G6: Guarantee → BLOCKING in rebuild** | `verify-phases.md` Step 1a | Provides 인터페이스 미구현 시 rebuild 모드에서 BLOCKING 승격. SKF-041 재발 방지 |
| **G2: CSS Rendering → BLOCKING upgrade** | `verify-phases.md` CSS Token Check | GUI + CSS framework 사용 시 CSS Rendering 실패를 BLOCKING으로 승격. SKF-023 재발 방지 |
| **Guard doc cross-reference** | `pipeline.md` | pipeline-integrity-guards.md 직접 참조 링크 추가 |

---

## [2026-03-16] Pipeline Integrity Guards — SKF-001~044 Root Cause Generalization

| Change | File | Rationale |
|--------|------|-----------|
| **Pipeline Integrity Guards (new)** | `smart-sdd/reference/pipeline-integrity-guards.md` | 44건의 SKF를 7개 근본 원인 패턴으로 일반화. 개별 ad-hoc 규칙 대신 확장 가능한 Guard 시스템으로 설계. Guard 1(Guideline→Gate), Guard 2(Static≠Runtime), Guard 3(Cross-Stage Trust), Guard 4(Granularity), Guard 5(Environment Parity), Guard 6(Cross-Feature Interface), Guard 7(Rebuild Fidelity) |
| **Component Tree Extraction** | `reverse-spec/commands/analyze.md` Phase 2-7c | GUI Feature의 컴포넌트 계층 구조를 pre-context에 추출 (Guard 4c, 7). SKF-037/044의 "파일 단위 SBI만으로는 UI 구조를 캡처할 수 없다" 문제 해결 |
| **Component Tree template** | `reverse-spec/templates/pre-context-template.md` | pre-context에 `### Component Tree` 섹션 추가. plan/implement/verify가 참조하는 구조적 기준선 |
| **Source→Target Component Mapping** | `smart-sdd/reference/injection/plan.md` | rebuild 모드에서 plan.md에 source↔target 컴포넌트 매핑 테이블 필수 (BLOCKING). SKF-038/044의 "plan이 source 구조를 참조하지 않고 독자적 아키텍처 설계" 문제 해결 |
| **FR Element Decomposition** | `smart-sdd/reference/injection/analyze.md` | FR 내 interactive 요소를 개별 분해하여 task 누락 감지 (Guard 4b). SKF-039의 "model selector dropdown 누락" 문제 해결 |
| **Data Round-Trip Verification** | `smart-sdd/reference/injection/implement.md` | INSERT vs UPDATE, hydrate(), streaming flush 등 persist 왕복 검증 규칙 (Guard 2 Level 4). SKF-040/041의 "데이터가 세션 중에는 보이지만 재시작 시 사라짐" 문제 해결 |
| **Cross-Reference Map 확장** | `ARCHITECTURE-EXTENSIBILITY.md` | Pipeline Integrity Guards, Component Tree flow, FR Decomposition, Data Round-trip 항목 추가 |

**설계 원칙**: 개별 SKF를 하나씩 반영하면 규칙이 무한히 증가하고 에이전트가 무시함. 대신 7개 Guard 패턴으로 일반화하여, 새로운 실패가 발생하면 기존 Guard를 확장하는 구조. Guard는 Trigger→Verification→Enforcement 3요소를 갖추어 어떤 프로젝트 유형에서도 적용 가능.

---

## [2026-03-16] Architecture Review — Content Distribution + Contributor Templates

| Change | File | Rationale |
|--------|------|-----------|
| Post-Change Propagation Check | `CLAUDE.md` | 작업 완료 시 README, ARCHITECTURE-EXTENSIBILITY, history, lessons-learned 반영 필요 여부를 반드시 판단하도록 규칙 추가 |
| Foundation _TEMPLATE.md | `reverse-spec/domains/foundations/` | 신규 Foundation 추가 시 copy-paste 가능한 F0-F9 구조 템플릿. 기여자 진입 장벽 감소 |
| Concern _TEMPLATE.md (reverse-spec) | `reverse-spec/domains/concerns/` | R1 Detection Signals 템플릿 |
| Concern _TEMPLATE.md (smart-sdd) | `smart-sdd/domains/concerns/` | S0/S1/S5/S7 구조 템플릿 |
| Foundation back-references | 19개 foundation 파일 전체 | `<!-- Format: _foundation-core.md \| ID prefix: XX -->` 코멘트 추가. 역참조 명시화 |

---

## [2026-03-16] SKF-035~036: Demo --ci ≠ UI Verification + CSS Theme Token Rendering

| Change | File | Rationale |
|--------|------|-----------|
| Demo --ci ≠ UI Verification (Gate rule 5) | `verify-phases.md` | SKF-035: Demo `--ci`만으로 GUI Feature verify를 완료하는 것을 명시적으로 금지. Steps 3/3d Playwright SC 검증이 필수이며, 누락 시 Review에 표시 |
| CSS Theme Token Rendering Check | `verify-phases.md` Step 3 | SKF-036: SC Tier 1 존재 확인 시 최소 1개 interactive 요소의 getComputedStyle() 검증. transparent/invisible 감지 시 테마 토큰 매핑 누락 경고 |
| CSS Theme Token mapping check | `injection/implement.md` Build Toolchain | SKF-036: CSS 변수 기반 디자인 토큰 사용 시 CSS 프레임워크 테마 시스템 매핑 확인 (Tailwind 4 @theme, Tailwind 3 config, UnoCSS config) |
| gui.md S7 cross-reference | `gui.md` | CSS Theme Token Rendering 규칙을 S7 Bug Prevention에 교차 참조 추가 |

---

## [2026-03-16] Multi-Language Backend Expansion — Phase D Completion + Full Verification

Completed remaining Phase D: FastAPI and NestJS Foundation files upgraded from TODO scaffold to full compact format (F0-F9). Updated ARCHITECTURE-EXTENSIBILITY.md with Foundation coverage table, Foundation format variants documentation, and expanded Cross-Reference Map. Full 87-point verification confirmed 100% pass rate across all files.

| Change | Category | Details |
|--------|----------|---------|
| FastAPI Foundation implemented | Foundation | Upgraded from TODO scaffold to compact format: F0-F9 complete, FA-* IDs, Pydantic/async-first philosophy |
| NestJS Foundation implemented | Foundation | Upgraded from TODO scaffold to compact format: F0-F9 complete, NJ-* IDs, modular/decorator-driven philosophy |
| Foundation Coverage table | ARCHITECTURE-EXTENSIBILITY.md | Language-by-language coverage matrix (14 languages, 21 frameworks) |
| Foundation Format Variants | ARCHITECTURE-EXTENSIBILITY.md | Documented Full vs Compact format decision with usage criteria |
| Cross-Reference Map expansion | ARCHITECTURE-EXTENSIBILITY.md | Added S3b, message-queue, task-worker, foundation file groups |
| README file table updates | README.md + README.ko.md | 13 new files added, nestjs/fastapi descriptions updated from "TODO scaffold" |
| _foundation-core.md F6 update | Foundation protocol | nestjs + fastapi status changed from "TODO scaffold" to "Implemented" |

---

## [2026-03-16] Multi-Language Backend Expansion — Architecture Stress Test

Stress-tested spec-kit-skills against 13+ real-world open source projects across 10 languages (TypeScript, Python, Java, Kotlin, Go, Rust, Ruby, PHP, Elixir, C#). Identified and resolved gaps in Foundation coverage, Concern modules, and toolchain detection.

| Change | Category | Details |
|--------|----------|---------|
| 9 new Foundation files | Foundation | spring-boot, django, rails, flask, actix-web, go-chi, dotnet, laravel, phoenix |
| 2 new Concern modules | Concern | `message-queue` (R1+S0/S1/S5/S7), `task-worker` (R1+S0/S1/S5/S7) |
| S3b Lint Detection expansion | _core.md | Added Java, Kotlin, Ruby, PHP, Elixir, C#/.NET toolchains (7 new languages) |
| R3-2 Data Model targets | reverse-spec _core.md | Added Ecto, EF Core, Eloquent, ActiveRecord, Diesel/SQLx/SeaORM, Go ORMs |
| R3-5 Env Var patterns | reverse-spec _core.md | Added Elixir, PHP, C#, Kotlin, Rust detection patterns |
| R1 Detection Signals expanded | reverse-spec _core.md | Added mix.exs, *.csproj, build.gradle.kts, 9 new framework imports |
| _foundation-core.md registry | Foundation protocol | F0 (10 new detection rows), F4 (9 new codes), F6 (9 new file entries) |
| B-3 Conditional Rules | smart-sdd _core.md | Added MQ-001/003, TW-002/004 to conditional rules table |
| Case-study Stack Profile | case-study generate.md | Optional subsection for non-JS/TS projects in Section 2 |
| Case-study challenge categories | case-study generate.md | Language/Framework/Ecosystem/Domain/Foundation gap categorization hint |
| ARCHITECTURE-EXTENSIBILITY.md | Documentation | Added message-queue, task-worker to concern table; native-app Out of Scope section |

**Projects analyzed**: OpenClaw (TS), Superset (Flask), mall (Spring Boot), conductor (Spring Boot), Gitea (Go/Chi), Mattermost (Go), Harbor (Go/Beego), Qdrant (Rust/Actix), Lemmy (Rust/Actix), Meilisearch (Rust/Actix), Mastodon (Ruby/Rails), Bagisto (PHP/Laravel), Plausible (Elixir/Phoenix), Sentry (Python/Django), Polar (Python/FastAPI), Vendure (TS/NestJS), eShop (C#/.NET), Komga (Kotlin/Spring Boot)

**Design decision**: Native app interface (SwiftUI/Jetpack Compose) explicitly deferred — documented in ARCHITECTURE-EXTENSIBILITY.md as "Out of Scope (Future Extension)".

---

## [2026-03-16] Full File Review — Dead Schema Fix + Structure Consumption + Checklist Repair

| Change | File | Rationale |
|--------|------|-----------|
| F8 Foundation Override in Toolchain Pre-flight | `pipeline.md`, `verify-phases.md` | F8 Toolchain Commands는 정의만 되고 소비처가 없었음 (dead schema). Foundation Gate와 verify Phase 1이 F8을 읽어 auto-detection 대신 사용하도록 연결 |
| F9 Scan Target Loading in Phase 2 | `analyze.md` | F9 Scan Targets도 dead schema. Phase 2 서두에 F9 로딩 지시 추가, `_core.md` universal targets와 MERGE하도록 연결 |
| Structure-aware build/test | `pipeline.md`, `verify-phases.md` | `**Structure**: monorepo` 필드가 정의·자동감지되지만 미사용. Foundation Gate build와 verify Phase 1 test/build에 workspace-aware 명령 분기 추가 |
| Step 3f checklist 추가 | `verify-phases.md` | Step 3f (User-Assisted SC Completion Gate) 구현은 있으나 Phase 3 checklist에서 누락. 3e와 3f2 사이에 Step 3f 항목 추가 |
| Cross-Reference Map 확장 | `ARCHITECTURE-EXTENSIBILITY.md` | F8, F9, Structure 항목을 Cross-Reference Map에 추가. 새 concern/interface 모듈 목록 추가 |
| Lessons Learned L23~L28 | `lessons-learned.md` | SKF-028~034 패턴을 universal lessons로 추가 (verification completeness, dead schema, checklist divergence 등) |

---

## [2026-03-16] User-Assisted Manual Verification Gate (Step 3f2)

| Change | File | Rationale |
|--------|------|-----------|
| Step 3f2: User-Assisted Manual Verification | `verify-phases.md` | "자동화 불가 ≠ 검증 스킵" 원칙 관철. manual SC, manual-only TEST PLAN 항목을 사용자에게 제시하여 수동 확인 요청. 3-state 결과: machine-verified / user-verified / explicitly-deferred |
| `manual` SC 분류 변경 | `verify-phases.md` Step 0 | `manual` SC가 "Skip as manual-only" → "User-assisted manual verification in Step 3f2"로 변경 |
| Core Principle 추가 | `user-cooperation-protocol.md` | "Automation-impossible ≠ verification skip" 원칙을 프로토콜 헤더에 명시 |

---

## [2026-03-16] SKF-033~034: Test State Isolation + Async Hydration Sync

| Change | File | Rationale |
|--------|------|-----------|
| Test State Isolation (Phase 0, Step 0-4) | `verify-phases.md` | SKF-033: Persist된 앱 상태(theme, language)가 테스트에 false positive/negative 유발. 3-tier 전략: clean data dir → reset API → read-before-act 패턴 |
| Async Hydration Sync | `injection/implement.md` | SKF-034: 비동기 hydration과 외부 시스템(i18n, theme) 간 race condition. i18n에 한정하지 않고 "async hydrate → unconditional sync" 범용 패턴으로 일반화 |

---

## [2026-03-16] SKF-028~032: SBI resolution, Interaction Chain verification, Feature Reachability, TEST PLAN

| Change | File | Rationale |
|--------|------|-----------|
| UI Control-Level Resolution Rule | `reverse-spec/commands/analyze.md` | SKF-028: SBI extraction stopped at file level → missed individual UI controls in dense pages (settings, forms). Now splits to per-control SBI when 5+ controls detected |
| Interaction Chain Verify Method Execution (Step 3d2) | `smart-sdd/commands/verify-phases.md` | SKF-029: plan.md Verify Method column was a dead column — verify never executed it. Now parsed and run as Playwright assertions |
| Feature Reachability Gate (Phase 0, Step 0-4) | `smart-sdd/commands/verify-phases.md` | SKF-030: GUI Feature could pass verify despite being unreachable from home screen. Now BLOCKS if no UI navigation path exists |
| Feature Reachability Path in specify | `smart-sdd/reference/injection/specify.md` | SKF-030: spec.md lacked FR for "how user accesses this Feature". Now requires navigation path FR for GUI Features |
| Demo TEST PLAN Comment Block | `smart-sdd/reference/demo-standard.md` | SKF-031: demo scripts listed features without "action → expected → confirm" format. Now requires structured TEST PLAN block |
| Demo TEST PLAN Execution (Step 3d3) | `smart-sdd/commands/verify-phases.md` | SKF-032: TEST PLAN was write-only — verify never executed its items. Now parses and runs automatable tests via Playwright |

---

## [2026-03-16] Extensibility expansion — new modules, F8/F9 schema, Structure parameter

| Change | File | Rationale |
|--------|------|-----------|
| F8 Toolchain Commands schema | `_foundation-core.md` | Foundation files can declare build/test/lint commands → pipeline reads them instead of auto-detection |
| F9 Scan Targets schema | `_foundation-core.md` | Foundation files can declare framework-specific scan targets → reverse-spec Phase 2 reads them without modifying _core.md |
| Structure parameter | `state-schema.md` | `single-package \| monorepo` parameter enables monorepo-aware pipeline behavior (workspace-aware build/test) |
| Bun/Solid.js/Hono detection | `_foundation-core.md` F0 table | Added detection signals for 3 new runtime/framework ecosystems |
| TUI interface (both skills) | `interfaces/tui.md` × 2 | Terminal UI support — PTY-based verification, keyboard navigation, reactivity patterns |
| Protocol integration concern (both skills) | `concerns/protocol-integration.md` × 2 | LSP/MCP/custom protocol lifecycle — initialization, capability negotiation, transport |
| Plugin system concern (both skills) | `concerns/plugin-system.md` × 2 | Plugin architecture — isolation, lifecycle, API contract, versioning |
| Authorization concern (both skills) | `concerns/authorization.md` × 2 | RBAC/ABAC/ACL permission models — boundary verification, escalation prevention |
| Bun Foundation | `foundations/bun.md` | Runtime/toolchain decisions with F7 philosophy (single binary, TypeScript-first) + F8 + F9 |
| Solid.js Foundation | `foundations/solidjs.md` | Reactivity model with F7 philosophy (fine-grained reactivity, no virtual DOM, props as proxies) |
| Hono Foundation | `foundations/hono.md` | Web framework decisions with F7 philosophy (ultralight, multi-runtime) + F8 + F9 |
| External SDK enhancement | `concerns/external-sdk.md` × 2 | S7b Large-Scale Provider Abstraction for multi-provider scenarios (20+ providers) |
| AI Assistant enhancement | `archetypes/ai-assistant.md` × 2 | A2b Coding Agent Sub-Pattern — sandbox, tool orchestration, context management |
| F8/F9 documentation | `ARCHITECTURE-EXTENSIBILITY.md` | Added F8/F9 to Foundation creation guide |

---

## [2026-03-16] README readability overhaul + flow diagram

| Change | File | Rationale |
|--------|------|-----------|
| Tagline rewrite | `README.md`, `README.ko.md` | "AI-controllable contract-based development" → "so Feature 3 knows what Feature 1 already decided" — concrete over abstract |
| Skill descriptions rewrite | `README.md`, `README.ko.md` | Technical jargon → plain language explaining what each skill does and when to use it |
| Architecture intro rewrite | `README.md`, `README.ko.md` | "harness" metaphor → "guardrail system" with self-driving car analogy |
| Design Philosophy rewrite | `README.md`, `README.ko.md` | All 5 principles rewritten in plain language with everyday analogies |
| 4-axis intro rewrite | `README.md`, `README.ko.md` | Removed internal jargon (SC generation, probes), focused on user-facing benefit |
| "How the Skills Connect" flow diagram | `README.md`, `README.ko.md` | Added big-picture 5-step visual (analyze → artifacts → build → per-feature → report) bridging Skills section to Architecture |
| "harness" → "system" | `README.md` | Consistent terminology in Rebuild Configuration |

---

## [2026-03-16] SKF-026/027: Branch conflict recovery + FR coverage severity calibration

| Change | File | Rationale |
|--------|------|-----------|
| Branch-already-exists recovery | `pipeline.md` | SKF-026: `create-new-feature.sh` errors on pre-created branch → added non-fatal error recovery guidance. Extends L18 pattern. |
| MEDIUM severity tier for FR coverage | `injection/analyze.md` | SKF-027: "task exists but lacks implementation detail" was HIGH → added MEDIUM tier. HIGH now reserved for missing behavioral coverage, not missing implementation specifics. |

---

## [2026-03-16] Inline Execute+Review sections for specify/plan/tasks

Pipeline.md had inline Execute+Review instructions for constitution (Phase 0, line 599-611) but NOT for specify, plan, or tasks. These steps relied on: (1) Common Protocol section at the top of pipeline.md, (2) injection files (specify.md, plan.md, tasks.md). Both could be compacted out of context by execution time. Result: agent showed raw spec-kit output ("Spec created and validated", "Ready for /speckit.clarify or /speckit.plan") and stopped — 위반 패턴 A.

| Change | File | Rationale |
|--------|------|-----------|
| Add Specify Execute+Review (HARD STOP) | `pipeline.md` | Inline reminder to suppress raw output, read artifact, show Review, AskUserQuestion |
| Add Plan Execute+Review (HARD STOP) | `pipeline.md` | Same pattern for plan step |
| Add Tasks Execute+Review (HARD STOP) | `pipeline.md` | Same pattern for tasks step |
| Catch-all fallback → all Execute+Review | `pipeline.md`, `injection/specify.md` | Fallback changed from "context limit only" to "ANY reason response ends without AskUserQuestion". Prevents silent dead-end where user doesn't know what to do next |
| CLAUDE.md #8 catch-all sub-item | `CLAUDE.md` | Permanent rule: user must NEVER be left without knowing what to do next. Fallback applies to ALL abnormal terminations, not just context limits |

---

## [2026-03-16] Pre-context freshness check at specify time

Specify injection read pre-context.md as-is without validating assumptions against preceding Features' actual implementation. If a dependency's tech choice changed after pre-context was written (e.g., better-sqlite3 → electron-store in F001), specify would draft SCs based on stale assumptions. Plan injection already reads actual data-model.md/contracts/, but that's 2 steps too late.

| Change | File | Rationale |
|--------|------|-----------|
| Pre-context freshness check | `injection/specify.md` | Step 3 added to Preceding Feature Result Reference — reads actual implementation artifacts and flags ⚠️ discrepancies against pre-context at Checkpoint |

---

## [2026-03-16] Systemic: Feature completeness + rebuild parity enforcement + rule generalization

### Feature Completeness — no blocking gate existed (Critical)

Features could pass all verification gates while being incomplete. Task completion was only checked as a ⚠️ warning in verify Phase 2 (too late, non-blocking). SC coverage threshold was advisory. Integration contracts, orphaned services, and demo coverage were all non-blocking warnings.

| Change | File | Rationale |
|--------|------|-----------|
| Post-Implement Completeness Gate | `pipeline.md` | BLOCKING gate between Smoke Launch and Review — audits tasks.md completion rate + rebuild visual reference. Catches incompleteness BEFORE verify |
| Elevate Phase 2 task completion to BLOCKING | `verify-phases.md` | If tasks incomplete without DEFERRED acknowledgment → blocks (not warning) |

### Rebuild Parity — plan/implement had no blocking parity gates (Critical)

In rebuild mode, agent produced output that didn't match the original app (SKF-024: sidebar+tabbar simultaneously instead of mode-exclusive). Visual references were "MUST consult" in prose but had no HARD STOP enforcement. Verify 3e could be skipped with single acknowledgment.

| Change | File | Rationale |
|--------|------|-----------|
| Rebuild Visual Reference Checkpoint (HARD STOP) | `injection/implement.md` | MANDATORY gate before first UI task — detects no visual reference and blocks |
| Strengthen 3e skip: require visual ref fallback | `verify-phases.md` | Source app unavailable → fallback to static visual refs → if neither exists, Feature = `limited` not `success` |
| Completeness Gate rebuild parity check | `pipeline.md` | Verifies visual reference was consulted during implement |

### Rule Generalization — specific → general

SKF-023 fixes were CSS-specific. Generalized to cover any build-time transformation framework.

| Before | After | Files |
|--------|-------|-------|
| CSS Build Pipeline Verification | Build Toolchain Integration Verification | `injection/implement.md` |
| CSS rendering check (Phase 1) | Build Output Fidelity Check | `verify-phases.md` |
| CSS Toolchain (Foundation Gate) | Build Plugins | `pipeline.md` |
| CSS framework misconfiguration (Smoke Launch) | Build-time framework misconfiguration | `pipeline.md` |
| CSS Value Map (utility CSS only) | CSS Value Map (all build-time CSS frameworks) | `injection/implement.md` |
| "avoid unnecessary re-renders" (React-specific) | "for performance and simplicity" (general) | `injection/implement.md` |

---

## [2026-03-16] Systemic: Warning → BLOCK escalation across specify/plan/tasks + build-time detection

### Problem Pattern — same as implement/verify but in earlier phases

The previous session fixed warning→BLOCK in implement.md and verify-phases.md. Same pattern existed in specify.md, plan.md, and tasks.md — critical architectural checks (Interaction Chains, Integration Contracts, SBI accuracy, Platform Constraints, Edge Cases, Multi-Provider coverage, demo tasks, integration wiring) were all ⚠️ warnings that users could dismiss with "Approve", allowing defects to propagate downstream.

### Changes — specify.md

| Check | Before | After |
|-------|--------|-------|
| SBI Accuracy Cross-Check | ⚠️ warning | **BLOCKING** if discrepancies found |
| Platform Constraint FR Verification | ⚠️ warning | **BLOCKING** if constraint uncovered by FR |
| Edge Case Coverage | ⚠️ warning | **BLOCKING** with acknowledge option |
| Multi-Provider API Detection | ⚠️ warning | **BLOCKING** if provider lacks SC |
| Runtime Default Coverage | ⚠️ warning | **BLOCKING** for layout defaults, ⚠️ for others |
| Build-Time Plugin FR Check | *didn't exist* | NEW — detects build-time plugins in source, warns if no FR |
| Pre-ReviewApproval Validation gate | *didn't exist* | NEW — verifies all blockers resolved before offering "Approve" |

### Changes — plan.md

| Check | Before | After |
|-------|--------|-------|
| Interaction Chains missing (UI Feature) | ⚠️ warning | **BLOCKING** — must add before approval |
| Integration Contracts missing (Enablement Chain) | ⚠️ warning | **BLOCKING** — must add before approval |
| Pattern Constraints missing | prose "MUST add" | **BLOCKING** — explicitly enforced |
| API Compatibility Matrix missing (multi-provider) | ⚠️ warning | **BLOCKING** — must add before approval |
| Pre-ReviewApproval Validation gate | *didn't exist* | NEW — 5-check table before offering "Approve" |
| Pattern Constraints table | 5 runtime-only rows | +3 build-time rows (plugin registration, chain ordering, codegen) |
| Rebuild Target mapping | No completeness check | +completeness check (>30% unmapped = warning) + build config verification |

### Changes — tasks.md

| Check | Before | After |
|-------|--------|-------|
| Demo tasks missing (Demo-Ready active) | ⚠️ warning | **BLOCKING** if constitution § VI active |
| Integration wiring missing (cross-boundary) | ⚠️ warning | **BLOCKING** if cross-boundary flow detected |
| Source complexity parity (rebuild) | Info only | **BLOCKING** if task count < 70% of estimate |
| Pattern Audit keywords | React-specific hardcoded | Framework-agnostic + framework-specific terms from Pattern Constraints |
| IPC detection keywords | Electron only | +Tauri keywords |
| Pre-ReviewApproval Validation gate | *didn't exist* | NEW — 6-check table before offering "Approve" |

---

## [2026-03-16] SKF-023: CSS rendering verification — build passes but UI is unstyled

### SKF-023: CSS framework misconfiguration invisible to build/TS/smoke gates (Critical)

Tailwind CSS 4 utility classes were not being generated because `@tailwindcss/vite` plugin was missing from the renderer build config. Build passed (no errors), TypeScript passed (CSS classes are strings), smoke launch passed (app didn't crash), verify Phase 1 passed — but the UI was completely unstyled. General problem: CSS frameworks that generate classes at build time can silently fail without any gate detecting it.

| Choice | Rationale |
|--------|-----------|
| CSS Build Pipeline Verification in implement B-3 | Catches misconfiguration at the source — before code is written against broken CSS |
| Smoke Launch snapshot MANDATORY for GUI | Previous rule said "if Playwright available" — changed to MANDATORY with layout structure check |
| CSS rendering check in verify Phase 1 (item 5) | Build gate alone cannot catch CSS-generates-but-doesn't-apply; need plugin registration + runtime spot check |
| CSS Toolchain row in Foundation Gate | Detect missing CSS plugin before any Feature starts |

**Files**: `injection/implement.md` (CSS Build Pipeline Verification), `pipeline.md` (Smoke Launch step 3 + Foundation Gate CSS Toolchain), `verify-phases.md` (Phase 1 item 5 — CSS rendering check)

---

## [2026-03-16] SKF-022: Inline Execution as default for speckit-* commands + Case Study README enhancement

### SKF-022: Execute+Review continuity structurally impossible with Skill tool (Critical)

The Skill tool creates a response boundary — when speckit-* completes via `Skill(speckit-plan)`, the skill's completion message becomes the final response. smart-sdd cannot continue to Review in the same turn, violating the Execute+Review Continuity Rule. Observed 3 times during F002 pipeline (specify, plan).

| Choice | Rationale |
|--------|-----------|
| Inline Execution as default (not Skill tool) | Skill tool's response boundary is a structural limitation, not a usage error. Inline execution keeps everything in smart-sdd's context |
| Removed "Skill Invocation Fallback" framing | Inline is now primary, not fallback. Renamed to "Inline Execution Protocol" |
| Added "Why not the Skill tool?" explanation | Prevents future contributors from reverting to Skill tool usage |

**Files**: `pipeline.md` (Step 3 Execute — replaced Skill tool invocation with Inline Execution Protocol), `CLAUDE.md` (Do NOT Modify #8 — added Violation Pattern C and Skill tool prohibition)

### README Enhancement: Case Study skill description

Added case-study as a third bullet in the top-level skill introduction (both README.md and README.ko.md). Previously only reverse-spec and smart-sdd were introduced at the top level, making case-study less discoverable.

---

## [2026-03-16] SKF-020 + SKF-021: Console noise filter + Feature number conflict prevention

### SKF-020: Playwright evaluate() Console noise filter (Minor)

Playwright's `evaluate()` triggers Chromium's anti-self-XSS warning in Electron DevTools Console. While it doesn't block execution, verify Phase 3's console error scan could misclassify it as a runtime error.

| Choice | Rationale |
|--------|-----------|
| Filter list in verify-phases.md (2 locations) | Console scan runs at Phase 3 Step 3a and Phase 3 Step 6 (demo --ci browser scan) |
| Explicit Electron note in runtime-verification.md | Central reference for all Electron-specific Playwright behaviors |
| Pattern-based filter (not exact string match) | Chromium may change exact warning text across versions |

**Files**: `verify-phases.md` (Phase 3 Step 3a console filter, Step 6 browser console filter), `runtime-verification.md` (§ Electron Library Mode)

### SKF-021: speckit-specify auto-numbering conflict with pre-created branch (Major)

smart-sdd creates Feature branch `{NNN}-{name}` in pre-flight (Step 0), then `speckit-specify` runs `create-new-feature.sh` which auto-detects the next available number. Since the branch already exists, the script assigns `{NNN+1}` — causing branch/directory number mismatch.

| Choice | Rationale |
|--------|-----------|
| Pass explicit `{NNN}-{name}` to speckit-specify (Option A from SKF) | smart-sdd controls Feature IDs; explicit number is safer than auto-numbering |
| Mismatch recovery instruction (rename + branch delete) | Graceful handling if conflict still occurs |
| Added to branch-management.md as cross-reference | Branch lifecycle docs should document this caveat |

**Files**: `pipeline.md` (§ Feature Number Conflict Prevention), `branch-management.md` (§ Pre-Flight auto-numbering warning)

---

## [2026-03-15] Tech-stack agnostic generalization + SKF-019 native dependency check

Comprehensive review identified 40+ points across pipeline.md, implement.md, and verify-phases.md where general rules were locked to specific technologies (JS/TS, React, Electron, Tailwind, npm). Instead of adding multi-language examples everywhere (which would bloat files), applied a lightweight strategy:

### Approach
1. **General rules describe intent** — "verify theme system is active", not "inspect `document.documentElement` computed styles"
2. **Tech-specific code blocks get explicit labels** — "Example (Tailwind CSS):", "Example (Electron/Node.js):"
3. **Adaptation notes at section entry points** — "Adapt file extensions and patterns to the project's tech stack"
4. **Single-incident references removed** — F007 bug numbers → generic pattern descriptions; SKF-013/014 ref → removed

### Files changed

**pipeline.md** (Foundation Gate):
- Checklist: CSS Theme → Theme/Styling, `getState()` → generic state init, IPC Bridge (Electron) → IPC / Cross-boundary
- Test code block: labeled "Example (Web/Electron + Playwright)" with "adapt to your stack" note
- Test runner: `@playwright/test` in devDependencies → project's test runner
- Result display + foundation-affecting files: generalized terminology
- Gate 2: `DOM hierarchy, flex direction` → `component hierarchy, layout direction, sizing strategy`
- Removed `(ref: SKF-013/014 incident)` from Cross-Stage Validation Gates
- Parallel agent shared files: `IPC registry` → `service registry`

**implement.md**:
- Added Step 1b: Native/compiled dependency compatibility check (SKF-019)
- Pattern Compliance Scan: moved "illustrative" disclaimer before table
- E2E Seam Check / Report: labeled as "Example (Electron/Node.js)"
- Hover advice: React `useState` + Tailwind `group-hover` → framework-agnostic principle
- CSS Value Map: labeled "Example (Tailwind CSS)"
- IPC Defense: generalized from JS/TS operators to defensive access patterns
- SDK trust table: prefixed examples with "e.g.,"
- Dependency Pre-flight display: generic placeholders instead of React packages
- UI component library check: generic library paths/commands
- Playwright dependency check / install: language-agnostic

**verify-phases.md** (16 edits):
- F007 references (2 locations) → generic pattern descriptions
- Source Modification Gate / Minor Fix Accumulator / Module boundary: generic names
- i18n detection, service file detection, import graph: tech-stack adaptation notes
- Lifecycle cleanup hooks: multi-framework examples
- UX Contract report: framework-agnostic language
- Browser console errors: framework-specific loop warnings
- Cross-module contract / Feature Contract reports: labeled as examples
- Preload bridge: added "(Electron only)" scope
- Dev Mode detection: multi-stack config reference
- Runtime error patterns: JS/Node.js-centric note + other language examples
- Source app start command: generic detection

| Choice | Rationale |
|--------|-----------|
| Adaptation notes (not multi-language rewrite) | Lightweight, maintainable, doesn't bloat files |
| Labels on existing examples (not replacement) | Existing examples are valuable for the most common case (JS/TS) |
| SKF-019 as generic Step 1b (not Electron-specific) | Same pattern applies to any native/compiled dependency |

---

## [2026-03-15] Smoke Launch failure escalation + implement completion gate

Reinforced the Post-Implement Smoke Launch section in pipeline.md. Previously, step 6 ("On failure: Fix the issue immediately") was too vague — the agent could mark implement ✅ and frame the failure as "verify is blocked," which is incorrect. Smoke Launch is part of implement, so its failure means implement is NOT complete.

### Changes

**pipeline.md — Post-Implement Smoke Launch**:
- Added bold warning: "implement is NOT complete until Smoke Launch passes"
- Replaced step 6 with 3-level Auto-Fix Escalation (Code Fix → Environment Fix → HARD STOP)
- Added `SMOKE-LAUNCH-DEGRADED` status for "proceed with build-only" cases (distinct from ✅)
- Added explicit Wrong/Right example to prevent the observed failure pattern

**implement.md — Auto-Fix Loop**:
- Added native/compiled dependency failure as a loop break condition with platform-appropriate rebuild attempt before breaking

| Choice | Rationale |
|--------|-----------|
| 3-level escalation (not just "fix immediately") | Agent needs clear guidance on what to try (code fix → env fix → user) before asking user |
| `⚠️ SMOKE-LAUNCH-DEGRADED` status (not ✅) | implement ✅ with known launch failure is misleading — status must reflect reality |
| Wrong/Right inline example | Agent tends to frame failures as "next step blocked" instead of "current step incomplete" |

---

## [2026-03-15] Foundation Verification Gate — T0 Feature skip condition

Added skip condition to Step 3b (Foundation Verification Gate): when the current Feature IS a T0 (Foundation) Feature, skip the Gate. Rationale: the Gate validates Foundation systems before building Features on top of them, but when the Feature being processed IS the Foundation itself (e.g., F001 app-shell), there is nothing to verify yet. Previously only "greenfield" was listed as a skip condition, which missed the rebuild + clean restart + T0 Feature case.

| Choice | Rationale |
|--------|-----------|
| Skip when current Feature is T0 | Cannot verify Foundation before building it — logical contradiction |
| Keep existing skip conditions (greenfield, already-verified) | Still valid for their respective cases |

**File**: `smart-sdd/commands/pipeline.md` Step 3b Skip-for line

---

## [2026-03-15] MANDATORY RULE 3: spec-kit Output Suppression + Review Gate

Added MANDATORY RULE 3 to smart-sdd SKILL.md to prevent the agent from showing spec-kit's raw output and skipping the Review HARD STOP. This is the most persistent failure pattern in the pipeline.

### Changes

**smart-sdd/SKILL.md**:
- Added MANDATORY RULE 3 with 5-step protocol: SUPPRESS → READ → DISPLAY → ASK → FALLBACK
- Documented two violation patterns: Pattern A (Stop) and Pattern B (Skip)

**pipeline.md Phase 0-3**:
- Added inline ⚠️ MANDATORY RULE 3 REMINDER before the Execute+Review steps
- Added step 7 (fallback message) to the Phase 0-3 step list
- Strengthened step 2 wording: "SUPPRESS" instead of "ignore"
- Added MANDATORY RULE 3 cross-reference to Common Protocol suppression rule

**CLAUDE.md**:
- Rule #8: Added two violation patterns (A: Stop, B: Skip) with descriptions and SKILL.md cross-reference
- Rule #9: Added clarification that skipping HARD STOP to "continue" is a violation, not continuity
- Review Protocol #5: Added HARD STOP + Execute+Review pattern verification as a review step

### Rationale
During Angdu Studio pipeline run, `speckit-constitution` completed and the agent showed "Constitution finalized" + "Suggested commit" (raw spec-kit output), then jumped directly to "F001-app-shell pipeline" without reading the artifact, displaying Review, or calling AskUserQuestion. Root cause: instructions were only in pipeline.md (loaded on-demand), not in SKILL.md (always loaded). The agent's default behavior is to treat Skill tool return values as "results to show the user", overriding the buried suppression instructions.

---

## [2026-03-15] reverse-spec Post-Run Bug Fixes (case-study-log path + Demo Group SBI)

Fixed two bugs discovered during the second Cherry Studio reverse-spec run.

### Changes

**case-study-log.md Path Bug**:
- Phase 0 Step 4 wrote `case-study-log.md` to `{target-directory}` (the source code being analyzed) instead of CWD (the project being built)
- Fixed all references to `./case-study-log.md (CWD root)` with explicit path warning block
- Updated all 5 milestone recording references across Phase 0/3/4 via replace_all

**Demo Group SBI Coverage Ranges**:
- Despite MANDATORY + BLOCKING instruction in SBI Numbering Verification step 5, the agent still wrote "TBD" for SBI Coverage in roadmap.md Demo Groups
- Root cause: instruction was buried as step 5 in a 5-step verification list — agent treated the whole block as "numbering verification" and skipped the unrelated SBI range calculation
- Fix: Separated Demo Group SBI into its own standalone `#### Demo Group SBI Coverage Ranges (MANDATORY — BLOCKING)` section with:
  - Explicit 4-step calculation algorithm
  - Display format showing Feature→range mapping
  - Warning: "Do NOT write TBD or defer this calculation"
  - Cross-reference to roadmap.md Phase 4-1 Demo Groups section

### Rationale
Both bugs have the same root cause pattern: instructions that are technically present but not structurally prominent enough for the agent to follow. The case-study-log bug used `{target-directory}` which is ambiguous (target of the build vs target of the analysis). The Demo Group SBI bug buried a distinct calculation inside an unrelated verification checklist.

---

## [2026-03-15] reverse-spec Completeness Improvements (SKF-018 + Cherry Studio Findings)

Strengthened analyze.md to close 7 gaps found during Cherry Studio reverse-spec run. Target: raise output completeness from ~60% to near 100%.

### Changes

**Phase 3-2 — Dependency Graph (SKF-018)**:
- Added "Dependency Interpretation Rules (MANDATORY)" block with 3 rules
- Rule 1: App Shell/Bootstrap always RG-1 first with zero dependencies
- Rule 2: Foundation Feature sanity check with AskUserQuestion confirmation
- Rule 3: "Could I write A without B's code?" test for each dependency edge
- Post-sort validation step added to Release Group Determination

**Phase 3-1e — Archetype Evidence Extraction**:
- Mandated evidence extraction format (Observed Trait + Implication) per A1 principle during archetype detection
- Principles without evidence recorded as "Not implemented in source" (not silently omitted)

**Phase 4-1 — Constitution-Seed Strengthening**:
- F7 Framework Philosophy: single-line suggestion → MANDATORY 4-step protocol with exact table format
- Archetype-Specific Principles: single-line mention → MANDATORY format spec prohibiting simple numbered lists

**Phase 4-2 — Pre-Context Completeness Gate**:
- Added "Per-Feature Pre-Context Generation Protocol (MANDATORY)" before existing verification
- Lists commonly skipped sections with explicit handling rules
- Added completeness score (14/14) and template cross-check

**Phase 2-7b — micro-interactions.md Generation Gate**:
- Added MANDATORY gate: file must be written even if no patterns found
- Existence verification before Phase 2-8

**Phase 4-1 — speckit-prompt.md**:
- Added MANDATORY keyword and all dynamic field names
- Post-generation placeholder verification

**Phase 1.5-5 — Visual Reference Manifest Verification**:
- Added post-capture manifest vs .png file list cross-check

**Phase 4-2 — Demo Group SBI Ranges**:
- Strengthened to MANDATORY + BLOCKING with read-back verification display

### Rationale
Cherry Studio output: SBI/Entity/API excellent, but F7 missing from constitution-seed, archetype principles without evidence, pre-context 30-40% filled, dependency graph confused runtime coupling with implementation ordering (SKF-018). Root cause across all issues: instructions used soft language without MANDATORY gates or format specifications.

---

## [2026-03-15] SKF-017: Electron CDP Connection Timing Guidance

Added Electron CDP 3-phase polling guidance to `reverse-spec/analyze.md` Phase 1.5-4, based on field experience with Cherry Studio (electron-vite).

### Changes
- **Step 1b table**: Added `REMOTE_DEBUGGING_PORT` env var as alternative for electron-vite 5.0+
- **Step 2**: Added "Electron CDP readiness — 3-phase polling" block: Port open → CDP HTTP API → Targets available, with expected timing (up to 120s total)
- **Warnings**: Documented that empty targets `[]` is normal during BrowserWindow creation, and standalone browser access to renderer URL fails due to missing Electron preload bridge

### Rationale
During Cherry Studio reverse-spec, CDP connection repeatedly failed or returned empty targets. Root cause: electron-vite has a ~45-60s multi-stage startup, and CDP targets only appear after BrowserWindow creation + renderer load. Without this guidance, the agent incorrectly concluded "CDP is not working" and wasted time with retries and alternative approaches.

---

## [2026-03-15] Case-Study Enhancement: Architecture Philosophy Integration

Enhanced the case-study skill to capture and communicate architecture philosophy (Archetype principles + Foundation F7 Philosophy) throughout the Case Study report. Transforms the report from a metrics-focused execution log into a philosophy-aware narrative that explains *why* architectural decisions were made.

### Changes

**Data Capture Layer** (Phase 1):
- `case-study-log-template.md`: Added `Archetype` and `Framework` header fields
- `recording-protocol.md`: Enhanced M1 (archetype signals, framework), M4 (archetype/F7 detection results), M5 (archetype/F7 adoption tracking), M6 (Philosophy Adherence subsection)

**Report Generation** (Phase 2):
- `generate.md`: Added Steps 3-11/3-12 (philosophy data extraction from constitution-seed.md and case-study-log.md)
- Section 1: Archetype/Framework in metadata + Key Metrics
- Section 4: Restructured into §4.1 Strategic Decisions, §4.2 Architecture Philosophy (principle tables with Constitution Status), §4.3 Principle-to-Decision Mapping
- Section 8: Added Architecture Philosophy Assessment (Principle Application Coverage, Principle Gaps, Module Feedback)

**Cross-Skill Triggers** (Phase 3):
- `reverse-spec/analyze.md`: case-study-log initialization populates Archetype/Framework defaults; Phase 1-2b updates Framework; Phase 3-1e updates Archetype
- `smart-sdd/pipeline.md`: M6 trigger includes Philosophy Adherence composition guidance
- `smart-sdd/adopt.md`: M6 trigger aligned with pipeline.md — added same Philosophy Adherence composition guidance

### Design Decisions
- 8-section report structure preserved (philosophy content added as subsections within §4 and §8, not new top-level sections)
- All philosophy sections are conditional — omitted when no data exists (backward compatible)
- No init command for case-study — log initialization handled by reverse-spec and smart-sdd

---

## [2026-03-15] Remove speckit-diff skill

Removed the `speckit-diff` skill entirely (3 files: SKILL.md, commands/diff.md, reference/integration-surface.md).

### Rationale
- **Extremely rare use case**: Only needed when spec-kit updates its internal structure — a rare event
- **Simpler alternative exists**: `gh` CLI + changelog review is faster and more reliable
- **Self-defeating maintenance**: `integration-surface.md` baseline requires manual updates when spec-kit changes — the tool doesn't fully automate what it promises
- **Cognitive overhead**: 3 skill files + install symlink + documentation references for a utility used perhaps once per quarter

### Impact
- 4 skills → 3 skills (reverse-spec, smart-sdd, case-study)
- install.sh/uninstall.sh unchanged (dynamic glob pattern)
- README.md/README.ko.md updated (Quick Start, Utilities, Installation, File Map)

---

## [2026-03-15] 4-Axis Domain Composition: Archetype modules + Foundation F7 Philosophy

Expanded the domain composition model from 3 axes (Interface × Concern × Scenario) to 4 axes (Interface × Concern × Archetype × Scenario) by introducing Archetype modules for application-domain philosophical principles (e.g., AI assistant's "Streaming-First", Public API's "Contract Stability"). Also added Foundation F7 Philosophy sections for framework-specific guiding principles (distinct from F0–F6 operational checklists).

### Motivation
- Domain-specific philosophy (e.g., "Streaming-First" for AI apps) was generated ad-hoc in constitution-seed without structured guidance
- Framework philosophy (e.g., Express's "Middleware Composition") was not distinguished from operational checklists
- The angdu-studio constitution-seed showed these principles emerge naturally — they needed a structured home

### Changes (24 files: 7 new, 17 modified)

**Schema & Core (4 files)**:
- `reverse-spec/domains/_schema.md` — Added Archetype module type, A0-A1 section schema, updated loading order to 4 items
- `smart-sdd/domains/_schema.md` — Added Archetype module type, A0-A4 section schema, updated loading order to 6 items
- `smart-sdd/domains/_resolver.md` — Added Step 2c (Resolve Archetype), updated worked example, A0 Aggregation
- `smart-sdd/reference/state-schema.md` — Added Archetype field (optional, default "none")

**Archetype Modules (6 new files)**:
- `reverse-spec/domains/archetypes/{ai-assistant,public-api,microservice}.md` — A0 signal keywords + A1 philosophy extraction
- `smart-sdd/domains/archetypes/{ai-assistant,public-api,microservice}.md` — Full A0-A4: signal keywords, philosophy principles, SC extensions, elaboration probes, constitution injection

**Foundation F7 (3 files)**:
- `foundations/_foundation-core.md` — Added F7 schema definition, updated F6 table
- `foundations/electron.md` — F7: Process Crash Isolation, Memory Budget Discipline, Native Feel, Secure by Default, Auto-Update as First-Class
- `foundations/express.md` — F7: Middleware Composition, Minimal Core, Error-First Conventions, Stateless Requests

**Pipeline Integration (5 files)**:
- `analyze.md` — Phase 3-1e archetype detection, Phase 4-1 archetype/F7 principles in constitution-seed
- `constitution-seed-template.md` — Archetype-Specific Principles + Framework Philosophy sections
- `init.md` — Inferred Archetype in Proposal output
- `pipeline.md` — Phase 0-3b archetype detection from constitution-seed
- `injection/constitution.md` — Archetype display in injection/checkpoint

**Documentation (4 files)**:
- `ARCHITECTURE-EXTENSIBILITY.md` (NEW) — Detailed extensibility guide: module system, adding modules, sophistication levels
- `CLAUDE.md` — Documentation Writing Guidelines section
- `README.md` / `README.ko.md` — 4-Axis rename, archetype docs, F7 mention, file map updates

### Design Decisions
- Archetype field is optional (default "none") — full backward compatibility
- A-prefix section numbering (A0-A4) avoids collision with R1-R6 and S0-S8
- F7 is optional per Foundation — only add when framework has strong opinionated principles
- 3 initial archetypes (ai-assistant, public-api, microservice) — e-commerce excluded due to region-specific patterns

---

## [2026-03-14] Reverse-spec output quality enforcement: BLOCKING gates + completeness verification

Second-round quality analysis of cherry-studio reverse-spec output (post-Fix 1-4). Fix 1-3 fully reflected; Fix 4 (Runtime Default Verification) still skipped despite MANDATORY keyword. Additionally found pre-context sections wholesale omitted and DG SBI ranges not persisted.

### Root Causes Identified (4 issues from 2nd analysis)
1. MANDATORY keyword alone insufficient — agent skips Step 5 because no downstream check verifies execution (RC-1)
2. Pre-context content requirements buried in bullet list without post-generation verification (RC-2/RC-4)
3. DG SBI ranges "Update" ambiguous — agent displayed but didn't write to roadmap.md (RC-3)

### Fixes Applied (all in analyze.md)
- **RC-1 — Step 6 BLOCKING gate**: Added pre-flight check before proceeding to Phase 2. If Playwright was used, `runtime-exploration.md` MUST contain `## Runtime Default Verification` section. Missing → re-execute Step 5. This is a BLOCKING gate, not just a MANDATORY request
- **RC-3 — DG SBI ranges explicit write**: Changed "Update Demo Group SBI ranges" to explicitly require writing `| **SBI Coverage** | B###–B### |` rows into roadmap.md. Emphasized "This is a file modification, not just a display"
- **RC-2/RC-4 — Pre-context Completeness Verification (MANDATORY, BLOCKING)**: Added 14-section checklist verification after SBI Numbering Verification. Each pre-context must contain all required sections from template. Missing sections → fix before proceeding to Phase 4-3. Includes Foundation Decisions/Dependencies, Static Resources, Environment Variables, Feature Contracts, and Runtime Exploration Results

### Design Decision
- Pattern: MANDATORY keyword alone is insufficient for agent compliance. BLOCKING **gates** (downstream verification that checks the output file) are needed to enforce execution. Applied same pattern as SBI Numbering Verification (which worked) to Runtime Default Verification and Pre-context Completeness

### Files Changed (1 file)
- `reverse-spec/commands/analyze.md` — 3 fixes across Phase 1.5 Step 6, Phase 4-2 SBI Verification Step 5, Phase 4-2 Pre-context Completeness Verification

---

## [2026-03-14] Reverse-spec quality prevention: SBI integrity + coverage verification

Quality analysis of cherry-studio reverse-spec output revealed 7 issues traceable to 5 root causes in analyze.md rules. Fixed the rules to prevent recurrence.

### Root Causes Identified (from output quality analysis)
1. SBI B### numbering collisions across Features (no post-verification step existed)
2. Mixed SBI formats — heading vs table (format not enforced inline)
3. Coverage-baseline total mismatch (no cross-verification against actual SBI count)
4. Runtime Default Verification skipped despite Playwright availability (not MANDATORY)
5. DG SBI ranges manually calculated (error-prone)

### Fixes Applied (all in analyze.md)
- **Fix 1 — SBI Numbering Verification (MANDATORY + BLOCKING)**: Added post-generation verification step in Phase 4-2 — builds global SBI map, checks contiguity/uniqueness/total, auto-updates DG SBI ranges. Blocks Phase 4-3 if any check fails
- **Fix 2 — SBI Table Format (MANDATORY)**: Inlined exact table format from pre-context-template.md into B### ID Assignment Rules. Added rules 3 (contiguous) and 6 (global-only) with explicit INVALID examples
- **Fix 3 — Coverage-baseline Cross-Verification**: Added MANDATORY verification in Phase 4-3 Step 4 — Surface Metrics SBI total must equal SBI Numbering Verification authoritative total. Per-Feature ranges copied directly from verification output
- **Fix 4 — Runtime Default Verification MANDATORY**: Changed from optional ("if Playwright was available") to MANDATORY when Playwright was used in Steps 1-4. Added required recording section in runtime-exploration.md to make execution auditable

### Files Changed (1 file)
- `reverse-spec/commands/analyze.md` — 4 fixes across Phase 1.5 Step 5, Phase 4-2, Phase 4-3 Step 4

---

## [2026-03-14] Flow Review: context-injection-rules.md reachability fix

Post-SKF batch (SKF-010~016) full project flow verification following CLAUDE.md Review Protocol (4-step: flow consistency → unused parts → commonization → over-fragmentation).

### Review Results
- **Step 1 (Flow Consistency)**: ALL PASS — all cross-references valid
- **Step 2 (Unused Parts)**: 1 ISSUE found — `context-injection-rules.md` not explicitly required reading in pipeline.md Step 1 Assemble. SKF-012's Dependency Stub Resolution Injection scanning protocol was only reachable if agent happened to read the shared file
- **Step 3 (Commonization)**: PASS — no new opportunities
- **Step 4 (Over-fragmentation)**: PASS — Demo-Ready (8 files) follows inline repetition exception, Dependency Stubs (7 files) has dual SSOT (format in implement.md, injection protocol in context-injection-rules.md), Interaction Surface (3 files) properly SSOT'd

### Fix Applied
- `pipeline.md` Step 1 Assemble: Explicitly requires reading `context-injection-rules.md` alongside per-command `injection/{command}.md` files. Added "both MUST be read" with rationale explaining per-command vs shared pattern split.

### Files Changed (1 file)
- `smart-sdd/commands/pipeline.md` — Step 1 Assemble explicit context-injection-rules.md reading requirement

---

## [2026-03-14] SKF-015 + SKF-016: Cross-Stage Validation Gates + Interaction Surface Inventory

SKF-015: Structural analysis of SKF-001~014 patterns revealing the pipeline's single-direction trust model as root cause. SKF-016: The Interaction Surface Preservation rule (SKF-009) lacked a concrete artifact for agents to reference.

### SKF-015: Cross-Stage Validation Gates
- **Problem**: Pipeline stages trust previous output without independent re-validation. 11 of 14 SKF items traced back to this trust model failure
- **Fix**: Added `## Cross-Stage Validation Gates (rebuild + GUI)` section to `pipeline.md` — 3 gates as circuit breakers:
  - Gate 1 (specify entry): Runtime default re-verification
  - Gate 2 (implement entry): Interaction Surface Inventory + layout structure analysis
  - Gate 3 (verify Phase 3e): Source app comparison MANDATORY
- **Design decision**: Consolidation section with cross-references, not rule duplication. Individual rules already exist in SKF-009/010/013/014 — this section frames them as a unified pattern

### SKF-016: Interaction Surface Inventory
- **Problem**: SKF-009's "enumerate surfaces before modifying" rule relied on ad-hoc inspection. Agent had no concrete checklist of what surfaces existed, leading to repeated omissions (drag region lost twice)
- **Fix**: Full lifecycle Interaction Surface Inventory:
  1. **Generate** (`injection/implement.md` Post-Step Update #3): Create `specs/{NNN-feature}/interaction-surfaces.md` with Surface, Type, Component:Line, Size, Criticality
  2. **Inject** (`injection/plan.md`): Include inventory in plan architecture input when Feature modifies shared components
  3. **Preserve** (`injection/implement.md` § Interaction Surface Preservation): Read inventory as authoritative source before modifying components
  4. **Verify** (`injection/verify.md` Post-Step Update #5): Playwright runtime verification of each Critical/High surface. Missing Critical = blocking failure

### Files Changed (4 skill files + 1 feedback file)
- `smart-sdd/commands/pipeline.md` — Cross-Stage Validation Gates section
- `smart-sdd/reference/injection/implement.md` — Interaction Surface Inventory generation + Preservation reads inventory
- `smart-sdd/reference/injection/plan.md` — Inject inventory as architectural input
- `smart-sdd/reference/injection/verify.md` — Interaction Surface Inventory Verification step
- `angdu-studio/skill-feedback.md` — SKF-015, SKF-016 marked as ✅ Reflected

---

## [2026-03-14] SKF-014: Pipeline Error Propagation Prevention — Source App Comparison MANDATORY for rebuild+GUI

Skill Feedback from angdu-studio F002-navigation deep analysis. SKF-013 root cause analysis revealed the wrong default propagated through all 6 pipeline stages uncaught. Two additional fixes beyond SKF-013.

### Root Cause: No independent verification checkpoint in the pipeline
- **Problem**: Pipeline operates on "trust previous stage output" principle. Wrong `navbarPosition='left'` from reverse-spec propagated through specify→plan→tasks→implement→verify. No stage independently verified against the running source app
- **Fix 1** (already in SKF-013): reverse-spec Phase 1.5 Step 5 Runtime Default Verification
- **Fix 2** (`verify-phases.md` Step 3e): Source App Comparison upgraded from "⚠️ NOT blocking" to "BLOCKING for rebuild+GUI". Layout structure deviations are Critical severity. Agent must attempt to start source app, not just ask user
- **Fix 3** (`pipeline.md`): Error Propagation Warning at pipeline top — explicit statement that early-stage errors cascade, and settings/modes/defaults require runtime verification

### Design decision: Two-checkpoint strategy
- **Checkpoint 1 (prevention)**: reverse-spec Phase 1.5 — catch wrong defaults before they enter the pipeline
- **Checkpoint 2 (detection)**: verify Phase 3e — catch any remaining mismatches after implementation
- Both checkpoints = makes 6-stage error propagation impossible

### Files Changed (2 skill files + 1 feedback file)
- `smart-sdd/commands/verify-phases.md` — Step 3e: MANDATORY gate for rebuild+GUI, BLOCKING result for layout deviations
- `smart-sdd/commands/pipeline.md` — Error Propagation Warning
- `angdu-studio/skill-feedback.md` — SKF-014 marked as ✅ Reflected

---

## [2026-03-14] SKF-013: Runtime Default Verification — prevent code analysis vs runtime mismatch

Skill Feedback from angdu-studio F002-navigation. Critical severity — `navbarPosition` code analysis said `'left'` but runtime default was `'top'`, causing entire Feature to be built with wrong layout.

### Root Cause: No runtime verification of settings defaults in reverse-spec
- **Problem**: SBI extraction relied on static code analysis. A `'left'` constant was found in code, but the app's actual default mode at runtime was `'top'` (tab mode). This propagated through specify → plan → tasks → implement, resulting in a completely wrong layout
- **Fix 1** (`reverse-spec/analyze.md` Phase 1.5 Step 5): "Runtime Default Verification" — after visual reference capture, identify settings-related SBI entries, verify against actual DOM attributes/app state via Playwright, correct any mismatches with runtime values taking precedence
- **Fix 2** (`smart-sdd/injection/specify.md`): Added "Runtime Default Coverage Check" as verification step #5, plus "Runtime-Verified Defaults" block in Checkpoint Display. For rebuild mode Features with settings/modes, cross-checks spec FR/SC against runtime-exploration.md values, warns on mismatch

### Design decisions
- **Runtime values take precedence**: When code analysis and runtime differ, runtime wins
- **Non-blocking warning**: Mismatch appears in Review Display but doesn't block pipeline
- **Graceful degradation**: If Playwright unavailable, skip with informational message (code analysis used as fallback)
- **Reverse-spec + smart-sdd both modified**: Prevention (reverse-spec) + detection (smart-sdd specify)

### Files Changed (2 skill files + 1 feedback file)
- `reverse-spec/commands/analyze.md` — Phase 1.5 Step 5: Runtime Default Verification
- `smart-sdd/reference/injection/specify.md` — Runtime Default Coverage Check + Checkpoint Display block
- `angdu-studio/skill-feedback.md` — SKF-013 marked as ✅ Reflected

---

## [2026-03-14] SKF-012: Dependency Stub Registry — cross-Feature stub tracking mechanism

Skill Feedback from angdu-studio F002-navigation. Stubs/placeholders created due to future Feature dependencies had no tracking or auto-injection mechanism — only TODO comments in code.

### Root Cause: No structured tracking for cross-Feature stub dependencies
- **Problem**: F002 created multiple stubs (hardcoded sidebar icons → F003, empty Pinned Apps → F008, etc.) tracked only by inline TODO comments. When F003/F008 enter the pipeline, there's no mechanism to surface these stubs as tasks to resolve
- **Fix**: Full lifecycle Dependency Stub Registry:
  1. **Generate** (`injection/implement.md` § Post-Step Update #2): After implement, scan for stubs referencing future FIDs → generate `specs/{NNN-feature}/stubs.md`
  2. **Shared injection rule** (`context-injection-rules.md` § Dependency Stub Resolution Injection): When Feature N enters pipeline, scan all preceding stubs.md for rows targeting FID=N
  3. **Inject into specify/plan/tasks**: Show stubs at checkpoint, include in plan architecture input, warn if no resolution tasks generated
  4. **Verify completeness** (`injection/verify.md` § Post-Step Update #4): Check if preceding stubs were resolved after this Feature completes

### Design decisions
- **Non-blocking at verify**: Unresolved stubs produce a warning, not a verify failure
- **Single Source of Truth**: stubs.md format in `injection/implement.md`, injection pattern in `context-injection-rules.md`
- **No stubs = no file**: stubs.md only generated when stubs exist

### Files Changed (7 skill files + 1 feedback file)
- `smart-sdd/reference/injection/implement.md` — Post-Step Update #2: Dependency Stub Registry generation
- `smart-sdd/commands/pipeline.md` — Brief mention after implement completion
- `smart-sdd/reference/context-injection-rules.md` — Dependency Stub Resolution Injection shared pattern
- `smart-sdd/reference/injection/specify.md` — Checkpoint Display: stubs block
- `smart-sdd/reference/injection/plan.md` — Injected Content: stubs bullet
- `smart-sdd/reference/injection/tasks.md` — Read Targets + task injection check + display format
- `smart-sdd/reference/injection/verify.md` — Post-Step Update #4: Stub Resolution Completeness Check
- `angdu-studio/skill-feedback.md` — SKF-012 marked as ✅ Reflected

---

## [2026-03-14] SKF-010 + SKF-011: Layout Structure Analysis + GUI Mandatory Playwright Gate

Skill Feedback from angdu-studio F002-navigation. Two related issues: (1) implement phase rebuilt layout without matching source app code-level structure, (2) verify phase skipped Playwright runtime verification despite GUI Feature.

### Root Cause 1: No code-level layout structure analysis (SKF-010)
- **Problem**: Visual references (screenshots) can look identical between different DOM structures (flex-row vs flex-column). The existing "Source App Visual Reference" rule focused on pixel-level screenshots but had no code-level layout analysis step
- **Fix**: Added "Layout Structure Analysis" subsection to `injection/implement.md` — before first UI task, read source app's root layout code and document: root container direction, container nesting hierarchy, height/width strategy, platform-specific offsets, persistent element placement
- **Placement**: Between "Dual-App Port Convention" and "Visual References Fallback" (one-time analysis, runs before any UI task)

### Root Cause 2: Playwright verification skippable for GUI Features (SKF-011)
- **Problem**: Phase 3 Step 3 said "MANDATORY — do NOT skip" but agent still skipped it for F002. The rule was strong text but lacked an enforceable gate mechanism. Result: layout structure differences, drag region omission, etc. not caught until user manually tested
- **Fix 1**: Added "🚫 GUI MANDATORY PLAYWRIGHT GATE" blockquote at Phase 3 entry in `verify-phases.md` — 4-point gate: cannot skip, must attempt install, SC matrix must be displayed, post-gate announcement required
- **Fix 2**: Added "GUI Feature empty-list guard" to Step 0 SC Verification Matrix — if `gui` is active but zero `cdp-auto` rows exist, agent must explain why (almost always a classification error)
- **Fix 3**: Added emphasis in `gui.md` S6 — "Static checks alone are NEVER sufficient for GUI Features. Playwright SC verification is equal in priority to build/lint/tsc"

### Cross-reference check
- `verify-phases.md` Pre-flight (Phase 1): Already checks Playwright availability — the new gate enforces that availability translates to actual execution
- `gui.md` S8 Runtime Verification Strategy: Already references Playwright — the new S6 emphasis adds the "mandatory, not optional" framing
- `injection/implement.md` Visual References Fallback (SKF-008): Screenshot-based. The new Layout Structure Analysis is code-based — complementary, not overlapping

### Files Changed (3 skill files + 1 feedback file)
- `smart-sdd/reference/injection/implement.md` — Layout Structure Analysis subsection
- `smart-sdd/commands/verify-phases.md` — GUI MANDATORY PLAYWRIGHT GATE + SC matrix empty-list guard
- `smart-sdd/domains/interfaces/gui.md` — S6 Playwright mandatory emphasis
- `angdu-studio/skill-feedback.md` — SKF-010, SKF-011 marked as ✅ Reflected

---

## [2026-03-14] SKF-008 + SKF-009: Visual Reference Fallback + Interaction Surface Preservation

Skill Feedback from angdu-studio F002-navigation. Two related issues: (1) visual references not consulted during implement, (2) F001's interaction surfaces removed when F002 replaced App.tsx.

### Root Cause 1: Visual References Fallback missing (SKF-008)
- **Problem**: Source App Visual Reference section had no fallback for when the source app can't start. `visual-references/` directory with screenshots existed but was not consulted
- **Fix**: Added "Visual References Fallback" subsection — when source app can't start but `visual-references/` exists, agent MUST read and reference screenshots. Made the last Skip Condition point to the fallback instead of "continue code-only"
- **Fix**: Added Checkpoint notification line: `📂 Visual References: [N] screenshots available`

### Root Cause 2: No Interaction Surface Preservation rule (SKF-009)
- **Problem**: F002 replaced F001's App.tsx (Titlebar with drag region, window controls, theme toggle) with a Router layout that lacked these surfaces. No rule existed to check for surface preservation
- **Fix**: Added "Interaction Surface Preservation" rule in B-3 Bug Prevention Checks, between Cross-Feature Integration and UI Interaction Surface Audit
- **Content**: enumerate surfaces before modifying → verify preservation after → report removals → fail runtime check if critical surface missing
- **Fix**: Added Checkpoint notification line: `⚠️ Interaction Surface Check: [component] from [previous FID] will be modified`

### Cross-reference check
- `verify-phases.md` Step 3b (Visual Fidelity Check): Already covers visual reference comparison at verify time — no change needed. The new fallback addresses the implement-time gap
- `verify-phases.md` Step 3c (Navigation Transition Sanity): Post-verify detection. The new Interaction Surface Preservation rule is a pre-implement prevention — complementary, not overlapping

### Files Changed (1 skill file + 1 feedback file)
- `smart-sdd/reference/injection/implement.md` — Visual References Fallback, Checkpoint notifications, Interaction Surface Preservation
- `angdu-studio/skill-feedback.md` — SKF-008, SKF-009 marked as ✅ Reflected

---

## [2026-03-14] SKF-007: Demo-Ready Delivery condition expansion

Skill Feedback from angdu-studio F002-navigation. Demo scripts were not generated because the condition only checked constitution, missing the established demo pattern from F001.

### Root Cause: Constitution-only gating ignores project demo history
- **Problem**: Demo-Ready Delivery was gated exclusively by "VI. Demo-Ready Delivery in constitution". If a project had no such constitution principle but already had `demos/F001-*.sh` from a previous Feature, the agent skipped demo creation for subsequent Features.
- **Fix**: Expanded the condition across 4 files to: "constitution includes Demo-Ready Delivery **OR** `demos/` directory already contains Feature demo scripts from previous pipeline runs"
- **Rationale**: If a project has established a demo pattern (regardless of constitution), maintaining that pattern is expected behavior. This avoids user surprise when demos suddenly stop appearing.

### Files Changed (4 skill files + 1 feedback file)
- `smart-sdd/reference/injection/implement.md` — L236: section header + L238: gating condition expanded
- `smart-sdd/reference/injection/tasks.md` — L37: task injection check condition expanded
- `smart-sdd/commands/verify-phases.md` — L909-915: Phase 3 header + skip condition expanded with inline definition
- `smart-sdd/reference/injection/verify.md` — L79 + L167: checkpoint/review display condition expanded
- `angdu-studio/skill-feedback.md` — SKF-007 marked as ✅ Reflected

### Cross-reference check
- `pipeline.md` L667: flow summary mentions "Demo-Ready Delivery" as a step name (not a gated condition) — no change needed
- `injection/implement.md` L611,637,665,672: use shorthand "if Demo-Ready Delivery active" — automatically covered by the expanded primary definition at L236
- `injection/tasks.md` L267: uses shorthand "if Demo-Ready Delivery active" — automatically covered
- `injection/verify.md` L79,167: updated to "(constitution OR existing demos/)" shorthand

---

## [2026-03-13] Full Project Review + Integration Demo Trigger Fix

Full file analysis per CLAUDE.md Review Protocol (4-step: flow consistency, unused parts, commonization, over-fragmentation). Also verified SKF-001~006 reflection quality and evaluated 2 minor issues.

### Review Results
- **4 skills analyzed** (reverse-spec: 36 files, smart-sdd: 55 files, speckit-diff: 3 files, case-study: 4 files) + 9 root files
- **SKF-001~006**: ALL PASS — all 6 feedback items properly reflected in pipeline.md and verify-phases.md
- **Cross-references**: All valid across all skills, no broken links or orphaned files
- **Over-fragmentation**: None found; HARD STOP inline repetition is intentional per CLAUDE.md #1

### Issues Found & Decisions
1. **_foundation-core.md F6 Status Table outdated** (tauri=Implemented but table says TODO scaffold) → **LEAVE AS-IS**: Table is purely informational/documentation, not used at runtime. Actual files work correctly regardless of table status.
2. **demo-status.sh not referenced in verify-phases.md** → **FIX**: Integration Demo Trigger and `scripts/demo-status.sh` call only existed in `reference/injection/verify.md` (supplementary). An agent following verify-phases.md (the primary execution guide) would miss it. Added Phase 5: Integration Demo Trigger section with explicit HARD STOP.

### Files Changed (2 files)
- `smart-sdd/commands/verify-phases.md` — Added Phase 5: Integration Demo Trigger (HARD STOP, demo-status.sh reference, demo-standard.md cross-ref)
- `history.md` — this entry

---

## [2026-03-13] Post-Pull Review — 10 Commits Cross-Reference Check

Pulled 10 commits (36 files, +2739 lines). Full review per CLAUDE.md Review Protocol across 10 check categories.

| # | Check | Result |
|---|-------|--------|
| 1 | Foundation file references (resolver, init, analyze) | ✅ All paths correct |
| 2 | All 10 Foundation files exist on disk | ✅ Verified |
| 3 | SKILL.md _core vs _resolver reference change | ✅ Both files coexist correctly |
| 4 | "acceptance criteria" → "success criteria" terminology | ✅ Complete migration |
| 5 | Pipeline.md new sections (Context Budget, Retry, Cycle Detection, Smoke Launch, Parallel Agent) | ✅ All positioned correctly |
| 6 | verify-phases.md new sections (Regression limit, Pre-Resumption, Code-Level Cross-Ref, new verbs, cli-limited) | ⚠️ 7 new VERIFY_STEPS verbs missing from demo-standard.md (fixed) |
| 7 | state-schema.md (State Validation, Foundation Decisions, Schema Version 2.0) | ✅ All consuming files consistent |
| 8 | Context Budget Protocol P1 sections vs injection Read Targets | ✅ Aligned |
| 9 | README File Map sync (10 new Foundation files + lessons-learned.md) | ✅ Both READMEs in sync |
| 10 | gui.md micro-interaction extraction vs verify-phases.md | ✅ 7 categories aligned |

**Fix**: Added 7 interactive VERIFY_STEPS verbs (hover, press-key, drag-to, focus, verify-tooltip, right-click, verify-animation) to demo-standard.md — SC→UI Action format, VERIFY_STEPS block example, and test file conversion.

**Files**: demo-standard.md (1 fix), history.md

---

## [2026-03-13] SKF-001~006: Implement + Verify Gap Fixes from angdu-studio F001

Skill Feedback from angdu-studio rebuild (F001-app-shell). 6 SKF items grouped into 3 root causes, fixed with generalized (not project-specific) rules.

### Root Cause 1: Parallel Agent Coordination (SKF-001, 003)
- **Problem**: Parallel background agents modified the same files (index.ts, ipc.ts), causing conflicts
- **Fix**: Added Parallel Agent File Ownership Protocol to pipeline.md — file scope separation, shared entry point reservation, conflict detection, sequential fallback
- **Fix**: Implement Checkpoint now displays file plan + parallel execution plan for user review

### Root Cause 2: No Runtime Gate in Implement (SKF-002, 004)
- **Problem**: Build passed but app crashed at runtime. Renderer was a blank page with no interactive UI
- **Fix**: Added Post-Implement Smoke Launch to pipeline.md — 5-second crash check, GUI snapshot, operability check
- **Rationale**: Overlaps with verify Phase 0 but catching issues in implement avoids the verify → regression → re-implement cycle

### Root Cause 3: cli-limited Misinterpreted as "No Runtime" (SKF-005, 006)
- **Problem**: cli-limited was treated as "code-level only." SC verification only checked function existence (Tier 1), missed target mismatches
- **Fix**: Redefined cli-limited in verify-phases.md — ad-hoc runtime exploration using inline Playwright API calls
- **Fix**: Added Code-Level Cross-Reference Rule — behavioral SCs must verify action target matches actual source
- **Fix**: Updated pre-flight message to "ad-hoc — no test file, will use inline exploration"

### Files Changed (3 files)
- `smart-sdd/commands/pipeline.md` — Parallel Agent File Ownership, Implement Checkpoint Display, Post-Implement Smoke Launch
- `smart-sdd/commands/verify-phases.md` — cli-limited ad-hoc exploration, Cross-Reference Rule, pre-flight message
- `history.md` — this entry

### Follow-up: Cross-Reference Consistency Fixes
Post-review audit found 3 stale/missing cross-references after the SKF fixes:
1. pipeline.md implement summary line didn't reflect new gates (Smoke Launch, parallel file ownership) → updated
2. injection/implement.md had no Parallel Agent File Ownership section → added, with cross-ref to pipeline.md
3. Implement Checkpoint Display clarified sequential-mode behavior (parallel plan omitted if sequential)

---

## [2026-03-13] Terminology Unification — "Acceptance Criteria" → "Success Criteria"

spec-kit defines SC-### as **Success Criterion** (`## Success Criteria` section in spec.md). However, spec-kit-skills used "Acceptance Criteria" and "Success Criteria" interchangeably across 12 occurrences in 9 files — including one line that used both terms simultaneously (`Draft acceptance criteria (SC-###): Draft Success Criteria / Acceptance Scenario`).

### Changes
Unified all 12 occurrences of "acceptance criteria" → "success criteria" to match spec-kit's canonical terminology.

### Files Changed (9 files)
- `smart-sdd/reference/injection/specify.md` — 4 occurrences (L48, L88, L73, L253)
- `smart-sdd/reference/injection/adopt-specify.md` — 2 occurrences (L48, L85)
- `smart-sdd/reference/context-injection-rules.md` — 1 occurrence (L62)
- `smart-sdd/commands/verify-phases.md` — 1 occurrence (L23)
- `reverse-spec/templates/pre-context-template.md` — 1 occurrence (L256)
- `reverse-spec/templates/business-logic-map-template.md` — 1 occurrence (L6)
- `reverse-spec/templates/speckit-prompt-template.md` — 1 occurrence (L41)
- `reverse-spec/reference/speckit-compatibility.md` — 1 occurrence (L48)
- `history.md` — this entry

---

## [2026-03-13] Full File Review + Cross-Reference Fixes + Context Budget README

Full file inspection following CLAUDE.md Review Protocol (4-step: flow consistency, unused parts, commonization, over-fragmentation).

### Issues Found & Fixed
- **Broken reference**: SKILL.md line 198 pointed to `../reverse-spec/domains/_resolver.md` (file does not exist) → Fixed to `../reverse-spec/domains/_core.md` and `_schema.md`
- **Over-fragmentation**: `reverse-spec/domains/_core.md` R7 duplicated Foundation Detection table from `_foundation-core.md` F0 → Replaced inline table with cross-reference per Single Source of Truth principle
- **README gap**: Context Budget Protocol not reflected in README → Added to Session Resilience section (both EN/KO)

### Review Results (11 checks passed, 2 fixed)
All other cross-references verified: injection files (11), profiles (4), foundations (10), references (11), templates (9). T0 handling, cycle detection, retry policy, pre-resumption validation all confirmed present. File Map complete.

### Files Changed (5 files)
- `.claude/skills/smart-sdd/SKILL.md` — Fix broken reverse-spec reference
- `.claude/skills/reverse-spec/domains/_core.md` — R7 de-duplicated (cross-ref to F0)
- `README.md` — Context Budget Protocol in Session Resilience, timestamp
- `README.ko.md` — Korean sync, timestamp
- `history.md` — this entry

---

## [2026-03-13] Context Budget Protocol + Domain Resolution Worked Example

Expert analysis (8.2/10) identified two addressable weaknesses:
1. No protocol for context overflow — what to do when assembled injection exceeds context window
2. No concrete trace showing how domain module resolution works end-to-end

### Context Budget Protocol (context-injection-rules.md)
- 3-tier priority system: P1 (must-inject), P2 (summarizable), P3 (skip-safe)
- Per-command P1 section table — single source of truth for "what must never be trimmed"
- 3-step overflow protocol: Summarize P2 → Skip P3 → Split if still over
- Size heuristics table for triggering budget triage (no exact token counting)
- Checkpoint budget indicator: `📊 Context: {P1}/{total} must-inject | {N} summarized | {M} skipped`

### Domain Resolution Worked Example (_resolver.md)
- Full `desktop-app` rebuild + Electron trace through all 4 resolution steps
- Profile expansion: `desktop-app` → gui + async-state + ipc + rebuild scenario
- Foundation resolution: electron.md (58 items) + _foundation-core.md (T0 rules)
- Module loading table: 5 files with per-module S-section contributions
- Merged result table: 7 S-sections with source attribution

### Design Principle Compliance
- **Single Source of Truth**: Budget priority definitions live ONLY in context-injection-rules.md; per-command injection files are NOT modified (they define WHAT to inject; the budget defines WHEN to trim)
- **No over-fragmentation**: Worked example in _resolver.md (where resolution protocol lives), not split across separate file
- **English only**: Both additions in English per CLAUDE.md Language rules

### Files Changed (2 files + bookkeeping)
- `.claude/skills/smart-sdd/reference/context-injection-rules.md` — Context Budget Protocol section
- `.claude/skills/smart-sdd/domains/_resolver.md` — Worked Example section
- `history.md` — this entry

---

## [2026-03-13] README Reliability Mechanisms + File Map Corrections

Post expert analysis (8.2/10) identified key architectural innovations not yet documented in README, plus stale File Map item counts from pre-review state.

### README Architecture Additions
- **Session Resilience & Agent Governance** section added — documents three reliability mechanisms:
  - Compaction-Resilient State (verify progress survives context window compaction via sdd-state.md)
  - Source Modification Gate (mandatory classification before edits + Minor Fix Accumulator auto-escalation at 3 fixes)
  - Context Window Management (lazy-loading decomposition: SKILL.md → commands → injection → domains)
- File Map TODO scaffold item counts corrected: FastAPI 49→41, React Native 55→50, Flutter 59→50

### Files Changed (3 files)
- `README.md` — Session Resilience section, File Map fixes, timestamp
- `README.ko.md` — Korean sync, File Map fixes, timestamp
- `history.md` — this entry

---

## [2026-03-13] Expert Review Fixes + README Architecture Enhancement

Post-implementation expert review identified 14 issues across Foundation files, reverse-spec integration, and smart-sdd integration.

### Fixes Applied
- **Critical**: Electron item count note (63 rows, 58 unique decisions with 5 cross-refs), Express category count (12→13), TODO scaffold F1 sums corrected (FastAPI 49→41, React Native 55→50, Flutter 59→50)
- **Significant**: Phase 4-2 Foundation distribution (added Foundation Decisions + Foundation Dependencies to pre-context distribution), roadmap-template T0 tier section added, STR/DTA categories added to _foundation-core.md F1 taxonomy
- **Minor**: Phase reference fix (2-4→2-8), dangling Phase 5 reference removed, verify-phases heading mismatch fixed, micro-interaction ID format specified, Express DXP description corrected, Electron ENV cross-ref annotations added

### README Architecture Enhancement
- Added "Design Philosophy" section: 5 principles (contracts over hope, cross-Feature context injection, composable domain knowledge, human checkpoints at irreversible boundaries, progressive detail capture)
- Added "Adapting to Your Project" section: 6 progressive customization levels (Level 0 defaults → Level 5 pipeline behavior modification)
- Enhanced "Extensibility" section: added Foundation creation and workflow adaptation examples
- All changes synced to README.ko.md (Korean)

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Electron cross-refs vs dedup | Keep 63 rows, annotate cross-refs | Different extraction axes need separate entries; "see also" links prevent agent confusion |
| Foundation distribution in Phase 4-2 | Explicit addition to enumeration | Without explicit instruction, agent may skip Foundation data when populating pre-context |
| T0 in roadmap template | New section before T1 | Template must mirror actual pipeline ordering; Foundation Features need a home in roadmap.md |

### Files Changed (16 files)
- `reverse-spec/domains/foundations/electron.md` — cross-ref annotations, item count note
- `reverse-spec/domains/foundations/_foundation-core.md` — F1 STR/DTA, F6 table corrected
- `reverse-spec/domains/foundations/express.md` — DXP description
- `reverse-spec/domains/foundations/fastapi.md` — TODO comment fix
- `reverse-spec/domains/foundations/react-native.md` — TODO comment fix
- `reverse-spec/domains/foundations/flutter.md` — TODO comment fix
- `reverse-spec/commands/analyze.md` — Phase ref, Foundation distribution, ID format
- `reverse-spec/templates/roadmap-template.md` — T0 tier section
- `smart-sdd/commands/verify-phases.md` — heading mismatch
- `README.md` — Design Philosophy, Adapting to Your Project, timestamp
- `README.ko.md` — Korean sync, timestamp
- `history.md` — this entry

---

## [2026-03-13] Micro-Interaction Layer + Expert Analysis Improvements

Added comprehensive micro-interaction detection and verification across the full pipeline, plus expert-recommended robustness improvements.

### 1. Micro-Interaction Detection (reverse-spec)

- **Phase 2-7b**: New source code analysis phase extracting 7 categories of micro-interactions: hover behaviors (tooltips, CSS :hover), keyboard shortcuts, animations/transitions, focus management, drag-and-drop, context menus, scroll behaviors
- **Two-pronged approach**: Source code analysis (always, via grep patterns for event listeners, CSS pseudo-classes, tooltip components, keyboard libraries) + optional runtime probing (Playwright, when available)
- **gui.md R4**: New analysis axis with detection heuristics tables per interaction category, covering 40+ signal patterns across React/Vue/CSS/HTML5/library ecosystems
- **micro-interactions.md**: New artifact output with structured tables per category
- **Priority classification**: P1 (core — must reproduce), P2 (enhancement — should reproduce), P3 (polish — can defer)

### 2. Micro-Interaction in Smart-SDD Pipeline (all stages)

- **specify**: Injects interaction inventory; for greenfield/add, prompts user to define interactions (tooltips, shortcuts, drag-and-drop) during specify → FR-### entries with interaction verbs in SCs
- **plan**: Injects interactions for architectural decisions (tooltip component library, shortcut framework, animation library, DnD library, focus trap approach)
- **implement**: Injects concrete interaction implementation tasks (tooltip rendering, shortcut registration, CSS transitions, DnD handler wiring)
- **verify**: Extended vocabulary with 7 new verbs (`hover`, `press-key`, `drag-to`, `focus`, `verify-tooltip`, `right-click`, `verify-animation`); micro-interaction completeness check (P1 missing = Major-Implement, P2 missing = Minor)
- **add.md**: Interaction Behavior Inventory section in pre-context generation (rebuild: filter from micro-interactions.md; greenfield: "define during specify")
- **pre-context-template.md**: New "Interaction Behavior Inventory" section with 7 structured sub-tables
- **context-injection-rules.md**: Graceful degradation for missing micro-interaction data

### 3. Expert Analysis Improvements

- **Regression depth limit** (verify-phases.md): Per-Feature regression counter. HARD STOP after 2 regressions (options: continue/abort/pause). Force block after 3. Counter persisted via Feature Detail Log `↩️ REGRESSION` entries
- **Context budget estimation** (pipeline.md Assemble step): For 10+ Feature projects, estimates total context volume before reading. If >2000 lines: progressive summarization (full for current Feature, summary for direct deps, IDs only for indirect deps, skip unrelated)

### Design Decisions

| # | Decision | Choice | Rationale |
|---|----------|--------|-----------|
| 1 | Micro-interaction approach | Source analysis + optional runtime probing | Source code captures the full inventory (event listeners, CSS, components); runtime confirms behavior details (tooltip text, timing) |
| 2 | Detection scope | 7 categories, 40+ signal patterns | Covers the full spectrum from CSS :hover to JS keyboard handlers to DnD libraries |
| 3 | Pipeline integration depth | All 4 stages (specify → plan → implement → verify) | User's feedback: micro-interactions should be active throughout, not just analysis |
| 4 | Greenfield micro-interaction definition | Prompt during specify, not init | Init handles project setup; specify is where behavioral requirements are defined |
| 5 | Regression depth limit | 2 warnings + 3 force block | Prevents infinite regression loops; 2 attempts should be sufficient for legitimate issues |
| 6 | Context budget threshold | 2000 lines (~40% of context) | Leaves 60% for system instructions + command execution + agent reasoning |
| 7 | Progressive summarization levels | 4 tiers (full / summary / IDs / skip) | Maximizes information density while staying within budget |

### Files Changed (13 files)

| File | Change |
|------|--------|
| `reverse-spec/commands/analyze.md` | Phase 2-7b + Phase 4-2 distribution + cross-check |
| `reverse-spec/domains/interfaces/gui.md` | R4 micro-interaction extraction |
| `reverse-spec/templates/pre-context-template.md` | Interaction Behavior Inventory section |
| `smart-sdd/commands/verify-phases.md` | 7 new verbs + regression depth limit |
| `smart-sdd/commands/pipeline.md` | Context budget estimation |
| `smart-sdd/commands/add.md` | Interaction Behavior Inventory in pre-context |
| `smart-sdd/reference/injection/specify.md` | Micro-interaction context + greenfield prompts |
| `smart-sdd/reference/injection/plan.md` | Micro-interaction architecture |
| `smart-sdd/reference/injection/implement.md` | Micro-interaction implementation reference |
| `smart-sdd/reference/injection/verify.md` | Micro-interaction completeness check |
| `smart-sdd/reference/context-injection-rules.md` | Graceful degradation for micro-interactions |
| `history.md` | This entry |

---

## [2026-03-13] Platform Foundation Layer + Architecture Documentation

Added framework-specific infrastructure decision management across the entire pipeline. Projects on specific frameworks (Electron, Express, Next.js, etc.) now have explicit Foundation checklists, T0 tier processing, and cross-framework migration support.

### Area 1: Foundation Reference Files (10 new files)

| File | Content |
|------|---------|
| `foundations/_foundation-core.md` | Resolution protocol (F0–F6), case matrix (A/B/C/D), T0 grouping rules, cross-framework carry-over map |
| `foundations/electron.md` | 58 items, 13 categories (WIN, SEC, IPC, NAT, UPD, DLK, BLD, LOG, STR, ERR, DXP, BST, ENV) |
| `foundations/tauri.md` | 44 items, 12 categories |
| `foundations/express.md` | 43 items, 12 categories |
| `foundations/nextjs.md` | 44 items, 13 categories |
| `foundations/vite-react.md` | 43 items, 12 categories |
| `foundations/nestjs.md` | TODO scaffold (51 items) |
| `foundations/fastapi.md` | TODO scaffold (49 items) |
| `foundations/react-native.md` | TODO scaffold (55 items) |
| `foundations/flutter.md` | TODO scaffold (59 items) |

### Area 2: reverse-spec Integration

| Change | Description |
|--------|-------------|
| Phase 1-2b Framework Identification | Detect framework from tech stack, record in analysis |
| Phase 2-8 Foundation Decision Extraction | Extract Foundation decisions from existing code with migration protocol for rebuild framework changes |
| pre-context Foundation Decisions section | Critical/Important/Undecided tables per Feature |
| pre-context Foundation Dependencies section | owns/consumes/extends dependency types |
| R7 Foundation Detection Heuristics | Framework identification rules in `_core.md` |

### Area 3: smart-sdd Integration

| Change | Description |
|--------|-------------|
| init.md Step 3b | Framework Selection & Foundation Decisions (auto-detect, present Critical items, record in state) |
| state-schema.md | State Schema Version 2.0, Framework field, Foundation Decisions section, State Validation procedure |
| _resolver.md Step 2b | Resolve Foundation — load Foundation file based on Framework field |
| _core.md S3d | Foundation Compliance verification for T0 Features |
| pipeline.md T0 ordering | T0 → T1 → T2 → T3 processing order with Foundation Gate |
| pipeline.md Cycle Detection | Kahn's algorithm in Pre-Phase to prevent dependency deadlock |
| pipeline.md Retry Policy | Max 3 retries per step per Feature, each attempt must differ |
| verify-phases.md Pre-Resumption | 5-point integrity check before verify resume |

### Area 4: Pipeline-wide Integration

| Change | Description |
|--------|-------------|
| injection/specify.md | Foundation Decisions context for specify |
| injection/plan.md | Foundation Technical Constraints for plan |
| injection/implement.md | Foundation Implementation Reference for implement |
| injection/verify.md | Foundation Regression Check for verify |
| add.md Phase 3d | T0 tier handling for Foundation Features |
| context-injection-rules.md | Foundation graceful degradation in Missing Content table |

### Area 5: Architecture Documentation

| Change | Description |
|--------|-------------|
| README.md | Platform Foundation, Tier System, Data Flow, Feature Lifecycle, Project Modes, Key Artifacts subsections + Foundation files in File Map |
| README.ko.md | Same sections in Korean + Foundation files in File Map |

### Design Decisions

| # | Decision | Choice | Rationale |
|---|----------|--------|-----------|
| 1 | Foundation files location | `reverse-spec/domains/foundations/` only | Analysis-reference; smart-sdd reads via resolver. Avoids duplication |
| 2 | T0 tier | Above T1 | Natural extension of T1/T2/T3 hierarchy |
| 3 | T0 granularity | Per Foundation category | 58 individual items as Features would be unworkable |
| 4 | TODO scaffold format | Header + category list + TODO comment | Consistent with data-science.md precedent |
| 5 | Foundation Migration | 4 classifications | carry-over/equivalent/irrelevant/new preserves decisions across stack changes |
| 6 | State Schema Versioning | v2.0 with validation | Prevents corruption cascades; enables future schema evolution |
| 7 | Dependency Cycle Detection | Kahn's algorithm | Prevents pipeline deadlock for 50+ Feature projects |
| 8 | Retry Limits | Max 3 per step | Prevents infinite retry loops |
| 9 | Unmatched framework | Generic Foundation (Case B) | Universal categories + agent probes better than skipping entirely |

### Files Changed (34 files)

- **10 new**: `foundations/_foundation-core.md`, `foundations/electron.md`, `foundations/tauri.md`, `foundations/express.md`, `foundations/nextjs.md`, `foundations/vite-react.md`, `foundations/nestjs.md`, `foundations/fastapi.md`, `foundations/react-native.md`, `foundations/flutter.md`
- **reverse-spec**: `commands/analyze.md`, `templates/pre-context-template.md`, `domains/_core.md`
- **smart-sdd**: `commands/init.md`, `commands/pipeline.md`, `commands/add.md`, `commands/verify-phases.md`, `domains/_resolver.md`, `domains/_core.md`, `reference/state-schema.md`, `reference/context-injection-rules.md`, `reference/injection/specify.md`, `reference/injection/plan.md`, `reference/injection/implement.md`, `reference/injection/verify.md`
- **docs**: `README.md`, `README.ko.md`, `history.md`

---

## [2026-03-12] Post-Pull Review — 5 Commits Cross-Reference Check

Pulled 5 commits (14 files, +548/-19 lines). Full review per CLAUDE.md Review Protocol: flow consistency, cross-references, unused parts, over-fragmentation.

| # | Check | Result |
|---|-------|--------|
| 1 | Step renumbering (6→6+7, 7→8, 8→9, 9→10) internal refs | ✅ All consistent |
| 2 | Process Lifecycle Protocol ordering | ❌ Line 319: "below" → "above" (fixed) |
| 3 | PID Registry definition consistency | ✅ OK |
| 4 | Step 1a C-[FID]-G##/D## format vs pre-context-template | ✅ Matches |
| 5 | Step 1f "Consumes ←" vs plan.md injection | ✅ Matches |
| 6 | Cross-feature Interaction Chain → tasks injection | ✅ Aligned |
| 7 | Minor Fix Accumulator lifecycle vs state-schema.md | ✅ Consistent |
| 8 | _core.md B-4 index vs verify-phases.md headings | ✅ OK (substep pointers acceptable) |
| 9 | reverse-spec SKILL.md relative link fix | ✅ Correct |
| 10 | analyze.md relative link fixes | ✅ Correct |
| 11 | README File Map — 27+ newly added files | ✅ All 93 files verified present |
| 12 | Stability window 10s vs 15s | ✅ Different contexts (dev probe vs demo CI) |

**Files**: verify-phases.md (1 fix)

---

## [2026-03-12] Verify Universal HARD STOP + Reverse-Spec Interaction Quality

Two-pronged enhancement addressing F007 repeated iteration quality stagnation.

### Area 1: Source Modification Gate → Universal HARD STOP

Made ALL source modifications during verify (including Minor) require user approval via AskUserQuestion. Previously only Major classifications triggered HARD STOP — Minor fixes proceeded silently, enabling accumulation of undisclosed rewrites.

| Change | Description |
|--------|-------------|
| Universal HARD STOP (step 6) | AskUserQuestion before ANY source edit — "Approve / Reclassify as Major / Skip" |
| Minor Fix Accumulator persistence | Persisted in sdd-state.md → survives context compaction |
| Resumption Protocol | Re-read Accumulator state after compaction |

### Area 2: Reverse-Spec Interaction Quality

Added behavioral contract extraction to reverse-spec analysis, addressing the root cause: insufficient inter-Feature interaction data flowing into specify/plan.

| Change | Description |
|--------|-------------|
| Phase 3-1d Interaction Intensity Check | Cross-Feature interaction matrix with anomaly detection (over-coupled, orphan, hub) |
| Feature Contracts in pre-context | Guarantees, Dependencies, Failure Modes — consumed by plan and verify |
| Interaction Coverage in coverage-baseline | Measures relationship coverage, not just item mapping |
| Cross-Feature Interaction Rules | Behavioral trigger-response chains in business-logic-map |
| verify Step 1a Feature Contract Compliance | Verify Guarantees implemented + Dependencies available |

### Design Decisions

| # | Decision | Choice | Rationale |
|---|----------|--------|-----------|
| 1 | Minor HARD STOP | AskUserQuestion after classification | User must see and approve before any edit |
| 2 | Existing Major HARD STOP | Preserved as secondary gate | Different role: regression routing vs. edit approval |
| 3 | Interaction Intensity | Informational, non-blocking | Auto merge/split too risky; user decides |
| 4 | Feature Contracts | Inside pre-context (no new artifact) | Maintains existing pipeline flow |
| 5 | Contract Compliance check | ⚠️ Warning, non-blocking | Backward compatible with projects without Contracts |

### Files Changed

- `smart-sdd/commands/verify-phases.md` — Universal HARD STOP (step 6), Accumulator persistence, Contract Compliance (Step 1a)
- `smart-sdd/reference/state-schema.md` — Minor Fix Accumulator schema
- `smart-sdd/reference/injection/verify.md` — Gate reminder update
- `reverse-spec/commands/analyze.md` — Phase 3-1d + Phase 4-2 Contract reference
- `reverse-spec/templates/pre-context-template.md` — Feature Contracts section
- `reverse-spec/templates/coverage-baseline-template.md` — Interaction Coverage metrics
- `reverse-spec/templates/business-logic-map-template.md` — Cross-Feature Interaction Rules
- `reverse-spec/domains/_core.md` — R5 interaction intensity heuristic

---

## [2026-03-12] Full File Review — Flow Consistency and File Map Sync

Comprehensive file review across 4 parallel agents (SKILL.md routing, domain system, verify-phases, scripts/README). Validated 98+ cross-file references in SKILL.md routing, 150+ in domain system, with zero broken domain links.

### Issues Found and Fixed

| Issue | Severity | Fix |
|-------|----------|-----|
| 3 broken relative links in reverse-spec (extra `../` level) | Medium | Fixed in SKILL.md, analyze.md |
| Stability window mismatch (verify-phases said ~10s, demo-standard says 15s) | Low | Aligned to 15s with explicit reference |
| 27+ files missing from README File Map | Low | Added all domain, profile, scenario, and reference files |
| README.ko.md File Map out of sync | Low | Synced with README.md |

### Files Changed

- `reverse-spec/SKILL.md` — Fixed 1 broken relative link (`../../smart-sdd/` → `../smart-sdd/`)
- `reverse-spec/commands/analyze.md` — Fixed 2 broken relative links (same pattern)
- `commands/verify-phases.md` — Stability window 10s → 15s (3 probes × 5s per demo-standard.md)
- `README.md` — Added lessons-learned.md, 12 reverse-spec domain files, 21 smart-sdd domain/profile/scenario/reference files, section headers (Domains, Templates)
- `README.ko.md` — Synced all File Map additions (Korean translations)

---

## [2026-03-12] Cross-Feature Integration Wiring — Pipeline Quality Analysis

Comprehensive pipeline quality analysis based on F007-knowledge implementation gaps. The document argued the pipeline lacks "where to connect" support — cross-referenced against codebase and found 7 of 9 proposed improvements already exist (Step 1d orphan detection, Step 1e API contract verification, tasks wiring injection, Integration Contracts, Visual Fidelity Check, etc.). Identified 2 genuine gaps and implemented them.

### Gap Analysis

| Proposal | Status | Action |
|----------|--------|--------|
| Wire task pattern | ✅ Already exists (tasks.md L74-103) | — |
| Integration Wiring Check | ✅ Already exists (verify Step 1d) | — |
| Cross-Module API Contract | ✅ Already exists (verify Step 1e) | — |
| Integration Chain in plan | ✅ Already exists (plan.md Integration Contracts) | — |
| Visual Reference Pipeline | ✅ Already exists (Visual Fidelity Check + preservation_level) | — |
| FR Integration Target metadata | spec-kit CLI scope, not modifiable | — |
| Plan Checkpoint BLOCKING on Integration Chain | Over-enforcement, warning level appropriate | — |
| **Cross-Feature File Modification Audit** | ❌ Not implemented | **Added as verify Step 1f** |
| **Cross-Feature Interaction Chain rows** | ❌ Not implemented | **Added to plan.md injection** |

### Design Decisions

| # | Decision | Choice | Rationale |
|---|----------|--------|-----------|
| 1 | verify Step 1f method | `git diff --name-only` + Integration Contracts `Consumes ←` cross-reference | Simple grep, complements Step 1d (import) + 1e (interface) with file-level check |
| 2 | cross-feature row location | Interaction Chains table, `cross-feature:` prefix | Same downstream flow (tasks→implement→verify) as existing rows; no new artifact |
| 3 | Missing cross-feature rows | Warning, not blocking | Integration Contracts already warn; this adds specificity |
| 4 | reverse-spec Integration Flow Extraction | Not added | Code-level integration paths belong in plan, not reverse-spec (stack-independent) |
| 5 | Existing Code Modification Protocol | Not added separately | Source Reference Injection covers rebuild; cross-feature rows cover add mode |

### Files Changed

- `commands/verify-phases.md` — Added Step 1f (Cross-Feature File Modification Audit) after Step 1e
- `reference/injection/plan.md` — Added Cross-Feature Integration rows to Interaction Chains section

---

## [2026-03-12] Verify Process Lifecycle Protocol — Comprehensive Gap Analysis

Second round of verify gap analysis based on comprehensive review document covering 7 themes. Cross-referenced all 13 proposed improvements against codebase — found 5 already implemented, 2 partially implemented, 7 not implemented. Selected 3 high-value, generally applicable improvements (Group A) and deferred 4 items as over-specific or premature.

### Gap Analysis

| Item | Status | Action |
|------|--------|--------|
| Step 5 CI/Interactive enforcement | ✅ Already implemented | — |
| --ci requires app startup | ✅ Already implemented | — |
| Demo task injection | ✅ Already implemented | — |
| Module-scope Lifecycle Dependency | ✅ Already implemented (prior session) | — |
| Phase-boundary cleanup | ⚠️ Post-verify only | Extended with Process Lifecycle Protocol |
| 0-2c process survival check | ❌ Passive stderr only | Added active `kill -0 $PID` check |
| Pre-flight orphan cleanup | ❌ Not implemented | Added port-based Pre-flight Clean Slate |
| Verify Abort Protocol | ❌ No unified cleanup | Added PID Registry + exit cleanup |
| Phase 3b multi-start test | ❌ Not implemented | Deferred (Electron-specific edge case) |
| Step-level audit trail | ❌ Not implemented | Deferred (Phase-level recording sufficient) |
| SC Matrix → smoke test auto-gen | ❌ Not implemented | Deferred (implementation complexity vs value) |
| Demo task → verify-phases.md ref | ❌ Not implemented | Deferred (unnecessary coupling) |

### Design Decisions

| # | Decision | Choice | Rationale |
|---|----------|--------|-----------|
| 1 | Orphan cleanup detection method | Port-based (`lsof -ti :PORT`) not PID-file-based | PID files from previous sessions may be stale; port occupancy is ground truth |
| 2 | PID Registry scope | In-memory per verify session, not persistent file | Only current session PIDs are relevant; Pre-flight catches cross-session orphans |
| 3 | Abort cleanup guarantee | Dual: exit cleanup (same session) + Pre-flight Clean Slate (next session) | Context compaction or crash may prevent same-session cleanup |
| 4 | Active survival check placement | After stderr stability window, before cleanup | Catches silent exits (segfault, OOM) that produce no stderr output |
| 5 | Deferred items | 4 items deferred | Over-specific (multi-start test), insufficient value/complexity ratio (audit trail, auto-gen), unnecessary coupling (task→verify ref) |

### Files Changed

- `commands/verify-phases.md` — Added Verify Process Lifecycle Protocol (PID Registry, Pre-flight Clean Slate, exit cleanup), enhanced 0-2c with active survival check, added PID registry references to 0-2/0-2alt, updated Resumption Protocol with clean slate step, added Phase 4 cleanup trigger
- `domains/_core.md` — Updated B-4 index to include Process Lifecycle Protocol

---

## [2026-03-12] Verify Gap Analysis — Dev/Production Code Path Divergence

Runtime crash in angdu-studio (`TypeError: Object has been destroyed`) exposed a structural gap: verify only exercised the production build path, missing bugs that manifest only in dev mode due to different module loading order. Generalized the root cause into two improvements applicable to any project type.

### Gap Analysis

| Gap | Root Cause | Generalized Principle |
|-----|-----------|----------------------|
| Dev mode untested | Verify runs production build only | Dev and production have different code paths (bundling, ESM vs CJS, HMR, init order) |
| Module-scope side effects | Singleton constructor calls lifecycle-dependent API at import time | Any `export const x = new X()` with constructor depending on runtime state breaks when import order changes |
| Mocked APIs in tests | Unit tests mock runtime APIs, hiding initialization order bugs | Tests that mock lifecycle APIs (filesystem, window, env) cannot detect real startup sequence issues |

### Design Decisions

| # | Decision | Choice | Rationale |
|---|----------|--------|-----------|
| 1 | Dev Mode Stability Probe location | Phase 0-2c (after app startup, before pre-flight) | Complements production build startup (0-2/0-2alt); probe-and-kill, not persistent |
| 2 | Probe scope | Any GUI project with distinct dev command, not Electron-only | Vite, Next.js, Tauri all have dev/prod path divergence |
| 3 | Blocking behavior | ⚠️ WARNING, not blocking | Dev crash may not affect production; user decides in Review |
| 4 | Module-scope Lifecycle rule location | `_core.md` Universal B-3 (not gui.md) | Pattern applies to any runtime (browser SSR, Node env loading, Electron lifecycle), not GUI-specific |
| 5 | Demo --ci change | Not needed | Phase 0-2c covers the gap; existing demo-standard convergence rule already requires same startup commands |

### Files Changed

- `commands/verify-phases.md` — Added Phase 0-2c Dev Mode Stability Probe
- `domains/_core.md` — Added Module-scope Lifecycle Dependency to Universal B-3 Rules; updated B-4 index to include Dev Mode Stability Probe

---

## [2026-03-11] Rebuild Scenario Enhancement + README Architecture Restructuring

Rebuild.md's 4 configuration parameters (`change_scope`, `preservation_level`, `source_available`, `migration_strategy`) were mostly dead code — only `source_available` was actively consumed. Restructured rebuild.md with proper S1/S3/S5/S7 schema sections, added consumption points throughout the pipeline, and repositioned the Architecture section in README from the bottom Reference area to between Skills and User Journeys for visibility. Integrated "harness engineering for agentic coding" framing into Architecture introduction.

### Design Decisions

| # | Decision | Choice | Rationale |
|---|----------|--------|-----------|
| 1 | change_scope grouping | 3 categories (code-level, platform-level, stack-level) | 6 individual values would cause over-fragmentation |
| 2 | rebuild.md section numbering | S1/S3/S5/S7 schema compliance | Consistency with `_schema.md` pattern |
| 3 | README Architecture position | After Skills, before User Journeys | Skills explains "what" → Architecture explains "how it's designed" → Journeys shows "how to use" |
| 4 | Old Reference Architecture content | Moved to Architecture section (removed from Reference) | Eliminate duplication, improve visibility |
| 5 | Rebuild Configuration | Architecture subsection + state-schema.md + roadmap-template.md | Single source in rebuild.md, cross-references elsewhere |
| 6 | Harness engineering framing | Architecture section introduction | Natural positioning — explains the "why" before the "how" |

### Files Changed

- `domains/scenarios/rebuild.md` — Rewritten: S1 (SC Rules), S3 (Verify Steps), S5 (Elaboration Probes), S7 (Bug Prevention) + Configuration Parameters with Consumed By column
- `reference/state-schema.md` — Added Rebuild Configuration section
- `reverse-spec/templates/roadmap-template.md` — Extended Strategy line with 4 rebuild parameters
- `commands/verify-phases.md` — Light-touch: migration_strategy coverage (Step 2), preservation_level visual fidelity (Step 3b), preservation_level comparison criteria (Step 3e)
- `README.md` — Architecture section repositioned; Rebuild Configuration + harness engineering added
- `README.ko.md` — Synced with README.md structural changes

---

## [2026-03-11] Unified Reset Command — remove→reset Redesign

User ran `/smart-sdd remove F007` intending to re-run F007's pipeline, but `remove` permanently deleted all traces. Root cause: command name mismatch — `remove` implies permanent deletion, but the user's intent was to reset progress for re-execution. Redesigned into a unified `reset` command with three modes.

### Design Decisions

| # | Decision | Choice | Rationale |
|---|----------|--------|-----------|
| 1 | Command name | `reset` (unified, not separate `remove`) | `remove` caused accidental permanent deletion. Single entry point prevents confusion |
| 2 | Per-Feature reset | `reset F007 [--from step]` | Primary use case: reset one Feature's progress so pipeline re-runs it. `--from` allows partial reset (e.g., keep specify, re-run from plan) |
| 3 | Permanent deletion | `reset --delete F007` | Explicit `--delete` flag required for destructive action. Not the default behavior |
| 4 | Full pipeline reset | `reset` (no FID) | Existing behavior preserved. `--all` flag for including logs |
| 5 | Reverse-spec preservation | Always preserved (all modes) | User requirement: pre-context.md, roadmap, registries never deleted during reset. Only `--delete` removes pre-context |
| 6 | Spec directory handling | Deleted on reset (re-created by pipeline) | Unlike restructure-guide's "never auto-delete" policy, reset is explicit user intent. Clean slate for re-execution |
| 7 | remove.md disposition | Deleted (absorbed into reset.md Mode C) | Single source of truth. `--delete` flag routes to the same deletion logic |

### Files Changed

- `commands/reset.md` — Rewritten: 3 modes (Per-Feature, Full Pipeline, Permanent Delete)
- `commands/remove.md` — Deleted (absorbed into reset.md)
- `SKILL.md` — Updated command reference, argument parsing, usage section
- `restructure-guide.md` — Updated cross-reference from `remove` to `reset --delete`
- `add.md` — Updated cross-reference for in_progress/completed Features

---

## [2026-03-11] README Update — Reset Command Documentation

Updated both README.md and README.ko.md Management sections to document the three-mode reset command.

| # | Change | Details |
|---|--------|---------|
| 1 | Per-Feature reset added | `reset F007`, `reset F007 --from plan` |
| 2 | Full pipeline reset clarified | `reset` (comment changed from "Reset pipeline state" to "Full pipeline reset") |
| 3 | Permanent deletion added | `reset --delete F007` |

---

## [2026-03-11] F007 Post-Mortem — 5 Structural Improvements

F007 Knowledge Base verify exposed 12 bugs, all discovered in verify (none in implement). Root causes: (A) implement had no E2E integration test — modules worked individually but were never connected end-to-end, (B) tasks had no integration wiring tasks — only module-level tasks, (C) verify inline-fixed 12 bugs without ever triggering regression, (D) cross-module API contracts (function names, argument formats) were never verified, (E) long debugging sessions lost SDD process rules to context compaction.

### Design Decisions

| # | Decision | Choice | Rationale |
|---|----------|--------|-----------|
| 1 | Integration Wiring Task check (S1) | tasks Review injection (injection/tasks.md) | Detect cross-boundary flow → warn if no E2E wiring task exists. Prevents module-only task generation. Separate from existing "Integration Test" check (testing vs building) |
| 2 | Minor Accumulator (S2-acc) | Source Modification Gate step 9 | 3+ Minor fixes in same module → auto-escalate to Major. Prevents death-by-a-thousand-cuts patchwork |
| 3 | E2E Integration Smoke Test (S3) | injection/implement.md, after CSS Value Map Compliance | Seam-based verification: trace data flow, verify each module boundary has caller+callee. Runtime E2E when available. Complements per-task runtime verify (module-level) |
| 4 | Cross-Module API Contract (S4) | verify Phase 2 Step 1e | grep+AST-lite verification of function name match, argument count/shape compatibility, URL path correctness across intra-Feature boundaries |
| 5 | Compaction-resilient Process Rules (S5) | Verify Initialization checkpoint → sdd-state.md | Write critical rules (Source Modification Gate, Accumulator, Depth Tracking) to sdd-state.md. Resumption Protocol re-reads on compaction recovery |

### F007 Bug Coverage

| Bug | Would be caught by |
|-----|-------------------|
| #1 6-tab IPC unconnected | S1 (wiring task) + S3 (seam check) |
| #2 loadDocument vs loadItem | S4 (function name mismatch) |
| #3 API URL /v1 missing | S3 (E2E runtime) + S4 (URL path) |
| #4 PDF parser missing | S1 (pipeline task) + S3 (seam check) |
| #5 pdf-parse v2 API | S3 (E2E runtime execution) |
| #6 DOMMatrix Node.js | S3 (E2E runtime execution) |
| #7 file path fallback | S3 (E2E) + S4 (API contract) |
| #8 dialog argument mismatch | S4 (argument shape check) |
| #9 Electron API unused | S4 (API contract) |
| #10 threshold default | S3 (E2E runtime — irrelevant query test) |
| #11 KB picker UX | Already addressed by SC Decomposition Rule |
| #12 CitationBlock name | Already addressed by Import Graph + Depth Tracking |

### Files Changed

| File | Change |
|------|--------|
| `reference/injection/tasks.md` | Integration wiring task injection check (cross-boundary flow detection + warning) |
| `reference/injection/implement.md` | E2E Integration Smoke Test section (seam-based + runtime verification) |
| `commands/verify-phases.md` | Source Modification Gate: Minor Accumulator (step 9). Phase 2 Step 1e: Cross-Module API Contract Verification. Verify Initialization: Process Rules Checklist to sdd-state.md. Resumption Protocol: re-read process rules |
| `history.md` | This decision record |

---

## [2026-03-11] Source Modification Gate + Post-Fix Runtime Verification

Real F007 failure: agent discovered issues during verify (KB picker restructure + KnowledgeReference.name + CitationBlock) and fixed all 4 files inline without first classifying severity. The Bug Fix Severity Rule existed (lines 14-47) but was a reference section, not an enforced gate. Same structural pattern as the Step 3f problem — agents skip reference rules.

### Design Decisions

| # | Decision | Choice | Rationale |
|---|----------|--------|-----------|
| 1 | Enforcement mechanism | Source Modification Gate with mandatory visible output | Reference-only rules get skipped. Mandatory visible output (table of planned changes + classification) forces the agent to stop and evaluate before editing |
| 2 | AGGREGATE file count | Count total unique files across ALL planned changes | Individual changes may seem Minor, but 4 "small" fixes across 4 files = Major-Implement. Agent must evaluate the aggregate, not each change in isolation |
| 3 | Post-Fix Runtime Verification | MANDATORY after every inline fix | "Build passes + tests pass ≠ fix correct." Inline fixes must be runtime-verified against affected SCs at Required Depth. Catches incomplete wiring (service compiles but data doesn't flow) |
| 4 | Scope escalation detection | If runtime re-verification fails → re-run gate with expanded scope | A fix that doesn't resolve the runtime issue likely means more files need changes, which may push aggregate to Major |
| 5 | Inline reminders | Gate reminders at Phase 1 failure, Step 3d depth retry, Phase 3b→4 transition | Agents need inline triggers at the exact points where "fix it now" bias occurs |

### Files Changed

| File | Change |
|------|--------|
| `commands/verify-phases.md` | New "Source Modification Gate" section (mandatory pre-fix classification with visible output). Post-Fix Runtime Verification (step 8). Inline gate reminders at Phase 1, Step 3d, Phase 3b→4 transition |
| `history.md` | This decision record |

---

## [2026-03-11] Verify Phase Hardening — SC Decomposition, Import Graph, Depth Enforcement

Three verify-phases.md improvements based on real F007 test failure where `KnowledgeChatService` was implemented and tested but never imported by its consumer (`Inputbar.tsx`), and SC-007 (RAG chat integration) was classified entirely as `user-assisted`, skipping the auto-verifiable UI wiring portion.

### Design Decisions

| # | Decision | Choice | Rationale |
|---|----------|--------|-----------|
| 1 | SC Decomposition Rule | Split mixed SCs into sub-SCs at classification time (Step 0) | SC-007 contained both auto-verifiable (KB picker UI) and user-dependent (RAG chat) parts. Classifying entire SC as `user-assisted` lost the auto-verifiable portion |
| 2 | Import Graph Verification | Phase 2 Step 1d (not Phase 1, not implement gate) | Orphaned services pass tests/build/lint (Phase 1). Phase 2 is "Behavior Completeness" — right home. Rejected S4 (implement gate) as redundant |
| 3 | SC Minimum Depth enforcement | SHOULD → MUST for behavioral SCs, per-SC depth tracking in Step 3d | Step 0 rule existed but was not enforced. Agents did presence-only (Tier 1) verification for SCs that require state-change (Tier 2). Now tracked and retried |
| 4 | S4 (implement Integration Checklist) | Rejected — redundant with S2 | Integration completeness is verify's role, not implement's. S2 in Phase 2 catches the same gap. Adding to implement blurs the boundary |

### Files Changed

| File | Change |
|------|--------|
| `commands/verify-phases.md` | Step 0: SC Decomposition Rule + SC Verification Matrix `Required Depth` column. Phase 2 Step 1d: Service Integration Verification. Step 3d: per-SC Depth Tracking with mandatory retry |
| `history.md` | This decision record |

---

## [2026-03-11] CLI+MCP Complementary Mode — Playwright Architecture

Changed Playwright architecture from mutually exclusive backend selection (CLI OR MCP) to complementary mode (CLI THEN MCP). Previously, `RUNTIME_BACKEND` chose one backend; now CLI always runs first (headful for user visibility) and MCP supplements when available for interactive inspection.

User-driven: Playwright CLI ran but browser window was invisible (headless default). User requested headful default, then suggested always running MCP after CLI when available, rather than choosing one or the other.

### Design Decisions

| # | Decision | Choice | Rationale |
|---|----------|--------|-----------|
| 1 | CLI headful default | `chromium.launch({ headless: false })` | User needs to see browser window during exploration/verification. CI may override |
| 2 | Backend model | CLI+MCP complementary (not exclusive) | CLI handles automated test scripts; MCP adds interactive inspection (console, DOM, complex UI) |
| 3 | New flag | `PLAYWRIGHT_MCP` (`supplement` / `primary` / `unavailable`) | Orthogonal to `RUNTIME_BACKEND` — MCP availability tracked independently, probed always (not optional) |
| 4 | Browser console scan trigger | `PLAYWRIGHT_MCP available` (not `RUNTIME_BACKEND = mcp`) | Console scan should run whenever MCP is available, regardless of whether CLI is the primary backend |
| 5 | analyze.md supplement | Step 2b — MCP Interactive Supplement after CLI exploration | Complex UI (drag-and-drop, modals, lazy loading) benefits from interactive MCP after automated CLI pass |

### Files Changed

| File | Change |
|------|--------|
| `reference/runtime-verification.md` | §3a classification table: added `PLAYWRIGHT_MCP` column. §4 session messages: CLI+MCP variants. All `chromium.launch()` → headful. Complementary mode paragraph |
| `commands/verify-phases.md` | Browser console scan condition: `RUNTIME_BACKEND = mcp` → `PLAYWRIGHT_MCP` available |
| `reverse-spec/commands/analyze.md` | Step 2b — MCP Interactive Supplement. `chromium.launch()` → headful |
| `history.md` | This decision record |

---

## [2026-03-11] `/smart-sdd remove` Command

New standalone command for removing specific Features. Previously required either `/smart-sdd add` pre-check (pending only) or manual restructure-guide.md checklist (in_progress/completed). Now unified into one command that works for any Feature status.

### Design Decisions

| # | Decision | Choice | Rationale |
|---|----------|--------|-----------|
| 1 | Command name | `remove` (not `clean`) | User preference — `clean` implies cache/temp cleanup, `remove` is clear deletion intent |
| 2 | Dependency handling | Warn, not block | User requirement — downstream Features get 🔀 marking, user decides whether to proceed |
| 3 | Source code handling | Warn only, don't auto-delete | Consistent with restructure-guide.md policy — code removal is user responsibility |
| 4 | Spec directory handling | Delete (with HARD STOP confirmation) | Unlike restructure (split/merge) where preservation aids reference, `remove` is explicit deletion intent |
| 5 | Multi-Feature support | `remove F007 F008` | Batch convenience |

### Files Changed

| File | Change |
|------|--------|
| `commands/remove.md` | New file — 5-step command (Parse → Impact Scan → Report HARD STOP → Execute → Commit) |
| `SKILL.md` | argument-hint + Command Reference table: added `remove` |
| `reference/restructure-guide.md` | Delete operation: cross-reference to `/smart-sdd remove` |
| `history.md` | This decision record |

---

## [2026-03-11] User-Assisted SC Completion Gate (Step 3f)

Real-world failure in F007 verify: agent classified SCs as `user-assisted` but skipped the cooperation block in Step 3d entirely, marking them as `⚠️` without ever presenting AskUserQuestion to the user. The `user-assisted` SCs subsection existed in Step 3d (with inline HARD STOP) but was treated as optional content among the auto-category subsections.

### Design Decisions

| # | Decision | Choice | Rationale |
|---|----------|--------|-----------|
| 1 | Separate gate step | New Step 3f as a mandatory gate before Step 4 | Per CLAUDE.md Rule 1 principle: agents ignore subsections within large steps. A separate, clearly labeled gate step forces entry and cannot be accidentally skipped as part of another step's flow |
| 2 | BLOCKING semantics | Do NOT proceed to Step 4 until gate passes | Marking `user-assisted` SCs as ⚠️ without user consent is a protocol violation — the user chose `user-assisted` classification specifically because cooperation is expected |
| 3 | Inline HARD STOP + re-ask | AskUserQuestion with "If response is empty → re-ask" in Step 3f body | Same principle as every other HARD STOP — agents skip reference-only rules |
| 4 | external-dep re-classification check | Gate includes review of `external-dep` SCs for possible reclassification | Some `external-dep` SCs may actually be `user-assisted` (user CAN provide the dependency). Gate catches misclassification before finalization |
| 5 | Coverage report includes user-assisted breakdown | Added verified/skipped split in SC Verification Coverage | Previously, user-assisted SCs had no separate line in the coverage report, making their disposition invisible in Review |

### Files Changed

| File | Change |
|------|--------|
| `commands/verify-phases.md` | New Step 3f — User-Assisted SC Completion Gate with inline HARD STOP. Step 0 coverage assessment references Step 3f. Step 7 rule updated. SC Verification Coverage report now includes user-assisted breakdown |
| `reference/user-cooperation-protocol.md` | §4 cross-reference table: added Step 3f gate entry |
| `history.md` | This decision record |

---

## [2026-03-11] Full File Review — Over-Fragmentation Consolidation

Comprehensive file review identified 3 HIGH-severity duplications from incremental updates. Applied Single Source of Truth principle: detailed definitions stay in one canonical file, consumers cross-reference.

### Design Decisions

| # | Decision | Choice | Rationale |
|---|----------|--------|-----------|
| 1 | Detection protocol consolidation | Canonical in runtime-verification.md §3a; verify-phases.md and analyze.md cross-reference | Same 2-phase probe was fully duplicated in 3 files — any change required 3 synced edits |
| 2 | Classification table consolidation | Canonical in runtime-verification.md §3a; verify-phases.md references with summary | Identical 5-row table duplicated word-for-word in 2 files |
| 3 | HARD STOP MCP option standardized | All 3 files use "Configure Playwright MCP" with cross-ref to §4 for restart rules | Was inconsistent: "Install MCP" / "Configure MCP" / "Configure MCP and restart session" |
| 4 | Review Protocol formalized | Added over-fragmentation check (item #4) to CLAUDE.md Review Protocol | Prevents future incremental updates from re-introducing duplication |
| 5 | CLAUDE.md Rule 7 updated | "Playwright Pre-flight" (was "Playwright MCP Pre-flight") | Rule text was outdated after CLI-primary architecture change |
| 6 | reverse-spec _resolver.md connected | Linked to shared smart-sdd/_resolver.md (was broken reference) | Per convention: dead references → connect, not delete |

### Files Changed

| File | Change |
|------|--------|
| `CLAUDE.md` | Review Protocol #4 over-fragmentation check, Rule 7 wording update |
| `commands/verify-phases.md` | Pre-flight Step 2a: ~40 lines → ~12 lines (cross-ref to runtime-verification.md §3a). HARD STOP MCP option standardized |
| `reverse-spec/commands/analyze.md` | Phase 1.5-0 Step 1: ~15 lines → ~6 lines (cross-ref). HARD STOP MCP option standardized |
| `reference/injection/implement.md` | HARD STOP MCP option standardized with cross-ref to §4 |
| `reverse-spec/SKILL.md` | _resolver.md → cross-reference to shared smart-sdd/_resolver.md |
| `history.md` | This decision record |

---

## [2026-03-11] Library Import Probe + CWD Fix for Playwright CLI

Real-world failure in reverse-spec Phase 1.5: `ERR_MODULE_NOT_FOUND: Cannot find package 'playwright'` when library mode script ran from `/tmp/` instead of the project root. Root cause: pre-flight only checked `npx playwright --version` (binary exists) but library mode uses `require('playwright')` which depends on CWD having `node_modules/playwright`.

### Design Decisions

| # | Decision | Choice | Rationale |
|---|----------|--------|-----------|
| 1 | No new classification level | Redefine "available" = binary + library importable | "binary-only" is a fixable misconfiguration, not a capability level. Adding `cli-runner` would touch 5+ consumer files for a transient state that auto-recovery resolves in seconds |
| 2 | Two-phase CLI probe | Binary check + `node -e "require('playwright')"` from project root | npx and require() use different module resolution. Binary success does NOT guarantee library mode works |
| 3 | Auto-recovery in probe | Install playwright if binary works but library fails | Recovery is fast (npm install) and deterministic. Avoids unnecessary HARD STOPs for a mechanical fix |
| 4 | CWD anchor for all library mode scripts | `cd PROJECT_ROOT && node -e "..."` | require() resolves from CWD. Scripts in /tmp/ or non-project dirs will always fail |
| 5 | Context-aware recovery | reverse-spec installs in output dir; smart-sdd installs in project root | Source project (reverse-spec) never has playwright; target project (smart-sdd) should have it |

### Files Changed

| File | Change |
|------|--------|
| `reference/runtime-verification.md` | §3a: two-phase CLI probe (binary + library import + recovery). §7: CWD requirement + anti-pattern warning |
| `commands/verify-phases.md` | Pre-flight Step 2a: library import probe + auto-recovery for smart-sdd context |
| `reverse-spec/commands/analyze.md` | Phase 1.5-0 Step 1: library probe + context-aware auto-install in output directory |
| `reference/injection/implement.md` | CWD anchor (`cd PROJECT_ROOT &&`) for library mode invocations |
| `PLAYWRIGHT-GUIDE.md` | "Verify Library Mode" section + "ERR_MODULE_NOT_FOUND" troubleshooting |

---

## [2026-03-11] F007 Post-Mortem — Runtime Verification Architecture + Multi-Backend Detection

Comprehensive verify improvements based on F007 post-mortem analysis. Core problem: verify checked code existence (grep) but didn't exercise runtime behavior. Five interrelated issues traced to this single architectural gap.

### Design Decisions

| # | Decision | Choice | Rationale |
|---|----------|--------|-----------|
| 1 | Runtime backend abstraction | `RUNTIME_BACKEND` variable replacing `MCP_STATUS` | Interface-specific verification needs different tools — MCP/CLI for GUI, curl for API, shell for CLI/data-io |
| 2 | Multi-backend detection | MCP probe → CLI probe → test file check → classify | Playwright MCP is unreliable (missing from session); CLI is stable fallback. Eliminates false "session restart needed" messages |
| 3 | Interface-aware SC categories | Added `api-auto`, `cli-auto`, `pipeline-auto`, `user-assisted` | Previous classification only had `cdp-auto` for GUI. Non-GUI interfaces had no automated verification path |
| 4 | `user-assisted` split from `external-dep` | SCs accessible with user help (API key, local model) are automatable after cooperation | Batched cooperation request prevents excessive HARD STOPs |
| 5 | SC Minimum Depth Rule | Tier-1-only SCs implying behavior auto-upgraded to Tier 2 | Prevents "text present" passing for SCs that say "should change/update/display" |
| 6 | Session restart messaging | Only when MCP specifically needed AND CLI also unavailable | Non-GUI interfaces never mention restart. CLI available = no restart needed |
| 7 | Workaround prohibition clarified | Raw CDP/puppeteer still prohibited; CLI, curl, shell explicitly permitted | CLI is a first-class Playwright tool, not a workaround |
| 8 | S8 Runtime Verification Strategy | New domain schema section — per-interface, no merge | Each interface declares its own start/verify/stop/SC-extension |
| 9 | Data dependency verification | Step 1c — runtime probe for cross-feature data availability | Embedding model not running = empty results, but code structure was correct |
| 10 | Navigation transition check | Step 3c — layout consistency across Feature pages | Header cramped when navigating between Features |
| 11 | User Cooperation Protocol | Centralized 6-step pattern (DETECT → CLASSIFY → DIAGNOSE → REQUEST → VERIFY → RECORD) | Standardizes user assistance requests across 10+ pipeline locations |

### Files Changed

| File | Change |
|------|--------|
| `reference/runtime-verification.md` | NEW — Multi-backend architecture, detection protocol, per-interface verification |
| `reference/user-cooperation-protocol.md` | NEW — Standardized user assistance pattern |
| `commands/verify-phases.md` | MAJOR UPDATE — Pre-flight multi-backend, Steps 1c/3c/3d/3e, SC categories, MCP_STATUS→RUNTIME_BACKEND |
| `domains/_schema.md` | Added S8 Runtime Verification Strategy section + merge rule |
| `domains/interfaces/*.md` (4 files) | Added S8 sections with interface-specific verification strategies |
| `reference/injection/implement.md` | CLI check before degradation, runtime-verification.md cross-reference |
| `reference/injection/verify.md` | Checkpoint/Review display updates for new steps and SC categories |
| `domains/scenarios/rebuild.md` | Source app runtime link to Step 3e |
| `commands/pipeline.md` | Foundation Gate cooperation reference |
| `lessons-learned.md` | Added G11 entry |

---

## [2026-03-11] Proposal Mode + Clarity Index (CI) — Streamlined Greenfield Entry

Added Proposal Mode to `init` command and Clarity Index (CI) scoring system. Enhances the 3-axis domain composition with signal-based inference for greenfield projects.

### Design Decisions

| # | Decision | Choice | Rationale |
|---|----------|--------|-----------|
| 1 | Entry point for ideas | Extend `init` with positional idea string (not new command) | One entry point for all greenfield paths. `init "idea"` = Proposal Mode, `init --prd` = PRD mode, `init` = standard Q&A |
| 2 | CI scoring model | 7 dimensions × confidence(0–3) × weights → percentage | Core Purpose and Key Capabilities weighted ×3 (most important for project viability), tech details weighted ×1 (can be inferred) |
| 3 | CI tier thresholds | Rich ≥70%, Medium 40–69%, Vague 15–39%, Empty <15% | Rich means enough to generate a Proposal directly. Medium means 2–3 targeted questions suffice. Vague needs a seed question first |
| 4 | S0 Signal Keywords | Optional section in domain modules (distributed vocabulary) | Each module declares its own activation signals. Adding a new module automatically extends the signal vocabulary |
| 5 | 3-axis inference | Match signals → activate interfaces + concerns | "React dashboard with Stripe payments" → gui + http-api + external-sdk + auth (automatic) |
| 6 | CI propagation into pipeline | Lower CI → more HARD STOPs and verification checks | Prevents shallow ideas from producing incomplete specs. Per-dimension low confidence triggers targeted checks |
| 7 | CI never decreases | Monotonic improvement only | Each pipeline step can only refine understanding, never degrade it |
| 8 | Clarification uses S5 probes | Reuse existing elaboration probes for CI questions | No new question content needed — domain modules already have the right questions |

### Files Changed

| File | Change |
|------|--------|
| `reference/clarity-index.md` | NEW — CI model, signal mapping, scoring rubric, Proposal format |
| `domains/_schema.md` | Added S0 Signal Keywords section schema |
| `domains/_resolver.md` | Added Greenfield Inference resolution path |
| `domains/interfaces/*.md` (4 files) | Added S0 Signal Keywords |
| `domains/concerns/*.md` (6 files) | Added S0 Signal Keywords |
| `commands/init.md` | Added Proposal Mode (idea string → CI → Proposal → auto-chain) |
| `reference/state-schema.md` | Added CI fields to sdd-state.md schema |
| `commands/pipeline.md` | Added CI propagation check (Step 3a) |

---

## [2026-03-10] G8-G10 — v4 Remaining Items: i18n, SDK Contract Gap, UI Interaction Audit

Reviewed F006 v4 improvement document (16 items) against current codebase. Found 12/16 already addressed, 2 not addressed (#4 i18n, #7 UI interaction), 2 partially addressed (#6 SDK completeness, #16 SDK trust).

| # | Decision | Choice | Rationale |
|---|----------|--------|-----------|
| 1 | i18n Coverage in verify Phase 1 | Step 4: grep t() keys → cross-check all locale files → BLOCK on missing | F006: 7 keys missing from ko.json, only found by CDP. Build/test cannot catch i18n gaps |
| 2 | i18n Completeness in implement | Step 1b per-task: auto-add missing keys to all locales after UI tasks | Catch at implement time instead of verify time — cheaper to fix |
| 3 | SDK API Contract Gap pattern | New scan rules: missing execute/callback, loose type bypass (Record\<string, unknown\>) | F006: metadata-only objects silently ignored by AI SDK; F005: .d.ts said `output` exists but runtime said `undefined` |
| 4 | External SDK Type Trust Classification | High/Medium/Low trust → increasing defense requirements | Low-trust (stream events, experimental APIs) → mandatory debug log before coding |
| 5 | UI Interaction Surface Audit | B-3 checklist: hover area, timing, CSS vs state, scroll interference, popup occlusion | F006: message hover → Copy button flash. CSS group-hover resolved with 0 re-renders |

**Files**: verify-phases.md, injection/implement.md, injection/verify.md, lessons-learned.md, history.md

---

## [2026-03-10] README User-Facing Meaning Review

README was accurate but described mechanisms from an implementation perspective ("injection source: pre-context.md + entity-registry.md") rather than from a user perspective ("what does each command know about my project?"). Full review applied the user-facing meaning principle across 6 sections.

| # | Section | Change |
|---|---------|--------|
| 1 | Per-Command Context Injection | Reframed as "What Each Command Knows About Your Project" — user-facing table + technical detail in collapsible |
| 2 | Phase 2 Extraction Tables | Summarized as supported framework list + detail in collapsible |
| 3 | Foundation Gate | Added "validates project infrastructure once" explanation |
| 4 | Post-Feature Processing | Reframed as "What Happens Automatically Between Steps" with "Why" column |
| 5 | Aggregation Scripts | Reframed as "Checking Project Status" — user question → script mapping |
| 6 | "Using Artifacts without smart-sdd" | Consolidated duplicate: added speckit-prompt.md reference + collapsible manual table |
| 7 | Path Convention + Artifact Structure | Fixed `specs/history.md` → `history.md`, added `lessons-learned.md` |

**Files**: README.md, README.ko.md, history.md

---

## [2026-03-10] G7 — Integration Contracts: Cross-Feature Data Shape Verification

F005↔F006 integration gap: F003's ParameterBuilder expected `assistant.mcpMode/mcpServers`, but F006's useMCPStore stored data differently. No bridge was designed (plan), built (implement), or verified (verify). Root cause: pipeline treats Features as isolated units with no data shape contract at boundaries.

| # | Decision | Choice | Rationale |
|---|----------|--------|-----------|
| 1 | Integration Contracts in plan.md | Table defining Provider Shape ↔ Consumer Shape ↔ Bridge per cross-Feature boundary | Makes shape expectations explicit — implement knows what bridge to build, verify knows what to check |
| 2 | Integration Contract Data Shape Verification | Phase 2 Step 6: grep interface existence + check shape compatibility + verify bridge adapter | Catches missing bridges and shape mismatches before merge, at code level |
| 3 | Plan Review Display | Integration Contracts section shown alongside existing Architecture/Data Model/API sections | User reviews shape contracts before approving plan |
| 4 | Verify Checkpoint/Review Display | Integration contract results shown in Phase 2 section | User sees integration verification status before approving verify |

**Files**: injection/plan.md, verify-phases.md, injection/verify.md, lessons-learned.md, history.md

---

## [2026-03-10] G6 — SC Verification Matrix: Runtime Behavior Verification

F006 pipeline: verify did static checks + UI rendering confirmation, but never tested actual runtime behavior. SC-level verification (Phase 3 Step 3) only covered SCs mapped in the demo Coverage header — if coverage was low (F006: 1/10), most SCs got zero runtime testing.

| # | Decision | Choice | Rationale |
|---|----------|--------|-----------|
| 1 | SC Verification Planning | Step 0 in Phase 3: classify ALL SCs from spec.md into `cdp-auto` / `test-covered` / `external-dep` / `manual` | Prevents SCs from being silently skipped — every SC has an explicit classification and skip reason |
| 2 | Verification boundary | Define what Playwright CDP can/cannot automate (local UI ✅, external deps ❌, IPC ⚠️) | Gives agent clear rules for classification instead of ad-hoc judgment |
| 3 | Drive Step 3 from SC matrix | SC-level UI verification covers ALL `cdp-auto` SCs, not just those in demo Coverage header | Closes the gap where low demo coverage = low runtime verification |
| 4 | Coverage gate | Warn if effective coverage (cdp-auto + test-covered) / total < 50% | Makes low coverage visible — user can choose to expand verification or acknowledge |

**Files**: verify-phases.md, injection/verify.md, lessons-learned.md, history.md

---

## [2026-03-10] G5 — Verify Compaction-Safe Checkpoint + Lessons Learned

F006 pipeline: verify lost all Phase references after context compaction, causing Playwright CDP UI verification (Phases 3/3b) to be entirely skipped. Root cause: all 66 countermeasures assume "agent reads skill files" — context compaction breaks this premise.

| # | Decision | Choice | Rationale |
|---|----------|--------|-----------|
| 1 | Verify Progress Checkpoint in sdd-state.md | Phase-by-phase status table (`⏳ pending` / `✅ complete` / etc.) with `⚠️ RESUME FROM` pointer | sdd-state.md is always read at session start; survives compaction unlike in-memory progress |
| 2 | Resumption Protocol | Re-read verify-phases.md + injection/verify.md, continue from first pending Phase | Restores the procedural context that compaction destroyed |
| 3 | Lessons Learned file | `lessons-learned.md` (project root) documenting G1~G5 chronic problems + L1~L8 specific past lessons | Record-keeping only (like history.md) — NOT referenced by pipeline at runtime |
| 4 | Lifecycle: create → update → delete | Verify Progress created at start, updated per Phase, deleted on completion | No stale state between Features; final result recorded in Notes as before |

**Files**: state-schema.md, verify-phases.md, injection/verify.md, lessons-learned.md (new, project root), README.md, README.ko.md, history.md

---

## [2026-03-10] Verify-time Change Recording — Implementation Gap Classification

F006 pipeline: during verify, i18n keys were added to source — an implementation gap (missing behavior within existing FR/task scope), not a bug (wrong behavior). No formal process existed to classify and record such changes.

| # | Decision | Choice | Rationale |
|---|----------|--------|-----------|
| 1 | Extend Bug Fix Severity Rule | Add complementary "Verify-time Change Recording" section (not modifying the existing rule) | Bug Fix Severity Rule covers bugs; new section covers ALL source modifications including implementation gaps |
| 2 | Three change types | Bug Fix (Minor), Implementation Gap, Design Change | Distinguishes "wrong behavior" from "absent behavior within scope" from "beyond scope" — each has different routing |
| 3 | Recording requirement | All inline changes summarized in sdd-state.md Notes | Transparency + audit trail — prevents silent scope expansion during verify |
| 4 | Review Display section | "Verify-time Changes" block in injection/verify.md Review | User sees what was modified before approving verify results |

**Files**: verify-phases.md, injection/verify.md, history.md

---

## [2026-03-10] spec-kit Standalone Prompt — speckit-prompt.md

reverse-spec generates `speckit-prompt.md` for users who run spec-kit without smart-sdd. Provides the manual equivalent of smart-sdd's cross-Feature context injection.

| # | Decision | Choice | Rationale |
|---|----------|--------|-----------|
| 1 | Standalone prompt file | `specs/reverse-spec/speckit-prompt.md` generated as Phase 4-1 artifact | Lowers barrier — users benefit from reverse-spec artifacts without committing to smart-sdd |
| 2 | Per-command context guide | specify/plan/implement/verify each list which artifacts to read | Maps directly to smart-sdd's Assemble step — manual version of automated injection |
| 3 | Core injection only | Omits advanced checks (SBI cross-check, CSS Value Map, Pattern Compliance Scan) | Keep prompt actionable — advanced automation is smart-sdd's value proposition |
| 4 | CLAUDE.md integration | Prompt designed to be copied into project's CLAUDE.md | Ensures agent reads it automatically at session start |

**Files**: reverse-spec/templates/speckit-prompt-template.md (new), reverse-spec/commands/analyze.md, README.md, README.ko.md

---

## [2026-03-11] Cross-reference Fix + CLAUDE.md Rule 4 Sync + README File Map

Post-pull analysis (19 commits, 35 files, +2429/-549 lines) found 3 issues. Fixed all:

| # | Issue | Fix | Severity |
|---|-------|-----|----------|
| 1 | 6 broken relative paths in pipeline.md | `reference/` → `../reference/` (lines 174, 180, 184, 223, 508, 517) | 🔴 CRITICAL |
| 2 | CLAUDE.md Rule 4 said "Minor/Major" but verify-phases.md has 4-tier system | Updated to "4단계(Minor, Major-Implement, Major-Plan, Major-Spec)" | 🟡 MEDIUM |
| 3 | README had no file inventory | Added complete File Map table to README.md and README.ko.md, added convention to CLAUDE.md | Enhancement |

**Files**: pipeline.md, CLAUDE.md, README.md, README.ko.md

---

## [2026-03-09] Toolchain Pre-flight: Lint Tool Detection at Foundation Gate

ESLint not installed → verify Phase 1 "eslint: command not found" repeated at every Feature (F001, F004, F005). Root cause: no early detection of lint tool availability.

| # | Decision | Choice | Rationale |
|---|----------|--------|-----------|
| 1 | Detect once, cache result | Foundation Gate Toolchain Pre-flight detects lint/test/build tool availability → records in sdd-state.md `## Toolchain` section | Avoids re-discovering same "command not found" error at every Feature verify |
| 2 | Lint detection rules per ecosystem | `domains/app.md` § 3b defines priority-ordered detection for Node.js, Python, Go, Rust | "Detect lint tool from project config" was too vague — agent had no algorithm to follow |
| 3 | Tool-not-found ≠ lint failure | verify Phase 1 distinguishes exit 127 (toolchain issue, non-blocking) from exit 1 (code quality, blocking) | "eslint: command not found" is not a code quality problem — it should not block the pipeline |
| 4 | Toolchain is WARNING, not BLOCKING | Missing lint tool displays ⚠️ + install guidance but does not block Foundation Gate | Matches existing Foundation Gate pattern (only Build is BLOCKING). Users may intentionally not use a linter |
| 5 | Backward compatibility | If sdd-state.md has no `## Toolchain` section, verify Phase 1 falls through to on-the-fly detection | Existing projects without Foundation Gate results continue to work as before |

**Files**: state-schema.md, domains/app.md, pipeline.md, verify-phases.md, injection/verify.md, injection/adopt-verify.md

---

## [2026-03-09] Cross-file Consistency Fix — 9 issues (7 critical + 2 bugs)

Post W1-W10 cross-file consistency audit found 12 issues. Fixed 9 (critical + bugs):

**Downstream flow breaks fixed (7 critical)**:
- injection/tasks.md: Added 4 new task injection checks (Interaction Chain, UX Behavior Contract, API Compatibility Matrix, SDK Migration) — tasks.md now receives and enforces downstream guidance from plan.md
- injection/implement.md: Added 3 new Read Targets + injection sections (Interaction Chains, UX Behavior Contract, API Compatibility Matrix) — implement now receives chain/contract/matrix context per task
- verify-phases.md: Added Step 5 (API Compatibility Matrix Verification) — per-provider auth/endpoint/response grep check

**Reference bugs fixed (2)**:
- injection/plan.md: UX Behavior Contract downstream flow said "Phase 3" → fixed to "Phase 2 Step 3b"
- verify-phases.md: Added temporal verb MCP mappings (wait-for, verify-scroll, trigger) to Step 3 and Step 6b

**Deferred (3 minor)**: Phase 3 checklist Step 3b missing, verify-scroll "not-bottom" mapping, css-value-map isolated to implement

---

## [2026-03-09] W10: Async UX Behavior Chains + UX Behavior Contract

Interaction Chains (V2) covered synchronous state propagation (click→handler→store→DOM) but missed temporal/async UX patterns — streaming auto-scroll, loading state transitions, error recovery, cleanup on unmount. These caused real bugs (e.g., chat doesn't scroll during streaming, spinner never disappears, memory leak on unmount).

Changes:
1. **Async-flow rows in Interaction Chains** (injection/plan.md) — `async-flow:` prefix for temporal UX behaviors (loading→streaming→complete→error states)
2. **UX Behavior Contract section** (injection/plan.md) — mandatory for UI Features with async operations. Documents expected temporal behavior, failure consequences, and verify methods
3. **Temporal verification verbs** (demo-standard.md, injection/implement.md) — `wait-for`, `wait-for ... gone`, `wait-for ... textContent`, `verify-scroll`, `trigger`. Extends VERIFY_STEPS with async-capable assertions
4. **UX Behavior Contract Verification** (verify-phases.md Step 3b) — grep for scroll, loading, error recovery, cleanup patterns. Runtime check via temporal verbs when Playwright available
5. **Checkpoint/Review Display update** (injection/verify.md) — UX behavior contract items shown in Phase 2

Key principle: "동작한다"의 기준을 "빌드 성공"에서 "실제 사용자 시나리오 통과"로 올리는 것.

---

## [2026-03-09] Pipeline v3: MCP-Independent Verification & Structural Enforcement — 9 changes (W1-W9)

Post-V1-V9 analysis revealed ~70% of Pipeline v2 value depends on MCP availability. Without MCP, Tier 2/3 SC verification, VERIFY_STEPS, Foundation Gate runtime checks are all silently skipped. Additionally, agent compliance with "MUST" rules lacks structural enforcement, and cross-Feature functional dependencies aren't checked until Integration Demo.

| # | Change | File(s) | Impact |
|---|--------|---------|--------|
| W1 | Playwright CLI Fallback for VERIFY_STEPS & SC verification | verify-phases.md, demo-standard.md, injection/implement.md | `npx playwright test` as MCP-independent fallback; generates `demos/verify/F00N-name.spec.ts` |
| W2 | Foundation Test File Generation (MCP-independent) | pipeline.md | Auto-generates `tests/foundation.spec.ts`; 3-tier fallback: Playwright CLI → MCP → build-only |
| W3 | Pattern Scan unconditional (remove RUNTIME-DEGRADED skip) | injection/implement.md | Static analysis runs ALWAYS; enhanced mode when RUNTIME-DEGRADED (promoted severity, extra patterns) |
| W4 | CSS Value Map Compliance Scan | injection/implement.md | Grep-based verification that css-value-map.md utility classes are actually used (not hardcoded) |
| W5 | Interaction Chain Completeness Check at verify | verify-phases.md | Greps for Handler→Store→DOM chain existence; broken chains = ⚠️ warning |
| W6 | Cross-Feature Enablement Smoke Test at verify | verify-phases.md, injection/verify.md | Verifies "Enables →" interfaces + "Blocked by ←" prerequisites at individual Feature verify |
| W7 | Enhanced Stability Window (multi-probe) | demo-standard.md | 3 probes × 5s = 15s; runtime error scan during stability window |
| W8 | API Compatibility Matrix + SDK Migration Awareness at plan | injection/plan.md, injection/specify.md | Per-provider auth/endpoint/header matrix; SDK breaking changes documentation; multi-provider SC coverage |
| W9 | Runtime Error Zero Gate at implement completion | injection/implement.md | BLOCKING gate: console errors = 0 required; Auto-Fix Loop + HARD STOP if errors persist |

Key design decisions:
- W1/W2 use same Playwright engine via CLI (`npx playwright test`) — no MCP dependency for functional verification
- W3 promotes warnings to HIGH severity when RUNTIME-DEGRADED — static analysis is last defense
- W5/W6 are grep-based (no MCP needed) for code existence checks; runtime smoke tests are MCP-optional
- W8 adds SDK Migration Awareness (not in original plan) — catches `textDelta→text` style breaking changes at plan time
- W9 HARD STOP follows MANDATORY RULE 1 pattern; respects RUNTIME-DEGRADED gracefully (skip gate, not fail)

---

## [2026-03-09] Pipeline v2: "Build Success ≠ Feature Complete" Root Fix — 9 changes (V1-V9)

Root problem: F004/F005 verified successfully but didn't work at runtime. 4 of 6 bugs were invisible to automated checks (build/test). Two remaining gaps after S1-S15: (A) Functional verification — verify checks "element visible?" but not "button works?", (B) Foundation — 7/7 bugs were Foundation-level issues (CSS theme, Zustand patterns, IPC bridge, layout) with no pre-Feature validation.

| # | Change | File(s) | Impact |
|---|--------|---------|--------|
| V1 | 3-Tier Functional SC Verification (Presence→State→Effect) | verify-phases.md, demo-standard.md | Extends verify beyond "element visible?" to check state changes and side effects |
| V2 | Interaction Chains (Side Effect Chain at plan) | injection/plan.md | Documents full propagation path: User Action→Handler→Store→DOM→Visual→Verify |
| V3 | CSS Value Map Generation (style-tokens→utility mapping) | injection/implement.md | Explicit original CSS value→Tailwind utility class mapping; no more guessing |
| V4 | Demo Functional Verification (`--verify` flag + VERIFY_STEPS) | demo-standard.md, verify-phases.md | Playwright MCP replays VERIFY_STEPS block for automated functional verification |
| V5 | Edge Case Matrix at specify | injection/specify.md | Structured edge case→SC coverage table; warns on uncovered edge cases |
| V6 | Cross-Feature Functional Enablement Chain | pre-context-template.md, injection/specify.md | Runtime behavioral dependencies (not just entity/API) between Features |
| V7 | Foundation Verification Gate (pre-Feature validation) | pipeline.md | Validates CSS theme, state management, IPC, layout BEFORE first Feature |
| V8 | Plugin/Dependency Pre-flight at implement | injection/implement.md | Checks plan.md dependencies against package.json before writing code |
| V9 | Verify Pipeline Regression Routing (4-level severity) | verify-phases.md, injection/verify.md | Routes verify feedback to correct stage: Minor (inline) / Major-Implement / Major-Plan / Major-Spec |

Key design decisions:
- V1 Tier 2/3 failures are **warnings** (not blocking) — same severity as existing SC failures
- V7 runs ONCE before first Feature; only Build check is BLOCKING, others are warnings
- V8 uses HARD STOP for missing dependencies (follows MANDATORY RULE 1)
- V9 preserves existing Bug Fix Severity Rule structure (per CLAUDE.md rule 4), extends from 2-level to 4-level

---

## [2026-03-09] HARD STOP audit — re-ask text + explicit options

Full audit of 56 HARD STOP points. Found and fixed 16 issues:
- 12 injection files' Review HARD STOPs: added inline `**If response is empty → re-ask** (per MANDATORY RULE 1)` text
- pipeline.md constitution incremental update: added explicit options ("Approve constitution update", "Reject", "Request modifications")
- init.md constitution seed checkpoint: added CheckpointApproval procedure reference + explicit options
- adopt.md environment config: added AskUserQuestion options ("I've created .env — continue", "Skip environment setup")
- reset.md uncommitted changes: added re-ask text
- verify.md Integration Demo trigger: added re-ask text

---

## [2026-03-09] Post-Execution Output Suppression — per-command inline reinforcement

Root cause: Agent showed spec-kit's "Ready for /speckit.clarify or /speckit.plan." message after speckit-specify instead of smart-sdd's fallback message. pipeline.md had suppression rules (lines 99-108), but per-command injection files had no inline reminder — agent ignored the generic rules at execution time.

Fix: Added `⚠️ SUPPRESS spec-kit output` inline blockquote to all 10 injection files' Review Display Content sections + shared pattern in context-injection-rules.md. Each reminder includes the specific fallback message format: `✅ [command] executed for [FID].\n💡 Type "continue" to review the results.`

---

## [2026-03-09] Specify/Tasks/Implement Accuracy Guards — 4 additional changes

Root cause (continued): Even with S1-S11 source reference + MCP improvements, pipeline still lacked accuracy verification at key handoff points. SBI text can be misinterpreted without cross-checking actual source (e.g., "3 tabs" vs "2 tabs"); tasks can be under-scoped relative to original complexity; components can be "implemented" as `() => null` stubs.

| # | Change | File(s) | Impact |
|---|--------|---------|--------|
| S12 | SBI Accuracy Cross-Check + Platform Constraint FR Verification | injection/specify.md | Catches SBI misinterpretation (tab count, conditional views) and missing platform FRs |
| S13 | Visual Verification Task injection | injection/tasks.md | Warns if UI rebuild tasks.md has no visual comparison task |
| S14 | Stub/Empty Implementation Detection | injection/implement.md | Detects `() => null`, `return null`, `// TODO` in grep scan |
| S15 | Source Complexity Annotation | injection/tasks.md | Shows original file sizes → helps estimate if tasks are under-scoped |

---

## [2026-03-09] Source Reference Pipeline & Playwright MCP Active Use — 11 supplementary changes

Root cause: F005-chat-ui post-mortem revealed TWO additional gap categories beyond runtime verification. (A) Information supply gaps: agent can't fix what it can't see — original source files invisible during implement, platform constraints not propagated, no concrete CSS values, coarse component mapping. (B) Playwright MCP structural gaps: 3-way dependency (App → MCP → Session) order matters, initial ToolSearch failure becomes permanent, no CDP diagnostic, no UI fix escalation.

| # | Change | File(s) | Impact |
|---|--------|---------|--------|
| S1 | Source Reference Active Read during implement | injection/implement.md | Original source files read before each task for rebuild fidelity |
| S2 | Platform Constraint dependency type + propagation | roadmap-template.md, pre-context-template.md, analyze.md | `frame:false` → `app-region:drag` propagated to downstream Features |
| S3 | Style Token Extraction during Phase 1.5 | analyze.md, injection/implement.md | Concrete CSS values (colors, spacing, fonts) extracted via browser_evaluate |
| S4 | Component-to-Source Mapping (Rebuild Target) | pre-context-template.md, analyze.md, injection/plan.md | Original files mapped to planned target paths for task matching |
| S5 | CDP Endpoint Diagnostic Fallback | verify-phases.md, analyze.md | `curl localhost:9222` diagnostic before generic "install MCP" dead end |
| S6 | Verify Phase 0: Build + App Start before MCP check | verify-phases.md | App running before MCP detection → tools load correctly |
| S7 | UI Fix Escalation Principle | injection/implement.md | 2+ failed code-reasoning fixes → re-check MCP/CDP availability |
| S8 | MCP-GUIDE.md CDP troubleshooting | MCP-GUIDE.md | "Connected" confusion, CDP order, 5-row troubleshooting table |
| S9 | SKILL.md Electron CDP prerequisites | smart-sdd/SKILL.md | Explicit Electron CDP install command + start order warning |
| S10 | Implement-time Playwright MUST/SHOULD/MAY | injection/implement.md | Playwright not verify-only: MUST/SHOULD/MAY usage classification |
| S11 | RUNTIME-DEGRADED in state-schema | state-schema.md | Special flags documented: RUNTIME-DEGRADED, NEVER-RUNTIME-VERIFIED |

Design constraint: MCP-GUIDE.md line 246 warns file-based MCP detection is unreliable. CDP diagnostic uses `curl` (runtime check), not config file reading.

---

## [2026-03-09] Runtime-First Verification & Visual Fidelity — 9 changes across pipeline

Root cause: F005-chat-ui passed full pipeline but app didn't work (Zustand selector instability → infinite re-render, useEffect DOM flicker). Verify equated "build passes" with "app works."

| # | Change | File(s) | Impact |
|---|--------|---------|--------|
| 1 | Pattern Constraints mandatory in plan.md output | injection/plan.md | Stack-generic framework interaction patterns (selector stability, layout effect timing, Error Boundary) |
| 2 | MCP degradation → HARD STOP (was silent warning) | injection/implement.md, verify-phases.md | Prevents Features from shipping with zero runtime verification unnoticed |
| 3 | Demo --ci captures browser console errors | demo-standard.md, verify-phases.md | Catches client-side-only bugs (infinite re-renders) that health endpoints miss |
| 4 | Pattern Audit + Integration Test task injection warnings | injection/tasks.md | Warns if tasks.md lacks audit or render test tasks |
| 5 | Post-implement anti-pattern grep scan | injection/implement.md | Automated detection of selector instability, DOM timing, missing Error Boundary |
| 6 | Runtime-First Verification principle in constitution | constitution-seed-template.md | "Build passes ≠ app works" as foundational principle |
| 7 | Feature size warning (100+ tasks, 50+ files) | injection/tasks.md | Soft warning for oversized Features that risk pattern inconsistency |
| 8 | Visual Reference Capture + Fidelity Check (rebuild) | reverse-spec/analyze.md, verify-phases.md | Screenshots of original app → compare against rebuilt UI in verify |
| 9 | Pattern Reference injection for parallel agents | injection/implement.md | Each agent receives Pattern Constraints to maintain consistency |

---

## [2026-03-09] smart-sdd — Single-Feature pipeline default + remove Step Mode

| # | Decision | Choice | Rationale |
|---|----------|--------|-----------|
| 1 | Single-Feature default | `pipeline` processes ONE Feature at a time by default | User only needed F003 but `--start verify` re-ran all 3 completed Features. Single-Feature default gives precise control without requiring `--only` flags |
| 2 | Feature targeting | `pipeline F003` targets a specific Feature; `pipeline --all` for batch mode | Replaces old behavior where pipeline always processed all Features. Simple, composable syntax |
| 3 | Step Mode removal | Removed 7 step-mode commands (specify, plan, tasks, analyze, implement, verify + step mode section) | `pipeline F003 --start verify` fully replaces `/smart-sdd verify F003`. Reduces 10 entry points to 3 (pipeline, pipeline [FID], constitution) |
| 4 | Feature auto-selection | Without FID: picks first in_progress → restructured → pending Feature | Intuitive "resume where you left off" behavior. No ambiguity about which Feature to process |

---

## [2026-03-09] smart-sdd — Fix --start to force re-execute named step

| # | Decision | Choice | Rationale |
|---|----------|--------|-----------|
| 1 | --start re-execution | `--start <step>` now forces re-execution of the named step even if already ✅ | User ran `--start verify` for F003 but pipeline skipped to merge because verify was ✅. The whole point of `--start` is to re-run from a specific step — skipping it defeated the purpose |
| 2 | Step marking | Already-✅ steps at `--start` are marked 🔀 before re-executing | Consistent with existing restructured-step semantics. Steps AFTER the named step are also re-executed |
| 3 | Feature ID ordering fix | Changed reverse-spec ID assignment from "RG-first, Tier within RG" to "Tier-first globally, RG within Tier" | Old rule produced F003(T1)→F004(T2)→F005(T1), causing gaps in T1-only pipeline (F003→F005 skip). New rule: all T1 first→all T2→all T3, so pipeline execution is always sequential with no gaps at any Tier activation level |

---

## [2026-03-09] smart-sdd — Demote restructure command to reference guide

| # | Decision | Choice | Rationale |
|---|----------|--------|-----------|
| 1 | restructure complexity | Convert from 6-phase automated command to reference checklist | 233-line command with heavyweight impact analysis added disproportionate complexity for a rarely-used operation. Most restructure operations (especially on pending Features) only need roadmap.md + pre-context edits |
| 2 | Knowledge preservation | Keep ID Stability Policy, Re-Execution Rules, Artifact Checklist in `reference/restructure-guide.md` | The restructure knowledge (what artifacts to update, re-execution rules) is valuable as a reference — the automated orchestration was overkill |
| 3 | Pipeline integration | Keep `restructured` status + 🔀 markers in state-schema and pipeline | Features can still be marked restructured and re-executed; the pipeline already handles this. Only the dedicated command entry point was removed |

---

## [2026-03-09] smart-sdd — UX: friendly continuation prompts

| # | Decision | Choice | Rationale |
|---|----------|--------|-----------|
| 1 | Suppress spec-kit messages | Add explicit pattern list to SUPPRESS rule | spec-kit's "Ready for /speckit.clarify" messages were leaking to users, causing confusion about what to do next |
| 2 | Step Mode completion | Add Step Mode Completion section with progress bar + next-step mapping | Step Mode had no post-completion guidance (unlike Pipeline Mode). Users didn't know what to do after a step finished |
| 3 | Universal "continue" | All pause/completion messages now offer `💡 Type "continue"` as primary action | One-word action is easier than remembering command syntax. Applied consistently across pipeline, init, expand, restructure-guide, parity |

---

## [2026-03-08] smart-sdd add — Vertical Slice Check in Phase 3

| # | Decision | Choice | Rationale |
|---|----------|--------|-----------|
| 1 | Backend-only Feature detection | Add Vertical Slice Check (step 3b) to Phase 3 Scope Negotiation | F002 was defined with full backend (stores, factories, IPC) but zero UI. Playwright verify had nothing to test. Detecting this at add-time prevents incomplete vertical slices |
| 2 | Enforcement level | Warning + option (not blocker) | Some Features are legitimately backend-only (libraries, infrastructure). The check surfaces the gap for user decision, doesn't block |
| 3 | UI Completeness probe | Add to app.md § 5 Perspective 4 | Surfaces the "do you need UI?" question during Phase 1 elaboration, before scope is finalized |
| 4 | Gap signal update | Strengthen Perspective 4 gap signal in feature-elaboration-framework.md | Explicitly flags the "stores/services defined but no UI touchpoints" pattern |

---

## [2026-03-08] smart-sdd verify — Promote Step 2b to Step 3 with mandatory checklist

| # | Decision | Choice | Rationale |
|---|----------|--------|-----------|
| 1 | Step 2b sub-step naming | Renumber to Step 3 (independent top-level step) | Agent skipped "Step 2b" entirely — sub-step numbering signals optional/supplementary. Promoting to Step 3 makes it equal to other steps |
| 2 | Phase 3 checklist | Add explicit 7-item checklist at top of Phase 3 | Agent jumped from Step 1 straight to demo --ci execution (Step 5), skipping Steps 2b, 3, 4, and Phase 3b. Checklist forces sequential completion |
| 3 | Cross-references | Update ui-testing-integration.md + demo-standard.md | "Step 2b" references updated to "Phase 3 Step 3". history.md entries kept as-is (historical record) |

---

## [2026-03-08] smart-sdd verify — Bug Fix Severity Rule (Minor vs Major)

| # | Decision | Choice | Rationale |
|---|----------|--------|-----------|
| 1 | Verify-phase code fixes | Severity-based: Minor = fix inline, Major = return to implement | Verify-phase fixes bypass spec/plan/tasks and have no checkpoint/review. Quick-patching a Major issue (e.g., frozen object pattern, service architecture) leads to suboptimal code that works but accumulates tech debt. |
| 2 | Major threshold | 3+ files touched, public API change, or architectural reasoning required | Simple heuristic to distinguish "add the missing line" from "restructure the approach." User can override to Minor if they disagree. |

---

## [2026-03-08] smart-sdd verify — Agent-managed app lifecycle for UI verification

| # | Decision | Choice | Rationale |
|---|----------|--------|-----------|
| 1 | App lifecycle ownership | Agent starts/stops the app — never asks the user to manually start, restart, or stop | Session B agent asked user to run `npx electron-vite dev -- --remote-debugging-port=9222` manually and wait. This is unnecessary friction — the agent can start the app itself via Bash, wait for it to be ready, then verify. |
| 2 | Case B — no HARD STOP needed | CDP configured + app not running → agent auto-starts the app (no user action required) | Previous design had a HARD STOP for Case B, but the user has nothing to decide — CDP is already configured, the agent just needs to start the app with the correct flags. Only Case A (CDP not configured) requires user action (reconfiguring Playwright MCP). |
| 3 | CDP probe timing | Probe runs twice: (1) before app launch to detect configuration, (2) after app launch to confirm connection | Single probe before app launch always fails for Case B (app not running), leading to false "standard mode" detection or unnecessary user interaction. |
| 4 | HARD STOP bypass prevention | Kept anti-bypass language for Case A (the only case requiring user action) | Previous bypass issues with health-check rationalization still apply to Case A. |
| 5 | "Non-blocking" clarification | Kept: results don't block verify, but verification itself cannot be skipped without user consent | Agent misinterpreted this in earlier session. |

---

## [2026-03-08] smart-sdd verify — Add Electron CDP check with user choice

| # | Decision | Choice | Rationale |
|---|----------|--------|-----------|
| 1 | Electron CDP detection in verify | Added `browser_snapshot` probe + HARD STOP with user choice | Electron apps require CDP for Playwright UI verification. Without CDP, Playwright opens a separate Chromium browser that cannot interact with the Electron window. User gets explicit choice: configure CDP or skip UI verification. |
| 2 | User choice design | "CDP 설정 후 재시도" vs "UI 검증 Skip" | User must explicitly decide — auto-skipping hides the fact that UI wasn't verified; forcing CDP setup blocks users who just want health-check-only verification. |

---

## [2026-03-08] reverse-spec Completion — Add CDP cleanup notice

| # | Decision | Choice | Rationale |
|---|----------|--------|-----------|
| 1 | CDP mode cleanup | Added Playwright MCP CDP restore notice at Phase 4-5 Completion Checkpoint | After reverse-spec completes with Electron CDP exploration, Playwright MCP remains in CDP mode (`--cdp-endpoint`). If user starts `/smart-sdd pipeline` without restoring standard mode, Playwright will fail to connect (no Electron app on port 9222). The notice reminds users to restore standard browser mode before proceeding. |

---

## [2026-03-08] README — Remove `<details>` collapsible tags for Confluence compatibility

| # | Decision | Choice | Rationale |
|---|----------|--------|-----------|
| 1 | `<details>` tags | Removed from both READMEs | `<details>` HTML tags are not supported in Confluence wiki pages. Converted `<summary><h2>` to regular `## ` headings for universal compatibility. |

---

## [2026-03-08] Playwright MCP Detection — Config File Read → Tool List Check

| # | Decision | Choice | Rationale |
|---|----------|--------|-----------|
| 1 | Detection method | Tool list check instead of config file read | Config file location varies by install method (CLI `claude mcp add`, plugin marketplace, manual). `settings.json`/`settings.local.json` check was failing because Playwright was installed as a marketplace plugin (stored in `~/.claude/plugins/`), not in `settings.json`. Checking available tools is the only reliable method. |
| 2 | CDP detection | `browser_snapshot` behavioral probe instead of config file read | Same root cause — `mcpServers.playwright.args` check in `settings.json` fails for plugin-installed Playwright. Calling `browser_snapshot` and examining content (Electron app vs blank page) is 100% reliable. |
| 3 | CDP pre-setup flow | Skip 1.5-4 (app launch) when `electron_mode = cdp` | If `browser_snapshot` already shows Electron app content, app is running and CDP is connected. No need to launch again. |
| 4 | MCP-GUIDE.md | Added warning against config file detection, documented behavioral detection | Prevent future agents from reverting to config file reads |

### Previous Session B Fixes (superseded by above)

| # | File | Fix |
|---|------|-----|
| 1 | `reverse-spec/analyze.md` Step 1c | CDP verification: replaced `browser_navigate` test with MCP config file read — deterministic, works before app launch, avoids agent navigating to CDP URL itself |
| 2 | `reverse-spec/analyze.md` Phase 1.5-0 | Moved CDP config check from Step 1c (after user choice) to Phase 1.5-0 Step 1b (before user choice) — avoids wasting user time selecting "Run" only to be told CDP isn't configured |
| 3 | `reverse-spec/analyze.md` Phase 1.5-0 | Auto-reconfigure: agent runs `claude mcp remove/add` commands automatically instead of telling user to do it manually. User only needs to restart Claude Code. |

---

## [2026-03-08] Pipeline Gap Analysis & Runtime Verification

### Pipeline Gap Resolution (G1–G7)

| Decision | Choice | Rationale |
|----------|--------|-----------|
| G1+G2: Runtime Exploration injection | Add runtime-exploration.md consumption to specify/plan injection | UI observations (layouts, flows, errors) must inform FR/SC drafts and component design |
| G3: Route→Feature Mapping | Define transitive mapping: route → page component → module → Feature | Phase 4-2 stated "distribute via mapping" but never defined the algorithm |
| G4: Runtime Verification + Fix Loop | Per-task build gate + runtime check in implement, with auto-fix (max 3 attempts) | implement generating code without running it caused bug explosion at verify time |
| G5: MCP Required Policy | Replace silent-skip with HARD STOP when MCP is absent | Silent skip was inconsistent with MCP required policy; users must know UI verification is skipped |
| G6: Electron Crash Recovery | HARD STOP with 3 options: restart + continue, proceed with collected data, skip | Exploration data loss on crash was unrecoverable without explicit recovery mechanism |
| G7: SBI Filtering Process | Explicitly document Phase 2-6 global → Phase 4-2 per-Feature filtering | Process was implicit, causing confusion about when B### IDs are assigned |

### Runtime Verification Architecture

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Per-task vs. end-of-implement verification | Both: per-task build gate + post-implement full SC verification | Per-task catches errors early; post-implement ensures no regressions |
| Auto-Fix Loop limit | Max 3 attempts per error, break on same error repeat | Prevents infinite loops while allowing automatic recovery from common issues |
| MCP-dependent verification | Level 1 (build only) without MCP, Level 2 (runtime) with MCP | Graceful degradation — still valuable without MCP, enhanced with it |

### SC→UI Action Mapping & Auto Verification

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Coverage header format | SC-level with UI actions (navigate → fill → click → verify) | FR-level coverage was too coarse for automated verification |
| UI verification result classification | All warnings, NOT blocking | False positives from selector changes make blocking unreliable |
| App session management | Start once, Navigate for screen switching, stop after phase completes | Avoids expensive app restart between each SC verification |

### Bug Prevention Rules (B-1~4)

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Per-stage prevention | B-1 (plan), B-2 (analyze), B-3 (implement), B-4 (verify) | Each stage has unique bug categories; prevention is more efficient than detection |
| B-4 Empty State Smoke Test | Warning, not blocking | Stability check should not gate verification — informational for developer awareness |
| Bug Prevention reference in domains/app.md | Stage-to-check mapping table | Central reference for which checks apply at which pipeline stage |

### Language Policy

| Decision | Choice | Rationale |
|----------|--------|-----------|
| All artifacts in English | English for all files except README.ko.md | Consistency and broader accessibility; Korean-only README.ko.md preserved for Korean users |

### MCP Capability Map

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Abstract MCP capabilities | Map generic capabilities (Navigate, Snapshot, Click, Type, Console) to MCP-specific tool names | Future-proofs against MCP tool changes; supports Tauri MCP extension |
| MCP-GUIDE.md as central reference | Single file for all MCP configuration and capability mapping | Prevents MCP-specific details from scattering across multiple skill files |

---

## [2026-03-08] Cross-File Consistency Fixes

> 11 issues found during comprehensive flow review (4 parallel audits).

| # | Severity | File | Fix |
|---|----------|------|-----|
| 1 | BROKEN | `injection/implement.md` | MCP-GUIDE.md link path: `../../../../` → `../../../../../` |
| 2 | HIGH | `injection/analyze.md` | B-2 result classification added: ⚠️ warning (NOT blocking) |
| 3 | HIGH | `injection/implement.md` | B-3 result classification added: ⚠️ warning (NOT blocking) |
| 4 | MEDIUM | `injection/implement.md` | MCP absent: added explicit `⚠️` warning message (was silent degradation) |
| 5 | MEDIUM | `injection/implement.md` | Review Display: removed "Test Results" section (tests run in verify, not implement) |
| 6 | MEDIUM | `domains/app.md` §7 | B-rule naming aligned with actual section headings (4 items) |
| 7 | MEDIUM | `domains/app.md` §6 | "screenshot" → "Snapshot" (Capability Map terminology) |
| 8 | MEDIUM | `reverse-spec/analyze.md` | MCP detection: 3-tool check → Capability Map Detect (browser_navigate only) |
| 9 | LOW | `pipeline.md` Step 5 | Added Demo-Ready Delivery and B-3 remind to implement summary |
| 10 | LOW | `pipeline.md` Step 6 | Added SC UI Verify and Phase 3b (B-4) to verify summary |
| 11 | LOW | `pre-context-template.md` | Skip notation unified: "N/A" → "Skipped — [reason]" |

### Design Decision

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Commit message language | English only (added to CLAUDE.md) | Consistency with English-first artifact policy |

---

## [2026-02-28] Initial Architecture

### Core Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Artifact path strategy | `specs/reverse-spec/` (CWD-relative) | Decouple from spec-kit's internal `.specify/` layout; write to user's CWD, not analyzed target |
| Wrapping vs. Forking | Wrap spec-kit commands, never replace | Immune to spec-kit updates; supplements via Constitution + artifacts |
| Feature ID ordering | Topological sort (dependency-based) | Ensures prerequisites are always built before dependents |
| Bilingual documentation | English source files + README.md / README.ko.md | Project originated in Korean; English added for broader reach |

### Initial Feature Set

| Decision | Choice | Details |
|----------|--------|---------|
| Two skills | reverse-spec + smart-sdd | reverse-spec extracts context; smart-sdd orchestrates pipeline |
| Operating mode | Brownfield rebuild only (initially) | Primary use case: re-implement existing codebase with spec-kit SDD |

---

## [2026-02-28] HARD STOP Philosophy Established

### Checkpoint / Review Design

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Human approval gates | Inescapable HARD STOPs at every Checkpoint and Review | User must retain control — AI cannot silently skip approval |
| Empty response handling | Re-ask if AskUserQuestion returns empty | Discovered that empty = silent bypass; mandatory re-ask prevents it |
| `--auto` mode | Skip confirmation display only, not approval logic | Power users need speed; safety rules still apply |
| `--dangerously-skip-permissions` | Use text message instead of AskUserQuestion | Environment limitation; still requires explicit response |

---

## [2026-02-28] Three Project Modes Introduced

### Mode Architecture

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Greenfield (`init`) | Interactive Q&A → empty Global Evolution Layer → pipeline | New projects need Feature definition from scratch |
| Brownfield incremental (`add`) | Inherit existing artifacts → add new Features → pipeline | Simplest mode — just extend what exists |
| Brownfield rebuild (`reverse-spec`) | Analyze existing code → full Global Evolution Layer → pipeline | Original mode; richest starting context |

---

## [2026-03-01] Demo-Ready Delivery Principle

### Demo Design

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Demo format | Executable script (`demos/F00N-name.sh`), NOT markdown docs | "Tests pass" is not a demo — user must see, use, and interact with the real Feature |
| Demo anti-patterns | Reject: test suites disguised as demos, markdown instructions, chat-only steps | Discovered agents repeatedly generated test scripts instead of real demos |
| `--ci` flag | Automated health check for verify Phase 3 | CI/CD needs non-interactive verification |
| Demo code markers | `@demo-only` (remove later) vs `@demo-scaffold` (extend later) | Separate throwaway demo code from promotable scaffolding |
| FR/SC coverage mapping | Demo script header maps to spec.md FR-###/SC-### | User sees what functionality they can experience |

---

## [2026-03-01] Scope System (Core vs Full)

### Scope Design

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Core scope | Tier-based phasing (T1 essential / T2 recommended / T3 optional) | Large codebases need incremental approach — focus on foundation first |
| Full scope | Pure topo-sort, no Tiers | Rebuild everything, no prioritization needed |
| 5-axis Tier analysis | Structural Foundation, Domain Core, Data Ownership, Integration Hub, Business Complexity | Single-axis classification was too simplistic; 5 axes capture nuance |
| `expand` command | Activate deferred Tiers incrementally | Users complete T1, then decide whether to proceed with T2/T3 |
| Feature ID assignment | Core: Tier-first then topo-sort; Full: pure topo-sort | Core needs all T1 before T2; Full just follows dependencies |

---

## [2026-03-01] Feature Granularity Selection

### Decomposition Design

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Granularity options | Coarse (domain-level) / Standard (module-level) / Fine (capability-level) | Same codebase can be decomposed at different levels; let user choose |
| Present with concrete lists | Show actual Feature names for each level, not just descriptions | Abstract descriptions ("fewer Features") are unhelpful; show the real trade-off |

---

## [2026-03-01] Stack Negotiation Protocol

### New Stack Design

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Per-category negotiation | One AskUserQuestion per tech category (Frontend, Backend, DB, etc.) | Batch selection leads to AI pre-filtering choices; per-category ensures user sees all options |
| Mandatory negotiation | Cannot skip categories, even with recommendations | Early design allowed AI to pre-filter "obvious" choices — this lost user control |
| `stack-migration.md` | Dedicated artifact for migration plan (new stack only) | Migration details don't belong in constitution-seed or pre-context |

---

## [2026-03-02] Pipeline Hardening

### Pipeline Design

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Execute+Review = one step | Merged into single continuous action | Discovered separating them created a gap where AI skipped Review entirely |
| Suppress spec-kit "Next step" | Prevent spec-kit output from triggering premature pipeline advancement | spec-kit's helpful output was causing the AI to auto-advance past Review |
| Per-Feature env var check | HARD STOP at each Feature's implement step | Global env check was too early; each Feature may need different variables |
| Pre-flight branch check | Ensure on main branch with clean state before each Feature | Features must start from main; dirty state causes merge conflicts |
| Feature branch management | Auto-create at specify, auto-merge at verify completion | Reduce manual git overhead |

---

## [2026-03-02] Feature Restructure Protocol

### Restructure Design

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Mid-pipeline restructuring | Allow split, merge, move, reorder, delete during pipeline | Real projects discover Feature boundaries are wrong after starting |
| Impact analysis | Auto-propagate changes to roadmap, registries, pre-context, sdd-state | Manual propagation across 5+ files is error-prone |
| Completed Feature deletion | Warning + confirmation only, no block | Users should be able to undo completed work, with awareness |

---

## [2026-03-03] Review System Overhaul

### Review Architecture

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Algorithmic ReviewApproval | Structured procedure replacing free-form review | Free-form reviews were inconsistently applied; algorithm ensures every artifact is shown |
| MANDATORY RULE banner | Top of SKILL.md, impossible to miss | Despite inline rules, agents still bypassed HARD STOPs; top-of-file banner fixed it |
| Constitution Phase 0 redesign | Prevent Review bypass by restructuring the flow | Original Phase 0 had a gap between execute and review where AI could skip ahead |

---

## [2026-03-03] Parity Checking System

### Parity Design

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Two gap types | Gap A (extraction miss) + Gap B (implementation miss) | Different root causes require different solutions |
| Coverage baseline (Phase 4-3) | Measure extraction coverage immediately after reverse-spec | Detect Gap A early, before pipeline starts |
| 5-phase parity command | Structural → Logic → Report → Remediation → Completion | Systematic approach instead of one-shot comparison |
| 6 exclusion reason codes | deprecated, replaced, third-party, deferred, out-of-scope, covered-differently | Structured reasons prevent "intentional exclusion" from becoming a catch-all |
| Cross-cutting dual treatment | Constitution update + infrastructure Feature | Rate limiting, CORS etc. need both architectural principle and actual code |

---

## [2026-03-04] speckit-diff Utility Skill

### Third Skill Design

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Independent utility | No dependency on reverse-spec or smart-sdd | Run anytime to check spec-kit compatibility |
| Structural signature comparison | Compare skill sections, templates, scripts, CLI flags, directories | Content-level diff is too noisy; structural signatures capture breaking changes |
| Stored baseline | `integration-surface.md` snapshot of last verified spec-kit | Enables offline comparison without re-analyzing spec-kit every time |
| P1/P2/P3 priority levels | Breaking / Compatibility / Enhancement | Not all changes are equal; prioritize what to fix first |

---

## [2026-03-04] Project Identity Renaming

### Renaming Design

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Prefix mapping | Collect old→new prefix pairs (e.g., "Cherry"→"Angdu") | Simple find-replace is insufficient; structured mapping ensures consistency |
| Apply to all artifacts | Roadmap, pre-context, constitution-seed, coverage baseline | Renaming must be pervasive; missed spots confuse agents |
| Coverage baseline flagging | Flag original-project-specific names as rename targets | Automated detection of names that need remapping |

---

## [2026-03-04] Fidelity Gap Solutions

### Source Behavior Inventory

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Function-level extraction | Phase 2-6: exported functions, public methods, handlers per file | Discovered 30-40% functionality loss in brownfield rebuild — structural extraction (entities, APIs) missed discrete behaviors |
| P1/P2/P3 priority | Core / Important / Nice-to-have per behavior | Not all behaviors are equal; P1 must map to FR-###, P3 can defer |
| Completeness check in verify | Phase 2 Step 2: per-Feature mini-parity (P1/P2 vs FR-###) | Catch unmapped behaviors before merge, not after full pipeline |

### UI Component Feature Extraction

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Library-level extraction | Phase 2-7: toolbar items, plugins, editing modes from third-party UI libs | Toast UI Editor toolbar, WYSIWYG mode etc. are invisible to function-level analysis but represent significant user-facing functionality |
| Configuration-based scanning | Read initialization code, not just exports | UI features are activated via library options/plugins, not exported as functions |
| Parity integration | Added to structural parity metrics | Without this, parity check would miss all library-provided features |

---

## [2026-03-04] Domain Profile System + Context Optimization

### Domain Profile Architecture

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Domain profile system | Swappable `domains/{domain}.md` profiles per skill | Web-app assumptions were hardcoded in SKILL.md; extensibility to data-science, AI/ML, embedded requires separating domain logic from core workflow |
| Default domain name | `app` (covers backend, frontend, fullstack, mobile, library) | More inclusive than "web-app"; a single profile covers the full application development spectrum |
| Single profile only | No multi-profile composition | Composition complexity outweighs benefit; hybrid domains (e.g., AI-serving) get dedicated profiles instead |
| CLI argument | `--domain app` (default) for both skills | Explicit over implicit; recorded in sdd-state.md for reproducibility |
| `data-science` template | Structure with `[TODO]` markers, no real logic | Establishes the pattern for future domain contributors without claiming to know data-science workflows |

### SKILL.md Context Optimization

| Decision | Choice | Rationale |
|----------|--------|-----------|
| smart-sdd command splitting | SKILL.md ~2,028→376 lines; commands in `commands/{cmd}.md` | SKILL.md is always loaded as system prompt — 80% reduction frees context window for actual work |
| Command dispatch table | Slim SKILL.md maps commands to reference files | Agent reads only the command file it needs, not all 2,028 lines |
| reverse-spec domain extraction | Domain-specific content → `domains/app.md` (~274 lines) | Core workflow (phases, HARD STOPs) stays in SKILL.md; analysis patterns are domain-swappable |
| Keep MANDATORY RULES in SKILL.md | Never move to reference files | Must be visible in system prompt — agents demonstrably ignore rules they have to "read later" |
| Common Protocol condensed | ~230→~50 lines in SKILL.md + detailed version in `commands/pipeline.md` | 4-step overview is always needed; checkpoint/review procedure details only needed during pipeline execution |

---

## [2026-03-04] Context Injection Rules Per-Command Split + Cross-File Consistency

### Context Injection Optimization

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Per-command injection files | `reference/injection/{command}.md` (8 files) | Monolithic `context-injection-rules.md` (1,190 lines) was loaded entirely for every pipeline step — only ~100-275 lines needed per command. Pipeline context cost dropped from 2,410 → 1,320-1,495 lines per step (~40% reduction) |
| Slim shared patterns file | `context-injection-rules.md` reduced to ~65 lines (shared patterns + dispatch table) | Shared patterns (HARD STOP, Checkpoint, Missing/Sparse Content Handling) needed by all commands; per-command details moved to injection files |
| Post-step update rules collocated | Each injection file includes its own update rules | Previously at the end of the monolith — now each command's rules are adjacent to its injection logic |

### Cross-File Consistency Fixes

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Feature Granularity table sync | init.md table updated to match reverse-spec's richer descriptions + cross-references added | init.md had simpler descriptions than reverse-spec; descriptions like "Good for small teams" were missing |
| Domain profile parity sync | reverse-spec `app.md` §8-9 updated to match smart-sdd `app.md` §2-3 structure | reverse-spec was missing Source behaviors, Test cases dimensions and Detection column in Verify Steps |
| Self-contained domain profiles | Both profiles remain independent (no cross-skill import) with cross-reference notes | Separation was intentional — reverse-spec for analysis, smart-sdd for execution. Cross-reference notes document the relationship without coupling |

## [2026-03-05] Unified commands/ Structure + case-study Skill

### Structural Unification

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Unified commands/ pattern | All 4 skills now use `SKILL.md` (slim routing) + `commands/*.md` (workflow detail) | Previously only smart-sdd had commands/ directory. reverse-spec (744 lines) and speckit-diff (370 lines) had all logic in SKILL.md. Unified for structural consistency and context efficiency |
| reverse-spec split | SKILL.md (~60 lines) + commands/analyze.md (~680 lines) | SKILL.md always loaded as system prompt — smaller footprint for relevance checking. Workflow only loaded on invocation |
| speckit-diff split | SKILL.md (~50 lines) + commands/diff.md (~320 lines) | Same rationale: slim routing + heavy implementation separated |

### case-study Skill

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Two-mode utility | `init` (create log + show protocol) + `generate` (read artifacts + produce report) | Non-invasive: no modification to reverse-spec or smart-sdd. Recording is a convention, not a forced hook |
| Hybrid data approach | Quantitative (auto-extracted from existing artifacts) + Qualitative (optional manual log) | Artifacts already capture metrics, timestamps, test results. Manual observations add context artifacts cannot provide (challenges, rationale, lessons) |
| 8-milestone recording protocol | M1-M8 covering key phases of reverse-spec and smart-sdd | Aligned with natural breakpoints in the SDD workflow. Each milestone maps to specific Case Study report sections |
| Language support | `--lang en\|ko` argument | Matches user's bilingual documentation pattern (README.md / README.ko.md) |
| 8-section Case Study agenda | Executive Summary → Background → Source Analysis → Architecture → Pipeline → Quality → Challenges → Outcomes | Covers both quantitative results (sections 3,5,6) and qualitative insights (sections 2,7,8). Section 1 provides at-a-glance summary |

## [2026-03-06] v2 Redesign — User Intent Model + Adoption + Demo + Coverage + Scripts

> Full design document: `v2-design.md` (removed)

### User Intent Redesign

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Intent-based mode selection | 5 user journeys replacing technical mode names | Users think "I want to adopt SDD" not "brownfield-incremental with scope=full, stack=same" |
| All paths → incremental | Every journey (init, adopt, rebuild) converges to incremental mode | Incremental is the steady state; other modes are bootstrapping |
| Adoption as distinct intent | Separate from Rebuild — keep existing code, add SDD docs | Current system forces "rebuild or nothing"; many users just want SDD governance on existing code |

### `adopt` Command

| Decision | Choice | Rationale |
|----------|--------|-----------|
| 4-step pipeline | specify → plan → analyze → verify (no tasks, no implement) | No code to write in adoption — steps only document and baseline |
| Adoption-specific injection | Each step gets distinct prompts: "extract what exists" not "define what to build" | spec-kit commands need different framing for adoption vs rebuild |
| `status: adopted` | New Feature status distinct from `completed` | Signals to incremental: "this Feature has code but may have legacy patterns" |
| Verify non-blocking | Test failures = pre-existing issues, not blockers | Adoption documents code as-is; failures aren't the agent's fault |
| Origin in sdd-state | `origin: adoption \| rebuild \| greenfield` at project level | Injection rules branch on origin; incremental knows what kind of codebase it's extending |

### Source Behavior Coverage

| Decision | Choice | Rationale |
|----------|--------|-----------|
| SBI unique IDs (B###) | Each behavior in Source Behavior Inventory gets a unique ID | Enables end-to-end tracing: B### → FR-### → implementation → verification |
| FR ↔ SBI mapping | `[source: B###]` tags in spec.md FR entries | Answers "which original behaviors are covered by this Feature?" |
| Coverage dashboard | sdd-state.md auto-updated after each verify | Running metric: "42/55 behaviors implemented (76%)" |
| P1 mandatory 100% | P1 behaviors must all be mapped regardless of scope mode | Core functionality must never be lost in rebuild/adoption |
| Deferred tracking | Unmapped P2/P3 → `deferred` → incremental candidates | Core completion naturally suggests what to add next |

### Demo Layering

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Three demo layers | Feature Demo → Integration Demo → Application Demo | Single-Feature demos can't show multi-Feature user journeys; layering addresses this |
| Feature demo types | standalone / infrastructure / enhancement | Infrastructure Features (DB, middleware) have no meaningful solo demo — skip to Integration |
| Demo groups | Defined in reverse-spec Phase 3, stored in roadmap.md | reverse-spec already understands code structure and can infer user journey groupings |
| Integration Demo trigger | All Features in group verified → HARD STOP | Ensures multi-Feature integration is tested, not just individual Features |
| Demo invalidation | Adding Feature to group → previous Integration Demo invalidated | Guarantees re-verification after group composition changes |

### Incremental Feature Consultation

| Decision | Choice | Rationale |
|----------|--------|-----------|
| 6-step consultation | Explore → Impact → Scope → SBI Match → Demo Group → Finalize | Current `add` is too simple (name+description); real Feature definition is collaborative |
| Script-assisted steps | Steps 2,4,5 use scripts for context gathering | Agent reads 40-line summary instead of 500+ lines of raw artifacts |
| SBI match conditional | Only for adoption/rebuild origin (greenfield has no SBI) | Greenfield projects don't have source behaviors to match against |
| HARD STOPs at Steps 2-6 | User confirms each decision point | Feature definition is too important for the agent to decide alone |

### Script Architecture

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Agent judges, scripts aggregate | Scripts handle counting/summarizing; agent handles decisions | Agent reading 10 files to count numbers wastes ~800 context lines per check |
| 5 scripts | context-summary, sbi-coverage, demo-status, pipeline-status, validate | Cover all aggregation needs; each saves 90%+ context vs agent reading raw files |
| Read-only, target-path argument | Scripts never modify artifacts; run from spec-kit-skills directory | No target project pollution; safe to run anytime |
| bash + grep/awk only | No external dependencies; fixed markdown patterns | Reliable parsing of known artifact table formats |

---

## [2026-03-06] Audit Fix — Case-Study Relative Path Correction

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Path depth fix | `adopt.md` (2곳) + `pipeline.md` (3곳): `../../../case-study/` → `../../case-study/` | `commands/` 하위 파일에서 `../../../`은 `.claude/` 레벨까지 올라가 잘못된 경로. `parity.md`는 이미 올바른 `../../`을 사용 중이었으므로 통일 |

---

## [2026-03-06] Context Efficiency Refactoring — Structural File Splitting

### Pipeline.md Split (#10a)

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Extract verify-phases.md | 134 lines → `commands/verify-phases.md` | Verify Phase 1-4 details loaded only during verify command, not every pipeline step |
| Replace branch-management.md stub | 3-line stub → 120 lines of full Git Branch Management | Merge workflow loaded only during merge step, not every pipeline step |
| Pipeline.md reduction | 855 → 608 lines (-29%) | ~3,000 tokens saved per non-verify pipeline step |

### Demo Standard Consolidation (#8)

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Create `reference/demo-standard.md` | Single source of truth for demo template, anti-patterns, requirements | Demo content was duplicated across 5+ files (implement.md, domains/app.md, verify.md, tasks.md, SKILL.md) |
| Trim implement.md | ~130 lines removed → 3-line reference | Full bash template + anti-patterns + Feature-type requirements moved to demo-standard.md |
| Keep SKILL.md Rule 2 intact | MANDATORY RULE stays in system prompt | Agents ignore rules they have to "read later" — same reasoning as original MANDATORY RULE banner decision |
| Integration Demo execution procedure | Added to demo-standard.md § 7 | Trigger HARD STOP existed in 6 files but execution procedure was never defined; agents wouldn't know what to do when user selects "Run Integration Demo" |

### Adoption Behavior Consolidation (#9)

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Reduce domains/app.md § 4 | 34 lines → 2-line reference to adopt.md + adopt-verify.md | Adoption behavior differences were fully duplicated; reference is sufficient since adoption files are loaded during adoption flow |
| Keep adopt-*.md self-contained | No extraction to shared file | Adopt injection files are loaded at different times; extracting to shared file would cause MORE loading |

### Display Format Compression — Not Pursued (#11)

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Do NOT compress display blocks | Confirmed not to proceed | Display format blocks serve dual purpose: formatting template + behavioral specification. Compressing them risks agents not knowing what to display, causing behavioral regressions |

### 4-Journey Audit

| Decision | Choice | Rationale |
|----------|--------|-----------|
| branch-management.md adoption note | Added `(or adopted — see adopt.md)` to merge display | Generic template showed `completed` for all modes; adoption mode uses `adopted` status |

---

## [2026-03-07] Audit — Status Command Extraction + MEMORY.md Update

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Extract status command | SKILL.md (355→313줄) → `commands/status.md` (42줄) | 다른 모든 명령은 `commands/*.md`로 분리되어 있었으나 status만 SKILL.md에 인라인. 분리 후 매 호출 시 시스템 프롬프트 12% 절감 |
| MEMORY.md 전면 갱신 | 2-skill → 4-skill 반영, 경로/아키텍처/v2 기능 업데이트 | speckit-diff, case-study 누락, sdd-state 경로 오류, 공통 프로토콜 단계 수 불일치 등 다수 부정확 수정 |

---

## [2026-03-07] add v3 Redesign — Universal Feature Definition + init Slimming

### Universal Feature Definition via `add`

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Universal feature definition | `add` handles all modes (greenfield, incremental, rebuild) | init's Feature definition and add's Feature definition were redundant — unifying through add ensures consistent quality across all modes |
| init slimming | init = project setup + constitution only (no Feature definition) | Feature definition delegated to add; init becomes lightweight. Phase count: 5 → 4 |
| Greenfield flow change | `init` → `add` → `pipeline` (was: `init` → `pipeline`) | Users define Features via add after init sets up the project skeleton |

### add v3 6-Phase Flow

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Draft file lifecycle | `specs/add-draft.md` created at Phase 1, deleted at Phase 6 | Enables session resume on interruption; provides inter-Phase data transfer. If file exists on next add invocation, offer resume or restart |
| Overlap checking (Phase 2) | Analyze Feature duplication, entity ownership conflict, API path overlap | Prevents defining Features that duplicate or conflict with existing ones. Skipped for first greenfield Feature |
| Constitution impact check | Embedded in Phase 2 as conditional lightweight check | Not worth a separate Phase — only fires when new technology/patterns detected. Displays warning + suggests `/smart-sdd constitution` update |
| SBI expansion (Phase 4) | Users can define NEW B### entries beyond original source | Original SBI only covers extracted behaviors; add-mode Features may introduce entirely new capabilities. NEW entries tagged with Origin=`new` to prevent original coverage metric pollution |
| Conditional FR drafts | SBI-mapped behaviors → FR draft in pre-context; no SBI → description only | Optimizes pre-context information density. Greenfield Features without SBI get leaner pre-context |
| Adaptive consultation (Phase 1) | 4 readiness types (A: vague, B: specific, C: PRD, D: extend existing) | Framework defined, detailed implementation deferred to follow-up iteration |

### init → add Chaining + PRD Support

| Decision | Choice | Rationale |
|----------|--------|-----------|
| init → add chaining | init Phase 4 asks "Define Features now?" → Yes chains into add flow | Eliminates the extra step of running add separately after init. User experience matches the old init-then-pipeline flow |
| add `--prd` argument | Per-invocation PRD path for Feature extraction (Phase 1 Type C) | Each add can reference a different requirements document. PRD is one-time input, not stored in sdd-state |
| PRD auto-forwarding | init `--prd` passes the same path to chained add | PRD specified once at init, Feature extraction happens automatically in add without re-specifying |
| init PRD vs add PRD | init extracts project meta (name, domain, stack); add extracts Feature candidates | Same document, different extraction targets — role separation is maintained |

### SBI Origin System

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Origin column | Added `Origin` column (`extracted` / `new`) to SBI Coverage table | Distinguishes behaviors from original source vs. user-defined new behaviors |
| Separate metrics | NEW entries excluded from P1/P2/P3 extracted coverage percentages | P1 100% mandate applies only to original source behaviors; NEW behaviors tracked separately |
| sbi-coverage.sh backward compat | Auto-detect Origin column presence; legacy format = all extracted | Existing projects without Origin column continue to work unchanged |

---

## [2026-03-07] Phase 1 Redesign — 3 Entry Types + Feature Elaboration Framework

### Phase 1 Entry Type Redesign

| Decision | Choice | Rationale |
|----------|--------|-----------|
| 3 entry types (was 4) | Type 1 (Document-based), Type 2 (Conversational), Type 3 (Gap-driven) | User-centric reframing: types differ only in HOW initial info is gathered. Old A+B merged into one spectrum (Type 2), old D absorbed by Phase 2 overlap check |
| Type D → Phase 2 | "Extend existing Feature" detected by Phase 2 overlap check, not Phase 1 type | D was a modifier, not an independent entry type. Any type can result in extending an existing Feature — Phase 2 handles this uniformly |
| Gap-driven type (Type 3) | New type for post-rebuild gap coverage (`--gap`) | Most important use case identified: rebuild completes but 13% functionality gap remains. Type 3 reverses the flow — starts from data (unmapped SBI/parity) instead of user intent |
| Auto gap detection | If unmapped P1/P2 behaviors exist → suggest Type 3 | Explicit `--gap` for intentional use + auto-detection for discovery. Prevents users from accidentally ignoring significant gaps |
| Type 3 → Phase 4 pre-mapping | Gap-driven Features arrive at Phase 4 pre-mapped | SBI selection already happened in Phase 1 (that's the entire basis of the Feature). Re-selecting in Phase 4 would be redundant |

### Feature Elaboration Framework

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Common elaboration step | All 3 types converge on perspective-based evaluation after initial gathering | Types differ in entry, but quality evaluation should be uniform. Ensures every Feature definition meets the same minimum bar |
| 6 perspectives | User & Purpose, Capabilities, Data, Interfaces, Quality, Boundaries | Covers all dimensions needed to scope a Feature. 1–4 required, 5–6 optional |
| Separate reference document | `reference/feature-elaboration-framework.md` | Separates "what to evaluate" from "how to gather" (the add.md flow logic). Reusable and independently maintainable |
| Domain extension via § 5 | `domains/{domain}.md` § 5 adds domain-specific probes | Base framework is domain-independent. Domain probes extend existing perspectives (not new ones). Follows established domain profile pattern (§ 1 Demo, § 2 Parity, § 3 Verify, § 4 Adoption, § 5 Elaboration) |
| Bilingual example questions | Korean example questions in framework | Helps Korean-speaking users; maintains project's bilingual pattern |

---

## [2026-03-07] Audit Fix — Phase 1 Redesign Cross-File Consistency

| Decision | Choice | Rationale |
|----------|--------|-----------|
| init.md Type refs | "Type C" → "Type 1", "Type A/B" → "Type 2" | Phase 1 redesign renamed types but init.md's chaining text was missed |
| README --gap | Added `--gap` to README.md usage block | Was present in SKILL.md and README.ko.md but missing from README.md usage block |
| README greenfield example | Updated to show init (Pre-Phase + 4 Phases) → add (6 Phases) chain | Example showed old init with inline Feature definition (Phase 2) which no longer exists |
| README incremental example | Updated to match add's 6-Phase structure | Example used old Phase numbering that didn't match add.md's actual flow |

---

## [2026-03-07] Pending Feature Cleanup + Catch-Up Workflow + Playwright Phase A

### Pending Feature Cleanup (add Pre-Check)

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Pending Feature review | add Pre-Check offers cleanup when both completed AND pending Features exist | Partial implementation from reverse-spec may leave stale pending Features; user should be able to clean them up before adding new ones |
| Cleanup scope | Only `pending` status — not `in_progress`, `completed`, or `adopted` | Active/done Features need `/smart-sdd restructure` for removal; add cleanup is for unstarted ones only |
| SBI unlinking | Cleaned-up Features' SBI entries return to `unmapped` status | Ensures gap detection (Type 3) can re-propose these behaviors for new Features |
| Type 3 unmapped filter | Explicitly filter to `unmapped` status only, exclude `in_progress` | `in_progress` behaviors are assigned to pending Features being worked on — they aren't truly "gaps" |

### Complete + Catch-Up Workflow

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Catch-up via parity + add --gap | `pipeline → parity --source updated → add --gap → pipeline` | Handles original source updates during rebuild. parity detects new gaps, add --gap covers them, pipeline implements |
| Incremental parity | Preserve previous decisions, only show new gaps | Avoids re-deciding already-handled gaps on each parity re-run |
| Re-run reverse-spec for large changes | Recommended when original has major refactoring or new modules | parity is lightweight (structural/logic comparison); reverse-spec is heavier but captures new SBI entries and registries |

### Playwright MCP Integration — Phase A

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Phase A scope | Hook points only — no core logic changes | LOW effort: verify Phase 3 gets UI check, demo scripts get Playwright header, domain profile gets hook table |
| Graceful degradation | All hooks check for Playwright MCP availability at runtime; absent → silent skip | No dependency on Playwright; existing behavior preserved when not available |
| verify Phase 3 Step 2b | After health check, navigate to demo URLs + screenshot + element check | Catches "server responds but UI doesn't render" issues that health checks miss |
| Demo script Playwright header | Optional `# Playwright` comment with URLs and element assertions | Informational when Playwright absent; actionable when present. Extends existing Coverage header pattern |
| Separate reference doc | `reference/ui-testing-integration.md` (~180 lines) | Too much content for domains/app.md; separate doc covers current usage, troubleshooting, and future roadmap (Phase B/C) |
| Future Phase B/C prerequisites | Original source must be runnable; Source Runnability Check needed in reverse-spec Pre-Phase | Static analysis doesn't need running source; visual parity and UI SBI extraction do. Check should be non-blocking (continues with static-only if not runnable) |

---

## Recurring Patterns

### Cross-File Consistency Challenge
At least 7 dedicated fix commits for cross-file inconsistencies. Root cause: multi-file skill architecture where changes in one file silently invalidate assumptions in others. Mitigated by comprehensive audit passes but remains an ongoing concern.

### spec-kit CLI Integration (Trial and Error)
Binary name: `specify` (not `speckit`). Skill names: `speckit-specify` (hyphen, not dot). Discovered through 3 rapid fix-revert cycles on day 1. Constitution path: `.specify/memory/constitution.md` (not `specs/`).

### Agent Behavior Correction Pattern
Multiple features were designed specifically to prevent AI agent misbehavior:
- HARD STOP re-ask for empty responses (agents treating silence as approval)
- Execute+Review merge (agents skipping review after execution)
- Demo anti-pattern rules (agents generating test suites instead of demos)
- MANDATORY RULE banner (agents ignoring inline rules)
- Suppress spec-kit "Next step" output (agents auto-advancing past review)

This pattern suggests that agent guardrails are as important as the workflow logic itself.

---

## [2026-03-07] HARD STOP Enforcement Audit + Mode Simplification

### HARD STOP Empty Response Enforcement (13 locations fixed)

**Problem**: User input was being skipped during execution. Audit revealed 13 HARD STOP locations where `AskUserQuestion` was called but lacked inline "If response is empty → re-ask" enforcement text. These locations used `(CheckpointApproval)` shorthand referencing pipeline.md's procedure, but agents don't reliably cross-reference other files for procedural definitions.

**Root cause**: `add.md` is loaded independently from `pipeline.md`. When add.md referenced `(CheckpointApproval)`, the agent had no access to the procedure definition in pipeline.md that contained the empty-response loop logic.

**Fix**: Added explicit inline enforcement `**If response is empty → re-ask** (per MANDATORY RULE 1).` to all 13 locations:
- `add.md` (7): Pre-Check, Phase 2, Phase 3, Phase 4, Phase 5, Phase 5c, Phase 6
- `adopt.md` (3): Bootstrap skip, Merge checkpoint, Final demo
- `verify-phases.md` (2): Phase 1 fail, Phase 3 fail
- `coverage.md` (1): Gap resolution choice

Also changed `(CheckpointApproval)` shorthand to full inline format: `**HARD STOP** — Use AskUserQuestion with options: [...]`.

### `--auto` and `--dangerously-skip-permissions` Removal

**Decision**: Removed both modes entirely from all skill files and READMEs.

**Rationale**: These modes created confusion and conflicted with the HARD STOP enforcement philosophy. `--auto` was the only way to bypass HARD STOPs, which undermined the safety-first design. `--dangerously-skip-permissions` added complexity for an edge case that diluted the clarity of the enforcement rules. Both can be re-implemented later if needed.

**Scope**: ~30 files modified across smart-sdd commands, reference files, injection files, reverse-spec, case-study, and both READMEs (EN+KO).

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Empty response enforcement | Inline at every HARD STOP | Agents don't cross-reference procedures from other files |
| `(CheckpointApproval)` shorthand | Replaced with full inline format | Shorthand was not being followed by agents |
| `--auto` mode | Removed entirely | Conflicted with HARD STOP enforcement philosophy |
| `--dangerously-skip-permissions` | Removed entirely | Added complexity for edge case, diluted enforcement clarity |

### Comprehensive Dry-Run Audit (3 additional fixes)

**Audit scope**: Full dry-run of all 4 user journeys (Greenfield, SDD Adoption, Rebuild, Incremental) + Step Mode + utility commands. Traced SKILL.md routing → command files → cross-file transitions for every command path.

**Findings**: 3 additional AskUserQuestion locations missing re-ask enforcement (missed in the initial 13-location audit):
- `pipeline.md`: Constitution Incremental Update approval
- `add.md`: Phase 5c New Demo Group creation details input
- `parity.md`: Source path resolution fallback prompt

**Fix**: Added inline `**If response is empty → re-ask** (per MANDATORY RULE 1)` to all 3 locations.

**False positive from audit**: recording-protocol.md relative path (`../../case-study/reference/recording-protocol.md`) was flagged as broken but verified correct — `commands/` → `../../` = `skills/` → `case-study/` ✓

| Decision | Choice | Rationale |
|----------|--------|-----------|
| 3 additional re-ask enforcement | Inline at each location | Same pattern as initial 13-location fix |
| recording-protocol.md paths | Kept as-is | Relative paths verified correct via filesystem test |

---

## [2026-03-07] Real-World Usage Audit — Pipeline Behavior Fixes + Case Study Enhancement

### Pipeline Behavior Fixes (from actual usage observations)

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Fallback message enhancement | Added next-step preview to pipeline/adopt pause messages | User typing "continue" had no idea what would happen next |
| FR→Task coverage severity split | FR with 0 tasks = CRITICAL (blocking), FR with partial = HIGH (non-blocking) | 100% enforcement was too strict for partial coverage; zero-coverage is genuinely dangerous |
| Runtime error scan in Phase 3 | Scan stdout/stderr for TypeError, fatal, unhandled rejection etc. | Demo health check only checked HTTP 200 on Vite port while Electron main process had fatal errors — false pass |
| Feature ID ordering | Defer ID assignment until after Release Groups + Tiers determined (Phase 3-2b) | IDs were assigned by topological sort before Release Groups, causing F001→F004 skip in pipeline execution |
| User testing pause | HARD STOP after each Feature completion: "Proceed" or "Test first" | Pipeline immediately proceeded to next Feature without giving user time to test |
| quickstart.md reference | Added to implement/verify Read Targets; demo scripts must follow quickstart.md run instructions | Demo creation and verification were disconnected from spec-kit's authoritative run instructions |
| history.md Project Context | Rebuild/adoption records original→target conversion as permanent header | New sessions couldn't quickly understand what was being rebuilt from what |

### Case Study Enhancement — Business Context + history.md Integration

| Decision | Choice | Rationale |
|----------|--------|-----------|
| M1 "What it does" | Added business purpose field to recording protocol + log template | Case study reports were metric-heavy but lacked the "what was built" narrative |
| M6 "Delivers" | Added user-facing capability field to recording protocol | Per-Feature outcomes had FR/SC counts but no user-perspective description |
| history.md "What it does" | Added to Project Context block (rebuild + adoption) | Permanent record of system purpose; available even without case-study-log |
| Per-Feature Decision History recording | Pipeline records notable implementation decisions to history.md after merge | history.md only had strategic decisions; pipeline-level choices were lost |
| generate.md Section 1 System Overview | Pulls from history.md > M1 > roadmap.md (priority order) | Executive Summary needs the "what" narrative, not just metrics |
| generate.md Section 2 structured | Project Context table + Strategic Decisions + Anticipated Challenges | Background section was unstructured; now has clear subsections from history.md |
| generate.md Section 8 Impact Assessment | Before vs After comparison table + "What was delivered" from M6 entries | Outcomes section lacked concrete before/after impact measurement |
| history.md as primary case-study source | Added guidance note: "history.md is the richest source of decision context" | Multiple sections (2,4,5,7,8) should pull from history.md; previously underutilized |

---

## [2026-03-07] Pipeline Reset + Reverse-Spec Checkpoint

### `smart-sdd reset` Command

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Reset command | `commands/reset.md` — deletes pipeline state, preserves reverse-spec | Users frequently need to restart smart-sdd pipeline from scratch after experimental runs; manual cleanup is error-prone |
| Two modes | `reset` (pipeline only) vs `reset --all` (include logs) | Default preserves case-study-log and history.md for reference; `--all` provides clean slate |
| Registry restoration | Restore entity/api-registry from `reverse-spec-complete` tag | Registries are modified during pipeline (new entities/APIs added); reset should return to reverse-spec baseline |
| Skip pre-validation | Reset bypasses spec-kit CLI check + project init check | Destructive operation doesn't need spec-kit installed; has its own pre-validation in reset.md Step 1 |

### Reverse-Spec Completion Checkpoint

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Commit + tag approach | Auto-commit + `git tag -f reverse-spec-complete` after Phase 4-4 | Tag provides stable reference point for `smart-sdd reset`; commit ensures clean git state before pipeline starts |
| Tag over branch | Tag instead of separate branch | Branch requires merge step and can cause state confusion; tag is a permanent, immutable reference point |
| Force-tag (`-f`) | Overwrite tag on re-run | Users may run reverse-spec multiple times; latest run should always be the reset target |

---

## [2026-03-07] Demo CI/Interactive Path Convergence

| Decision | Choice | Rationale |
|----------|--------|-----------|
| CI path convergence rule | CI exit must come AFTER Feature startup, never before | Real incident: CI checked frontend build → passed; actual demo ran `tauri dev` → `command not found`. CI gave false confidence |
| Verify Step 4 added | Read demo script source, verify CI branch doesn't exit before Feature startup | Static analysis catches shortcut paths before execution; prevents CI-passes-but-demo-fails scenario |
| Template comments | Added `⚠️` comments at correct CI exit placement in demo template | Makes the correct pattern visually obvious to the implementing agent |

---

## [2026-03-07] Pipeline --start Flag

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Flag name | `--start <step>` | `--from` already used for artifact path; `--start` is intuitive and avoids conflict |
| Valid values | `specify`, `plan`, `tasks`, `analyze`, `implement`, `verify` | Matches the pipeline step names exactly; `constitution` excluded (use normal pipeline); `merge` excluded (not independently startable) |
| Prerequisite validation | All steps before `--start` must be ✅ per Feature | Ensures spec artifacts exist before running later steps; prevents implement without plan/tasks |
| Per-Feature eligibility | Eligible (prerequisites met), Blocked (prerequisites missing), Already-past (resume from next uncompleted) | Three-way classification gives clear feedback; doesn't force re-execution of completed steps |
| HARD STOP pre-check | Display eligible/blocked summary, user confirms before proceeding | User sees exactly which Features will run and which are blocked; prevents surprise failures |
| Phase 0 always skipped | Constitution verified but never re-executed in --start mode | Constitution is a one-time setup; if it's not done, pipeline should be run normally first |

---

## [2026-03-07] TODO — Browser MCP → Playwright MCP 용어 통일

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Browser MCP umbrella 폐기 | "Browser MCP" 카테고리 대신 "Playwright MCP"로 단일화 | Browser MCP umbrella를 유지하면 감지 로직 3단계 (Playwright → 다른 MCP → 수동), MCP 종류별 tool name 표준화, 각 MCP마다 action 매핑 필요 등 불필요한 복잡도 발생 |
| 감지 로직 간소화 | 3단계 → 2단계: `Playwright MCP 있음 → 자동` / `없음 → 수동 체크리스트` | Claude in Chrome 등 다른 browser MCP 대응 제거. Playwright MCP 하나로 통일하면 구현량도 줄어듦 |
| 미결정 사항 정리 | "Browser MCP 종류별 tool name 표준화" 항목 삭제 | Playwright MCP 단일화로 문제 자체가 해소됨 |
| constitution 질문 | "Browser MCP 자동 검증" → "Playwright MCP 자동 검증" | UI Verify Mode 값도 `browser-mcp` → `playwright-mcp`로 변경 |

---

## [2026-03-07] TODO Part 7 — Playwright MCP 데스크톱 앱 플랫폼 한계

| Decision | Choice | Rationale |
|----------|--------|-----------|
| 플랫폼 한계 명시 | Electron(❌ MCP 미지원), Tauri(❌ 불가), Flutter/RN Desktop(❌ 불가) 문서화 | Playwright MCP는 브라우저 자동화 전용. 데스크톱 앱에서 "demo 멈춤인데 verify 통과" 문제를 Playwright MCP로는 해결 불가 |
| 데스크톱 앱 UI 검증 | Part 3 수동 체크리스트가 유일한 수단 | Playwright MCP 자동 검증 불가 → 수동 체크리스트 중요도 상승 |
| 접근 방식 | A: 스택 기반 자동 모드 분기, B: 데스크톱 특화 체크리스트, C: Electron CDP 장기 대응 | A+B는 Part 0/3 구현 후 확장. C는 Playwright MCP 측 지원 필요로 우리 범위 밖 |

---

## [2026-03-07] TODO Part 8 — Implement-time Incremental Verification

| Decision | Choice | Rationale |
|----------|--------|-----------|
| 근본 원인 진단 | implement 중 코드 미실행 + 자동 fix 루프 부재 | 코드 작성 → 최초 실행(verify Phase 3)까지 간격이 너무 크고, 실패 시 에이전트가 자동 수정하지 않음. 데모가 전혀 동작하지 않거나 런타임 에러 다수 발생 |
| 4대 메커니즘 제안 | A: 태스크 레벨 빌드 검증, B: 데모 사전 실행, C: 자동 Fix 루프, D: 빌드 게이트 | A는 에러 조기 발견, B는 implement 완료 전 데모 1회 실행, C는 verify 실패 시 자동 수정(최대 3회), D는 implement → verify 전이 조건 |
| 우선순위 | 높음 (현재 가장 큰 실사용 문제) | 실제 테스트에서 데모 동작 문제가 가장 빈번하게 보고됨 |

---

## [2026-03-07] TODO Part 9 — F006 Post-Mortem 기반 파이프라인 단계별 버그 예방

| Decision | Choice | Rationale |
|----------|--------|-----------|
| 데이터 소스 | F006 구현 중 발견된 실제 버그 7건 분석 | 추상적 개선이 아닌 실전 버그 기반 설계. 빌드+테스트 125/125 통과했지만 런타임 버그 6건 발생 |
| Part 8과의 관계 | Part 8 = 구조(언제/어떻게 실행), Part 9 = 내용(무엇을 검사) | Part 8의 빌드 게이트에서 Part 9의 검증 항목 실행, Part 8의 Fix 루프에서 Part 9의 규칙 위반 수정 |
| 4단계 개선 | plan(호환성+anti-pattern+경쟁조건), analyze(데이터흐름), implement(IPC안전+CSS제약+통합체크), verify(empty state+런타임) | 7건의 버그 각각에 대해 "어느 단계에서 막았어야 하는가" 역추적하여 배치 |
| 주요 발견 | "빌드 성공 ≠ 런타임 성공" — verify가 빌드/테스트에만 의존 | 125/125 테스트 통과했지만 WKWebView 호환성, Zustand 무한 리렌더, IPC 필드 크래시 등 6건 미검출 |

---

## [2026-03-07] TODO Part 7 갱신 — Tauri MCP Server 활용으로 플랫폼 한계 해결

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Tauri UI 검증 | mcp-server-tauri (hypothesi/mcp-server-tauri) 활용 | Part 7 기존 결론 "Tauri → ❌ 불가"를 뒤집음. WebSocket + Rust Bridge Plugin으로 시스템 WebView 직접 연결 |
| 도구 매핑 | Tauri MCP 20개 도구 → Playwright MCP 대응 매핑 | webview_interact≈browser_click, webview_screenshot≈screenshot, ipc_execute_command은 Tauri 전용 |
| 전략 다이어그램 변경 | 2분기(Playwright/수동) → 3분기(웹앱+Playwright / Tauri+TauriMCP / 기타+수동) | 프로젝트 스택 감지 → 적합한 MCP 선택 → 자동 검증 or 수동 fallback |
| F006 버그 커버리지 | 버그 #1(JS엔진), #3(CSS), #4(초기화), #5(IPC) → Tauri MCP로 런타임 자동 검증 가능 | Part 9의 "사전 방지" 규칙 + Tauri MCP의 "런타임 검증" 조합으로 이중 방어 |
| 에이전트 자기 검증 | Tauri MCP 있으면 에이전트가 앱을 직접 조작/검증 가능 | "사용자가 직접 테스트해야 하는" 메타 문제를 Tauri 프로젝트에 한해 해결 |
| Part 0 확장 | UI Verify Mode에 `tauri-mcp` 옵션 추가 | auto 모드에서 스택 기반 MCP 자동 감지 (Playwright/Tauri/수동 3분기) |

---

## [2026-03-07] TODO Part 10 — 추가 파이프라인 개선 (실전 운영 피드백)

| Decision | Choice | Rationale |
|----------|--------|-----------|
| 6개 개선 항목 추가 | Tauri 프로젝트 실전 운영에서 발견된 구체적 문제점 | Part 8/9가 방향 제시라면, Part 10은 실전에서 확인된 구체적 검증 패턴 |
| 10-A Module Import Graph | implement에서 side-effect import chain 검증 (NEW) | registry 패턴 모듈이 import chain에서 누락되면 빌드는 되지만 런타임에서 등록 실패 |
| 10-B Smoke Launch 구체화 | 5초 내 crash/error boundary 트리거 여부 (Part 8-B, 9-D-9 확장) | "빌드 통과 ≠ 런타임 통과"의 구체적 실행 기준 제시 |
| 10-C Nullable Field Tracking | analyze에서 공유 타입 nullable 필드 사용 패턴 검증 (Part 9-B 확장) | F003의 healthStatus optional chaining 누락이 F006에서야 발견된 사례 |
| 10-D Store Dependency Graph | plan/tasks에서 스토어 의존 그래프 명시적 생성 (Part 9-A/B 확장) | Provider store가 App.tsx에서 미로드 → chat Feature 전체 동작 실패 사례 |
| 10-E Persistence Write-Through | implement에서 write-back 라이브러리 save() 호출 검증 (NEW) | tauri-plugin-store set()이 in-memory only인데 save() 누락 사례 |
| 10-F Downgrade Compatibility | plan에서 패키지 다운그레이드 시 타입/API 호환성 매트릭스 (Part 9-A 확장) | remark-gfm v4→v3 다운그레이드 시 TypeScript 타입 불일치 사례 |

---

## [2026-03-07] TODO Part 11 — Demo 실패의 근본 원인 5가지 구조적 공백 (F006 종합 분석)

| Decision | Choice | Rationale |
|----------|--------|-----------|
| 분석 방법 | F006 버그 10건 전수 역추적 → 5가지 구조적 공백 도출 | 개별 버그 수정이 아닌 파이프라인 구조 자체의 문제 식별 |
| 공백 1: Runtime Verification | verify가 정적 분석(tsc/build/unit test)에서 멈춤 | 10건 전부 정적 분석 통과 → runtime verification loop 부재가 근본 원인 |
| 공백 2: Integration Contract | Feature 간 의존이 문서적 참조뿐, 실행 가능한 계약 없음 | F003→F006 cross-feature 버그 3건이 Feature 독립 검증 구조에서 누락 |
| 공백 3: Runtime Constraints | Stack 이름만 기록, 런타임 제약 무인식 | WKWebView의 JS/CSS 제약이 constitution/specify 어디에도 반영 안 됨 |
| 공백 4: Behavioral Contract | 프레임워크 이름만 기록, 암묵적 동작 규칙 누락 | Zustand referential stability, React StrictMode 멱등성, tauri-plugin-store write-back 등 타입 시스템이 잡을 수 없는 함정 |
| 공백 5: Module Dependency Graph | 파일 목록만 존재, import chain 미추적 | side-effect import 누락으로 registry 패턴 전체 실패 |
| Part 8-10과의 관계 | Part 11은 상위 프레임, Part 8-10은 구체적 해법 | 5가지 공백이 해결되지 않으면 모든 Feature에서 동일 패턴 실패 반복 |

---

## [2026-03-08] 전체 소스 점검 기반 버그 수정 (H1-H3, M1-M5, M9, L1-L6)

| Decision | Choice | Rationale |
|----------|--------|-----------|
| H1: implement 조기 completed | implement.md Post-Step에서 roadmap `completed` 설정 제거 + 명시적 주석 추가 | state-schema.md에 따르면 completed는 merge 후에만 설정. state-schema.md의 Global Evolution Log 예시도 수정 |
| H2: adopt-verify Phase 3 skip | skip 사유를 "Adoption mode does not create per-Feature demos (existing code verified as-is)"로 수정 | 기존 "constitution not yet finalized"은 adoption과 무관 |
| H3: adopt-verify 상태값 혼동 | verify 결과(success/limited/failure)와 Feature Progress Status(adopted)를 분리 표기 | 두 개념이 혼동되어 에이전트가 잘못된 상태를 기록할 수 있었음 |
| M1: 미사용 스크립트 연결 | validate.sh를 status.md에 연결 (pipeline-status.sh는 이미 연결됨) | CLAUDE.md 규칙: dead code로 판단하지 말고 연결 |
| M2: domain schema 확장 | _schema.md에 section 5 (Feature Elaboration Probes), 6 (UI Testing Integration) 추가 | app.md에 이미 존재하는 섹션이 schema에 정의되지 않았음 |
| M3: adopt restructured | adopt.md pre-flight에 restructured 상태 처리 분기 추가 | restructured Feature가 adopt pipeline에 들어오면 처리 방법이 없었음 |
| M4: uv fallback | spec-kit CLI 설치를 uv → pipx → pip 3단계 fallback으로 변경 | uv 미설치 환경에서 설치 실패 |
| M5: speckit-diff sub-rule | Impact Mapping에 implement/analyze/tasks/clarify/checklist 5개 sub-rule 추가 | 해당 spec-kit 스킬 변경 시 전용 injection 파일 업데이트 누락 방지 |
| M9: uninstall.sh | install.sh와 대응하는 제거 스크립트 생성 | 설치만 있고 제거 수단이 없었음 |
| L1: adopt .env re-ask | .env HARD STOP에 re-ask 텍스트 추가 | MANDATORY RULE 1 패턴과 일관성 |
| L2: restructured 예시 | status.md 출력 예시에 restructured 상태 + 🔀 표기 추가 | restructured가 가능한 상태이나 예시에 미포함 |
| L5: speckit-diff AskUserQuestion | allowed-tools에서 미사용 AskUserQuestion 제거 | read-only 분석 스킬에 불필요 |
| L6: speckit-diff read-only | "Read-only analysis" → "Non-destructive analysis"로 수정, --output 쓰기 설명 추가 | --output 파일 쓰기와 "read-only" 주장이 모순 |

---

## [2026-03-08] case-study 간소화 — init 제거 + generate 단일 명령

| Decision | Choice | Rationale |
|----------|--------|-----------|
| init 서브커맨드 제거 | `commands/init.md` 삭제, SKILL.md 라우팅 제거 | case-study-log.md는 `/reverse-spec`, `/smart-sdd init`, `/smart-sdd pipeline` 3곳에서 자동 생성. init은 중복이며, 사용자가 수동으로 init을 실행할 이유가 없음 |
| argument-hint 간소화 | `"[init\|generate] [target-directory] [--lang en\|ko]"` → `"[target-directory] [--lang en\|ko]"` | 서브커맨드 없이 바로 generate 실행. 사용 편의성 향상 |
| allowed-tools 변경 | `AskUserQuestion` 제거, `Bash` 추가 | init이 유일한 AskUserQuestion 사용처(기존 로그 덮어쓰기 확인). Bash는 타임스탬프 생성(`date` 명령) 등에 필요 |
| M7: stack-migration.md 추출 단계 | generate.md Step 3에 3-8 (From stack-migration.md) 추가 | Step 2 아티팩트 발견에 등록되어 있었으나 Step 3 추출 단계가 누락. history.md와의 데이터 관계도 명시 |
| 템플릿/프로토콜 유지 | `templates/`, `reference/` 디렉토리는 그대로 유지 | reverse-spec, smart-sdd가 case-study-log.md 자동 생성 시 템플릿/프로토콜을 참조하므로 삭제 불가 |

---

## [2026-03-08] 전체 소스 2차 점검 — Flow 일관성 + 미활용 연결 수정 (F1-F6 + validate.sh)

> Review Protocol(CLAUDE.md) 기준: Flow 불일치 → 미활용 부분 → Context 효율성 순서로 검토

| Decision | Choice | Rationale |
|----------|--------|-----------|
| F1: verify injection step 번호 | "step 5 (Analyze)" → "step 4 (Analyze)" | pipeline.md 흐름도 기준 analyze는 step 4. verify.md가 잘못된 번호를 참조하면 에이전트 혼동 유발 |
| F2: adoption analyze fallback | context-injection-rules.md에 `tasks.md absent` 항목 추가 | adopt.md가 "tasks.md 부재 시 two-artifact mode" 를 주장하지만 규칙 테이블에 해당 항목 없어 에이전트가 누락된 파일을 읽으려 에러 발생 가능 |
| F3: tasks 흐름도 Update 누락 | `→ Update` 추가 | injection/tasks.md에 Update 규칙이 존재하지만 pipeline.md 흐름도에서만 생략. specify/plan과 불일치 |
| F4: analyze 흐름도 정확성 | `(simplified — Assemble/Update are no-ops)` 표기 추가 | "full Common Protocol" 주장과 흐름도 생략의 불일치 해소 |
| F5: adoption verify 분기 | verify-phases.md 헤더에 adoption 모드 분기 안내 추가 | step-mode로 `/smart-sdd verify F001`을 adopted Feature에 실행 시, adoption 특화 동작을 알 수 있는 경로가 없었음 |
| F6: 템플릿 경로 명시화 | 4곳의 산문형 참조 → 명시적 상대 경로 링크 `[...](../../case-study/templates/...)` | recording-protocol은 이미 명시적 상대 경로 사용. 템플릿도 동일 패턴으로 통일 |
| validate.sh 연결 강화 | pipeline.md Phase 0 완료 + 전체 완료 시 자동 호출, 스크립트 헤더 갱신 | 헤더에 "Post-artifact update validation"이라 명시하면서 실제 자동 호출 지점 없었음. 핵심 2곳(Phase 0 후, 전체 완료 후)에 연결 |

## [2026-03-08] MCP-GUIDE.md 신규 — 런타임 검증용 MCP 설정 가이드

> MCP 조사 결과를 기반으로 플랫폼별 권장 MCP 확정 + 사용자 가이드 작성

| Decision | Choice | Rationale |
|----------|--------|-----------|
| 기본 MCP 통일 | Playwright MCP (웹앱 + Electron) | 하나의 MCP로 두 플랫폼 커버. MS 공식, 25개 도구, 접근성 트리 기반. Claude Preview는 dev server 관리 보조용으로 유지 |
| Electron 연결 방식 | 방법 A: `--electron-app` (권장) + 방법 B: CDP fallback | PR #1291 머지 확인. 안정 릴리스 미포함 가능성 있어 CDP(`--cdp-endpoint`)를 검증된 대안으로 병기 |
| Tauri MCP | 향후 확장 예정으로 분류 | 베타(v0.9.0), Bridge Plugin 필요, 안정성 미검증. 웹+Electron 우선 지원 후 확대 |
| 가이드 파일명 | `MCP-GUIDE.md` | 하이픈 분리로 가독성 확보. 프로젝트 루트 대문자 관례(CLAUDE.md, README.md) 유지 |
| README 연결 | 헤더 링크 + Prerequisites에 optional 항목 추가 | README.md, README.ko.md 동기화. 필수가 아닌 선택 사항으로 명시 |

---

## [2026-03-08] TODO 재구성 + A-1 Runtime Exploration 구현

### TODO.md 전면 재구성

| Decision | Choice | Rationale |
|----------|--------|-----------|
| 12 Parts → 4 Groups | A (Runtime Interaction), B (Bug Prevention), C (Spec-Code Drift), D (Structural Gap Reference) | 1409줄 → ~280줄. 중복 통합 (Part 4⊂Part 2, Part 10→Parts 8/9), 구현 순서 테이블 추가 |
| 구현 순서 | A-6 → A-4 → A-3 → A-5 → A-2 → A-1 → B-1~4 → C | 의존성 기반: MCP 감지(A-6) → 수동 fallback(A-4) → 자동 검증(A-3) → 데이터 소스(A-5) → implement 검증(A-2) → reverse-spec 탐색(A-1) |

### A-1: reverse-spec Phase 1.5 Runtime Exploration

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Phase 위치 | Phase 1 (Surface Scan)과 Phase 2 (Deep Analysis) 사이 | Phase 1 이후 tech stack 파악 완료 → 실행 방법 판단 가능. Phase 2 전에 시각/행동 컨텍스트 확보 → 코드 분석 정확도 향상 |
| MCP 감지 시점 | Phase 1.5 Step 0에서 Playwright MCP 가용성 확인 | verify의 A-6 감지와 독립적. reverse-spec은 별도 스킬이므로 자체 감지 필요 |
| 환경 설정 3분류 | Auto-resolvable / Requires User Action / Optional | 에이전트가 자동 처리 가능한 범위를 명확히 구분. secret은 절대 자동 설정 불가 |
| Docker Compose 활용 | docker-compose.yml 감지 시 인프라 자동 시작 옵션 제공 | 가장 마찰 적은 환경 구성 경로. DB, Redis 등을 사용자 수동 설정 대신 원클릭 |
| 탐색 예산 | 최대 20화면, 화면당 10초, 전체 5분 | 컨텍스트 윈도우 소모 제한. 반복 패턴은 샘플링 (3개 이상 → "N more similar") |
| Manual fallback | Playwright 없을 때 에이전트가 앱 실행 → 사용자에게 수동 탐색 요청 | MCP 없이도 가치 제공. 사용자 관찰 결과를 같은 포맷으로 기록 |
| 산출물 위치 | pre-context.md → "Runtime Exploration Results" 섹션 (Feature별 분배) | 기존 pre-context 구조 안에 통합. Phase 4-2에서 라우트-Feature 매핑 기반 분배 |
| adopt 모드 | Phase 1.5 전체 스킵 | adoption은 기존 앱을 문서화하는 것이므로 런타임 탐색 불필요 |
| .env 보안 규칙 | secret 변수에 실제 값 절대 미기입. placeholder 주석만 | NEVER write actual secret values to .env — 기존 env var 보안 규칙과 일관 |

### MCP-GUIDE.md 트러블슈팅 섹션 추가

| Decision | Choice | Rationale |
|----------|--------|-----------|
| 트러블슈팅 추가 | 설치 확인 + Failed to connect 해결 가이드 | MCP 서버는 login shell 거치지 않아 .zshrc PATH 미적용. `-e PATH=...`로 환경변수 명시 필요. 실제 설치 테스트에서 발견된 문제 |

### 중간 산출물 파일 영속화 + Runtime Exploration 라우트 중심 구조

| Decision | Choice | Rationale |
|----------|--------|-----------|
| 에이전트 메모리 → 파일 영속화 | 모든 Phase 간 중간 산출물은 파일로 저장 (CLAUDE.md Design Principles에 원칙 추가) | 메모리는 컨텍스트 윈도우 한계/세션 단절/Phase 간 정보 손실에 취약. 파일은 재읽기/사용자 확인·수정/다른 세션 활용 가능 |
| runtime-exploration.md 구조 | 데이터 타입별(안A) → 라우트/화면 중심(안B) | 각 화면의 UI+흐름+행동+에러가 한 블록에 모여 기능 재현 관점에서 완결. Phase 4-2에서 라우트→Feature 매핑으로 직접 분배 가능 |
| 파일 위치 | `specs/reverse-spec/runtime-exploration.md` | reverse-spec 산출물 경로 컨벤션 준수 |
| Step 1.5-4b 추가 | App Initial Setup — 앱 내 UI 설정 HARD STOP | .env는 인프라 레벨, 앱 내 설정(API provider, model 선택, 온보딩)은 별도 계층. Cherry Studio 테스트에서 발견 — API key를 Settings UI에서 입력해야 AI 채팅 기능 탐색 가능 |

### Electron CDP 가이드 + Path B Screenshot-Assisted 개선

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Electron CDP 가이드 추가 | Step 1.5-4에 빌드 도구별 CDP 플래그 테이블 | electron-vite는 `ELECTRON_ARGS` 무시. `--` separator가 필수. Cherry Studio 테스트에서 CDP 연결 실패 원인으로 확인 |
| Playwright MCP CDP 재설정 안내 | Electron 앱 탐색 시 `--cdp-endpoint` 없으면 HARD STOP으로 재설정 or Skip | Playwright MCP가 일반 웹 브라우저용으로 시작된 경우 Electron CDP에 연결 불가. 사용자에게 명확한 선택지 제공 |

### Path B 제거 — Playwright MCP 필수화

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Path B 제거 | MCP 없으면 설치 안내 or Skip. 수동 탐색 경로 삭제 | MCP 설치는 한 줄 명령어. CDP 연결 실패도 재설정으로 해결 가능. 스크린샷 몇 장으로 얻는 정보 대비 사용자 부담이 과도. Skip해도 Phase 2 코드 분석 + SBI + UI Components 등 다른 메커니즘으로 보완됨 |
| Path A 라벨 제거 | "Path A — Automated Exploration" → "1.5-5. Runtime Exploration (Automated via Playwright MCP)" | Path B가 없으면 A/B 구분 불필요 |

### 파이프라인 Gap 분석 + TODO 재구성

| Decision | Choice | Rationale |
|----------|--------|-----------|
| 전체 파이프라인 추적 | reverse-spec 산출물 → specify → plan → implement → verify 정보 흐름 7개 Gap 식별 | runtime-exploration.md가 수집만 되고 소비 안 됨(G1/G2), 라우트→Feature 매핑 미정의(G3), implement 런타임 검증 전무(G4), verify UI silent-skip(G5), Electron 크래시(G6), SBI 필터링 모호(G7) |
| TODO 재구성 | Gap 기반 10개 과업으로 재편. A-4(수동 체크리스트) 제거, A-6 단순화 | verify도 MCP 필수. 수동 fallback 불필요. Gap 해소가 곧 과업 |
| runtime-exploration.md 품질 평가 | Cherry Studio 17화면 탐색 결과 — Phase 1.5 목적에 충분 | UI 요소, 레이아웃, 컴포넌트 라이브러리, 에러, 빈 상태 등 코드만으로는 파악 불가한 정보 확보됨 |

---

## [2026-03-08] Cross-File Consistency Fixes

11 cross-file consistency issues resolved:

| Item | Fix | Files |
|------|-----|-------|
| implement.md MCP-GUIDE.md link path | `../../../../` → `../../../../../` | injection/implement.md |
| B-2 result classification missing | Added "⚠️ warning (NOT blocking)" | injection/analyze.md |
| B-3 result classification missing | Added "⚠️ warning (NOT blocking)" | injection/implement.md |
| implement.md MCP absent silent degradation | Added warning message display | injection/implement.md |
| implement.md Review Display "Test Results" | Removed (tests run in verify, not implement) | injection/implement.md |
| app.md §7 B-rule naming mismatches | 4 items fixed to match injection files | domains/app.md |
| app.md §6 "screenshot" | Changed to "Snapshot" | domains/app.md |
| MCP detection 3-tool check | Changed to Capability Map Detect (browser_navigate only) | referenced files |
| pipeline.md Step 5 & 6 summary gaps | Added Demo-Ready/B-3/SC UI Verify/Phase 3b | pipeline.md |
| pre-context-template.md skip notation | "N/A" → "Skipped — [reason]" | pre-context-template.md |
| Git commit message language | Added "MUST be written in English" to CLAUDE.md | CLAUDE.md |

---

## [2026-03-08] Session B Testing Fixes — CDP/Electron Runtime Exploration

### Problem Evolution

Testing `/reverse-spec` on cherry-studio (Electron app) revealed that Phase 1.5 Runtime Exploration for Electron apps required CDP (Chrome DevTools Protocol) configuration in Playwright MCP, which necessitated Claude Code restart — losing all session progress.

| Fix Round | What Changed | Result |
|-----------|-------------|--------|
| Round 1 | CDP verification: `browser_navigate` to localhost:9222 → MCP config file read | Correct detection, wrong timing |
| Round 2 | Moved CDP check to Phase 1.5-0 Step 1b (before user choice) | Correct timing, manual reconfiguration |
| Round 3 | Auto-run `claude mcp remove/add` commands | Automatic, but still requires restart |
| Round 4 (**final**) | **Web Preview Mode** — renderer dev server only, no CDP needed | No restart needed |

### Web Preview Mode → CDP Pre-Setup (방향 전환)

Web Preview Mode를 구현했으나, CDP가 업계 표준이고 Web Preview는 자체 제작 워크어라운드에 불과하다는 점에서 CDP 사전 설정 방식으로 전환.

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Default Electron exploration mode | **CDP 사전 설정** (세션 시작 전 준비) | CDP가 업계 표준. Web Preview Mode는 renderer만 독립 실행하는 자체 워크어라운드 — 제한사항(IPC, 네이티브 메뉴 등 미지원)이 있고 비표준 |
| Web Preview Mode 삭제 | analyze.md, MCP-GUIDE.md에서 모든 Web Preview 코드/문서 제거 | CDP 사전 설정으로 세션 중간 재시작 문제를 해결. Web Preview는 불필요 |
| Playwright MCP를 전제조건으로 명시 | SKILL.md (reverse-spec, smart-sdd) + README에 Prerequisites로 추가 | 런타임 감지 대신 사전 준비 강조. 인자보다 전제조건이 적합 (Playwright 없이도 코드 분석은 가능) |
| Snapshot 기반 탐색 (Screenshot 미사용) | `browser_snapshot` (접근성 트리)만 사용, `browser_take_screenshot` 미사용 | Snapshot이 Feature 추출에 충분한 구조적 정보 제공. Screenshot은 시각적 외관만 제공 + 컨텍스트 윈도우 소모 |
| MCP-GUIDE.md Electron 방법 | 방법 A (`--electron-app`) + 방법 B (CDP) 두 가지로 정리 | 방법 C (Web Preview) 삭제. CDP 사전 설정 방식 + 원복 절차 문서화 |

---

## [2026-03-10] 3-Axis Modular Domain Architecture

Decomposed monolithic `domains/app.md` (both smart-sdd and reverse-spec) into a composable 3-axis module system: Interface × Concern × Scenario. ~30 new module files created, 24 references updated across the codebase.

| # | Decision | Choice | Rationale |
|---|----------|--------|-----------|
| 1 | Domain decomposition model | 3 independent axes: Interface (http-api, gui, cli, data-io), Concern (async-state, ipc, external-sdk, i18n, realtime, auth), Scenario (greenfield, rebuild, incremental, adoption) | Monolithic app.md treated all app types identically. Hybrid apps (e.g., Electron = gui + http-api + ipc) required duplicating rules. Axes compose without duplication |
| 2 | Content migration strategy | Cross-reference, not extraction — implement.md and verify-phases.md content stays in place, modules act as activation gates | 598/870-line procedural workflows with 30+ HARD STOPs, internal cross-references, sequential flow. Extracting fragments would break them |
| 3 | Module section schema | Unified S1-S7 (smart-sdd) + R1-R6 (reverse-spec) numbering across all module types | Consistent structure enables predictable loading. Omitting sections that don't apply keeps modules minimal |
| 4 | Backward compatibility | `app.md` → shim that auto-expands to `fullstack-web` profile; old sdd-state.md `**Domain**: app` auto-migrated to new format | Existing projects with `--domain app` continue to work without manual migration |
| 5 | Profile manifests | ~10-line files listing interfaces + concerns; scenario determined by sdd-state.md Origin | Profiles are pure composition declarations, not content. Content lives in modules |
| 6 | User customization | `specs/reverse-spec/domain-custom.md` using same S1-S7 schema, loaded last (highest priority) | Project-specific rules (e.g., idempotency SCs for payment endpoints) without forking modules |
| 7 | F005/F006 generalization | Specific references (Zustand selector, AI SDK v6, hover flicker) → universal patterns | Lessons are reusable across projects. Specific case studies preserved in history.md only |
| 8 | Loading protocol | `_core.md` (always) → each interface → each concern → scenario → custom | Predictable, ordered, cacheable by agent context |

**Files**: 30+ new files in `domains/` (both skills), 24 reference updates across SKILL.md, pipeline.md, verify-phases.md, add.md, parity.md, analyze.md, implement.md, state-schema.md, feature-elaboration-framework.md, demo-standard.md, ui-testing-integration.md, README.md, README.ko.md

---

## [2026-03-10] v4 Improvement Gap Analysis — Selective Adoption

Analyzed v4 improvement document (F005 MCP tool integration case study, proposals #9-#18) against current codebase. Found 5/10 already fully covered (#9, #10/#16, #12, #14), 2 shallow (#11, #13), 3 not covered (#15, #17, #18). Adopted 4 improvements after cost/benefit analysis; rejected 3 as unnecessary or impractical.

| # | Decision | Choice | Rationale |
|---|----------|--------|-----------|
| 1 | #15 Root Cause Tracing | Added upstream tracing step (2b) to Auto-Fix Loop | Core prevention for multi-iteration fix loops. v4 case: 5 iterations because each fix patched downstream symptoms instead of tracing upstream to SDK stream event behavior |
| 2 | #13 Stuck Stream Defense | Added stale/timeout to async-state S1 lifecycle + UX Behavior Contract template | Lightweight: one SC anti-pattern + one contract row. Existing error/cleanup patterns assumed stream eventually completes; silent stream (no events, no error) was unaddressed |
| 3 | #17 Plan Deviation Quick Check | Added Step 1b to verify Phase 2: entity count, API count, tasks completion rate | Lighter than v4's full FR sampling. Catches structural drift without consuming 34-FR × grep context. Full FR coverage is specify's job (FR→SC mapping), not verify's |
| 4 | #18 Verification Depth Tags | Added `(code)` / `(runtime)` tags to Phase 2 report formats (Steps 3, 3b, 4, 6) | Prevents "6/6 pass" conflation of grep-existence with runtime-confirmation. Minimal cost — format change only |
| 5 | #11 MCP Protocol | Not adopted | Already covered by #14 (per-task runtime check) + #10 (SDK trust classification) + #12 (CDP verification). MCP-specific protocol would over-couple to one technology |
| 6 | #17 Full FR Sampling | Not adopted | Root cause is specify-stage SC quality, not verify-stage coverage. FR re-sampling at verify is redundant if SCs are well-defined, and expensive if they aren't |
| 7 | #18 Delegation Rules | Not adopted | Sub-agent internal judgment quality cannot be enforced by skill rules. Report format tags (#18 adopted) are the practical alternative |

**Files**: implement.md (Auto-Fix Loop), async-state.md (S1), plan.md (UX Behavior Contract), verify-phases.md (Phase 2 Step 1b + report formats)

---

### F007 Post-mortem: Playwright MCP Runtime Failure Handling (2026-03-10)

**Trigger**: F007 verify phase — Playwright MCP was properly configured with `--cdp-endpoint http://localhost:9222` and showed `Status: ✓ Connected`, but `browser_snapshot` failed with "Target page, context or browser has been closed". The agent bypassed the HARD STOP by using raw WebSocket CDP scripts, violating verify-phases.md protocol.

**Root cause**: Pre-flight status table only had 3 states (active/configured/unavailable). "Tool exists but target lost" was not classified — it fell through to improper handling. No explicit rule prohibited workaround tools.

| # | Decision | Detail | Rationale |
|---|----------|--------|-----------|
| 1 | Add 4th probe result row | "Target closed" runtime errors → `MCP_STATUS = configured` (not unavailable) | MCP IS installed, CDP IS configured. The app just needs to be (re)started. Treating it as `unavailable` triggers wrong diagnostic path |
| 2 | Workaround Prohibition rule | Explicit ban on raw CDP/WebSocket/puppeteer as alternatives to Playwright MCP | Agent improvised a bypass that appeared to work but violated the verification contract. Must be explicitly forbidden |
| 3 | Phase 3 probe table updated | 4 outcomes instead of 3 — "Target closed" mapped to Case B (agent starts app) | Same Case B logic applies: CDP is configured, app is not running, agent handles it |

**Files**: verify-phases.md (Pre-flight status table, Workaround Prohibition, Phase 3 Step 3 probe table)

---

## [2026-03-11] CLI-Primary Playwright Architecture + Implement-Phase Browser Access

Flipped Playwright backend priority from MCP-primary to CLI-primary. Added implement-phase browser access for source app reference during coding. Renamed MCP-GUIDE.md → PLAYWRIGHT-GUIDE.md with full English rewrite.

### Motivation

Three problems drove this change:
1. **MCP reliability** — Chronic session registration failures ("Playwright MCP 도구가 이 세션에서 없어서"). MCP tools load at session start; if misconfigured or timing wrong, entire session has no browser access.
2. **Implement phase blindness** — Agent coded UI from spec.md text only. No visual reference to source app, no way to check if built UI renders correctly during coding. Errors discovered only at verify.
3. **Electron complexity** — CDP port pre-configuration + session restart + mode switching. CLI's `_electron.launch()` eliminates all of this.

### Design Decisions

| # | Decision | Choice | Rationale |
|---|----------|--------|-----------|
| 1 | Backend priority flip | CLI primary (priority 1), MCP accelerator (priority 2) | CLI is session-independent, always available once installed. MCP depends on session registration timing |
| 2 | Two CLI usage modes | Library mode (`node -e`) for implement; Test runner mode (`npx playwright test`) for verify | Implement needs ad-hoc quick checks; verify needs structured SC verification |
| 3 | Implement-phase browser access | 4 CLI script patterns: snapshot, css-extract, element-check, compare | Agent can reference source app visually and verify built app rendering during implementation, not just at verify |
| 4 | Electron simplification | `_electron.launch()` as primary (no CDP), MCP+CDP as legacy alternative | Direct Electron connection eliminates CDP port configuration and session restart requirements |
| 5 | Session restart elimination | CLI available → NEVER recommend restart | Session restart was only needed because MCP required re-registration. CLI has no such dependency |
| 6 | MCP-GUIDE.md → PLAYWRIGHT-GUIDE.md | Rename + full rewrite (Korean MCP-centric → English CLI-primary) | File name and content reflected MCP-only worldview; now covers both CLI and MCP with CLI as default |
| 7 | Dual-app lifecycle (rebuild) | Source app (default port) + built app (+1000 port) run simultaneously during implement | Enables side-by-side comparison via CLI compare pattern without manual app switching |
| 8 | Workaround prohibition update | Playwright library mode and `_electron.launch()` explicitly PERMITTED | These are first-class Playwright APIs, not workarounds. Needed explicit allowance after F007 prohibition rule |

### Files Changed

| File | Change |
|------|--------|
| `MCP-GUIDE.md` → `PLAYWRIGHT-GUIDE.md` | Renamed + major rewrite (~350 lines English CLI-primary, was 422 lines Korean MCP-centric) |
| `reference/runtime-verification.md` | §1-6 CLI-first reorder + §7 new implement-phase browser access protocol (~90 lines) |
| `reference/injection/implement.md` | Source App Visual Reference section, CLI primary runtime check, renamed Playwright section |
| `commands/verify-phases.md` | Pre-flight CLI first, `_electron.launch()` primary, session restart scoped to MCP-only |
| `reverse-spec/commands/analyze.md` | Phase 1.5 CLI primary detection and exploration, `_electron.launch()` for Electron |
| `smart-sdd/SKILL.md` | Prerequisites: CLI primary, MCP optional |
| `reverse-spec/SKILL.md` | Prerequisites: CLI primary, MCP optional |
| `reference/ui-testing-integration.md` | "Playwright MCP" → "Playwright (CLI or MCP)" throughout |
| `reference/injection/verify.md` | RUNTIME_BACKEND display format updated |
| `domains/interfaces/gui.md` | S6/S8: CLI primary backend, `_electron.launch()` |
| `README.md` + `README.ko.md` | Playwright Setup Guide link, CLI primary prerequisites |
| `CLAUDE.md` | Language rule: MCP-GUIDE.md → PLAYWRIGHT-GUIDE.md |

## [2026-03-16] Composition → Pipeline Mapping Documentation

| Choice | Rationale |
|--------|-----------|
| Added ARCHITECTURE-EXTENSIBILITY.md § 2b "How Composed Modules Drive the Pipeline" | User requested clear explanation of what module composition produces and how it affects each pipeline step — the composition mechanism was documented (4-axis, resolver) but the output mapping to pipeline steps was not |
| Section → Pipeline Step mapping table | Each S/A/F section routes to exactly one pipeline step — making this explicit eliminates the "what does this actually do?" question |
| Concrete before/after walkthrough per step | Abstract merge rules are insufficient — showing "without modules: generic SCs" vs "with modules: domain-specific SCs with IPC/streaming/preservation" makes the value tangible |
| "CSS for a pipeline" metaphor | Modules cascade and merge to "style" each step's behavior — aligns with developers' existing mental model of cascading rules |
| Brief summary in README.md/README.ko.md linking to § 2b | README provides the one-sentence explanation, ARCHITECTURE-EXTENSIBILITY provides the full walkthrough — per CLAUDE.md § Documentation Writing Guidelines |

### Files Modified
| File | Change |
|------|--------|
| `ARCHITECTURE-EXTENSIBILITY.md` | New § 2b: Section→Pipeline mapping table, concrete step-by-step walkthrough, merge rule summary, ASCII diagrams |
| `README.md` | Added "How composition drives the pipeline" paragraph with link to § 2b |
| `README.ko.md` | Korean translation of the same paragraph |

## [2026-03-16] README Architecture Section Restructure

| Choice | Rationale |
|--------|-----------|
| Reordered Architecture subsections for user understanding flow | Original order: Design Philosophy → 4-Axis → Rebuild Config → Extensibility → Signal Keywords → Foundation → Tier → Data Flow → Feature Lifecycle → Session Resilience → Project Modes → Key Artifacts → Adapting. Users couldn't understand 4-Axis composition without knowing what the pipeline does first |
| New order follows natural questions | "What does it do?" (Pipeline + Lifecycle) → "How do I use it?" (Modes) → "What does it produce?" (Artifacts) → "How does it know my rules?" (4-Axis + auto-detection + composition) → "Framework specifics?" (Foundation + Tiers) → "How do I customize?" (Extensibility) → "How is it reliable?" (Session Resilience) |
| Merged Data Flow + Feature Lifecycle into "How the Pipeline Works" | These are two views of the same concept — splitting them separated related information |
| Merged Platform Foundation + Tier System | Foundation creates T0 → Tiers order processing. Separating them broke the causal chain |
| Merged Extensibility + Adapting + module extension examples | Previously scattered across 3 sections with overlapping content |
| Moved Rebuild Configuration into Project Modes | It's a mode-specific detail, not a general architecture concept |
| Moved Signal Keywords into 4-Axis section | Auto-detection is HOW the 4 axes get selected — not a separate concept |

### Files Modified
| File | Change |
|------|--------|
| `README.md` | Architecture section restructured: 13 subsections → 8 subsections in user-understanding order |
| `README.ko.md` | Same restructure applied to Korean version |

---

## [2026-03-16] Diagram Alignment Fix + File Map Directory Descriptions

| Choice | Rationale |
|--------|-----------|
| Fix ASCII box diagram alignment across 3 files | Display width measurement revealed 1-2 column misalignment in 4 diagrams (box chars vs content padding) |
| Widen ARCH-EXT 4-Axis box from 29→33 inner width | "What cross-cutting patterns?" (29 chars) needs padding inside the box; 33 accommodates all questions with 2-space margins |
| Add directory structure overview to File Map | Users see file list without understanding why directories exist — "commands = what, domains = rules, reference = how" distinction aids navigation |
| Include sub-directory descriptions (interfaces/, concerns/, etc.) | Nested structure is non-obvious; one-line descriptions per sub-dir prevent users from having to open files to understand organization |
| No physical domain separation in reference/ | reference/ files are universal pipeline mechanics (not domain-specific); `injection/` sub-dir already handles per-step grouping |

### Files Modified
| File | Change |
|------|--------|
| `ARCHITECTURE-EXTENSIBILITY.md` | Fixed 4-Axis box (inner 29→33), Module Loading box (trailing space alignment) |
| `README.md` | Fixed Big Picture box (3 lines off by ±1), added Directory Structure Overview to File Map |
| `README.ko.md` | Fixed Korean Big Picture box (CJK display width compensation), added Korean Directory Structure Overview |

---

## [2026-03-16] Shared Domain Directory Introduction

Extracted cross-skill signal keywords (S0/R1/A0) into a unified `shared/domains/` directory, eliminating 40-70% duplication between reverse-spec and smart-sdd domain modules.

| Choice | Rationale |
|--------|-----------|
| Create `.claude/skills/shared/` as a non-skill resource directory | Shared modules need a home outside either skill; shared/ has no SKILL.md, just resources consumed by both skills |
| Extract S0 (semantic) + R1 (code patterns) into unified shared files | 26 matching file pairs had 40-70% keyword overlap; single source of truth prevents drift |
| Extract A0 (archetype signals) into shared archetype files | ~50% overlap between smart-sdd A0 (semantic) and reverse-spec A0 (code patterns) |
| Keep _core.md files skill-specific (no sharing) | R1-R7 (analysis) vs S1-S7 (execution) have 0% overlap — intentionally different concerns |
| Use cross-reference pattern (`See [shared/...] § Signal Keywords`) | Skill modules retain their S1-S8/R3-R7 sections; only signal keywords are replaced with references |
| Add `_taxonomy.md` as module registry | Single source of truth listing all 19 modules (5 interfaces + 11 concerns + 3 archetypes) with metadata |
| Add `_TEMPLATE.md` for contributors | Standardizes new module creation with both S0/A0 and R1/A0 signal sections |
| No changes to install.sh/uninstall.sh | Existing `$SKILLS_SRC/*/` glob auto-discovers shared/ directory |

### Files Created (21 new)
| File | Purpose |
|------|---------|
| `shared/domains/_taxonomy.md` | Module registry — lists all interfaces, concerns, archetypes |
| `shared/domains/_TEMPLATE.md` | Contributor template for new shared modules |
| `shared/domains/interfaces/{gui,http-api,cli,data-io,tui}.md` | 5 interface signal modules (S0 semantic + R1 code patterns) |
| `shared/domains/concerns/{async-state,auth,authorization,external-sdk,i18n,ipc,message-queue,plugin-system,protocol-integration,realtime,task-worker}.md` | 11 concern signal modules |
| `shared/domains/archetypes/{ai-assistant,public-api,microservice}.md` | 3 archetype signal modules (A0 unified) |

### Files Modified (~40)
| File | Change |
|------|--------|
| 37 smart-sdd + reverse-spec domain modules | S0/R1/A0 sections replaced with `See [shared/...]` cross-references |
| `smart-sdd/domains/_resolver.md` | Added Signal Keywords resolution note + updated S0/A0 Aggregation paths |
| `README.md` | Added shared/ directory overview + file map section |
| `README.ko.md` | Korean version of above |

---

## [2026-03-16] Greenfield Pipeline Strengthening (Track B)

Fixed 7 gaps in the greenfield pipeline to bring it to parity with the rebuild pipeline's specificity and rigor.

| Choice | Rationale |
|--------|-----------|
| Add concrete Matching Algorithm to clarity-index.md (Gap 1) | "Parse input and extract keywords" was too vague — no spec for case sensitivity, compound keywords, or disambiguation. Added tokenization, compound-first matching, whole-token-only rules |
| Integrate A0 archetype inference into clarity-index.md (Gap 3) | A0 was scattered across 3 files (_resolver.md, init.md, clarity-index.md). Now clarity-index.md is the single source for both S0 and A0 extraction |
| Add Proposal modification flow to init.md (Gap 2) | "Modify Proposal" option existed but had no specification for what happens. Added per-section modification rules, CI re-scoring rules, and signal re-extraction scoping |
| Add Principle Recommendation Table to init.md (Gap 4) | constitution-seed generation for greenfield had only 3 inline examples. Added systematic mapping table driven by active S0/A0 modules and CI dimensions |
| Clarify framework detection source in greenfield (Gap 5) | init.md referenced "auto-detect from project files" but greenfield has no files. Added conditional routing table: Proposal Mode → S0 signals, Standard + empty dir → Phase 1 Q&A |
| Enrich greenfield.md from 23 to 103 lines (Gap 7) | rebuild.md had Configuration Parameters, per-category probes, bug prevention rules. greenfield.md had none. Added project_maturity parameter, SC anti-patterns, maturity-adjusted depth, architecture scaffolding, 7 bug prevention rules |
| Add inline CI propagation to pipeline specify/plan/verify (Gap 6) | clarity-index.md § 6 defined propagation but pipeline steps didn't implement it. Added CI pre-checks at specify (low-CI clarify sub-step), plan (emphasis on uncertain areas), verify Phase 3b (empty-state checks) |

### Files Modified
| File | Change |
|------|--------|
| `reference/clarity-index.md` | Added Matching Algorithm (§3), A0 Archetype Inference (§4b), renamed §5 to S0/A0, added A0 Aggregation Rule |
| `commands/init.md` | Added framework source routing table (Step 3b), Proposal modification flow (Step 3a), Principle Recommendation Table (Phase 3) |
| `domains/scenarios/greenfield.md` | Expanded from 23→103 lines: Configuration Parameters, S1 anti-patterns + maturity depth, S3 scaffolding check, S5 per-maturity/team probes, S7 7 bug prevention rules |
| `commands/pipeline.md` | Added CI pre-check to specify (step 1), CI coverage check to specify (step 5), CI propagation to plan (step 3) |
| `commands/verify-phases.md` | Added CI propagation check to Phase 3b |

---

## [2026-03-16] Greenfield Simulation + Signal Keyword Fixes

Simulated 3 greenfield projects through the init pipeline (Hono REST API, Electron AI Desktop, CLI Build Tool) to validate the matching algorithm, CI scoring, and principle recommendation. Found and fixed 4 signal vocabulary gaps.

| Choice | Rationale |
|--------|-----------|
| Add `auth` to auth concern S0 Primary | Simulation showed `auth` (most common abbreviation) was missing — only `authentication` (full word) was listed |
| Add `Claude` standalone to ai-assistant A0 Primary | `Claude API` (compound) existed but `Claude` alone didn't match — users write "OpenAI, Claude" not "OpenAI, Claude API" |
| Add functional keywords to async-state Secondary | `conversation history`, `undo/redo`, `persistence` — S0 was biased toward library names (Zustand, Redux) and missed feature-describing signals |
| Add webhook principle row to Recommendation Table | Webhook-heavy projects (e-commerce, integrations) had no idempotency principle despite webhook being a common signal |
| Consolidate _resolver.md A0 Aggregation → cross-reference to clarity-index.md | File review found A0 algorithm duplicated between two files — now _resolver.md references clarity-index.md § 5 |

### Simulation Results Summary
| Project | CI Score | Tier | Modules Activated | Issues Found |
|---------|---------|------|------------------|--------------|
| Hono REST API | 58% | Medium | http-api, external-sdk (auth missed → fixed) | G1: `auth` abbreviation, G2: webhook principle |
| Electron AI Desktop | 78% | Rich | gui, ipc, external-sdk, realtime, ai-assistant | G3: `Claude` standalone, G4: async-state feature keywords |
| CLI Build Tool | 44% | Medium | cli only | G5: TypeScript not in S0 (correct — pure tech stack) |

### Files Modified
| File | Change |
|------|--------|
| `shared/domains/concerns/auth.md` | Added `auth` to S0 Primary |
| `shared/domains/archetypes/ai-assistant.md` | Added `Claude` to A0 Primary |
| `shared/domains/concerns/async-state.md` | Added `conversation history`, `undo/redo`, `persistence`, `local storage state` to S0 Secondary |
| `commands/init.md` | Added webhook principle row to Recommendation Table |
| `domains/_resolver.md` | Replaced A0 Aggregation section with cross-reference to clarity-index.md § 5 |

## [2026-03-16] Documentation Strengthening — shared/ Architecture + Proposal Modification

| Decision | Rationale |
|----------|-----------|
| Add ARCHITECTURE-EXTENSIBILITY.md § 1.5 "Signal Keywords: Shared Architecture" | shared/ directory was created but never documented in the extensibility guide — contributors wouldn't know the 3-file pattern |
| Update § 3/4/5 steps to shared-first 3-file pattern | Steps still said "create files in both skills" — outdated after shared/ refactoring |
| Add Proposal Modification overview to README.md + README.ko.md | Proposal Mode modification (per-section editing, CI re-scoring) was implemented in init.md but never mentioned in user-facing docs |
| Verify README.ko.md parity with README.md | Korean README was missing the same Proposal Modification mention — both now in sync |

### Files Modified
| File | Change |
|------|--------|
| `ARCHITECTURE-EXTENSIBILITY.md` | Added § 1.5 shared architecture section; updated § 3/4/5 contributor steps to 3-file pattern |
| `README.md` | Added Proposal Modification sentence to CI/Proposal paragraph; updated timestamp |
| `README.ko.md` | Added Proposal Modification sentence (Korean); updated timestamp |


## [2026-03-20] Design-to-Implementation Wiring — Scale, Cross-Concern, Philosophy

| Decision | Rationale |
|----------|-----------|
| Add Scale Modifier Enforcement + Cross-Concern Integration Enforcement to `context-injection-rules.md` | Scale modifier (project_maturity × team_context) was fully defined in `_resolver.md`/`_schema.md`/`state-schema.md` but NEVER consumed by any injection file. Cross-Concern Integration Rules (14 rules in `_resolver.md` Step 3.5) had zero enforcement logic. Both scored D in philosophy fidelity analysis — defined but not operationalized |
| Add Scale & Cross-Concern Adjustments sections to all 4 injection files (specify, plan, implement, verify) | Per P2 (Enforce, Don't Reference), rules in a central file aren't enough — each execution point needs inline instructions. Each injection file now has a dedicated section that reads sdd-state.md Scale values, applies per-command adjustments, checks cross-concern combinations, and displays in Checkpoint |
| Add explicit `Read injection/{step}.md` instructions to pipeline.md for plan, tasks, analyze | Pipeline injection was asymmetric — implement and verify had explicit "🚨 CRITICAL: Read injection/..." instructions, but plan/tasks/analyze relied on implicit Common Protocol Assemble. Agents skipped the injection files when not explicitly told to read them (P2 violation) |
| Add "Design Philosophy" section to README.md + README.ko.md | The 3 foundational philosophies (P1 Context Continuity, P2 Enforce Don't Reference, P3 File over Memory) were only documented in CLAUDE.md. User-facing docs had no philosophy hierarchy — concepts were explained but not framed as a coherent governance system |
| Add Sophistication Level current status to ARCHITECTURE-EXTENSIBILITY.md § 9 | Sophistication Levels were defined as an aspiration but never had honest "where we are now" markers. Added status table showing L1 ~90%, L2 ~60%, L3 ~40%, L4 ~10%, L5 ~15% |
| Add P1/P2/P3 philosophy tags to lessons-learned.md Themes | Each Theme's lessons trace to specific philosophy violations, but the connection was implicit. Tags make the mapping explicit and help readers navigate by principle |

### Files Modified
| File | Change |
|------|--------|
| `smart-sdd/reference/context-injection-rules.md` | Added Scale Modifier Enforcement section + Cross-Concern Integration Enforcement section |
| `smart-sdd/reference/injection/specify.md` | Added Scale & Cross-Concern Adjustments section |
| `smart-sdd/reference/injection/plan.md` | Added Scale & Cross-Concern Adjustments section |
| `smart-sdd/reference/injection/implement.md` | Added Scale & Cross-Concern Adjustments section |
| `smart-sdd/reference/injection/verify.md` | Added Scale & Cross-Concern note in header |
| `smart-sdd/commands/pipeline.md` | Added explicit injection file read instructions for plan, tasks, analyze steps |
| `README.md` | Added Design Philosophy section; updated timestamp |
| `README.ko.md` | Added 설계 철학 section; updated timestamp |
| `ARCHITECTURE-EXTENSIBILITY.md` | Added Sophistication Level current status table to § 9 |
| `lessons-learned.md` | Added P1/P2/P3 tags to all 9 Theme headings |

## [2026-03-20] Philosophy Reframing — Core Concepts vs Design Rules

| Decision | Rationale |
|----------|-----------|
| Rename "Design Philosophy" → "Design Discipline" in README.md/README.ko.md | P1/P2/P3 are engineering rules (HOW we build), not philosophy (WHAT we believe). The real philosophy is already in the three core concepts: GEL, Domain Profile, Brief |
| Add foundational belief statement to "What It Solves" intro | "The quality of an agent pipeline is determined by the quality of the structure, not the agent's capability" — this is the actual philosophical premise that GEL/Domain Profile/Brief derive from |
| Add philosophical taglines to GEL, Domain Profile, Brief subsections | Each concept now has a one-line italicized belief statement above the "gap/solution" pattern, making the WHY visible alongside the WHAT |
| Connect P1/P2/P3 rules back to core concepts | Each rule now ends with an italicized sentence explaining which core concept it serves (P1→GEL, P2→Domain Profile, P3→Brief) |

### Files Modified
| File | Change |
|------|--------|
| `README.md` | Renamed Design Philosophy → Design Discipline; added belief statement + concept taglines + rule↔concept connections |
| `README.ko.md` | Same changes in Korean; 설계 철학 → 설계 규율 |
