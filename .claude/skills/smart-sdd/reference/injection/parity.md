# Context Injection: Parity

> Read targets and update rules for `/smart-sdd parity`.
> The parity command has its own multi-phase workflow — see [parity.md](../../commands/parity.md).
> It does NOT follow the Common Protocol (Assemble → Checkpoint → Execute+Review → Update) and does NOT wrap a spec-kit command.

---

## Domain Module Filtering (per _resolver.md Step 5)

Parity uses S2 (Parity Dimensions) from domain modules. Retain ONLY S2; skip all other sections.

| Active (retain) | Skipped (discard from context) |
|-----------------|-------------------------------|
| S2 | S0, S1, S3, S5, S6, S7, S8, S9 |

Display in Checkpoint: `📊 Domain: [N] modules → S2 active | all other sections skipped`

---

## Read Targets

| File | Section | Filtering |
|------|---------|-----------|
| `BASE_PATH/coverage-baseline.md` | Intentional Exclusions table | Filter known exclusions from gap list. **If file does not exist, skip — no exclusion filtering** |
| `BASE_PATH/entity-registry.md` | Entity Index | All entities for structural parity comparison |
| `BASE_PATH/api-registry.md` | API Index | All endpoints for structural parity comparison |
| `BASE_PATH/business-logic-map.md` | All Feature sections | All rules for logic parity comparison. **If file does not exist (greenfield origin), skip logic parity Phase 2 entirely** |
| `BASE_PATH/sdd-state.md` | Source Path, Feature Progress, Origin | Source path resolution, completed Features list, origin verification |
| `SPEC_PATH/*/spec.md` | Requirements sections (FR-###) | All completed Features' requirements for logic rule mapping |
| `SPEC_PATH/*/data-model.md` | Entity schemas | All completed Features' entities for structural comparison |
| `SPEC_PATH/*/contracts/*.md` | API contracts | All completed Features' APIs for structural comparison |

## Source Path Resolution

1. If `--source <path>` argument is provided → use that path
2. If not → read `Source Path` from `sdd-state.md`
3. If Source Path is `N/A` (greenfield) → display error: "⚠️ Parity check is only available for brownfield rebuild projects (Origin: rebuild)." and exit
4. Verify the resolved path exists and is accessible. If not found → display error and prompt user for a valid path

## Display Content

No Checkpoint/Review cycle. The parity command displays progress after each of its 5 phases:
- Phase 1: Structural parity metrics table
- Phase 2: Logic parity metrics table
- Phase 3: Gap report summary + parity-report.md generation
- Phase 4: Remediation plan per group (HARD STOP per group)
- Phase 5: Completion report

---

## Post-Parity Update Rules

1. **Generate `BASE_PATH/parity-report.md`** with gaps, grouping, and exclusions
2. **Update `BASE_PATH/sdd-state.md`**:
   - Add entry to Parity Check Log (date, source path, parity %, gaps, actions, status)
   - If new Features created via `add` workflow: add to Feature Progress table (pending)
   - If existing Features flagged for re-execution: mark with 🔀 from specify in Feature Progress
   - Record all changes in Global Evolution Log
3. **If new Features created**:
   - Update `BASE_PATH/roadmap.md` (Feature Catalog, Dependency Graph)
   - Generate `SPEC_PATH/[NNN-feature]/pre-context.md` per new Feature
4. **If cross-cutting gaps trigger constitution update**:
   - Follow Constitution Incremental Update procedure (SKILL.md)
   - Create infrastructure Feature via `add` workflow
5. **Update `BASE_PATH/coverage-baseline.md`** (if it exists):
   - Add newly classified intentional exclusions from Phase 4
