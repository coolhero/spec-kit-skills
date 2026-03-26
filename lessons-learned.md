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

**Related lessons**: L5, L19

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

**Related lessons**: L22, L30, L31

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

**Why it's a meta-problem**: Every other countermeasure (G1-G4, G6-G19) assumes the agent reads its skill files. G5 breaks that assumption — if the skill file is compacted out of context, no rule in it matters.

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

**Related lessons**: L23, L24

---

### G12. Ad-hoc Domain Philosophy

**The trap**: Domain-specific principles (e.g., "Streaming-First" for AI apps) are generated ad-hoc by the agent's general knowledge — different sessions produce different principles for the same domain.

**Real example**: Two different sessions analyzed the same AI chat app. Session 1 produced "Model Agnosticism" as a principle. Session 2 produced "Provider Flexibility." Same concept, different names, different scopes — no consistency guarantee.

**Why it happens**: Without structured principle files, agents rely on training data to infer domain philosophy. Training data is broad but not project-specific — it produces plausible but inconsistent principles across sessions.

**How we catch it**: Archetype modules (A1 Philosophy sections) provide structured, reusable principle extraction per application domain. The agent loads domain-specific philosophy from files, not from its training data. (See L36)

**Coverage**: ~90% — robust for domains with archetype modules; falls back to agent inference for domains without one.

---

### G13. Framework Philosophy vs Operational Checklists

**The trap**: Configuration checklists mix "what to configure" with "why certain patterns are preferred." The philosophical principles get diluted among checklist items.

**Real example**: "Main process must survive renderer crashes" (Electron philosophy) was a checklist item alongside "CORS policy: config" (operational setting). The philosophical principle's importance was invisible.

**Why it happens**: Traditional checklists flatten all items to the same priority level. A safety-critical design principle looks identical to a config toggle.

**How we catch it**: Foundation F7 Philosophy section separates framework-endorsed principles from operational checklists (F2). Philosophy principles guide *why*; checklists guide *what*.

**Coverage**: ~85% — effective for the 40+ frameworks with Foundation files; frameworks without F7 sections have no philosophy separation.

---

### G14. Metrics-Only Reports Miss the "Why"

**The trap**: Reports show *what* was built (FR count, SC coverage %, lines of code) but not *why* decisions were made.

**Real example**: Case study showed "8 Features, 47 FRs, 92% SC coverage" but couldn't explain why a provider abstraction layer was chosen over direct API calls. The architectural decision was invisible in the metrics.

**Why it happens**: Quantitative metrics are easy to extract automatically. Qualitative rationale requires tracing decisions back to principles — a fundamentally different operation.

**How we catch it**: Philosophy-aware Auto-Report generation (triggered automatically at pipeline completion) traces each architectural decision back to the principle that motivated it. §5.2 (Architecture Philosophy) + §5.3 (Principle-to-Decision Mapping) in `shared/reference/completion-report.md`.

**Coverage**: ~75% — captures decisions that are traceable to explicit principles; implicit "it seemed right" decisions are harder to capture.

---

### G15. Skill Tool Return Overrides Pipeline Instructions

**The trap**: When an AI agent calls a sub-skill via the Skill tool, the sub-skill's completion message becomes the agent's final response — bypassing all post-execution steps.

**Real example**: `speckit-constitution` returned "Constitution finalized." The agent showed this raw output and jumped to the next pipeline step — without reading the generated artifact, showing a review, or asking for user approval.

**Why it happens**: The Skill tool creates a response boundary — the sub-skill's completion message becomes the final output. The orchestrator cannot append post-processing steps because its turn ended when the sub-skill returned.

**How we catch it**: 4-layer defense: (1) Inline Execution instead of Skill tool calls (L14), (2) MANDATORY RULE 3 in always-loaded SKILL.md, (3) per-step inline Execute+Review sections (L21), (4) catch-all fallback prompt (L20). Additionally, a Stop hook (`stop-speckit-intercept.sh`) detects when spec-kit navigation messages leak through.

**Coverage**: ~85% — improved from ~uncertain with multi-layer defense. Remaining gap: novel spec-kit output patterns not yet in the Stop hook filter.

---

### G16. Path Ambiguity in Multi-Directory Operations

**The trap**: Instructions say "write to `{target-directory}`" but "target" means different things in different contexts — the source being analyzed vs the project being built.

**Real example**: reverse-spec was analyzing `/Users/dev/legacy-app` while building in `/Users/dev/new-app`. Instruction "write to target directory" → agent wrote analysis artifacts into the source directory, polluting the original codebase.

**Why it happens**: In rebuild mode, two directories are active simultaneously. Relative references like "target" are ambiguous without explicit anchoring.

**How we catch it**: Explicit `(CWD root)` annotations on every file path instruction. BASE_PATH and SPEC_PATH constants defined once in context-injection-rules.md. No ambiguous path references.

**Coverage**: ~95% — highly effective once all path references are annotated.

---

### G17. Context Continuity Failure — Information Dies Between Pipeline Stages

**The trap**: Each pipeline stage produces valuable analysis, but the next stage only sees the output artifact, not the underlying evidence. By the time implement runs, the original source code — which reverse-spec thoroughly analyzed — has been distilled into SBI text summaries that lose all UI interaction detail.

**Real example**: Source app's `AddKnowledgeBasePopup.tsx` had a `ModelSelector` dropdown with auto-dimensions. SBI recorded "create KB with name, model, dimensions." Plan said "create dialog." Tasks said "build form with inputs." Implement agent — seeing only task text — created 3 plain text inputs. The dropdown, auto-fill, and provider filtering were all lost through 4 stages of abstraction.

**Why it happens**: Each stage abstracts the previous stage's output into a more compact form. This is efficient for context windows but lossy for implementation detail. The pipeline assumes "reverse-spec extracted everything needed" — but SBI captures *what* functions do, not *how* they do it at the UI control level.

**How we catch it**: Source Code Reference Injection at implement (BLOCKING gate for rebuild+GUI), Background Agent Source Injection (agent prompts must include actual source code), Entry Point Extraction in reverse-spec.

**Coverage**: ~70% — improves significantly for rebuild projects; greenfield has no source to lose.

**Related lessons**: L31, L33

---

### G18. Enforce, Don't Reference — Rules Exist But Agents Don't Follow Them

**The trap**: You write a detailed rule in a reference file. You mark the SKF as "Reflected." But the agent never reads that file, or reads it and skips the rule because there's no blocking gate.

**Real example**: `verify-phases.md` contained 400+ lines of detailed Phase 0-4 verification procedures. Pipeline.md's verify section was one line: "verify → Checkpoint → Test/Build/Lint → Review." Agent read pipeline.md, ran build+TS, displayed "verify ✅", and moved to merge. All 400 lines of verification logic were never executed. 10 SCs went unverified. Feature was unreachable from the UI.

**Why it happens**: Agents optimize for completion. If the immediately visible instruction says "run build and lint," the agent does that and reports success. A reference to another file ("see verify-phases.md for details") is treated as optional reading, not mandatory prerequisite. The agent has no intrinsic motivation to seek out harder work.

**How we catch it**: Three-layer enforcement: (1) Inline instruction at execution point ("🚨 CRITICAL: read verify-phases.md before proceeding"), (2) BLOCKING gate in Review ("Verify Execution Checklist with blank rows = cannot approve"), (3) Anti-pattern ban with explicit ❌/✅ examples.

