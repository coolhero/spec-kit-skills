# Lessons Learned — AI Agent Pipeline Design

> **What this file is for**: This document captures failure patterns discovered while building and operating AI agent pipelines with spec-kit-skills. Each entry describes a real problem, how it was fixed, and — most importantly — the **universal lesson** applicable to any AI agent system.
>
> Whether you're building your own agent skills, designing multi-step workflows, or trying to make AI agents more reliable, these patterns will save you time.
>
> **How to read**: Part 1 (Gap Patterns) describes *categories* of problems. Part 2 (Specific Lessons) describes *concrete incidents* with actionable takeaways. Cross-references (e.g., "see L10") link related entries.

---

## Part 1: Gap Patterns

> Recurring failure categories discovered across multiple Features. Each pattern represents a class of bugs that traditional software checks (build, test, lint) do not catch.

### G1. Build Pass ≠ Feature Works

**The trap**: Your build succeeds, tests pass, linter is clean — but the feature doesn't actually work at runtime.

**Real example**: Zustand state selectors created new object references every render → infinite re-renders, scroll broken during streaming. Build and TypeScript saw nothing wrong.

**Why it happens**: Build tools check syntax and types. Tests check isolated units. Neither checks runtime state behavior, animation timing, or interaction between live components.

**How we catch it**: Per-task runtime verification after each implementation task, pattern compliance scanning for known anti-patterns (selector instability, stale closures), runtime error zero-tolerance gate.

**Coverage**: ~80% — drops to build-only verification when Playwright is unavailable.

---

### G2. Foundation Absence

**The trap**: The same infrastructure bug appears in every Feature because nobody verified the foundation.

**Real example**: CSS theme misconfiguration, IPC bridge errors, state management anti-patterns — all 7 bugs found across Features were actually foundation-level issues that should have been caught once.

**Why it happens**: Each Feature's pipeline starts fresh. Without a one-time foundation check, every Feature rediscovers the same infrastructure problems.

**How we catch it**: Foundation Gate runs once before the first business Feature — verifies build toolchain, framework plugins, IPC bridges, layout structure. Results are cached so subsequent Features skip it.

**Coverage**: ~90% — most robust pattern.

---

### G3. Source Information Gap

**The trap**: The agent guesses values it could have looked up in the original source code.

**Real example**: Agent guessed CSS color tokens instead of reading them from source. Assumed "3 sidebar tabs" from a summary when the source code actually had 2 tabs (the third was a conditional view). Pre-context said "better-sqlite3" when the preceding Feature had already switched to electron-store.

**Why it happens**: Agents work from summaries and descriptions, not from source code. Summaries lose nuance — counts get rounded, conditional behavior gets flattened, implementation changes aren't back-propagated.

**How we catch it**: Source Reference Active Read (read actual source files for each SBI entry), SBI Accuracy Cross-Check (verify counts/structures against code), Pre-context Freshness Check (compare pre-context assumptions against actual implementation of completed dependencies), Visual Reference Checkpoint (load screenshots before UI implementation).

**Coverage**: ~85% — weakens when runtime exploration (Phase 1.5) is skipped.

---

### G4. Async/Temporal Pattern Omission

**The trap**: Only synchronous "happy path" flows are documented. Async state transitions, error recovery, and cleanup are missing.

**Real example**: A streaming chat feature's spec defined `send message → receive response` but not `loading → streaming → completion → error → cleanup → retry`. The implementation had no error state handling.

**How we catch it**: UX Behavior Contract (mandatory temporal flow documentation), Interaction Chains (state machine for each user flow), VERIFY_STEPS with temporal verbs (loading, streaming, completing).

**Coverage**: ~70% — most recently added, needs more real-world validation.

---

### G5. Context Compaction Procedure Loss

**The trap**: The AI agent's context window compacts mid-session → it forgets which verification phases it already completed → phases get skipped or repeated.

