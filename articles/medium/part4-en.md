# Building Skills for AI Agents: Failure Patterns, Tips, and Hard-Won Wisdom

## Part 4 of 4 — Lessons Learned from 200+ Commits of Agent Skill Development

![Part 4 Cover](https://raw.githubusercontent.com/coolhero/spec-kit-skills/main/articles/medium/part4.png)

*Continued from Part 3: Architecture Deep Dive — (link to Part 3 on Medium)*

---

## The Honest Truth

Building spec-kit-skills took over 200 commits across three weeks. We cataloged 19 recurring failure patterns and 50+ specific incidents. Every single one came from a real pipeline run that produced wrong results.

The insight that changed everything: making AI agents *reliable* is fundamentally different from making them *capable*. The agent could always build features. The challenge was getting it to build the right features, the right way, every time.

This article distills those failures into **universal patterns** that apply to anyone building AI agent workflows — whether you use spec-kit-skills, build your own Claude Code skills, or work with any other agentic coding tool.

---

## Part A: Failure Patterns Every Skill Developer Should Know

---

### "Build Passes" Is Not "Feature Works"

**The trap:** Your build succeeds, tests pass, linter is clean — and the feature is broken at runtime.

**Real example:** A state management selector created new object references every render. Result: infinite re-renders, broken scroll during streaming. TypeScript saw nothing wrong. Tests passed in isolation. The app was unusable.

Another: A CSS framework plugin wasn't registered in the build config. The UI was completely unstyled — plain HTML. Build passed. The framework's absence didn't cause errors; it just produced no output.

**The universal lesson:** Build tools check syntax. Tests check isolated units. Neither checks runtime behavior — animation timing, state interaction, CSS rendering, scroll position during streaming. **If your skill has a verify step, it must include runtime verification, not just build+test.** When runtime verification isn't possible (no Playwright, no browser), delegate to the user — never skip.

---

### Agents Guess Instead of Reading

**The trap:** The agent generates a plausible value when it could have read the actual value from the codebase.

**Real example:** The agent guessed CSS color tokens instead of reading them from the source theme file. It assumed "3 sidebar tabs" from a summary when the code actually had 2 (the third was conditional).

**The universal lesson:** Agents are trained to generate. Given incomplete information, they produce the most likely completion — but "most likely" isn't "correct." **Your skill instructions must force source reading with explicit verbs**: not "check the config" but "Read `config.yaml`, extract the exact value for `max_connections`, use that value." Vague instructions get vague (generated) results.

---

### Context Compression Erases Your Rules

**The trap:** The agent reads your skill file at conversation start. 50 messages later, context compression kicks in. The rules are gone. The agent reverts to default behavior.

**Real example:** After 5 Features were correctly verified with full Playwright UI checks, Feature 6's verification skipped Playwright entirely. Context compression had eaten the verification instructions. Same agent, same skill, same pipeline — just a longer conversation.

**The universal lesson:** This is the meta-problem of skill development. Every other safeguard assumes the agent reads your instructions. **If instructions get compressed out of context, nothing works.** Three defenses: (1) Inline critical rules at every execution point, not just in a header. (2) Track state in files so the agent can recover. (3) Write progress markers — even if the agent forgets the rules, the state file tells it where to resume.

---

### Cross-Feature Integration Fails Silently

**The trap:** Each Feature works in isolation, but they break when they interact — because nobody defined the data shapes at boundaries.

**Real example:** Feature A expected `{ mcpMode, mcpServers }` on an object. Feature B stored `{ mcpEnabled, servers }`. Different names, different structure. Spec didn't define the contract, implementation didn't build a bridge, verification didn't check compatibility.

**The universal lesson:** If your pipeline builds multiple Features, **define integration contracts explicitly** — what does Feature A provide, what does Feature B consume, and what's the exact data shape at the boundary. Then verify the contract at runtime, not just in the spec.

---

### SDK APIs Accept Anything, Execute Nothing

**The trap:** Code passes metadata-only objects to SDK functions that expect callable objects. Build passes (loose types). The SDK silently ignores the input.

**Real example:** An AI SDK's `tool()` function expects `{ execute: async () => {...} }`. The agent passed `{ type: "mcp", serverId: "xxx" }` — metadata only, no execute function. The SDK silently accepted it. The AI responded without tool access. Everything "worked" — except the tools.

**The universal lesson:** Many SDKs use permissive types that accept anything at compile time. **Classify SDKs by trust level**: high-trust (strict types, fails loudly), medium-trust (typed but permissive), low-trust (accepts anything, documentation-only contracts). For medium and low trust SDKs, add explicit runtime contract checks in your verification step.

---

### Sub-Skill Calls Break Orchestration

**The trap:** When your orchestrator skill calls a sub-skill via the Skill tool, the sub-skill's completion message becomes the final response. All your post-execution steps (review, approval, state update) become structurally impossible.

**Real example:** An orchestrator called a spec generation sub-skill. The sub-skill returned "Spec finalized." That became the entire response. No artifact review, no user approval, no state update. The user saw a cryptic message and had no idea what to do next.

**The universal lesson:** The Skill tool creates a response boundary. **If your orchestrator needs to do anything after a sub-skill completes, don't use the Skill tool.** Instead, read the sub-skill's instructions and execute them inline. This preserves your turn and allows post-processing.

---

### Information Dies Between Pipeline Stages

**The trap:** Each stage produces analysis, but the next stage only sees the output artifact — not the underlying evidence. Details get lost through layers of abstraction.

**Real example:** Source code had a dropdown component with auto-calculated dimensions. Stage 1 recorded "create form with model selection." Stage 2 said "create dialog." Stage 3 said "build form with inputs." The final implementation created 3 plain text inputs — the dropdown, auto-fill, and dynamic sizing were all lost through 4 stages of summarization.

**The universal lesson:** If your pipeline has multiple stages, **be intentional about what context each stage receives.** Summaries are efficient but lossy. For critical details (UI interactions, data formats, error handling), inject the original source alongside the summary. Don't assume the summary preserved everything.

---

### "See X for Details" Gets Ignored

**The trap:** You write a detailed rule in a reference file. You reference it from the main skill. The agent treats the reference as optional reading.

**Real example:** A verification file contained 400+ lines of detailed procedures. The main pipeline file said: "verify → run tests → review." The agent ran tests, displayed "verify complete," and moved on. All 400 lines were never read. 10 success criteria went unverified. The feature was unreachable from the UI.

**The universal lesson:** This is probably the single most important lesson. **Referenced rules don't exist for agents.** Every critical rule needs three layers: (1) Inline instruction at the execution point, (2) Blocking gate that structurally prevents progression, (3) Anti-pattern examples showing WRONG then RIGHT. If you only do one thing from this article, do this.

---

## Part B: Practical Tips for Skill Developers

---

### Your Skill Is a Contract, Not a Guide

Write SKILL.md as if it's a legal contract. Every ambiguous phrase will be interpreted the easiest way for the agent.

"Consider running tests after implementation" → Agent: "Tests are optional."

"BLOCKING: Run tests. If tests fail, do NOT proceed." → Agent: "I must run tests and they must pass."

The difference is night and day. Agents aren't malicious — they're optimizers. They'll find the shortest path to "done." Make sure the shortest path goes through your quality gates.

---

### Anti-Patterns Are More Important Than Patterns

A RIGHT example gives the agent one reference point. A WRONG + RIGHT pair gives it a **boundary**. Agents learn boundaries faster than targets.

Show what NOT to do first, then what TO do:

```
❌ WRONG: Show raw output and stop. User sees cryptic text.
✅ RIGHT: Read the artifact → show formatted summary → ask for approval.
```

Anti-patterns saved us more debugging time than any other technique.

---

### State Machines Beat Natural Language Conditionals

When your skill has multiple states (pending, in progress, waiting for review, completed, needs revision...), model them as a state machine in a **file** — not as conditional logic in your skill text.

The file-based state machine has three advantages: (1) it survives context compression, (2) the agent can read it to recover after a session break, (3) you can inspect and edit it manually when something goes wrong.

---

### The Inverse Proximity Law

The probability of an agent following an instruction is inversely proportional to its distance from the execution point.

Rules at the top of a file are "documentation" by the time execution happens 200 lines later. Rules adjacent to the execution point are "working memory."

Implication: **place rules where they'll be executed, not where they're organizationally tidy.** Yes, this means repeating yourself. In agent skills, 30 inline repetitions beat 1 beautifully organized reference that gets ignored.

---

### Test with Context Compression in Mind

Your skill will eventually be compressed out of the agent's context. Test for this:

1. Start a conversation
2. Run your skill through a long workflow (50+ messages)
3. Check: does the agent still follow your rules?

If not, you need more inline enforcement and more file-based state tracking. This is the single most important test you can run.

---

### Delegate What You Can't Automate

The agent can't drag files, can't enter API keys, can't observe terminal UI rendering. Instead of skipping these checks, delegate to the user with **specific instructions:**

"Drag-and-drop test skipped (tool limitation)" → Untested. ❌

"Please drag a file onto the upload zone. Does the status change from 'idle' to 'processing'?" → User verifies. ✅

The second version is 10x more valuable. Skipping is invisible tech debt. Delegating is documented verification.

---

### Version Your Skill Like Software

Skills evolve. Track changes in a history file. When you change a rule, document **why** — which failure triggered it. Future-you needs this context.

We have 40+ entries in our history file. Each links a rule change to the specific failure that caused it. When we need to decide "is this rule still needed?" the history tells us exactly what breaks if we remove it.

---

### Safety Nets Must Be Unconditional

Don't write: "If context limit prevents review, show fallback."

Write: "If this response ends without user interaction, for ANY reason, show the continue prompt."

The difference: the first version enumerates one failure mode. The second covers all of them. If you enumerate conditions, you'll always miss one. Define safety nets as invariants, not conditions.

---

## The Bigger Picture

These patterns aren't specific to Claude Code skills. They apply wherever AI agents execute multi-step workflows with human oversight:

**Context Continuity** — Information must survive transitions. Between features, between stages, between sessions. Files, not memory.

**Enforce, Don't Reference** — Rules that aren't enforced at the execution point don't exist. Inline repetition beats DRY for agent compliance.

**File over Memory** — Everything that matters goes into a persistent, diffable, editable file. The agent's context window is finite and unreliable.

**Delegate, Don't Skip** — When the agent can't automate something, it asks the user. Skipping is never acceptable.

As AI agents become more capable, the value shifts from writing code to designing the systems that channel that capability. The developers who thrive won't be the ones who write the best prompts — they'll be the ones who build the best harnesses.

---

## Getting Started

```
git clone https://github.com/coolhero/spec-kit-skills.git
cd spec-kit-skills
./install.sh
```

Then:

```
/code-explore /path/to/interesting-project
/smart-sdd init "your project idea"
/smart-sdd add "your first Feature"
/smart-sdd pipeline F001
```

The repository includes 32 user-facing scenarios in SCENARIO-CATALOG.md and a comprehensive lessons-learned file with all 19 patterns and 50+ specific incidents.

---

## 🤖 For Agents — Skill Development Checklist

```
skill development checklist:

  structure:
    - SKILL.md under 300 lines (always loaded — routing + mandatory rules)
    - commands/ for on-demand workflows (loaded per invocation)
    - reference/ for supporting rules and schemas
    - domains/ for modular expertise (loaded per profile)

  enforcement:
    - every critical rule: inline instruction + blocking gate + anti-pattern
    - never "See X for details" for critical behavior
    - HARD STOPs: use AskUserQuestion, never auto-proceed
    - empty response: always re-ask
    - safety nets: invariants, not conditions
    - 30 inline repetitions > 1 reference that gets ignored

  state management:
    - all pipeline state in files (not agent memory)
    - state machine file with valid transitions
    - after context compression: recover by reading state file

  testing:
    - test with 50+ message conversations (compression scenario)
    - test with interrupted sessions (resume from file state)
    - test anti-patterns (agent avoids WRONG patterns)
    - re-execute after rule changes (reading ≠ validating)

  failure patterns to watch:
    - build pass ≠ feature works → runtime verification required
    - agent guesses → force explicit source reading
    - context compression → inline rules at every execution point
    - cross-feature integration → explicit contracts + runtime check
    - SDK contracts → trust classification + runtime verification
    - sub-skill calls → inline execution instead of Skill tool
    - information loss between stages → inject source alongside summary
    - referenced rules → 3-layer enforcement (inline + gate + anti-pattern)

  principles:
    - contract not guide
    - anti-patterns > patterns
    - state machines > conditionals
    - inverse proximity law
    - delegate > skip
    - unconditional safety nets
    - version with WHY
```

---

*This concludes the 4-part series on spec-kit-skills. The project is open-source at github.com/coolhero/spec-kit-skills — contributions, feedback, and experiments welcome.*

*Written using Claude Code (Claude Opus 4.6). This entire series, and the project it describes, was developed through human-AI collaboration. The human designed the harness. The AI operated within it. Both were essential.*
