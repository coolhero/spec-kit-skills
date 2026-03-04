# Add Command — Brownfield Incremental

> Reference: Read after `/smart-sdd add` is invoked. For shared rules, see SKILL.md.

## Add Command — Brownfield Incremental

Running `/smart-sdd add` adds new Feature(s) to an existing smart-sdd project.

**Prerequisite**: `roadmap.md`, `entity-registry.md`, `api-registry.md`, and `sdd-state.md` must already exist at BASE_PATH.

### Add Workflow

#### Phase 1: Current Project State

1. Read `sdd-state.md` → completed/in-progress Feature list
2. Read `roadmap.md` → Feature Catalog, Dependency Graph
3. Read `entity-registry.md` → currently defined entities
4. Read `api-registry.md` → currently defined APIs
5. Display current state summary to the user:
   ```
   📊 Current Project State:

   Features: N total (X completed, Y in-progress, Z pending)
   Entities: N defined
   APIs: N defined

   Completed Features: F001-auth, F002-product, ...
   In-progress: F003-order (→ plan step)
   Pending: F004-payment, ...
   ```

#### Phase 2: New Feature Definition (Interactive Q&A)

1. Ask the user: "Describe the Feature(s) you want to add"
   - Feature name, description
   - Which existing Features it depends on (entity references, API calls, etc.)
   - Tier classification: Only if the project uses `core` scope (read from `sdd-state.md`). Default: Tier 2. If project scope is `full`, no Tier assignment needed.
2. Multiple Features can be added at once (iterative)
3. Define dependencies between new Features if applicable
4. Assign Feature IDs: continue from the last existing ID

#### Phase 3: Checkpoint (HARD STOP)

1. Display new Feature(s) with dependencies (and Tier, if `core` scope)
2. Show the updated Dependency Graph (existing + new nodes)
3. Propose Release Group placement
4. Use AskUserQuestion to ask for approval. **You MUST STOP and WAIT for the user's response. Do NOT proceed to Phase 4 until the user explicitly approves or requests modifications.** **If response is empty → re-ask** (per MANDATORY RULE 1).

#### Phase 4: Artifact Updates

1. **Update `roadmap.md`**:
   - Add new Features to Feature Catalog
   - Add new nodes/edges to Dependency Graph
   - Place new Features in Release Groups
   - Update Cross-Feature Entity/API Dependencies

2. **Create `features/F00N-name/pre-context.md`** per new Feature:
   - Source Reference: "N/A (added to existing project)"
   - For /speckit.specify: Feature description + dependency summary (no FR/SC drafts)
   - For /speckit.plan: Dependencies with entity/API info copied from existing registries
   - For /speckit.analyze: Dependency-based cross-Feature verification points

3. **Update `sdd-state.md`**:
   - Add new Features to Feature Progress table (`pending`)
   - Add to Feature Mapping
   - Record "Feature added" in Global Evolution Log

#### Phase 5: Completion Report

```
✅ Added N new Feature(s) to the project:
  F006-notifications — depends on F001-auth, F003-order [Tier 2 if core scope]
  F007-analytics — depends on F002-product [Tier 3 if core scope]

Updated: roadmap.md, sdd-state.md
Created: features/F006-notifications/pre-context.md, features/F007-analytics/pre-context.md

Next steps:
  /smart-sdd specify F006     — Start specifying the first new Feature
  /smart-sdd pipeline         — Resume pipeline (picks up from first pending Feature)
```
