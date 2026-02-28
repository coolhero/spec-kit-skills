# API Registry

**Source**: [Original source path]
**Generated**: [DATE]
**Total Endpoints**: [N]

> Used as a preliminary reference when writing contracts/ during spec-kit /speckit.plan.
> When writing the plan for each Feature, directly reflect provided APIs into contracts/,
> and check contracts for consumed APIs in this registry to ensure compatibility.

---

## Endpoint Index

| Method | Path | Feature | Auth | Description |
|--------|------|---------|------|-------------|
| GET | /api/users | F001-auth | Bearer Token | List users |
| POST | /api/users | F001-auth | Public | Register user |
| GET | /api/products | F002-product | Bearer Token | List products |

---

## Cross-Feature API Dependencies

| API | Provider | Consumer(s) | Call Purpose |
|-----|----------|-------------|-------------|
| `POST /api/auth/verify` | F001-auth | F002-product, F003-order | Token verification |
| `GET /api/products/:id` | F002-product | F003-order, F005-cart | Product info lookup |

---

## F001-auth APIs

### POST /api/auth/register

**Original Source**: `[file path]:[line number]`
**Authentication**: Public (no authentication required)

#### Request

**Headers**:
| Header | Value | Required |
|--------|-------|----------|
| Content-Type | application/json | Y |

**Body**:
```json
{
  "email": "string (required, email format)",
  "password": "string (required, min 8 chars)",
  "name": "string (required)"
}
```

#### Response

**200 OK**:
```json
{
  "id": "uuid",
  "email": "string",
  "name": "string",
  "token": "string (JWT)"
}
```

**400 Bad Request**:
```json
{
  "error": "string",
  "details": [
    { "field": "string", "message": "string" }
  ]
}
```

**409 Conflict**:
```json
{
  "error": "Email already exists"
}
```

#### Dependencies
- **Entity**: User (create)
- **Called APIs**: None
- **Cross-Feature Consumers**: None (standalone endpoint)

---

### GET /api/auth/me

**Original Source**: `[file path]:[line number]`
**Authentication**: Bearer Token (required)

#### Request

**Headers**:
| Header | Value | Required |
|--------|-------|----------|
| Authorization | Bearer {token} | Y |

**Query Parameters**: None

#### Response

**200 OK**:
```json
{
  "id": "uuid",
  "email": "string",
  "name": "string",
  "role": "string"
}
```

**401 Unauthorized**:
```json
{
  "error": "Invalid or expired token"
}
```

#### Dependencies
- **Entity**: User (read)
- **Cross-Feature Consumers**: F002-product (user profile display), F003-order (orderer info)

---

<!-- Repeat the above format for each API group (per Feature) -->
