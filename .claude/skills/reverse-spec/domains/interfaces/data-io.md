# Interface: data-io (reverse-spec)

> Data pipeline analysis axes. Loaded when project processes data in batch or stream.
> Module type: interface (reverse-spec analysis)

---

## R1. Detection Signals

> See [`shared/domains/interfaces/data-io.md`](../../../shared/domains/interfaces/data-io.md) § Code Patterns

## R3. Analysis Axes — Pipeline Extraction

For each pipeline stage, extract:
- Stage name, description
- Input data source (file, database, API, stream)
- Transformation logic (what operations are performed)
- Output destination (file, database, API, downstream stage)
- Dependencies on other stages
- Configuration parameters (thresholds, model parameters)
