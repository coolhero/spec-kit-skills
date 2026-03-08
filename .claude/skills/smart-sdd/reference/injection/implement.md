# Context Injection: Implement

> Per-command injection rules for `/smart-sdd implement [FID]`.
> For shared patterns (HARD STOP, Checkpoint, Missing/Sparse Content Handling), see [context-injection-rules.md](../context-injection-rules.md).

---

## Read Targets

| File | Section | Filtering |
|------|---------|-----------|
| `SPEC_PATH/[NNN-feature]/tasks.md` | Entire file | Current Feature |
| `SPEC_PATH/[NNN-feature]/quickstart.md` | Entire file | **If exists** — run instructions for the Feature |
| `BASE_PATH/features/[FID]-[name]/pre-context.md` | "Static Resources" section | **If present and non-empty** |
| `BASE_PATH/features/[FID]-[name]/pre-context.md` | "Environment Variables" section | **If present and non-empty** |
| `BASE_PATH/features/[FID]-[name]/pre-context.md` | "Naming Remapping" section | **If present (project identity changed)** |

## Static Resource Handling

Before or during implementation, if the Feature's `pre-context.md` has a non-empty Static Resources section:

1. Read `Source Path` from `sdd-state.md` to get the Source Root value
2. For each resource listed in the Static Resources table:
   - **Copy** the file from `[Source Path]/[relative Source Path column]` to `[Target Path column]` in the new project
   - Create target directories if they don't exist
   - If the source file is not found, warn: "⚠️ Static resource not found: [path]. Manual action required."
3. If any resources have modification notes (in the Usage column), display them to the user after copying
4. Include the resource copy as a task in the implementation — either as a pre-task before code implementation or integrated into the relevant code task

**Greenfield projects**: Skip — no Static Resources section exists.
**Incremental (add) projects**: Source Path = `.`, so resources are already in place. Skip copying but verify the files exist at the expected paths.

## Environment Variable Handling

Before implementation, if the Feature's `pre-context.md` has a non-empty Environment Variables section:

1. Read the Feature's `pre-context.md` → "Environment Variables" section (both owned and shared variables)
2. Check if a `.env` file exists in the project root
3. If `.env` exists: Check for the **presence** of each required variable name (do NOT read actual values)
4. Display a summary showing which variables are set (✅) and which are missing (❌)
5. **If any REQUIRED variables are missing**: HARD STOP — use AskUserQuestion with "Environment is ready" / "Skip for now" and WAIT for user response. If "ready", re-check to verify. If "skip", warn and proceed.
6. **If all required variables are present**: Display "✅ All set" and proceed without stopping.

**Security rule**: NEVER read actual values from `.env`. Only check for the **presence** of variable names (e.g., check if a line starts with `VARIABLE_NAME=`). Never display, log, or reference actual secret values.

**Greenfield projects**: Environment Variables section may be empty or contain "TBD" entries. Display TBD entries as reminders during implementation.
**Incremental (add) projects**: `.env` should already exist. Verify required variables are present.

## Naming Remapping (only if pre-context has a Naming Remapping section)

When the Feature's `pre-context.md` contains a "Naming Remapping" section (indicating the project identity changed):

1. Read the Naming Remapping table — it lists original identifiers found in this Feature's source files and their new names
2. **Inject as context for `speckit-implement`**: Before execution, provide the remapping table as implementation guidance:
   ```
   ⚠️ Project Identity Remapping for [FID]:
   The following identifiers from the original source must use new names:
     createCherryIn → createAngdu (function)
     CherryProvider → AngduProvider (class)
     CHERRY_API_KEY → ANGDU_API_KEY (env var)
   Ensure all new code uses the "New Identifier" column. Do NOT carry over original project naming.
   ```
3. This is a **soft reminder** — not a HARD STOP. The constitution's "Naming Conventions" section provides the authoritative old → new prefix mapping; the pre-context table provides the Feature-specific occurrences

**Greenfield/incremental projects**: No Naming Remapping section exists. Skip entirely.

## Demo-Ready Delivery (only if VI. Demo-Ready Delivery is in the constitution)

After `speckit-implement` completes, if the constitution includes "Demo-Ready Delivery":

1. **Clean up obsolete demo-only components from previous Features**:
   - Check `demos/` directory for demo scripts of **already completed** Features
   - In each completed Feature's demo script, check the **Demo Components** header comment
   - If any component has Category = "Demo-only" and Fate = "Remove after F0XX-[current-feature]", **remove that component** (delete the file/directory) and update the demo script's header comment
   - Report removed demo-only components to the user

