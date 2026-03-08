# TODO — Feature Development Completeness

> Resolve information flow gaps (Gaps) discovered by tracing the entire pipeline,
> and add runtime execution-based verification to ensure accuracy of Feature reproduction.

---

## Core Goal: Accuracy of Feature Reproduction

To **identically reproduce** Features from the original app in a new project, functionality loss must be prevented throughout the pipeline.

```
              Input Quality            Implementation Verify      Output Verify
         (reverse-spec)               (implement)                (verify)
         ┌──────────┐                ┌──────────┐              ┌──────────┐
         │ Code     │                │ Code     │              │ Build+   │
  Before │ Analysis │  ───────────→  │ Writing  │  ─────────→  │ Test     │
         │ (Phase 2)│                │ (no run) │              │ (server) │
         └──────────┘                └──────────┘              └──────────┘
                ↓                           ↓                        ↓
         ┌──────────┐                ┌──────────┐              ┌──────────┐
         │ + Runtime │                │ + Per-task│              │ + SC-based│
  After  │  Explor- │  ───────────→  │   Runtime │  ─────────→  │  UI      │
         │  ation   │                │   Verify  │              │  Verify  │
         │ (Ph 1.5) │                │ + Fix Loop│              │ + Parity │
         └──────────┘                └──────────┘              └──────────┘
```

**Feature reproduction mechanisms** (all implemented):

| Mechanism | What It Catches | Status |
|-----------|----------------|--------|
| SBI (Source Behavior Inventory) | Function-level functionality loss — full tracking of exported functions | ✅ |
| UI Component Features (Phase 2-7) | Library config/plugin-based features | ✅ |
| FR ↔ SBI Mapping (specify + verify) | B### → FR-### tracking to prevent spec omission | ✅ |
| Parity Check | Post-implementation comparison against original: structure/logic/UI | ✅ |
| Runtime Exploration (Phase 1.5) | Visual/behavioral context collection — UI/UX invisible to code-only analysis | ✅ |
| Runtime Verification + Fix Loop | Per-task build gate + runtime check during implement | ✅ |
| SC-Based Auto UI Verification | SC-### interaction verification at verify Phase 3 | ✅ |
| Bug Prevention (B-1~4) | Per-stage prevention rules: plan/analyze/implement/verify | ✅ |

---

## Completed Tasks (2026-03-08)

All pipeline gaps (G1–G7) and enhancement tasks (1–9) have been resolved.

| Task | Gap | Summary | Modified Files |
|------|-----|---------|----------------|
| 1 | G1+G2 | runtime-exploration → specify/plan injection | injection/specify.md, injection/plan.md |
| 2 | G3 | Route→Feature Mapping Algorithm in Phase 4-2 | analyze.md |
| 3 | G5 | verify MCP Required Policy (silent-skip → HARD STOP) | verify-phases.md |
| 4 | G4 | implement Runtime Verification + Auto-Fix Loop | injection/implement.md, pipeline.md |
| 5 | — | SC→UI Action Mapping in Coverage header | injection/specify.md, demo-standard.md |
| 6 | — | verify SC-Based Auto UI Verification (Phase 3 Step 2b) | verify-phases.md |
| 7 | G6 | Electron Crash Recovery in Phase 1.5-5 | analyze.md |
| 8 | G7 | SBI Per-Feature Filtering Process (Phase 2-6 → 4-2) | analyze.md |
| 9 | — | Bug Prevention B-1~4 (plan/analyze/implement/verify) | injection/*.md, verify-phases.md, domains/app.md |

---

## MCP Policy (Finalized)

| Platform | MCP | Notes |
|----------|-----|-------|
| Web App | Playwright MCP | Default |
| Electron | Playwright MCP (`--cdp-endpoint`) | Requires temporary CDP switching |
| Tauri v2 | Tauri MCP (future extension) | Currently unsupported |

**MCP Required Policy**: Both reverse-spec and verify require Playwright MCP. If absent, provide installation guide or Skip option.

Details: [MCP-GUIDE.md](MCP-GUIDE.md)

---

## Remaining Work

### 10. Spec-Code Drift (Undecided)

> Reverse-sync spec artifacts when code changes during/after implement.

**Problem**: During pipeline, "also add OAuth" → code changes, but spec/plan/tasks are not updated.

**Potential approaches**:
- A. Detect drift in verify (code vs spec comparison)
- B. Detect new functionality in implement Review + suggest spec additions
- C. Separate `sync` command

**Status**: Undecided — approach decision needed
**Priority**: Low (after real-world validation of Tasks 1–9)

---

## Open Questions

- [ ] Should SC interaction failure ever be promoted to BLOCKING?
- [ ] Should Coverage header UI actions be mandatory or optional?
- [ ] Auto-Fix Loop maximum attempts (3? 5?) — currently set to 3
- [ ] Should build gate be enforced or overridable?
- [ ] How to apply "server start" condition in build gate for desktop apps
- [ ] Context window consumption of B-1 plan stage verification items
- [ ] Should B-1 State Management Anti-patterns be per-library or common principles only?
- [ ] Spec-Code Drift approach decision (A/B/C)

---

## Structural Gap Reference

> 5 structural gaps discovered in F006. All resolved by Tasks 4, 6, 9.

| # | Gap | Resolved By |
|---|-----|-------------|
| 1 | Runtime Verification absent | Tasks 4, 6 |
| 2 | Integration Contract absent | Task 9 (B-2, B-3) |
| 3 | Runtime Constraints unrecognized | Task 9 (B-1) |
| 4 | Behavioral Contract missing | Task 9 (B-1, B-3) |
| 5 | Module Dependency Graph absent | Task 9 (B-3) |

---

## Tauri Extension (Future)

> To be added after Tauri MCP (hypothesi/mcp-server-tauri) stabilization.

**Content to add**:
- Task 3: Tauri MCP branch (webview_interact, webview_screenshot, etc.)
- Task 6: Tauri auto-verification flow (including IPC verification)
- Task 9 (B-3): Tauri IPC Safety Rules, Platform CSS Constraints
- MCP Bridge Plugin auto-installation (new projects)
