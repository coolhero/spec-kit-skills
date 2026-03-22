# 400 Markdown Files That Think: The Architecture of spec-kit-skills

## Part 3 of 4 — Design Philosophy, File Structure, Extensibility

![Part 3 Cover](https://raw.githubusercontent.com/coolhero/spec-kit-skills/main/articles/medium/part3.png)

*Continued from Part 2: Three Skills, One Pipeline — (link to Part 2 on Medium)*

---

## The Paradox of AI Skill Design

Here's the strange truth about building tools for AI agents: **the agent is both your user and your runtime.**

When you write a React component, React runs it. When you write a Claude Code skill, Claude *reads* it — as markdown — and decides how to behave. Your "code" is natural language. Your "compiler" is an LLM. Your "bugs" are behavioral: the agent does the wrong thing not because of a syntax error, but because it misunderstood your intent.

This means you can't debug with a stack trace. You can't set breakpoints. You can't write unit tests for "the agent follows instruction X." Your only testing method is: run the pipeline, watch what happens, iterate.

And there's an additional constraint that makes this uniquely difficult: **context windows are finite and get compressed.** The beautifully written rule you put at the top of your skill file? After 50 messages, it may be compressed into a single summary sentence — or dropped entirely.

This changes everything about how you design.

---

## Three Foundational Philosophies

Every design decision in spec-kit-skills traces back to three principles. We didn't start with these principles — we discovered them through hundreds of failed pipeline runs, each failure revealing a pattern that no amount of "write better instructions" could fix.

---

### P1: Context Continuity — Information Must Flow Forward

> Information must flow continuously through every pipeline stage. Nothing gets lost at transitions.

This sounds obvious until you realize what "transitions" means for an AI agent:

**Between Features:** Feature 3 starts with a clean context. It knows nothing about Feature 1's User entity or Feature 2's API contracts — unless you explicitly load that information. We solved this with the Global Evolution Layer: entity-registry.md, api-registry.md, and sdd-state.md carry information forward as files.

**Between pipeline stages:** When `speckit-specify` finishes and `speckit-plan` starts, the agent's working context shifts. The detailed analysis from specify might be compressed. We solved this with injection files that explicitly re-load the relevant context for each stage.

**Between sessions:** The user closes their laptop, opens it the next day, and continues. Everything the agent "knew" yesterday is gone — except what's in files. Every intermediate result, every decision, every state transition is persisted to the filesystem.

Context Continuity has three sub-principles:

**P1-a: Domain Profile is a First-Class Citizen.** It's not a one-time configuration. The Domain Profile actively shapes every stage — which probes get asked during `add`, which rules activate during `specify`, which verification steps run during `verify`. If the profile says `gui + realtime`, then specify generates SCs for optimistic UI updates and reconnection handling. If it says `cli + resilience`, completely different SCs emerge.

Here's the concrete mechanism: domain modules have standardized sections (S1 for SC generation rules, S5 for elaboration probes, S7 for bug prevention rules, S8 for runtime verification strategy). When the pipeline runs, the injection file loads the relevant modules and merges their sections. An `ai-assistant` archetype adds A2 (SC extensions for token management, streaming interruption). A `gui` interface adds S6 (UI testing integration). They accumulate — the final context for specify is the union of all active modules' S1 sections.

**P1-b: Artifact Separation (Source Code Fidelity).** This principle was born from a painful failure. During a rebuild project, the spec for Feature 3 described the source app's implementation details instead of the desired behavior. When we tried to implement it differently (better data model, different API design), the spec fought us — it kept pulling toward the old implementation.

The fix: specs describe *what to build*, never *where it came from*. Source analysis stays in reverse-spec artifacts (pre-context.md). Smart-sdd specs (spec.md) are source-agnostic. This separation means you can rebuild differently without the spec being contaminated by the old implementation.

**P1-c: Cross-Feature Memory (GEL).** The Global Evolution Layer consists of files that carry information across Features:
- `entity-registry.md` — all data models with fields, types, relationships
- `api-registry.md` — all endpoints with contracts
- `sdd-state.md` — project state machine (which Feature is at which step)
- `roadmap.md` — Feature dependency graph
- `pre-context.md` (per Feature) — detailed requirements context

When Feature 3 starts, the agent reads the registry. It sees Feature 1's User entity and generates SCs that reference existing fields, not hypothetical ones. This is trivially obvious in hindsight — but without it, every Feature reinvents every entity, and integration becomes a nightmare.

---

### P2: Enforce, Don't Reference — The Most Counterintuitive Principle

> "See X for details" has zero enforcement power. Rules must be enforced at the point of execution, not referenced from a distance.

In normal software, you write a function once and call it from everywhere. DRY — Don't Repeat Yourself. But in agent skills, **DRY kills compliance.**

Here's why: the agent treats references as optional reading. When it sees "See verify-phases.md for the full verification protocol," it processes this as "there's more info available, but I have enough context to proceed." It runs build + TypeScript, reports "verify ✅", and moves on. The 400 lines of detailed verification logic in verify-phases.md are never read.

This isn't a hypothetical. It happened during Feature 6 verification — after the same agent had correctly executed the full verification protocol for Features 1 through 5. Context compression had eaten the verify-phases.md content, and the reference was treated as optional.

The fix required three layers:

**Layer 1 — Inline instruction.** The rule appears directly at the execution point, not in a referenced file. Not "see verify-phases.md" but the actual rule, right there.

**Layer 2 — Blocking gate.** Not a warning ("⚠️ you should verify") but a blocker ("🚫 BLOCKING: verification incomplete. Cannot proceed to merge."). The difference is the agent can't rationalize its way past a blocker — it structurally cannot produce the next step's output without completing verification.

**Layer 3 — Anti-pattern examples.** Explicit WRONG and RIGHT patterns:

```
❌ WRONG: Run build+TS, display "verify ✅", proceed to merge
   → 10 SCs unverified. Feature unreachable from UI.

✅ RIGHT: Read verify-phases.md → execute Phase 0-4 →
   show SC coverage matrix → AskUserQuestion
```

This is why spec-kit-skills has what looks like redundant text. The HARD STOP re-ask instruction appears 30+ times across different files. Each occurrence is at a different execution point. Extracting it to a shared file would be "cleaner" code — and would be ignored by the agent.

**A concrete example of the pattern:**

We discovered that the agent would often execute a spec-kit command, show the raw output, and stop — without reading the generated artifact, displaying a review, or asking for user approval (Gap Pattern G15). The fix wasn't a single rule; it was a 4-layer defense:

1. The SKILL.md (always loaded) contains MANDATORY RULE 3: "After every speckit-* execution, you MUST read the artifact, show a review, and call AskUserQuestion"
2. Each pipeline step's section contains an inline Execute+Review protocol specific to that step
3. A catch-all fallback: if for ANY reason the response ends without AskUserQuestion, show a continue prompt
4. A Stop hook (shell script) that detects raw spec-kit navigation messages leaking through

---

### P3: File over Memory — The Persistence Principle

> Every intermediate artifact and state goes into a file. Never rely on agent memory.

Three properties of the agent's context window make it unreliable for state:

- **Limited** — It gets compressed as the conversation grows. After 50 messages, early context is summarized or dropped entirely.
- **Session-scoped** — When the session ends, everything is gone. The next session starts blank.
- **Non-inspectable** — You can't see what the agent remembers. You can't debug "why did it forget that Feature 1 uses UUIDs?"

Files have none of these problems. They're persistent, diffable (`git diff` shows exactly what changed), editable (you can manually fix a spec and re-run), and shareable (another agent or human can continue the work).

This is why `sdd-state.md` exists as a state machine file. When the agent resumes after context compression or a new session, it reads the file, sees "F003 is at step implement, task 4/7", and continues from there. No guessing, no "I think we were working on..."

---

## The File Architecture: How 400+ Files Stay Context-Efficient

### The Core Pattern

Every skill follows the same structure:

```
SKILL.md              — Always loaded (~200 lines)
commands/             — Loaded on-demand (only the invoked command)
reference/
  injection/          — Per-command context assembly rules
  state-schema.md     — State machine definition
  pipeline-integrity-guards.md
domains/
  _core.md            — Universal rules (always loaded with domain)
  _resolver.md        — Module loading logic
  interfaces/         — 9 modules (gui, cli, http-api, grpc, tui, embedded, mobile, library, data-io)
  concerns/           — 48 modules (auth, realtime, resilience, connection-pool, tls-management, ...)
  archetypes/         — 15 modules (ai-assistant, microservice, network-server, ...)
  scenarios/          — 4 modules (greenfield, rebuild, adoption, incremental)
  profiles/           — 15 pre-built profiles
```

### Why This Structure Works: The Context Budget

LLM context windows are large but not infinite. If you load everything, you burn through the context budget before the agent even starts working. spec-kit-skills uses **selective loading** — only the modules that match the current task and project profile.

Here's the math for a typical pipeline step:

- **Always loaded:** ~200 lines (SKILL.md with routing + mandatory rules)
- **Per-command:** ~500 lines (the specific command file, e.g., pipeline.md)
- **Per-domain:** ~400 lines (3-5 modules × ~100 lines each, matching the Domain Profile)
- **Per-Feature:** ~200 lines (pre-context + current spec)
- **Total:** ~1,300 lines in working context

If everything were loaded: ~15,000+ lines — the agent would spend its context budget reading instructions instead of doing work. The selective loading is what makes this practical.

### The Domain Module Loading Order

When the pipeline runs, modules load in a specific order. Each layer can extend the previous:

1. **_core.md** — Universal rules that apply to every project
2. **interfaces/{name}.md** — Rules specific to the Interface axis (gui, cli, http-api, grpc, etc.)
3. **concerns/{name}.md** — Rules for each active Concern (auth, realtime, resilience, etc.)
4. **archetypes/{name}.md** — Domain philosophy rules (ai-assistant, microservice, network-server, etc.)
5. **foundations/{framework}.md** — Framework-specific rules (electron, fastapi, go, etc.)
6. **org-convention.md** — Organization-wide rules (optional, shared across projects)
7. **scenarios/{name}.md** — Lifecycle rules (greenfield, rebuild, adoption)
8. **domain-custom.md** — Project-level overrides (optional)

Modules use standardized section numbering. Interfaces and concerns use S0-S9. Archetypes use A0-A5 (separate numbering to avoid collision). When multiple modules are active, their sections **merge** — `gui.md`'s S1 (SC generation rules) accumulates with `realtime.md`'s S1 and `ai-assistant`'s A2 (SC extensions).

The merge semantics are append-based: if `gui` says "every interactive element needs a hover state SC" and `realtime` says "every streaming display needs a completion indicator SC," the combined S1 section includes both rules. No conflicts because the rules operate on different domains.

### Context Injection: The Key Innovation

This is the architectural heart of the system. Each pipeline step has an **injection file** that orchestrates context assembly:

```
reference/injection/
  specify.md    — What context speckit-specify receives
  plan.md       — What context speckit-plan receives
  implement.md  — What context speckit-implement receives
```

Think of it as a dependency injection container for natural language rules. The injection file doesn't contain the rules — it declares which modules to load, which GEL artifacts to include, and which step-specific instructions to add.

**Example: What happens when `speckit-specify` runs for an ai-assistant + gui + realtime project:**

1. Injection file loads `_core.md` § S1 — universal SC generation rules
2. Loads `gui.md` § S1 — "Every form needs validation feedback SC, every navigation needs route guard SC"
3. Loads `realtime.md` § S1 — "Every streaming display needs: start indicator, progress update, completion signal, error fallback, reconnection logic"
4. Loads `ai-assistant` § A2 — "Provider abstraction requires: multi-provider SC, rate limit handling SC, token budget management SC"
5. Adds step-specific rules: Brief → SC mapping, elaboration probes, SC numbering convention
6. Includes GEL context: existing entity-registry.md, api-registry.md
7. Includes Feature context: pre-context.md for this Feature

The result: speckit-specify receives a tailored context that reflects this specific project's needs. A different project — say, a cli + resilience + microservice — would receive completely different rules through the same injection mechanism.

---

## Extensibility: Convention over Configuration

### Adding a New Concern Module

You've discovered a cross-cutting pattern that doesn't fit any existing concern — say, `rate-limiting` as a distinct concern. Here's what you do:

1. Create `domains/concerns/rate-limiting.md`
2. Add sections following the schema:
   - S0: Signal Keywords (how to detect this concern in code)
   - S1: SC Generation Rules (what SCs to create when this concern is active)
   - S3: Verify Steps (additional verification when this concern is active)
   - S5: Elaboration Probes (questions to ask during Brief consultation)
   - S7: Bug Prevention Rules (common anti-patterns for this concern)
3. That's it. The resolver auto-discovers it when a user's Domain Profile includes `rate-limiting`.

No code changes. No registration step. No config file update. If the file exists at the expected path, it gets loaded.

### Adding a New Foundation

Framework-specific rules live in `domains/foundations/{framework}.md` with two sections:

- **F2** — Specify-time rules (what constraints this framework imposes on spec generation)
- **F3** — Implement-time rules (framework idioms, anti-patterns, toolchain setup)

For example, `electron.md`'s F2 includes "main process must survive renderer crashes" as a mandatory architectural principle. Its F3 includes "use `_electron.launch()` for Playwright, pass `--user-data-dir` to preserve user settings."

### Creating a Custom Profile

A profile is a ~10-line manifest:

```markdown
# Profile: my-ai-chat

interfaces: gui, http-api
concerns: auth, realtime, ai-assistants, external-sdk
archetype: ai-assistant
foundation: nextjs
scenario: greenfield
scale:
  project_maturity: mvp
  team_context: solo
```

Save to `domains/profiles/my-ai-chat.md`. Use with `/smart-sdd init --profile my-ai-chat`. The resolver reads the profile and loads all declared modules.

### The Three-Level Convention Hierarchy

Rules can come from three levels, with later levels overriding earlier ones:

1. **Skill-level** — `_core.md` + domain modules (universal, maintained by the project)
2. **Org-level** — `org-convention.md` (shared across an organization's projects)
3. **Project-level** — `domain-custom.md` (specific to one project)

This means a company can define org-wide conventions (naming patterns, API design standards, security requirements) that automatically apply to all projects using spec-kit-skills, while individual projects can override specific rules.

---

## The Pipeline Integrity Guards

Seven guards (G1-G7) enforce pipeline correctness. Each guard is a blocking check at a specific pipeline transition:

**G1 — Constitution Guard.** Before specify: is the constitution defined? Without it, specs lack guiding principles.

**G2 — Entity Registry Guard.** Before plan: are all entities from spec registered? Without them, the plan can't reference existing data models.

**G3 — API Registry Guard.** Before implement: are all APIs from the plan registered? Without them, implementation guesses at contracts.

**G4 — Pre-Context Guard.** Before specify: does pre-context exist for this Feature? Without it, the spec is based on nothing.

**G5 — Dependency Order Guard.** Before pipeline: are this Feature's dependencies completed? Without them, implementation references entities that don't exist yet.

**G6 — Augmentation Guard.** After `add --to`: was the pipeline re-run? Without it, the spec doesn't reflect the new requirements.

**G7 — Regression Guard.** After verify finds issues: was the regression addressed? Without it, known bugs carry forward.

Each guard follows the same pattern: check condition → if failed, display blocking message → agent cannot proceed until the condition is met.

---

## 🤖 For Agents — Architecture Reference

```
architecture:
  principles:
    P1 Context Continuity:
      P1-a: Domain Profile is first-class (shapes every pipeline stage via module sections)
      P1-b: Artifact Separation (specs describe WHAT, not WHERE FROM)
      P1-c: Cross-Feature Memory via GEL files (entity-registry, api-registry, sdd-state)

    P2 Enforce Don't Reference:
      requirement: every critical rule needs 3 layers
        layer_1: inline instruction at execution point
        layer_2: blocking gate (not warning — structural blocker)
        layer_3: anti-pattern examples (WRONG then RIGHT)
      evidence: HARD STOP text appears 30+ times (each at different execution point)
      reason: agents treat references as optional reading
      corollary: DRY kills compliance in agent skills

    P3 File over Memory:
      requirement: all state in files (sdd-state.md, registries, pre-context)
      reason: context window is limited, session-scoped, non-inspectable
      benefit: git diff = full audit trail, cross-session persistence, human-editable

  file structure:
    SKILL.md: ~200 lines, always loaded (routing + mandatory rules)
    commands/: loaded per invocation (~500 lines)
    reference/injection/: context assembly per pipeline step (DI container for natural language rules)
    domains/: loaded per Domain Profile (~400 lines for 3-5 modules)

  domain module system:
    loading_order: _core → interfaces → concerns → archetypes → foundations → org → scenarios → custom
    section_schema:
      interfaces_concerns: S0 (keywords), S1 (SC rules), S3 (verify), S5 (probes), S7 (bugs), S8 (runtime)
      archetypes: A0 (keywords), A1 (philosophy), A2 (SC extensions), A3 (probes), A4 (constitution), A5 (brief criteria)
    merge_rule: append semantics (accumulate, don't override)
    selection: only modules matching active Domain Profile

  context_budget:
    typical: ~1,300 lines (SKILL.md + command + 3-5 modules + Feature context)
    worst_case: ~15,000 lines if everything loaded (avoided by selective loading)

  pipeline_guards: G1 (constitution) through G7 (regression)
    pattern: check condition → if failed → blocking message → cannot proceed

  extensibility:
    add_concern: create domains/concerns/{name}.md with S0-S9 → auto-discovered
    add_foundation: create domains/foundations/{name}.md with F2-F3 → auto-loaded
    add_profile: create domains/profiles/{name}.md → usable via --profile
    convention_hierarchy: skill-level → org-level → project-level (later overrides earlier)
```

---

*Next: **Part 4 — Lessons Learned** — 19 gap patterns and 50+ specific lessons from building AI agent skills. Real failures, real fixes, and universal takeaways for anyone building their own agent workflows.*