2. **Determine the Feature's demo surface type** based on what was implemented:
   - Has UI components → demo script starts the server, opens/tests the route, and shuts down
   - Backend/API only → demo script invokes the API endpoints and displays results
   - Data/logic layer only → demo script exercises the core logic with sample data
   - Pipeline/engine → demo script runs the pipeline with sample input and shows output

3. **Categorize each demo component** as either:
   - **Demo-only**: Mock data, temporary UI scaffolding. Mark with `// @demo-only` comment. Will be removed when the real Feature replaces it
   - **Promotable**: Minimal but real implementation that future Features will extend. Place in the regular source tree. Mark with `// @demo-scaffold — will be extended by F00N-[feature]` comment. Not deleted, but evolved

4. **Create executable demo script** at `demos/F00N-name.sh` (or `.ts`/`.py`/etc.):
   > Anti-patterns, full bash template, key requirements, and Feature-type-specific demo approaches are defined in [demo-standard.md](../demo-standard.md).
   > **Demo artifacts**: During `implement`, create the surfaces users will interact with (demo routes, demo pages, demo data fixtures, demo CLI wrappers, etc.) — these are what make the demo real, not just test stubs.
   >
   > **quickstart.md reference**: If `specs/{NNN-feature}/quickstart.md` exists (generated by `speckit-plan`), the demo script MUST follow its run instructions (startup commands, required environment, health check endpoints, etc.). The quickstart.md is the authoritative source for how to launch and verify the Feature.

5. **Update `demos/README.md`** — see [demo-standard.md § 8](../demo-standard.md) for format.

## Runtime Verification + Fix Loop

> **Purpose**: Resolve G4 — implement only generates code without running it. Per-task runtime verification prevents bug explosion at verify time.
> **App Session Management**: Start app at first task verification → subsequent tasks use Navigate for screen switching only → shut down after Review complete. See [MCP-GUIDE.md](../../../../MCP-GUIDE.md) for MCP Capability Map.

### Per-Task Runtime Verification

After each `speckit-implement` task completes (before starting the next task):

**Step 1 — Build Gate**:
- Run build command (`npm run build`, `cargo build`, etc.)
- **Build failure**: Enter Auto-Fix Loop (see below)
- **Build success**: Proceed to Step 2

**Step 2 — Runtime Check** (when MCP available):
1. If app is not yet running: start app (dev server / Electron / etc.)
2. Navigate to the screen related to the completed task
3. Snapshot to confirm normal rendering (not an error screen)
4. Check Console logs for JS errors (TypeError, ReferenceError, etc.)
5. **Success**: Proceed to next task (keep app running)
6. **Failure**: Enter Auto-Fix Loop

**Without MCP**: Replace Step 2 with build success confirmation only (Level 1 verification)

### Post-Implement Full Verification

After all tasks complete, before Review:

1. Start app (or keep running if already started)
2. Identify verifiable items from the Feature's SC-### list
3. Navigate to each SC-related screen → Snapshot → confirm normal rendering
4. Scan Console logs for all errors
5. **If failures found**: Enter Auto-Fix Loop
6. **All pass**: Display "Runtime Verified: ✅" in Review Display

### Auto-Fix Loop

Attempt automatic fix when runtime verification fails:

```
FIX_LOOP (max 3 attempts):
  1. Analyze stdout/stderr error messages
  2. Classify error type:
     - Import/Module: path errors, unregistered modules
     - Config: missing/invalid config files
     - Type: type mismatches, unimplemented interfaces
     - API: endpoint mismatches, schema errors
     - Runtime: null reference, undefined access
  3. Modify related source files
  4. Rebuild → re-verify
  5. Same error repeats: break loop → error report
```

**Loop break conditions**:
- Same error after 3 attempts → break
- New error resets counter (different issue)
- Error from external dependency (DB, API server, etc.) → break immediately, show reason

**Break report**:
```
⚠️ Runtime Verification — Auto-Fix failed:
  Error: [error message]
  Attempts: [N]
  Classification: [error type]
  Files modified: [list of attempted fix files]

You can fix manually or proceed to Review with this state.
```

**Use AskUserQuestion** with options:
- "Fix manually and re-verify"
- "Proceed to Review as-is" — Review includes ⚠️ marker
**If response is empty → re-ask** (per MANDATORY RULE 1)

