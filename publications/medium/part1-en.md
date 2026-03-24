# Taming the AI Coder: Why Your Agent Needs a Harness, Not Just a Prompt

## Part 1 of 4 — Background, Architecture, and Real-World Scenarios

![Part 1 Cover](https://raw.githubusercontent.com/coolhero/spec-kit-skills/main/articles/medium/part1.png)

*This article was written with Claude Code — the same tool this project is built for. The irony is intentional.*

---

**TL;DR**: AI coding agents are incredibly capable, but "capable" isn't the same as "controllable." This series introduces **spec-kit-skills**, a set of Claude Code skills that give developers structured control over how AI agents explore, plan, and build software. Think of it as a flight harness for your AI copilot — it can still fly, but now you decide where.

**Repository**: github.com/coolhero/spec-kit-skills

---

## The Problem Nobody Talks About

Here's a scenario every developer using AI coding tools has experienced:

You ask your AI agent to "add user authentication." It generates 400 lines of code in 30 seconds. You review it. It looks… reasonable. You merge it.

Three weeks later, you discover:

- It used JWT when your team standardized on sessions
- It stored tokens in localStorage (hello, XSS)
- It created a User model that conflicts with the one Feature 2 already defined
- The error handling covers the happy path and literally nothing else

The code *worked*. It even had tests. But it wasn't *your* code — it was code that happened to be in your repository.

**This is the gap between AI capability and developer control.**

---

## "Just Write a Better Prompt"

The most common advice is to write better prompts. And yes, better prompts help. But there's a ceiling.

A prompt is a one-shot instruction. It carries no memory of what Feature 1 decided, no awareness of your team's architectural patterns, no understanding that your project is an Electron app (not a web app) and that changes how state management works.

What you actually need isn't a better prompt — it's a **system** that:

**Remembers** across Features — Feature 3 knows Feature 1's data models

**Adapts** to your project type — an Electron app gets different rules than a REST API

**Enforces** quality gates — the agent can't skip verification just because the build passed

**Documents** decisions in files, not in the agent's memory — which evaporates between sessions

This is what we call **Harness Engineering** — building structured systems that channel AI agent behavior toward reliable outcomes.

---

## Why Now?

Agentic coding tools have crossed a threshold. Claude Code, Cursor, Copilot Workspace, Devin — they don't just autocomplete lines; they plan, implement, test, and iterate across entire Features.

But here's the thing: **the smarter the agent, the more damage it can do unsupervised.**

A basic autocomplete suggestion is easy to review — it's one line. An agentic workflow that scaffolds an entire authentication system across 12 files? That's a different kind of review. You need to trust the *process* that generated it, not just the output.

This is where the industry is heading. Not "AI replaces developers" but "developers build harnesses for AI." The value shifts from *writing code* to *designing the system that writes code*.

---

## What spec-kit-skills Actually Is

**spec-kit-skills** is a set of four Claude Code skills that wrap spec-kit (GitHub's Specification-Driven Development tool) with project-wide awareness. They form a pipeline:

**Understand** (`/code-explore`: orient → trace → synthesis)
→ **Analyze** (`/reverse-spec`: scan → classify → extract → generate)
→ **Specify + Build** (`/smart-sdd`: init → add → specify → plan → implement)
→ **Verify** (`/smart-sdd`: 4-phase runtime verification)
→ *feedback loop back to Understand*

The fourth skill, `/domain-extend`, works differently — it doesn't sit in the pipeline but **wraps around it**. When any of the three pipeline skills encounters a pattern your project uses (WebRTC signaling, custom protocols, blockchain consensus) that no built-in module covers, domain-extend teaches the system that new domain. It can also import your team's ADRs, style guides, and postmortems into the module format. The three pipeline skills consume domain knowledge; domain-extend produces it.

---

## The Three Key Concepts

**1. Global Evolution Layer (GEL) — Cross-Feature memory that lives in files**

Every Feature the agent builds gets registered: its data models go into `entity-registry.md`, its API endpoints into `api-registry.md`. When Feature 3 starts, the agent doesn't guess what exists — it reads the registry.

This is the "File over Memory" philosophy: anything the agent needs to remember goes into a file, not into its context window (which gets compacted and eventually forgotten).

**2. Domain Profile — Project-type expertise in 5 axes**

Not all projects are the same. An Electron desktop app has different concerns than a FastAPI server. The Domain Profile captures this in 5 axes:

- **Interface** — How users interact: `gui`, `cli`, `http-api`, `grpc`
- **Concern** — Cross-cutting patterns: `auth`, `realtime`, `resilience`
- **Archetype** — Domain philosophy: `ai-assistant`, `microservice`
- **Foundation** — Framework specifics: `electron`, `fastapi`, `go`
- **Context** — Project situation: `greenfield`, `rebuild`, `adoption` + scale + modifiers

When you tell the system your project is an Electron app with real-time features, every subsequent spec, plan, and verification step adapts — IPC gets checked, renderer/main process boundaries are enforced, and Playwright launches via Electron-specific protocols. And when a pattern isn't covered by any existing module, that's where `/domain-extend` comes in — as described above.

This creates your project's **Domain Profile Instance** — stored in `sdd-state.md`. As you define Features through the Brief, your domain-specific decisions (auth strategy, protocol choices, error handling approach) are recorded in a dedicated `domain-profile-instance.md` file. This separation matters: the *module files* define what to ask; the *Instance file* records what you answered. Feature 2 can look up Feature 1's auth decisions without parsing spec documents.

**3. Brief — Structured Feature intake**

Instead of "add auth," you go through a structured consultation:

1. What does this Feature do? *(scope)*
2. Who uses it? *(actors)*
3. What data does it touch? *(entities)*
4. What happens when things go wrong? *(error paths)*
5. How does it interact with existing Features? *(dependencies)*

This takes 2 minutes instead of 2 seconds. The payoff is that every downstream artifact — spec, plan, implementation — is grounded in explicit decisions, not assumptions.

These three concepts reinforce each other. Domain Profile injects **domain-specific questions** into the Brief — if your project has an `auth` concern, the Brief automatically asks "What auth strategy?" If `realtime` is active, it asks "What happens on disconnect?" The richer your Domain Profile, the deeper your Briefs. And when `/domain-extend` adds a new module, its questions make the *next* Brief smarter. GEL remembers, Domain Profile shapes, Brief validates — and domain-extend grows the vocabulary that drives all three.

---

## Real-World Scenarios

Here's how actual users interact with the system:

**"I have an idea and want to build it"**

```
/smart-sdd init "build a chat app with AI providers"
/smart-sdd add "multi-provider LLM chat with streaming"
/smart-sdd pipeline F001
```

The pipeline runs: specify → plan → tasks → implement → verify. At each stage, you review and approve. The agent can't skip steps.

**"I have existing code and want to understand it"**

```
/code-explore /path/to/opencode
/code-explore trace "how does context window management work"
/code-explore trace "how does the provider abstraction handle streaming"
/code-explore synthesis
```

You get: architecture maps, flow traces with Mermaid diagrams, entity/API inventories, and Feature candidates you can feed into the SDD pipeline.

**"I want to rebuild an existing app from scratch"**

```
/reverse-spec /path/to/legacy-app
/smart-sdd init --from-reverse-spec
/smart-sdd pipeline
```

Reverse-spec extracts the roadmap, registries, and constitution from the existing code. Smart-sdd uses those as the foundation for a clean rebuild.

**"I want to add SDD documentation to code I already have"**

```
/smart-sdd adopt /path/to/existing-app
```

Adoption mode wraps your existing code with spec.md, plan.md, and tasks.md — without rewriting anything.

---

## What Makes This Different

There are plenty of "prompt libraries" and "AI workflow tools." Here's what's different about this approach:

**It's files, not memory.** Every decision, every registry, every spec lives in your repo. You can `git diff` the agent's work. You can edit the spec and re-run. You can switch sessions and nothing is lost.

**It enforces, not suggests.** HARD STOP gates require your explicit approval. The agent literally cannot proceed without your response. This isn't a "best practice" — it's a blocking gate.

**It adapts to your domain.** 48 concern modules, 15 archetypes, 40+ framework foundations. The verification rules for an Electron app are different from a Django server. This isn't a generic checklist.

**It composes.** Use code-explore alone to study a codebase. Use smart-sdd alone for greenfield. Use all four together for a full rebuild. Each skill works independently; together they form a pipeline.

---

## For Humans / For Agents

> This article series has an unusual structure: each part has two sections.
>
> **"For Humans"** (what you've been reading) explains the concepts in plain language with stories and examples.
>
> **"For Agents"** (below) presents the same information in a structured format that an AI agent can directly consume — with explicit rules, file paths, and decision trees.
>
> Why? Because spec-kit-skills is fundamentally about the interface between humans and AI agents. The same concept needs two representations: one that builds intuition, and one that drives behavior. This dual structure is itself a demonstration of the project's core philosophy.
>
> Try it: copy the "For Agents" section below and paste it into a Claude Code conversation. See what happens.

---

## 🤖 For Agents — Structured Summary

```
project: spec-kit-skills
version: 0.1.0
repository: https://github.com/coolhero/spec-kit-skills

purpose:
  Harness Engineering for AI coding agents.
  Structured control over explore → specify → plan → implement → verify pipeline.

skills:
  code-explore:
    trigger: /code-explore
    commands: orient, trace, synthesis, status
    output: specs/explore/
    concept: Understand before you build

  reverse-spec:
    trigger: /reverse-spec
    output: specs/reverse-spec/
    concept: Source code → structured specs

  smart-sdd:
    trigger: /smart-sdd
    commands: init, add, pipeline, adopt, status, coverage, parity, expand, reset
    output: specs/
    concept: Every Feature knows about every other Feature

  domain-extend:
    trigger: /domain-extend
    commands: create, import, validate
    output: domains/ (new concern, archetype, or foundation modules)
    concept: Grow the domain vocabulary when existing modules don't cover your patterns

core concepts:
  GEL: Cross-Feature memory in files (entity-registry, api-registry, sdd-state)
  Domain Profile: 5 axes (Interface, Concern, Archetype, Foundation, Context)
  Brief: 6-step structured Feature intake

enforcement:
  HARD STOPs: explicit user approval at every checkpoint
  Pipeline Guards: 7 blocking checks that prevent progression
  Empty response: always re-ask, never proceed on silence

scenarios:
  greenfield: init → add → pipeline
  rebuild: reverse-spec → init --from-reverse-spec → pipeline
  adoption: adopt
  exploration: code-explore → init --from-explore
```

---

*This article was written using Claude Code (Claude Opus 4.6). The entire spec-kit-skills project, including this series, was developed through human-AI collaboration — the human designs the harness, the AI operates within it.*

---

📖 **Want the complete reference?** Download the [Technical Reference Manual (114 pages, PDF)](https://github.com/coolhero/spec-kit-skills/releases/download/v0.2.0/spec-kit-skills-technical-reference-en.pdf) — covers everything from design philosophy to module schemas to failure patterns.

**Series Navigation:**

→ **Part 2**: [Four Skills, One Pipeline](https://medium.com/@thejihoonchoi/four-skills-one-pipeline-how-code-explore-reverse-spec-smart-sdd-and-domain-extend-work-cfc33edf249d) — deep dive into each skill with step-by-step walkthroughs

→ **Part 3**: [400 Markdown Files That Think](https://medium.com/@thejihoonchoi/400-markdown-files-that-think-the-architecture-of-spec-kit-skills-50047f0ecd1f) — design philosophy, file structure, extensibility

→ **Part 4**: [Failure Patterns and Hard-Won Wisdom](https://medium.com/@thejihoonchoi/building-skills-for-ai-agents-failure-patterns-tips-and-hard-won-wisdom-507f3137a538) — 19 gap patterns, 50+ lessons, practical tips
