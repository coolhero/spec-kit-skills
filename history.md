# spec-kit-skills Design Decision History

> Extracted from git history (89 commits, 2026-02-28 ~ 2026-03-04).
> Records key architectural and design decisions that shaped the project.

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

> Full design document: [`v2-design.md`](v2-design.md)

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
