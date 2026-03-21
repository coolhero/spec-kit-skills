# Concern: audit-logging (reverse-spec)

> Audit logging detection. Identifies immutable audit trails, event capture, and integrity verification patterns.

## R1. Detection Signals

> See [`shared/domains/concerns/audit-logging.md`](../../../shared/domains/concerns/audit-logging.md) § Code Patterns

## R3. Analysis Depth Modifiers

When detected, include in analysis:
- Audit event schema (fields captured: who, what, when, before/after state)
- Storage mechanism (append-only table, event store, external service)
- Integrity protection (hash chain, HMAC, WORM storage, digital signatures)
- Retention policy and archival process
- Access control for audit data (who can read, export format)
- Compliance reporting capabilities
