# Concern: polyglot

> Multi-language codebases with cross-language bridges (FFI, Protobuf, gRPC).

---

## S0. Signal Keywords

> See [`shared/domains/concerns/polyglot.md`](../../../shared/domains/concerns/polyglot.md) § Signal Keywords
>
> _(Define Signal Keywords in the shared module, not here.)_

---

## S1. SC Generation Rules

### Required SC Patterns

| Pattern | SC Requirement |
|---------|----------------|
| Cross-language function call | SC must verify the call succeeds with correct argument types and return value across the bridge |
| IDL/Proto change | SC must verify all language stubs are regenerated and compile after IDL modification |
| Bridge error propagation | SC must verify errors thrown in one language are correctly caught/translated in the calling language |
| Type mapping | SC must verify language-specific types (e.g., Rust `Vec<u8>` ↔ Python `bytes`) roundtrip without data loss |

### SC Anti-Patterns (reject if seen)

- "Bridge works correctly" — too vague; must specify which function, which types, which direction
- "Code compiles in both languages" — compilation alone doesn't verify bridge correctness
- "Data is passed between languages" — must specify type, size constraints, and error cases

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|-----------------|
| Source-of-truth | Which language owns the canonical implementation? Is the other a binding/mirror? |
| Bridge mechanism | FFI (PyO3, cgo, JNI, NAPI)? IDL (Protobuf, Thrift)? WASM? Shared library? |
| Type contract | How are types mapped across languages? Auto-generated stubs or manual bindings? |
| Build orchestration | Single build command or per-language? Build order dependencies? |
| Test strategy | Per-language unit tests + cross-language integration tests? Which language runs integration? |
| Performance boundary | Where is the performance-critical path? Does the bridge introduce measurable overhead? |

---

## S7. Bug Prevention

| ID | Pattern | Detection | Prevention |
|----|---------|-----------|------------|
| PLY-001 | Stale generated stubs | IDL/Proto file modified but generated stubs not regenerated | Pre-build step: always regenerate from IDL; verify with checksum or timestamp |
| PLY-002 | Type mismatch across bridge | Rust returns `Option<T>`, Python caller assumes non-null | Bridge functions must have explicit null/error handling on both sides |
| PLY-003 | Memory ownership confusion | Rust allocates, Python frees (or vice versa) → double-free or leak | Document ownership per bridge function; use language-native ownership (e.g., PyO3 manages Python objects) |
| PLY-004 | Build order race | Go module built before Proto stubs generated | Build script must enforce: IDL generate → compile all languages → link/test |
| PLY-005 | Inconsistent error codes | Python raises `ValueError`, Rust returns `Err(...)`, Go returns `error` — no mapping | Define shared error code enum in IDL or bridge layer; map per-language exceptions |
