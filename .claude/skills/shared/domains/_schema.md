# Domain Module Schema (shared)

> Defines the section schema for shared domain modules.
> Shared modules contain **signal keywords** and **code patterns** used by both smart-sdd (init inference) and reverse-spec (source analysis).
> For skill-specific sections: see `smart-sdd/domains/_schema.md` (S1-S9, A1-A5) and `reverse-spec/domains/_schema.md` (R1-R6).

---

## Module Types

| Type | Location | Purpose |
|------|----------|---------|
| **Interface** | `interfaces/{name}.md` | S0 signal keywords + R1 code patterns for an interface type |
| **Concern** | `concerns/{name}.md` | S0 signal keywords + R1 code patterns for a cross-cutting concern |
| **Archetype** | `archetypes/{name}.md` | A0 signal keywords + R1 code patterns for a domain archetype |
| **Context Modifier** | `contexts/modifiers/{name}.md` | M0 signal detection + M1-M4 classification framework |

> **Note**: Foundations and Profiles are skill-specific (not in shared). Foundations live in `reverse-spec/domains/foundations/`. Profiles live in `smart-sdd/domains/profiles/`.

---

## Section Schema

### S0 / A0. Signal Keywords (interfaces, concerns, archetypes)

Keywords used for module auto-detection. smart-sdd `init` uses Semantic keywords for Domain Profile inference. reverse-spec `analyze` uses Code Patterns for source-level detection.

| Sub-section | Used by | Description |
|-------------|---------|-------------|
| **Semantic (S0/A0)** | smart-sdd init | High-level keywords from user descriptions (e.g., "REST API", "WebSocket") |
| **Code Patterns (R1)** | reverse-spec analyze | File patterns, import statements, framework markers found in source code |

#### Semantic Keywords

| Field | Description |
|-------|-------------|
| **Primary** | High-confidence keywords — strong indicator that this module is needed |
| **Secondary** | Medium-confidence keywords — needs user confirmation |

#### Code Patterns

| Field | Description |
|-------|-------------|
| **File patterns** | Config files, directory structures, package dependencies |
| **Code patterns** | Import statements, API usage patterns, framework markers |

### Module Metadata

Every shared module ends with a metadata block:

| Field | Description |
|-------|-------------|
| **Axis** | Interface, Concern, or Archetype |
| **Common pairings** | Modules that often co-activate (for cross-concern rule lookup) |
| **Profiles** | Pre-built profiles that include this module |

---

## Context Modifier Schema (M0-M4)

Context modifiers use a different section scheme from Interface/Concern/Archetype modules:

| Section | Description |
|---------|-------------|
| **M0: Signal Detection** | Trigger conditions — when this modifier should activate |
| **M1: Scale Classification** | Categorize the scope/impact level |
| **M2: Target Layer Classification** | What is being changed (code, data, infra) |
| **M3: Impact Assessment** | Analyze affected scope (code, data, infra, risk) |
| **M4: Pipeline Depth Modifier** | Adjust pipeline behavior based on M1 scale |

> Context modifiers in shared define the classification framework. Pipeline-specific rules (S1/S3/S5/S7) live in `smart-sdd/domains/contexts/modifiers/`. Analysis-specific rules (R3-R5) live in `reverse-spec/domains/contexts/modifiers/`.

---

## Template

See `_TEMPLATE.md` for the contributor template for new shared modules.
