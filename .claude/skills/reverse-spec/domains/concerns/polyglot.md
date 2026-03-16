# Concern: polyglot

> Multi-language codebases with cross-language bridges (FFI, Protobuf, gRPC).

---

## R1. Detection Signals

> See [`shared/domains/concerns/polyglot.md`](../../../shared/domains/concerns/polyglot.md) § Code Patterns

### Additional Detection Heuristics

- **Multi-build-file test**: Count distinct build system files at project root. 2+ of: `Cargo.toml`, `pyproject.toml`/`setup.py`, `go.mod`, `package.json`, `pom.xml`/`build.gradle`, `*.csproj`/`*.sln` → polyglot.
- **Bridge directory patterns**: `bindings/`, `bridge/`, `ffi/`, `native/`, `wasm/`, `crates/` alongside Python/JS/Go source.
- **Generated stub co-location**: `*_pb2.py` + `*.pb.go` + `*_grpc.java` in the same proto output tree.

---

## R3. Analysis Axes — Cross-Language Bridge Extraction

When polyglot concern is detected, extract:

| Axis | What to Extract | Output Format |
|------|-----------------|---------------|
| Language map | Each language's role (primary, binding, performance, generated) and file count | `{language: role, files: N}` per language |
| Bridge points | Functions/types exposed across language boundary | Bridge Registry: `{function, source_lang, target_lang, mechanism}` |
| IDL definitions | Proto/Thrift/IDL files and their generated outputs | `{idl_file → [generated_files]}` mapping |
| Build dependency graph | Which language must build first; cross-language build ordering | Ordered build stages |
| Shared types | Types that exist in multiple languages (possibly auto-generated) | Type Mapping Table: `{type_name, lang_A_repr, lang_B_repr}` |
