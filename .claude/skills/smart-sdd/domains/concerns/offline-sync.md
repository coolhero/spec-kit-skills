# Concern: offline-sync

<!-- Format defined in smart-sdd/domains/_schema.md § Concern Section Schema. -->

> Offline-first data storage, sync queue management, conflict resolution strategies, background sync, network state detection.
> Module type: concern

---

## S0. Signal Keywords

> See [`shared/domains/concerns/offline-sync.md`](../../../shared/domains/concerns/offline-sync.md) § Signal Keywords

---

## S1. SC Generation Rules

### Required SC Patterns
- Offline write: user performs action while offline → change queued in local store with timestamp and operation metadata → UI reflects optimistic update → sync indicator shows pending status
- Sync on reconnect: network connectivity restored → sync queue processed in order → each change sent to server → server responds with accept/conflict → accepted changes confirmed locally → conflicts queued for resolution
- Conflict resolution: server detects conflicting change → conflict metadata returned (server version, client version, timestamps) → resolution strategy applied (last-write-wins / merge / user choice) → resolved state persisted on both sides
- Background sync: periodic or event-driven sync trigger → diff calculated between local and remote state → delta sync (not full sync) → progress reported → interrupted sync resumable from last checkpoint

### SC Anti-Patterns (reject if seen)
- "App works offline" — must specify which data is available offline, storage mechanism, and sync strategy
- "Conflicts are resolved" — must specify resolution strategy (LWW, CRDT, manual merge), what happens to losing changes, and how user is notified
- "Data syncs automatically" — must specify sync trigger (connectivity, timer, manual), conflict handling, and error recovery

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| **Storage** | IndexedDB? SQLite? Realm? What data is stored offline? Size limits? |
| **Sync protocol** | Delta sync? Full sync? Timestamp-based? Vector clock? CRDT? |
| **Conflicts** | Last-write-wins? Field-level merge? User-prompted resolution? How are conflicts surfaced? |
| **Network** | How is connectivity detected? Graceful degradation? Bandwidth-aware sync? |
| **Recovery** | What if sync interrupted? Resumable uploads? Queue persistence across app restart? |

---

## S7. Bug Prevention

| ID | Pattern | Detection | Prevention |
|----|---------|-----------|------------|
| OFS-001 | Lost offline writes | App crash or force-close before sync queue persisted → user changes lost silently | Write to persistent store (IndexedDB/SQLite) before confirming to user; WAL mode for crash safety |
| OFS-002 | Sync queue ordering violation | Dependent operations synced out of order (delete before create) → server rejects or corrupts data | Maintain causal ordering in queue; batch dependent operations; server validates operation sequence |
| OFS-003 | Conflict resolution data loss | Last-write-wins discards earlier edit without user awareness → important changes silently overwritten | Log overwritten versions; notify user of auto-resolved conflicts; provide undo/history for contested fields |
| OFS-004 | Stale UI after sync | Remote changes synced but UI not re-rendered → user sees outdated data → acts on stale state | Reactive data binding from local store; trigger UI refresh on sync completion; invalidate affected queries |
| OFS-005 | Unbounded offline queue | Extended offline period → queue grows indefinitely → device storage exhausted → app crash | Set queue size limit; prioritize recent changes; warn user when approaching limit; compact queue by merging sequential edits to same record |
