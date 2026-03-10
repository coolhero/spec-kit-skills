# Concern: ipc

> Inter-process communication (Electron main/renderer, Web Workers, microservice RPC).
> Applies when the project has IPC boundaries between processes.
> Module type: concern

---

## S0. Signal Keywords

> Keywords that indicate this module should be activated. Used by Clarity Index signal extraction.

**Primary**: Electron, IPC, main process, renderer process, Web Workers, SharedWorker, microservice RPC, child process, message passing
**Secondary**: preload script, contextBridge, process isolation, sandboxed

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
