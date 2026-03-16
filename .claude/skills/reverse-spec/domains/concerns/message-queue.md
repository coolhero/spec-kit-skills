# Concern: message-queue (reverse-spec)

> Message broker and event bus detection. Identifies async messaging patterns via RabbitMQ, Kafka, Redis queues, Sidekiq, BullMQ, Celery, and similar systems.

## R1. Detection Signals
- Broker libraries: `amqplib`, `kafkajs`, `@nestjs/microservices`, `bullmq`, `bull`, `bee-queue`, `celery`, `dramatiq`, `rq`, `bunny`, `sneakers` (Ruby), `php-amqplib`, `laravel-horizon`, `broadway` (Elixir), `Confluent.Kafka` (.NET), `MassTransit`, `spring-kafka`, `spring-amqp`, `spring-cloud-stream`, `pika` (Python)
- Config patterns: `RABBITMQ_URL`, `KAFKA_BROKERS`, `KAFKA_BOOTSTRAP_SERVERS`, `REDIS_URL` with queue context, `CELERY_BROKER_URL`, `AMQP_URL`
- Code patterns: `channel.assertQueue`, `channel.sendToQueue`, `channel.consume`, `producer.send`, `consumer.subscribe`, `@MessagePattern`, `@EventPattern`, `deliver_later` (Rails), `dispatch()` (Laravel), `publish/subscribe` patterns, `@RabbitListener` (Spring), `@KafkaListener`
- Infrastructure: `docker-compose.yml` with `rabbitmq`/`kafka`/`zookeeper`/`redis` service definitions, `Procfile` with worker entries
- Config files: `celeryconfig.py`, `sidekiq.yml`, `queue.php` (Laravel), `cable.yml` (Rails), `application.yml` with `spring.kafka.*` or `spring.rabbitmq.*`
