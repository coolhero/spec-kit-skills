# Concern: authorization (reverse-spec)

> Fine-grained authorization/permission system detection. Distinct from auth (authentication = who you are; authorization = what you can do).

## R1. Detection Signals
- Permission models: RBAC (role definitions), ABAC (attribute-based rules), ACL (access control lists)
- Permission checks: `can()`, `hasPermission()`, `authorize()`, `@Authorize`, guard patterns
- Rule definitions: permission rule files, policy files, glob-based path rules
- Scope/capability: OAuth scopes, capability tokens, permission matrices
- Per-entity permissions: row-level security, tenant isolation rules
