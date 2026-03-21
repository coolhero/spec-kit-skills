# Concern: compliance

> Regulatory frameworks (HIPAA, PCI-DSS, GDPR, SOX), data retention policies, consent management, audit trails, data classification, right to erasure.

---

## Signal Keywords

### Semantic (S0 — for init inference)

**Primary**: compliance, GDPR, HIPAA, PCI-DSS, SOX, data retention, consent management, audit trail, regulatory, data classification

**Secondary**: right to erasure, data subject request, consent record, data processing agreement, privacy policy, data controller, data processor, breach notification, retention policy, access control audit, SOC 2, CCPA, FERPA, data lineage, anonymization, pseudonymization

### Code Patterns (R1 — for source analysis)

- Consent: `consent_records`, `data_subject_requests`, `gdpr_consent`, cookie consent banners, preference center
- Retention: `retention_policy`, `data_expiry`, TTL-based deletion, scheduled purge jobs
- Audit: `audit_log`, `compliance_event`, immutable append-only tables, change data capture
- Classification: `data_classification`, `sensitivity_level`, PII detection, field-level encryption
- Patterns: `@PersonalData`, `@Sensitive`, `redact()`, `anonymize()`, `pseudonymize()`, `consentRequired`

---

## Module Metadata

- **Axis**: Concern
- **Common pairings**: auth, authorization, audit-logging
- **Profiles**: —
