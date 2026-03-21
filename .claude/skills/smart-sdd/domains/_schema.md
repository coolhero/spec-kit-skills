# Domain Module Schema (smart-sdd)

> Defines the section schema for domain modules in the **5-axis + 1 modifier** architecture.
> Every module (interface, concern, archetype, foundation, scenario) follows this schema. Omit sections that don't apply.
> For reverse-spec module sections (R1-R6), see `../reverse-spec/domains/_schema.md`.

---

## Domain Profile Model: 5 Axes + 1 Modifier

Domain Profile is a **first-class citizen** — a living context that actively influences every step of every skill.

### 5 Axes (rule producers)

Each axis contributes rules (S-sections or F-sections) that are merged and applied throughout the pipeline.

| Axis | Location | Purpose | Rule Sections |
|------|----------|---------|---------------|
| **Interface** | `interfaces/{name}.md` | What the app exposes to users/consumers | S0–S9 |
| **Concern** | `concerns/{name}.md` | Cross-cutting patterns that span multiple Features | S0–S9 |
| **Archetype** | `archetypes/{name}.md` | Domain philosophy — WHY certain decisions matter | A0–A5 |
| **Foundation** | `foundations/{name}.md` | Framework-specific rules, constraints, and toolchain | F0–F9 |
| **Scenario** | `scenarios/{name}.md` | Project lifecycle context (greenfield, rebuild, adoption) | S1, S3, S5, S7 |

### 1 Modifier (rule filter)

The modifier does not produce rules — it **adjusts the depth and rigor** of rules from the 5 axes.

| Modifier | Fields | Purpose | Effect |
|----------|--------|---------|--------|
| **Scale** | `project_maturity` × `team_context` | How big/serious is this project? | Dials rule depth up or down |

> **Axis vs Modifier**: An axis produces rules ("check for IPC timeout handling"). A modifier adjusts how strictly those rules apply ("in prototype mode, timeout SCs are optional").

### Archetype ↔ Concern Relationship

Archetypes and Concerns occupy different abstraction levels:

- **Concern**: *What* cross-cutting pattern to handle (e.g., realtime → WebSocket management)
- **Archetype**: *Why* certain patterns matter more (e.g., ai-assistant → streaming is non-negotiable because LLM responses are inherently streaming)

Archetypes **extend** Concern rules via A2 (SC extensions) and A3 (probes). They do NOT duplicate Concern rules — they add domain-specific emphasis. Example:
- `realtime` concern S1: "WebSocket SCs must cover reconnection"
- `ai-assistant` archetype A2: "Streaming SCs must cover token budget mid-stream" ← adds to realtime's S1

---

## Module Types

| Type | Location | Purpose |
|------|----------|---------|
| **Interface** | `interfaces/{name}.md` | What the app exposes (http-api, gui, cli, data-io, tui) |
| **Concern** | `concerns/{name}.md` | Cross-cutting patterns (async-state, ipc, external-sdk, i18n, realtime, auth, ...) |
| **Archetype** | `archetypes/{name}.md` | Domain philosophy — principles that transcend framework/interface choices (ai-assistant, public-api, microservice, sdk-framework) |
| **Foundation** | `../../reverse-spec/domains/foundations/{name}.md` | Framework-specific constraints and toolchain (React, Next.js, Electron, ...). For multi-language projects (Phase 1-2a), the Framework field stores comma-separated values (e.g., `pytorch,cmake,cuda`). Each Foundation is loaded independently per `_resolver.md` Step 2b. |
| **Scenario** | `scenarios/{name}.md` | Why we're building (greenfield, rebuild, incremental, adoption) |
| **Profile** | `profiles/{name}.md` | Preset composition of interfaces + concerns (~10 line manifest) |
| **Core** | `_core.md` | Universal rules loaded for ALL projects |

---

## Section Schema (S0–S9)

Every module uses the same section numbering. Omit sections that don't apply to the module type.

### S0. Signal Keywords (interfaces, concerns — optional)

Keywords that indicate this module should be activated. Used by Clarity Index signal extraction during `init` Proposal Mode. See `reference/clarity-index.md` § 5.

| Field | Description |
|-------|-------------|
| **Primary** | High-confidence keywords — strong indicator that this module is needed |
| **Secondary** | Medium-confidence keywords — needs user confirmation |

### S1. SC Generation Rules (interfaces, concerns)

Success Criteria patterns, anti-patterns, and measurability criteria for this module.

| Field | Description |
|-------|-------------|
| **Required SC patterns** | What every SC must include (e.g., status code + response shape for API) |
| **Anti-patterns** | Vague SC formulations to reject (e.g., "API responds correctly") |
| **Measurability criteria** | How to verify the SC is testable and automatable |

### S2. Parity Dimensions (interfaces — additions to _core)

Additional structural/logic parity dimensions when this interface is active.

| Field | Description |
|-------|-------------|
| **Structural dimensions** | Additional structural elements to compare |
| **Logic dimensions** | Additional behavioral elements to compare |

