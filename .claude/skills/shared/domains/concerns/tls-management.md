# Concern: tls-management

> TLS/mTLS certificate lifecycle: ACME provisioning, certificate rotation, SNI routing, mutual authentication.

---

## Signal Keywords

### Semantic (S0 — for init inference)

**Primary**: TLS, SSL, certificate, mTLS, mutual TLS, ACME, Let's Encrypt, SNI, certificate rotation, HTTPS

**Secondary**: X.509, CA, certificate authority, private key, CSR, OCSP, CRL, TLS termination, TLS passthrough, cert-manager, trust store, PEM, PKCS

### Code Patterns (R1 — for source analysis)

- Go: `crypto/tls`, `tls.Config`, `autocert`, `certmagic`
- Rust: `rustls`, `tokio-rustls`, `native-tls`, `rcgen`
- Node.js: `tls.createServer`, `https.createServer`, `acme-client`
- Java: `SSLContext`, `KeyStore`, `TrustManagerFactory`, `X509TrustManager`
- Infra: `cert-manager.io`, `traefik.toml` (ACME), `nginx ssl_certificate`, `Caddyfile` (automatic HTTPS)
- ACME: `certbot`, `lego`, `acme.sh`, `boulder`

---

## Module Metadata

- **Axis**: Concern
- **Common pairings**: network-server (archetype), http-api, grpc
- **Profiles**: —
