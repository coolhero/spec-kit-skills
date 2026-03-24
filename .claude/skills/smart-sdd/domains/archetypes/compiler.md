# Archetype: compiler

<!-- Format defined in smart-sdd/domains/_schema.md § Archetype Section Schema. -->

> Compilers, interpreters, language servers, linters, formatters, and static analysis tools.
> Universal architecture: source → lexer → parser → AST → IR → optimization → codegen/output.

---

## A0. Signal Keywords

> See [`shared/domains/archetypes/compiler.md`](../../../shared/domains/archetypes/compiler.md) § Signal Keywords

---

## A1. Philosophy Principles

| Principle | Description |
|-----------|-------------|
| **Phase Separation** | Each compilation phase (lex → parse → analyze → transform → emit) is an independent, composable stage. Data flows forward through well-defined intermediate representations. No phase reaches back to modify a previous phase's output |
| **AST Immutability** | Syntax trees are immutable after construction. Transformations produce new trees (or annotate existing ones), never mutate in place. This enables parallel analysis, caching, and incremental recomputation |
| **Error Recovery** | The compiler must not stop at the first error. Parser recovers to continue parsing (synchronization points). Analyzer collects all diagnostics before reporting. Users see all errors in one pass |
| **Incremental Computation** | Re-parsing/re-analyzing only what changed. File-level or sub-tree-level granularity. Supports IDE use cases where latency matters (< 100ms for completions). Cache invalidation based on dependency graph |
| **Source Fidelity** | The AST preserves all source information: whitespace, comments, original formatting. Enables round-trip (parse → print = original source). Source maps maintain original-to-output position mapping |

---

## A2. SC Generation Extensions

When this archetype is active, add these SC requirements to relevant Features:

| Domain | SC Extension |
|--------|-------------|
| **Parsing** | Parser produces correct AST for valid input AND recovers gracefully for invalid input (partial AST + diagnostics). Verify: parse malformed input → error diagnostics point to correct source location (line:col) |
| **Transformation** | Each transform pass preserves semantic equivalence (output program behavior identical to input). Verify: transform → evaluate both → same result |
| **Diagnostics** | Error messages include: source location (file:line:col), severity (error/warning/info), human-readable message, and error code. Verify: diagnostic points to correct span in source |
| **Performance** | Parsing/analysis completes within budget: < 100ms for single-file IDE operations, < 10s for full-project build. Verify: benchmark on representative input sizes |

---

## A3. Elaboration Probes

| Area | Probe Questions |
|------|----------------|
| **Architecture** | Compilation phases? Single-pass or multi-pass? IR levels (HIR → MIR → LIR)? |
| **Parser Type** | Recursive descent? Pratt parser? Parser generator (PEG, LALR)? Hand-written or generated? |
| **Error Recovery** | Panic mode? Synchronization tokens? Error productions? How many errors before giving up? |
| **Incremental** | File-level or sub-tree incremental? Dependency tracking between files? Red-green tree (Roslyn-style)? |
| **IDE Integration** | LSP support? What capabilities (completion, hover, go-to-def, rename, code actions)? Response time budget? |
| **Output** | Target output: machine code? Bytecode? Another language (transpiler)? Formatted source (formatter)? Diagnostics only (linter)? |

---

## A4. Constitution Injection

When this archetype activates, inject these rules into the project constitution:

- **Parse-Transform-Emit pipeline**: Every code transformation follows the pattern: parse source → build AST → transform AST → emit output. No string-based regex transformations on source code
- **Diagnostic quality**: Every error/warning includes file path, line:column range, human-readable message, and machine-readable error code. No "internal compiler error" without actionable context
- **Correctness over performance**: A compiler must be correct first. Optimizations must not change program semantics. Performance improvements require correctness proofs (test suite + fuzzing)
- **Backward compatibility**: Parser accepts all previously valid syntax. New syntax additions must not break existing valid programs. Breaking changes require major version bump

---

## A5. Brief Completion Criteria

| Required Element | Completion Signal |
|-----------------|-------------------|
| **Compilation phases** | At least lex → parse → emit identified; intermediate representations (AST, IR) specified if applicable |
| **Input/output** | Source language and target output (machine code, bytecode, transpiled source, diagnostics) defined |
| **Error recovery strategy** | Parser recovery approach stated (panic mode, synchronization tokens, error productions) |
| **Performance budget** | Target latency for IDE operations (< 100ms) and full build (< Ns for representative input) stated |
| **Incremental scope** | Whether file-level or sub-tree incremental recomputation is required — stated or explicitly deferred |

---

## A2b. Bug Prevention Extensions

| ID | Pattern | Detection | Prevention |
|----|---------|-----------|------------|
| CMP-001 | AST mutation side effects | Transform A mutates a shared AST node → Transform B sees corrupted tree → wrong output | Make AST nodes immutable; transforms produce new nodes; use arena allocation for node ownership |
| CMP-002 | Source position drift | After transformation, error messages point to wrong source location → user cannot find the issue | Maintain source maps through every transformation; verify span accuracy in test suite |
| CMP-003 | Infinite loop in error recovery | Parser enters recovery mode but synchronization token never found → parser loops forever | Limit recovery attempts per error; advance at least one token per recovery; set maximum error count before bail-out |
| CMP-004 | Incremental cache invalidation miss | File A changes but cached analysis of dependent file B is not invalidated → stale type information → wrong diagnostics | Track inter-file dependencies explicitly; invalidate transitively on change; verify with "change file → rebuild → compare with clean build" test |
| CMP-005 | Semantic-breaking optimization | Optimization pass reorders operations with side effects → program behavior changes → silent correctness bug | Define optimization safety levels; side-effectful operations are barriers; test optimizations with side-effect-heavy programs |
