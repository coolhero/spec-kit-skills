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

## S3. Verify Steps

Additional verification steps when IPC concern is active.

| Step | Required | Detection | Description |
|------|----------|-----------|-------------|
| `ipc-channel-audit` | BLOCKING | `scripts/wiring-check.sh` or manual grep for handler registrations | Every registered IPC handler has a matching caller. Orphan handlers = dead code or missing integration |
| `ipc-n-layer-check` | BLOCKING | Trace each channel: handler → bridge (if applicable) → caller | All communication layers are implemented per architecture (e.g., Electron 3-layer, Web Workers 2-layer) |
| `ipc-payload-shape` | BLOCKING | Compare TypeScript types or runtime shapes across handler/caller | Request/response payload shapes match across all IPC layers. Shape mismatch = runtime error |

---

## S4. Data Integrity Extensions (IPC-specific)

> Extends `_core.md` S4 (Data Integrity Principles) with IPC-specific integrity patterns.

- **IPC N-Layer Completeness** (S4x): Every IPC channel must have ALL layers of the communication chain implemented. Missing layers cause silent failures at runtime, passing all static checks.
  - **Electron (3-layer)**: Handler (main) → Bridge (preload) → Caller (renderer)
  - **Web Workers (2-layer)**: Worker handler → Main thread caller
  - **Microservice RPC (3-layer)**: Server handler → Client stub/proxy → Caller
  - Detection: `scripts/wiring-check.sh` § IPC/API Registration Check

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
- **IPC N-Layer Completeness**: See § S4 above for full definition. Any missing layer → `scripts/wiring-check.sh` § IPC/API Registration Check catches this as BLOCKING. Each layer must use consistent channel names and parameter shapes (checked by Wiring Check § Parameter Shape Cross-Check).
- **IPC Channel Registration Audit**: After implement, grep for all registered handlers and verify each has a corresponding caller. Orphan handlers (registered but never called) = ⚠️ WARNING (dead code or missing caller)

---

## S9. Brief Completion Criteria

When IPC concern is active, the Brief is not considered complete until:

| Required Element | Completion Signal |
|-----------------|-------------------|
| At least one IPC boundary identified | Process names + communication direction stated (e.g., "main → renderer via preload bridge") |
| Channel inventory | At least the primary channels/methods listed with purpose (e.g., "file-read: main reads file, returns content to renderer") |
| Error handling strategy | What happens when the other process is unavailable or crashes (e.g., "timeout after 5s, show error toast") |
