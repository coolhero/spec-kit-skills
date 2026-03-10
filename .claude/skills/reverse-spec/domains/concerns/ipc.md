# Concern: ipc (reverse-spec)

> IPC communication detection. Identifies inter-process communication patterns.

## R1. Detection Signals
- Electron: `ipcMain`, `ipcRenderer`, `contextBridge`, `preload.ts`
- Web Workers: `new Worker()`, `postMessage`, `onmessage`
- Node.js child process: `child_process`, `fork()`, `spawn()`
