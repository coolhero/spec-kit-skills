# Interface: library

> Libraries, SDKs, and frameworks consumed via linking, importing, or embedding.
> The "interface" is the public API surface, not an HTTP endpoint or CLI command.
> Module type: interface

---

## S0. Signal Keywords

> See [`shared/domains/interfaces/library.md`](../../../shared/domains/interfaces/library.md) § Signal Keywords

---

## S1. SC Generation Rules

### Required SC Patterns
- Public API contract: specify exported functions/types/traits with input types, return types, and error types. Verify API matches documented signature
- Error handling: specify error types returned by public API. Callers must be able to match/handle all error variants without catching generic exceptions
- Backward compatibility: new versions do not break existing callers. Verify: compile existing consumer code against new version without changes (semver minor/patch)
- Type exports: all public types are exported and documented. TypeScript: `.d.ts` accurate. Rust: `pub` items documented. Python: `py.typed` marker + type stubs

### SC Anti-Patterns (reject)
- "API is stable" — must specify which APIs are public vs internal, and versioning policy
- "Errors are handled" — must specify error type taxonomy and what callers should do for each
- "Works as a library" — must specify public API surface, import path, and minimum consumer requirements

### SC Measurability Criteria
- Bundle size / package size within budget
- Import time / initialization latency
- API surface size (number of public exports)

---

## S1. Demo Pattern (override)

- **Type**: Test-harness-based (not server or app)
- **Default mode**: Import library → call key APIs with sample data → verify output → print results
- **CI mode**: Run test suite → verify all public APIs exercised → check type exports
- **"Try it" instructions**: `npm install` / `cargo add` / `pip install` → sample code snippet

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| **API Surface** | Which functions/types are public? Namespace/module organization? |
| **Versioning** | Semver? What constitutes a breaking change? Deprecation policy? |
| **Bundling** | Tree-shakeable? ESM + CJS? Bundle size budget? |
| **Types** | TypeScript types? Rust trait bounds? Python type hints? |
| **Dependencies** | Peer deps? Optional deps? Zero-dependency goal? |

---

## S9. Brief Completion Criteria

| Required Element | Completion Signal |
|-----------------|-------------------|
| Public API surface | Key exports (functions, types, classes) identified |
| Consumer pattern | How consumers import/use the library described |
| Error contract | Error types and handling expectations stated |

---

## S8. Runtime Verification Strategy

| Field | Value |
|-------|-------|
| **Start method** | N/A — libraries are consumed, not started |
| **Verify method** | Import library in test harness → call public API → verify return values and types. Backend: test runner (jest, pytest, cargo test) |
| **Stop method** | N/A |
| **SC classification extensions** | `lib-auto` — API contract SCs verifiable via test harness; `lib-compat` — backward compatibility SCs verifiable via consumer compilation test |

**Library-specific verification**:
- API contract SCs: call each public API with valid/invalid inputs → verify return type and error type
- Backward compatibility SCs: compile/import from consumer project on previous version → no breaking changes
- Type export SCs: verify `.d.ts` / `py.typed` / doc comments cover all public APIs