### S3. Verify Steps (concerns — additions or overrides to _core)

Additional verification steps when this module is active.

| Field | Description |
|-------|-------------|
| **Step name** | Identifier (e.g., `i18n-coverage`) |
| **Required** | Whether failure blocks the pipeline (`BLOCKING` or `optional`) |
| **Detection** | How to find/run the relevant tool |
| **Description** | What this step checks |

### S4. Data Integrity Principles (Universal — _core.md + extensible by concerns/scenarios)

Universal data engineering principles that apply to ALL projects. Defined in `_core.md` as S4a-S4c. Concerns and scenarios can extend with S4x subsections (e.g., `ipc.md` adds IPC N-Layer Completeness as S4 extension; `rebuild.md` adds S4d Source Deep Analysis).

| Sub-section | Scope | Description |
|-------------|-------|-------------|
| **S4a** | Universal | Data Authority (Single Source of Truth) — every persistent data entity has one authoritative source |
| **S4b** | Universal | Empty/Invalid Input Handling — no pipeline stage treats empty input as success |
| **S4c** | Universal | Data Pipeline Traceability — every processing stage is independently verifiable |
| **S4d** | Scenario (rebuild) | Source Feature Deep Analysis — 3-level source analysis (pipeline, UI, rendering) |
| **S4x** | Concern-specific | Extension point — concerns add concrete integrity patterns (e.g., IPC N-Layer) |

> **Note**: Adoption-specific behavior (verify treatment, injection framing, Feature status) is now in `scenarios/adoption.md` § Adoption-Specific Rules, not in S4.

### S5. Elaboration Probes (interfaces, concerns — additions to _core)

Domain-specific questions asked during the `add` command's consultation phase.

| Field | Description |
|-------|-------------|
| **Perspective** | Which base perspective (1–6) this probe extends |
| **Sub-domain** | Category within the perspective |
| **Probe questions** | Domain-specific elaboration questions |

### S6. UI Testing Integration (interfaces/gui.md only)

Guidance for automated UI verification during verify Phase 3.

| Field | Description |
|-------|-------------|
| **Feature type mapping** | Which Feature types get UI verification |
| **MCP tools mapping** | Which MCP tools map to verification actions |
| **SC verification flow** | How to translate SC items into automated test steps |

### S7. Bug Prevention Rules (interfaces, concerns)

Pattern compliance rules and anti-patterns to check during implementation.

| Field | Description |
|-------|-------------|
| **Rule name** | Short identifier |
| **Stage** | Which pipeline stage enforces it (plan, analyze, implement, verify) |
| **Reference** | Cross-reference to injection file where the rule is enforced |
| **Description** | What the rule checks |

### S8. Runtime Verification Strategy (interfaces only)

Interface-specific runtime verification configuration. Cross-references [reference/runtime-verification.md](../reference/runtime-verification.md).

| Field | Description |
|-------|-------------|
| **Start method** | How to start the app/server/process for verification |
| **Verify method** | How to verify runtime behavior (backend type + approach) |
| **Stop method** | How to clean up after verification |
| **SC classification extensions** | Interface-specific SC auto-categories (e.g., `api-auto` for http-api) |

### S9. Brief Completion Criteria (interfaces, concerns — additions to _core)

Domain-specific minimum requirements for the **Briefing** process (`/smart-sdd add` Phase 1). When this module is active, the Brief is not considered complete until these criteria are met in addition to the base six-perspective completion criteria from `reference/feature-elaboration-framework.md`.

| Field | Description |
|-------|-------------|
| **Required elements** | Domain-specific items that must be present in the Brief (e.g., "at least one endpoint for http-api") |
| **Completion signal** | How to confirm the element is sufficiently defined (e.g., "method + path + purpose stated") |

> S9 criteria are checked during `add` Phase 1 Elaboration (1c) alongside the base six perspectives.
> If a criterion is not met, the agent asks targeted S5 probes to fill the gap before proceeding.

---

## Archetype Section Schema (A0–A5)

Archetype modules use a separate section numbering (A-prefix) to avoid collision with S0–S9. Archetypes define application-domain philosophy — principles that transcend framework and interface choices. While an Interface says _what_ the app exposes and a Concern says _how_ it handles cross-cutting patterns, an Archetype says _why_ certain architectural decisions matter for this domain.

> **Multi-Archetype Support**: A project may activate multiple archetypes (comma-separated, e.g., `ai-assistant,sdk-framework`). When multiple archetypes are active, their sections are merged using **append semantics** — A1 principles accumulate, A2 SC extensions accumulate, A3 probes accumulate, A4 constitution injections accumulate, A5 Brief criteria accumulate. No deduplication is performed; if two archetypes produce overlapping rules, both are kept (the more specific one wins at execution time). See `_resolver.md` § Step 2c for the resolution order.

### A0. Signal Keywords (archetypes)

