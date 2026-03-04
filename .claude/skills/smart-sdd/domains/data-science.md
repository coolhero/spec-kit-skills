# Domain Profile: data-science (smart-sdd)

> **Status**: Template -- not yet implemented. All sections marked [TODO] need domain-specific content.
> For reverse-spec analysis profiles, see `../reverse-spec/domains/data-science.md`.

---

## 1. Demo Pattern

[TODO]

- **Type**: Script-based (not server)
- **Default mode**: Run pipeline/inference with sample data -> display results + metrics + visualizations -> keep output visible
- **CI mode**: Run with sample data -> validate output format + metrics within threshold -> exit
- **Script location**: `demos/F00N-name.sh` (or `.py`)
- **"Try it" instructions**: Commands to run, output files to inspect, metrics to check

---

## 2. Parity Dimensions

[TODO]

### Structural Parity

| Category | What to Compare |
|----------|----------------|
| Data schemas | Input/output data schemas, column definitions |
| Pipeline stages | Processing steps, DAG structure, stage ordering |
| Model architecture | Layer definitions, hyperparameters, feature inputs |
| Configuration | Pipeline configs, training configs, deployment configs |

### Logic Parity

| Category | What to Compare |
|----------|----------------|
| Transformations | Data transformation logic, feature engineering steps |
| Model behavior | Prediction accuracy, metric thresholds, edge case handling |

---

## 3. Verify Steps

[TODO]

| Step | Required | Detection | Description |
|------|----------|-----------|-------------|
| **Test** | Yes (BLOCKING) | pytest, unittest, data validation frameworks | Data validation + unit tests |
| **Pipeline Run** | Yes (BLOCKING) | Pipeline runner (Airflow, DVC, custom) | End-to-end pipeline with sample data |
| **Metrics Check** | Yes (BLOCKING) | Evaluation script output | Output metrics within acceptable threshold |
| **Lint** | Optional | flake8, black, ruff | Code style check |
