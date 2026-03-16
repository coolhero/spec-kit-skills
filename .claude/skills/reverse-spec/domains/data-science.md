# Domain Profile: data-science

> Data science, ML pipelines, feature stores, and AI/ML platform projects.

---

## 1. Detection Signals

- **Notebooks**: `*.ipynb`, `notebooks/` directory
- **ML frameworks**: `requirements.txt`/`pyproject.toml` with `scikit-learn`, `tensorflow`, `pytorch`, `torch`, `xgboost`, `lightgbm`, `transformers`, `huggingface`
- **Pipeline tools**: `dvc.yaml`, `MLproject` (MLflow), `pipeline.py`, `dags/` (Airflow), `prefect` flows, `dagster` assets
- **Data dirs**: `data/`, `models/`, `features/`, `experiments/`
- **Feature store**: `feast`, `featuretools`, `feature_store.yaml`, `FeatureView`, `FeatureService`
- **Vector/embedding**: `chromadb`, `qdrant`, `pinecone`, `faiss`, `milvus`, `weaviate`, `pgvector`, embedding generation code
- **NL-to-SQL / text-to-X**: `vanna`, `text2sql`, SQL generation from natural language, LLM + database connector patterns
- **ML serving**: `BentoML`, `MLflow`, `Seldon`, `TorchServe`, `TensorFlow Serving`, `triton`
- **Config**: `params.yaml`, `config/experiment_*.yaml`, hyperparameter configs, `wandb` / `mlflow` tracking

---

## 2. Project Type Classification

| Type | Description | Detection Signals |
|------|-------------|-------------------|
| **pipeline** | Data processing / ETL pipeline | Airflow DAGs, dbt models, Prefect flows, `pipeline.py`, scheduled transforms |
| **modeling** | ML model training + evaluation | Training scripts, model definitions, evaluation metrics, experiment tracking |
| **analysis** | Exploratory data analysis / reporting | Primarily notebooks, visualization, statistical analysis, report generation |
| **platform** | ML platform / serving infrastructure | Feature store, model registry, serving endpoints, multi-backend plugin system |
| **nl-interface** | Natural language interface to data | LLM integration + database connectors + query generation + result presentation |

---

## 3. Analysis Axes

| Axis | Description | Extraction Targets |
|------|-------------|-------------------|
| **Data Sources** | Input datasets, connections, schemas | Database configs, file readers, API clients, feature definitions |
| **Pipeline Stages** | ETL/ML steps, transformations, data flow | Pipeline definitions, DAG configs, materialization jobs |
| **Feature Engineering** | Feature definitions, transformations, serving | Feature store configs, transformation code, online/offline store patterns |
| **Model Architecture** | Model classes, hyperparameters, training loop | Model definitions, training scripts, config files |
| **Evaluation Metrics** | Loss functions, evaluation criteria | Evaluation scripts, metric definitions, threshold configs |
| **Store Abstraction** | Online/offline store, vector store, registry | Plugin interfaces, backend implementations, config-driven store selection |
| **Provider Abstraction** | LLM providers, embedding models, DB connectors | Abstract base classes, provider registry, adapter implementations |

---

## 4. Registries

| Registry | File | Purpose |
|----------|------|---------|
| **Dataset Registry** | `dataset-registry.md` | Cross-Feature data source ownership, schema definitions, lineage |
| **Model Registry** | `model-registry.md` | Model versions, architectures, performance metrics, serving endpoints |
| **Pipeline Map** | `pipeline-map.md` | Stage dependencies, data flow, materialization schedule |
| **Store Backend Map** | `store-backend-map.md` | Available store backends, their configs, and which Features use which backend |

---

## 5. Feature Boundary Heuristics

- **Pipeline stage boundaries**: Each major processing stage (ingest → transform → train → serve) is a candidate Feature boundary
- **Dataset ownership boundaries**: Each independently owned dataset/feature-view is a candidate
- **Model training vs inference separation**: Training pipeline and serving infrastructure are separate Features
- **Store interface vs implementation**: Abstract store interface = one Feature; each concrete backend = one Feature
- **Provider abstraction boundary**: Provider interface = one Feature; each provider implementation = one Feature
- **Experiment/workflow boundaries**: Each independent experiment or workflow is a candidate

---

## 6. Tier Classification Axes

| Axis | Description | Judgment Basis |
|------|-------------|----------------|
| **Data Foundation** | Core data pipelines other Features depend on | Number of downstream dependencies, data freshness requirements |
| **Model Core** | Central ML models defining the project's value | Business impact, prediction accuracy, retraining frequency |
| **Pipeline Criticality** | Processing stages that block other pipelines | Dependency depth, failure impact, SLA requirements |
| **Store Infrastructure** | Online/offline store and registry | Number of Features using the store, latency requirements |
| **Integration Surface** | Connection points with external systems | Number of data sources/sinks, provider count |
| **Complexity** | Algorithmic and computational complexity | Training time, resource requirements, infrastructure cost |

---

## 7. Demo Pattern

- **Type**: Script-based (not server) for pipeline/modeling; server-based for platform/nl-interface
- **Pipeline/modeling default**: Run pipeline/inference with sample data → display results + metrics + visualizations → generate report
- **Platform default**: Start feature server → run sample feature retrieval → display results → stop
- **NL-interface default**: Start server → execute sample natural language query → display generated SQL + results → stop
- **CI mode**: Run with sample data → validate output format + metrics within threshold → exit
- **Script location**: `demos/F00N-name.sh` (or `.py`)

---

## 8. Parity Dimensions

| Dimension | What to Compare |
|-----------|----------------|
| **Data schemas** | Input/output data schemas, column definitions, feature types |
| **Pipeline stages** | Processing steps, DAG structure, stage ordering, materialization schedule |
| **Model architecture** | Layer definitions, hyperparameters, feature inputs, output format |
| **Store configuration** | Online/offline store type, connection config, serialization format |
| **Provider configuration** | Active providers, model names, API endpoints, embedding dimensions |
| **Metrics thresholds** | Acceptable accuracy, latency, throughput ranges per Feature |

---

## 9. Verify Steps

| Step | Required | Detection | Description |
|------|----------|-----------|-------------|
| **Test** | Yes (BLOCKING) | pytest, unittest, data validation frameworks | Data validation + unit tests + integration tests |
| **Pipeline Run** | Yes (BLOCKING) | Pipeline runner (Airflow, DVC, Prefect, custom) | End-to-end pipeline with sample data |
| **Metrics Check** | Yes (BLOCKING) | Evaluation script output, metric logging | Output metrics within acceptable threshold |
| **Store Health** | Conditional (platform type) | Feature store health check, online store latency check | Online/offline store responds with correct data |
| **Lint** | Optional | ruff, flake8, black, mypy | Code style + type checking |
