# Concern: {name}

<!-- Format defined in smart-sdd/domains/_schema.md § Concern Section Schema. -->
<!-- This file provides S0/S1/S5/S7 for smart-sdd pipeline execution. -->
<!-- The corresponding reverse-spec file (reverse-spec/domains/concerns/{name}.md) provides R1 detection. -->

> {One-line description of what this cross-cutting concern covers.}

---

## S0. Signal Keywords

**Primary** (high-confidence — activates this module):
- {keyword1}, {keyword2}, {keyword3}

**Secondary** (needs confirmation with user):
- {keyword4}, {keyword5}

---

## S1. SC Generation Rules

### Required SC Patterns
When this concern is active, every Feature that touches {concern area} MUST include SCs for:

| Pattern | SC Requirement |
|---------|---------------|
| {Pattern A} | {What the SC must verify} |
| {Pattern B} | {What the SC must verify} |

### SC Anti-Patterns (reject if seen)
- {Anti-pattern}: {Why it's insufficient and what to replace it with}

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|-----------------|
| {Area 1} | {Question about architectural choice} |
| {Area 2} | {Question about failure handling} |
| {Area 3} | {Question about scaling/observability} |

---

## S7. Bug Prevention

| ID | Pattern | Detection | Prevention |
|----|---------|-----------|------------|
| {CC}-001 | {Bug pattern name} | {How to detect this bug} | {How to prevent it} |
| {CC}-002 | {Bug pattern name} | {How to detect this bug} | {How to prevent it} |

<!-- ID format: {CC}-{NNN} where CC is the concern code (e.g., MQ for message-queue, TW for task-worker) -->
<!-- These IDs are referenced from smart-sdd/domains/_core.md § S7 B-3 conditional rules -->