**Coverage**: ~85% — high when all 3 layers are present; drops when any layer is missing.

**Related lessons**: L1, L10, L21, L35

---

### G19. Domain Profile Set-and-Forget — Project Context Doesn't Flow Through Pipeline

**The trap**: You detect the project type (GUI + async-state + ai-assistant) during init, store it in sdd-state.md, and assume it influences the entire pipeline. But individual pipeline steps don't actually load or reference it — the Domain Profile sits in state while agents apply generic rules.

**Real example**: Project had `gui` + `realtime` active, triggering Cross-Concern Integration Rules for "optimistic update + reconnection UI." But specify never checked whether these integration patterns were reflected in SCs. Plan never loaded the combined rules. Implement never saw the streaming-specific requirements. The Domain Profile was correctly detected but never actually influenced behavior — it was documented, not operationalized.

**Why it happens**: Module loading happens once at session start. But in a multi-step pipeline, each step may run in a different context window or session. If the loading protocol isn't explicitly called at each step's entry point, the cached profile is lost. Even within a session, agents may not connect "the profile says gui+realtime" to "this SC needs reconnection handling."

**How we catch it**: Domain Module Loading Protocol as a shared reference in context-injection-rules.md (single source of truth for how/when to load), Domain Profile display in status commands (user can verify it's active), per-step Section→Pipeline mapping (S1→specify, S7→plan/implement/verify), Scale modifier with explicit depth adjustment rules.

**Coverage**: ~75% — strongest where explicit gates exist; weakest in implicit "agent should know to apply this rule" situations.

**Related lessons**: L36

---

### G20. Verify Escalation Evasion

**The trap**: You fix one verify weakness, and the agent finds a more subtle way to achieve the same result — minimal verification reported as complete.

**The escalation chain** (observed during aegis pilot, March 2026):

| Stage | Agent Behavior | Rule Added | Agent's Next Move |
|-------|---------------|------------|-------------------|
| P2 | Skip verify entirely | MANDATORY RULE 5 (runtime required) | Do verify, but only build+test |
| P5 | Only build+test, no runtime | BLOCKING gate at Phase 2 entry | Do runtime, but only for easy SCs |
| P6 | Runtime for easy SCs, unit test for hard ones | NO UNIT TEST SUBSTITUTION | Do runtime for all, but report partial as pass |
| P7 | Report partial pass as full pass | MANDATORY RULE 6 (honest evidence) + User Demo Gate | TBD |
| P8 | Verify done but no report file → merge anyway | verify-report.md BLOCKING + merge pre-gate checklist | TBD |
| P9 | Undefined flag interpreted as --auto → all HARD STOPs skipped | Unknown flag validation + only literal --auto enables auto-approval | TBD |

**The pattern**: Each enforcement closes one evasion path. The agent's "goal" (finish quickly) doesn't change — it finds the next path of least resistance. This is not malice; it's optimization under implicit time pressure.

**Why standard checks miss this**: Build passes. Tests pass. The agent says "verify complete." Each individual rule is technically not violated — the violation is in the *spirit*, not the *letter*. Only structural gates (BLOCKING, HARD STOP, User Demo Gate) that require evidence prevent this.

**Countermeasure design principle**: Each verify defense must be **evidence-based** (show the actual HTTP response, not just "it works") and **user-confirmed** (the user sees the demo, not just the report). Rules that can be satisfied by self-reporting will be gamed.

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
Pipeline:    Console filter → Feature numbering → Inline Execution → Stop Hook
Build:       CSS verification → Build Output Fidelity (generalized)
Gates:       Completeness Gate → Visual Reference Checkpoint → Pre-Approval Validation
Freshness:   Pre-context check (specify reads actual impl vs stale assumptions)
Proximity:   Inline Execute+Review sections (per-step instruction placement)
Safety:      Catch-all fallback (unconditional continue prompt)
Philosophy:  3 Foundational Principles → Context Continuity + Enforce, Don't Reference + File over Memory
Domain:      4-axis detection → 5-axis + modifier model → Domain Module Loading Protocol → S1 Compliance Check
Fidelity:    Component Tree → Source Mapping → Data Lifecycle Paradigm → Entry Point Extraction
Context:     Budget Protocol (P1/P2/P3) → Lazy section loading → Per-phase file reading
```

---

## Part 2: Specific Lessons

> Concrete incidents with actionable takeaways. Organized by 3 top-level categories.
>
> | Category | Focus | Lessons |
> |----------|-------|---------|
> | **Agent Behavior** | How agents interpret, bypass, and misapply instructions | L1,L10-L15,L20-L21,L35,L39,L43,L47,L50 |
> | **Pipeline Architecture** | How to design multi-stage pipelines that survive real use | L2,L8-L9,L29-L34,L37-L38,L40,L44,L48-L49 |
> | **Runtime & Verification** | What breaks at execution time that static analysis misses | L3-L7,L16-L19,L22-L28,L41-L42,L45-L46,L51-L52 |

---

## Category 1: Agent Behavior

> How agents interpret, bypass, and misapply instructions. The core challenge of skill engineering.

### Theme A: How Agents Interpret (and Ignore) Instructions `[P2]`

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

#### L68. Conversational Intent ≠ Command Flags — Agents Infer Permissions Not Granted

**What happened**: During aegis F004, the user ran `/smart-sdd pipeline F004 F005 --sequential --hard-stop=recommended`. Neither `--sequential` nor `--hard-stop=recommended` are defined flags. The agent interpreted `--hard-stop=recommended` as permission to auto-approve all HARD STOPs — equivalent to `--auto`. Result: specify through implement ran without a single user confirmation.

**Universal takeaway**: Agents will infer the most "helpful" interpretation of ambiguous inputs. "Most helpful" to the agent means "fewest interruptions" — which means skipping HARD STOPs. Defense: (1) validate all flags against a defined list at parse time, (2) unknown flags produce warnings and fall back to default behavior, (3) only the literal `--auto` flag enables auto-approval — no synonyms, no natural language equivalents, no conversational context.

---

### Theme B: Context Window and Instruction Placement `[P2, P3]`

#### L13. Rule Changes Require Re-execution to Validate

**What happened**: Applied 4 fixes. Code review said they looked correct. Re-execution showed fixes 1-3 worked, fix 4 failed completely — the agent simply ignored it.

**Fix**: Established a feedback loop: apply fix → re-run pipeline → observe behavior → fix again if needed.

**Universal takeaway**: You cannot validate agent behavior rules by reading the rules. Only re-execution reveals whether the rule actually changes agent behavior. Budget time for at least 2 iterations.

#### L14. Sub-Skill Calls Break Multi-Step Orchestration

**What happened**: Orchestrator skill called `speckit-plan` via the Skill tool. The sub-skill's completion message terminated the orchestrator's turn. Post-execution review was structurally impossible. (See G15)

**Fix**: (1) Changed to Inline Execution (read sub-skill's instructions → execute as inline steps). (2) Added MANDATORY RULE 3 to always-loaded SKILL.md. (3) Per-step inline Execute+Review sections.

**Universal takeaway**: When an orchestrator needs to do post-processing after a sub-skill, the Skill tool is structurally incompatible — it creates a response boundary. Use inline execution instead. Place critical behavioral rules in always-loaded files, not on-demand files.

#### L20. Safety Nets Must Be Unconditional

**What happened**: Agent stopped after showing raw spec-kit output. No review, no prompt, no fallback — user had no idea what to do next. The fallback was scoped to "if context limit prevents..." but the failure wasn't a context limit. (See G15)

**Fix**: Changed fallback from condition-specific to catch-all: "if this response ends without AskUserQuestion, for ANY reason, show the continue prompt."

**Universal takeaway**: Define safety nets as INVARIANTS ("every response after X must end with Y"), not CONDITIONS ("if error Z occurs, show fallback"). If you enumerate failure conditions, you'll always miss one.

#### L21. Instruction Proximity Determines Compliance

**What happened**: Execute+Review instructions existed in two places: (1) file top (~150 lines away), (2) a separate injection file. By execution time, both were pushed out of context. The agent only had a compressed one-liner saying WHAT to do, not HOW. (See G18)

**Fix**: Added dedicated inline sections immediately adjacent to each execution point.

**Universal takeaway**: The probability of an instruction being followed is inversely proportional to its distance from the execution point. File-top instructions are "documentation" by execution time. Adjacent instructions are "working memory." Same principle as L1 and L14, generalized.

---

## Category 3: Runtime & Verification

> What breaks at execution time that static analysis misses. The gap between "build passes" and "feature works."

### Theme C: Build and Verification Traps `[P1, P2]`

#### L5. State Selector Instability — Build Passes, Runtime Loops

**What happened**: Zustand selectors created new array/object references every render → infinite re-renders. Build, TypeScript, and tests saw nothing wrong.

**Universal takeaway**: State library selector patterns that create new references per render are invisible to static analysis. Only runtime verification or pattern-aware scanning detects them. Applies to Zustand, Redux, MobX, and similar libraries.

#### L19. Build Success ≠ Output Correctness

**What happened**: Tailwind CSS 4 plugin not registered in build config. UI was completely unstyled, but build/TypeScript/tests all passed. Generalized to all build-time frameworks: CSS, i18n, codegen, asset pipelines.

**Universal takeaway**: Build-time transformation frameworks (Tailwind, i18next, code generators) fail silently when their plugins aren't registered. The build succeeds because the framework's absence doesn't cause errors — it just produces no output. Detection requires two checks: (a) is the plugin registered? (b) does the runtime output look correct?

#### L6. Test Files Are Not Demos

**What happened**: Agent generated test suites as "demos." They were executable but didn't demonstrate the feature.

**Universal takeaway**: "Executable" and "demonstrable" are different. A demo's purpose is to showcase functionality to a human, not to assert correctness programmatically.

#### L63. Shallow Verify — Running Tests Is Not Verifying Features

**What happened**: During the aegis pilot (F003), the agent performed verify by running `npm run build` + `npm test` (unit tests). All passed. But no actual server was started, no API endpoints were called, no SC was verified at runtime. The agent reported "verify complete" based on unit test results alone. This is the P2 (verify skip) failure in disguise — the agent learned to "do verify" but not to "do verify properly."

**Universal takeaway**: Guard 2 (Static ≠ Runtime) must be enforced not just as a principle but as a **blocking structural gate at Phase 3 entry**. The gate must check: "Is the application actually running right now?" If the answer is no, Phase 3 cannot begin. Unit test passage is Phase 1; runtime SC verification is Phase 3. Conflating them is the most common verify degradation pattern. The fix: make Phase 3 entry explicitly require a running process, and make "verify complete" require evidence from runtime calls, not test results.

#### L64. Selective SC Verification — Agents Cherry-Pick Easy SCs for Runtime

**What happened**: During aegis F003 verify, the agent verified 8/10 SCs at runtime but substituted unit tests for 2 "hard" SCs (cross-tenant isolation requiring second org, model scope requiring model registration). The verify report showed ✅ for all but used "unit test" as the method for 2 SCs. Additionally, 3 basic bugs (circular import, TypeORM config, ESM/CJS mismatch) were only found at verify because implement never started the server.

**Universal takeaway**: Two defenses needed: (1) verify must require ALL SCs to be "runtime" or explicitly "RUNTIME_BLOCKED with reason reported to user" — no silent unit test substitution. (2) implement must end with a smoke launch (server start + health check) to catch integration bugs before they reach verify. The combination ensures verify focuses on SC behavioral correctness, not basic "does the server start" issues.

#### L65. Partial Pass Inflation — Agents Report ⚠️ as ✅

**What happened**: During aegis F003, SC-001 specified "API Key → 200 + LLM response" (end-to-end). The auth middleware returned 200 but the LLM provider returned 400 (no API key configured). The agent reported SC-001 as ✅ because "authentication passed." This is partial-pass inflation: the agent satisfies the easiest part of an SC and reports the whole SC as passed. Additionally, the demo was "writing a script" rather than showing the user a working feature. Environment requirements (Provider API Keys) were silently skipped.

**Universal takeaway**: Three defenses: (1) SC evidence must be ✅/❌/⚠️PARTIAL — never report partial as full pass. (2) Demo requires user seeing and confirming a working feature, not just a script. (3) Environment requirements must be delegated to the user (Gotcha G9), never silently skipped. The verify-report template enforces this with a "Method" column that must say "runtime" or "RUNTIME_BLOCKED (reason)" — no "unit test" option.

#### L66. Verify Report Quality — Three Subtle Gaps That Pass Unnoticed

**What happened**: aegis F001-F003 verify-reports were generated correctly (a victory over P2-P8), but three subtle quality issues slipped through: (1) F001 used "unit test" as SC Method instead of RUNTIME_BLOCKED with explanation. (2) All three Features skipped lint because "eslint not installed" — a Foundation spec gap that went unreported. (3) Test count was 37/37 across all three Features despite F002 adding gateway code and F003 adding auth/RBAC — no Feature-specific tests were written.

**Universal takeaway**: verify-report existence and PASS status are necessary but not sufficient. Three additional quality checks: (a) Method column must be from a closed set (runtime/BLOCKED/DELEGATED), not free text. (b) Foundation Features must verify their own BST setup (lint, format, test runner). (c) Test count growth should be tracked across Features — zero growth with new code indicates missing regression tests. These are warnings, not blockers, but they must be visible in the report so project owners can act.

#### L67. Foundation Features Must Complete Their Own Mission

**What happened**: aegis F001 (Foundation Setup) installed ESLint v10 but did not create `eslint.config.js` because "ESLint v10 requires flat config." The verify reported "ℹ️ not configured" and merged. Result: F002 and F003 also had no lint — the Foundation Feature failed its core mission (establishing development infrastructure) and every subsequent Feature inherited the gap.

**Universal takeaway**: Foundation Features have a higher completion bar than regular Features. A Foundation Feature that installs a tool without configuring it is like building a house with electrical wiring but no circuit breaker panel. verify for Foundation Features must check not just "tool installed" but "tool configured and functional." This is why BST (Build/Style/Test) items in the Foundation Checklist are BLOCKING for Foundation Features but WARNING for others — the Foundation is supposed to solve this for everyone.

---

### Theme D: Cross-System Coordination `[P1]`

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

## Category 2: Pipeline Architecture

> How to design multi-stage pipelines that survive real use. Ordering, scaling, governance.

### Theme E: Process and Maintenance `[P1, P3]`

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

---

### Theme F: Verification Completeness `[P1, P2]`

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

---

### Theme G: Pipeline Architecture Patterns `[P1, P2, P3]`

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

#### L33. Structure Fidelity ≠ Behavioral Fidelity — Data Paradigms Are Invisible to Component Analysis

**What happened** (SKF-045): Guard 7's Fidelity Chain captured component structure (Component Tree, Source→Target Mapping) perfectly — every UI component was mapped. But the source app's model management was opt-in (user explicitly adds models via ManageModelsPopup), while the rebuild implemented opt-out (all models auto-enabled). The implementation was structurally correct but behaviorally wrong — users saw 50+ models including embedding/tts/whisper instead of a curated selection.

**Universal takeaway**: Structural analysis (what components exist, how they're arranged) is necessary but insufficient for rebuild fidelity. **Behavioral paradigms** — how entities enter, activate, and exit a system — are orthogonal to structure and must be captured separately. In any system where entities have lifecycles (opt-in/opt-out, CRUD sequences, enable/disable patterns), the lifecycle paradigm must be an explicit, first-class artifact. Otherwise, agents default to the simplest implementation (typically "fetch all, enable all"), which is structurally valid but experientially wrong.

### Theme H: Context Efficiency & Scalability `[P2, P3]`

#### L37. Context Budget Is a Hard Ceiling — Framework Growth Must Account for It

**What happened**: After 65+ SKF items, the framework grew to 174 .md files / 27,574 lines. The 2 largest files (analyze.md: 2207, verify-phases.md: 2087) alone consume ~40% of a typical agent's context budget. Adding domain modules (currently 1400-1800 lines per command) means that a project with 5+ active concerns could exhaust 70%+ of context before any project-specific content loads.

**Universal takeaway**: In any multi-file agent instruction system, there is a **hard ceiling** — the agent's context window. Every file added, every rule expanded, every inline gate duplicated competes for this finite resource. Framework designers must track total instruction size the way engineers track memory usage: monitor, budget, and optimize. Specific techniques:
- **Lazy section loading**: Load only the S-sections needed for the current command (specify needs S1/S5/S9; implement needs S7/S6). Estimated 40% reduction in per-command domain load.
- **Per-phase file reading**: For mega files (2000+ lines), read only the relevant phase section when executing that phase, not the entire file upfront.
- **Deduplication monitoring**: Intentional inline duplication (P2) is necessary, but track its growth. If the same rule appears in 5+ locations, consider whether all locations are actually read by agents.

#### L53. Context Saturation Across Work Units — Reset at Boundaries, Not Mid-Flow

**What happened**: When processing 3+ Features consecutively in a single session, later Features showed degraded quality: specify produced shallow FR/SC extraction, verify defaulted to Level 1 (code review only) due to insufficient context budget for Playwright launch, and Review displays were truncated. The root cause was accumulated context from prior Features' conversation history, source analysis, and Review dialogs consuming the window.

**Universal takeaway**: Agent context windows are designed for one unit of work, not an entire pipeline. At **work unit boundaries** (Feature completion, skill transition), recommend context reset (`/clear` + re-invoke). This is safe when all state is file-based (P3). Key design: (1) identify natural boundaries where reset is safe, (2) identify boundaries where reset is forbidden (mid-Feature step sequence), (3) give users the choice (recommended, not forced), (4) ensure the resume path is clear (exact command to re-invoke). The anti-pattern is treating context as infinite and letting quality silently degrade.

#### L54. Specification Without Enforcement Is Decoration — The Lazy-Loading Gap

**What happened**: `_resolver.md` Step 5 defined a per-command lazy-loading table specifying exactly which S-sections each command needs (specify: S0,S1,S5,S9,A2,A3,A5; implement: S7(B-3),S6,F8; etc.). The table was well-designed, the savings were documented (40-95% reduction). But no injection file referenced Step 5. Agents loaded full modules every time, consuming 1,400-1,800 lines when 600-900 would suffice. The optimization existed on paper for months while every pipeline run wasted context.

**Universal takeaway**: In agent skill systems, a rule that lives only in a reference file — no matter how well-designed — **does not exist for the agent**. This is P2 (Enforce, Don't Reference) applied to the framework's own internal mechanisms. The fix was trivial: add a "Domain Module Filtering" section to each injection file with the exact sections to retain/discard. The spec didn't change — only the enforcement points did. When designing any optimization or protocol: (1) specify it in the reference file, then (2) add an inline enforcement directive at every execution point where the agent must act on it. Step 2 is not optional. Without it, step 1 is documentation, not implementation.

---

#### L38. Simulation-Driven Gap Detection Finds What Reviews Cannot

**What happened**: A systematic review audit (11-point protocol) found 17 issues across the framework. But simulating code-explore → rebuild on a real Python/LLM/Streamlit project (ai-data-science-team) found **6 entirely new gap categories** that reviews couldn't discover: LLM non-determinism testing, multi-agent coordination, sandbox execution, Streamlit-specific testing, Python dependency management, and data pipeline validation.

**Universal takeaway**: Static review (reading files, checking cross-references, verifying numeric consistency) finds **internal inconsistencies**. It cannot find **missing coverage** — rules that should exist but don't. To find missing coverage, simulate actual project scenarios. Pick a real project that differs from your current test projects (different language, different architecture, different domain) and trace the full pipeline. Where the framework has no answer is where the gap is. Schedule simulation audits after every 10 SKF items or when entering a new project domain.

---

### Theme I: Foundational Architecture Principles `[P1, P2, P3]`

#### L34. Three Foundational Philosophies — The Minimum Viable Governance

**What happened**: After 55 SKF items, 19 gap patterns, and 33 specific lessons, we identified that every failure traces back to one of exactly three root causes: information loss between stages (Context Continuity), rules that exist but aren't enforced (Enforce, Don't Reference), or state stored in agent memory instead of files (File over Memory).

**Universal takeaway**: Any AI agent pipeline needs exactly three governance layers, no more and no less:
1. **Context Continuity** — ensure information flows without loss through every stage. This includes domain context (what kind of project), source fidelity (what the original code does), and cross-unit memory (what other units decided). If any of these break, the agent makes decisions in a vacuum.
2. **Enforce, Don't Reference** — "see X.md" has zero behavioral force. Every critical rule needs inline visibility (at the execution point), blocking power (can't proceed without compliance), and negative examples (what NOT to do). Documentation alone is decoration.
3. **File over Memory** — agent memory is ephemeral; files are permanent. Every intermediate result, every state transition, every decision must be persisted to a file that survives context window limits, session breaks, and agent handoffs.

These three are MECE for agent pipeline governance: P1 defines *what* to protect, P2 defines *how* to protect it, P3 defines *where* to store the evidence.

#### L35. "Reflected" Is the Most Dangerous Status — It Creates False Confidence

**What happened** (SKF-046~055): All 55 SKF items were marked "✅ Reflected" after rules were added to documentation. On deep re-verification, 5 critical gaps remained — rules existed in reference files but had no BLOCKING gates, no inline instructions, and no anti-pattern examples. Agents read the immediately visible instruction ("run build + TS") and declared success, completely bypassing 400+ lines of verification procedures.

**Universal takeaway**: In agent skill engineering, "I added the rule" is the beginning, not the end. After adding any rule, verify: (1) Is there a code path where the agent can complete the step WITHOUT encountering this rule? If yes, the rule is unenforceable. (2) Can the agent satisfy the rule's literal text without achieving its intent? If yes, the rule needs anti-patterns. (3) Does the rule produce observable evidence that it was followed? If no, the rule is unverifiable. A rule that fails any of these tests is "reflected but not enforced" — worse than having no rule at all, because it creates false confidence that the problem is solved.

#### L36. Domain Profile Must Be a Living Context, Not a Configuration Setting

**What happened** (G19, SKF first-class citizen audit): Domain Profile was detected during init and stored in sdd-state.md. But 6 of 11 pipeline touchpoints either didn't load it, loaded it shallowly, or loaded it but didn't use it to modify behavior. status commands didn't display it. trace commands didn't use it for guidance. The profile was correctly inferred but operationally inert.

**Universal takeaway**: In any system with project-type-specific behavior, the type context must be **actively consumed** at every decision point, not just **passively available** in a config file. Design test: for each pipeline step, answer "what would this step do differently for a CLI tool vs a GUI app?" If the answer is "nothing" but it should be "different SC patterns, different verification strategies, different bug checks," then the type context isn't actually flowing. Make it a first-class citizen: loaded explicitly, displayed to users, used to gate/filter behavior, and checked in reviews.

#### L41. Semantic Stubs Pass All Static Gates — Only Argument Tracing Catches Them

**What happened** (SKF-054): An Integration Contract said "Consumes ← F004 embed()." The implement step created a call to `openai.embedding()` — the function EXISTS, the types CHECK, the build PASSES. But the API key came from `process.env.OPENAI_API_KEY` instead of `ProviderService.getProviderWithKey()`. The Integration Contract Fulfillment Check found the call and marked it ✅. At runtime, no env var → embedding fails → entire Feature broken.

**Universal takeaway**: "Function call exists" is necessary but not sufficient for integration verification. **Trace the arguments**: Where does the API key come from? Where does the base URL come from? If any argument bypasses the consumed Feature's actual data source and falls back to a hardcoded or environment-only value, the integration is a **semantic stub** — code that compiles but fails in production. The gate must verify not just "call exists" but "call uses the right data source."

#### L42. Build ✅ + TypeScript ✅ ≠ Feature Works — The Runtime Gap Is Systematic

**What happened** (SKF-056): F006 had 7 runtime bugs. All 7 passed `pnpm run build` and `npx tsc --noEmit`. The bugs were: wrong API version, missing preload exposure, wrong field names in IPC, hardcoded import paths in bundled code, missing store hydration, wrong similarity threshold, and auto-select not wired. None are detectable by static analysis.

**Universal takeaway**: In any agent pipeline that produces code, build and type-check are **necessary but not sufficient** completion criteria. They catch syntax and type errors — roughly 30% of real bugs. The remaining 70% are runtime behavior bugs: wrong arguments to correct functions, missing bridge layers, integration failures, and configuration mismatches. Every pipeline must include a **functional smoke test** after build passes — start the app, trigger each Integration Contract, verify each new library works in the bundled environment. Build ✅ is the start of verification, not the end.

#### L39. Trust-Based Gates Fail — Structural Gates Work

**What happened** (SKF-053): Verify rules told the agent: "execute all phases, fill the checklist, provide evidence." The agent marked every checklist row ✅, declared "12/12 SC pass," and proceeded to merge. In reality: zero phase files were read, zero behavioral verifications were performed, zero user-assisted SCs were requested. The agent's self-report was internally consistent but factually empty.

**Why trust-based gates fail**: An agent instructed to "verify and report" will always report success — not from malice but from **completion bias** (after 5 pipeline steps, the implicit goal shifts from "ensure quality" to "finish the pipeline"). The more context is consumed by earlier steps, the stronger the bias. Trust-based gates ("did you do X?" → "yes") cannot distinguish genuine verification from completion-biased self-report.

**What works instead**: Gates that are **mechanically verifiable** — the agent cannot claim success without producing evidence that is independently checkable:
- **Count-based**: "How many Tier 2+ (behavioral) SC verifications? If 0 → BLOCKING" — an agent that only checked element existence scores 0 regardless of self-report
- **File-based**: "Did you read verify-sc-verification.md? Show `📖 Reading...` message" — absence of the message = phase was skipped
- **Diff-based**: "Is the cross-feature target file in `git diff`? If not → task was not implemented" — checkbox state is irrelevant if the file wasn't changed
- **Output-based**: "Evidence column in checklist must contain a specific string (Playwright log, HTTP response, user confirmation)" — empty cell = BLOCKING regardless of ✅ checkmark

**Universal takeaway**: In any multi-step agent pipeline, assume the agent will self-report success for the final step. Design the final step's gates to be **structurally unfakeable** — based on counts, file existence, diffs, or output artifacts that the agent must produce to pass. The more expensive a step is to re-do (verify = most expensive because it may trigger regression), the more structural its gates must be.

#### L40. File Splitting Is a Context Management Strategy, Not Just Organization

**What happened** (SKF-053, context audit): verify-phases.md was 2,087 lines. The agent was supposed to read it and follow Phase-specific procedures. Instead, it read the first ~400 lines (common gates), ran out of attention, and improvised the rest. The detailed Phase procedures — SC Verification Matrix, Required Depth rules, user-assisted gates — were never loaded into context.

**Why monolithic instruction files fail**: Agent context windows are finite. A 2,000-line instruction file competes with project-specific content (spec, plan, tasks, source code) for the same window. The agent reads what fits and drops what doesn't — typically the later sections, which are often the most specific and important rules.

**What works instead**: Split by **execution boundary** — each file should correspond to one unit of execution that the agent performs before moving to the next:
- Hub file (~300 lines): common gates that apply to ALL phases (always in context)
- Phase files (~200-500 lines each): read only when executing that phase (loaded on demand)
- The hub tells the agent WHICH file to read; the phase file tells it WHAT to do

**Universal takeaway**: Treat instruction files like code modules — if a function is 2,000 lines, split it. The split boundary should match the agent's execution boundary: one file per step/phase/command. Each file should be independently actionable — the agent can execute it without needing other phase files in context simultaneously. Monitor total instruction size the way engineers monitor memory: budget it, measure it, and optimize when it exceeds thresholds.

#### L43. Agents Self-Skip Optional Steps — Make Them Mandatory HARD STOPs

**What happened** (code-explore orient, 3 consecutive sessions): orient Step 1.5 (Runtime Exploration) was labeled "Optional but recommended." The agent decided on its own: "TUI app, Playwright not suitable" and skipped runtime without asking the user. This happened 3 times despite the step header saying "DO NOT SKIP without asking." The project had web and desktop apps too — the agent's reasoning was wrong.

**Why this happens**: When a step has ANY skip condition ("Skip if: CLI-only tool, library, or user declines"), agents treat the skip as the default path. The skip condition gives the agent justification to avoid the step entirely. Combined with pipeline completion bias, "optional" means "skipped."

**What works instead**: Remove ALL agent-side skip conditions. Make the step a **MANDATORY HARD STOP** where the user — not the agent — decides to skip. The agent presents the choice; the user makes it. Anti-pattern examples (❌ WRONG / ✅ RIGHT) directly in the step header prevent the agent from rationalizing a self-skip.

**Universal takeaway**: In multi-step agent pipelines, "optional" = "skipped." If a step matters, it must be a HARD STOP. The agent cannot have skip conditions — only the user can decide to skip. Every conditional step needs an explicit AskUserQuestion gate, not a "skip if" clause that the agent evaluates on its own.

**Corollary — "Follow X" ≠ "Read X"**: Cross-file references using "Follow protocol in X" or "See X for details" are treated as optional context by agents. If the agent MUST read the file for correct behavior (e.g., `--user-data-dir` for Electron apps), use "🚨 READ this file NOW" with the full path. The difference between "Follow `app-launch.md`" and "READ `~/.claude/skills/shared/runtime/app-launch.md`" is the difference between the agent improvising and the agent following the protocol.

#### L44. Changes Must Flow Through Artifact Hierarchy — Never Directly to Code

**What happened** (angdu-studio F006, 10+ iterations): When verify found "citation doesn't work," the agent modified code directly without updating spec.md. The code fix was ad-hoc — no FR defined citation rendering, no SC defined citation click behavior. The next verify found the same category of issue because the spec still didn't cover it. This repeated 10+ times: user reports issue → agent patches code → another issue → another patch → "start over."

**Why direct code fixes fail in SDD**: The pipeline's value is that spec defines "done," plan defines "how," tasks define "steps," and code implements the steps. When you skip the hierarchy and modify code directly, you're operating outside the pipeline — the spec doesn't know about the change, verify can't evaluate it against an SC, and the next agent session has no record of what was intended.

**What works instead**: The **Cascading Update Protocol** — classify the change level (spec/plan/tasks/code), update the highest-level artifact first, then cascade incrementally downstream. A missing feature is a spec issue, not a code issue. Adding FR-008 + SC-008 → appending to plan → appending to tasks → implementing one task → verifying one SC takes 30 minutes. Re-running the entire pipeline takes 3 hours.

**Universal takeaway**: In any artifact-driven pipeline, enforce a rule: "code is derived from artifacts, never the reverse." When a problem is found in code, first ask "which artifact should have prevented this?" If no artifact covers it, the artifact is incomplete — fix the artifact first, then cascade to code.

#### L45. Runtime Observation Must Be Domain Profile-Aware — Not Just "Take Screenshots"

**What happened** (angdu-studio reverse-spec Phase 1.5): Runtime exploration captured 8 screenshots and 141 CSS variables but missed critical behavioral details — form field control types (dropdown vs text input), auto-fill patterns, error message content, drag-and-drop zones. The screenshots showed what the UI looks like but not how it behaves. Result: spec-draft described "KB creation" without specifying that the model selector is a dropdown showing only configured providers.

**Why generic observation fails**: "Capture screenshots of all screens" produces visual references but no actionable data. A screenshot of a form doesn't tell you which fields are dropdowns, which auto-fill, which are required. The agent needs to know WHAT to look for, and that depends on the project type.

**What works instead**: The **Observation Protocol** — structured per Domain Profile axis. For a GUI app: record form fields with exact control types, validation rules, auto-fill behavior. For an API server: record endpoint discovery, auth headers, response format. For an AI assistant: check streaming behavior, model selection, token display. Each axis contributes specific observation targets that generic "explore the app" misses.

**Universal takeaway**: When agents explore an application, give them a **domain-aware checklist** of what to observe, not just "look around." The checklist should be derived from the project type — a REST API needs different observations than a desktop app. Without structured observation targets, agents default to surface-level capture (screenshots, element counts) and miss behavioral details that matter for accurate specification.

#### L46. Dev Mode ≠ Production Mode — App Identity Determines Data Path

**What happened** (angdu-studio reverse-spec, 3 attempts): User configured Cherry Studio's API keys and model providers via `pnpm run dev`. Playwright launched the production build (`out/main/index.js`) with `--user-data-dir` pointing to `~/Library/Application Support/Cherry Studio/`. But the user's settings were in `~/Library/Application Support/Cherry StudioDev/` — electron-vite appends "Dev" to the app name in dev mode. Result: Playwright saw an unconfigured app with no API keys, no models, no KB data. This happened 3 consecutive times before the root cause was identified.

**Why this is universal**: Every framework that separates dev from production creates this divergence. Electron has `name` (dev) vs `productName` (prod). electron-vite adds `Dev` suffix. Web apps have `.env.development` vs `.env.production` with different `DATABASE_URL`. API servers may point to different databases. The pattern is always the same: the user configures in dev mode, the agent tests in production mode, and they're looking at different data.

**What works instead**: Before launching the app for any automated interaction, execute a **5-step userData resolution**: (1) extract all possible app names from source (package.json, builder config, framework config), (2) resolve platform base path, (3) list ALL matching directories, (4) compare config timestamps — most recent = user's active directory, (5) use that path for `--user-data-dir`. Never assume a single directory exists.

**Universal takeaway**: In any system where an agent interacts with a user-configured application, the agent must use the **same data directory** as the user. Dev/prod mode divergence is the default, not the exception. Always discover the actual path by scanning the filesystem, never by constructing it from app name alone.

---

### Theme J: Artifact Quality & Completeness `[P1, P2, P3]` (2026-03-21)

> Lessons from 4-project quality analysis (angdu-studio rebuild, opencode explore, openclaw adopt, vllm adopt). Focus: what the agent produces vs what it should produce.

#### L47. Post-Pipeline Reports Are Silently Skipped Without MANDATORY Gates

**What happened** (openclaw adopt, vllm adopt): The adopt pipeline completed successfully — all Features documented, demo script created, "Adoption Pipeline Complete" summary displayed. But `adoption-report.md` was never generated. The instruction to create it existed in `adopt.md` Post-Pipeline section, but it was advisory ("After Coverage Verification passes, generate..."), not a BLOCKING gate. The agent showed the completion summary and stopped, satisfied it had "finished."

**Why this is universal**: Agents treat the final step of a workflow as optional — especially when the preceding steps produce visible output (summaries, status tables). If the final artifact is a report that isn't immediately consumed by a subsequent step, the agent skips it. The agent's "satisfaction threshold" is met by the summary display, not by the file write.

**What works instead**: Make report generation a MANDATORY gate with explicit anti-pattern: "The pipeline is NOT complete until `report.md` is written to disk. Displaying a summary without writing the report file is a violation."

**Universal takeaway**: Any artifact that is the *final output* of a pipeline — not consumed by a subsequent step — will be skipped unless it has a BLOCKING gate. Advisory instructions ("generate the report") are consistently ignored at pipeline boundaries.

---

#### L48. Detected Domain Profile Not Persisted — Downstream Re-Detection Required

**What happened** (angdu-studio rebuild): reverse-spec Phase 1-3 detected the full Domain Profile (gui interface, async-state/ipc/llm-agents concerns, ai-assistant archetype, electron foundation). But Phase 4 only wrote `Artifact Language: ko` to sdd-state.md. When smart-sdd started, it had to re-detect the profile from scratch — or worse, asked the user to specify it again.

**Why this is universal**: Detection and persistence are separate actions. The agent performs detection (reads code, identifies patterns) and uses the results immediately. But it doesn't store the results for the next agent/session. Every multi-phase system where Phase N detects something and Phase N+M consumes it faces this: the detection results live in the agent's working memory, not in a persistent file.

**What works instead**: Add a "persist detection results" step at the boundary between detection and consumption. In our case: Phase 4-0 writes the full Domain Profile to sdd-state.md before generating any deliverables.

**Universal takeaway**: If one agent/phase detects something and another agent/phase needs it, the detection result MUST be written to a file. Agent memory is session-scoped; file state is permanent.

---

#### L49. Report Section Numbering Mismatch — Template ≠ Instructions

**What happened** (angdu-studio completion-report): The completion-report.md template has 10 sections (§1-§10). But the analyze-generate.md instruction listed only 7 sections (§1-§7) with different numbering (§5 mapped to "Quality Assessment" instead of template's "Architecture & Strategy"). The agent generated 7 sections and stopped, missing §8 (Challenges), §9 (Outcomes), §10 (Artifact Inventory).

**Why this is universal**: When a template and its invocation instructions use different numbering, the agent follows the instructions (closer in context), not the template (farther away, read once). The template is "reference"; the instructions are "execution". Instructions win.

**What works instead**: Instructions must use the exact same section numbering as the template. Add a post-generation completeness check: "verify all active sections are present in the output file."

**Universal takeaway**: Template files and their invocation instructions must be kept in strict sync. Any numbering divergence means the agent generates the wrong structure. Include a post-generation verification step that checks the output against the template.

---

#### L50. Agents Default to Happy Path — Error Scenarios Require Explicit Enforcement

**What happened** (all 4 tests): spec.md files consistently had 10-15 FRs with matching SCs — but all SCs tested only the success path. No validation errors, no network timeouts, no empty states, no permission errors. The agent treated "cover all FRs with SCs" as "one SC per FR, happy path" and reported the spec as complete.

**Why this is universal**: Agents optimize for coverage metrics. "12 FRs → 12 SCs → 100% coverage" looks complete. Error scenarios add SCs without adding FRs, making the ratio look "worse" (12 FRs → 17 SCs). The agent doesn't spontaneously think about what can go wrong — it thinks about what the Feature does right.

**What works instead**: Add an explicit Error Scenario Coverage Check that categorizes error types (input validation, network, empty state, auth, concurrency) and requires at least one SC per applicable category. Make it BLOCKING for production scale.

**Universal takeaway**: If you want error handling in specifications, you must explicitly require it. Agents will never spontaneously add error scenarios — they must be prompted with a checklist of error categories applicable to the Feature.

---

#### L51. Source Reference Paths Drift from Actual Filenames

**What happened** (openclaw adopt): Pre-context.md listed `src/config/config-validation.ts` as a source reference, but the actual file was `src/config/validation.ts`. Similarly, `src/config/config-migration.ts` → actual `src/config/legacy-migrate.ts`. The agent used descriptive names from its Phase 2 analysis notes rather than verifying the actual filesystem.

**Why this is universal**: During deep analysis, agents create internal labels for files based on their function ("the config validation file"). When writing references, they reconstruct filenames from these labels rather than re-checking the filesystem. The result: paths that are semantically correct but filesystem-incorrect.

**What works instead**: Add a Source Reference Path Verification step after pre-context generation. For each listed file, resolve the path and check existence. If not found, search for similarly named files and auto-correct.

**Universal takeaway**: Any agent-generated file path must be verified against the actual filesystem. Agents reconstruct paths from semantic understanding, not from `ls` output. Always verify, never trust agent-generated paths.

---

#### L52. Demo Scripts Default to Minimum Viable — Health Check ≠ Feature Demonstration

**What happened** (openclaw, vllm demos): Demo scripts contained only basic health checks — `curl /health`, `--help`, `--version`. No error scenarios tested. No streaming. No concurrent requests. No advanced features (LoRA, multi-model, plugin system). The agent treated "demo script exists and is executable" as sufficient.

**Why this is universal**: Demo generation is the last step before pipeline completion. The agent has already produced spec, plan, tasks, implementation, and verification — it's context-fatigued. The simplest possible demo (health check) satisfies the "create a demo" instruction while consuming minimal remaining context budget.

**What works instead**: Define a 3-tier demo scope requirement: T1 Core (health + CRUD, mandatory), T2 Error (invalid input + service failure, mandatory for production), T3 Advanced (streaming, concurrency, Feature-specific capabilities, recommended). Verify tier coverage after creation.

**Universal takeaway**: Last-step artifacts receive the least agent attention. The more fatigued the agent, the more minimal the output. Compensate with explicit tier requirements and post-creation verification. Never rely on the agent to spontaneously produce comprehensive demos.

---

### Theme K: Skill Authoring Patterns `[P2]` (2026-03-23)

> Patterns specific to writing and maintaining agent skills (SKILL.md, commands, domain modules). These apply to anyone building reusable agent instructions.

#### L57. Skill Files Are Contracts, Not Guides — Ambiguity Is Exploited, Not Resolved

**What happened**: Early skill files used natural language like "consider running tests after implementation" and "you should verify all phases." The agent consistently interpreted these as suggestions. "Consider" became "optional." "Should" became "when convenient." Tests were skipped when context was tight. Verification was simplified to build-only. The agent wasn't being defiant — it was being an optimizer, finding the shortest path to "done."

**Universal takeaway**: Write every skill file as if it's a legal contract, not a helpful guide. Every ambiguous phrase will be interpreted the easiest way — not the most thorough way. Replace "consider" with "BLOCKING." Replace "should" with "MUST." Replace "verify all phases" with "BLOCKING: Phase 0-4 completion records required in sdd-state.md before merge proceeds." The difference in compliance is measurable: guidelines (~70%), warnings (~85%), BLOCKING gates (~100%). If you're writing instructions for an AI agent and using soft language anywhere, rewrite it with hard constraints.

#### L58. Anti-Pattern Examples Are More Effective Than Positive Examples Alone

**What happened**: We documented correct behavior with positive examples: "After speckit-specify, read the artifact, show review, call AskUserQuestion." The agent followed this ~80% of the time. When we added WRONG+RIGHT pairs — explicitly showing the bad pattern first, then the correct pattern — compliance jumped to ~95%. Adding a BLOCKING gate on top reached ~100%.

**Why it works**: A single positive example gives the agent one reference point. A WRONG+RIGHT pair gives it a **boundary** — a region of behavior to avoid plus a region to target. Agents learn boundaries faster than targets because boundaries constrain the search space. The WRONG example is especially powerful because it matches patterns the agent might otherwise generate (show raw output, stop, declare "done"). Seeing those patterns explicitly labeled as WRONG creates an avoidance signal that pure positive examples don't.

**Universal takeaway**: For every critical behavior in your skill, define WRONG then RIGHT. The WRONG example should be the behavior you've actually observed the agent produce — not a hypothetical. Real anti-patterns are more effective because they match the agent's natural tendencies. Format: `❌ WRONG: [observed bad behavior] → [consequence]` then `✅ RIGHT: [desired behavior] → [outcome]`. This single technique saved more debugging time than any other in our development.

#### L60. Template Compliance Cannot Be Optional — Agents Always Choose Speed Over Structure

**What happened** (aegis greenfield case study): The pipeline's fallback clause said "if spec-kit CLI is unavailable, generate artifacts directly following the templates." The agent interpreted "following the templates" as "inspired by the templates" — it produced spec.md with 3 sections instead of 8, skipped research.md/data-model.md/contracts/ entirely, and put data models inline in plan.md. Build passed. Tests passed. Everything "worked." But downstream Features had no entity registry to reference, no API contracts to consume, and no structured data models to extend. The user saying "do everything quickly" amplified the behavior — the agent optimized for completion speed, not structural completeness.

**Why this is universal**: Agents treat structural requirements as elastic — "8 sections" becomes "the important sections" becomes "3 sections that cover the key points." This is the same optimization behavior that makes agents useful (summarizing, prioritizing) turned destructive (dropping required sections). The more time pressure, the more aggressive the simplification.

**What works instead**: Template compliance must be a BLOCKING gate, not a guideline. Before generating any artifact, read the template file. After generating, verify section count matches. If template has 8 sections and output has 3, that's a pipeline integrity violation — not a "simplified version." The anti-pattern must be explicitly named: `❌ WRONG: Write spec.md with FR/SC only because "it's faster"` → `✅ RIGHT: Read .specify/templates/spec.md, match every section`.

**Universal takeaway**: Any time you allow agents to "generate directly" as a fallback, you've created a speed shortcut that will become the default path. Fallbacks must be equally rigorous as the primary path — just with a different execution mechanism. "Generate directly following templates" must mean "read the template file, match every section, create every companion file" — not "write something that looks roughly like a spec."

---

#### L61. Verify Cannot Be Overridden by User Urgency — "Do Everything" Is Not Permission to Skip

**What happened** (aegis case study): The user instructed "do everything, auto-approve HARD STOPs." The agent interpreted this as license to skip verify entirely — going from implement directly to "Feature complete." Four phases of verification (build check, SC verification, cross-Feature integration, demo) were silently omitted. The merge gate should have blocked this, but the agent marked the Feature as complete without reaching the merge gate.

**Why this is universal**: "Pipeline Completion Bias" (L52) describes how agents shift from quality to speed after long sessions. User urgency ("just finish it") amplifies this bias to the point where quality gates are treated as obstacles rather than requirements. The agent rationalizes: "the user wants speed, verify takes time, therefore skip verify."

**What works instead**: Classify verify as CRITICAL — the highest HARD STOP classification that cannot be auto-approved regardless of `--auto` flag or user urgency. The merge gate must structurally require verify completion (check sdd-state.md verify status). If verify status is not `success` or `limited`, merge is BLOCKED — no override possible.

**Universal takeaway**: Some quality gates must be immune to user override. Identify which gates protect against "silent failure" (everything looks fine but isn't) and make those structurally un-skippable. User urgency is the #1 vector for quality gate bypass in agent systems.

---

#### L62. Feature-Level Parallelism Destroys Cross-Feature Integrity

**What happened** (aegis case study): The agent launched 3 background agents to implement F003, F004, F005 simultaneously. F004 depended on F003's Organization/Team/User entities. F005 depended on F002+F003's APIs. All 3 agents wrote to shared files (app.module.ts, entity-registry.md, api-registry.md) concurrently. Caught and stopped before merge, but the damage pattern was clear: entity definitions conflicted, API contracts were inconsistent, and sdd-state.md had incoherent status entries.

**Why this is universal**: The Agent tool makes parallelism trivially easy — "launch 3 agents in background." But cross-Feature dependencies mean Features are NOT independent work units. Feature B's specify needs Feature A's entity-registry output. Feature B's implement needs Feature A's API contracts. Parallelizing Features is like running database migrations in parallel — technically possible, semantically catastrophic.

**What works instead**: Features are ALWAYS sequential. The pipeline rule is absolute: F001 verify+merge → F002 start → F002 verify+merge → F003 start. The ONLY parallelism allowed is within-Feature task-level parallelism (multiple files within the same Feature, with disjoint ownership). Context Reset between Features further reinforces the sequential boundary.

**Universal takeaway**: In any agent workflow with shared state (registries, config files, state machines), work units that read/write shared state must be sequential. Parallelism is safe only when work units are truly independent — no shared files, no dependency ordering, no state coupling. The ease of launching parallel agents is inversely correlated with the safety of doing so.

---

#### L59. File-Based State Machines Beat Natural Language Conditionals for Multi-State Workflows

**What happened**: Early pipeline designs used natural language conditionals: "If the Feature is in progress, continue from the current step. If it's completed, skip it. If it's blocked, ask the user." The agent handled 2-3 states correctly but fell apart at 5+ states. It would resume a completed Feature, skip a blocked Feature without asking, or process a deferred Feature that should have been filtered out.

**Why it fails**: Natural language conditionals don't compose. Each new state adds interactions with every existing state. At 7 states (pending, in_progress, completed, adopted, blocked, deferred, restructured), there are 21 possible state transitions. Natural language can't encode 21 transitions clearly — the agent "merges" similar-sounding states and invents transitions that don't exist.

**Universal takeaway**: When your workflow has 4+ states, model them as a file-based state machine, not natural language conditionals. The file gives three advantages: (1) it survives context compression (the agent reads it fresh), (2) you can inspect and edit it manually, (3) valid transitions are explicit (if a transition isn't in the file, it's invalid). Our sdd-state.md encodes Feature status, current step, verify progress, and bootstrap status — all as structured data the agent reads, not as conversational context it tries to remember. The cost is a file read at each step. The benefit is deterministic state management in a probabilistic system.
---

#### L69. Spec Internal Consistency — US and SC Must Agree

**What happened**: aegis F004 spec.md had US2-AS4 describing a failure scenario with `status: failed`, while SC-007 described the same scenario with `status: released`. The entity definition only had `reserved/reconciled/released` — no `failed` state. The Post-Execution Verification sequence didn't catch this because it checked FR↔SC coverage but not US↔SC value consistency.

**Universal takeaway**: When a spec contains both narrative descriptions (User Stories) and testable criteria (SCs), they can independently reference the same concepts with different values. Post-Execution Verification must cross-reference: same scenario → same state values, error codes, and response formats. SC is authoritative (it's what gets tested), so US descriptions should align to SC, not the other way around.

---

#### L70. Feature Branch Isolation — Cross-Feature Changes Must Not Silently Bundle

**What happened**: During aegis F004 pipeline, the user requested Korean language conversion of F001-F003 artifacts. This was performed on the `004-token-budget` branch. Result: F004's branch contained both token budget code AND language changes for 3 other Features. If F004 were reset or discarded, the language changes would also be lost.

**Universal takeaway**: Feature branches should contain ONLY that Feature's changes. When mid-pipeline requests affect other Features, the agent must warn about bundling and offer branch separation. The safest approach: commit current Feature work, switch to main for cross-Feature changes, switch back. If the user accepts bundling, record it in sdd-state.md so the decision is traceable.

---

#### L71. Demo Is a Deliverable, Not an Afterthought

**What happened**: aegis F004 completed implement + verify with 13/20 SC runtime verified, but no demo script was created. tasks.md T008 explicitly listed "Demo script: demos/F004-token-budget.sh" but it was skipped during implement. verify didn't check for demo existence either.

**Universal takeaway**: Feature completion = code + tests + demo. The demo script is not documentation — it's a deliverable that packages the user experience. Three enforcement points: (1) Post-Implement Completeness Gate checks demo file exists. (2) verify Pre-Demo Check confirms --ci mode works. (3) User Demo Gate requires user to see the running Feature via the demo. If any of these is missing, the agent will skip demo creation because "the code works."
