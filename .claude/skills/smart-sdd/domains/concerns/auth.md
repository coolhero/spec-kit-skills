# Concern: auth

> Authentication and authorization patterns.
> Applies when the project implements user authentication or access control.
> Module type: concern

---

## S1. SC Generation Rules

### Required SC Patterns
- Login: specify credentials format + success response (token/session) + failure response
- Protected resources: specify auth header/cookie + authorized response + unauthorized (401) + forbidden (403)
- Token lifecycle: specify issuance + expiration + refresh mechanism

### SC Anti-Patterns (reject)
- "Authentication works" — must specify auth method, token format, and error responses
- "Access is controlled" — must specify which roles/permissions and what happens when denied

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| **Auth method** | JWT? Session? OAuth? API key? Multi-factor? |
| **Authorization** | Role-based? Permission-based? Resource-level? |
| **Token management** | Expiration? Refresh? Revocation? |
| **Session** | Server-side? Cookie-based? Concurrent session limits? |
