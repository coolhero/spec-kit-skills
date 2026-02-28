# API Registry

**Source**: [원본 소스 경로]
**Generated**: [DATE]
**Total Endpoints**: [N]개

> spec-kit /speckit.plan 시 contracts/ 작성의 선행 참조로 사용됩니다.
> 각 Feature의 plan 작성 시, 제공 API는 contracts/에 그대로 반영하고,
> 소비 API는 이 레지스트리에서 계약을 확인하여 호환성을 보장하세요.

---

## Endpoint Index

| Method | Path | Feature | Auth | 설명 |
|--------|------|---------|------|------|
| GET | /api/users | F001-auth | Bearer Token | 사용자 목록 조회 |
| POST | /api/users | F001-auth | Public | 사용자 등록 |
| GET | /api/products | F002-product | Bearer Token | 상품 목록 조회 |

---

## Cross-Feature API Dependencies

| API | Provider | Consumer(s) | 호출 목적 |
|-----|----------|-------------|-----------|
| `POST /api/auth/verify` | F001-auth | F002-product, F003-order | 토큰 검증 |
| `GET /api/products/:id` | F002-product | F003-order, F005-cart | 상품 정보 조회 |

---

## F001-auth APIs

### POST /api/auth/register

**원본 소스**: `[파일 경로]:[라인 번호]`
**인증**: Public (인증 불필요)

#### Request

**Headers**:
| 헤더 | 값 | 필수 |
|------|-----|------|
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
- **Entity**: User (생성)
- **호출 API**: 없음
- **Cross-Feature Consumers**: 없음 (독립 엔드포인트)

---

### GET /api/auth/me

**원본 소스**: `[파일 경로]:[라인 번호]`
**인증**: Bearer Token (required)

#### Request

**Headers**:
| 헤더 | 값 | 필수 |
|------|-----|------|
| Authorization | Bearer {token} | Y |

**Query Parameters**: 없음

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
- **Entity**: User (조회)
- **Cross-Feature Consumers**: F002-product (사용자 프로필 표시), F003-order (주문자 정보)

---

<!-- 위 형식을 각 API 그룹(Feature)별로 반복 -->
