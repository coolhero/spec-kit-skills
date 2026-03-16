# Pipeline Integrity Guards

> **7 generalized guard patterns** extracted from 44 field-discovered failure cases (SKF-001 through SKF-044).
> Each guard addresses a **class** of pipeline failure — not a single instance.
> When a new failure occurs, classify it under one of these guards and add the specific rule to the relevant injection/command file, cross-referencing this document.
>
> **Design principle**: Guards are extensible. Each guard defines a **Trigger Condition**, **Verification Method**, and **Enforcement Level**. New project types, tech stacks, or failure modes are handled by extending the guard — not by creating a new ad-hoc rule.

---

## Guard 1: Guideline → Gate Escalation

**Root cause**: Rules written as "should" or "recommended" get skipped by agents under context pressure.

**Pattern**: Any rule whose violation causes Major+ quality regression MUST be a BLOCKING gate, not a guideline. A BLOCKING gate requires agent action (AskUserQuestion, file read, or assertion) before proceeding — it cannot be silently skipped.

**Trigger conditions** (promote to BLOCKING when ANY apply):
- Rebuild mode
- GUI Feature with visual fidelity requirements
- Cross-Feature dependency (Integration Contracts with Provides →)
- Rule has been violated in a previous SKF (historical evidence)

**Application points**:
| Rule | File | Enforcement |
|------|------|-------------|
| Source Reference Injection | injection/implement.md | BLOCKING: "📂 Source Reference: [N] files loaded" required before UI tasks |
| Visual Reference Checkpoint | injection/implement.md | BLOCKING: HARD STOP before first UI task |
| Interaction Surface Preservation | injection/implement.md | BLOCKING: read inventory before modifying shared components |
| Source Component Mapping | injection/plan.md | BLOCKING: plan Review rejects if source components unmapped |

**Extensibility**: New rules default to WARNING. After first documented violation (SKF entry), automatically promote to BLOCKING. Track promotions in `lessons-learned.md`.

---

## Guard 2: Static ≠ Runtime Verification

**Root cause**: Build/TypeScript/lint pass while runtime behavior is broken. CSS not rendering, UI not interactive, API returning 404 — all invisible to static checks.

**Pattern**: Static checks are **necessary but not sufficient** for GUI projects. Every static pass must be paired with a runtime verification of equivalent scope.

**Trigger conditions**:
- GUI Feature with `RUNTIME_BACKEND ≠ build-only`
- Feature introduces new CSS framework/plugin
- Feature uses SDK with version-sensitive API
- Feature has streaming/async data flows

**Verification chain** (each level includes all previous):
```
Level 0: Build + TS + Lint                    (static — catches syntax/type errors)
Level 1: + App launches without crash         (smoke — catches import/config errors)
Level 2: + UI elements render visually        (render — catches CSS/template errors)
Level 3: + Interactions produce correct state  (functional — catches logic errors)
Level 4: + Data persists across restart        (round-trip — catches persist errors)
```

**Application points**:
| Check | Phase | Level |
|-------|-------|-------|
| Post-Implement Smoke Launch | implement | Level 1 |
| CSS Rendering Check | implement + verify Phase 1 | Level 2 |
| Playwright SC Verification | verify Phase 3 | Level 3 |
| Data Round-trip Verification | verify Phase 3 | Level 4 |

**CSS Toolchain Registry** (extensible — add entries as new CSS tools are encountered):
| Tool | Required Plugin | Verification |
|------|----------------|--------------|
| Tailwind CSS 4 | `@tailwindcss/vite` or `@tailwindcss/postcss` | `@theme` block in globals.css; `getComputedStyle` ≠ transparent |
| PostCSS | postcss.config.js | Plugin chain produces non-empty output |
| CSS Modules | vite/webpack css-modules config | `.module.css` imports resolve |

**Extensibility**: When a new CSS/build tool causes a "builds but doesn't render" failure, add it to the CSS Toolchain Registry above. The guard pattern stays the same — only the registry grows.

---

## Guard 3: Cross-Stage Trust Breakers (Circuit Breakers)

**Root cause**: Pipeline stages blindly trust previous stage output. A wrong assumption at stage N propagates unchanged through N+1, N+2, ... N+6. No independent verification.

