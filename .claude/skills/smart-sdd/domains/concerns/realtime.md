# Concern: realtime

> Real-time communication (WebSocket, SSE, Socket.io, etc.).
> Applies when the project uses persistent connections for live data.
> Module type: concern

---

## S0. Signal Keywords

> Keywords that indicate this module should be activated. Used by Clarity Index signal extraction.

**Primary**: WebSocket, SSE, Socket.io, real-time, live updates, streaming, push notifications, gRPC streaming, MQTT
**Secondary**: reconnection, heartbeat, pub/sub, event-driven, broadcast, presence

---

## S1. SC Generation Rules

### Required SC Patterns
- Connection lifecycle: connect -> authenticate -> subscribe -> receive -> disconnect
- Reconnection: specify trigger + backoff strategy + state reconciliation after reconnect
- Event delivery: specify event type + payload shape + ordering guarantees

### SC Anti-Patterns (reject)
- "Real-time updates work" — must specify event types, delivery guarantees, and reconnection behavior

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| **Protocol** | WebSocket? SSE? Socket.io? gRPC streaming? |
| **Events** | What events are published/subscribed? Payload shapes? |
| **Reliability** | Reconnection strategy? Message ordering? At-least-once/exactly-once? |
| **Scaling** | Multiple server instances? Sticky sessions? Pub/sub broker? |
