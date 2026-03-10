# Scenario: incremental

> Adding features to an existing SDD-managed project.
> Module type: scenario

---

## SC Rules (extends _core)

- New Feature SCs must not contradict existing Feature SCs
- Integration SCs required: new Feature x existing Features data shape contracts
- Cross-Feature regression: existing demo scripts must still pass after new Feature added

## Verification Strategy

- Standard + Cross-Feature regression (run all existing tests after new Feature)
- Integration Contract verification: verify data shape compatibility at Feature boundaries
- Existing demo scripts re-run as smoke test

## Elaboration Probes

| Category | Probes |
|----------|--------|
| **Integration points** | Which existing Features does this interact with? |
| **Data contracts** | What data shapes are expected/provided at boundaries? |
| **Backward compatibility** | Does this change any existing API or data format? |
