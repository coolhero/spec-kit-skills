# Concern: realtime

> WebSocket, SSE, live updates, persistent connections.

---

## Signal Keywords

### Semantic (S0 — for init inference)

**Primary**: WebSocket, SSE, Socket.io, real-time, live updates, streaming, push notifications, gRPC streaming, MQTT

**Secondary**: reconnection, heartbeat, pub/sub, event-driven, broadcast, presence

### Code Patterns (R1 — for source analysis)

- Libraries: `socket.io`, `ws`, `@nestjs/websockets`, `channels` (Django)
- SSE patterns: `EventSource`, `text/event-stream`
- Pub/sub: Redis pub/sub, NATS, RabbitMQ with streaming

---

## Module Metadata

- **Axis**: Concern
- **Common pairings**: gui, http-api
- **Profiles**: —
