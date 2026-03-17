# Archetype: sdk-framework

> Libraries, SDKs, and frameworks consumed by other developers — not end-user applications.

---

## A0. Signal Keywords

> See [`shared/domains/archetypes/sdk-framework.md`](../../../shared/domains/archetypes/sdk-framework.md) § Signal Keywords
>
> _(Define Signal Keywords in the shared module, not here.)_

---

## A1. Philosophy Principles

### API Stability

- **Description**: Public API changes follow semver. Breaking changes are documented, versioned, and migration-guided.
- **Implication**: Every Feature touching public API surface must include backward compatibility SC. Plan must flag breaking changes. Verify must diff public exports against previous version.

### Extension-First Design

- **Description**: Core functionality is minimal; features are added through extension points (providers, adapters, plugins, hooks) rather than monolithic expansion.
- **Implication**: New backend/provider/connector Features are scoped to the extension interface, not the core. SC must verify the extension works through the public plugin API, not internal wiring.

### Example-as-Contract

- **Description**: Example code and quickstart guides are executable contracts — if they break, the SDK is broken.
- **Implication**: Verify must run examples as integration tests. Demo script = example execution, not server startup. Example failure is BLOCKING.

### Documentation Parity

- **Description**: Public API changes require corresponding documentation changes in the same Feature.
- **Implication**: Plan must include doc update tasks for any public API change. Verify checks that new/modified exports have docstrings and appear in API reference.

---

## A2. SC Generation Extensions

### Required SC Patterns (append to S1)

| Pattern | SC Requirement |
|---------|----------------|
| Public API surface | SC must verify public exports match the intended API (no accidental exposure, no missing exports) |
| Backward compatibility | SC must verify existing public API signatures are unchanged (or deprecated with migration path) |
| Extension point contract | SC must verify new extensions implement the required interface and pass the extension test suite |
| Example execution | SC must verify all example scripts/notebooks in `examples/` execute without error |

### SC Anti-Patterns (reject if seen)

- "SDK works" — must specify which API, which consumer scenario, which version compatibility
- "Plugin loads" — must specify plugin implements full interface contract, not just init
- "Documentation updated" — must specify which exports are documented and where

### Feature Boundary Guidance

> **Extension-point scoping**: When the project is a framework with pluggable backends:
> - Each **extension interface** (e.g., "Offline Store interface", "LLM Provider interface") = one Feature defining the contract
> - Each **concrete implementation** (e.g., "Redis Online Store", "PostgreSQL Offline Store") = one Feature implementing the contract
> - The **core orchestrator** (e.g., "FeatureStore class", "Agent class") = one Feature
> - Do NOT create one Feature per consumer use-case; create Features per extension boundary

---

## A3. Elaboration Probes (append to S5)

| Sub-domain | Probe Questions |
|------------|-----------------|
| Distribution | How is the package distributed? (PyPI, npm, crates.io, Maven Central, internal registry) |
| API surface definition | Where is the public API defined? (`__init__.py __all__`, `index.ts` exports, `pub` visibility) |
| Versioning strategy | Semver? CalVer? How are breaking changes communicated? CHANGELOG format? |
| Extension model | Provider pattern? Adapter pattern? Plugin hooks? Mixin composition? Dependency injection? |
| Consumer persona | Who uses this SDK? (App developers, data scientists, platform engineers, AI agent builders) |
| Compatibility matrix | Which runtimes/versions are supported? (Python 3.9+, Node 18+, etc.) How is compatibility tested? |
| Example coverage | Do examples cover all major use cases? Are they tested in CI? |

---

## A4. Constitution Injection

> These principles are injected into `constitution-seed.md` when the sdk-framework archetype is active.

1. **Public API is the product** — treat every public export as a user-facing commitment. No accidental exposure. Use explicit `__all__`, barrel exports, or visibility modifiers.

2. **Extension interfaces are contracts** — once published, extension interfaces (abstract classes, protocols, plugin hooks) cannot change signatures without a major version bump and migration guide.

3. **Examples are tests** — every `examples/` script must execute in CI. If an example breaks, the release is broken.

4. **Backward compatibility by default** — new Features must not break existing consumer code. Deprecation warnings for at least one minor version before removal.

5. **Documentation ships with code** — public API without documentation is a bug. Docstrings on all public exports. API reference generated from source.

---

## A5. Brief Completion Criteria

| Required Element | Completion Signal |
|-----------------|-------------------|
| Public API surface | At least one public export/function/class described |
| Extension mechanism | How consumers extend the SDK (plugins, hooks, subclassing, composition) — or "none" |
| Target consumer | Who uses this SDK/framework (application developers, library authors, internal teams) |
| Compatibility scope | Minimum supported versions (language, runtime, OS) stated or "TBD" |
