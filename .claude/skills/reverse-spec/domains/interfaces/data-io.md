# Interface: data-io (reverse-spec)

> Data pipeline analysis axes. Loaded when project processes data in batch or stream.
> Module type: interface (reverse-spec analysis)

---

## R1. Detection Signals

> See [`shared/domains/interfaces/data-io.md`](../../../shared/domains/interfaces/data-io.md) § Code Patterns

## R3. Analysis Axes — Pipeline Extraction

### R3-1. DAG Structure
- Identify all pipeline entry points (DAG definitions, flow definitions, job definitions)
- Map stage dependencies (upstream/downstream relationships)
- Classify: linear pipeline, fan-out, fan-in, diamond dependency

### R3-2. Connector/Source/Sink Inventory
For each pipeline stage, extract:
- Stage name, description
- Input data source (file, database, API, stream)
- Transformation logic (what operations are performed)
- Output destination (file, database, API, downstream stage)
- Dependencies on other stages
- Configuration parameters (thresholds, model parameters)

### R3-3. SQL-as-Source Detection
- If `models/` directory with `.sql` files containing `ref()` or `source()` → dbt pattern
- Each SQL model = candidate SBI entry
- Extract Jinja macro dependencies for lineage mapping

### R3-4. Scheduler/Executor Split
- Identify scheduler component (cron, dependency-based, event-driven)
- Identify executor component (local, Celery, Kubernetes, Dask, Spark)
- These are natural Feature boundary candidates

---

## R4. Data Flow Extraction

- Build pipeline-level data flow graph (distinct from entity-level)
- Each stage = node, data flow between stages = edge
- Annotate edges with data format/schema
- Feed into entity-registry as "Pipeline Entity" type

---

## R5. Feature Boundary Heuristics

- **DAG boundary**: Each independently schedulable DAG/flow/job = candidate Feature
- **Connector boundary**: Each unique source/sink integration = candidate Feature
- **Scheduler vs Executor**: Separate Feature candidates
- **Data quality layer**: Dedicated validation pipeline = separate Feature
