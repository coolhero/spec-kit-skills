# Archetype: sdk-framework

> Libraries, SDKs, and frameworks consumed by other developers — not end-user applications.

---

## Signal Keywords

### Semantic (A0 — for init inference)

**Primary**: SDK, framework, library, package, pip install, npm publish, crate, gem, NuGet, PyPI, public API, developer tools, developer experience, DX

**Secondary**: semver, breaking change, backward compatibility, API surface, extension point, quickstart, getting started, contributor guide, CHANGELOG, migration guide, API reference, plugin interface, provider pattern, adapter pattern

### Code Patterns (A0 — for source analysis)

- **Package metadata**: `pyproject.toml [project]`, `setup.py`, `package.json` with `main`/`exports`, `Cargo.toml [package]`, `*.gemspec`, `*.nuspec`
- **Public API surface**: `__init__.py` with explicit `__all__`, `index.ts` barrel exports, `pub mod`/`pub fn` in Rust, `export` statements
- **Extension points**: abstract base classes, protocol classes (`typing.Protocol`), interface definitions, decorator-based registration (`@register`), plugin hooks
- **Examples/docs**: `examples/` directory, `docs/` directory, `quickstart` notebooks, `README` with install + usage
- **Versioning**: `CHANGELOG.md`, `MIGRATION.md`, `BREAKING_CHANGES.md`, semver tags, `__version__`
- **CI/publishing**: `pypi` publish workflows, `npm publish`, `cargo publish`, release automation

---

### Instrumentation/Wrapper Variant

Some SDKs don't provide new functionality but add observability/telemetry to existing libraries by wrapping or monkey-patching them.

**Detection signals**:
- Keywords: `instrument`, `patch`, `wrap`, `monkey_patch`, `auto_instrument`, `trace`, `span`
- Pattern: imports target library → wraps its methods → adds telemetry/logging/metrics
- Registration: `register_instrumentor()`, `auto_configure()`, zero-config initialization

**SBI extraction for instrumentation SDKs**:
- **P1**: Instrumentor registration/initialization (what gets patched and how)
- **P1**: Attribute extraction logic (what data is captured from wrapped calls)
- **P2**: Span/metric creation (telemetry output format)
- **P2**: Configuration options (enable/disable, sampling, filtering)
- **P3**: Internal utility functions

**Feature decomposition**: Use Repeating-Pattern strategy (see analyze-classify.md) — one template instrumentor + framework + variant list per wrapped library.

---

## Module Metadata

- **Axis**: Archetype
- **Typical interfaces**: cli, http-api
- **Common pairings**: plugin-system, codegen, polyglot
