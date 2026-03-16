# Archetype: sdk-framework

> Libraries, SDKs, and frameworks consumed by other developers — not end-user applications.

---

## A0. Signal Keywords

> See [`shared/domains/archetypes/sdk-framework.md`](../../../shared/domains/archetypes/sdk-framework.md) § Signal Keywords

---

## A1. Analysis Axes — SDK/Framework Philosophy Extraction

When source code is identified as a library/SDK/framework, extract these design dimensions:

### API Surface Analysis

- **Public exports**: Identify all explicitly exported symbols (`__all__`, barrel `index.ts`, `pub` in Rust)
- **Internal vs public boundary**: How does the codebase separate public API from implementation details?
- **API versioning signals**: CHANGELOG, deprecation decorators (`@deprecated`), version-gated imports

### Extension Model Analysis

- **Extension mechanism**: Abstract classes, Protocol/Interface definitions, decorator-based registration, hook systems, dependency injection containers, mixin composition
- **Extension discovery**: File-system scanning, entry points (`[project.entry-points]`), explicit registration, config-driven (`type: "redis"` → class lookup)
- **Extension contract**: What must an extension implement? Required methods, lifecycle hooks, configuration schema

### Consumer Pattern Analysis

- **Example inventory**: `examples/` directory structure, notebook quickstarts, README usage snippets
- **Integration test patterns**: Do tests exercise the public API surface? Or only internal implementation?
- **Documentation structure**: API reference generation (Sphinx, TypeDoc, rustdoc), tutorial/guide organization

### Dependency Architecture

- **Core vs optional**: Which dependencies are required vs extras/optional groups (`[project.optional-dependencies]`)?
- **Plugin dependency isolation**: Do plugins/extensions have their own dependency sets?
- **Version constraint strategy**: Pinned, range, or minimal version requirements?
