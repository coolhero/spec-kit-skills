# Concern: offline-sync (reverse-spec)

> Offline-first capability detection. Identifies local storage, sync queues, and conflict resolution patterns.

## R1. Detection Signals

> See [`shared/domains/concerns/offline-sync.md`](../../../shared/domains/concerns/offline-sync.md) § Code Patterns

## R3. Analysis Depth Modifiers

When detected, include in analysis:
- Offline storage mechanism (IndexedDB, SQLite, Realm, PouchDB)
- Sync protocol and trigger (connectivity-based, periodic, manual)
- Conflict resolution strategy (LWW, CRDT, field-level merge, user-prompted)
- Network state detection and connectivity handling
- Background sync implementation and queue persistence
- Data schema for offline vs online modes
