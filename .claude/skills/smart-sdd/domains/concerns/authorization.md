# Concern: authorization

> Fine-grained authorization and permission systems.
> Applies when the project has permission models beyond simple authentication (RBAC, ABAC, rule-based access control).
> Module type: concern

---

## S0. Signal Keywords

> See [`shared/domains/concerns/authorization.md`](../../../shared/domains/concerns/authorization.md) § Signal Keywords

---

## S1. SC Generation Rules

### Required SC Patterns
- Permission check: action + resource + actor → allow/deny decision
- Default deny: unrecognized action or missing rule → deny (not allow)
- Permission inheritance: role hierarchy → child inherits parent permissions
- Permission boundary: even admin role has explicit boundaries (not implicit "allow all")

### SC Anti-Patterns (reject)
- "Only authorized users can access" — must specify role/permission + resource + expected behavior on denial
- "Admin has full access" — must specify explicit admin permission set (not implicit wildcard)

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| **Model** | RBAC? ABAC? ACL? Capability-based? Custom? |
| **Granularity** | Route-level? Resource-level? Field-level? Row-level? |
| **Rules** | Static (code)? Dynamic (database)? Pattern-based (glob)? |
| **Hierarchy** | Role inheritance? Permission groups? Nested scopes? |
| **Context** | Time-based? Location-based? Device-based? Multi-tenant? |

---

## S7. Bug Prevention — Authorization-Specific

| ID | Pattern | Detection | Prevention |
|----|---------|-----------|------------|
| AUTHZ-001 | Default allow | Missing permission check → access granted | Default-deny policy — all routes/resources require explicit permission |
| AUTHZ-002 | Permission bypass via path | Alternative URL path reaches protected resource | Permission check at resource layer, not route layer |
| AUTHZ-003 | Role confusion | "editor" in context A has different permissions than "editor" in context B | Namespace roles per context/tenant |
| AUTHZ-004 | Stale permission cache | Permission revoked but cached permission still allows access | Cache TTL + immediate invalidation on permission change |
| AUTHZ-005 | Horizontal privilege escalation | User A accesses User B's resource by changing ID parameter | Owner check at resource access — verify actor owns/has-access-to resource |
