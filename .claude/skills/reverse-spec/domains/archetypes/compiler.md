# Archetype: compiler (reverse-spec)

> Compiler, interpreter, language tool detection. Identifies lexer-parser-AST-IR-codegen pipeline patterns.

## R1. Detection Signals

> See [`shared/domains/archetypes/compiler.md`](../../../shared/domains/archetypes/compiler.md) § Code Patterns

## R2. Classification Guide

When detected, classify the project sub-type:
- **Full Compiler**: source → AST → IR → machine code/bytecode (Zig, Rust, GCC)
- **Transpiler**: source → AST → different source language (SWC, Babel, TypeScript)
- **Linter/Formatter**: source → AST → diagnostics/formatted source (Ruff, Biome, Prettier)
- **Language Server**: source → AST → IDE features via LSP (rust-analyzer, pyright)
- **Interpreter**: source → AST → direct execution (MicroPython, Deno)

## R3. Analysis Depth Modifiers

When detected, include in analysis:
- Compilation pipeline stages and intermediate representations
- Parser architecture (recursive descent, Pratt, generated)
- AST node structure and immutability guarantees
- Error recovery strategy and diagnostic quality
- Incremental computation approach (if any)
- Plugin/extension mechanism for custom transforms
- Source map generation and fidelity
