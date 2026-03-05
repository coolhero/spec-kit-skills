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

## Recurring Patterns

### Cross-File Consistency Challenge
At least 5 dedicated fix commits for cross-file inconsistencies. Root cause: multi-file skill architecture where changes in one file silently invalidate assumptions in others. Mitigated by comprehensive audit passes but remains an ongoing concern.

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
