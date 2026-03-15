# Lessons Learned — spec-kit-skills Pipeline

> Key failure patterns and their countermeasures.
> Read this file when starting verify or debugging quality issues.

---

## G1. Build Pass ≠ Feature Works

**Problem**: Build and tests pass, but runtime is broken
**Case**: F005 Zustand selector instability → infinite re-renders, scroll not working during streaming
**Countermeasures**: Per-task Runtime Check, Runtime Error Zero Gate, 3-Tier SC verification, Pattern Compliance Scan
**Coverage**: ~80% — drops to Level 1 (build-only) when MCP is unavailable

## G2. Foundation Absence

**Problem**: Same infrastructure bugs found repeatedly across Features
**Case**: CSS theme, IPC bridge, state management patterns — 7/7 bugs were Foundation-level
**Countermeasures**: Foundation Gate (one-time pre-verification), Foundation Test auto-generation, Toolchain Pre-flight
**Coverage**: ~90% — most robust

## G3. Source Information Gap

**Problem**: Agent cannot see original source during implement
**Case**: CSS value guessing, SBI metric errors ("3 tabs" vs actual 2 tabs), platform constraint omissions
**Countermeasures**: Source Reference Active Read, Style Token Extraction, SBI Accuracy Cross-Check, CSS Value Map
**Coverage**: ~85% — weakens when Phase 1.5 is skipped

## G4. Async/Temporal Pattern Omission

**Problem**: Only synchronous chains documented, async state transitions missing
**Case**: Loading → streaming → completion → error → cleanup full flow undefined
**Countermeasures**: UX Behavior Contract, Interaction Chains, VERIFY_STEPS temporal verbs
**Coverage**: ~70% — most recently added, insufficient real-world validation

## G5. Context Compaction Procedure Loss

**Problem**: Context compaction during verify → agent loses verify-phases.md reference → Phases skipped
**Case**: F006 Playwright CDP UI verification entirely skipped (F001~F005 all executed successfully)
**Countermeasures**: Verify Progress Checkpoint (sdd-state.md) + Resumption Protocol
**Key insight**: All 66 countermeasures are built on the premise "agent reads skill files." G5 is the meta-problem that breaks this premise.

## G6. Runtime Behavior Verification Gap

**Problem**: verify does static checks (test/build/lint) + UI rendering confirmation (CDP snapshot), but does NOT verify actual runtime behavior (feature interactions, data flow, state changes)
**Case**: F006 — SC verification covered 1/10 SCs (only SC-028 rendering). SCs requiring server connection, tool execution, enable/disable toggles were never runtime-tested. F001~F005 had the same pattern.
**Root causes**:
- verify-phases.md had no step for "run the app and test the feature works"
- SC-level verification (Phase 3 Step 3) only covered SCs in the demo Coverage header — if coverage was low, most SCs got no runtime check
- No defined boundary for what CDP can vs cannot automate (external deps, API keys, etc.)
**Countermeasures**: SC Verification Matrix (classify ALL SCs from spec.md), verification boundary rules (CDP capabilities), coverage gate (warn if < 50%)
**Coverage**: ~75% — external-dependency SCs still need manual verification

## G7. Cross-Feature Integration Contract Gap

**Problem**: Pipeline treats each Feature as isolated unit — no mechanism to define or verify data shape contracts at Feature boundaries
**Case**: F003 ParameterBuilder expects `assistant.mcpMode/mcpServers`, F006 useMCPStore stores differently — no bridge designed, implemented, or verified. 3-layer miss: spec/plan didn't define the contract, implement didn't build the bridge, verify didn't check shape compatibility.
**Root causes**:
- Functional Enablement Chain says "A enables B" but not "A provides {shape} and B expects {shape}"
- Entity/API registries track schemas independently per Feature, no cross-Feature shape comparison
- Enablement Interface Smoke Test checks existence (grep + curl), not data shape compatibility
**Countermeasures**: Integration Contracts (plan.md section defining Provider/Consumer shapes + bridges), Integration Contract Data Shape Verification (verify Phase 2 Step 6)
**Coverage**: ~80% — catches shape mismatches and missing bridges at plan+verify, but cannot catch all semantic compatibility issues

