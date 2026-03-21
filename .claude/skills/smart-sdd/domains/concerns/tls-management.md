# Concern: tls-management

> TLS/certificate lifecycle — provisioning, rotation, mTLS, and SNI routing.
> Module type: concern

---

## S0. Signal Keywords

> See [`shared/domains/concerns/tls-management.md`](../../../shared/domains/concerns/tls-management.md) § Signal Keywords

---

## S1. SC Generation Rules

### Required SC Patterns
- Certificate provisioning: ACME challenge (HTTP-01/DNS-01) → CA issues certificate → install in server → verify TLS handshake succeeds
- Certificate rotation: detect approaching expiry → provision new certificate → atomic swap → verify zero-downtime → revoke old if needed
- mTLS handshake: server presents cert → client presents cert → server validates client cert against CA bundle → check CRL/OCSP → establish session or reject
- SNI routing: client sends SNI hostname → server selects matching certificate → TLS handshake with correct cert → route to appropriate backend

### SC Anti-Patterns (reject)
- "TLS is enabled" — must specify certificate source (ACME, manual, self-signed), minimum TLS version, cipher suites, and certificate validation behavior
- "Certificates are renewed" — must specify renewal trigger (time-based, threshold), automation mechanism, rollback plan on failure, and monitoring
- "Client authentication works" — must specify client cert issuance, CA trust chain, revocation checking method (CRL vs OCSP), and behavior on validation failure

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| **Provisioning** | ACME (Let's Encrypt)? Self-managed CA? Cloud provider (ACM, Cloud SSL)? Challenge type? |
| **Rotation** | Automated or manual? Rotation frequency? Grace period before expiry? Rollback procedure? |
| **mTLS** | Client cert required for all endpoints or specific paths? CA bundle management? Revocation checking? |
| **Configuration** | Minimum TLS version (1.2/1.3)? Cipher suite allowlist? HSTS? Certificate transparency? |
| **Monitoring** | Expiry alerting? Certificate chain validation? OCSP stapling? CT log monitoring? |

---

## S7. Bug Prevention — TLS-Specific

| ID | Pattern | Detection | Prevention |
|----|---------|-----------|------------|
| TLS-001 | Expired certificate in production | Certificate expires → TLS handshake fails → all clients get connection errors → full outage | Automated renewal with threshold (e.g., 30 days before expiry); monitoring alerts at multiple thresholds; runbook for manual renewal |
| TLS-002 | Missing OCSP stapling | Server does not staple OCSP response → client makes separate OCSP request → latency increase; OCSP responder down → soft-fail allows revoked cert | Enable OCSP stapling; cache OCSP responses; configure must-staple extension for critical certs |
| TLS-003 | Key material in logs | Private key or certificate contents logged during debugging → exposed in log aggregation → key compromise | Never log key material; sanitize TLS error messages; use structured logging that excludes sensitive fields |
| TLS-004 | Certificate pinning break | Server rotates certificate → pinned clients reject new cert → client-side outage with no server-side indication | Use backup pins; pin to CA/intermediate, not leaf; implement pin expiry; provide pin update mechanism |
| TLS-005 | Incomplete certificate chain | Server sends leaf cert without intermediates → clients without cached intermediates fail validation → intermittent TLS errors | Always send full chain (leaf + intermediates); validate chain completeness in CI/CD; test with empty trust store |
