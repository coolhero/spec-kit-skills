# Concern: tls-management (reverse-spec)

> TLS/certificate lifecycle detection. Identifies certificate provisioning, rotation, mTLS, and SNI patterns.

## R1. Detection Signals

> See [`shared/domains/concerns/tls-management.md`](../../../shared/domains/concerns/tls-management.md) § Code Patterns

## R3. Analysis Depth Modifiers

When detected, include in analysis:
- Certificate provisioning method (ACME, manual, cloud-managed)
- Rotation automation (cron-based, threshold-based, event-driven)
- mTLS configuration (client cert validation, CA bundle management, revocation)
- TLS version and cipher suite configuration
- OCSP stapling and certificate transparency
- Key storage mechanism (HSM, KMS, vault, filesystem)
