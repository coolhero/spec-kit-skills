# Stack Migration Plan

**Source Project**: [Original project path]
**Generated**: [DATE]
**Decision Made In**: Phase 3-4 (Stack Strategy Details)

---

## Migration Overview

| Category | Current | New | Migration Complexity |
|----------|---------|-----|---------------------|
| Language | [e.g., Python 3.10] | [e.g., TypeScript 5.x] | [Low/Medium/High] |
| Framework | [e.g., Django 4.2] | [e.g., Next.js 14] | [Low/Medium/High] |
| ORM / Data Layer | [e.g., Django ORM + PostgreSQL] | [e.g., Prisma + PostgreSQL] | [Low/Medium/High] |
| Frontend | [e.g., jQuery + Templates] | [e.g., React 18] | [Low/Medium/High] |
| Authentication | [e.g., Django Auth + Session] | [e.g., NextAuth.js + JWT] | [Low/Medium/High] |
| Testing | [e.g., pytest] | [e.g., Vitest + Playwright] | [Low/Medium/High] |
| Build / Deploy | [e.g., Docker + manual] | [e.g., Docker + GitHub Actions] | [Low/Medium/High] |
| Package Manager | [e.g., pip + requirements.txt] | [e.g., pnpm + package.json] | [Low/Medium/High] |

---

## Category Details

### Language: [Current] → [New]
- **Rationale**: [Why this language was chosen]
- **Key differences**: [Major paradigm/syntax differences to be aware of]
- **Impact on Features**: [Which Features are most affected]

### Framework: [Current] → [New]
- **Rationale**: [Why this framework was chosen]
- **Routing model**: [Current routing approach] → [New routing approach]
- **Middleware/Plugin model**: [How middleware patterns change]
- **Impact on Features**: [Which Features are most affected]

### ORM / Data Layer: [Current] → [New]
- **Rationale**: [Why this ORM/data layer was chosen]
- **Schema definition**: [Current approach] → [New approach]
- **Migration strategy**: [How DB migrations are handled]
- **Impact on entities**: [entity-registry.md entity mapping considerations]

### [Add additional categories as needed]

---

## Migration Considerations

### Patterns That Transfer Directly
- [e.g., REST API structure — endpoint paths and contracts remain the same]
- [e.g., Business validation rules — logic-level rules are stack-independent]
- [e.g., Database schema — same PostgreSQL schema, different ORM mapping]

### Patterns That Require Rethinking
- [e.g., Template rendering → Component-based UI — fundamentally different approach]
- [e.g., Synchronous ORM queries → Async data fetching — different data loading patterns]
- [e.g., Server-side sessions → JWT tokens — different auth architecture]

### Risks and Mitigations
| Risk | Impact | Mitigation |
|------|--------|------------|
| [e.g., Loss of Django admin] | Medium | [Build lightweight admin with new stack or use headless CMS] |
| [e.g., ORM feature gap] | Low | [Prisma covers 95% of use cases; raw SQL for edge cases] |
| [e.g., Learning curve] | High | [Follow idiomatic patterns; reference official docs] |

---

## Per-Feature Migration Notes

> Brief notes on how the stack change affects each Feature's implementation approach.
> Detailed guidance is in each Feature's `pre-context.md` under the `[New Stack]` sections.

| Feature | Key Migration Consideration |
|---------|----------------------------|
| [F001-name] | [e.g., Auth middleware completely different; use NextAuth.js patterns] |
| [F002-name] | [e.g., CRUD patterns map cleanly; Prisma schema mirrors Django models] |
| [F003-name] | [e.g., File upload handling differs; use new stack's streaming API] |

---

**Version**: 0.1.0 | **Generated**: [DATE]
