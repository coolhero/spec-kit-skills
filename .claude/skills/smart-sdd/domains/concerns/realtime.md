# Concern: realtime

> Real-time communication (WebSocket, SSE, Socket.io, etc.).
> Applies when the project uses persistent connections for live data.
> Module type: concern

---

## S0. Signal Keywords

> See [`shared/domains/concerns/realtime.md`](../../../shared/domains/concerns/realtime.md) § Signal Keywords

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

---

## S9. Brief Completion Criteria

| Required Element | Completion Signal |
|-----------------|-------------------|
| Connection type | WebSocket, SSE, or polling identified |
| Event types | At least one real-time event described (what triggers it, what data it carries) |
| Reconnection requirement | Whether auto-reconnect is needed stated |