**Pattern**: Critical assumptions — especially those only verifiable at runtime — need **independent verification at 2+ pipeline stages**. These act as circuit breakers, stopping error propagation before it compounds.

**Trigger conditions**:
- Rebuild mode (source app exists as ground truth)
- Features with settings/mode/config that affect UI structure
- Features where runtime defaults differ from code-level static analysis
- Any assumption labeled "inferred from code" rather than "verified at runtime"

**3 Gate positions** (rebuild + GUI):
| Gate | Pipeline Position | Verification | Source SKF |
|------|-------------------|-------------|-----------|
| Gate 1 | specify entry | Source app runtime → verify config defaults match SBI | SKF-013 |
| Gate 2 | implement entry | Read Interaction Surface Inventory + analyze source layout structure | SKF-009, 016 |
| Gate 3 | verify Phase 3e | Source app comparison: MANDATORY for rebuild+GUI, BLOCKING | SKF-014, 024 |

**Extensibility**: Additional gates can be defined per-project in the constitution. Each gate needs: (1) what to verify, (2) how to verify, (3) what to do on mismatch. The 3-gate structure is the minimum — projects may add gates at plan or tasks stages.

---

## Guard 4: Granularity Alignment

**Root cause**: Analysis operates at file/function level, but bugs occur at UI control level. A settings page with 15 toggles gets one SBI entry ("renders settings page"), causing 14 toggles to be missed downstream.

**Pattern**: SBI, FR, Task, and Interaction Chain granularity must match the **interaction granularity** of the UI. Dense UI pages require control-level decomposition.

**Trigger conditions**:
- UI page/component with 5+ interactive controls (Switch, Select, Input, Button, Slider)
- Settings pages, form pages, dashboards, admin panels
- FR description contains "and" or "," joining distinct interactive elements

**3 Decomposition rules**:

### Rule 4a: SBI Control-Level Resolution (reverse-spec Phase 2)
When a source file contains 5+ form control elements, each control becomes an individual SBI entry, not a single "renders page" SBI. Applied in `reverse-spec/commands/analyze.md` Phase 2.

### Rule 4b: FR Element Decomposition (analyze)
When an FR description contains multiple interactive elements joined by "and"/"," → decompose into individual elements. Each element must have a corresponding task. Applied in `injection/analyze.md` Coverage Severity Rules.

### Rule 4c: Component Tree Extraction (reverse-spec Phase 2-7c)
Extract parent-child component hierarchy for each page/route. Conditional rendering branches and panel systems are explicitly noted. Applied in `reverse-spec/commands/analyze.md` Phase 2-7c, output to pre-context.md.

**Extensibility**: The threshold (5+ controls) is a default. Projects with simpler UIs can raise it; projects with complex micro-interactions can lower it. Configurable via `project_maturity` in constitution or sdd-state.md.

---

## Guard 5: Environment Parity

**Root cause**: Playwright `_electron.launch()` creates a clean-state environment with no persisted data. Tests pass in clean state but fail in the user's real environment (fontSize 22, persisted API keys, stale localStorage, different language).

**Pattern**: Verification must cover **both** clean state (baseline) and real-world state (with persisted data, non-default settings). Neither alone is sufficient.

**Trigger conditions**:
- Feature reads from persistent storage (electron-store, SQLite, localStorage)
- Feature has configurable display settings (fontSize, theme, language)
- Feature depends on data created by previous sessions

**Dual-Mode Verification Protocol**:
```
A. Clean Environment (Playwright _electron.launch — isolated userData):
   - Baseline rendering + default-setting functionality
   - This alone is INSUFFICIENT for verify pass

B. Real Environment Simulation:
   - Option 1: _electron.launch with --user-data-dir pointing to user's actual data
   - Option 2: Dev server + Playwright MCP browser_navigate(localhost:port)
   - Option 3: Screenshot request to user (last resort)
   - Test with non-default settings (fontSize extremes, non-default language, etc.)

Both A and B must pass for verify Phase 3 to pass.
```

