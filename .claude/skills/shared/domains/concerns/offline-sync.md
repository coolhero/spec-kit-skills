# Concern: offline-sync

> Offline-first data storage, sync queue management, conflict resolution strategies, background sync, network state detection.

---

## Signal Keywords

### Semantic (S0 — for init inference)

**Primary**: offline-first, sync queue, conflict resolution, background sync, IndexedDB, service worker, offline mode, data synchronization, CRDT

**Secondary**: network state, connectivity detection, optimistic update, last-write-wins, merge conflict, sync protocol, replication, local-first, eventual consistency, retry queue, pending changes, reconciliation

### Code Patterns (R1 — for source analysis)

- Storage: `IndexedDB`, `localForage`, `WatermelonDB`, `PouchDB`, `CouchDB`, `Realm`, `SQLite`, `MMKV`
- Sync: `SyncManager`, `BackgroundSync`, `navigator.onLine`, `NetInfo`, `workbox-background-sync`
- CRDT: `automerge`, `yjs`, `diamond-types`, `loro`
- Patterns: `syncQueue`, `pendingChanges`, `conflictResolver`, `lastSyncTimestamp`, `offlineStorage`, `replicationState`

---

## Module Metadata

- **Axis**: Concern
- **Common pairings**: async-state, mobile
- **Profiles**: —
