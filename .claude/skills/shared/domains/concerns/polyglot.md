# Concern: polyglot

> Multi-language codebases with cross-language bridges (FFI, Protobuf, gRPC).

---

## Signal Keywords

### Semantic (S0 — for init inference)

**Primary**: polyglot, multi-language, FFI, foreign function interface, PyO3, Maturin, cgo, JNI, NAPI, N-API, node-addon-api, Protobuf, gRPC, WASM bridge, Cython, SWIG, ctypes

**Secondary**: language bridge, cross-language, interop, binding generator, type stub, IDL, interface definition, native extension, mixed codebase

### Code Patterns (R1 — for source analysis)

- Build files: `Cargo.toml` + `pyproject.toml` coexist, `go.mod` + `package.json` coexist, `pom.xml` + `build.gradle` + `package.json` coexist
- Bridge code: `PyO3` (`#[pyfunction]`, `#[pyclass]`), `Maturin` config, `cgo` (`import "C"`), `JNI` (`native` methods), `NAPI` (`napi::bindgen_prelude`), `ctypes`, `cffi`, `Cython` (`.pyx`)
- IDL: `.proto` files with multi-language generated stubs, `.thrift`, `.flatbuffers`, `.capnp`
- WASM: `wasm-bindgen`, `wasm-pack`, `emscripten`, `.wasm` artifacts
- Type stubs: `.pyi` files mirroring Rust/C modules, TypeScript `.d.ts` for native modules

---

## Module Metadata

- **Axis**: Concern
- **Common pairings**: plugin-system, codegen
- **Profiles**: —