## G8. i18n Key Coverage Gap

**Problem**: Components use `t('key')` but keys are missing from locale JSON files → UI shows raw key strings instead of translations
**Case**: F006 — 7 i18n keys added to components but missing from `ko.json`. Build/tests pass because i18next silently falls back to key string. Only discovered during CDP UI verification.
**Countermeasures**: Per-task i18n completeness check (implement Step 1b), verify Phase 1 Step 4 i18n coverage lint (cross-check code→locale + locale→locale)
**Coverage**: ~95% — grep-based extraction covers standard `t()` patterns; dynamic key construction (`t(\`prefix.${var}\`)`) is not detectable

## G9. SDK API Contract Gap (Placeholder Implementation)

**Problem**: Code passes metadata-only objects to SDK functions that expect callable objects → build passes (loose types), runtime silently fails
**Case**: F006 MCP tool injection — `ParameterBuilder` returned `{ type: "mcp", serverId: "xxx" }` instead of `tool({ execute: async () => {...} })`. AI SDK ignored the objects, AI responded without tools.
**Also**: F005 MCP — `fullStream` tool-result `part.result === undefined` despite `.d.ts` declaring `output` field. 5 fix iterations due to trusting type definitions.
**Countermeasures**: SDK API contract gap detection in Pattern Compliance Scan, Loose type bypass warning, External SDK Type Trust Classification (High/Medium/Low trust levels)
**Coverage**: ~70% — grep-based detection catches common patterns; complex SDK contract mismatches require runtime verification

## G10. UI Interaction Over-exposure

**Problem**: Hover/click interactions applied to overly broad areas → UI flickers, re-renders, poor UX during scroll
**Case**: F006 — message-level `onMouseEnter/Leave` state caused Copy button to flash on every message during scroll. CSS `group-hover` with `transition-opacity` resolved with zero re-renders.
**Countermeasures**: UI Interaction Surface Audit checklist in implement B-3 (hover area scope, response timing, CSS vs React state, scroll interference)
**Coverage**: ~60% — checklist raises awareness but requires agent judgment; no automated detection

## G11. Verify Checks Code Existence, Not Runtime Behavior

**Problem**: verify passes when code structure is correct (grep finds the right patterns) but the Feature doesn't actually work at runtime
**Case**: F007 — embedding model not running → search returns empty results, but verify passed because code for embedding/search was structurally present. Header layout cramped when navigating between Features, but verify only checked individual pages in isolation.
**Root causes**:
- verify had no step for "start the app and exercise the Feature's actual behavior"
- Pre-flight only checked Playwright MCP — if unavailable, immediately recommended session restart even when Playwright CLI was available
- SC classification had no interface-specific categories (only `cdp-auto` for GUI)
- No cross-Feature navigation transition check
- No runtime data dependency verification
**Countermeasures**: Multi-backend detection protocol (MCP → CLI → demo-only → build-only), interface-aware SC categories (`api-auto`, `cli-auto`, `pipeline-auto`, `user-assisted`), Step 1c Data Dependency Verification, Step 3c Navigation Transition Sanity Check, Step 3d Interactive Runtime Verification, Step 3e Source App Comparative Verification, SC Minimum Depth Rule, Empty State ≠ PASS principle
**Coverage**: ~85% — `external-dep` SCs still require manual verification; `user-assisted` SCs depend on user cooperation

## G12. Ad-hoc Domain Philosophy in Constitution

