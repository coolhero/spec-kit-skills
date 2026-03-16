# Architecture & Extensibility Guide

> Detailed reference for understanding and extending the spec-kit-skills modular domain architecture.
> For a high-level overview, see [README.md](README.md) § Architecture.

---

## Table of Contents

1. [Module System Overview](#1-module-system-overview)
2. [4-Axis Domain Composition](#2-4-axis-domain-composition)
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

---

## 2. 4-Axis Domain Composition

The domain composition system has 4 orthogonal axes. Each axis answers a different question:

```
                    ┌─────────────────────────────┐
                    │      Project Domain          │
                    │                               │
  INTERFACE ────────┤  What does the app expose?    │──── http-api, gui, cli, data-io
                    │                               │
  CONCERN ──────────┤  What cross-cutting patterns? │──── auth, async-state, ipc, i18n, realtime
                    │                               │
  ARCHETYPE ────────┤  What domain philosophy?      │──── ai-assistant, public-api, microservice
                    │                               │
  SCENARIO ─────────┤  Why are we building?         │──── greenfield, rebuild, incremental, adoption
                    └─────────────────────────────┘
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

## 3. Adding a New Interface

Interfaces define the app's external surface — the protocol through which users or systems interact.

### When to Add

Add a new interface when a project has a distinct interaction surface not covered by existing interfaces (gui, http-api, cli, data-io).

### Steps

1. **Create reverse-spec module**: `.claude/skills/reverse-spec/domains/interfaces/{name}.md`
   - Add R1 (Detection Signals) and R3 (Analysis Axes)
   - R1: file patterns and code patterns that indicate this interface
   - R3: what to extract during analysis (e.g., for `graphql`: schema extraction, resolver patterns, subscription patterns)

2. **Create smart-sdd module**: `.claude/skills/smart-sdd/domains/interfaces/{name}.md`
   - Add S0 (Signal Keywords), S1 (SC Generation Rules), S5 (Elaboration Probes), S8 (Runtime Verification)
   - S0: keywords for auto-detection during `init` Proposal Mode
   - S1: required SC patterns and anti-patterns for this interface
   - S5: domain-specific consultation questions
   - S8: how to start, verify, and stop runtime testing for this interface

3. **Update _schema.md** (both skills): No changes needed — existing schema supports new interfaces automatically.

4. **Update profiles**: If the new interface should be part of a profile (e.g., `web-api` might include `graphql`), update the profile manifest.

5. **Test**: Run through an init → specify flow with a project that uses this interface. Verify S0 keywords trigger detection and S1 rules produce meaningful SCs.

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

1. **Create reverse-spec module**: `.claude/skills/reverse-spec/domains/concerns/{name}.md`
   - Add R1 (Detection Signals): libraries, code patterns, config files

2. **Create smart-sdd module**: `.claude/skills/smart-sdd/domains/concerns/{name}.md`
   - Add S0, S1, S5, S7 (optional: S3 for verification overrides)

3. **Update profiles**: If the concern should be default for a profile, update the profile manifest.

### Examples of Potential New Concerns

- `caching` — Redis, in-memory cache, CDN cache invalidation patterns
- `file-storage` — S3, local filesystem, upload handling, CDN integration
- `notifications` — Push notifications, email, SMS, in-app notifications
- `search` — Elasticsearch, Algolia, full-text search patterns

---

## 5. Adding a New Archetype

Archetypes define application-domain philosophy — guiding principles that transcend framework and interface choices.

### When to Add

Add a new archetype when a class of applications has distinct philosophical principles that should guide architectural decisions. The key test: **do projects in this domain consistently need the same set of architectural principles regardless of their tech stack?**

### Steps

1. **Create reverse-spec module**: `.claude/skills/reverse-spec/domains/archetypes/{name}.md`
   - **A0**: Signal Keywords — libraries, code patterns, config files specific to this domain
   - **A1**: Analysis Axes — Philosophy Extraction — what principles to look for in the code

2. **Create smart-sdd module**: `.claude/skills/smart-sdd/domains/archetypes/{name}.md`
   - **A0**: Signal Keywords — Primary (high-confidence) and Secondary (needs confirmation)
   - **A1**: Philosophy Principles — the core domain principles (name, description, implication)
   - **A2**: SC Generation Extensions — domain-specific SC patterns and anti-patterns
   - **A3**: Elaboration Probes — domain-specific consultation questions
   - **A4**: Constitution Injection — principles to embed in the project's constitution

3. **No schema/resolver changes needed** — the archetype loading system is generic.

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

### TODO Scaffold Pattern

For frameworks not yet fully documented, use a TODO scaffold (only F0 and F1 filled, rest marked TODO). This is intentional — see CLAUDE.md § Do NOT Modify #2. Examples: `nestjs.md`, `fastapi.md`.

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
- Fill F0–F4 for all Foundation files (currently: nestjs, fastapi, react-native, flutter are TODO)

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

1. Fill `nestjs.md` and `fastapi.md` Foundation files (currently TODO scaffolds)
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
| **Foundation schema (F0–F7)** | `reverse-spec/domains/foundations/_foundation-core.md` |
| **State file format** | `smart-sdd/reference/state-schema.md` |
| **Signal keywords (S0/A0)** | `smart-sdd/reference/clarity-index.md` § 5, `smart-sdd/domains/_resolver.md` § S0/A0 Aggregation |
| **Constitution flow** | `reverse-spec/commands/analyze.md` § Phase 4-1, `reverse-spec/templates/constitution-seed-template.md`, `smart-sdd/commands/pipeline.md` § Phase 0, `smart-sdd/reference/injection/constitution.md` |
| **Profile resolution** | `smart-sdd/domains/_resolver.md` § Step 2, `smart-sdd/domains/profiles/*.md` |
| **Archetype resolution** | `smart-sdd/domains/_resolver.md` § Step 2c, `smart-sdd/reference/state-schema.md` § Archetype field |
| **Foundation resolution** | `smart-sdd/domains/_resolver.md` § Step 2b, `reverse-spec/domains/foundations/_foundation-core.md` § F2 |
