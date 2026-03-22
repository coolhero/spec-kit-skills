# 400 Markdown Files That Think: The Architecture of spec-kit-skills

## Part 3 of 4 — Design Philosophy, File Structure, Extensibility

*Continued from [Part 2: Three Skills, One Pipeline](part2-en.md)*

---

## The Paradox of AI Skill Design

Here's the strange truth about building tools for AI agents: **the agent is both your user and your runtime.**

When you write a React component, React runs it. When you write a Claude Code skill, Claude *reads* it — as markdown — and decides how to behave. Your "code" is natural language. Your "compiler" is an LLM. Your "bugs" are behavioral: the agent does the wrong thing not because of a syntax error, but because it misunderstood your intent.

This changes everything about how you design.

## Three Foundational Philosophies

Every design decision in spec-kit-skills traces back to three principles. We learned them the hard way — through hundreds of failed pipeline runs.

### P1: Context Continuity

> Information must flow continuously through every pipeline stage. Nothing gets lost at transitions.

This sounds obvious. It isn't.

In practice, an AI agent starting Feature 3 knows nothing about Feature 1 — unless you explicitly load Feature 1's artifacts into its context. The agent doesn't have a "project memory." It has a context window that gets compressed and eventually forgets.

Context Continuity manifests in three ways:

**P1-a: Domain Profile is a First-Class Citizen**. It's not a one-time config. It actively shapes every stage — which probes get asked during `add`, which rules activate during `specify`, which verification steps run during `verify`.

**P1-b: Source Code Fidelity (Artifact Separation)**. Specs describe *what to build*, not *where it came from*. Source analysis stays in reverse-spec artifacts. Smart-sdd specs are source-agnostic. This means you can rebuild a feature differently from the source without the spec being contaminated by the old implementation.

**P1-c: Cross-Feature Memory (GEL)**. Entity registries, API registries, pre-context, stubs — these are the Global Evolution Layer. Feature 3 reads Feature 1's registry. Feature 4 reads Feature 3's stubs. The information flows forward through files, not through the agent's memory.

### P2: Enforce, Don't Reference

> "See X for details" has zero enforcement power. Rules must be enforced at the point of execution, not referenced from a distance.

This is the most counterintuitive principle. In normal software, you write a function once and call it from everywhere. In agent skills, **referenced rules get ignored.**

Why? Because the agent treats references as optional reading. "See verify-phases.md for the full verification protocol" → the agent reads this as "there's more info somewhere, but I'll just do build + test and call it done."

Every critical rule needs three things:
1. **Inline instruction** — the rule appears directly at the execution point
2. **Blocking gate** — not a warning, a blocker. The agent cannot proceed without compliance.
3. **Anti-pattern examples** — explicit "WRONG" and "RIGHT" patterns

```
❌ WRONG: "See verify-phases.md for details"
   → Agent: "noted" → runs build+TS only → "verify ✅"

✅ RIGHT: "🚨 Running build+TS only is NOT verification.
   You MUST read verify-phases.md and execute Phases 0-4."
   → Agent: "I need to read that file" → executes full protocol
```

This is why spec-kit-skills has seemingly redundant text across files. It's intentional. The HARD STOP re-ask text appears 30+ times because each occurrence is at a different execution point, and referencing a shared file doesn't work.

### P3: File over Memory

> Every intermediate artifact and state goes into a file. Never rely on agent memory.

The agent's context window is:
- **Limited** — gets compressed as the conversation grows
- **Session-scoped** — gone when the session ends
- **Non-inspectable** — you can't see what the agent remembers

Files are:
- **Persistent** — survive across sessions
- **Diffable** — `git diff` shows exactly what changed
- **Editable** — you can manually fix a spec and re-run the pipeline
- **Shareable** — another agent (or human) can continue the work

This is why `sdd-state.md` exists. It's the project's state machine — in a file, not in the agent's head.

## The File Architecture

### Skill Structure

Each skill follows the same pattern:

```
SKILL.md              ← System prompt (slim routing, MANDATORY RULES)
commands/
  orient.md           ← On-demand workflow (loaded only when invoked)
  trace.md
  synthesis.md
reference/
  injection/          ← Per-command context injection rules
    specify.md
    plan.md
    implement.md
  state-schema.md     ← State machine definition
  pipeline-integrity-guards.md
domains/
  _core.md            ← Universal rules (always loaded)
  _resolver.md        ← Module loading logic
  _schema.md          ← Profile model definition
  interfaces/         ← 9 interface modules
  concerns/           ← 48 concern modules
  archetypes/         ← 15 archetype modules
  scenarios/          ← 4 scenario modules
  profiles/           ← 15 pre-built profiles
```

### Why This Structure?

**Context efficiency.** SKILL.md is always loaded (~200 lines). Command files are loaded on-demand (only `orient.md` during `/code-explore`, only `pipeline.md` during `/smart-sdd pipeline`). Domain modules are loaded selectively — only the modules matching your Domain Profile.

A Venn diagram of what's in context at any given time:

```
Always loaded:          SKILL.md (~200 lines)
Per-command:            commands/pipeline.md (~500 lines)
Per-domain:             3-5 modules × ~100 lines = ~400 lines
Per-Feature:            pre-context.md + spec.md (~200 lines)
                        ─────────────────────
Total:                  ~1,300 lines in context

vs. loading everything: ~15,000+ lines → context overflow
```

