# Interface: data-io

> Data pipelines, ETL, batch/stream processing.

---

## Signal Keywords

### Semantic (S0 — for init inference)

**Primary**: ETL, data pipeline, batch processing, stream processing, data transformation, Apache Kafka, Apache Spark, Airflow, Luigi, Prefect, dbt

**Secondary**: CSV, Parquet, data lake, data warehouse, cron job, ingestion, aggregation

### Code Patterns (R1 — for source analysis)

- Pipeline frameworks: Apache Airflow, Luigi, Prefect, Dagster, dbt
- Data processing: pandas, polars, Spark, Flink
- ML frameworks: scikit-learn, PyTorch, TensorFlow, Hugging Face
- Config files: `dvc.yaml`, `pipeline.yml`, `dags/`

---

## S5 — Elaboration Probes

| Category | Probes |
|----------|--------|
| **Pipeline topology** | How many stages? Linear or branching DAG? Any fan-out/fan-in? |
| **Data sources** | What input sources (files, databases, APIs, streams)? Format (CSV, JSON, Parquet, Avro)? |
| **Processing model** | Batch (scheduled), micro-batch, streaming (continuous)? What triggers execution? |
| **Orchestration** | Self-managed (cron), framework-managed (Airflow/Prefect/Dagster), event-driven? |
| **Data quality** | Schema validation? Data contracts? Anomaly detection? Retry on failure? |
| **Destinations** | Where does data land (warehouse, lake, API, file)? Append, upsert, or replace? |

---

## R3. Analysis Axes — Pipeline Extraction

### R3-1. DAG Structure
- Identify all pipeline entry points (DAG definitions, flow definitions, job definitions)
- Map stage dependencies (upstream/downstream relationships)
- Classify: linear pipeline, fan-out, fan-in, diamond dependency

### R3-2. Connector/Source/Sink Inventory
- List all data sources (databases, APIs, files, streams) with connection method
- List all data destinations
- Note: each unique source/sink type = potential SBI entry

### R3-3. Transformation Lineage
- For each stage: input schema → transformation → output schema
- Track column-level lineage where possible
- Identify business logic embedded in transformations vs pure data movement

### R3-4. Scheduler/Executor Architecture
- Scheduler type: cron, event-driven, dependency-based
- Executor type: local, distributed (Celery, Kubernetes, Dask, Spark)
- Retry policy, timeout, backfill strategy

### R3-5. SQL-as-Source Detection
- If `models/` directory with `.sql` files containing `ref()` or `source()` → dbt pattern
- If Jinja-templated SQL → extract macro dependencies
- Each SQL model = candidate SBI entry

---

## R5. Feature Boundary Heuristics

- **Pipeline/DAG boundary**: Each independently schedulable DAG/flow/job = candidate Feature
- **Connector boundary**: Each unique source/sink integration = candidate Feature or sub-Feature
- **Scheduler vs Executor split**: Scheduler engine and executor engine are separate Features
- **Data quality layer**: If dedicated validation/quality pipeline exists, treat as separate Feature

---

## R6. Tier Classification

| Tier | Criteria |
|------|----------|
| T1 (Core) | Main data pipeline(s), primary source/sink connectors, scheduler/executor core |
| T2 (Important) | Secondary connectors, data quality/validation, monitoring/alerting |
| T3 (Enhancement) | Backfill tools, admin UI, lineage visualization, metadata catalog |

---

## Module Metadata

- **Axis**: Interface
- **Common pairings**: task-worker, message-queue
- **Profiles**: ml-platform, data-pipeline
