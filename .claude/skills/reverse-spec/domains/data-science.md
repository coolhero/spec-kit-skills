# Domain Profile: data-science

> **Status**: Template -- not yet implemented. All sections marked [TODO] need domain-specific content.

Data science and ML pipeline projects. Covers data processing pipelines, ML model training, exploratory analysis, and ML platforms.

---

## 1. Detection Signals

[TODO]
- `*.ipynb` (Jupyter notebooks)
- `requirements.txt` with pandas/numpy/scikit-learn/tensorflow/pytorch
- `dvc.yaml`, `MLproject`, `pipeline.py`
- `data/`, `models/`, `notebooks/` directories

---

## 2. Project Type Classification

[TODO]

| Type | Description |
|------|-------------|
| **pipeline** | Data processing / ETL pipeline |
| **modeling** | ML model training + evaluation |
| **analysis** | Exploratory data analysis / reporting |
| **platform** | ML platform / serving infrastructure |

---

## 3. Analysis Axes

[TODO]

| Axis | Description | Extraction Targets |
|------|-------------|-------------------|
| Data Sources | Input datasets, connections, schemas | Database configs, file readers, API clients |
| Pipeline Stages | ETL steps, transformations, data flow | Pipeline definitions, DAG configs |
| Feature Engineering | Feature definitions, transformations | Feature store configs, transformation code |
| Model Architecture | Model classes, hyperparameters | Model definitions, training scripts |
| Evaluation Metrics | Loss functions, evaluation criteria | Evaluation scripts, metric definitions |

---

## 4. Registries

[TODO]

| Registry | File | Purpose |
|----------|------|---------|
| Dataset Registry | dataset-registry.md | Cross-Feature data source ownership |
| Model Registry | model-registry.md | Model versions, architectures, performance metrics |
| Pipeline Map | pipeline-map.md | Stage dependencies and data flow |

---

## 5. Feature Boundary Heuristics

[TODO]
- Pipeline stage boundaries
- Dataset ownership boundaries
- Model training vs. inference separation
- Experiment/workflow boundaries

---

## 6. Tier Classification Axes

[TODO]

| Axis | Description | Judgment Basis |
|------|-------------|----------------|
| Data Foundation | Core data pipelines other Features depend on | Number of downstream dependencies |
| Model Core | Central ML models defining the project's value | Business impact, prediction accuracy |
| Pipeline Criticality | Processing stages that block other pipelines | Dependency depth, failure impact |
| Integration Surface | Connection points with external systems | Number of data sources/sinks |
| Complexity | Algorithmic and computational complexity | Training time, resource requirements |

---

## 7. Demo Pattern

[TODO]
- **Type**: Script-based (not server)
- **Default**: Run pipeline/inference -> display results + visualizations -> generate report
- **CI mode**: Run with sample data -> validate output format + metrics threshold -> exit
- **Script**: `demos/F00N-name.sh` (or `.py`)

---

## 8. Parity Dimensions

[TODO]

| Dimension | Compare |
|-----------|---------|
| Data | Input/output schemas, data transformations, feature definitions |
| Pipeline | Processing stages, dependencies, execution order |
| Model | Architecture match, hyperparameters, metric thresholds |

---

## 9. Verify Steps

[TODO]

| Step | Required | Description |
|------|----------|-------------|
| Test | Yes (BLOCKING) | Data validation + unit tests |
| Pipeline Run | Yes (BLOCKING) | End-to-end pipeline with sample data |
| Metrics Check | Yes (BLOCKING) | Output metrics within acceptable threshold |
| Lint | Optional | Code style check |
