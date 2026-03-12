# Business Logic Map

**Source**: [Original source path]
**Generated**: [DATE]

> Used as a preliminary reference when writing acceptance criteria during spec-kit /speckit.specify.
> When writing specs for each Feature, verify that all business rules documented here are
> fully reflected in Requirements and Success Criteria.

---

## Logic Index

| Feature | Rules | Validations | Workflows | Cross-Feature Rules |
|---------|-------|-------------|-----------|-------------------|
| F001-auth | [N] | [N] | [N] | [N] |
| F002-product | [N] | [N] | [N] | [N] |

---

## F001-auth

### Core Rules

| Rule ID | Description | Related Entity | Original Location |
|---------|-------------|---------------|-------------------|
| BR-001 | Email must be unique across the entire system | User | `[file]:[line]` |
| BR-002 | Passwords must be hashed with bcrypt before storage | User | `[file]:[line]` |
| BR-003 | JWT token validity period is 24 hours | User | `[file]:[line]` |
| BR-004 | Account locked for 30 minutes after 5 failed login attempts | User | `[file]:[line]` |

### Validation Logic

| Validation ID | Target | Condition | Error Message | Original Location |
|---------------|--------|-----------|---------------|-------------------|
| VL-001 | email | RFC 5322 email format | "Please enter a valid email address" | `[file]:[line]` |
| VL-002 | password | Min 8 chars, upper+lower+digits+special chars | "Password format is invalid" | `[file]:[line]` |

### Workflows

#### User Registration Flow

```
1. Check email uniqueness → Return 409 if duplicate
2. Hash password
3. Create User entity
4. Send welcome email (async)
5. Issue JWT token
6. Return response
```

**Original Location**: `[file]:[line]`
**Related Entity**: User
**Side Effects**: Email dispatch (depends on F007-notification)

#### Login Flow

```
1. Look up User by email → 401 if not found
2. Check account lock status → 403 if locked
3. Verify password → Increment failure count on mismatch
4. If failure count >= 5, lock account
5. On success, reset failure count
6. Issue JWT token
7. Update last login timestamp
```

**Original Location**: `[file]:[line]`
**Related Entity**: User
**State Transition**: active → locked (after 5 failures)

### Cross-Feature Rules

| Rule ID | Description | Related Features | Original Location |
|---------|-------------|-----------------|-------------------|
| XR-001 | All authenticated API endpoints must pass through Bearer token verification middleware | All | `[file]:[line]` |
| XR-002 | When a user is deleted, related order data must be soft-deleted | F003-order | `[file]:[line]` |

### Cross-Feature Interaction Rules

> Behavioral dependencies between Features that go beyond entity/API data rules.
> These capture "when Feature A does X, Feature B must do Y" relationships.
> Populated from Phase 3-1d interaction analysis where shared business rules (weight 3) were detected.

| Rule ID | Trigger Feature | Trigger Action | Affected Feature | Required Response | Failure Impact |
|---------|----------------|----------------|-----------------|-------------------|----------------|
| XIR-001 | [F00N-feature] | [User action or system event — e.g., "User account deleted"] | [F00N-feature] | [What the affected Feature must do — e.g., "Soft-delete associated order data"] | [What happens if response is missed — e.g., "Orphaned orders with invalid user references"] |

> **How to use**: During `/speckit.specify`, ensure both the trigger Feature and affected Feature have FR-### entries covering this interaction. During `/smart-sdd verify`, check that the trigger-response chain actually works at runtime (Phase 2 Cross-Feature Consistency).

---

<!-- Repeat the above format for each Feature -->
