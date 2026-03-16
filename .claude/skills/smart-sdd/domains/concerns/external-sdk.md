# Concern: external-sdk

> Third-party SDK integration (AI SDKs, payment SDKs, cloud SDKs, etc.).
> Applies when the project integrates with external SDKs that have their own type systems and APIs.
> Module type: concern

---

## S0. Signal Keywords

> See [`shared/domains/concerns/external-sdk.md`](../../../shared/domains/concerns/external-sdk.md) § Signal Keywords

---

## S1. SC Generation Rules

### Required SC Patterns
- SDK calls: specify input parameters + expected return type + error handling
- SDK configuration: specify required config fields + validation
- SDK version constraints: specify minimum version if API compatibility matters

### SC Anti-Patterns (reject)
- "SDK integration works" — must specify which SDK function, input, and expected output

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| **SDK selection** | Which SDKs? Version constraints? |
| **API surface** | Which SDK functions/methods used? Synchronous or async? |
| **Error handling** | SDK-specific error types? Retry strategy? Fallback? |

---

## S7. Bug Prevention Rules

When this concern is active, enforce:
- SDK API Contract Gap: SDK function expects callable/executable object but code passes metadata-only object. Build passes (loose types), runtime silently fails. See `injection/implement.md` § Pattern Compliance Scan
- Loose Type Bypass: `Record<string, unknown>`, `any`, or untyped object passed to SDK where SDK expects specific shape. See `injection/implement.md` § Pattern Compliance Scan
- External SDK Type Trust Classification (High/Medium/Low trust levels):
  - High trust: sync pure functions — use type definitions directly
  - Medium trust: async functions — add runtime validation for return values
  - Low trust: stream events, experimental APIs — always validate at runtime, never trust .d.ts alone
  See `injection/implement.md` § External SDK Type Trust Classification

---

## S7b. Large-Scale Provider Abstraction

> When a project integrates 5+ external providers through a unified abstraction layer (e.g., Vercel AI SDK for 20+ LLM providers), additional SC and verification rules apply.

### Detection
- Unified SDK/adapter pattern: single interface, multiple provider implementations
- Provider registry or factory pattern
- Provider-specific configuration (API keys, endpoints, model names)

### Additional SC Rules
- **Abstraction layer SC**: The unified interface itself must have SCs (not just individual providers)
- **Provider fallback chain**: If provider A fails → fallback to provider B → verify fallback behavior
- **Provider-specific edge cases**: Each provider may have unique constraints (rate limits, token limits, response format differences) — SC for edge cases per active provider
- **Mock strategy**: Test against mock provider that validates request/response contract (not real API calls in CI)

### Verification
- At minimum, verify against 2 providers: one primary + one alternative
- Verify provider switching at runtime (if supported) doesn't lose state
- Verify auth credential isolation per provider (no cross-contamination)
