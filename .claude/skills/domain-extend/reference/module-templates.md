# Module Templates Reference

> Internal reference for domain-extend. Defines the canonical structure for each module type
> across the 3-file system (shared + reverse-spec + smart-sdd).
> See `smart-sdd/domains/_schema.md` for section schemas, `reverse-spec/domains/_schema.md` for R-sections.

---

## File Naming Convention

- Module name: lowercase-kebab-case (e.g., `video-encoding`, `k8s-api`)
- ID prefix: 2-3 uppercase letters (e.g., `VE` for video-encoding, `K8S` for k8s-api)
- ID prefix MUST be unique across all existing modules (check `_core.md` § S7 B-3 for existing prefixes)
- File name = module name across all 3 locations (shared, reverse-spec, smart-sdd)

---

## Module Type: Concern (3-file set)

Concerns are cross-cutting patterns that span multiple Features. Most common module type.

### File 1: `shared/domains/concerns/{name}.md`

```markdown
# Concern: {name}

> {One-line description}

---

## Signal Keywords

### Semantic (S0 — for init inference)

**Primary**: {high-confidence keywords}

**Secondary**: {medium-confidence keywords}

### Code Patterns (R1 — for source analysis)

- {Category}: {library/pattern list}
- {Category}: {library/pattern list}

---

## Module Metadata

- **Axis**: Concern
- **Common pairings**: {modules that often co-activate}
- **Profiles**: {profiles that include this module, or —}
```

### File 2: `reverse-spec/domains/concerns/{name}.md`

```markdown
# Concern: {name} (reverse-spec)

> {One-line description of detection focus}

## R1. Detection Signals

> See [`shared/domains/concerns/{name}.md`](../../../shared/domains/concerns/{name}.md) § Code Patterns

## R3. Analysis Depth Modifiers

- {Feature boundary heuristic 1}
- {Data flow extraction focus area 1}
```

### File 3: `smart-sdd/domains/concerns/{name}.md`

```markdown
# Concern: {name}

<!-- Format defined in smart-sdd/domains/_schema.md § Concern Section Schema. -->
<!-- ID prefix: {PREFIX} -->

> {One-line description}

---

## S0. Signal Keywords

> See [`shared/domains/concerns/{name}.md`](../../../shared/domains/concerns/{name}.md) § Signal Keywords

---

## S1. SC Generation Rules

### Required SC Patterns

| Pattern | SC Requirement |
|---------|---------------|
| {pattern} | {what SC must verify} |

### SC Anti-Patterns (reject if seen)
- {anti-pattern}: {why insufficient, what to replace with}

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|-----------------|
| {area} | {question about architectural choice} |

---

## S7. Bug Prevention

| ID | Pattern | Detection | Prevention |
|----|---------|-----------|------------|
| {PREFIX}-001 | {bug pattern} | {how to detect} | {how to prevent} |

<!-- IDs referenced from smart-sdd/domains/_core.md § S7 B-3 conditional rules -->
```

---

## Module Type: Interface (3-file set)

Interfaces define what the app exposes to users/consumers. Includes S2, S6, S8, S9 sections.

### File 1: `shared/domains/interfaces/{name}.md`
Same structure as Concern shared file, but with `**Axis**: Interface`.

### File 2: `reverse-spec/domains/interfaces/{name}.md`

```markdown
# Interface: {name} (reverse-spec)

> {One-line description}

## R1. Detection Signals

> See [`shared/domains/interfaces/{name}.md`](../../../shared/domains/interfaces/{name}.md) § Code Patterns

## R3. Analysis Axes — {Name}-Specific Extraction

| Axis | Description | Extraction Targets | Output Format |
|------|-------------|--------------------|--------------|
| {axis-name} | {what it captures} | {file/code patterns} | {how recorded} |
```

### File 3: `smart-sdd/domains/interfaces/{name}.md`

```markdown
# Interface: {name}

<!-- Format: _schema.md | ID prefix: {PREFIX} -->

> {One-line description}

---

## S0. Signal Keywords

> See [`shared/domains/interfaces/{name}.md`](../../../shared/domains/interfaces/{name}.md) § Signal Keywords

---

## S1. SC Generation Rules

### Required SC Patterns
- {pattern}: {SC requirement}

### SC Anti-Patterns (reject)
- {anti-pattern}: {replacement}

### SC Measurability Criteria
- {how to verify SC is testable}

---

## S2. Parity Dimensions (additions)

| Category | What to Compare |
|----------|----------------|
| {category} | {structural/logic dimension} |

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| {area} | {question} |

---

## S7. Bug Prevention

| ID | Pattern | Detection | Prevention |
|----|---------|-----------|------------|
| {PREFIX}-001 | {pattern} | {detection} | {prevention} |

---

## S8. Runtime Verification Strategy

| Field | Value |
|-------|-------|
| Start method | {how to start app/server} |
| Verify method | {how to verify runtime behavior} |
| Stop method | {how to clean up} |
| SC classification extensions | {interface-specific auto-categories} |

---

## S9. Brief Completion Criteria

| Required Element | Completion Signal |
|-----------------|-------------------|
| {element} | {how to confirm} |
```

---

## Module Type: Archetype (3-file set)

Archetypes define domain philosophy. Use A-prefix sections (A0-A5) to avoid collision with S0-S9.

### File 1: `shared/domains/archetypes/{name}.md`

