# Concern: auth (reverse-spec)

> Authentication detection. Identifies auth implementation patterns.

## R1. Detection Signals
- Libraries: `passport`, `next-auth`, `@auth0/*`, `firebase/auth`, `django.contrib.auth`
- JWT patterns: `jsonwebtoken`, `jose`, JWT middleware
- Session patterns: `express-session`, session stores
- OAuth config: OAuth provider configuration, redirect URIs
