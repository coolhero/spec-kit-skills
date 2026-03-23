# Interface Module Template

> Create a new Interface module by generating 3 files from this template.
> Replace all `{placeholders}` with actual values.
> Interfaces include S2 (Parity), S8 (Runtime Verification), and S9 (Brief Criteria)
> sections that Concerns do not have.

---

## File 1: `shared/domains/interfaces/{name}.md`

```markdown
# Interface: {name}

> {One-line description of what this interface exposes to users/consumers.}

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

- **Axis**: Interface
- **Common pairings**: {concerns that often co-activate with this interface}
- **Profiles**: {profiles that include this interface, or —}
```

---

## File 2: `reverse-spec/domains/interfaces/{name}.md`

```markdown
# Interface: {name} (reverse-spec)

> {Analysis-focused description}

---

## R1. Detection Signals

> See [`shared/domains/interfaces/{name}.md`](../../../shared/domains/interfaces/{name}.md) § Code Patterns

## R3. Analysis Axes — {Name}-Specific Extraction

| Axis | Description | Extraction Targets | Output Format |
|------|-------------|--------------------|--------------|
| {axis-1} | {what it captures} | {file/code patterns to scan} | {how to record} |
| {axis-2} | {what it captures} | {file/code patterns to scan} | {how to record} |
```

---

## File 3: `smart-sdd/domains/interfaces/{name}.md`

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
- {interaction pattern}: specify {what SC must include}
- {response pattern}: specify {what SC must include}

### SC Anti-Patterns (reject)
- {vague formulation}: must specify {concrete replacement}

### SC Measurability Criteria
- {how to verify SCs are testable and automatable}

---

## S2. Parity Dimensions (additions)

| Category | What to Compare |
|----------|----------------|
| {structural category} | {elements to match between source and target} |
| {logic category} | {behavioral elements to match} |

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| {area-1} | {question about interface design} |
| {area-2} | {question about error handling} |

---

## S7. Bug Prevention

| ID | Pattern | Detection | Prevention |
|----|---------|-----------|------------|
| {PREFIX}-001 | {bug pattern} | {how to detect} | {how to prevent} |

---

## S8. Runtime Verification Strategy

| Field | Value |
|-------|-------|
| Start method | {how to start the app/server/process for verification} |
| Verify method | {how to verify runtime behavior — backend type + approach} |
| Stop method | {how to clean up after verification} |
| SC classification extensions | {interface-specific SC auto-categories, e.g., "api-auto"} |

---

## S9. Brief Completion Criteria

| Required Element | Completion Signal |
|-----------------|-------------------|
| {minimum element 1} | {how to confirm element is defined} |
| {minimum element 2} | {how to confirm element is defined} |
```

---

## Checklist After Creation

- [ ] ID prefix is unique across all modules
- [ ] Shared file has both Semantic and Code Patterns sections
- [ ] Reverse-spec file has R3 Analysis Axes (interface-specific extraction)
- [ ] Smart-sdd file has S2 Parity, S8 Runtime Verification, S9 Brief Criteria
- [ ] S8 defines start/verify/stop lifecycle for runtime checks
- [ ] If this interface interacts with existing modules, add row to `_resolver.md` § Step 3.5