**Real example**: During F006 verify, context compaction erased the verify-phases.md reference. The agent skipped Playwright UI verification entirely — despite completing it successfully for F001~F005.

**Why it's a meta-problem**: Every other countermeasure (G1-G4, G6-G16) assumes the agent reads its skill files. G5 breaks that assumption — if the skill file is compacted out of context, no rule in it matters.

**How we catch it**: Verify progress is written to sdd-state.md at every phase boundary. A resumption protocol reads persisted state and resumes from the exact phase after compaction.

---

### G6. Runtime Behavior Verification Gap

**The trap**: Verify does static checks (tests pass, code structure correct) but never actually runs the feature to see if it works.

**Real example**: SC verification covered only 1 of 10 success criteria for F006 — the one about "renders correctly." The 9 SCs requiring server connection, tool execution, and toggle interactions were never tested at runtime.

**How we catch it**: SC Verification Matrix classifies ALL success criteria (not just the ones covered by demos). Coverage gate warns if less than 50% of SCs have runtime verification. Multi-backend verification (Playwright for GUI, curl for API, shell for CLI).

**Coverage**: ~75% — SCs that depend on external services still require manual verification.

---

### G7. Cross-Feature Integration Contract Gap

**The trap**: Each Feature works in isolation, but Features break when they try to talk to each other — because nobody defined the data shapes at Feature boundaries.

**Real example**: Feature A's ParameterBuilder expected `{ mcpMode, mcpServers }` on the assistant object. Feature B's store actually stored `{ mcpEnabled, servers }`. No bridge was designed, built, or verified. Three-layer miss: spec didn't define it, implement didn't build it, verify didn't check it.

**How we catch it**: Integration Contracts in plan.md explicitly define Provider Shape vs Consumer Shape for each cross-Feature boundary. Verify Phase 2 checks actual data shape compatibility.

**Coverage**: ~80% — catches structural mismatches, but cannot catch all semantic compatibility issues.

---

### G8. i18n Key Coverage Gap

**The trap**: Components use `t('key')` but the keys are missing from translation files → UI shows raw key strings like `settings.general.language` instead of actual translations.

**Why it's invisible**: i18next silently falls back to the key string. Build passes. Tests pass. TypeScript passes. The only way to notice is to look at the rendered UI.

**How we catch it**: Per-task i18n completeness check during implement, verify Phase 1 i18n coverage lint (cross-check code → locale files, locale → locale consistency).

**Coverage**: ~95% — doesn't catch dynamically constructed keys like `t(\`prefix.${var}\`)`.

---

### G9. SDK API Contract Gap

**The trap**: Code passes metadata-only objects to SDK functions that expect callable objects → build passes (loose types), but the SDK silently ignores the objects at runtime.

**Real example**: AI SDK's `tool()` function expects `{ execute: async () => {...} }`. The agent passed `{ type: "mcp", serverId: "xxx" }` — metadata only, no execute function. The SDK silently ignored these "tools." The AI responded without tool access.

**How we catch it**: SDK API contract gap detection in Pattern Compliance Scan. External SDK Type Trust Classification: High-trust (well-typed, strict), Medium-trust (typed but permissive), Low-trust (any-typed or documentation-only).

**Coverage**: ~70% — complex SDK contract mismatches require runtime verification.

---

### G10. UI Interaction Over-exposure

**The trap**: Hover/click interactions are attached to overly broad DOM areas → UI flickers, re-renders cascade, poor UX during scroll.

**Real example**: `onMouseEnter/Leave` on each chat message caused Copy buttons to flash on every message during scroll. Solution: CSS `group-hover` with `transition-opacity` — zero re-renders, smooth scroll.

**Universal takeaway**: Before adding any hover/click handler, ask: "What's the smallest DOM element this interaction should apply to?" Prefer CSS-only solutions (`:hover`, `group-hover`) over framework state (`useState`) for visual-only effects.

**Coverage**: ~60% — checklist raises awareness but requires judgment.

---

### G11. Verify Checks Code Existence, Not Runtime Behavior

