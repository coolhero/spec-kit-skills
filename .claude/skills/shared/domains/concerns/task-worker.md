# Concern: task-worker

> Background jobs, scheduled tasks, async worker processes.

---

## Signal Keywords

### Semantic (S0 — for init inference)

**Primary**: background job, task worker, Celery, Sidekiq, BullMQ, cron job, scheduled task, async worker, job queue, background service

**Secondary**: task retry, task timeout, periodic task, task result backend, task priority, worker concurrency, beat scheduler, dead letter, task state, worker pool

### Code Patterns (R1 — for source analysis)

- Worker libraries: `celery` (Python), `dramatiq` (Python), `rq` (Python), `huey` (Python), `sidekiq` (Ruby), `delayed_job` (Ruby), `good_job` (Ruby), `solid_queue` (Ruby), `bullmq`, `bull`, `agenda` (Node.js), `oban` (Elixir), `exq` (Elixir), `Hangfire` (.NET), `Quartz.NET` (.NET), `spring-batch`, `Quartz` (Java)
- Code patterns: `@shared_task`, `@celery.task`, `@app.task` (Celery), `perform_async`, `perform_later`, `perform_in` (Sidekiq), `queue.add()`, `worker.process()` (BullMQ), `@Scheduled`, `@Cron`, `@Interval` (Spring/NestJS), `Oban.Worker` (Elixir), `BackgroundService` (.NET), `IHostedService` (.NET)
- Config files: `celeryconfig.py`, `celery.py`, `sidekiq.yml`, `Procfile` with worker entries, `docker-compose.yml` with worker service, `systemd` unit files for workers
- Process patterns: separate `worker` process definitions, `beat`/`scheduler` processes, `clock` process in Procfile
- Scheduling: `crontab`, `periodic_task`, `PeriodicTask`, `cron()` configuration, `RecurringJob`, APScheduler

---

## Module Metadata

- **Axis**: Concern
- **Common pairings**: message-queue
- **Profiles**: —
