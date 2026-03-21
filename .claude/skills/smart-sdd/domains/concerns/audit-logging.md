# Concern: audit-logging

<!-- Format defined in smart-sdd/domains/_schema.md § Concern Section Schema. -->

> Immutable audit trails, structured event logging, tamper-proof storage, event correlation, compliance reporting, retention policies.
> Module type: concern

---

## S0. Signal Keywords

> See [`shared/domains/concerns/audit-logging.md`](../../../shared/domains/concerns/audit-logging.md) § Signal Keywords

---

## S1. SC Generation Rules

### Required SC Patterns
- Audit event capture: state-changing action performed → audit entry created (who, what, when, where, before/after state) → entry written to append-only store → entry ID returned for correlation → write confirmed before action response
- Tamper-proof storage: audit entry written → entry hash computed (including previous entry hash for chain) → hash stored alongside entry → periodic integrity verification → any chain break triggers alert
- Compliance reporting: report requested for time range → audit entries queried by filters (actor, action, target, time) → entries aggregated per report template → report generated with integrity checksum → report access logged
- Retention management: retention policy evaluated per entry category → entries past retention period identified → entries archived to cold storage (or deleted if policy allows) → archival/deletion logged as audit event → storage reclaimed

### SC Anti-Patterns (reject if seen)
- "Actions are logged" — must specify what fields are captured, storage mechanism (append-only), and retention period
- "Audit trail is tamper-proof" — must specify integrity mechanism (hash chain, HMAC, WORM storage) and verification schedule
- "Logs are kept for compliance" — must specify retention periods per category, archival process, and deletion audit

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| **Events** | Which actions are audited? All mutations? Reads of sensitive data? Authentication events? |
| **Schema** | What fields per entry (actor, action, target, timestamp, IP, before/after)? Structured or free-text? |
| **Integrity** | Hash chain? HMAC? Digital signatures? WORM storage? Verification frequency? |
| **Retention** | How long retained? Different periods per event category? Legal hold support? |
| **Access** | Who can read audit logs? Separate from application access? Export format? |

---

## S7. Bug Prevention

| ID | Pattern | Detection | Prevention |
|----|---------|-----------|------------|
| AL-001 | Mutable audit entries | Audit records stored in regular table with UPDATE/DELETE permissions → tampering possible → audit trail untrustworthy | Use append-only storage; revoke UPDATE/DELETE on audit tables; use database triggers to prevent modification |
| AL-002 | Missing before/after state | Audit entry records "field changed" but not old/new values → impossible to reconstruct historical state → audit gap | Always capture before/after snapshots for mutations; validate audit entry completeness at write time |
| AL-003 | Audit write failure silenced | Audit log write fails but action proceeds → unaudited state change → compliance violation | Make audit write synchronous and required; fail the action if audit write fails; alert on audit write errors |
| AL-004 | Clock skew in audit timestamps | Distributed system clocks diverge → audit entries out of order → causal sequence unrecoverable | Use centralized timestamp service or NTP-synced clocks; include logical clock (sequence number) alongside wall clock |
| AL-005 | PII in audit entries | Full user details (email, name, address) logged in audit → audit store becomes PII store → GDPR erasure complexity | Reference users by ID only in audit entries; join with user data at query time; handle user deletion by keeping ID reference |
