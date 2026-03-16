# Concern: authorization

> Fine-grained permission models — RBAC, ABAC, ACL.
> Distinct from auth (authentication = who you are; authorization = what you can do).

---

## Signal Keywords

### Semantic (S0 — for init inference)

**Primary**: authorization, permissions, RBAC, ABAC, ACL, access control, role-based, permission model, policy engine, capabilities

**Secondary**: permission check, guard, authorize decorator, permission rule, scopes, row-level security, tenant isolation, glob pattern permissions

### Code Patterns (R1 — for source analysis)

- Permission models: RBAC (role definitions), ABAC (attribute-based rules), ACL (access control lists)
- Permission checks: `can()`, `hasPermission()`, `authorize()`, `@Authorize`, guard patterns
- Rule definitions: permission rule files, policy files, glob-based path rules
- Scope/capability: OAuth scopes, capability tokens, permission matrices
- Per-entity permissions: row-level security, tenant isolation rules

---

## Module Metadata

- **Axis**: Concern
- **Common pairings**: auth
- **Profiles**: —
