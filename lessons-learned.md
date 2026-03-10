# Lessons Learned — spec-kit-skills Pipeline

> Key failure patterns and their countermeasures.
> Read this file when starting verify or debugging quality issues.

---

## G1. Build Pass ≠ Feature Works

**Problem**: Build and tests pass, but runtime is broken
**Case**: F005 Zustand selector instability → infinite re-renders, scroll not working during streaming
**Countermeasures**: Per-task Runtime Check, Runtime Error Zero Gate, 3-Tier SC verification, Pattern Compliance Scan
**Coverage**: ~80% — drops to Level 1 (build-only) when MCP is unavailable

## G2. Foundation Absence

**Problem**: Same infrastructure bugs found repeatedly across Features
**Case**: CSS theme, IPC bridge, state management patterns — 7/7 bugs were Foundation-level
**Countermeasures**: Foundation Gate (one-time pre-verification), Foundation Test auto-generation, Toolchain Pre-flight
**Coverage**: ~90% — most robust

## G3. Source Information Gap

**Problem**: Agent cannot see original source during implement
**Case**: CSS value guessing, SBI metric errors ("3 tabs" vs actual 2 tabs), platform constraint omissions
**Countermeasures**: Source Reference Active Read, Style Token Extraction, SBI Accuracy Cross-Check, CSS Value Map
**Coverage**: ~85% — weakens when Phase 1.5 is skipped

## G4. Async/Temporal Pattern Omission

**Problem**: Only synchronous chains documented, async state transitions missing
**Case**: Loading → streaming → completion → error → cleanup full flow undefined
**Countermeasures**: UX Behavior Contract, Interaction Chains, VERIFY_STEPS temporal verbs
**Coverage**: ~70% — most recently added, insufficient real-world validation

## G5. Context Compaction Procedure Loss

**Problem**: Context compaction during verify → agent loses verify-phases.md reference → Phases skipped
**Case**: F006 Playwright CDP UI verification entirely skipped (F001~F005 all executed successfully)
**Countermeasures**: Verify Progress Checkpoint (sdd-state.md) + Resumption Protocol
**Key insight**: All 66 countermeasures are built on the premise "agent reads skill files." G5 is the meta-problem that breaks this premise.

## G6. Runtime Behavior Verification Gap

**Problem**: verify does static checks (test/build/lint) + UI rendering confirmation (CDP snapshot), but does NOT verify actual runtime behavior (feature interactions, data flow, state changes)
**Case**: F006 — SC verification covered 1/10 SCs (only SC-028 rendering). SCs requiring server connection, tool execution, enable/disable toggles were never runtime-tested. F001~F005 had the same pattern.
**Root causes**:
- verify-phases.md had no step for "run the app and test the feature works"
- SC-level verification (Phase 3 Step 3) only covered SCs in the demo Coverage header — if coverage was low, most SCs got no runtime check
- No defined boundary for what CDP can vs cannot automate (external deps, API keys, etc.)
**Countermeasures**: SC Verification Matrix (classify ALL SCs from spec.md), verification boundary rules (CDP capabilities), coverage gate (warn if < 50%)
**Coverage**: ~75% — external-dependency SCs still need manual verification

## G7. Cross-Feature Integration Contract Gap

**Problem**: Pipeline treats each Feature as isolated unit — no mechanism to define or verify data shape contracts at Feature boundaries
**Case**: F003 ParameterBuilder expects `assistant.mcpMode/mcpServers`, F006 useMCPStore stores differently — no bridge designed, implemented, or verified. 3-layer miss: spec/plan didn't define the contract, implement didn't build the bridge, verify didn't check shape compatibility.
**Root causes**:
- Functional Enablement Chain says "A enables B" but not "A provides {shape} and B expects {shape}"
- Entity/API registries track schemas independently per Feature, no cross-Feature shape comparison
- Enablement Interface Smoke Test checks existence (grep + curl), not data shape compatibility
**Countermeasures**: Integration Contracts (plan.md section defining Provider/Consumer shapes + bridges), Integration Contract Data Shape Verification (verify Phase 2 Step 6)
**Coverage**: ~80% — catches shape mismatches and missing bridges at plan+verify, but cannot catch all semantic compatibility issues

---

## Countermeasure Lineage

```
Initial → V1~V4 (SC verification) → V7 (Foundation Gate) → S1~S4 (Source Reference)
  → S12~S15 (SBI Cross-Check, Stub Detection) → W1~W4 (Playwright Fallback, Pattern Scan)
  → W5~W6 (Chain Completeness, Enablement) → W8~W9 (API Matrix, Zero Gate)
  → W10 (UX Behavior Contract) → Toolchain Pre-flight → Verify Progress Checkpoint
  → SC Verification Matrix (runtime coverage) → Integration Contracts (cross-Feature shapes)
```

---

## Specific Lessons (Past Resolutions)

### L1. HARD STOP Bypass — 56-Point Audit Result
**Situation**: Agent auto-skipped HARD STOPs citing health check passes, non-blocking classification, etc.
**Resolution**: Inserted inline re-ask text at 30+ locations (countering tendency to ignore reference file rules)
**Lesson**: Agents fabricate "reasonable excuses" to bypass safety gates. Inline repetition is the only defense.

### L2. Feature ID Tier-First Reordering
**Situation**: RG-first ordering → Feature skip in T1-only pipeline (F003 → F004(T2) → F005 ordering issue)
**Resolution**: Switched to Tier-first global ordering (all T1 → all T2 → all T3)
**Lesson**: Feature ordering must be tested under "single Tier active" scenarios, not just "all Tiers active."

### L3. ESLint Command Not Found — Recurring
**Situation**: "eslint: command not found" repeated at every Feature's verify Phase 1
**Resolution**: Foundation Gate Toolchain Pre-flight (detect once → cache in sdd-state.md) + auto-install offer
**Lesson**: The assumption "tool is installed" must be verified early in the pipeline.

### L4. verify-phases.md and injection/verify.md Inconsistency
**Situation**: Added verification items to verify-phases.md → injection/verify.md Checkpoint/Review not updated
**Resolution**: Full file audit found 4 Critical + 2 Major inconsistencies, all fixed
**Lesson**: Verification logic and display logic must always be updated as a pair.

### L5. Zustand Selector Instability — Infinite Re-renders
**Situation**: F005 build passes but runtime has infinite re-renders (new array/object references created every render)
**Resolution**: Added "Selector reference instability" pattern to Pattern Compliance Scan
**Lesson**: React state library selector patterns cannot be caught by build/test alone.

### L6. Demo-Ready Anti-Pattern — Test Files Mistaken for Demos
**Situation**: Agent generated test suites as "demos." Executable but doesn't demonstrate the actual Feature
**Resolution**: Added "MUST launch real Feature, NOT test-only" rule to Demo Standard + Phase 3 verification
**Lesson**: "Executable" and "demonstrable" are different. The purpose of a demo is to showcase functionality.

### L7. Source Reference Path Resolution
**Situation**: pre-context.md recorded absolute paths to original files → unresolvable on other machines
**Resolution**: Store Source Path in sdd-state.md, pre-context uses relative paths only
**Lesson**: Paths must always be designed as relative path + runtime resolution.

### L8. Cross-File Consistency — 9-Issue Audit
**Situation**: After adding W1~W10, downstream files (injection/tasks, implement, verify) were not updated
**Resolution**: Full pipeline ↔ verify ↔ injection flow audit, 9 issues fixed
**Lesson**: When adding new mechanisms, always trace "which downstream files read this value."
