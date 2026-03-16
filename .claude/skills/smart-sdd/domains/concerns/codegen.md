# Concern: codegen

> Generated/templated code where an IDL, schema, or template is source-of-truth.

---

## S0. Signal Keywords

> See [`shared/domains/concerns/codegen.md`](../../../shared/domains/concerns/codegen.md) § Signal Keywords
>
> _(Define Signal Keywords in the shared module, not here.)_

---

## S1. SC Generation Rules

### Required SC Patterns

| Pattern | SC Requirement |
|---------|----------------|
| Generator execution | SC must verify the generator runs without error and produces expected output files |
| Generated output validity | SC must verify generated code compiles/type-checks in its target language |
| Source-of-truth change propagation | SC must verify modifying the IDL/schema/template produces correct updated output |
| Generated code non-modification | SC must verify no manual edits exist in generated files (checksum or marker check) |

### SC Anti-Patterns (reject if seen)

- "Code is generated" — must specify what is generated from what, and how correctness is verified
- "Generated files exist" — existence alone doesn't verify content correctness
- "Template produces output" — must specify expected structure or key elements in the output

### Feature Boundary Rules

> **Critical**: Repetitive generated code (e.g., 100+ API wrappers from a spec) must NOT be split into individual Features.
> Instead: one Feature for the **generation rule/template** + one Feature for the **generator infrastructure**.
> Individual generated files are artifacts, not Features.

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|-----------------|
| Source-of-truth | What is the canonical definition? (Proto, OpenAPI, JSON Schema, DB schema, custom DSL) |
| Generator toolchain | Which tool generates code? (protoc, openapi-generator, buf, prisma, custom script) |
| Output scope | How many files are generated? One-to-one (1 proto → 1 stub) or one-to-many? |
| Manual patches | Are generated files ever manually edited after generation? If so, how are patches preserved? |
| Regeneration trigger | When does regeneration happen? (pre-build hook, CI step, manual command) |
| Repetitive pattern | Are there directories with many structurally identical files? What varies between them? |

---

## S7. Bug Prevention

| ID | Pattern | Detection | Prevention |
|----|---------|-----------|------------|
| CGN-001 | Manual edit to generated file | File has `@generated` marker but git diff shows manual changes | Pre-commit hook: reject changes to files matching generated markers unless regeneration script also ran |
| CGN-002 | Stale generated output | Source-of-truth changed but generated files not updated | CI step: regenerate all → `git diff --exit-code` on generated files |
| CGN-003 | Generator version drift | Generator tool updated but output not regenerated with new version | Pin generator version; regenerate on version bump |
| CGN-004 | Template logic error | Template has conditional logic that silently produces wrong output for edge cases | Generated output must have compilation + at least one integration test per template variant |
| CGN-005 | Repetition disguised as features | 100+ similar files treated as individual features → pipeline explosion | Detect >80% structural similarity across file group; consolidate into generation-rule Feature |
