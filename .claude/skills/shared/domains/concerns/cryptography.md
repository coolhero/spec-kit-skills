# Concern: cryptography

> Cryptographic operations: key exchange, encryption/decryption, digital signatures, secure random, constant-time comparisons.
> Distinct from auth (application-level): this covers low-level cryptographic primitives and protocol security.

---

## Signal Keywords

### Semantic (S0 — for init inference)

**Primary**: encryption, decryption, key exchange, digital signature, AES, ChaCha20, Ed25519, X25519, ECDH, HMAC, hash, SHA-256

**Secondary**: key derivation, KDF, PBKDF2, scrypt, Argon2, nonce, IV, GCM, CBC, constant-time, side-channel, key rotation, envelope encryption, HSM, vault

### Code Patterns (R1 — for source analysis)

- Go: `crypto/aes`, `crypto/ed25519`, `crypto/x509`, `golang.org/x/crypto`, `crypto/rand`
- Rust: `ring`, `rustcrypto`, `sodiumoxide`, `age`, `orion`, `rand::rngs::OsRng`
- Node.js: `crypto`, `sodium-native`, `tweetnacl`, `jose`, `node:crypto`
- Python: `cryptography`, `nacl`, `hashlib`, `secrets`, `pycryptodome`
- Java: `javax.crypto`, `Cipher`, `KeyGenerator`, `MessageDigest`, `BouncyCastle`
- Patterns: `encrypt()`, `decrypt()`, `sign()`, `verify()`, `deriveKey()`, `generateKeyPair()`

---

## Module Metadata

- **Axis**: Concern
- **Common pairings**: wire-protocol, tls-management, auth
- **Profiles**: —