**Test State Isolation Rules**:
1. Before test: reset to known state OR detect current state before asserting
2. Toggle tests: read current value → change to opposite → verify change (never assume initial state)
3. Each test scenario: order-independent (no dependency on previous test's side effects)

**Extensibility**: Add new environment dimensions as discovered. Current dimensions: persist data, display settings, language, OS theme. Future: network conditions, timezone, accessibility mode.

---

## Guard 6: Cross-Feature Interface Verification

**Root cause**: Feature A is verified in isolation (build ✅, UI renders ✅) but its interface to Feature B is broken (hydrate() missing, API returning wrong format, stub never replaced).

**Pattern**: `Provides →` interfaces must be verified **from the consumer's perspective**, not just the provider's. A Feature's merge is blocked if its downstream interfaces don't work.

**Trigger conditions**:
- Integration Contracts with `Provides →` entries
- Dependency Stub Registry entries targeting current Feature
- IPC/store patterns where renderer depends on main process data

**3 Verification mechanisms**:

### 6a: Provides Interface Verification (verify Phase 2)
For each `Provides →` in Integration Contracts:
1. Simulate downstream Feature's consumption scenario (IPC call, store read, API fetch)
2. Persist-dependent interfaces: verify after app restart (round-trip)
3. All must pass → merge allowed. Any failure → BLOCKING.

### 6b: Interaction Surface Inventory (implement → verify)
After implement: generate `specs/{NNN-feature}/interaction-surfaces.md` listing all user-facing interaction points (drag regions, window controls, keyboard shortcuts, theme toggles).
Next Feature's implement: read inventory before modifying shared components.
Verify Phase 3: Playwright checks each surface still works.

### 6c: Dependency Stub Resolution (implement → verify)
During implement: if a behavior is stubbed due to future Feature dependency, record in `specs/{NNN-feature}/stubs.md`.
When the dependency Feature starts: inject stub list into specify/plan/tasks context.
During dependency Feature's verify: check that relevant stubs were resolved.

**Extensibility**: Each new cross-Feature integration pattern → add a consumer verification scenario template. The Inventory/Stub mechanism is generic — it works for any project type, not just Electron.

---

## Guard 7: Rebuild Fidelity Chain

**Root cause**: Rebuild projects produce UI that looks nothing like the source app. This happens because source structure is captured once (reverse-spec) then ignored through 5 subsequent stages.

**Pattern**: In rebuild mode, source app structure must be a **first-class artifact** referenced at every pipeline stage — not just a one-time input to reverse-spec.

**Trigger conditions**:
- Pipeline mode = rebuild (reverse-spec → pipeline)
- Source app has GUI

**Fidelity Chain** (source structure flows through entire pipeline):
```
reverse-spec → Component Tree in pre-context.md
    ↓
specify → FR references specific source components
    ↓
plan → Source Component Mapping Table (source→target, BLOCKING)
    ↓
tasks → Each UI task references source component(s)
    ↓
implement → Source-First: read source BEFORE writing code (BLOCKING gate)
    ↓
verify → Source App Comparison: run both apps, compare (BLOCKING for rebuild+GUI)
```

**Key artifacts**:
| Artifact | Created by | Consumed by |
|----------|-----------|-------------|
| Component Tree (pre-context.md § Component Tree) | reverse-spec Phase 2-7c | plan, implement |
| Source→Target Mapping (plan.md § Source Component Mapping) | plan | tasks, implement, verify |
| Source Reference Log (per-task "📂 Source Reference: [files]") | implement | verify |

**Extensibility**: The chain structure is generic. For non-GUI rebuilds (API migration, CLI tool rebuild), the "Component Tree" becomes "API Endpoint Tree" or "Command Tree" — same pattern, different vocabulary. Add new tree types to reverse-spec Phase 2 as needed.

---

## Using This Document

1. **When a new SKF is discovered**: Classify it under one of the 7 guards. If it doesn't fit, it's either a Guard extension or a candidate for Guard 8.
2. **When adding a rule to an injection/command file**: Cross-reference the guard: `(See pipeline-integrity-guards.md § Guard N)`
3. **When reviewing pipeline for a new project type**: Walk through all 7 guards and verify each has at least one application point.
4. **Guard coverage check**: `grep -c "Guard [1-7]" injection/*.md verify-phases.md pipeline.md` should show references in at least 3 files per guard.
