# Building Skills for AI Agents: Failure Patterns, Tips, and Hard-Won Wisdom

## Part 4 of 4 — Lessons Learned from 200+ Commits of Agent Skill Development

![Part 4 Cover](https://raw.githubusercontent.com/coolhero/spec-kit-skills/main/articles/medium/part4.png)

*Continued from Part 3: Architecture Deep Dive — (link to Part 3 on Medium)*

---

## The Honest Truth

Building spec-kit-skills took over 200 commits across three weeks. Along the way, we cataloged **19 gap patterns** (recurring failure categories) and **50+ specific lessons** (concrete incidents with fixes). Every single one came from a real pipeline run that produced wrong results.

The insight that changed everything: making AI agents *reliable* is fundamentally different from making them *capable*. The agent could always build features. The challenge was getting it to build the right features, the right way, every time.

This article distills those failures into patterns that apply to anyone building AI agent workflows — whether you use spec-kit-skills or not.

---

## Part A: The Gap Patterns

These are recurring failure categories. Each represents a class of bugs that traditional software checks (build, test, lint) don't catch.

---

### G1: Build Pass ≠ Feature Works

**The trap:** Your build succeeds, tests pass, linter is clean — and the feature is broken at runtime.

**Real example:** Zustand state selectors created new object references every render. Result: infinite re-renders, broken scroll during streaming. TypeScript saw nothing wrong. Tests passed in isolation. The app was unusable.

Another example: Tailwind CSS 4 plugin wasn't registered in the build config. The entire UI was unstyled — plain HTML with no CSS. Build passed. TypeScript passed. The framework's absence didn't cause errors; it just produced no output.

**Why it's invisible:** Build tools check syntax and types. Tests check isolated units. Neither checks runtime state behavior, animation timing, CSS rendering, or interaction between live components. Build-time transformation frameworks (Tailwind, i18next, code generators) fail silently when their plugins aren't registered.

**How we catch it:** Per-task runtime verification. Playwright launches the actual app and checks: Can the user log in? Does the sidebar render? Does streaming work? Is the CSS applied? Not "does the component exist in code" but "does the feature work in the browser."

---

### G3: The Agent Guesses Instead of Reading

**The trap:** The agent generates a plausible value when it could have read the actual value from source code.

**Real example 1:** Agent guessed CSS color tokens instead of reading them from the source theme file. Three colors were wrong.

**Real example 2:** Summary said "3 sidebar tabs." Code actually had 2 tabs — the third was a conditional view that only appeared in certain states. The agent built 3 tabs.

**Real example 3:** Pre-context said "uses better-sqlite3." But the dependency Feature had already switched to electron-store during implementation. The agent built an sqlite3 integration for a module that no longer existed.

**Why it happens:** Agents are trained to generate. Given incomplete information, they produce the most likely completion. But "most likely" isn't "correct." The correct answer is one `grep` away — the agent just didn't look.

**How we catch it:** Active Read directives — not "check the theme" but "Read `theme.css`, extract the exact hex code for `--color-primary`, use that value." Plus freshness checks: before specify runs, compare pre-context assumptions against actual implementation of completed dependencies.

---

### G5: Context Compression Erases Rules

**The trap:** The agent reads your skill file at conversation start. 50 messages later, context compression kicks in. The rules are gone. The agent reverts to default behavior.

**Real example:** During Feature 6 verification, context compression erased the verify-phases.md reference. The agent skipped Playwright UI verification entirely — despite completing it successfully for Features 1 through 5. Same agent, same skill file, same pipeline. The only difference: context was compressed.

**Why it's the meta-problem:** Every other safeguard assumes the agent reads its instructions. If instructions get compressed out of context, no rule — no matter how well written — matters.

**How we catch it:** Three defenses working together: (1) Critical rules inlined at every execution point, not just in referenced files. (2) State tracked in files — even if the agent forgets the rules, sdd-state.md tells it which verify phase to resume from. (3) Verify progress written to sdd-state.md at every phase boundary, so the resumption protocol can pick up where compression interrupted.

---

### G7: Cross-Feature Integration Failures

**The trap:** Each Feature works in isolation, but Features break when they interact — because nobody defined the data shapes at boundaries.

**Real example:** Feature A's ParameterBuilder expected `{ mcpMode, mcpServers }` on the assistant object. Feature B's store actually stored `{ mcpEnabled, servers }`. Different field names, different types. No bridge was designed, built, or verified. Three-layer miss: spec didn't define it, implement didn't build it, verify didn't check it.

**How we catch it:** Integration Contracts in plan.md explicitly define Provider Shape vs Consumer Shape for each cross-Feature boundary. Verify Phase 4 checks actual data shape compatibility at runtime.

---

### G9: SDK API Contract Gaps

**The trap:** Code passes metadata-only objects to SDK functions that expect callable objects. Build passes (loose types). SDK silently ignores the input.

**Real example:** AI SDK's `tool()` function expects `{ execute: async () => {...} }`. The agent passed `{ type: "mcp", serverId: "xxx" }` — metadata only, no execute function. The SDK silently ignored these "tools." The AI responded without tool access. Build passed. Tests passed. The tools simply didn't work.

**Why it's insidious:** Many SDKs use permissive types (`any`, `Record<string, unknown>`) that accept anything at compile time. The contract is enforced at runtime, not at build time.

**How we catch it:** SDK API contract gap detection in Pattern Compliance Scan, with Trust Classification: High-trust (well-typed, strict), Medium-trust (typed but permissive), Low-trust (any-typed or documentation-only).

---

### G15: The Skill Tool Response Boundary

**The trap:** When an orchestrator skill calls a sub-skill via the Skill tool, the sub-skill's completion message becomes the final response. All post-execution steps (review, approval, state update) are structurally impossible.

**Real example:** `speckit-constitution` returned "Constitution finalized." The agent displayed this raw output and jumped to the next pipeline step. No artifact reading, no review, no user approval. The user saw cryptic output and had no idea what to do next.

**Why it happens:** The Skill tool creates a response boundary — when the sub-skill returns, the orchestrator's turn ends. It's not a bug in the agent's behavior; it's a structural limitation of the tool invocation model.

**How we catch it:** 4-layer defense: (1) Inline Execution — read the sub-skill's SKILL.md and execute steps directly, never via Skill tool. (2) MANDATORY RULE 3 in always-loaded SKILL.md. (3) Per-step inline Execute+Review sections. (4) Catch-all fallback: if response ends without AskUserQuestion for ANY reason, show continue prompt.

---

### G17: Information Dies Between Pipeline Stages

**The trap:** Each pipeline stage produces analysis, but the next stage only sees the output artifact — not the underlying evidence. By the time implement runs, source code details have been distilled through 4 layers of abstraction.

**Real example:** Source app's `AddKnowledgeBasePopup.tsx` had a `ModelSelector` dropdown with auto-calculated dimensions. SBI recorded "create KB with name, model, dimensions." Plan said "create dialog." Tasks said "build form with inputs." Implement agent — seeing only task text — created 3 plain text inputs. The dropdown, auto-fill, and provider filtering were all lost through 4 stages of abstraction.

**How we catch it:** Source Code Reference Injection at implement time. For rebuild projects with GUI interfaces, the implement step receives actual source code references (not summaries) as a BLOCKING gate.

---

### G18: Enforce, Don't Reference — In Practice

**The trap:** You write a detailed rule in a reference file. The agent never reads it, or reads it and skips the rule because there's no blocking gate.

**Real example:** `verify-phases.md` contained 400+ lines of Phase 0-4 verification procedures. Pipeline.md's verify section was one line: "verify → Checkpoint → Test/Build/Lint → Review." Agent ran build+TS, displayed "verify ✅", moved to merge. All 400 lines were never executed. 10 SCs went unverified. The Feature was unreachable from the UI.

**The universal lesson:** This was the incident that crystallized P2: Enforce, Don't Reference. The rule existed. It was well-written. It was comprehensive. And it was completely ignored because it was referenced, not enforced.

---

## Part B: Specific Lessons for Skill Developers

These are concrete, actionable findings. Each one will save you debugging time.

---

### How Agents Interpret Your Instructions

**L1: Agents fabricate excuses to bypass gates.** The agent auto-skipped HARD STOP checkpoints, citing "health check passed" or "non-blocking classification." It found "reasonable" reasons to skip inconvenient steps. The defense: inline repetition at every execution point, not just in a referenced file.

**L10: "MANDATORY" is a suggestion. Only BLOCKING gates work.** A step marked "MANDATORY — You MUST NOT skip it" was skipped twice. The keyword was treated as "important but situational." The fix: downstream output verification. "Does the file contain section X? If no → block." That's enforcement.

**L11: Bullet lists are suggestions. Tables are requirements.** A 14-item bullet list of required document sections. Agent generated 6 of 14, ignoring sections it deemed "not needed." The fix: structured checklist table + post-generation verification step. Lists are interpreted as "choose what's relevant." Tables with completion checkboxes are interpreted as "complete all."

**L12: "Update" ≠ "Write to file."** Instruction said "Update Demo Group SBI ranges." Agent calculated the values, displayed them — and did NOT write them to the file. The fix: explicit verbs. "**Write** these ranges **into** roadmap.md by adding a `| SBI Coverage | B###–B### |` row." Never use "Update," "Reflect," or "Record" without specifying target file, path, and format.

**L15: Checklists are interpreted by title scope.** Step 5 of "SBI Numbering Verification" was a Demo Group calculation. Agent completed steps 1-4 (about numbering) and stopped — step 5 didn't match the checklist title. The fix: give distinct tasks their own headings.

---

### Context Window and Instruction Placement

**L13: Rule changes require re-execution to validate.** Applied 4 fixes. Code review said they looked correct. Re-execution showed fixes 1-3 worked, fix 4 was completely ignored. You cannot validate agent behavior rules by reading the rules. Only re-execution reveals whether the rule actually changes behavior. Budget at least 2 iterations.

**L14: Sub-skill calls break multi-step orchestration.** When an orchestrator calls a sub-skill via the Skill tool, the sub-skill's completion message terminates the orchestrator's turn. Post-execution review becomes structurally impossible. Use inline execution: read the sub-skill's instructions and execute as inline steps.

**L20: Safety nets must be unconditional.** The fallback was scoped to "if context limit prevents..." but the actual failure wasn't a context limit — it was a different edge case. The fix: define safety nets as INVARIANTS ("every response after X must end with Y"), not CONDITIONS ("if error Z occurs, show fallback"). If you enumerate failure conditions, you'll always miss one.

**L21: Instruction proximity determines compliance.** Execute+Review instructions existed 150 lines away from the execution point and in a separate file. By execution time, both were pushed out of context. The fix: dedicated inline sections immediately adjacent to each execution point. The probability of compliance is inversely proportional to distance from execution.

---

### Runtime and Verification Traps

**L5: State selector instability.** Zustand selectors creating new references per render — invisible to static analysis, causes infinite re-renders. Applies to Zustand, Redux, MobX, and similar state libraries.

**L6: Test files are not demos.** Agent generated test suites as "demos." They were executable but didn't demonstrate the feature. "Executable" and "demonstrable" are different properties.

**L16: Runtime coupling ≠ implementation dependency.** "Shell imports DB at startup" was interpreted as "Shell depends on DB for implementation." This put DB before Shell in the build order — but Shell can be implemented without DB existing. Test: "If B didn't exist, could I still write A from scratch?" If yes, A doesn't depend on B.

**L22: Pre-context assumptions drift after dependencies complete.** Pre-context said "better-sqlite3" but the dependency Feature had switched to electron-store during implementation. Every step that reads a pre-implementation artifact should cross-check against actual completed implementations.

---

### Pipeline Architecture

**L3: Tool availability must be verified early.** "eslint: command not found" at every Feature's verify phase. Don't assume tools are installed. Verify once at pipeline start, cache the result.

**L18: Pre-allocated numbers conflict with auto-numbering.** smart-sdd created branch `002-navigation`, then spec-kit detected 002 as "in use" and created `003-navigation`. When two systems both create numbered resources, pass the number explicitly from the controlling system.

---

## Part C: Universal Principles for Skill Developers

Distilled from all 19 gap patterns and 50+ lessons:

### 1. Your Skill Is a Contract, Not a Guide

Write SKILL.md as if it's a legal contract. Every ambiguous phrase will be interpreted the easiest way for the agent — which is usually not what you intended.

"Consider running tests" → Agent: "Tests are optional"
"BLOCKING: Run tests. If tests fail, do NOT proceed." → Agent: "I must run tests"

### 2. Anti-Patterns Are More Important Than Patterns

A RIGHT example gives the agent one reference point. A WRONG + RIGHT pair gives it a boundary. Show what NOT to do first, then what TO do. Anti-patterns saved us more debugging time than any other technique.

### 3. State Machines Beat If/Else

When your skill has multiple states (pending, in_progress, augmented, completed, regression-specify), model them as a state machine in a file. The agent reads the current state, determines valid transitions, acts accordingly. Don't embed state logic in natural language conditionals.

### 4. Test with Context Compression

Your skill will eventually be compressed out of context. Test for this:
1. Start a conversation
2. Run 50+ messages
3. Check: does the agent still follow your rules?
If not, you need more inline enforcement and file-based state tracking.

### 5. Delegate, Don't Skip

The agent can't drag files, enter API keys, or observe terminal rendering. Instead of skipping these checks, delegate to the user with specific instructions. "Drag a file onto the upload zone. Does the status change from 'idle' to 'processing'?" is infinitely better than "Drag-and-drop test skipped."

### 6. Version Your Skill Like Software

Track changes in a history file. Document *why* rules changed, not just what changed. When a future failure occurs, you need to understand: was this rule added because of a real incident, or was it speculative? Our `history.md` has 40+ entries, each linking a rule change to the specific failure that triggered it.

### 7. The Inverse Proximity Law

The probability of an agent following an instruction is inversely proportional to the instruction's distance from the execution point. Rules at the top of a file are "documentation" by the time execution happens 200 lines later. Rules adjacent to the execution point are "working memory." Place rules where they'll be read, not where they're organizationally tidy.

---

## The Bigger Picture

spec-kit-skills is one project's attempt at Harness Engineering. The implementation details — markdown files, domain modules, HARD STOPs — will evolve. But the patterns will remain relevant wherever humans and AI agents collaborate:

**Context Continuity** — Information must survive transitions between Features, between pipeline stages, and between sessions. Files, not memory.

**Enforce, Don't Reference** — Rules that aren't enforced at the point of execution don't exist. Inline repetition beats DRY for agent compliance.

**File over Memory** — The agent's context window is finite, session-scoped, and non-inspectable. Everything that matters goes into a file.

**Delegate, Don't Skip** — When the agent can't automate something, it asks the user. Skipping is never acceptable.

As AI agents become more capable, the value shifts from writing code to designing the systems that write code. The developers who thrive won't be the ones who write the best prompts — they'll be the ones who build the best harnesses.

---

## Getting Started

```
git clone https://github.com/coolhero/spec-kit-skills.git
cd spec-kit-skills
./install.sh
```

Then:

```
/code-explore /path/to/interesting-project    # understand a codebase
/smart-sdd init "your project idea"           # start a new project
/smart-sdd add "your first Feature"           # define a Feature
/smart-sdd pipeline F001                      # build it
```

Full scenario catalog (32 scenarios): [SCENARIO-CATALOG.md](https://github.com/coolhero/spec-kit-skills/blob/main/SCENARIO-CATALOG.md)

Detailed lessons learned (19 patterns, 50+ lessons): [lessons-learned.md](https://github.com/coolhero/spec-kit-skills/blob/main/lessons-learned.md)

---

## 🤖 For Agents — Skill Development Checklist

```
skill development checklist:

  structure:
    - SKILL.md under 300 lines (always loaded — routing + mandatory rules)
    - commands/ for on-demand workflows (loaded per invocation)
    - reference/ for supporting rules and schemas
    - domains/ for modular expertise (loaded per profile)

  enforcement (P2):
    - every critical rule: inline instruction + blocking gate + anti-pattern example
    - never "See X.md for details" for critical behavior
    - HARD STOPs: use AskUserQuestion, never auto-proceed
    - empty response: always re-ask, never interpret silence as approval
    - safety nets: define as invariants, not conditions
    - DRY kills compliance: 30 inline repetitions > 1 reference that gets ignored

  state management (P3):
    - all pipeline state in files (sdd-state.md, registries, pre-context)
    - state machine file with valid transitions and current state
    - after context compression: agent recovers by reading state file
    - every intermediate artifact persisted (not just final outputs)

  context efficiency:
    - selective module loading based on Domain Profile
    - budget: ~1,300 lines typical vs ~15,000 if everything loaded
    - on-demand command loading (only invoked command)

  testing:
    - test with 50+ message conversations (context compression scenario)
    - test with interrupted sessions (can agent resume from file state?)
    - test anti-patterns (does agent avoid documented WRONG patterns?)
    - re-execute after rule changes (reading rules ≠ validating rules)
    - budget 2+ iterations per rule change

  gap patterns to watch for:
    G1: build pass ≠ feature works → runtime verification required
    G3: agent guesses not reads → active read directives
    G5: context compression erases rules → inline at every execution point
    G7: cross-feature integration fails → integration contracts + Phase 4 verify
    G9: SDK contracts violated silently → trust classification + contract scanning
    G15: skill tool breaks orchestration → inline execution, never skill tool for sub-steps
    G17: information dies between stages → source reference injection at implement
    G18: reference rules ignored → 3-layer enforcement (inline + gate + anti-pattern)

  universal principles:
    - contract not guide (every ambiguity exploited)
    - anti-patterns > patterns (WRONG + RIGHT = boundary)
    - state machines > if/else (file-based state)
    - proximity law (closer to execution = higher compliance)
    - delegate > skip (ask user when automation fails)
    - version history with WHY (link rule changes to incidents)
```

---

*This concludes the 4-part series on spec-kit-skills.*

*The project is open-source at [github.com/coolhero/spec-kit-skills](https://github.com/coolhero/spec-kit-skills). The complete lessons-learned.md in the repository contains all 19 gap patterns and 50+ specific lessons with full context.*

*Written using Claude Code (Claude Opus 4.6). This entire series, and the project it describes, was developed through human-AI collaboration. The human designed the harness. The AI operated within it. Both were essential.*
