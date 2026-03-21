# Concern: audit-logging

> Immutable audit trails, structured event logging, tamper-proof storage, event correlation, compliance reporting, retention policies.

---

## Signal Keywords

### Semantic (S0 — for init inference)

**Primary**: audit log, audit trail, event log, immutable log, compliance log, change tracking, activity log, tamper-proof

**Secondary**: event correlation, retention policy, log integrity, append-only, change data capture, who-what-when, audit report, log archival, log signing, chain of custody, non-repudiation, event sourcing audit

### Code Patterns (R1 — for source analysis)

- Tables: `audit_logs`, `event_log`, `activity_stream`, `change_history`, append-only tables
- Libraries: `audit-log`, `django-auditlog`, `papertrail`, `envers` (Hibernate), `javers`
- Patterns: `AuditEntry`, `logEvent()`, `recordChange()`, `before/after` snapshots, `actor`, `action`, `target`, `timestamp`
- Storage: Write-once storage, WORM, blockchain-anchored hashes, signed log entries
- Integrity: HMAC chain, Merkle tree, log hash chain, `previousHash` linking

---

## Module Metadata

- **Axis**: Concern
- **Common pairings**: auth, compliance, observability
- **Profiles**: —