**The trap**: Verify uses `grep` to confirm code patterns exist in the codebase — but the code doesn't actually run correctly.

**Real example**: Embedding model wasn't running → vector search returned empty results. Verify passed because `grep` found the embedding/search code. The code was structurally correct but functionally useless without the model.

**Key principle**: **Empty state ≠ PASS.** If a search returns zero results, a list shows zero items, or a feature produces no output — that's a verification failure, not a pass.

**Coverage**: ~85% — external-dependency SCs still require manual verification.

---

### G12. Ad-hoc Domain Philosophy

**The trap**: Domain-specific principles (e.g., "Streaming-First" for AI apps) are generated ad-hoc by the agent's general knowledge — different sessions produce different principles for the same domain.

**How we catch it**: Archetype modules provide structured, reusable principle extraction per application domain. The agent loads domain-specific philosophy from files, not from its training data.

---

### G13. Framework Philosophy vs Operational Checklists

**The trap**: Configuration checklists mix "what to configure" with "why certain patterns are preferred." The philosophical principles get diluted among checklist items.

**Real example**: "Main process must survive renderer crashes" (Electron philosophy) was a checklist item alongside "CORS policy: config" (operational setting). The philosophical principle's importance was invisible.

**How we catch it**: Foundation F7 Philosophy section separates framework-endorsed principles from operational checklists.

---

### G14. Metrics-Only Reports Miss the "Why"

**The trap**: Reports show *what* was built (FR count, SC coverage %, lines of code) but not *why* decisions were made.

**How we catch it**: Philosophy-aware report generation traces each architectural decision back to the principle that motivated it.

---

### G15. Skill Tool Return Overrides Pipeline Instructions

**The trap**: When an AI agent calls a sub-skill via the Skill tool, the sub-skill's completion message becomes the agent's final response — bypassing all post-execution steps.

**Real example**: `speckit-constitution` returned "Constitution finalized." The agent showed this raw output and jumped to the next pipeline step — without reading the generated artifact, showing a review, or asking for user approval.

**Why it's hard to fix**: The failure happens *between* tool execution and the next instruction. Unlike other gaps where you can add a verification gate, this one requires behavioral change at the agent level. No single fix was sufficient — it took 4 layers of defense (see L14, L20, L21).

**Coverage**: Improved from ~uncertain to ~moderate with multi-layer defense.

---

### G16. Path Ambiguity in Multi-Directory Operations

**The trap**: Instructions say "write to `{target-directory}`" but "target" means different things in different contexts — the source being analyzed vs the project being built.

**How we catch it**: Explicit `(CWD root)` annotations on every file path instruction. No ambiguous path references.

---

## Countermeasure Evolution

How defenses were added over time, each triggered by a real failure:

```
Foundation:  SC verification → Foundation Gate → Source Reference → SBI Cross-Check
Playwright:  Fallback chain → Pattern Scan → Chain Completeness → API Matrix
Behavior:    UX Contract → Verify Progress → SC Matrix → Integration Contracts
i18n/SDK:    i18n Lint → SDK Contract Gap → Type Trust Classification
UX:          Interaction Surface Audit → Runtime multi-backend architecture
Governance:  BLOCKING gates → Completeness verification → MANDATORY RULE 3
Instruction: Standalone sections → Dependency rules → CWD annotations
Pipeline:    Console filter → Feature numbering → Inline Execution
Build:       CSS verification → Build Output Fidelity (generalized)
Gates:       Completeness Gate → Visual Reference Checkpoint → Pre-Approval Validation
Freshness:   Pre-context check (specify reads actual impl vs stale assumptions)
Proximity:   Inline Execute+Review sections (per-step instruction placement)
Safety:      Catch-all fallback (unconditional continue prompt)
```

---

## Part 2: Specific Lessons

> Concrete incidents with actionable takeaways. Grouped by theme.

### Theme A: How Agents Interpret (and Ignore) Instructions