Keywords that indicate this archetype should be activated. Used by Clarity Index signal extraction during `init` Proposal Mode alongside S0 keywords. See `reference/clarity-index.md` § 5.

| Field | Description |
|-------|-------------|
| **Primary** | High-confidence keywords — strong indicator that this archetype applies |
| **Secondary** | Medium-confidence keywords — needs user confirmation |

### A1. Philosophy Principles (archetypes)

Core architectural principles this archetype embodies. These are domain-specific guiding principles that inform every architectural decision in the project.

| Field | Description |
|-------|-------------|
| **Principle name** | Short identifier (e.g., "Streaming-First", "Contract Stability") |
| **Description** | What the principle means in practice |
| **Implication** | How this affects SC generation, implementation, and verification |

### A2. SC Generation Extensions (archetypes)

Archetype-specific Success Criteria patterns that augment S1 rules from interfaces/concerns.

| Field | Description |
|-------|-------------|
| **Required SC patterns** | Domain-specific SC requirements (e.g., "AI SCs must specify token budget") |
| **Anti-patterns** | Domain-specific vague SC formulations to reject |

### A3. Elaboration Probes (archetypes)

Domain-specific questions asked during the `add` command's consultation phase, extending S5 probes.

| Field | Description |
|-------|-------------|
| **Sub-domain** | Category within the archetype's domain |
| **Probe questions** | Archetype-specific elaboration questions |

### A4. Constitution Injection (archetypes)

Principles to inject into the constitution-seed during reverse-spec analysis and into the constitution during smart-sdd pipeline Phase 0.

| Field | Description |
|-------|-------------|
| **Principle** | Constitution-level principle statement |
| **Rationale** | Why this principle is critical for this archetype |

### A5. Brief Completion Criteria (archetypes)

Archetype-specific minimum requirements for the **Briefing** process (`/smart-sdd add` Phase 1). When this archetype is active, the Brief must satisfy these criteria in addition to base and interface/concern criteria.

| Field | Description |
|-------|-------------|
| **Required elements** | Archetype-specific items that must be present in the Brief (e.g., "model provider strategy for ai-assistant") |
| **Completion signal** | How to confirm the element is sufficiently defined |

> A5 criteria extend S9 criteria. Checked during `add` Phase 1 Elaboration (1c).

---

## Profile Schema

Profiles are pure manifests (~10 lines) that compose interfaces and concerns:

```markdown
# Profile: {name}

> {description}

interfaces: [{comma-separated list}]
concerns: [{comma-separated list}]

# Scenario is determined by sdd-state.md Origin field, not by profile.
```

---

## Loading Order

Defined in `_resolver.md`. Modules are loaded in this order:

```
1. _core.md                              (ALWAYS — universal rules)
2. interfaces/{interface}.md             (for EACH listed interface)
3. concerns/{concern}.md                 (for EACH listed concern)
4. archetypes/{archetype}.md             (for EACH listed archetype)
5. {Org convention path}                 (if specified — organization-level shared conventions)
6. scenarios/{scenario}.md               (ONE scenario)
7. {Custom path}/domain-custom.md        (if specified — project-level customization)
```

### Convention Hierarchy

Three levels of customization, from broadest to most specific:

| Level | File | Scope | Example |
|-------|------|-------|---------|
| **Skill-level** | `_core.md` + modules | Universal — all projects of this type | "HTTP API SCs must include status code" |
| **Org-level** | `org-convention.md` | Shared across projects in an organization | "All APIs must use our standard error envelope" |
| **Project-level** | `domain-custom.md` | Specific to one project | "This project uses GraphQL subscriptions for real-time" |

Later levels override earlier ones. Org conventions override module defaults; project conventions override org conventions.

**Merge rule**: Later modules extend earlier ones. For same-section content:
- **S0 Signal Keywords**: Aggregated per-module (each module's keywords are independent; see `reference/clarity-index.md` § 5)
- **S1 SC Rules**: Append (accumulate all rules)
- **S2 Parity Dimensions**: Append (add module-specific dimensions)
- **S3 Verify Steps**: Override only if module explicitly overrides (otherwise inherit _core)
- **S5 Elaboration Probes**: Append (accumulate all probes)
- **S7 Bug Prevention**: Append (accumulate all activation conditions)
- **S8 Runtime Verification**: Per-interface (no merge — each interface has its own strategy)
- **S9 Brief Completion Criteria**: Append (accumulate all module-specific Brief requirements)
- **A0 Signal Keywords**: Aggregated per-archetype (each archetype's keywords are independent; see `reference/clarity-index.md` § 5)
- **A1 Philosophy Principles**: Append (accumulate from all active archetypes)
- **A2 SC Generation Extensions**: Append (add archetype-specific SC rules to S1)
- **A3 Elaboration Probes**: Append (add archetype-specific probes to S5)
- **A4 Constitution Injection**: Append (accumulate all archetype constitution principles)
- **A5 Brief Completion Criteria**: Append (add archetype-specific Brief requirements to S9)
