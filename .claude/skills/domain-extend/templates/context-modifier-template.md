# Context Modifier Template

> Context Modifiers are **situational overlays** that adjust rule depth and add
> context-specific probes/prevention without changing the pipeline mode or producing
> new structural rules. They live as single files in `contexts/modifiers/`.
>
> Unlike Concerns (which define cross-cutting domains), Context Modifiers activate
> temporarily when a specific situation applies (e.g., migration, compliance audit,
> performance optimization).

---

## File: `smart-sdd/domains/contexts/modifiers/{name}.md`

```markdown
# Context Modifier: {name}

> {One-line description of the situational context this modifier provides.}

---

## Activation Condition

{When this modifier is active. Be specific about triggers.}
{e.g., "When migrating from framework X to Y", "When project requires SOC2 compliance"}

---

## S1. SC Preservation / Additional SCs

| Condition | SC Requirement |
|-----------|---------------|
| {situation-specific condition} | {what must be preserved or added to SCs} |

---

## S5. Context-Specific Probes

| Sub-domain | Probe Questions |
|------------|-----------------|
| {area} | {question that only matters in this context} |

---

## S7. Context-Specific Prevention

| ID | Pattern | Detection | Prevention |
|----|---------|-----------|------------|
| {CTX}-001 | {context-specific failure pattern} | {how to detect} | {how to prevent} |
```

---

## Example: Migration Modifier

```markdown
# Context Modifier: migration

> Adjusts rules when migrating from one framework/architecture to another.

## Activation Condition

When `sdd-state.md` indicates a migration scenario, or user explicitly
declares a migration source and target framework.

## S1. SC Preservation / Additional SCs

| Condition | SC Requirement |
|-----------|---------------|
| Data model changes | Verify backward compatibility with existing stored data |
| API surface changes | Verify old API consumers still work (or migration path documented) |

## S5. Context-Specific Probes

| Sub-domain | Probe Questions |
|------------|-----------------|
| Data | What data formats change? Is migration reversible? |
| Dependencies | Which shared dependencies change version? |

## S7. Context-Specific Prevention

| ID | Pattern | Detection | Prevention |
|----|---------|-----------|------------|
| MIG-001 | Big-bang migration | All modules changed in single Feature | Break into incremental migration Features |
| MIG-002 | Missing rollback | No rollback plan in spec | Require rollback strategy SC for each migration Feature |
```

---

## Checklist After Creation

- [ ] File placed in `smart-sdd/domains/contexts/modifiers/{name}.md`
- [ ] Activation Condition clearly describes when this modifier applies
- [ ] S1 entries add SCs that only matter in this context (not duplicating Concern S1)
- [ ] S5 probes are context-specific (would not apply outside this situation)
- [ ] S7 ID prefix is unique (check existing modifiers for collisions)
- [ ] NOT registered in `_taxonomy.md` (modifiers are activated by condition, not by keywords)
