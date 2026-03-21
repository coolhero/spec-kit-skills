# Concern: compliance

<!-- Format defined in smart-sdd/domains/_schema.md § Concern Section Schema. -->

> Regulatory frameworks (HIPAA, PCI-DSS, GDPR, SOX), data retention policies, consent management, audit trails, data classification.
> Module type: concern

---

## S0. Signal Keywords

> See [`shared/domains/concerns/compliance.md`](../../../shared/domains/concerns/compliance.md) § Signal Keywords

---

## S1. SC Generation Rules

### Required SC Patterns
- Consent management: user presented with consent options → consent choice recorded (what, when, version) → processing governed by consent status → consent withdrawal honored within SLA → downstream systems notified of consent change
- Data subject request: subject submits request (access/erasure/portability) → request validated and authenticated → data located across all storage systems → request fulfilled within regulatory deadline → confirmation sent → audit trail recorded
- Data retention: data classified by category → retention period applied per category → expired data identified by scheduled job → deletion/anonymization executed → deletion certificate generated → audit record created
- Data classification: data field tagged with sensitivity level (public/internal/confidential/restricted) → access controls applied per classification → encryption-at-rest required for confidential+ → logging required for all access to restricted data

### SC Anti-Patterns (reject if seen)
- "GDPR compliant" — must specify which GDPR articles are relevant, consent mechanism, data subject request workflow, and retention policy
- "Data is deleted when requested" — must specify discovery across all stores, deletion verification, and response time SLA
- "Audit trail exists" — must specify what events are logged, retention period, tamper-proof mechanism, and access controls

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| **Regulations** | Which regulations apply (GDPR, HIPAA, PCI-DSS, SOX, CCPA, FERPA)? Multi-jurisdiction? |
| **Consent** | Granular consent per purpose? Consent versioning? Double opt-in? Withdrawal mechanism? |
| **Retention** | Retention periods per data category? Automated deletion? Legal hold override? |
| **Data Subject Rights** | Access, erasure, portability, rectification? Response time SLA? Identity verification? |
| **Classification** | How many sensitivity levels? Who classifies? Automated PII detection? |

---

## S7. Bug Prevention

| ID | Pattern | Detection | Prevention |
|----|---------|-----------|------------|
| CMP-001 | Incomplete erasure | Data deleted from primary store but remains in backups, caches, logs, or analytics → regulatory violation | Map all data stores during classification; erasure job covers all stores; verify with post-deletion audit query |
| CMP-002 | Consent version mismatch | User consented to v1 policy but processing uses v2 terms → invalid legal basis → enforcement risk | Version consent records; re-consent required on material policy changes; processing checks consent version against current policy |
| CMP-003 | Retention policy not enforced | Retention periods defined in documentation but no automated enforcement → data accumulates indefinitely → storage cost + compliance risk | Implement scheduled retention jobs; alert on data older than retention period; test retention with synthetic aged data |
| CMP-004 | PII in logs/analytics | Personal data appears in application logs, error reports, or analytics events → data leakage outside compliance boundary | Implement log sanitizer; scan analytics payloads for PII patterns; field-level redaction before log emission |
| CMP-005 | Cross-border data transfer | Data replicated to region without adequacy decision → GDPR Chapter V violation | Enforce data residency at infrastructure level; validate replication targets against allowed regions; alert on cross-border writes |
