# Architecture & Extensibility Guide

> Detailed reference for understanding and extending the spec-kit-skills modular domain architecture.
> For a high-level overview, see [README.md](README.md) § Architecture.

---

## Table of Contents

1. [Module System Overview](#1-module-system-overview)
   - [Signal Keywords: Shared Architecture](#signal-keywords-shared-architecture)
2. [4-Axis Domain Composition](#2-4-axis-domain-composition)
2b. [How Composed Modules Drive the Pipeline](#2b-how-composed-modules-drive-the-pipeline)
3. [Adding a New Interface](#3-adding-a-new-interface)
4. [Adding a New Concern](#4-adding-a-new-concern)
5. [Adding a New Archetype](#5-adding-a-new-archetype)
6. [Adding a New Foundation](#6-adding-a-new-foundation)
7. [Adding a New Profile](#7-adding-a-new-profile)
8. [Adding a New Scenario](#8-adding-a-new-scenario)
9. [Sophistication Levels](#9-sophistication-levels)
10. [API Server Refinement Example](#10-api-server-refinement-example)
11. [Cross-Reference Map](#11-cross-reference-map)

---

## 1. Module System Overview

spec-kit-skills uses a **modular domain architecture** where project-specific behavior is composed from small, focused module files. Each module contributes rules, probes, and constraints that shape how the SDD pipeline operates for a given project.

### Dual-Skill Architecture

Every module type exists in **two skills** with complementary roles:

| Skill | Purpose | Section Schema | Module Role |
|-------|---------|---------------|-------------|
| **reverse-spec** | Analysis (extract from existing code) | R1–R6 (interfaces/concerns), A0–A1 (archetypes) | Detection signals, extraction axes, philosophy extraction |
| **smart-sdd** | Execution (build new/rebuilt code) | S0–S8 (interfaces/concerns), A0–A4 (archetypes) | SC generation, elaboration probes, verification, constitution injection |

When adding a new module, you create files in **both** skills — they have different section schemas but cover the same domain concept.

### Module Loading

Modules are loaded at skill invocation based on the project's `sdd-state.md` configuration. The **resolver** (`smart-sdd/domains/_resolver.md`) reads the state file and loads modules in a defined order:

```
1. _core.md                    (ALWAYS — universal rules)
2. interfaces/{name}.md        (for EACH listed interface)
3. concerns/{name}.md          (for EACH listed concern)
4. archetypes/{name}.md        (for EACH listed archetype)
5. scenarios/{scenario}.md     (ONE scenario)
6. domain-custom.md            (if specified)
```

Later modules extend earlier ones. Merge rules vary by section — see `_schema.md` in each skill for details.

### Signal Keywords: Shared Architecture

Signal keywords (S0/A0 for init inference, R1/A0 for source analysis) are **shared across skills** — they live in a single location rather than being duplicated in each skill's domain modules.

```
.claude/skills/shared/domains/          ← Cross-skill shared resources (NOT a skill)
├── _taxonomy.md                        ← Module registry (single source of truth)
├── _TEMPLATE.md                        ← Contributor template for new modules
├── interfaces/{name}.md                ← S0 (semantic) + R1 (code patterns) per interface
├── concerns/{name}.md                  ← S0 (semantic) + R1 (code patterns) per concern
└── archetypes/{name}.md                ← A0 (semantic + code patterns) per archetype
```

Each shared module file contains:
- **Semantic keywords (S0/A0)** — used by `smart-sdd init` for Proposal Mode signal extraction. Matched via the [Matching Algorithm](smart-sdd/reference/clarity-index.md) (case-insensitive, compound-first, whole-token-only).
- **Code pattern keywords (R1/A0)** — used by `reverse-spec` for source code analysis and module auto-detection.

**How skill modules reference shared keywords**: Each skill-local domain module (e.g., `smart-sdd/domains/concerns/auth.md`) replaces its S0/R1 section with a cross-reference:
```
> See [shared/domains/concerns/auth.md](../../../shared/domains/concerns/auth.md) § Signal Keywords
```

This ensures a **single source of truth** — keyword updates in `shared/` automatically apply to both skills.

**When adding a new module**, create **3 files** (not 2):
1. `shared/domains/{type}/{name}.md` — Signal keywords (S0/R1 or A0)
2. `reverse-spec/domains/{type}/{name}.md` — R3–R7 analysis sections (reference shared/ for R1)
3. `smart-sdd/domains/{type}/{name}.md` — S1–S8 execution sections (reference shared/ for S0)

See `shared/domains/_TEMPLATE.md` for the contributor template and `shared/domains/_taxonomy.md` for the complete module registry.

---

## 2. 4-Axis Domain Composition

The domain composition system has 4 orthogonal axes. Each axis answers a different question:

```
                    ┌─────────────────────────────────┐
                    │       Project Domain            │
                    │                                 │
  INTERFACE ────────┤  What does the app expose?      │──── http-api, gui, cli, data-io
                    │                                 │
  CONCERN ──────────┤  What cross-cutting patterns?   │──── auth, async-state, ipc, i18n, realtime
                    │                                 │
  ARCHETYPE ────────┤  What domain philosophy?        │──── ai-assistant, public-api, microservice
                    │                                 │
  SCENARIO ─────────┤  Why are we building?           │──── greenfield, rebuild, incremental, adoption
                    └─────────────────────────────────┘
```

### How the Axes Differ

| Axis | Defines | Example |
|------|---------|---------|
| **Interface** | The _surface_ — how users or systems interact | HTTP API defines endpoints, status codes, request/response shapes |
| **Concern** | The _mechanism_ — internal cross-cutting patterns | Auth defines authentication flows, token management, session handling |
| **Archetype** | The _philosophy_ — domain-specific guiding principles | AI Assistant defines Streaming-First, Model Agnosticism, Token Awareness |
| **Scenario** | The _context_ — why this project exists | Rebuild defines preservation rules, migration gates, parity checks |

### Composition Example

An AI-powered desktop app being rebuilt:

```
Profile:    desktop-app
Interfaces: [gui]
Concerns:   [async-state, ipc]
Archetype:  ai-assistant
Scenario:   rebuild
Framework:  electron
```

This loads 6 domain modules + 2 Foundation files = 8 file reads, all cached for the session.

### Why Archetype Was Added (3-Axis → 4-Axis)

The original 3-Axis model (Interface × Concern × Scenario) covered _what_ the app exposes, _how_ it handles cross-cutting patterns, and _why_ it's being built. But it lacked structured guidance for _domain-specific philosophy_.

**Before (3-Axis)**: When reverse-spec analyzed an AI desktop app, it generated principles like "Streaming-First" and "Model Agnosticism" ad-hoc in the constitution-seed. These principles were valuable but unstandardized — different analysis runs might extract different principles with different names.

**After (4-Axis)**: Archetype modules provide a structured vocabulary of domain principles. The `ai-assistant` archetype defines exactly which principles to extract (A1), how they affect SC generation (A2), what questions to ask during consultation (A3), and what to inject into the constitution (A4). This makes domain philosophy **reusable, consistent, and extensible**.

---

## 2b. How Composed Modules Drive the Pipeline

> The previous section explains *what* gets composed. This section explains *what the composition produces* and *how it shapes each pipeline step*.

### The Core Mechanism

Domain modules are **not** compiled into an output file. They are loaded into the agent's working memory at session start and act as **behavioral modifiers** — each S-section tells the agent to do something *additional* or *different* at a specific pipeline step.

Think of it like CSS for a pipeline: modules cascade, merge, and the combined rules "style" each step's behavior.

```
┌─────────────────────────────────────────────────────────────┐
│                    Module Loading (once)                    │
│                                                             │
│  _core.md → gui.md → async-state.md → ipc.md                │
│           → ai-assistant.md → rebuild.md                    │
│           → electron.md (Foundation)                        │
│                                                             │
│  Result: Merged ruleset cached in agent working memory      │
└──────────────────────────┬──────────────────────────────────┘
                           │
         Each S/A/F section routes to a pipeline step
                           │
    ┌──────────┬──────────┬┴─────────┬───────────┬──────────┐
    ▼          ▼          ▼          ▼           ▼          ▼
 specify     plan      tasks    implement    verify    parity
```

### Section → Pipeline Step Mapping

Every section from every module routes to a specific pipeline step. This is the complete mapping:

| Section | What It Contains | Pipeline Step | How It Modifies Behavior |
|---------|-----------------|---------------|--------------------------|
| **S0** | Signal Keywords | `init` | Auto-detects which modules to activate from user's project description |
| **S1** | SC Generation Rules | `specify` | Adds mandatory Success Criteria patterns; rejects anti-patterns |
| **S2** | Parity Dimensions | `parity` | Defines structural/logic comparison axes (old vs new) |
| **S3** | Verify Steps | `verify` | Adds/extends verification gates (test, build, lint, demo + module-specific) |
| **S5** | Elaboration Probes | `specify` (clarify) | Adds domain-specific questions during Feature consultation |
| **S6** | UI Testing Strategy | `verify` Phase 2-3 | Defines how to test UI rendering (Playwright, screenshots) |
| **S7** | Bug Prevention Rules | `plan` / `analyze` / `implement` / `verify` | Activates stage-specific checks (split into B-1, B-2, B-3, B-4) |
| **S8** | Runtime Verification | `verify` Phase 2-3 | Defines how to start, probe, and stop the running app |
| **A1** | Philosophy Principles | `constitution` | Injects domain guiding principles (e.g., "Streaming-First") |
| **A2** | SC Extensions | `specify` | Adds archetype-specific SC patterns (appended to S1) |
| **A3** | Probes | `specify` (clarify) | Adds archetype-specific questions (appended to S5) |
| **A4** | Constitution Injection | `constitution` | Embeds actionable principles into project constitution |
| **F2** | Foundation Checklist | `pipeline` Phase 0 | Creates T0 infrastructure Features from framework decisions |
| **F7** | Framework Philosophy | `constitution` | Adds framework-specific principles (e.g., Electron process model) |
| **F8** | Toolchain Commands | `verify` Phase 1 | Overrides auto-detected build/test/lint commands |
| **F9** | Scan Targets | `reverse-spec` Phase 2 | Adds framework-specific extraction patterns (decorators, models) |

### Concrete Walkthrough: Step by Step

Using the `desktop-app + ai-assistant + rebuild + electron` example, here is exactly what changes at each pipeline step:

#### 1. `constitution` — What gets injected into the project's constitution

| Source | Contribution |
|--------|-------------|
| **A1** (ai-assistant) | Principles: Streaming-First, Model Agnosticism, Offline Resilience, Token Awareness, Prompt Versioning |
| **A4** (ai-assistant) | Actionable rules: "Never call provider SDKs directly from business logic" |
| **F7** (electron) | Framework principles: Process Crash Isolation, Secure by Default, Web Standards First |

Without modules: constitution contains only user-provided and spec-kit default principles.
With modules: constitution embeds **12+ domain-specific principles** that guide all downstream decisions.

#### 2. `specify` — How Feature specs are shaped

| Source | Contribution |
|--------|-------------|
| **S1** (_core) | Base SC rules: every Feature needs testable SCs with clear pass/fail |
| **S1** (gui) | +UI SCs: interaction SCs must specify user action → visual result |
| **S1** (async-state) | +State SCs: async operations must have loading/error/success states |
| **S1** (ipc) | +IPC SCs: cross-process calls must specify channel, payload, response |
| **S1** (rebuild) | +Preservation SCs: must verify original behavior is maintained |
| **A2** (ai-assistant) | +AI SCs: streaming responses must handle partial/complete/error states |
| **S5** (all modules) | Combined probes: 30+ questions across auth, CRUD, routing, UI, IPC, streaming, model selection, preservation |

Without modules: specify generates generic SCs like "user can log in."
With modules: specify generates **precise, domain-aware SCs** like "User sends a message → streaming response renders token-by-token in the chat panel (loading indicator during first-token latency) → response completes → chat history persists across app restart."

#### 3. `plan` — Bug prevention during architecture design

| Source | Contribution |
|--------|-------------|
| **S7 B-1** (_core) | Runtime Compatibility, Async & Concurrency, Dependency Safety |
| **S7 B-1** (gui) | +UI anti-patterns: CSS rendering traps, component lifecycle issues |
| **S7 B-1** (ipc) | +IPC anti-patterns: serialization boundaries, process lifecycle |

Without modules: plan checks for generic runtime issues.
With modules: plan **proactively flags** IPC serialization boundary issues, CSS theme token mapping gaps, and Electron process model violations.

#### 4. `implement` — Conditional bug checks during coding

| Source | Contribution |
|--------|-------------|
| **S7 B-3** (_core) | Cross-Feature integration, data persistence, module-scope lifecycle |
| **S7 B-3** (gui) | +Platform CSS Rendering check, +UI Interaction Surface Audit |
| **S7 B-3** (ipc) | +IPC Boundary Safety, +IPC Return Value Defense |
| **S7 B-3** (async-state) | +Selector instability, +Unbatched updates, +UX behavior contract |

Without modules: implement runs generic safety checks.
With modules: implement **actively verifies** that every IPC handler validates return values, every CSS variable maps to the theme system, and every async selector is memoized.

#### 5. `verify` — Multi-phase verification

| Source | Contribution |
|--------|-------------|
| **S3** (_core) | Phase 1: test + build + lint (BLOCKING) |
| **S3** (rebuild) | +Migration regression gate, +Foundation compliance (S3d) |
| **S6** (gui) | Phase 2-3: Playwright UI testing — screenshot comparison, interaction testing |
| **S8** (gui) | Runtime strategy: how to start/stop the Electron app for testing |
| **F8** (electron) | Toolchain override: use Electron-specific build/test commands |

Without modules: verify runs test/build/lint and stops.
With modules: verify runs **5 phases** — test/build/lint → Playwright UI testing → demo script → migration parity check → Foundation compliance audit.

### The Merge Rule (How Conflicts Resolve)

When multiple modules contribute to the same section, the merge follows a simple rule:

```
Load order: _core → interfaces → concerns → archetypes → scenarios → custom

Merge behavior:
  S1 (SC Rules)        → APPEND  (accumulate all rules)
  S5 (Probes)          → APPEND  (accumulate all questions)
  S7 (Bug Prevention)  → APPEND  (accumulate all checks)
  S2 (Parity)          → APPEND  (add module-specific dimensions)
  S3 (Verify Steps)    → EXTEND  (later modules add steps; override only if explicit)
```

No conflicts arise because each module contributes **additive** domain knowledge. The `gui` module doesn't conflict with the `ipc` module — they add different rules to different domains.

### Summary: What Composition Actually Produces

```
Modules in:   [_core, gui, async-state, ipc, ai-assistant, rebuild, electron]
                                    │
                                    ▼
Merged output:  NOT a file — a behavioral ruleset in agent memory
                                    │
                    ┌───────────────┼───────────────┐
                    ▼               ▼               ▼
              SC Rules ×18    Probes ×30+     Bug Checks ×15
              (S1+A2)         (S5+A3)         (S7 B1-B4)
                    │               │               │
                    ▼               ▼               ▼
              Shapes          Shapes          Shapes
              specify         clarify         plan/impl/verify
```

The agent doesn't "generate" a composition artifact. It **behaves differently** at each step because the merged rules tell it: "when writing SCs, also check for IPC patterns" or "during verify, also run Playwright UI tests." The modules are invisible infrastructure — the user sees better specs, more thorough plans, and more reliable implementations.

---

## 3. Adding a New Interface

Interfaces define the app's external surface — the protocol through which users or systems interact.

### When to Add

Add a new interface when a project has a distinct interaction surface not covered by existing interfaces (gui, http-api, cli, data-io, tui).

### Steps

1. **Create shared signal module**: `.claude/skills/shared/domains/interfaces/{name}.md`
   - Add S0 (Semantic keywords) and R1 (Code patterns)
   - Use `shared/domains/_TEMPLATE.md` as the starting template
   - Register in `shared/domains/_taxonomy.md`

2. **Create reverse-spec module**: `.claude/skills/reverse-spec/domains/interfaces/{name}.md`
   - Reference shared/ for R1: `See [shared/domains/interfaces/{name}.md] § Signal Keywords`
   - Add R3 (Analysis Axes): what to extract during analysis (e.g., for `graphql`: schema extraction, resolver patterns)

3. **Create smart-sdd module**: `.claude/skills/smart-sdd/domains/interfaces/{name}.md`
   - Reference shared/ for S0: `See [shared/domains/interfaces/{name}.md] § Signal Keywords`
   - Add S1 (SC Generation Rules), S5 (Elaboration Probes), S8 (Runtime Verification)

4. **Update _schema.md** (both skills): No changes needed — existing schema supports new interfaces automatically.

5. **Update profiles**: If the new interface should be part of a profile (e.g., `web-api` might include `graphql`), update the profile manifest.

5. **Test**: Run through an init → specify flow with a project that uses this interface. Verify S0 keywords trigger detection and S1 rules produce meaningful SCs. For signal matching mechanics (case-insensitive, compound-first, whole-token-only), see [`clarity-index.md` § 3 Matching Algorithm](smart-sdd/reference/clarity-index.md).

### Section Checklist

| Section | reverse-spec | smart-sdd | Required? |
|---------|-------------|-----------|-----------|
| Detection/Signal | R1 | S0 | Yes |
| Analysis/SC Rules | R3 | S1 | Yes |
| Parity Dimensions | — | S2 | If the interface adds structural/logic parity dimensions |
| Elaboration Probes | — | S5 | Recommended |
| Bug Prevention | — | S7 | Recommended |
| Runtime Verification | — | S8 | Yes (for interfaces) |

---

## 4. Adding a New Concern

Concerns are internal cross-cutting patterns that affect multiple Features.

### When to Add

Add a new concern when a project has a recurring cross-cutting pattern not covered by existing concerns (auth, async-state, ipc, i18n, realtime, external-sdk).

### Steps

1. **Create shared signal module**: `.claude/skills/shared/domains/concerns/{name}.md`
   - Add S0 (Semantic keywords for init inference) and R1 (Code patterns for source analysis)
   - Use `shared/domains/_TEMPLATE.md` as the starting template
   - Register in `shared/domains/_taxonomy.md`

2. **Create reverse-spec module**: `.claude/skills/reverse-spec/domains/concerns/{name}.md`
   - Reference shared/ for R1: `See [shared/domains/concerns/{name}.md] § Signal Keywords`
   - Add R3–R7 analysis-specific sections

3. **Create smart-sdd module**: `.claude/skills/smart-sdd/domains/concerns/{name}.md`
   - Reference shared/ for S0: `See [shared/domains/concerns/{name}.md] § Signal Keywords`
   - Add S1, S5, S7 (optional: S3 for verification overrides)

4. **Update profiles**: If the concern should be default for a profile, update the profile manifest.

5. **Test**: Verify S0 keywords trigger module activation during `init` Proposal Mode. For matching mechanics, see [`clarity-index.md` § 3 Matching Algorithm](smart-sdd/reference/clarity-index.md).

### Existing Concern Modules

| Concern | Description | Key Patterns |
|---------|-------------|-------------|
| `auth` | Authentication flows, session management | Token lifecycle, OAuth, RBAC |
| `async-state` | Async data fetching, loading/error states | Race conditions, stale-while-revalidate |
| `ipc` | Inter-process communication (desktop apps) | Channel design, preload bridge, message serialization |
| `i18n` | Internationalization | Key coverage, locale fallback, RTL support |
| `realtime` | WebSocket, SSE, live data | Connection lifecycle, reconnection, state sync |
| `external-sdk` | Third-party SDK integration | SDK contract validation, version management |
| `protocol-integration` | LSP/MCP/custom protocol implementations | Message lifecycle, capability negotiation, transport abstraction |
| `plugin-system` | Plugin architecture patterns | Plugin lifecycle, isolation, API surface, versioning |
| `authorization` | RBAC/ABAC/ACL access control | Permission models, role hierarchy, policy enforcement |
| `message-queue` | Message broker / event bus patterns | Publish/consume lifecycle, DLQ, delivery guarantees, idempotency |
| `task-worker` | Background job / scheduled task patterns | Task dispatch, retry, timeout, periodic scheduling, worker lifecycle |

### Examples of Potential New Concerns

- `caching` — Redis, in-memory cache, CDN cache invalidation patterns
- `file-storage` — S3, local filesystem, upload handling, CDN integration
- `notifications` — Push notifications, email, SMS, in-app notifications
- `search` — Elasticsearch, Algolia, full-text search patterns

### Out of Scope (Future Extension)

- **`native-app` interface** — Pure native mobile/desktop apps (SwiftUI, Jetpack Compose, WinUI). The existing `gui` interface + `react-native`/`flutter` foundations cover cross-platform native, but pure native (Swift/Kotlin/C++ without JS bridge) requires a dedicated interface module for build systems (Xcode/Gradle), native UI testing (XCTest/Espresso), and platform-specific SC generation. The 4-axis composition model supports this extension without structural changes — only new module files are needed.

---

## 5. Adding a New Archetype

Archetypes define application-domain philosophy — guiding principles that transcend framework and interface choices.

### When to Add

Add a new archetype when a class of applications has distinct philosophical principles that should guide architectural decisions. The key test: **do projects in this domain consistently need the same set of architectural principles regardless of their tech stack?**

### Steps

1. **Create shared signal module**: `.claude/skills/shared/domains/archetypes/{name}.md`
   - **A0**: Signal Keywords — Semantic (for init inference) + Code Patterns (for source analysis)
   - Use `shared/domains/_TEMPLATE.md` as the starting template
   - Register in `shared/domains/_taxonomy.md`

2. **Create reverse-spec module**: `.claude/skills/reverse-spec/domains/archetypes/{name}.md`
   - Reference shared/ for A0: `See [shared/domains/archetypes/{name}.md] § Signal Keywords`
   - **A1**: Analysis Axes — Philosophy Extraction — what principles to look for in the code

3. **Create smart-sdd module**: `.claude/skills/smart-sdd/domains/archetypes/{name}.md`
   - Reference shared/ for A0: `See [shared/domains/archetypes/{name}.md] § Signal Keywords`
   - **A1**: Philosophy Principles — the core domain principles (name, description, implication)
   - **A2**: SC Generation Extensions — domain-specific SC patterns and anti-patterns
   - **A3**: Elaboration Probes — domain-specific consultation questions
   - **A4**: Constitution Injection — principles to embed in the project's constitution

4. **No schema/resolver changes needed** — the archetype loading system is generic.

4. **Test**: Run `init` with an idea string containing A0 keywords. Verify the archetype is auto-detected.

### Archetype Design Principles

- **3–5 philosophy principles** per archetype (A1) — too few is shallow, too many dilutes focus
- **Principles should be non-obvious** — "write tests" is universal, "streaming is the default delivery mode" is archetype-specific
- **Each A2 SC pattern should cite an A1 principle** — SC rules flow from philosophy
- **A4 constitution injection should be actionable** — "model agnosticism" is vague; "never call provider SDKs directly from business logic" is actionable

### Examples of Potential New Archetypes

- `saas-platform` — Multi-tenancy, Tenant Isolation, Subscription Lifecycle, Usage Metering
- `real-time-collaboration` — Conflict Resolution (CRDT/OT), Presence Awareness, Offline-First
- `iot-gateway` — Device Lifecycle, Telemetry Pipeline, Firmware Updates, Connection Management
- `developer-tool` — Extensibility (plugins/hooks), Configuration as Code, Backward Compatibility

---

## 6. Adding a New Foundation

Foundations capture framework-specific infrastructure decisions made before business Features begin.

### When to Add

Add a new Foundation when a framework has enough opinionated infrastructure decisions (typically 30+) that benefit from a structured checklist.

### Steps

1. **Create Foundation file**: `.claude/skills/reverse-spec/domains/foundations/{name}.md`
   - **F0**: Detection Signals (auto-detection during profile resolution)
   - **F1**: Framework Category Taxonomy (which F1 categories from `_foundation-core.md` apply, plus framework-specific categories)
   - **F2**: Foundation Checklist (the actual items — ID, item, decision needed, priority)
   - **F3**: Extraction Rules (how to detect existing decisions from code)
   - **F4**: T0 Feature Grouping (how Foundation items map to T0 Features)
   - **F7**: Framework Philosophy (optional — guiding principles the framework advocates)
   - **F8**: Toolchain Commands (optional — build/test/lint/typecheck commands the pipeline reads for automation)
   - **F9**: Scan Targets (optional — framework-specific patterns for reverse-spec Phase 2 data model/API extraction)

2. **Update `_foundation-core.md`**: Add a row to the F6 Framework Files table.

3. **Test**: Run reverse-spec on a project using this framework. Verify Foundation items are detected and grouped into T0 Features.

### F8 Toolchain Commands

F8 lets a Foundation file declare the exact build/test/lint commands for its ecosystem. When present, Foundation Gate and Verify Phase 1 use these commands instead of auto-detection. If F8 is absent, the pipeline falls back to npm/yarn/pnpm heuristics. See `_foundation-core.md` § F8 for the full field list.

### F9 Scan Targets

F9 lets a Foundation file declare framework-specific scan targets for reverse-spec Phase 2 analysis (data model extraction, API endpoint extraction, component patterns). These targets are MERGED with the universal scan targets in `_core.md` — no need to modify `_core.md` when adding a new framework. If F9 is absent, only universal targets apply. See `_foundation-core.md` § F9 for the format.

### Foundation Format Variants

Foundation files exist in two formats depending on framework maturity and item density:

| Format | When to Use | Sections | Example Files |
|--------|------------|----------|---------------|
| **Full** | Frameworks with 40+ decision items | F0, F1 (item counts), F2 (per-category item tables), F3, F4, F7, F8, F9 | `electron.md`, `express.md`, `nextjs.md` |
| **Compact** | Well-known frameworks where the agent has strong built-in knowledge | F0, F1, F2 (key items only), F7, F8, F9 | `hono.md`, `spring-boot.md`, `django.md`, `fastapi.md`, `nestjs.md` |

The compact format works because Foundation files guide **structured extraction** rather than teach the framework — the agent already has deep framework knowledge. Compact files typically run ~80-120 lines vs ~200+ for full files.

### TODO Scaffold Pattern

For frameworks not yet fully documented, use a TODO scaffold (only F0 and F1 filled, rest marked TODO). This is intentional — see CLAUDE.md § Do NOT Modify #2. Examples: `react-native.md`, `flutter.md`.

### Foundation Coverage by Language

Current Foundation coverage across languages and frameworks:

| Language | Frameworks Covered | Foundation File | Format |
|----------|-------------------|-----------------|--------|
| **JavaScript/TypeScript** | Express, NestJS, Next.js, Hono | `express.md`, `nestjs.md`, `nextjs.md`, `hono.md` | Full / Compact |
| **Python** | FastAPI, Django, Flask | `fastapi.md`, `django.md`, `flask.md` | Compact |
| **Java/Kotlin** | Spring Boot | `spring-boot.md` | Compact |
| **Go** | Chi, Gin | `go-chi.md` | Compact |
| **Rust** | Actix-web | `actix-web.md` | Compact |
| **Ruby** | Rails | `rails.md` | Compact |
| **PHP** | Laravel | `laravel.md` | Compact |
| **Elixir** | Phoenix | `phoenix.md` | Compact |
| **C#** | ASP.NET Core | `dotnet.md` | Compact |
| **Dart** | Flutter | `flutter.md` | TODO scaffold |
| **JS (Mobile)** | React Native | `react-native.md` | TODO scaffold |
| **JS (Desktop)** | Electron, Tauri | `electron.md`, `tauri.md` | Full |
| **JS (Frontend)** | Vite+React, Solid.js | `vite-react.md`, `solidjs.md` | Full / Compact |
| **JS (Runtime)** | Bun | `bun.md` | Compact |

When a project uses a framework not listed above, the **Generic Foundation Protocol** (Case B in `_foundation-core.md`) applies — universal categories are used with agent-supplemented probes.

### F7 Philosophy Guidelines

Only add F7 when the framework has strong opinions:
- Express: Minimal but with clear conventions → F7 warranted (Middleware Composition, Stateless Requests)
- Electron: Strong process model opinions → F7 warranted (Process Crash Isolation, Secure by Default)
- A purely un-opinionated library: skip F7

---

## 7. Adding a New Profile

Profiles are ~10-line manifests that compose interfaces and concerns into named configurations.

### Format

```markdown
# Profile: {name}

> {description}

interfaces: [{comma-separated list}]
concerns: [{comma-separated list}]

# Scenario is determined by sdd-state.md Origin field, not by profile.
```

### When to Add

Add a profile when a common project configuration (interface + concern combination) is used repeatedly. Profiles are convenience shortcuts — the same result can be achieved by specifying interfaces and concerns individually.

### Steps

1. Create `.claude/skills/smart-sdd/domains/profiles/{name}.md`
2. List the interfaces and concerns
3. Archetypes are **not** part of profiles — they are resolved separately (Step 2c in resolver)

### Existing Profiles

| Profile | Interfaces | Concerns |
|---------|-----------|----------|
| `desktop-app` | gui | async-state, ipc |
| `fullstack-web` | http-api, gui | async-state, auth, i18n |
| `web-api` | http-api | auth |
| `cli-tool` | cli | (none) |

---

## 8. Adding a New Scenario

Scenarios define pipeline behavior variations based on _why_ the project is being built.

### When to Add

Rarely. The four scenarios (greenfield, rebuild, incremental, adoption) cover most use cases. Only add a new scenario if the pipeline needs fundamentally different behavior for a new project context.

### Steps

1. Create `.claude/skills/smart-sdd/domains/scenarios/{name}.md`
2. Define which S-sections the scenario contributes (typically S1, S3, S5, S7)
3. Update `_resolver.md` if the scenario has special resolution rules

---

## 9. Sophistication Levels

Modules evolve through 5 levels of sophistication. This model helps prioritize improvement work.

### Level 1: Module Completeness

**Goal**: Every module has all required sections filled (not TODO scaffolds).

- Fill R1/R3 for all reverse-spec modules
- Fill S0/S1/S5/S8 for all smart-sdd interface modules
- Fill S0/S1/S5/S7 for all smart-sdd concern modules
- Fill A0–A4 / A0–A1 for all archetype modules
- Fill F0–F4 for all Foundation files (currently: react-native, flutter are TODO)

**Metric**: `(filled sections) / (total required sections)` across all modules.

### Level 2: Composition Intelligence

**Goal**: Define how modules interact when combined.

- Cross-module interaction rules (e.g., "when `http-api` + `public-api` are both active, S1 rate limit rules from `public-api` override generic `http-api` rules")
- Conflict resolution (e.g., "when `auth` concern + `public-api` archetype, prefer API key auth probes over session auth probes")
- Synergy amplification (e.g., "when `gui` + `ai-assistant`, add streaming UI rendering probes")

**Metric**: Number of documented cross-module interaction rules.

### Level 3: Pipeline Behavior Customization

**Goal**: Modules can modify pipeline step behavior (not just add content).

- Per-archetype verify behavior (e.g., `ai-assistant` adds token budget verification in verify Phase 2)
- Per-archetype specify behavior (e.g., `public-api` requires OpenAPI spec generation during specify)
- Conditional step injection (e.g., `microservice` adds contract testing step)

**Metric**: Number of pipeline steps with module-specific behavior variations.

### Level 4: Pattern Library

**Goal**: Modules provide reusable implementation patterns.

- Code snippet templates per interface/concern/archetype combination
- Architectural decision records (ADRs) for common decisions
- Common implementation anti-patterns with fixes

**Metric**: Number of documented patterns per module combination.

### Level 5: Evidence-Based Refinement

**Goal**: Real project data drives module improvements.

- Track which S1 rules catch real issues vs. produce noise
- Track which S5 probes produce useful answers vs. confusion
- Track which A1 principles are actually referenced during implementation
- Feed `skill-feedback.md` data back into module refinement

**Metric**: Module refinement cycles backed by project evidence.

---

## 10. API Server Refinement Example

This walkthrough demonstrates how the `web-api` interface + `public-api` archetype evolve through sophistication levels for an API server project.

### Starting Point (Level 0)

A project with `web-api` profile + `express` Foundation. Currently:
- `http-api.md` interface: basic S0/S1/S5/S8
- `express.md` Foundation: full F0–F4, now F7
- No archetype (Archetype: `"none"`)

### Level 1: Complete the Modules

1. Verify Foundation files for relevant frameworks are implemented (e.g., `nestjs.md`, `fastapi.md`, `spring-boot.md`)
2. Add `public-api` archetype to the project's sdd-state.md
3. Now the pipeline loads: `_core → http-api → auth → public-api → scenarios/greenfield`

### Level 2: Add Composition Intelligence

Define how `http-api` + `public-api` interact:
- `public-api` A2 SC rules **extend** (not replace) `http-api` S1 rules
- When both are active: rate limit SCs from `public-api` take precedence
- `auth` concern + `public-api`: shift probes from session-based to API key/OAuth

### Level 3: Pipeline Customization

- During `specify`: if `public-api` is active, require OpenAPI spec stub generation
- During `plan`: `public-api` adds API versioning decision to complexity tracking
- During `verify`: `public-api` adds contract test verification step
- During `implement`: `public-api` requires rate limit headers in every endpoint

### Level 4: Pattern Library

Document common patterns:
- "Express + public-api: API versioning via URL prefix" — code template + ADR
- "NestJS + public-api: Swagger auto-generation" — configuration template
- "Rate limiting with express-rate-limit" — middleware setup pattern
- "API key rotation" — implementation pattern

### Level 5: Evidence Feedback

After running `public-api` on 3+ real projects:
- Refine A0 keywords (which signals had false positives?)
- Adjust A2 SC rules (which rules caught real issues?)
- Update A3 probes (which questions produced useful answers?)
- Add new A1 principles discovered from real projects

---

## 11. Cross-Reference Map

Which files touch which concepts — use this when modifying a concept to find all affected files.

| Concept | Files |
|---------|-------|
| **Module loading order** | `smart-sdd/domains/_schema.md` § Loading Order, `smart-sdd/domains/_resolver.md` § Step 3, `reverse-spec/domains/_schema.md` § Loading Order |
| **Section schema (S0–S8)** | `smart-sdd/domains/_schema.md` § Section Schema |
| **Section schema (R1–R6)** | `reverse-spec/domains/_schema.md` § Section Schema |
| **Section schema (A0–A4)** | `smart-sdd/domains/_schema.md` § Archetype Section Schema, `reverse-spec/domains/_schema.md` § Archetype Section Schema |
| **Foundation schema (F0–F9)** | `reverse-spec/domains/foundations/_foundation-core.md` |
| **F8 Toolchain Commands** | `reverse-spec/domains/foundations/_foundation-core.md` § F8, `smart-sdd/commands/pipeline.md` § Foundation Gate Toolchain Pre-flight, `smart-sdd/commands/verify-phases.md` § Phase 1 |
| **F9 Scan Targets** | `reverse-spec/domains/foundations/_foundation-core.md` § F9, `reverse-spec/commands/analyze.md` § Phase 2 F9 Scan Target Loading |
| **Structure field** | `smart-sdd/reference/state-schema.md` § Structure, `smart-sdd/commands/pipeline.md` § Foundation Gate build, `smart-sdd/commands/verify-phases.md` § Phase 1 test/build |
| **State file format** | `smart-sdd/reference/state-schema.md` |
| **Signal keywords (S0/A0)** | `smart-sdd/reference/clarity-index.md` § 5, `smart-sdd/domains/_resolver.md` § S0/A0 Aggregation |
| **Constitution flow** | `reverse-spec/commands/analyze.md` § Phase 4-1, `reverse-spec/templates/constitution-seed-template.md`, `smart-sdd/commands/pipeline.md` § Phase 0, `smart-sdd/reference/injection/constitution.md` |
| **Profile resolution** | `smart-sdd/domains/_resolver.md` § Step 2, `smart-sdd/domains/profiles/*.md` |
| **Archetype resolution** | `smart-sdd/domains/_resolver.md` § Step 2c, `smart-sdd/reference/state-schema.md` § Archetype field |
| **Foundation resolution** | `smart-sdd/domains/_resolver.md` § Step 2b, `reverse-spec/domains/foundations/_foundation-core.md` § F2 |
| **S3b Lint Detection** | `smart-sdd/domains/_core.md` § S3b (language-specific lint tool priority), `smart-sdd/commands/verify-phases.md` § Phase 1 |
| **Message queue concern** | `reverse-spec/domains/concerns/message-queue.md` (R1 detection), `smart-sdd/domains/concerns/message-queue.md` (S0/S1/S5/S7), `smart-sdd/domains/_core.md` § B-3 (MQ-001, MQ-003) |
| **Task worker concern** | `reverse-spec/domains/concerns/task-worker.md` (R1 detection), `smart-sdd/domains/concerns/task-worker.md` (S0/S1/S5/S7), `smart-sdd/domains/_core.md` § B-3 (TW-002, TW-004) |
| **Foundation files (server)** | `reverse-spec/domains/foundations/{express,nestjs,fastapi,spring-boot,django,rails,flask,actix-web,go-chi,dotnet,laravel,phoenix,hono}.md` |
| **Foundation files (desktop)** | `reverse-spec/domains/foundations/{electron,tauri}.md` |
| **Foundation files (frontend)** | `reverse-spec/domains/foundations/{nextjs,vite-react,solidjs}.md` |
| **Foundation files (runtime)** | `reverse-spec/domains/foundations/{bun}.md` |
| **Foundation files (mobile)** | `reverse-spec/domains/foundations/{react-native,flutter}.md` (TODO scaffolds) |
| **Pipeline Integrity Guards** | `smart-sdd/reference/pipeline-integrity-guards.md` (7 guard patterns), `smart-sdd/reference/injection/implement.md` (Guards 1,2,5,6,7), `smart-sdd/reference/injection/plan.md` (Guard 7), `smart-sdd/reference/injection/analyze.md` (Guard 4), `smart-sdd/commands/verify-phases.md` (Guards 2,3,5,6), `reverse-spec/commands/analyze.md` (Guards 4,7) |
| **Component Tree flow** | `reverse-spec/commands/analyze.md` § Phase 2-7c, `reverse-spec/templates/pre-context-template.md` § Component Tree, `smart-sdd/reference/injection/plan.md` § Source Component Mapping, `smart-sdd/reference/injection/implement.md` § Source-First Implementation |
| **FR Element Decomposition** | `smart-sdd/reference/injection/analyze.md` § FR Element Decomposition, `smart-sdd/reference/pipeline-integrity-guards.md` § Guard 4b |
| **Data Round-trip Verification** | `smart-sdd/reference/injection/implement.md` § Data Persistence Round-Trip, `smart-sdd/reference/pipeline-integrity-guards.md` § Guard 2 Level 4 |
| **Data Lifecycle Paradigm Mapping** | `reverse-spec/commands/analyze.md` § Phase 2-7d, `reverse-spec/templates/pre-context-template.md` § Data Lifecycle Patterns, `smart-sdd/reference/injection/plan.md` § Data Lifecycle Mapping, `smart-sdd/reference/injection/implement.md` § Source Reference Injection (lifecycle compliance), `smart-sdd/reference/pipeline-integrity-guards.md` § Guard 7 |
| **Source Reference BLOCKING Gate** | `smart-sdd/reference/injection/implement.md` § Source Reference Injection (BLOCKING for rebuild+GUI), `smart-sdd/reference/pipeline-integrity-guards.md` § Guard 7 |
