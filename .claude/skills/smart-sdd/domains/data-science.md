# Domain Profile: data-science (smart-sdd)

> Data science, ML pipelines, feature stores, and AI/ML platform projects.
> For reverse-spec analysis profiles, see `../../reverse-spec/domains/data-science.md`.

---

## 1. Demo Pattern

- **Pipeline/modeling type**: Script-based (not server)
  - **Default mode**: Run pipeline/inference with sample data → display results + metrics + visualizations → keep output visible
  - **CI mode**: Run with sample data → validate output format + metrics within threshold → exit
- **Platform type**: Server-based
  - **Default mode**: Start feature server → run sample retrieval → display latency + results → keep running
  - **CI mode**: Start → health check → sample query → validate response → stop
- **NL-interface type**: Server-based
  - **Default mode**: Start server → submit sample NL query → display generated SQL + results → keep running
  - **CI mode**: Start → submit known query → validate SQL output matches expected → stop
- **Script location**: `demos/F00N-name.sh` (or `.py`)
- **"Try it" instructions**: Commands to run, expected output files, metrics to check, sample queries

---

## 2. Parity Dimensions

### Structural Parity

| Category | What to Compare |
|----------|----------------|
| Data schemas | Input/output data schemas, column definitions, feature types, entity definitions |
| Pipeline stages | Processing steps, DAG structure, stage ordering, materialization configuration |
| Model architecture | Layer definitions, hyperparameters, feature inputs, output format |
| Store configuration | Online/offline store type, connection config, serialization, indexing strategy |
| Provider configuration | Active providers, model IDs, API endpoints, embedding dimensions, vector store backends |

### Logic Parity

| Category | What to Compare |
|----------|----------------|
| Transformations | Data transformation logic, feature engineering steps, aggregation windows |
| Model behavior | Prediction accuracy, metric thresholds, edge case handling, confidence scores |
| Query generation | NL-to-SQL accuracy, SQL dialect correctness, result formatting |

---

## 3. Verify Steps

| Step | Required | Detection | Description |
|------|----------|-----------|-------------|
| **Test** | Yes (BLOCKING) | pytest, unittest, data validation frameworks (Great Expectations, pandera) | Data validation + unit tests |
| **Pipeline Run** | Yes (BLOCKING) | Pipeline runner (Airflow, DVC, Prefect, Dagster, custom) | End-to-end pipeline with sample data |
| **Metrics Check** | Yes (BLOCKING) | Evaluation script output, experiment tracking (MLflow, W&B) | Output metrics within acceptable threshold |
| **Store Health** | Conditional (BLOCKING for platform type) | Feature store health endpoint, online store latency probe | Online/offline store responds correctly |
| **Example Execution** | Conditional (BLOCKING for platform/SDK type) | `examples/` scripts, quickstart notebooks | All examples run without error |
| **Lint** | Optional | ruff, flake8, black, mypy | Code style + type check |
