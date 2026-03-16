# Concern: auth

> Authentication flows — JWT, OAuth, session management.

---

## Signal Keywords

### Semantic (S0 — for init inference)

**Primary**: authentication, authorization, JWT, OAuth, session, login, signup, RBAC, role-based, permissions, access control, SSO, SAML, Passport.js, Auth0, Clerk, NextAuth

**Secondary**: password reset, multi-factor, MFA, 2FA, token refresh, protected routes

### Code Patterns (R1 — for source analysis)

- Libraries: `passport`, `next-auth`, `@auth0/*`, `firebase/auth`, `django.contrib.auth`
- JWT patterns: `jsonwebtoken`, `jose`, JWT middleware
- Session patterns: `express-session`, session stores
- OAuth config: OAuth provider configuration, redirect URIs

---

## Module Metadata

- **Axis**: Concern
- **Common pairings**: http-api
- **Profiles**: web-api, fullstack-web
