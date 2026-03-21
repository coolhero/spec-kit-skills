# Interface: library

> Libraries, SDKs, and frameworks consumed by other applications via linking, importing, or embedding.
> The "interface" is the public API surface, not an HTTP endpoint or CLI command.

---

## Signal Keywords

### Semantic (S0 — for init inference)

**Primary**: library, SDK, framework, package, module, API surface, public API, exports, bindings, FFI

**Secondary**: semver, backward compatibility, ABI, header file, re-export, tree-shaking, bundle size, peer dependency, type definitions

### Code Patterns (R1 — for source analysis)

- Node.js: `"main"`, `"exports"`, `"types"` in package.json, `index.ts`, `index.js`, `declare module`
- Rust: `[lib]` in Cargo.toml, `pub fn`, `pub struct`, `pub trait`, `pub mod`, `#[no_mangle]`
- Python: `setup.py`, `pyproject.toml` with `[project]`, `__init__.py`, `__all__`, `py.typed`
- Go: no `func main()`, exported identifiers (capitalized), `go.mod` as module root
- C/C++: `.h` header files, `__declspec(dllexport)`, `__attribute__((visibility("default")))`, `.so`/`.dll`/`.dylib`
- Java: `pom.xml` with `<packaging>jar</packaging>`, `build.gradle` with `java-library` plugin
- TypeScript: `.d.ts` files, `declare`, `export type`, `export interface`

---

## Module Metadata

- **Axis**: Interface
- **Common pairings**: plugin-system, codegen
- **Archetypes**: sdk-framework, database-engine (embedded mode)
- **Profiles**: —
