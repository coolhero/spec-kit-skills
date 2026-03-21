# Concern: cryptography

> Cryptographic operations — key management, encryption/decryption, digital signatures, and key derivation.
> Module type: concern

---

## S0. Signal Keywords

> See [`shared/domains/concerns/cryptography.md`](../../../shared/domains/concerns/cryptography.md) § Signal Keywords

---

## S1. SC Generation Rules

### Required SC Patterns
- Key generation: generate key pair (or symmetric key) → store in secure backend (HSM, KMS, vault) → metadata recorded → rotation schedule established
- Encrypt/decrypt: plaintext → generate unique nonce/IV → encrypt with key + nonce → produce ciphertext + auth tag → decrypt with same key + nonce → verify auth tag → recover plaintext
- Digital signatures: compute hash of message → sign with private key → produce signature → recipient verifies signature with public key → reject if tampered
- Key derivation: user password → apply KDF (Argon2id/scrypt/bcrypt) with salt and tuned cost parameters → derived key → store salt + parameters alongside hash

### SC Anti-Patterns (reject)
- "Data is encrypted" — must specify algorithm (AES-256-GCM, ChaCha20-Poly1305), key management (where stored, rotation policy), and nonce/IV generation strategy
- "Passwords are hashed" — must specify KDF (Argon2id, scrypt, bcrypt), cost parameters, salt generation, and upgrade path for increasing cost over time
- "Signatures are verified" — must specify algorithm (Ed25519, RSA-PSS, ECDSA), key distribution mechanism, and behavior on verification failure

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| **Algorithms** | Symmetric (AES-GCM, ChaCha20)? Asymmetric (RSA, Ed25519, X25519)? Hash functions (SHA-256, SHA-3, BLAKE3)? |
| **Key management** | Where are keys stored (HSM, KMS, vault, env vars)? Rotation frequency? Key hierarchy (master → data keys)? |
| **KDF** | Which KDF (Argon2id, scrypt, bcrypt)? Cost parameters? Salt length? Pepper used? |
| **Random** | CSPRNG source? OS-provided (/dev/urandom, CryptGenRandom)? Library (libsodium, BoringSSL)? |
| **Compliance** | FIPS 140-2/3? PCI-DSS? HIPAA? Audit requirements? |

---

## S7. Bug Prevention — Cryptography-Specific

| ID | Pattern | Detection | Prevention |
|----|---------|-----------|------------|
| CRY-001 | Hardcoded keys | Encryption key embedded in source code or config file → key extraction trivial → all encrypted data compromised | Store keys in HSM/KMS/vault only; scan for key patterns in CI; reject hardcoded keys in code review |
| CRY-002 | Nonce reuse | Same nonce used with same key for two different plaintexts → AES-GCM auth tag forgery, plaintext XOR recovery | Use random nonces (96-bit for AES-GCM) or counter-based nonces with persistence; never derive nonce from plaintext |
| CRY-003 | Non-constant-time comparison | Signature or MAC verification uses early-exit comparison → timing side channel → byte-by-byte forgery | Use constant-time comparison (e.g., crypto.timingSafeEqual, CRYPTO_memcmp); never use == or memcmp for secret comparison |
| CRY-004 | Weak random source | Math.random() or similar non-CSPRNG used for key generation or nonce → predictable values → key recovery | Use only CSPRNG (crypto.getRandomValues, os.urandom, SecureRandom); lint for weak random in crypto contexts |
| CRY-005 | Key material in logs | Private key, symmetric key, or derived key logged during debugging → exposed in log aggregation → key compromise | Never log key material; use key IDs for reference; sanitize error messages containing crypto state |