## Injected Content

- Automatically executes `speckit-implement` based on tasks.md
- Static resource copy instructions from pre-context.md (if applicable)
- Naming remapping context from pre-context.md (if applicable) — displays old → new identifier mapping before execution
- If Demo-Ready Delivery is active: demo surface implementation + executable demo script creation (`demos/F00N-name.sh`)
- **Runtime verification**: Per-task build gate + runtime check (MCP available 시), post-implement full SC verification

## Checkpoint

Only a simplified checkpoint is displayed:
```
📋 Implement execution: [FID] - [Feature Name]
speckit-implement will be executed based on tasks.md. Do you want to proceed?
```

## Review Display Content

After `speckit-implement` completes:

**Files to read**:
1. `specs/{NNN-feature}/tasks.md` — Re-read to cross-reference which tasks were completed
2. All source files created/modified during implementation — use `git diff --name-only` on the Feature branch to identify them
3. Test output — capture from the test run during implementation
4. Build output — capture from the build step during implementation
5. `demos/{FID}-{name}.sh` (or `.ts`/`.py`/etc.) — If Demo-Ready Delivery is active, read the demo script

**Display format**:
```
📋 Review: Implementation for [FID] - [Feature Name]
📄 Branch: {NNN}-{short-name}

── Files Created/Modified ───────────────────────
[List of files from git diff --name-only:
 - New files: path — purpose
 - Modified files: path — what changed]

── Test Results ─────────────────────────────────
[Test pass/fail summary: X/Y tests passed]

── Build Status ─────────────────────────────────
[Build success/failure]

── Runtime Verification ────────────────────────
[Per-task verification summary:
 Task 1: ✅ Build + Runtime OK
 Task 2: ✅ Build + Runtime OK
 Task 3: ⚠️ Build OK, Runtime Fix (1 attempt)
 Post-implement: ✅ [N]/[M] SCs verified]
[If MCP not available: "Build-only verification (Level 1)"]

── Demo Status (if Demo-Ready Delivery active) ──
[Demo surface created: yes/no
 demos/F00N-name.sh: created/updated]

── Files You Can Edit ─────────────────────────
  📄 All source files listed above under "Files Created/Modified"
  📄 specs/{NNN-feature}/tasks.md  (to adjust remaining tasks)
  📄 demos/{FID}-{name}.sh  (if Demo-Ready Delivery active)
You can open and edit any of these files directly, then select
"I've finished editing" to continue.
──────────────────────────────────────────────────
```

**HARD STOP** (ReviewApproval): Options: "Approve", "Request modifications", "I've finished editing"

---

## Bug Prevention Checks (B-3)

> Bug prevention rules applied during code writing in the implement stage.
> Reminded at Checkpoint before speckit-implement execution, compliance checked during Review.

### IPC Boundary Safety (Electron/Tauri)

- **IPC Message Validity**: Prevent argument type/count mismatches in main↔renderer IPC calls
- **Context Isolation**: Confirm renderer cannot directly access Node.js APIs
- **IPC Error Handling**: Recovery strategy for IPC call failures (process crash, timeout)

### Platform CSS Constraints

- **Electron/Tauri Webview CSS Constraints**: Desktop-specific CSS considerations (`-webkit-app-region: drag`, frameless window layouts)
- **Cross-browser Compatibility**: CSS Grid/Flexbox fallbacks, vendor prefix requirements

### Cross-Feature Integration

- **Import Path Validation**: Verify correct paths when importing modules from other Features
- **Interface Contract Compliance**: Confirm actual implementation of shared entities/APIs matches entity-registry/api-registry contracts
- **Module Import Graph**: Prevent circular imports, check tree-shaking impact when using barrel exports

### Data Persistence Safety

- **Write-Through Consistency**: Synchronization strategy between in-memory state changes and persistence layer (DB, localStorage, file)
- **Optimistic Update Rollback**: Mechanism to restore previous state when optimistic updates fail

---

## Post-Step Update Rules

1. Subsequent Feature impact analysis:
   - Find the list of Features that depend on the current Feature from the Dependency Graph in `roadmap.md`
   - Inspect the `pre-context.md` of each subsequent Feature
   - If the entity/API drafts in the "For /speckit.plan" section differ from the actual implementation, update them
   - Report the changes to the user

> **Note**: Feature Progress Status remains `in_progress` after implement. Status transitions to `completed` only after all steps including merge are ✅ (per state-schema.md).
