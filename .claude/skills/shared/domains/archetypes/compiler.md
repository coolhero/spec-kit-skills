# Archetype: compiler

> Compilers, interpreters, language servers, linters, formatters, and static analysis tools.
> Universal architecture: source → lexer → parser → AST → IR → optimization → codegen/output.

---

## Signal Keywords

### Semantic (A0 — for init inference)

**Primary**: compiler, parser, lexer, AST, abstract syntax tree, IR, intermediate representation, codegen, transpiler, interpreter, language server

**Secondary**: tokenizer, syntax tree, visitor pattern, semantic analysis, type checker, linter, formatter, source map, LSP, incremental parsing, error recovery, span, diagnostic

### Code Patterns (R1 — for source analysis)

- AST: `Node`, `SyntaxKind`, `AstNode`, `SyntaxTree`, `ParseTree`, `Expr`, `Stmt`, `Decl`
- Parser: `parse()`, `expect()`, `peek()`, `advance()`, `consume()`, `Pratt parser`, `recursive descent`
- Lexer: `Token`, `Lexer`, `Scanner`, `tokenize()`, `lex()`, `TokenKind`, `Span`
- Visitor: `visit()`, `walk()`, `Visitor trait`, `AstVisitor`, `traverse()`
- IR: `HIR`, `MIR`, `LIR`, `BasicBlock`, `Instruction`, `SSA`, `CFG`
- LSP: `textDocument/completion`, `textDocument/hover`, `textDocument/definition`, `LanguageServer`
- Tools: `swc`, `oxc`, `biome`, `ruff`, `rust-analyzer`, `tree-sitter`, `babel`, `esbuild`

---

## Module Metadata

- **Axis**: Archetype
- **Common interfaces**: cli (compiler binary), library (embedded parser)
- **Common concerns**: codegen, plugin-system
- **Profiles**: —
