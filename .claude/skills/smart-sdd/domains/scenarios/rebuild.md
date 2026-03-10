# Scenario: rebuild

> Preserve existing behavior while changing the implementation environment.
> Covers: EOS replacement, platform migration, framework upgrade, language migration, architecture refactoring, vendor switch.
> Module type: scenario

---

## Configuration Parameters

| Parameter | Values | Description |
|-----------|--------|-------------|
| `change_scope` | `stack`, `platform`, `framework`, `language`, `architecture`, `vendor` | What category of change is being made |
| `preservation_level` | `exact`, `equivalent`, `functional` | How strictly behavior must match |
| `source_available` | `running`, `code-only`, `docs-only` | Is the old system accessible? |
| `migration_strategy` | `big-bang`, `incremental`, `strangler-fig` | How to transition from old to new |

> These parameters are recorded in sdd-state.md and influence SC generation + verification.

---

## SC Rules (extends _core)

### Preservation SC Generation
- For each existing behavior (SBI P1/P2):
  generate "Given [same input] -> [equivalent output]" SC
- `preservation_level` determines equivalence criteria:
  - `exact`: byte-level or pixel-level match (same API response body, same UI layout)
  - `equivalent`: semantic match (same data/outcome, format may differ)
  - `functional`: capability match (achieves same user goal, implementation may differ)

### Change-Boundary SC Generation
- Identify what IS changing (new stack/platform APIs)
- Generate SCs for: new dependency integration, new deployment, new configuration
- Old-system-specific implementation details should NOT appear in new SCs

---

## Verification Strategy

### Behavioral Parity Verification
- `source_available: running` -> side-by-side comparison
  - Same request -> compare responses (per preservation_level)
  - Same user flow -> compare outcomes
- `source_available: code-only` -> SBI-based verification
  - Each P1/P2 behavior has corresponding test in new system
- `source_available: docs-only` -> SC-based verification only
  - No automated parity; rely on SC pass/fail

### Regression Gate
- After each Feature: run ALL previously passing SCs (not just current Feature)
- Cross-Feature regression is mandatory in rebuild scenario

---

## Elaboration Probes

| Category | Probes |
|----------|--------|
| **Change scope** | What exactly is being replaced? What stays the same? |
| **Constraints** | New environment limitations vs old? Performance requirements changed? |
| **Data** | Data migration needed? Schema changes? Format conversions? |
| **Coexistence** | Must old and new coexist during transition? How long? |
| **Rollback** | Can we revert to old system if issues found? Rollback criteria? |