### The Domain Module Loading Order

When the pipeline runs, domain modules are loaded in a specific order. Later modules can extend earlier ones:

```
1. _core.md                     ← Universal rules (always)
2. interfaces/{name}.md         ← Per Interface (gui, cli, http-api, etc.)
3. concerns/{name}.md           ← Per Concern (auth, realtime, etc.)
4. archetypes/{name}.md         ← Per Archetype (ai-assistant, etc.)
5. foundations/{framework}.md   ← Per Foundation (electron, fastapi, etc.)
6. org-convention.md            ← Organization-wide rules (optional)
7. scenarios/{name}.md          ← Per Scenario (greenfield, rebuild, etc.)
8. domain-custom.md             ← Project-level overrides (optional)
```

Each module has standardized sections (S0-S9 for interfaces/concerns, A0-A5 for archetypes). Rules accumulate — if both `gui` and `realtime` are active, their S1 (SC Generation Rules) sections merge.

### Context Injection

This is the key architectural innovation. Each pipeline step has an **injection file** that defines what context gets assembled for that step:

```
reference/injection/
  specify.md    ← What context speckit-specify receives
  plan.md       ← What context speckit-plan receives
  implement.md  ← What context speckit-implement receives
```

The injection file doesn't contain the rules — it orchestrates *which* domain modules, GEL artifacts, and pre-context get loaded. Think of it as a dependency injection container for natural language rules.

Example: when `speckit-specify` runs for an `ai-assistant` + `gui` + `realtime` project:
- `_core.md` § S1 loads universal SC rules
- `gui.md` § S1 adds UI-specific SC patterns
- `realtime.md` § S1 adds streaming/latency SC requirements
- `ai-assistant` § A2 adds LLM-specific SC extensions
- `injection/specify.md` orchestrates this loading and adds specify-specific rules (Brief → SC mapping, Elaboration Probes)

## Extensibility

### Adding a New Concern Module

1. Create `domains/concerns/your-concern.md`
2. Follow the section schema (S0-S9)
3. That's it — the resolver auto-discovers it when the user's Domain Profile includes it

No code changes. No registration. The module system is convention-based: if a file exists at the expected path, it gets loaded.

### Adding a New Foundation

1. Create `domains/foundations/your-framework.md` (in reverse-spec's domain dir)
2. Add F2 (specify-time) and F3 (implement-time) sections
3. The resolver loads it when the Domain Profile's Foundation axis matches

### Creating a Custom Profile

```markdown
# Profile: my-custom-stack

interfaces: gui, http-api
concerns: auth, realtime, ai-assistants
archetype: ai-assistant
foundation: nextjs
scenario: greenfield
scale:
  project_maturity: mvp
  team_context: solo
```

Save to `domains/profiles/my-custom-stack.md`. Use with `/smart-sdd init --profile my-custom-stack`.

---

## 🤖 For Agents — Architecture Reference

```yaml
architecture:
  design_principles:
    P1_context_continuity:
      sub_principles: [domain_profile_first_class, artifact_separation, cross_feature_memory]
      enforcement: GEL artifacts (entity-registry, api-registry, sdd-state.md)
    P2_enforce_dont_reference:
      requirement: every critical rule needs inline_instruction + blocking_gate + anti_pattern
      reason: agents treat references as optional reading
    P3_file_over_memory:
      requirement: all intermediate state stored in files, never in agent context alone
      reason: context window is limited, session-scoped, non-inspectable

  file_structure:
    skill_pattern:
      SKILL.md: system prompt, mandatory rules, slim routing (~200 lines, always loaded)
      commands/: on-demand workflows (loaded per invocation)
      reference/injection/: per-command context assembly rules
      domains/: modular domain expertise (loaded per Domain Profile)

  module_loading:
    order: [_core, interfaces, concerns, archetypes, foundations, org_convention, scenarios, domain_custom]
    merge_rule: later modules extend earlier ones (append semantics for S1, S5, A2)
    selection: only modules matching active Domain Profile are loaded

  context_injection:
    purpose: orchestrate which modules + artifacts load for each pipeline step
    files: [injection/specify.md, injection/plan.md, injection/implement.md]
    pattern: injection file reads Domain Profile → loads relevant modules → assembles context → feeds to speckit-* command

  extensibility:
    add_concern: create domains/concerns/{name}.md with S0-S9 sections → auto-discovered
    add_foundation: create domains/foundations/{name}.md with F2-F3 sections → auto-loaded
    add_profile: create domains/profiles/{name}.md with axis declarations → usable via --profile
    add_archetype: create domains/archetypes/{name}.md with A0-A5 sections → auto-discovered

  context_budget:
    always_loaded: ~200 lines (SKILL.md)
    per_command: ~500 lines (command file)
    per_domain: ~400 lines (3-5 modules × ~100 lines)
    per_feature: ~200 lines (pre-context + spec)
    total_typical: ~1300 lines (vs ~15000 if everything loaded)
```

---

*Next: **Part 4 — Lessons Learned: Building Skills for AI Agents** — failure patterns, tips, and practical guidance for anyone building their own skills.*
