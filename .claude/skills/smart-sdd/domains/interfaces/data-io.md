# Interface: data-io

> Data processing pipelines. Applies when the project processes data in batch or stream.
> Module type: interface

---

## S1. SC Generation Rules

### Required SC Patterns
- Pipeline execution: input data shape + processing steps + output data shape verification
- Data validation: invalid input -> specific error with row/field identification
- Idempotency: re-running with same input produces same output

### SC Anti-Patterns (reject)
- "Data is processed" — must specify input/output shapes and transformation rules
- "Pipeline completes" — must specify success criteria (row counts, checksums, schema compliance)

---

## S1. Demo Pattern (override)

- **Type**: Script-based
- **Default mode**: Run pipeline with sample dataset -> print summary statistics -> show output sample
- **CI mode**: Run with minimal test data -> verify output shape matches expected

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| **Data sources** | Input format? Schema? Volume? Frequency? |
| **Transformations** | What processing steps? Order? Dependencies? |
| **Output** | Output format? Destination? Validation? |
| **Error handling** | Partial failure strategy? Dead letter queue? Retry? |
