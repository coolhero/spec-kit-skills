# Concern: CQRS / Event Sourcing

## S0: Detection Signals

### Semantic Keywords
cqrs, event sourcing, event store, command handler, query handler, aggregate, projection, read model, write model, domain event, saga, process manager

### Code Patterns
- **Axon Framework**: `@Aggregate`, `@CommandHandler`, `@EventHandler`, `@QueryHandler`, `@EventSourcingHandler`, `AggregateLifecycle.apply()`
- **Spring with manual CQRS**: Separate command/query packages (e.g., `*.command`, `*.query`), event class hierarchies, event store tables (`event_store`, `domain_events`)
- **EventStoreDB client**: `EventStoreDBClient`, `appendToStream`, `readStream`
- **Generic patterns**: Classes ending in `Command`, `Event`, `Query`, `Projection`; separate read/write database configurations; event replay/rebuild mechanisms
- **Kafka/RabbitMQ as event bus**: Event publishing to message broker with consumer projections

## R1: Reverse-Spec Analysis Signals

### Detection Heuristics
- Directory structure: `command/`, `query/`, `event/`, `aggregate/`, `projection/`, `saga/`
- Separate datasource configs: write DB (often PostgreSQL/event store) + read DB (often MongoDB/Elasticsearch)
- Event class hierarchy with timestamp + aggregate ID fields
- Command → Event → Projection data flow pattern

### SBI Extraction Notes
- **Aggregates** are natural Feature boundaries (each aggregate = one Feature or Feature group)
- **Command Handlers** are P1 behaviors (write-side entry points)
- **Query Handlers** are P1 behaviors (read-side entry points)
- **Event Handlers / Projections** are P1 behaviors (materialized view builders)
- **Sagas / Process Managers** are P1 behaviors (cross-aggregate orchestration)
- Events themselves are P2 (data contracts, not executable behavior)
