# Concern: CQRS / Event Sourcing (reverse-spec)

> Extends shared S0/R1 signals with reverse-spec-specific analysis rules.

## R1: Detection Signals
See `shared/domains/concerns/cqrs-eventsourcing.md` for S0 keywords and code patterns.

## R3: Feature Boundary Impact
When CQRS/Event Sourcing is detected:
- **Feature boundaries follow Aggregates**, not packages or layers
- Each Aggregate (command-side) + its Projections (query-side) = one Feature
- Sagas spanning multiple Aggregates = separate Feature (cross-cutting orchestration)
- Event Store infrastructure = Foundation-level (not a Feature)

## R4: Data Flow Extraction
- Trace: Command → Command Handler → Aggregate → Domain Event → Event Handler → Projection
- Record the complete flow per use case in pre-context.md § Data Lifecycle Patterns
- Separate read/write datasource configurations → record in Foundation Decisions
