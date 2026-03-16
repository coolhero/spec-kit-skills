# Concern: multi-tenancy

> Tenant isolation, per-tenant configuration, and cross-tenant data protection.

---

## S0. Signal Keywords

> See [`shared/domains/concerns/multi-tenancy.md`](../../../shared/domains/concerns/multi-tenancy.md) § Signal Keywords
>
> _(Define Signal Keywords in the shared module, not here.)_

---

## S1. SC Generation Rules

### Required SC Patterns

| Pattern | SC Requirement |
|---------|----------------|
| Tenant isolation | SC must verify that data created by Tenant A is never visible to Tenant B |
| Tenant context propagation | SC must verify tenant ID flows from entry point (request/token) through all service layers to data access |
| Tenant-scoped query | SC must verify every data query includes tenant filter (no unscoped queries on tenant-owned tables) |
| Tenant provisioning | SC must verify new tenant creation sets up all required resources (schema/config/storage) |

### SC Anti-Patterns (reject if seen)

- "Tenant data is isolated" — must specify isolation mechanism and how violation is tested
- "Multi-tenant support works" — must specify which operations are tested with which tenant combinations
- "User sees only their data" — conflates auth with tenancy; must separate tenant filtering from user permissions

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|-----------------|
| Isolation strategy | Row-level (shared tables + tenant_id)? Schema-per-tenant? Database-per-tenant? Hybrid? |
| Tenant identification | How is tenant resolved? Subdomain? JWT claim? Header? URL path? |
| Context propagation | How does tenant context flow through the request lifecycle? Middleware injection? Thread-local? |
| Per-tenant customization | Do tenants have different feature flags, themes, or configurations? |
| Data migration | How are schema migrations applied across tenants? Rolling? Simultaneous? |
| Cross-tenant operations | Are there any legitimate cross-tenant operations (admin views, analytics)? How are they scoped? |

---

## S7. Bug Prevention

| ID | Pattern | Detection | Prevention |
|----|---------|-----------|------------|
| MTN-001 | Missing tenant filter | Query on tenant-owned table lacks `WHERE tenant_id = ?` | Lint/review rule: all queries on tenant tables must include tenant filter; use query middleware or base query class |
| MTN-002 | Tenant context lost in async | Background job or event handler loses tenant context from original request | Explicitly pass tenant_id to all async operations; verify in job handler |
| MTN-003 | Cross-tenant data leak in cache | Cache key missing tenant prefix → Tenant B reads Tenant A's cached data | Cache key format: `{tenant_id}:{resource}:{id}`; reject cache keys without tenant prefix |
| MTN-004 | Migration applied to wrong tenants | Schema migration targets all tenants but should be tenant-specific | Migration scripts must declare scope (all tenants / specific tenants / new tenants only) |
| MTN-005 | Admin endpoint bypasses isolation | Admin API returns all-tenant data without explicit scope declaration | Admin endpoints must use separate query path with explicit `all_tenants=true` flag |
