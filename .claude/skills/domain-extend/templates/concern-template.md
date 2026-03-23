# Concern Module Template

> Create a new Concern module by generating 3 files from this template.
> Replace all `{placeholders}` with actual values.
> See `smart-sdd/domains/_schema.md` for section definitions.

---

## File 1: `shared/domains/concerns/{name}.md`

```markdown
# Concern: {name}

> {One-line description of what this cross-cutting concern covers.}

---

## Signal Keywords

### Semantic (S0 — for init inference)

**Primary**: {keyword1}, {keyword2}, {keyword3}

**Secondary**: {keyword4}, {keyword5}

### Code Patterns (R1 — for source analysis)

- {Category}: {pattern1}, {pattern2}
- {Category}: {pattern3}

---

## Module Metadata

- **Axis**: Concern
- **Common pairings**: {modules that often co-activate}
- **Profiles**: {profiles that include this module, or —}
```

---

## File 2: `reverse-spec/domains/concerns/{name}.md`

```markdown
# Concern: {name} (reverse-spec)

> {Detection-focused description}

## R1. Detection Signals

> See [`shared/domains/concerns/{name}.md`](../../../shared/domains/concerns/{name}.md) § Code Patterns

## R3. Analysis Depth Modifiers

- {Feature boundary heuristic — when does this concern indicate a Feature boundary?}
- {Data flow focus — what data flows are unique to this concern?}
```

---

## File 3: `smart-sdd/domains/concerns/{name}.md`

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
When this concern is active, every Feature that touches {concern area} MUST include SCs for:

| Pattern | SC Requirement |
|---------|---------------|
| {pattern-1} | {what the SC must verify} |
| {pattern-2} | {what the SC must verify} |

### SC Anti-Patterns (reject if seen)
- {vague formulation}: {why insufficient and what to replace with}

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|-----------------|
| {area-1} | {question about architectural choice} |
| {area-2} | {question about failure handling} |
| {area-3} | {question about scaling/observability} |

---

## S7. Bug Prevention

| ID | Pattern | Detection | Prevention |
|----|---------|-----------|------------|
| {PREFIX}-001 | {bug pattern name} | {how to detect this bug} | {how to prevent it} |
| {PREFIX}-002 | {bug pattern name} | {how to detect this bug} | {how to prevent it} |

<!-- ID format: {PREFIX}-{NNN} where PREFIX is the concern code (e.g., MQ for message-queue) -->
<!-- These IDs are referenced from smart-sdd/domains/_core.md § S7 B-3 conditional rules -->
```

---

## Checklist After Creation

- [ ] ID prefix is unique (grep existing modules for collisions)
- [ ] Shared file has both Semantic and Code Patterns sections
- [ ] Reverse-spec file cross-references shared file for R1
- [ ] Smart-sdd file cross-references shared file for S0
- [ ] S7 IDs follow `{PREFIX}-{NNN}` format
- [ ] If this concern interacts with existing modules, add row to `_resolver.md` § Step 3.5
