# Archetype Module Template

> Create a new Archetype module by generating 3 files from this template.
> Replace all `{placeholders}` with actual values.
> Archetypes use A-prefix sections (A0-A5) to avoid collision with S0-S9.
> Archetypes define domain philosophy — WHY certain patterns matter.

---

## File 1: `shared/domains/archetypes/{name}.md`

```markdown
# Archetype: {name}

> {One-line description of the application domain this archetype represents.}

---

## Signal Keywords

### Semantic (A0 — for init inference)

**Primary**: {keyword1}, {keyword2}, {keyword3}

**Secondary**: {keyword4}, {keyword5}

### Code Patterns (A0 — for source analysis)

- **Libraries**: {library1}, {library2}
- **Code patterns**: {usage pattern1}, {usage pattern2}
- **Config files**: {config indicators}

---

## Module Metadata

- **Axis**: Archetype
- **Typical interfaces**: {interfaces commonly seen with this archetype}
- **Common pairings**: {concerns that often co-activate}
```

---

## File 2: `reverse-spec/domains/archetypes/{name}.md`

```markdown
# Archetype: {name} (reverse-spec)

> {Analysis-focused description}

---

## A0. Signal Keywords

> See [`shared/domains/archetypes/{name}.md`](../../../shared/domains/archetypes/{name}.md) § Signal Keywords

---

## A1. Analysis Axes — Philosophy Extraction

For each detected {name} pattern, extract:

| Principle | Extraction Targets | Output Format |
|-----------|--------------------|---------------|
| **{principle-1}** | {where to look in code} | {how to record in constitution-seed} |
| **{principle-2}** | {where to look in code} | {how to record in constitution-seed} |
```

---

## File 3: `smart-sdd/domains/archetypes/{name}.md`

```markdown
# Archetype: {name}

> {One-line description}
> Module type: archetype

---

## A0. Signal Keywords

> See [`shared/domains/archetypes/{name}.md`](../../../shared/domains/archetypes/{name}.md) § Signal Keywords

---

## A1. Philosophy Principles

| Principle | Description | Implication |
|-----------|-------------|-------------|
| **{principle-1}** | {what it means in practice} | {how it affects SC generation, implementation, verification} |
| **{principle-2}** | {what it means in practice} | {how it affects decisions} |

---

## A2. SC Generation Extensions

### Required SC Patterns
- **{domain pattern}**: {what every SC involving this pattern must specify}

### SC Anti-Patterns (reject)
- {vague formulation}: must specify {concrete requirements}

---

## A3. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| {area-1} | {domain-specific question} |
| {area-2} | {domain-specific question} |

---

## A4. Constitution Injection

Principles to inject into constitution-seed when this archetype is active:

| Principle | Rationale |
|-----------|-----------|
| {principle statement for constitution} | {why critical for this archetype} |

---

## A5. Brief Completion Criteria

| Required Element | Completion Signal |
|-----------------|-------------------|
| {element specific to this archetype} | {how to confirm it is defined} |
```

---

## Checklist After Creation

- [ ] Shared file has both Semantic and Code Patterns under A0
- [ ] Reverse-spec A1 defines extraction targets for each philosophy principle
- [ ] Smart-sdd A1 principles have Description + Implication columns
- [ ] A2 extends (not duplicates) S1 rules from interfaces/concerns
- [ ] A4 constitution principles are actionable and archetype-specific
- [ ] A5 criteria are checked during `add` Phase 1 Elaboration alongside S9
