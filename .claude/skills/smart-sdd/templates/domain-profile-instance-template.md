# Domain Profile Instance

> This file records the concrete domain decisions made for THIS project.
> It is the profiling RESULT — the "filled-out questionnaire."
> The profiling TOOLS (S0/S1/S5/S7 module files) define what to ask;
> this file records what was answered.
>
> Auto-generated and maintained by the pipeline. Manual editing is safe.
> Location: specs/_global/domain-profile-instance.md

---

## Project-Level Profile

**Interfaces**: [from sdd-state.md]
**Concerns**: [from sdd-state.md]
**Archetype**: [from sdd-state.md]
**Foundation**: [from sdd-state.md]
**Context**: [mode | maturity × team | +modifiers]

---

## Per-Concern Decisions

> Each active concern's S5 probe answers, recorded when the user responds during Brief.

### [concern-name]

| Probe (S5) | Decision | Decided At | Feature |
|------------|----------|------------|---------|
| [probe question from S5] | [user's answer] | [timestamp] | [FID] |

---

## Per-Archetype Decisions

> Active archetype's A3 probe answers.

### [archetype-name]

| Probe (A3) | Decision | Decided At | Feature |
|------------|----------|------------|---------|
| [probe question from A3] | [user's answer] | [timestamp] | [FID] |

---

## Cross-Concern Integrations Applied

> Records which cross-concern rules from _resolver.md Step 3.5 were activated.

| Combination | Rule Injected | First Applied At | Feature |
|------------|--------------|-----------------|---------|
| [module1 + module2] | [rule description] | [step] | [FID] |

---

## Per-Feature Domain Summary

### [FID]-[name]

- **Active modules**: [list]
- **Key decisions**: [1-2 sentence summary]
- **Inherited constraints from**: [preceding FID list, or "none"]
- **New decisions made**: [what this Feature decided that preceding Features didn't]
