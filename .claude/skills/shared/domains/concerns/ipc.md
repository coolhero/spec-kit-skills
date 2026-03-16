# Concern: ipc

> Inter-process communication — Electron, Web Workers, child processes.

---

## Signal Keywords

### Semantic (S0 — for init inference)

**Primary**: Electron, IPC, main process, renderer process, Web Workers, SharedWorker, microservice RPC, child process, message passing

**Secondary**: preload script, contextBridge, process isolation, sandboxed

### Code Patterns (R1 — for source analysis)

- Electron: `ipcMain`, `ipcRenderer`, `contextBridge`, `preload.ts`
- Web Workers: `new Worker()`, `postMessage`, `onmessage`
- Node.js child process: `child_process`, `fork()`, `spawn()`

---

## Module Metadata

- **Axis**: Concern
- **Common pairings**: gui (desktop-app)
- **Profiles**: desktop-app
