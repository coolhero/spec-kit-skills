# Concern: realtime (reverse-spec)

> Real-time communication detection. Identifies persistent connection patterns.

## R1. Detection Signals
- Libraries: `socket.io`, `ws`, `@nestjs/websockets`, `channels` (Django)
- SSE patterns: `EventSource`, `text/event-stream`
- Pub/sub: Redis pub/sub, NATS, RabbitMQ with streaming
