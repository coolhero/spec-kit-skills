# Concern: message-queue

> Async messaging — RabbitMQ, Kafka, BullMQ, Sidekiq, Celery.

---

## Signal Keywords

### Semantic (S0 — for init inference)

**Primary**: message queue, RabbitMQ, Kafka, AMQP, event bus, pub/sub broker, BullMQ, Sidekiq, Celery, message broker, event-driven

**Secondary**: dead letter queue, message retry, consumer group, topic, exchange, queue binding, message ordering, exactly-once delivery, at-least-once, backpressure, partition, offset

### Code Patterns (R1 — for source analysis)

- Broker libraries: `amqplib`, `kafkajs`, `@nestjs/microservices`, `bullmq`, `bull`, `bee-queue`, `celery`, `dramatiq`, `rq`, `bunny`, `sneakers` (Ruby), `php-amqplib`, `laravel-horizon`, `broadway` (Elixir), `Confluent.Kafka` (.NET), `MassTransit`, `spring-kafka`, `spring-amqp`, `spring-cloud-stream`, `pika` (Python)
- Config patterns: `RABBITMQ_URL`, `KAFKA_BROKERS`, `KAFKA_BOOTSTRAP_SERVERS`, `REDIS_URL` with queue context, `CELERY_BROKER_URL`, `AMQP_URL`
- Code patterns: `channel.assertQueue`, `channel.sendToQueue`, `channel.consume`, `producer.send`, `consumer.subscribe`, `@MessagePattern`, `@EventPattern`, `deliver_later` (Rails), `dispatch()` (Laravel), `publish/subscribe` patterns, `@RabbitListener` (Spring), `@KafkaListener`
- Infrastructure: `docker-compose.yml` with `rabbitmq`/`kafka`/`zookeeper`/`redis` service definitions, `Procfile` with worker entries
- Config files: `celeryconfig.py`, `sidekiq.yml`, `queue.php` (Laravel), `cable.yml` (Rails), `application.yml` with `spring.kafka.*` or `spring.rabbitmq.*`

---

## Module Metadata

- **Axis**: Concern
- **Common pairings**: microservice (archetype), task-worker
- **Profiles**: —
