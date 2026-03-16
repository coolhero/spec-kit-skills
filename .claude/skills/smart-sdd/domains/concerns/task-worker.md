# Concern: task-worker

> Background job and scheduled task patterns. Applies when the project uses separate worker processes for deferred execution, periodic scheduling, or async task processing.
> Module type: concern

---

## S0. Signal Keywords

**Primary**: background job, task worker, Celery, Sidekiq, BullMQ, cron job, scheduled task, async worker, job queue, background service
**Secondary**: task retry, task timeout, periodic task, task result backend, task priority, worker concurrency, beat scheduler, dead letter, task state, worker pool

---

## S1. SC Generation Rules

### Required SC Patterns
- Task dispatch + execution lifecycle: dispatch → enqueue → pick up → execute → result/failure
- Task failure handling: exception → retry with backoff → max retries exhausted → failure callback/DLQ
- Task timeout: execution exceeds TTL → kill → report → optional retry with fresh attempt
- Scheduled task precision: trigger fires at expected time ± acceptable drift

### SC Anti-Patterns (reject)
- "Background processing works" — must specify task timeout, retry count, failure notification strategy
- "Tasks run on schedule" — must specify schedule precision tolerance, overlap policy (skip/queue/kill-previous), timezone handling
- "Worker processes tasks" — must specify concurrency limit, memory/CPU bounds, graceful shutdown behavior

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| **Task types** | CPU-bound? I/O-bound? Periodic/scheduled? Event-triggered? One-off? |
| **Execution** | Same process? Separate worker process? Container? Serverless? |
| **Reliability** | Retry policy (count, backoff)? Timeout? Result backend? Task state tracking? |
| **Scheduling** | Cron-based? Fixed interval? Calendar? Dynamic scheduling? |
| **Monitoring** | Task dashboard (Flower, Horizon, Bull Board)? Failure alerting? Queue depth? |
| **Lifecycle** | Graceful shutdown? In-flight task handling on deploy? Worker recycling? |

---

## S7. Bug Prevention — Task Worker-Specific

| ID | Pattern | Detection | Prevention |
|----|---------|-----------|------------|
| TW-001 | Task starvation | Low-priority tasks never execute because high-priority queue is always full | Separate queues with guaranteed minimum throughput per priority |
| TW-002 | Zombie tasks | Worker crashes mid-task, task stays "in progress" forever | Heartbeat + visibility timeout + auto-requeue after timeout |
| TW-003 | Memory leak in long-running workers | Worker process memory grows over time without bound | Max tasks per worker + periodic worker recycling (e.g., `--max-tasks-per-child`) |
| TW-004 | Schedule overlap | Previous execution still running when next scheduled run fires | Overlap policy: skip / queue / terminate-previous; lock-based mutual exclusion |
| TW-005 | Result backend overflow | Task results accumulate indefinitely in result store | TTL on results + periodic cleanup; or disable result backend if not needed |
