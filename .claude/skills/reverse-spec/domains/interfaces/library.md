# Interface: library (reverse-spec)

> Library/SDK detection. Identifies packages consumed via import/linking rather than HTTP/CLI.

## R1. Detection Signals

> See [`shared/domains/interfaces/library.md`](../../../shared/domains/interfaces/library.md) § Code Patterns

## R3. Analysis Depth Modifiers

When detected, include in analysis:
- Public API surface (exported functions, types, traits, classes)
- Versioning strategy and backward compatibility posture
- Type definition exports (TypeScript .d.ts, Python py.typed, Rust doc)
- Bundle/package size and tree-shaking support
- Dependency policy (zero-dep, peer deps, optional deps)
- Error type taxonomy and consumer-facing error handling contract
