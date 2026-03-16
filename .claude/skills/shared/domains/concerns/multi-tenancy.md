# Concern: multi-tenancy

> Tenant isolation, per-tenant configuration, and cross-tenant data protection.

---

## Signal Keywords

### Semantic (S0 — for init inference)

**Primary**: multi-tenant, tenant, SaaS, tenant isolation, row-level security, tenant context, organization, workspace

**Secondary**: tenant ID, subdomain routing, tenant middleware, tenant-aware, data isolation, tenant provisioning, white-label, per-tenant config

### Code Patterns (R1 — for source analysis)

- Tenant identification: `tenant_id` in models/schemas, subdomain extraction middleware, JWT `org_id`/`tenant_id` claims, `X-Tenant-ID` header
- Query filtering: `.filter(tenant_id=...)`, RLS policies (`CREATE POLICY`), schema-per-tenant (`SET search_path`), database-per-tenant connection switching
- Middleware: tenant context injection in request pipeline, tenant resolution from URL/header/token
- Configuration: per-tenant feature flags, tenant-specific settings tables, tenant config files
- Isolation boundaries: separate storage buckets per tenant, tenant-scoped cache keys, tenant-prefixed queue names

---

## Module Metadata

- **Axis**: Concern
- **Common pairings**: auth, authorization
- **Profiles**: —
