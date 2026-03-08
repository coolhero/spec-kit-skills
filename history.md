# spec-kit-skills Design Decision History

> Extracted from git history (89 commits, 2026-02-28 ~ 2026-03-04).
> Records key architectural and design decisions that shaped the project.

---

## [2026-03-08] smart-sdd verify — Strengthen Electron CDP HARD STOP (anti-bypass)

| # | Decision | Choice | Rationale |
|---|----------|--------|-----------|
| 1 | HARD STOP bypass prevention | Added explicit anti-bypass language: "Do NOT skip, do NOT auto-decide, do NOT rationalize" | Session B agent acknowledged the HARD STOP requirement but bypassed it by rationalizing that "health check already passed and UI verification is non-blocking." Strengthened wording to remove any rationalization escape hatch. |
| 2 | "Non-blocking" clarification | Clarified that "non-blocking" means results don't block verify, NOT that verification can be skipped | Agent misinterpreted "UI verification failures are NOT blocking" as permission to skip the entire UI verification step without user consent. Added explicit disambiguation. |

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
