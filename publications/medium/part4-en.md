# Building Skills for AI Agents: Failure Patterns, Tips, and Hard-Won Wisdom

## Part 4 of 4 — Lessons Learned from 500+ Commits of Agent Skill Development

![Part 4 Cover](https://raw.githubusercontent.com/coolhero/spec-kit-skills/main/articles/medium/part4.png)

*Continued from [Part 3: 400 Markdown Files That Think](https://medium.com/@thejihoonchoi/400-markdown-files-that-think-the-architecture-of-spec-kit-skills-50047f0ecd1f)*

*Written with Claude Code — because of course it was. This article about controlling AI agents was itself drafted, revised, and polished by the same AI agent, operating within the same harness this series describes.*

---

## The Honest Truth

The build passed. TypeScript was clean. Tests were green. And the app was completely unusable — infinite re-renders caused by a state selector creating new object references every frame, scroll broken during streaming, the UI locked in a death spiral. A "successful" pipeline run had produced a broken application.

Building spec-kit-skills took over 500 commits across three weeks. We cataloged 19 recurring failure patterns and 50+ specific incidents. Every single one came from a real pipeline run that produced wrong results.

The insight: making AI agents *reliable* is fundamentally different from making them *capable*. The agent could always build features. The challenge was getting it to build the *right* features, the *right* way, *every time*.

Part 3 explained the architecture — *how* we built the system. This part is the field guide — *what went wrong* along the way, and what we learned from it. These patterns apply to anyone building AI agent workflows, regardless of the tool.

---

## For Humans — Failure Patterns and Practical Wisdom

> The first half of this article tells the human story: patterns we discovered, tips we wish we'd known earlier, and the bigger picture of where this is all heading. The second half — "For Agents" — encodes the same lessons as structured data for agent consumption.

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

### Pattern 9: Vocabulary Gap — Implement Guesses When No Module Covers the Pattern

The pipeline's quality depends on domain modules. When the system has an `auth` concern module, every Feature touching authentication gets 8 specific SC rules, 4 bug prevention patterns, and 5 elaboration probes. Quality is structural.

But when a Feature uses a pattern no module covers — say, video transcoding or blockchain consensus — the pipeline has no domain-specific rules to draw from. It falls back to generic `_core.md` rules, which produce generic SCs like "handle error gracefully" instead of "verify codec negotiation produces compatible output format."

**The fix**: `/domain-extend detect` identifies these gaps. `/domain-extend extend concern "video-encoding"` creates a module with targeted S1 rules, S7 bug patterns, and S5 probes. Once created, the module is indistinguishable from built-in ones — and every future Feature in this domain benefits.

**The universal lesson**: Any rule system has vocabulary limits. Build a mechanism to extend the vocabulary when the system encounters something new, rather than falling back to generic behavior that passes all gates but misses domain-specific risks.

---

## Practical Tips for Skill Developers

The failure patterns above describe *what* goes wrong. These tips describe *how to prevent it* — practical techniques we've validated through 500+ commits.

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

### Specification Without Enforcement Is Decoration

We had a perfectly designed lazy-loading table: "specify needs sections S0, S1, S5, S9; implement needs S7, S6." The table was documented, the savings calculated (40-95% context reduction). It sat in a reference file for months.

No injection file referenced it. Agents loaded full modules every time.

The fix took one afternoon: add a "Domain Module Filtering" section to each injection file with the exact sections to retain. The specification didn't change — only the enforcement points did.

This is the P2 principle applied to your own internal mechanisms: **a rule that lives only in a reference file does not exist for the agent.** Design the optimization, then add enforcement at every execution point. Step 2 is not optional.

---

### State Machines Beat Natural Language Conditionals

When your skill has multiple states (pending, in progress, waiting for review, completed, needs revision...), model them as a state machine in a **file** — not as conditional logic in your skill text.

The file-based state machine has three advantages: (1) it survives context compression, (2) the agent can read it to recover after a session break, (3) you can inspect and edit it manually when something goes wrong.

---

### Context Reset Protocol

When processing multiple Features, clear the context between them. All state is in files — nothing is lost.

Here's why this matters: after completing Feature 1 through all pipeline steps (specify → plan → tasks → implement → verify → merge), the agent's context window holds thousands of lines of conversation history — spec review discussions, plan alternatives considered, implementation debugging, verify evidence. Feature 2 starts in this cramped context, and the degradation is measurable: specify produces fewer SCs, verify defaults to code review instead of Playwright, Reviews get truncated.

The fix is simple: `/clear` (or start a new session) between Features. The agent re-reads `sdd-state.md`, loads updated registries, and operates with a fresh context budget. P3 (File over Memory) guarantees nothing is lost — every decision, every artifact, every status update lives in files.

When NOT to reset: never between steps within a Feature (specify → plan → tasks must flow continuously). Reset only at Feature boundaries, between skill transitions (reverse-spec → pipeline), or after the agent warns about context compaction.

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

### Reset Context Between Work Units

Context saturation is cumulative and silent. After processing 3+ work units (features, documents, analysis passes) in a single session, later work units receive degraded attention — shallower analysis, truncated reviews, simplified verification. The agent doesn't announce this degradation. It just produces less thorough output.

The fix is simple: clear the conversation context at natural work unit boundaries. Between features, between skill transitions (exploration to implementation), between analysis and execution.

This works because of P3 (File over Memory) — if all state is in files, clearing context loses nothing. The agent re-reads the state file, picks up where it left off, and operates with a fresh context budget.

The key design: identify where reset is safe (between work units) and where it's forbidden (mid-work-unit, where step continuity matters). Give users the choice — recommend reset, don't force it.

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

Throughout this series, we keep returning to the same tension: AI agents are getting smarter every month, yet the need for structured control isn't decreasing — it's increasing.

Why? Because a more capable agent without guardrails produces more *impressive-looking* output that's *harder to review*. When the agent generates 12 files of authentication code in 30 seconds, you can't review each line. You have to trust the process. And the process is only trustworthy if it has structural guarantees — gates that block, registries that remember, state machines that track.

This is the future of software development with AI: not "prompting better" but **harness engineering**. The three principles from Part 3 — Context Continuity, Enforce Don't Reference, File over Memory — plus the fourth from this article:

**Delegate, Don't Skip** — When the agent can't automate something, it asks the user with specific instructions. Skipping is never acceptable. Silent skips are invisible tech debt.

The developers who thrive in the age of agentic coding won't be the ones who write the best prompts. They'll be the ones who build the best harnesses — the systems that channel AI capability toward reliable, reviewable, controllable outcomes.

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

> Everything above was the human version — stories, analogies, practical wisdom. Everything below encodes the same lessons in a format agents consume directly. If you're building a skill, paste this into your project as a reference. If you're an agent reading this — well, this part is literally for you.

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

  failure_patterns:
    build_passes_feature_broken:
      signal: build ✅ + TypeScript ✅ but feature doesn't work at runtime
      cause: static analysis can't catch runtime behavior (state selectors, async timing, CSS rendering)
      fix: add Playwright runtime verification (Phase 3) — never trust build-only verification
    agent_guesses_instead_of_reading:
      signal: implementation doesn't match source app's UI controls or behavior
      cause: agent invents from imagination instead of reading source code
      fix: BLOCKING source code reference at implement stage — agent must read before writing
    context_compression_erases_rules:
      signal: agent follows rules for first N features, then stops
      cause: long conversation triggers context compression, skill instructions get evicted
      fix: inline critical rules at every execution point + file-based state for recovery
    cross_feature_integration_fails:
      signal: features work alone but break when combined
      cause: no explicit data contract at feature boundaries
      fix: define integration contracts (provider shape, consumer shape, exact fields) + runtime check
    sdk_accepts_anything_executes_nothing:
      signal: SDK call succeeds but produces no effect
      cause: permissive SDK types accept metadata-only objects without callable functions
      fix: classify SDKs by trust level + add runtime contract checks for medium/low trust
    sub_skill_breaks_orchestration:
      signal: orchestrator stops after sub-skill returns, no review or state update
      cause: Skill tool creates response boundary, post-execution steps become unreachable
      fix: read sub-skill instructions and execute inline instead of using Skill tool
    information_dies_between_stages:
      signal: final implementation missing details that existed in source analysis
      cause: each stage only sees previous stage's summary, not underlying evidence
      fix: inject original source alongside summaries for critical details (UI, data formats, errors)
    referenced_rules_get_ignored:
      signal: agent skips detailed procedures in reference files
      cause: "See X for details" is treated as optional reading by agents
      fix: 3-layer enforcement at every execution point (inline instruction + blocking gate + anti-pattern)
    context_saturation_across_work_units:
      signal: later work units get shallower analysis, truncated reviews, simplified verification
      cause: accumulated context from prior work units fills the window silently
      fix: reset context at work unit boundaries (between features, between skill transitions) — safe when all state is in files

  principles:
    - "contract not guide": write SKILL.md like a legal contract — every ambiguous phrase will be interpreted the easiest way
    - "anti-patterns > patterns": WRONG + RIGHT pairs give boundaries; agents learn boundaries faster than targets
    - "state machines > conditionals": model multi-state workflows as file-based state machines, not natural language if/else
    - "context reset protocol": clear context between work units (Features) — all state is in files, nothing is lost, later Features get fresh context budget
    - "domain extend": when existing modules don't cover your patterns, /domain-extend creates new ones from discovery, ADR import, or manual creation
    - "inverse proximity law": place rules where they execute, not where they're organized — 30 inline repetitions beat 1 ignored reference
    - "delegate > skip": when the agent can't automate a check, ask the user with specific instructions — never silently skip
    - "unconditional safety nets": define safety nets as invariants ("if response ends without interaction"), not conditions ("if context limit")
    - "version with WHY": track every rule change with the failure that caused it — future-you needs that context
```

---

*This concludes the 4-part series on spec-kit-skills. The project is at [github.com/coolhero/spec-kit-skills](https://github.com/coolhero/spec-kit-skills) — feedback and experiments welcome.*

*Written using Claude Code (Claude Opus 4.6). This entire series, and the project it describes, was developed through human-AI collaboration. The human designed the harness. The AI operated within it. Both were essential.*

---

📖 **Want the complete reference?** Download the [Technical Reference Manual (114 pages, PDF)](https://github.com/coolhero/spec-kit-skills/releases/download/v0.2.0/spec-kit-skills-technical-reference-en.pdf) — covers everything from design philosophy to module schemas to failure patterns.

**Series Navigation:**

← **Part 1**: [Why Your Agent Needs a Harness](https://medium.com/@thejihoonchoi/taming-the-ai-coder-why-your-agent-needs-a-harness-not-just-a-prompt-0869fa51da34)

← **Part 2**: [Four Skills, One Pipeline](https://medium.com/@thejihoonchoi/four-skills-one-pipeline-how-code-explore-reverse-spec-smart-sdd-and-domain-extend-work-cfc33edf249d)

← **Part 3**: [400 Markdown Files That Think](https://medium.com/@thejihoonchoi/400-markdown-files-that-think-the-architecture-of-spec-kit-skills-50047f0ecd1f)