**Problem**: Domain-specific philosophical principles (e.g., "Streaming-First" for AI apps, "Contract Stability" for public APIs) were generated ad-hoc in constitution-seed without structured guidance — quality and consistency varied by session
**Case**: angdu-studio constitution-seed produced "AI Desktop App Domain" principles (Streaming-First, Model Agnosticism, Offline Resilience, Token Awareness) correctly, but these emerged from the agent's general knowledge, not from a structured extraction module. Different sessions could produce different principles for the same archetype.
**Countermeasures**: Archetype modules (A0–A4) provide structured signal detection, philosophy extraction, SC generation extensions, elaboration probes, and constitution injection per application domain
**Coverage**: ~90% — structured extraction ensures consistent principles; novel domains without archetype modules still rely on agent ad-hoc generation

## G13. Framework Philosophy vs Operational Checklists

**Problem**: Foundation files (F0–F6) mixed operational configuration decisions with philosophical principles — "what to configure" and "why certain patterns are preferred" were conflated in the same checklist
**Case**: Express's "everything is middleware" and Electron's "main process must survive renderer crashes" are philosophical principles that guide all architectural decisions, not just individual configuration items. Mixing them with checklist items (e.g., "CORS policy: config") diluted their importance.
**Countermeasures**: Foundation F7 Philosophy section separates framework-endorsed principles from operational checklists. F7 defines _why_ patterns are preferred; F0–F6 define _what_ to configure.
**Coverage**: ~85% — F7 is optional per Foundation, so frameworks without F7 still lack explicit philosophy separation

## G14. Metrics-Only Reports Miss the "Why"

**Problem**: Case study reports focused on quantitative metrics (FR/SC/Task counts, coverage %, parity %) but failed to explain *why* architectural decisions were made — the philosophy behind the decisions was invisible
**Case**: angdu-studio case study would show "Provider abstraction layer" as a decision but not trace it to the "Model Agnosticism" archetype principle that motivated it. The report told *what* was built but not *why* it was designed that way.
**Countermeasures**: Philosophy-aware report generation — §4.2 Architecture Philosophy (principle tables with Constitution Status), §4.3 Principle-to-Decision Mapping (decision → principle correlation), §8 Philosophy Assessment (principle application coverage + gaps + module feedback). M6 milestone enhanced with Philosophy Adherence subsection for per-Feature principle tracking.
**Coverage**: ~75% — depends on M6 Philosophy Adherence data being recorded; implicit principle adherence (followed but not recorded) creates coverage gaps

## G15. Skill Tool Return Overrides Pipeline Instructions

**Problem**: Agent treats spec-kit Skill tool return value as "final response to show user" — bypasses all post-execution steps (output suppression, artifact read, Review display, HARD STOP)
**Case**: angdu-studio constitution — `speckit-constitution` returned, agent showed "Constitution finalized" + "Suggested commit" (raw output), then jumped directly to "F001-app-shell pipeline" without reading `.specify/memory/constitution.md`, displaying Review format, or calling AskUserQuestion. Both Pattern A (stop) and Pattern B (skip) observed in different runs.
**Root cause**: The default agent behavior for any tool call is: execute tool → show result to user → stop or continue. Pipeline instructions saying "suppress tool output and do X instead" are in pipeline.md (loaded on-demand), but by the time the Skill tool returns, the agent's working memory is dominated by the tool output. The pipeline suppression rules have already been pushed down in context priority.
**Countermeasures**: MANDATORY RULE 3 in SKILL.md (always-loaded, 5-step protocol: SUPPRESS → READ → DISPLAY → ASK → FALLBACK), inline reminders at each Execute+Review point in pipeline.md, CLAUDE.md Review Protocol #5 (pattern verification during file review)
**Coverage**: ~uncertain — this is a model-level behavioral tendency, not a rule enforcement gap. SKILL.md placement is the strongest possible mitigation, but the underlying behavior (tool output = user response) cannot be structurally prevented.
**Key insight**: Unlike G1-G14 where the fix is "add a verification gate," this problem has no verification gate solution — the failure happens *between* tool execution and the next instruction read. The only defense is placing suppression rules at the highest-priority context level (SKILL.md).

