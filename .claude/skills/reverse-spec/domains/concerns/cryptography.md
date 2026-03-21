# Concern: cryptography (reverse-spec)

> Cryptographic operations detection. Identifies key management, encryption, signing, and KDF patterns.

## R1. Detection Signals

> See [`shared/domains/concerns/cryptography.md`](../../../shared/domains/concerns/cryptography.md) § Code Patterns

## R3. Analysis Depth Modifiers

When detected, include in analysis:
- Algorithms used (symmetric, asymmetric, hashing, KDF)
- Key storage and management (HSM, KMS, vault, env vars)
- Nonce/IV generation strategy
- Random number source (CSPRNG verification)
- Compliance requirements (FIPS, PCI-DSS)
- Key rotation and lifecycle patterns
