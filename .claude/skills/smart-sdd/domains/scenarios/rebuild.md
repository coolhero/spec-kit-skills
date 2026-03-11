# Scenario: rebuild

> Preserve existing behavior while changing the implementation environment.
> Covers: stack migration, platform migration, framework upgrade, language migration, architecture refactoring, vendor switch.
> Module type: scenario

---

## Configuration Parameters

| Parameter | Values | Consumed By |
|-----------|--------|-------------|
| `change_scope` | `stack`, `platform`, `framework`, `language`, `architecture`, `vendor` | S5 (probes), S7 (bug prevention) |
| `preservation_level` | `exact`, `equivalent`, `functional` | S1 (SC depth), S3 (verify criteria) |
| `source_available` | `running`, `code-only`, `docs-only` | S3 (verify Step 3e, Step 3b) |
| `migration_strategy` | `big-bang`, `incremental`, `strangler-fig` | S3 (regression gate), Demo guidance |

> Set during reverse-spec Phase 0. Stored in `roadmap.md` Strategy line → propagated to `sdd-state.md` Rebuild Configuration section during pipeline initialization.

### change_scope Categories

Group the six values into three categories for probe and rule selection:

| Category | Values | Focus |
|----------|--------|-------|
| **Code-level** | `language`, `framework`, `vendor` | API mapping, library replacement, idiom translation. Runtime environment stays the same |
| **Platform-level** | `platform`, `architecture` | Infrastructure, deployment, runtime constraints change. Code patterns may stay similar |
| **Stack-level** | `stack` | Full migration — combines Code-level + Platform-level concerns |

---

## S1. SC Rules (extends _core)

### Preservation SC Generation
- For each existing behavior (SBI P1/P2):
  generate "Given [same input] -> [equivalent output]" SC
- `preservation_level` determines SC depth requirements:

| Level | SC Depth Requirement | Anti-pattern |
|-------|---------------------|--------------|
| `exact` | SC must specify exact expected values (byte-level response body, pixel-level UI) | "should produce equivalent output" (too vague) |
| `equivalent` | SC must define what "equivalent" means per case (same data shape, same outcome) | "should produce the same result" (no comparison dimension) |
| `functional` | SC specifies the user goal achieved, not implementation detail | "should work the same way" (implementation-focused) |

### Change-Boundary SC Generation
- Identify what IS changing (new stack/platform APIs)
- Generate SCs for: new dependency integration, new deployment, new configuration
- Old-system-specific implementation details should NOT appear in new SCs

---

## S3. Verify Steps (extends _core)

| Step | Required | Condition | Description |
|------|----------|-----------|-------------|
| Preservation SC Depth Validation | BLOCKING | Always (rebuild) | Verify each Preservation SC has depth matching `preservation_level`. SC declared as `exact` must be tested with exact comparison, not semantic |
| Migration Regression Gate | BLOCKING | Always (rebuild) | After each Feature: run previously passing SCs. Scope varies by `migration_strategy` (see below) |
| Visual Fidelity (preservation-aware) | Conditional | `gui` interface active | Comparison severity varies by `preservation_level` (see below) |
| Source App Comparison | Optional | `source_available: running` | Side-by-side comparison. See [verify-phases.md](../../commands/verify-phases.md) Step 3e |
| Source Behavior Completeness | BLOCKING (P1) | Always (rebuild) | Coverage requirement varies by `migration_strategy` |

### Migration Regression Gate by strategy

| Strategy | Scope | Merge Condition |
|----------|-------|-----------------|
| `big-bang` | ALL P1+P2 behaviors across ALL Features | All Features must pass before any can merge. Batch verification |
| `incremental` | P1 for current Feature + all previously merged Features | Per-Feature merge allowed. Running regression on merged Features |
| `strangler-fig` | Same as incremental + coexistence health check | Per-Feature merge allowed. Old system health check included |

### Visual Fidelity by preservation_level

| Level | Severity |
|-------|----------|
| `exact` | Visual deviations are ⚠️ HIGH WARNING (pixel-level match expected) |
| `equivalent` | Structural deviations are ⚠️ WARNING; minor spacing/color differences informational |
| `functional` | Visual fidelity check is informational only (UI may be intentionally redesigned) |

### Source App Comparison by preservation_level

| Level | Comparison Criteria |
|-------|-------------------|
| `exact` | Byte-level response comparison (API), pixel-level screenshot comparison (UI). Any deviation = ⚠️ WARNING |
| `equivalent` | Data shape and semantic comparison. Format differences (JSON key order, whitespace) ignored. Same data values required |
| `functional` | Goal-level comparison. Same user flow produces same outcome. UI appearance and API format may differ |

### Behavioral Parity by source_available

| Availability | Verification Approach |
|-------------|----------------------|
| `running` | Side-by-side comparison via runtime backend. See [runtime-verification.md](../../reference/runtime-verification.md) and [user-cooperation-protocol.md](../../reference/user-cooperation-protocol.md) |
| `code-only` | SBI-based verification — each P1/P2 behavior has corresponding test in new system |
| `docs-only` | SC-based verification only — no automated parity; rely on SC pass/fail |

---

## S5. Elaboration Probes (extends _core)

### Generic Probes (all rebuild cases)

| Category | Probes |
|----------|--------|
| **Change scope** | What exactly is being replaced? What stays the same? |
| **Constraints** | New environment limitations vs old? Performance requirements changed? |
| **Data** | Data migration needed? Schema changes? Format conversions? |
| **Coexistence** | Must old and new coexist during transition? How long? |
| **Rollback** | Can we revert to old system if issues found? Rollback criteria? |

### Per-Category Probes (filtered by change_scope category)

| Category | Probes |
|----------|--------|
| **Code-level** (language, framework, vendor) | What is the API/library mapping between old and new? Which patterns are framework-specific vs business logic? Are there vendor-specific data formats or SDKs to replace? |
| **Platform-level** (platform, architecture) | What deployment/infrastructure changes are required? New runtime constraints (memory model, concurrency, file system access)? Platform-specific APIs to replace? |
| **Stack-level** (stack) | Combines Code-level + Platform-level probes. Additionally: full dependency tree replacement plan? Which third-party services change? |

### Per-Strategy Probes (filtered by migration_strategy)

| Strategy | Probes |
|----------|--------|
| **big-bang** | Cutover plan? Downtime tolerance? Full rollback procedure? Verification environment for batch testing? |
| **incremental** | Feature ordering for transition? Backward compatibility during coexistence? Shared state management between old and new? |
| **strangler-fig** | Routing strategy (path-based, feature flags, subdomain)? Shared database access patterns? Session management across old/new systems? |

---

## S7. Bug Prevention Rules

| Rule | Stage | Condition | Description |
|------|-------|-----------|-------------|
| Preservation Depth Mismatch | verify | Always | SC declares `exact` preservation but verification uses semantic comparison → escalate to HARD STOP |
| Implicit Behavior Loss | implement | Always | Source file listed in pre-context Source Reference has no corresponding implementation AND no exclusion record in coverage-baseline |
| Framework Pattern Leak | implement | Code-level | Using old framework idioms in new framework code (e.g., jQuery patterns in React, synchronous patterns in async framework) |
| Platform Assumption | implement | Platform-level | Using platform-specific APIs not available in target platform (e.g., `fs.readFileSync` in browser, desktop-only APIs in web app) |
| Coexistence Data Conflict | implement | `strangler-fig` | New system writes to shared database without checking old system's constraints or data format expectations |
| Big-Bang Incomplete Merge | verify | `big-bang` | Attempting to merge a Feature when P1 SBI coverage < 100% across all Features |
