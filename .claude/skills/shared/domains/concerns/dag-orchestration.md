# Concern: dag-orchestration

> DAG-based workflow orchestration — Airflow, Prefect, Dagster, dbt, and similar task dependency engines.

---

## Signal Keywords

### Semantic (S0 — for init inference)

**Primary**: DAG, task dependency, upstream, downstream, sensor, trigger rule, backfill, retry policy, workflow orchestration, data pipeline, task scheduler

**Secondary**: operator, hook, connection, variable, XCom, pool, queue, SLA, data lineage, partition, materialization, asset, scheduling interval, cron

### Code Patterns (R1 — for source analysis)

- **Airflow**: `dags/` directory, `@dag` decorator, `@task` decorator, `>>` operator (dependency), `BashOperator`, `PythonOperator`, `airflow.cfg`, `dag_id`
- **Prefect**: `@flow`/`@task` decorators, `prefect.yaml`, flow runs, task states, `submit()`
- **Dagster**: `@asset`/`@op`/`@job` decorators, `Definitions`, `repository`, `workspace.yaml`, `dagster.yaml`
- **dbt**: `dbt_project.yml`, `ref()`/`source()` functions, `models/` directory, `.sql` with Jinja, `schema.yml`
- **Common**: DAG definition files, dependency graph construction, execution engine, scheduler, retry/timeout config

---

## Module Metadata

- **Axis**: Concern
- **Common pairings**: task-worker, message-queue
- **Profiles**: —
