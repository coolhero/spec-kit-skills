# Org Convention Template

> Organization-wide coding standards applied to ALL projects in this org.
> Place this file at a path accessible to all projects, then reference it
> in `sdd-state.md` via `**Org Convention**: {path}`.
>
> Override hierarchy: skill-level modules < **org convention** < project-level domain-custom.md

---

## File: `{org-path}/org-convention.md`

```markdown
# Organization Convention: {org-name}

> Organization-wide coding standards. Applied to ALL projects in this org.
> Overrides skill-level module rules. Overridden by project-level domain-custom.md.
> Version: 1.0.0 | Last updated: {YYYY-MM-DD}

---

## S1. SC Generation Rules (org standards)

| Pattern | SC Requirement | Rationale |
|---------|---------------|-----------|
| {org-wide pattern} | {mandatory SC formulation} | {why this is org-wide} |

---

## S7. Bug Prevention (org additions)

| ID | Pattern | Detection | Prevention |
|----|---------|-----------|-----------|
| ORG-001 | {org-specific anti-pattern} | {how to detect} | {how to prevent} |

<!-- Use ORG-{NNN} prefix to distinguish from module-level S7 IDs -->

---

## API Standards

| Standard | Rule |
|----------|------|
| Error format | {e.g., RFC 7807 Problem Details} |
| URL naming | {e.g., kebab-case, plural nouns} |
| Versioning | {e.g., URL path /v1/, /v2/} |
| Pagination | {e.g., cursor-based, Link header} |
| Auth header | {e.g., Bearer token in Authorization header} |

---

## Testing Requirements

| Requirement | Threshold |
|-------------|----------|
| Unit test coverage | {e.g., 80% line coverage} |
| Integration tests | {e.g., required for all API endpoints} |
| E2E tests | {e.g., required for critical user flows} |
| Performance tests | {e.g., required for endpoints > 500ms p95} |

---

## Custom Rules

| Rule | Scope | Description |
|------|-------|-------------|
| {rule-name} | {affected commands: specify, plan, implement, verify, or all} | {what the rule enforces} |
```

---

## Checklist After Creation

- [ ] S1 rules are truly org-wide (not project-specific)
- [ ] S7 IDs use `ORG-` prefix
- [ ] API Standards are consistent with existing org services
- [ ] Testing Requirements are achievable for all project types in the org
- [ ] Custom Rules have explicit scope annotations
- [ ] File path is referenced in `sdd-state.md` `**Org Convention**` field