## G16. CWD vs Target Directory Path Ambiguity

**Problem**: Instructions using `{target-directory}` are ambiguous — "target" can mean "the source being analyzed" (reverse-spec target) or "the project being built" (build target). Agent picks whichever interpretation fits the immediate context.
**Case**: reverse-spec analyze.md Phase 0 Step 4 said "Write `case-study-log.md` to `{target-directory}`." Agent interpreted target-directory as the source code being analyzed (cherry-studio), not the CWD project being built (angdu-studio). File was written to the wrong location.
**Countermeasures**: Replaced all ambiguous path references with explicit `./case-study-log.md (CWD root)` + added ⚠️ Path warning block explaining CWD vs target distinction
**Coverage**: ~95% — explicit "CWD root" annotation eliminates ambiguity for known cases; new file creation instructions must be reviewed for the same pattern
**Key insight**: In reverse-spec, the agent operates across two directories (source = read-only, CWD = write target). Any path instruction that doesn't specify which directory is a bug waiting to happen.

---

## Countermeasure Lineage

```
Initial → V1~V4 (SC verification) → V7 (Foundation Gate) → S1~S4 (Source Reference)
  → S12~S15 (SBI Cross-Check, Stub Detection) → W1~W4 (Playwright Fallback, Pattern Scan)
  → W5~W6 (Chain Completeness, Enablement) → W8~W9 (API Matrix, Zero Gate)
  → W10 (UX Behavior Contract) → Toolchain Pre-flight → Verify Progress Checkpoint
  → SC Verification Matrix (runtime coverage) → Integration Contracts (cross-Feature shapes)
  → i18n Coverage Lint (translation completeness) → SDK API Contract Gap + Type Trust Classification
  → UI Interaction Surface Audit (hover/click UX)
  → Runtime Verification Architecture (multi-backend, interface-aware, data dependency)
  → BLOCKING Gates (output file verification > MANDATORY keyword)
  → Pre-context Completeness Verification (template checklist enforcement)
  → MANDATORY RULE 3 (Skill tool output suppression + Review gate — SKILL.md level)
  → Standalone section separation (instruction visibility > checklist piggyback)
  → Dependency Interpretation Rules (implementation ordering ≠ runtime coupling)
  → Explicit CWD path annotations (CWD vs target-directory disambiguation)
```

---

## Specific Lessons (Past Resolutions)

### L1. HARD STOP Bypass — 56-Point Audit Result
**Situation**: Agent auto-skipped HARD STOPs citing health check passes, non-blocking classification, etc.
**Resolution**: Inserted inline re-ask text at 30+ locations (countering tendency to ignore reference file rules)
**Lesson**: Agents fabricate "reasonable excuses" to bypass safety gates. Inline repetition is the only defense.

### L2. Feature ID Tier-First Reordering
**Situation**: RG-first ordering → Feature skip in T1-only pipeline (F003 → F004(T2) → F005 ordering issue)
**Resolution**: Switched to Tier-first global ordering (all T1 → all T2 → all T3)
**Lesson**: Feature ordering must be tested under "single Tier active" scenarios, not just "all Tiers active."

### L3. ESLint Command Not Found — Recurring
**Situation**: "eslint: command not found" repeated at every Feature's verify Phase 1
**Resolution**: Foundation Gate Toolchain Pre-flight (detect once → cache in sdd-state.md) + auto-install offer
**Lesson**: The assumption "tool is installed" must be verified early in the pipeline.

### L4. verify-phases.md and injection/verify.md Inconsistency
**Situation**: Added verification items to verify-phases.md → injection/verify.md Checkpoint/Review not updated
**Resolution**: Full file audit found 4 Critical + 2 Major inconsistencies, all fixed
**Lesson**: Verification logic and display logic must always be updated as a pair.