#### L1. Agents Fabricate Excuses to Bypass Safety Gates

**What happened**: Agent auto-skipped HARD STOP checkpoints, citing "health check passed" or "non-blocking classification."

**Fix**: Inserted inline re-ask text at 30+ locations throughout the codebase.

**Universal takeaway**: Agents will find "reasonable" reasons to skip inconvenient steps. The only defense is inline repetition — put the rule at every point where the violation can occur. Reference-only rules ("see file X for details") are ignored under context pressure.

#### L10. "MANDATORY" Is a Suggestion — Only BLOCKING Gates Work

**What happened**: A step marked `MANDATORY — You MUST NOT skip it` was skipped twice. The keyword was treated as "important but situational."

**Fix**: Added a BLOCKING gate that checks the output file contains the expected section. Missing section → re-execute.

**Universal takeaway**: Design enforcement as downstream output verification, not upstream instruction emphasis. "MANDATORY" is a request. "Does the file contain section X? If no → block" is enforcement. Agents comply with verifiable constraints (Y/N), not behavioral directives.

#### L11. Bullet Lists Are Suggestions — Tables Are Requirements

**What happened**: A 14-item bullet list of required sections for a document. Agent generated only 6 of 14, ignoring sections it deemed "not needed."

**Fix**: Changed from bullet list to a structured checklist table with a post-generation verification step.

**Universal takeaway**: Content requirements in prose are suggestions. Enforceable requirements need a table + a verification step that checks completeness. Pattern: define expected items → generate → verify → block if incomplete.

#### L12. Ambiguous Verbs — "Update" ≠ "Write to File"

**What happened**: Instruction said "Update Demo Group SBI ranges." Agent calculated the values and displayed them — but did NOT write them to the file.

**Fix**: Changed to: "**Write** these ranges **into** roadmap.md by adding a `| SBI Coverage | B###–B### |` row."

**Universal takeaway**: When you need file modification, use explicit verbs: "Write X into [filename]", "Add X to [filename]." Never use "Update," "Reflect," or "Record" without specifying target file and format.

#### L15. Checklists Are Interpreted by Title Scope

**What happened**: Step 5 of "SBI Numbering Verification" was a Demo Group calculation. Agent completed steps 1-4 (about numbering) and stopped — step 5 didn't match the checklist title.

**Fix**: Gave the Demo Group calculation its own section heading.

**Universal takeaway**: Agents interpret checklist items through the title's semantic scope. An item that doesn't match the title will be skipped. Fix: give distinct tasks their own headings — don't piggyback unrelated tasks on existing checklists.

---

### Theme B: Context Window and Instruction Placement

#### L14. Sub-Skill Calls Break Multi-Step Orchestration

**What happened**: Orchestrator skill called `speckit-plan` via the Skill tool. The sub-skill's completion message terminated the orchestrator's turn. Post-execution review was structurally impossible.