```markdown
# Archetype: {name}

> {One-line description}

---

## Signal Keywords

### Semantic (A0 — for init inference)

**Primary**: {keywords}

**Secondary**: {keywords}

### Code Patterns (A0 — for source analysis)

- **Libraries**: {library list}
- **Code patterns**: {usage patterns}
- **Config files**: {config indicators}

---

## Module Metadata

- **Axis**: Archetype
- **Typical interfaces**: {interfaces commonly seen with this archetype}
- **Common pairings**: {concerns that often co-activate}
```

### File 2: `reverse-spec/domains/archetypes/{name}.md`

```markdown
# Archetype: {name} (reverse-spec)

> {Description for analysis}

---

## A0. Signal Keywords

> See [`shared/domains/archetypes/{name}.md`](../../../shared/domains/archetypes/{name}.md) § Signal Keywords

---

## A1. Analysis Axes — Philosophy Extraction

| Principle | Extraction Targets | Output Format |
|-----------|--------------------|---------------|
| **{principle}** | {where to look} | {how to record in constitution-seed} |
```

### File 3: `smart-sdd/domains/archetypes/{name}.md`

```markdown
# Archetype: {name}

> {One-line description}

---

## A0. Signal Keywords

> See [`shared/domains/archetypes/{name}.md`](../../../shared/domains/archetypes/{name}.md) § Signal Keywords

---

## A1. Philosophy Principles

| Principle | Description | Implication |
|-----------|-------------|-------------|
| **{name}** | {what it means} | {how it affects SC/implementation/verification} |

---

## A2. SC Generation Extensions

### Required SC Patterns
- {archetype-specific SC requirement}

### SC Anti-Patterns (reject)
- {vague formulation}: {what to require instead}

---

## A3. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| {area} | {question} |

---

## A4. Constitution Injection

| Principle | Rationale |
|-----------|-----------|
| {principle statement} | {why critical for this archetype} |

---

## A5. Brief Completion Criteria

| Required Element | Completion Signal |
|-----------------|-------------------|
| {element} | {how to confirm} |
```

---

## Module Type: Foundation (reverse-spec only, single file)

Foundations are framework-specific. Located only in `reverse-spec/domains/foundations/`.
Use `_TEMPLATE.md` in that directory as the canonical template.

### Structure: `reverse-spec/domains/foundations/{name}.md`

| Section | Purpose | Required |
|---------|---------|----------|
| F0 | Detection Signals | YES |
| F1 | Foundation Categories (category table) | YES |
| F2 | Decision Items (per-category ID tables) | YES |
| F3 | Extraction Rules (reverse-spec scanning) | Optional (full format) |
| F4 | T0 Feature Grouping (foundation → feature mapping) | Optional (full format) |
| F7 | Framework Philosophy (principles table) | YES |
| F8 | Toolchain Commands (build/test/lint) | YES |
| F9 | Scan Targets (data model, API endpoint patterns) | Optional |

ID format: `{FW}-{CAT}-{NN}` (e.g., `EX-SEC-01` for Express Security item 1).

---

## Module Type: Context Modifier (smart-sdd only, single file)

Context modifiers adjust rule depth without producing new rules. Currently the `Scale` modifier
is built into `_resolver.md` Step 4. Additional context modifiers (e.g., `migration`) live in
`reverse-spec/domains/contexts/` and `shared/domains/contexts/`.

### Structure: `{skill}/domains/contexts/{name}.md`

```markdown
# Context: {name}

> {One-line description of what context this modifier provides}

## Activation Condition
{When this context is active — e.g., "when migrating from framework X to Y"}

## S1. SC Preservation / Additional SCs
| Condition | SC Requirement |
|-----------|---------------|
| {condition} | {what must be preserved or added} |

## S5. Context-Specific Probes
| Sub-domain | Probe Questions |
|------------|-----------------|
| {area} | {question} |

## S7. Context-Specific Prevention
| ID | Pattern | Detection | Prevention |
|----|---------|-----------|------------|
| {CTX}-001 | {pattern} | {detection} | {prevention} |
```

---

## Module Type: Profile (smart-sdd only, single file)

Profiles are pure manifests (~5-10 lines) composing interfaces + concerns.

### Structure: `smart-sdd/domains/profiles/{name}.md`

```markdown
# Profile: {name}

> {One-line description}

interfaces: [{comma-separated list}]
concerns: [{comma-separated list}]
```

Profiles do NOT define Scenario (determined by `sdd-state.md` Origin field) or
Archetype (set explicitly in `sdd-state.md`).

---

## Module Type: Org Convention (project-level, single file)

Org conventions are project-specific overrides placed at a path referenced in `sdd-state.md`.
They override skill-level rules and are overridden by project-level `domain-custom.md`.

### Structure: `{org-path}/org-convention.md`

| Section | Purpose |
|---------|---------|
| S1 | Org-wide SC generation rules (override/extend module S1) |
| S7 | Org-wide bug prevention rules (extend module S7) |
| API Standards | Org-wide API formatting rules |
| Testing Requirements | Org-wide testing thresholds |
| Custom Rules | Arbitrary org rules with scope annotation |

---

## Cross-Concern Integration Rule

When two or more modules interact, add a single row to `_resolver.md` § Step 3.5:

| Active Combination | Pattern | Rule |
|--------------------|---------|------|
| {module-A} + {module-B} | {interaction pattern} | {what the combined rule enforces} |

Only needed when the combination produces behavior not covered by either module alone.
