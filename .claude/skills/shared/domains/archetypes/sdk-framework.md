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

## Module Metadata

- **Axis**: Archetype
- **Typical interfaces**: cli, http-api
- **Common pairings**: plugin-system, codegen, polyglot
