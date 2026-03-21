# Concern: scheduling-algorithm

> Task scheduling (preemptive/cooperative), resource allocation, bin packing, priority queues, deadline scheduling, constraint solving.

---

## Signal Keywords

### Semantic (S0 — for init inference)

**Primary**: task scheduling, scheduler, resource allocation, bin packing, priority queue, job scheduler, constraint solver, deadline scheduling, preemptive scheduling

**Secondary**: round robin, FIFO, shortest job first, earliest deadline first, work stealing, thread pool, fair scheduling, capacity planning, backfill, gang scheduling, DAG scheduling, cron, rate limiting, throttle

### Code Patterns (R1 — for source analysis)

- Schedulers: `node-schedule`, `cron`, `APScheduler`, `Quartz`, `Hangfire`, `Celery Beat`, `Airflow`, `Temporal`
- Algorithms: `PriorityQueue`, `MinHeap`, `MaxHeap`, `BinPacking`, `FirstFit`, `BestFit`, `WorkStealingPool`
- Constraint: `or-tools`, `optaplanner`, `z3`, `constraint_solver`, `linear_programming`
- Patterns: `schedule()`, `enqueue()`, `dequeue()`, `prioritize()`, `allocate()`, `preempt()`, `yield()`, `deadline`

---

## Module Metadata

- **Axis**: Concern
- **Common pairings**: task-worker, distributed-consensus
- **Profiles**: —
