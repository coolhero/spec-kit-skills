# Concern: external-sdk

> Third-party SDK integration (AI SDKs, payment SDKs, cloud SDKs, etc.).
> Applies when the project integrates with external SDKs that have their own type systems and APIs.
> Module type: concern

---

## S0. Signal Keywords

> Keywords that indicate this module should be activated. Used by Clarity Index signal extraction.

**Primary**: OpenAI, Anthropic, Stripe, AWS SDK, Google Cloud, Firebase, Twilio, SendGrid, third-party API, AI SDK, Vercel AI SDK, LangChain, payment SDK, cloud SDK
**Secondary**: API key, SDK version, rate limit, quota, webhook callback, SDK wrapper

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
