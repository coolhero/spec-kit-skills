# Domain Module Schema (reverse-spec)

> Defines the section schema for domain modules used during reverse-spec analysis.
> Every module (interface, concern) follows this schema. Omit sections that don't apply.
> For smart-sdd module sections (S0-S9), see `../smart-sdd/domains/_schema.md`.

---

## Module Types

| Type | Location | Purpose |
|------|----------|---------|
| **Interface** | `interfaces/{name}.md` | Interface-specific extraction axes (http-api, gui, cli, data-io) |
| **Concern** | `concerns/{name}.md` | Concern-specific detection signals (async-state, ipc, external-sdk, i18n, realtime, auth) |
| **Archetype** | `archetypes/{name}.md` | Application-domain philosophy and extraction axes (ai-assistant, public-api, microservice) |
| **Core** | `_core.md` | Universal analysis framework loaded for ALL projects |

---

## Section Schema (R1–R6)

### R1. Detection Signals (interfaces, concerns)

File/directory patterns that indicate this module is relevant to the project. Used for auto-detection during profile resolution.

| Field | Description |
|-------|-------------|
| **File patterns** | Config files, directory structures, package dependencies |
| **Code patterns** | Import statements, API usage patterns, framework markers |

### R2. Project Type Classification (_core only)

Project type categories for Phase 1-3 classification.

| Field | Description |
|-------|-------------|
| **Type name** | Category identifier (e.g., `backend`, `frontend`, `fullstack`) |
| **Description** | What characterizes this type |
| **Indicators** | File/directory signals that suggest this type |

### R3. Analysis Axes (interfaces — additions to _core)

Phase 2 Deep Analysis extraction targets specific to this interface.

| Field | Description |
|-------|-------------|
| **Axis name** | Short identifier (e.g., `API Endpoint Extraction`) |
| **Description** | What this axis captures |
| **Extraction targets** | File patterns, code patterns, frameworks to scan |
| **Output format** | How extracted data should be recorded |

### R4. Registries (_core only)

Registry files to generate during Phase 4.

| Field | Description |
|-------|-------------|
| **File name** | Output filename (e.g., `entity-registry.md`) |
| **Purpose** | What cross-Feature information it tracks |
| **Template** | Reference to template file in `templates/` |

### R5. Feature Boundary Heuristics (_core only)

Criteria for identifying Feature boundaries in Phase 3-1. Domain-specific signals that indicate where one Feature ends and another begins.

### R6. Tier Classification Axes (_core only)

Importance analysis criteria for Phase 3-3 (core scope only). Each axis evaluates Features from a different perspective to determine Tier placement.

---

## Archetype Section Schema (A0–A1)

Archetype modules use a separate section numbering (A-prefix) to avoid collision with R1–R6.

### A0. Signal Keywords (archetypes)

File/library/code patterns that indicate this archetype is relevant to the project. Used for auto-detection during analysis.

| Field | Description |
|-------|-------------|
| **Libraries** | Package dependencies, SDKs, frameworks specific to this domain |
| **Code patterns** | Import patterns, API usage, architectural markers |
| **Config files** | Configuration files, directory structures indicative of this archetype |

### A1. Analysis Axes — Philosophy Extraction (archetypes)

Domain-specific philosophical principles to extract during Phase 2 Deep Analysis. For each detected archetype pattern, extract guiding principles that inform architectural decisions.

| Field | Description |
|-------|-------------|
| **Principle name** | Short identifier for the architectural principle |
| **Extraction targets** | Where to look in the code for evidence of this principle |
| **Output format** | How extracted principles should be recorded in constitution-seed |

---

## Loading Order

Modules are loaded in this order during reverse-spec execution:

```
1. _core.md                              (ALWAYS — universal analysis framework)
2. interfaces/{interface}.md             (for EACH detected/specified interface)
3. concerns/{concern}.md                 (for EACH detected/specified concern)
4. archetypes/{archetype}.md             (for EACH detected/specified archetype)
```

**Merge rule**: Later modules extend earlier ones:
- **R1 Detection Signals**: Append (accumulate from all modules)
- **R3 Analysis Axes**: Append (add module-specific extraction targets to _core axes)
- **A0 Signal Keywords**: Aggregated per-archetype (each archetype's keywords are independent)
- **A1 Philosophy Extraction**: Append (accumulate from all active archetypes)
