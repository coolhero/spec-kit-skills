# Interface: data-io

> Data processing pipelines. Applies when the project processes data in batch or stream.
> Module type: interface

---

## S0. Signal Keywords

> See [`shared/domains/interfaces/data-io.md`](../../../shared/domains/interfaces/data-io.md) § Signal Keywords

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

---

## S9. Brief Completion Criteria

| Required Element | Completion Signal |
|-----------------|-------------------|
| Data source(s) identified | Input type (file, database, API, stream) + format (CSV, JSON, Parquet, etc.) stated |
| Processing pipeline described | At least one transformation step + expected output format |
| Volume/frequency indication | Batch vs streaming, approximate data size or frequency |

---

## S8. Runtime Verification Strategy

> Cross-references [reference/runtime-verification.md](../../reference/runtime-verification.md) § 6d.

| Field | Value |
|-------|-------|
| **Start method** | Pipeline prerequisites setup (test data placement, dependency services) |
| **Verify method** | Run pipeline with sample/test data → compare output against expected results. Backend: Pipeline runner (shell execution) |
| **Stop method** | N/A — pipeline runs terminate naturally; clean up temp data |
| **SC classification extensions** | `pipeline-auto` — pipeline SCs verifiable with sample test data without external dependencies |

**Data-IO-specific verification**:
- Step 3d Interactive Runtime Verification: group `pipeline-auto` SCs by pipeline stage → run with test data → compare output schema + row counts + checksums
- Idempotency check: run pipeline twice with same input → verify identical output