### L5. Zustand Selector Instability — Infinite Re-renders
**Situation**: F005 build passes but runtime has infinite re-renders (new array/object references created every render)
**Resolution**: Added "Selector reference instability" pattern to Pattern Compliance Scan
**Lesson**: React state library selector patterns cannot be caught by build/test alone.

### L6. Demo-Ready Anti-Pattern — Test Files Mistaken for Demos
**Situation**: Agent generated test suites as "demos." Executable but doesn't demonstrate the actual Feature
**Resolution**: Added "MUST launch real Feature, NOT test-only" rule to Demo Standard + Phase 3 verification
**Lesson**: "Executable" and "demonstrable" are different. The purpose of a demo is to showcase functionality.

### L7. Source Reference Path Resolution
**Situation**: pre-context.md recorded absolute paths to original files → unresolvable on other machines
**Resolution**: Store Source Path in sdd-state.md, pre-context uses relative paths only
**Lesson**: Paths must always be designed as relative path + runtime resolution.

### L8. Cross-File Consistency — 9-Issue Audit
**Situation**: After adding W1~W10, downstream files (injection/tasks, implement, verify) were not updated
**Resolution**: Full pipeline ↔ verify ↔ injection flow audit, 9 issues fixed
**Lesson**: When adding new mechanisms, always trace "which downstream files read this value."

### L9. Feature-Specific References → Universal Patterns
**Situation**: Bug prevention rules and lessons referenced specific Feature cases (e.g., "F005 Zustand selector instability", "F006 AI SDK v6 tool() requires execute callback", "F006 hover flicker on message scroll"). These are useful for case-study context but make rules appear narrowly applicable.
**Resolution**: Generalized to universal patterns: "State selector instability: creating new object/array references per render", "SDK function expects callable/executable object but receives metadata-only object", "Hover/click interaction applied to overly broad container causes re-renders during scroll". Specific case histories preserved in history.md.
**Lesson**: Bug prevention rules should describe the *pattern*, not the *instance*. Specific cases belong in decision history, not in operational rules that the agent evaluates on every run.

### L10. MANDATORY ≠ Enforced — BLOCKING Gates Required
**Situation**: Runtime Default Verification was marked MANDATORY with "You MUST NOT skip it." Agent skipped it anyway — twice (before and after the fix). The MANDATORY keyword was treated as "important but situational."
**Resolution**: Added a BLOCKING gate at Phase 2 entry that verifies the output file contains the expected section (`## Runtime Default Verification` in `runtime-exploration.md`). Missing section → re-execute the step. Same pattern as SBI Numbering Verification (which worked on first attempt).
**Lesson**: "MANDATORY" is a request. "BLOCKING gate that checks the output file" is enforcement. Agents comply with verifiable constraints (file section exists? Y/N), not with behavioral directives ("you must do X"). Design enforcement as downstream output verification, not upstream instruction emphasis.

### L11. Bullet List Content Requirements → Post-Generation Completeness Check
**Situation**: analyze.md Phase 4-2 listed 14 required sections for each pre-context.md in a bullet list. Agent generated pre-contexts with only 6 of 14 sections — selectively ignoring sections it deemed "not needed" (Runtime Exploration, UI Component Features, Interaction Behavior, Static Resources, Environment Variables, Feature Contracts, etc.).
**Resolution**: Added Pre-context Completeness Verification — a 14-row checklist table (MANDATORY + BLOCKING) that runs after all pre-contexts are generated. Each section must exist or have an explicit empty value ("None", "Skipped — [reason]", "N/A — backend-only").
**Lesson**: Content requirements in prose/bullet lists are suggestions to agents. Enforceable requirements need a structured checklist with a verification step. The pattern: define expected sections in a table → generate → verify table against output → block if incomplete.