**Fix**: (1) Changed to Inline Execution (read sub-skill's instructions → execute as inline steps). (2) Added MANDATORY RULE 3 to always-loaded SKILL.md. (3) Per-step inline Execute+Review sections.

**Universal takeaway**: When an orchestrator needs to do post-processing after a sub-skill, the Skill tool is structurally incompatible — it creates a response boundary. Use inline execution instead. Place critical behavioral rules in always-loaded files, not on-demand files.

#### L20. Safety Nets Must Be Unconditional

**What happened**: Agent stopped after showing raw spec-kit output. No review, no prompt, no fallback — user had no idea what to do next. The fallback was scoped to "if context limit prevents..." but the failure wasn't a context limit.

**Fix**: Changed fallback from condition-specific to catch-all: "if this response ends without AskUserQuestion, for ANY reason, show the continue prompt."

**Universal takeaway**: Define safety nets as INVARIANTS ("every response after X must end with Y"), not CONDITIONS ("if error Z occurs, show fallback"). If you enumerate failure conditions, you'll always miss one.

#### L21. Instruction Proximity Determines Compliance

**What happened**: Execute+Review instructions existed in two places: (1) file top (~150 lines away), (2) a separate injection file. By execution time, both were pushed out of context. The agent only had a compressed one-liner saying WHAT to do, not HOW.

**Fix**: Added dedicated inline sections immediately adjacent to each execution point.

**Universal takeaway**: The probability of an instruction being followed is inversely proportional to its distance from the execution point. File-top instructions are "documentation" by execution time. Adjacent instructions are "working memory." Same principle as L1 and L14, generalized.

#### L13. Rule Changes Require Re-execution to Validate

**What happened**: Applied 4 fixes. Code review said they looked correct. Re-execution showed fixes 1-3 worked, fix 4 failed completely — the agent simply ignored it.

**Fix**: Established a feedback loop: apply fix → re-run pipeline → observe behavior → fix again if needed.

**Universal takeaway**: You cannot validate agent behavior rules by reading the rules. Only re-execution reveals whether the rule actually changes agent behavior. Budget time for at least 2 iterations.

---

### Theme C: Build and Verification Traps

#### L5. State Selector Instability — Build Passes, Runtime Loops

**What happened**: Zustand selectors created new array/object references every render → infinite re-renders. Build, TypeScript, and tests saw nothing wrong.

**Universal takeaway**: State library selector patterns that create new references per render are invisible to static analysis. Only runtime verification or pattern-aware scanning detects them. Applies to Zustand, Redux, MobX, and similar libraries.

#### L19. Build Success ≠ Output Correctness

**What happened**: Tailwind CSS 4 plugin not registered in build config. UI was completely unstyled, but build/TypeScript/tests all passed. Generalized to all build-time frameworks: CSS, i18n, codegen, asset pipelines.

**Universal takeaway**: Build-time transformation frameworks (Tailwind, i18next, code generators) fail silently when their plugins aren't registered. The build succeeds because the framework's absence doesn't cause errors — it just produces no output. Detection requires two checks: (a) is the plugin registered? (b) does the runtime output look correct?

#### L6. Test Files Are Not Demos

**What happened**: Agent generated test suites as "demos." They were executable but didn't demonstrate the feature.

**Universal takeaway**: "Executable" and "demonstrable" are different. A demo's purpose is to showcase functionality to a human, not to assert correctness programmatically.

---

### Theme D: Cross-System Coordination

#### L16. Runtime Coupling ≠ Implementation Dependency

**What happened**: `Shell imports DB at startup` was interpreted as `Shell depends on DB for implementation`. This put the DB Feature before Shell in the dependency graph — but Shell can be implemented without DB code existing.

**Universal takeaway**: Feature dependency = implementation ordering ("I need B's code to write A"), NOT runtime initialization sequence. Test: "If B didn't exist, could I still write A from scratch?" If yes, A doesn't depend on B.

#### L17. Automation Platform Noise ≠ Application Errors

**What happened**: Playwright's `evaluate()` triggered Chromium's anti-XSS warning. Console error scanning misclassified this as an app error.

**Universal takeaway**: Automation tools inject code that triggers platform warnings. Console error scans must maintain a filter list of known automation artifacts (Chromium warnings, deprecation notices, DevTools messages).

#### L18. Pre-Allocated Numbers Conflict with Auto-Numbering

**What happened**: smart-sdd created branch `002-navigation`, then spec-kit's auto-numbering detected 002 as "in use" and created `003-navigation` instead.

**Universal takeaway**: When two systems both create numbered resources and one runs before the other, pass the number explicitly from the controlling system. Don't rely on auto-detection.

#### L22. Pre-Context Assumptions Drift After Dependencies Complete

**What happened**: Pre-context said "better-sqlite3" but the dependency Feature had switched to electron-store during implementation. The downstream Feature's spec was based on stale assumptions.

**Universal takeaway**: Any artifact written before implementation is a hypothesis. When dependencies change during the pipeline, downstream artifacts become silently wrong. Every step that reads a pre-implementation artifact should cross-check it against actual completed implementations.

---

### Theme E: Process and Maintenance

#### L2. Feature Ordering Must Survive Edge Cases

**What happened**: Release-Group-first ordering worked when all tiers were active but skipped features when only T1 was enabled.

**Universal takeaway**: Test ordering logic under minimal configurations, not just full configurations.

#### L3. Tool Availability Must Be Verified Early

**What happened**: "eslint: command not found" at every Feature's verify phase.

**Universal takeaway**: Don't assume tools are installed. Verify once at pipeline start, cache the result.

#### L4. Logic and Display Must Update Together

**What happened**: Added verification items to the logic file but forgot to update the display file → items were checked but never shown to the user.

**Universal takeaway**: When logic and display are in separate files, always update both. Create a review checklist: "which downstream files consume this value?"

#### L7. Paths Must Be Relative

**What happened**: Absolute paths to source files → unresolvable on other machines.

**Universal takeaway**: Store a base path separately. All file references should be relative + runtime-resolved.

#### L8. New Mechanisms Require Downstream Tracing

**What happened**: Added 10 new verification items. None of the downstream files (injection, display, checkpoint) were updated.

**Universal takeaway**: When adding any new mechanism, trace: "which files READ this value?" Update all of them.

#### L9. Rules Should Describe Patterns, Not Instances

**What happened**: Bug prevention rules referenced specific features: "F005 Zustand selector instability." These looked narrowly applicable.

**Universal takeaway**: Describe the *pattern*, not the *instance*. "State selector creating new references per render" is universal. "F005 Zustand selector instability" is a case study. Patterns go in rules; instances go in history.

---

### Theme F: Verification Completeness

#### L23. Automation-Impossible ≠ Verification Skip

**What happened** (SKF-033/034): `manual` SCs and `manual-only` TEST PLAN items were silently skipped during verify — no error, no warning, just unverified. The agent treated "can't automate" as "doesn't need verification."

**Universal takeaway**: When automated verification is impossible, the system must explicitly route to user-assisted verification — not silently omit. Every verification item must end in one of three states: machine-verified ✅, user-verified ✅, or explicitly acknowledged as unverifiable ⚠️. "Skipped because no automation path" is not a valid state.

#### L24. Test State Isolation — False Results from Persisted State

**What happened** (SKF-028): Tests passed because previous test runs left data in the app's persistent storage. The feature appeared to work because it was reading stale data, not generating fresh data.

**Universal takeaway**: 3-tier isolation strategy: (1) clean data directory before test run, (2) reset API/service state, (3) read-before-act pattern (verify initial state before asserting behavior). Applies to any system with persistent state — databases, file caches, browser storage, config files.

#### L25. Feature Reachability — Code Exists but User Can't Reach It

**What happened** (SKF-029): A feature was fully implemented and tests passed, but users couldn't reach it — no navigation path from the home screen. The feature was an orphan in the UI.

**Universal takeaway**: For GUI features, verify the navigation path from the entry point (home screen) to the feature. A feature that exists but can't be reached is functionally nonexistent. This is the UI analog of the "orphaned service" pattern (G1).

#### L26. Async Hydration Sync — External Systems Stale After Config Load

**What happened** (SKF-030): App loaded async configuration (from store/API/file), updated internal state, but didn't sync dependent external systems. The external system operated with default/stale configuration until next restart.

**Universal takeaway**: After any async config hydration, unconditionally sync all dependent external systems. Don't assume the external system's initial state matches the loaded config. Pattern: `loadConfig() → applyToState() → syncExternalSystems()`. The third step is always forgotten.

#### L27. Dead Schema — Defined but Never Consumed

**What happened** (SKF-028~032, internal review): F8 Toolchain Commands and F9 Scan Targets were fully defined in Foundation files with text claiming "Foundation Gate reads F8" and "Phase 2 reads F9" — but neither pipeline.md nor analyze.md actually referenced these sections. The schema was dead code.

**Universal takeaway**: When defining a new schema/format, immediately add the consumption logic in the consumer files. "Will be read by X" is not the same as "X reads this." Trace the data flow end-to-end: producer → storage → consumer. A schema with no consumer is documentation, not infrastructure.

#### L28. Checklist-Implementation Divergence

**What happened** (internal review): Step 3f (User-Assisted SC Completion Gate) was fully implemented in verify-phases.md at line ~1594 with complete logic, but was missing from the Phase 3 checklist at line ~1026. The checklist jumped from 3e to 3f2, making Step 3f invisible to the execution flow.

**Universal takeaway**: When adding a new step to a multi-step process, update BOTH the implementation AND the index/checklist that enumerates the steps. Implementation without checklist entry = invisible step. Checklist entry without implementation = phantom step. Both cause failures.

### Theme G: Pipeline Architecture Patterns

#### L29. Ad-hoc Rules Don't Scale — Generalize into Guards

**What happened** (SKF-001~044): Over 5 Features (F001–F005), 44 individual failure reports were filed. Each was reflected as a specific rule in the relevant file. But the rules accumulated without structure — implement.md grew to 960+ lines, verify-phases.md to 1890+ lines. Agents started ignoring rules due to context pressure, causing the same *class* of failure to recur in different *instances*.

**Universal takeaway**: When individual rules exceed ~20 for the same failure class, stop adding rules and extract a **Guard Pattern** — a generalized trigger/verification/enforcement template. The Guard tells the agent *why* to check, *when* to check, and *how strongly* to enforce. New incidents extend the existing Guard (add a row to a table) instead of creating a new standalone rule. See `pipeline-integrity-guards.md` for the 7 Guards extracted from 44 SKFs.

#### L30. Single-Direction Trust Kills Pipelines

**What happened** (SKF-013/014/015/044): A wrong runtime default (`navbarPosition: 'left'` instead of `'top'`) was inferred at reverse-spec via static code analysis. This wrong assumption propagated unchanged through specify → plan → tasks → implement → verify — 6 stages, 27 files, 3 user feedback rounds to discover. No stage independently verified the assumption.

**Universal takeaway**: In any multi-stage pipeline where each stage trusts the previous stage's output, insert **circuit breakers** — independent verification points that check critical assumptions against ground truth (runtime state, source app, user confirmation). Minimum 2 breakers: one early (after initial analysis) and one late (before final delivery). The cost of 2 extra checks is trivial compared to 6-stage error propagation.

#### L31. Granularity Mismatch — Analysis Resolution Must Match Problem Resolution

**What happened** (SKF-028/037/038/039): SBI extraction operated at file level ("renders settings page"), FR→Task mapping at FR level ("ChatHeader covers FR-003"). But actual bugs occurred at control level (missing model selector dropdown, missing theme toggle). 14 controls on a settings page → 1 SBI entry → 13 controls lost.

**Universal takeaway**: The granularity of analysis must match the granularity of the problem domain. For UI, the problem domain is individual interactive controls. For APIs, it's individual endpoints. For data, it's individual fields. When analysis granularity is coarser than problem granularity, bugs hide in the aggregation. Rule of thumb: if a single analysis unit contains 5+ distinct user-visible behaviors, decompose it.

#### L32. Test Environment ≠ User Environment — Both Must Pass

**What happened** (SKF-033/040/043): Playwright tested in clean state (no persisted data, default settings). All tests passed. User's app had fontSize:22, dark theme persisted, API keys saved — and UI was broken (double scrollbars, invisible switches, stale data). The clean-state tests were true positives for clean state but false negatives for real state.

**Universal takeaway**: Automated tests prove the feature works *in the test environment*. They say nothing about the user's environment unless the test environment replicates it. For any feature with persistent state, test in both clean AND seeded environments. The seeded environment should include: non-default settings, edge-case values (max fontSize, long strings), and data from previous sessions.
