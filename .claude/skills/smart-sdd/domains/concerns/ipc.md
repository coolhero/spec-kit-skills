# Concern: ipc

> Inter-process communication (Electron main/renderer, Web Workers, microservice RPC).
> Applies when the project has IPC boundaries between processes.
> Module type: concern

---

## S0. Signal Keywords

> See [`shared/domains/concerns/ipc.md`](../../../shared/domains/concerns/ipc.md) § Signal Keywords

---

## S1. SC Generation Rules

### Required SC Patterns
- IPC calls: specify channel/method + request payload + response payload + error case
- Process lifecycle: specify startup order, graceful shutdown, crash recovery

### SC Anti-Patterns (reject)
- "IPC communication works" — must specify channel, payload shapes, and error handling

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| **IPC channels** | What channels/methods? Request/response or fire-and-forget? |
| **Error handling** | What happens when the other process is unavailable? |
| **Security** | Are IPC channels validated? Input sanitization? |

---

## S7. Bug Prevention Rules

When this concern is active, enforce:
- IPC Boundary Safety: mandatory optional chaining + nullish coalescing for all IPC return values. See `injection/implement.md` § Bug Prevention B-3
- IPC Return Value Defense: never trust IPC return shape without validation. See `injection/implement.md` § Bug Prevention B-3
- **IPC N-Layer Completeness**: Every IPC channel must have ALL layers of the communication chain implemented. The number of layers depends on the architecture:
  - **Electron (3-layer)**: Handler (main) → Bridge (preload) → Caller (renderer)
  - **Web Workers (2-layer)**: Worker handler → Main thread caller
  - **Microservice RPC (3-layer)**: Server handler → Client stub/proxy → Caller
  - **Any layer missing → implement Wiring Check § IPC/API Registration Check catches this as BLOCKING**
  - Each layer must use consistent channel names and parameter shapes (checked by Wiring Check § Parameter Shape Cross-Check)
- **IPC Channel Registration Audit**: After implement, grep for all registered handlers and verify each has a corresponding caller. Orphan handlers (registered but never called) = ⚠️ WARNING (dead code or missing caller)