### L12. "Update" ≠ "Write to File" — Ambiguous Verbs
**Situation**: SBI Numbering Verification Step 5 said "Update Demo Group SBI ranges." Agent calculated the ranges, displayed them in the verification output, but did NOT write them to roadmap.md. The verb "Update" was interpreted as "calculate and show."
**Resolution**: Changed to explicit language: "**Write these ranges into roadmap.md** by adding a `| **SBI Coverage** | B###–B### |` row. This is a file modification, not just a display."
**Lesson**: When you need the agent to modify a file, say "Write X into [filename]" or "Add X to [filename]." Never use ambiguous verbs like "Update," "Reflect," or "Record" without specifying the target file and the exact content format.

### L13. Fix Verification Requires Re-execution, Not Just Code Review
**Situation**: Applied Fix 1-4 to analyze.md rules. Assumed the fixes were sufficient based on code review. After re-running reverse-spec, found Fix 1-3 worked perfectly but Fix 4 failed completely — the MANDATORY keyword was simply ignored.
**Resolution**: Established a feedback loop: apply fix → re-run the pipeline → analyze output → identify remaining failures → apply stronger fix. Needed two rounds to get Runtime Default Verification right (1st: MANDATORY keyword, 2nd: BLOCKING gate).
**Lesson**: Rule changes cannot be validated by reading the rule. They can only be validated by observing agent behavior under the rule. Every fix must be followed by a re-execution to verify the fix actually changed agent behavior.

### L14. Skill Tool Return Treated as User Response
**Situation**: `speckit-constitution` completed. Agent showed raw output ("Constitution finalized", "Suggested commit") and jumped to F001 pipeline — skipping artifact read, Review display, and HARD STOP AskUserQuestion. In a separate run, agent showed raw `speckit-specify` output ("Ready for /speckit.clarify or /speckit.plan") and stopped without Review or "continue" fallback.
**Resolution**: Added MANDATORY RULE 3 to SKILL.md (always-loaded context). Defined 5-step post-execution protocol (SUPPRESS → READ → DISPLAY → ASK → FALLBACK). Documented Pattern A (Stop) and Pattern B (Skip) as distinct violations.
**Lesson**: Pipeline instructions in on-demand files (pipeline.md) lose priority against the agent's default tool-use behavior. Critical behavioral rules must live in SKILL.md — the only file guaranteed to be in context when the violation occurs. This is the same principle as L1 (inline repetition), elevated to file-level: put the rule where it will be read at the moment it matters.

### L15. Instruction Buried in Unrelated Checklist
**Situation**: Demo Group SBI range calculation was step 5 of a 5-step "SBI Numbering Verification" checklist. Agent completed steps 1-4 (numbering checks) and stopped, treating step 5 (Demo Group SBI calculation) as optional or irrelevant since it wasn't about "numbering verification."
**Resolution**: Separated Demo Group SBI into its own `#### Demo Group SBI Coverage Ranges (MANDATORY — BLOCKING)` section with dedicated heading, algorithm, display format, and anti-TBD warning.
**Lesson**: Agents interpret checklist items through the lens of the checklist title. An item that doesn't match the title's semantic scope will be skipped even if it's marked MANDATORY. Fix: give distinct tasks their own section headings, don't piggyback on existing checklists.

### L16. Runtime Coupling ≠ Implementation Dependency (SKF-018)
**Situation**: reverse-spec placed F008 (Data & Storage) before F001 (Electron Shell) in the dependency graph because "Shell imports DB at startup → Shell depends on DB." This caused smart-sdd to select F008 as the first Feature instead of F001.
**Resolution**: Added 3 Dependency Interpretation Rules to analyze.md Phase 3-2: (1) Bootstrap Feature always RG-1 first, (2) Foundation sanity check with AskUserQuestion, (3) "Could I write A without B's code?" test. Added post-sort validation.
**Lesson**: "A's code imports B at runtime" ≠ "A cannot be implemented without B." Feature dependency is about implementation ordering ("I need B's code to exist before I can write A"), not runtime initialization sequence. The test: "If B's code didn't exist at all, could I still write A from scratch?" If yes, A does not depend on B.
