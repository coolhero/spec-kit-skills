# Status Command

> Read after `/smart-sdd status` is invoked. For state file schema, see `reference/state-schema.md`.

---

Running `/smart-sdd status` reads `sdd-state.md` and displays the overall progress.

Follows the schema defined in [state-schema.md](../reference/state-schema.md).

### Quick Summary via Script

Run `scripts/pipeline-status.sh <target-path>` first to produce a quick progress summary (project info, constitution status, feature completion %, current feature, blocked/deferred counts). Display the script output as a preamble before rendering the detailed table below.

Optionally, append `scripts/validate.sh <target-path>` output if the user requests a consistency check — this validates cross-file consistency (Feature ID matching between roadmap/state, SBI mappings, Demo Group references).

Output format varies by scope:

**Full scope** (no Tier concept):
```
📊 Smart-SDD Progress Status

Origin: [greenfield | rebuild | adoption]
Constitution: ✅ v1.0.0 (2024-01-15)

Feature         | specify | plan | tasks | analyze | implement | verify | merge | Status
----------------|---------|------|-------|---------|-----------|--------|-------|----------
F001-auth       |   ✅    |  ✅  |  ✅   |   ✅    |    ✅     |   ✅   |  ✅  | completed
F002-product    |   ✅    |  🔄  |       |         |           |        |      | in_progress
F003-cart       |         |      |       |         |           |        |      | pending
F004-search     |   ✅    |  🔀  |  🔀   |         |           |        |      | restructured

Active: 1/4 completed, 1/4 in progress | Restructured: 1 (🔀 = needs re-execution)
```

**Core scope** (with Tier column):
```
📊 Smart-SDD Progress Status

Origin: [greenfield | rebuild | adoption]
Scope: core | Active Tiers: [T1 | T1,T2 | T1,T2,T3]
Constitution: ✅ v1.0.0 (2024-01-15)

Feature         | Tier | specify | plan | tasks | analyze | implement | verify | merge | Status
----------------|------|---------|------|-------|---------|-----------|--------|-------|----------
F001-auth       | T1   |   ✅    |  ✅  |  ✅   |   ✅    |    ✅     |   ✅   |  ✅  | completed
F002-product    | T1   |   ✅    |  🔄  |       |         |           |        |      | in_progress
F003-cart       | T2   |         |      |       |         |           |        |      | 🔒 deferred
F004-payment    | T2   |         |      |       |         |           |        |      | 🔒 deferred

Active: 1/4 completed, 1/4 in progress | Deferred: 2 (Tier 2)
💡 Use /smart-sdd expand to activate deferred Features
```
