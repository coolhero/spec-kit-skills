# Concern: dag-orchestration (reverse-spec)

> Extends shared S0/R1 signals with reverse-spec-specific analysis rules.

## R1: Detection Signals
See `shared/domains/concerns/dag-orchestration.md` for S0 keywords and code patterns.

## R3: Feature Boundary Impact
When DAG orchestration is detected:
- Each **DAG/flow/pipeline** = one Feature (or Feature group if complex)
- Shared **operators/hooks/connections** = Foundation-level infrastructure
- **Scheduler and executor** = Foundation-level, not a Feature
- **Custom operators** = separate Feature if reusable across DAGs

## R4: Data Flow Extraction
- Trace: Schedule Trigger → Task Dependencies → Task Execution → XCom/Output → Downstream Tasks
- Record DAG dependency graph in pre-context.md § Data Lifecycle Patterns
- Note retry policies, SLAs, and backfill behavior per DAG
