# Context Injection: Implement

> Per-command injection rules for `/smart-sdd implement [FID]`.
> For shared patterns (HARD STOP, Checkpoint, --auto, Missing/Sparse Content Handling), see [context-injection-rules.md](../context-injection-rules.md).

---

## Read Targets

| File | Section | Filtering |
|------|---------|-----------|
| `SPEC_PATH/[NNN-feature]/tasks.md` | Entire file | Current Feature |
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

4. **Create executable demo script** at `demos/F00N-name.sh` (or `.ts`/`.py`/etc. matching the project's language):

   > **⚠️ ANTI-PATTERN — DO NOT DO THIS:**
   > ```markdown
   > # F001 Auth Demo          ← WRONG: This is a markdown document
   > ## Demo Steps              ← WRONG: Manual instructions for a human to follow
   > 1. Open the browser       ← WRONG: Not executable by a machine
   > 2. Click "Login"          ← WRONG: Requires human interaction
   > ```
   > A markdown file with instructions is **documentation, NOT a demo script**.
   >
   > ```bash
   > #!/usr/bin/env bash
   > TOTAL=0; PASSED=0
   > TOTAL=$((TOTAL+1)); curl -s ... | grep -q "OK" && PASSED=$((PASSED+1))
   > echo "${PASSED}/${TOTAL} passed"    ← WRONG: This is a test suite, not a demo
   > ```
   > A script that only runs assertions and exits is a **test suite**, not a demo.
   > Tests are for `verify` Phase 1. Demos are for showing the **real, working Feature**.

   **CORRECT — executable demo that launches the Feature for the user to experience:**
   ```bash
   #!/usr/bin/env bash
   # Demo: [Feature Name]
   #
   # Purpose: Launches [Feature Name] so the user can experience it firsthand.
   #          Sets up the environment, starts the service, and provides
   #          concrete examples of what to try.
   #
   # Usage:
   #   ./demos/F00N-name.sh        # Launch the demo (interactive, default)
   #   ./demos/F00N-name.sh --ci   # CI mode — quick health-check and exit
   #
   # Coverage (maps to spec.md):
   #   ✅ FR-001 [Requirement name]   → Demonstrated: [how the user can see this]
   #   ✅ FR-002 [Requirement name]   → Demonstrated: [how the user can see this]
   #   ⬜ FR-003 [Requirement name]   → Not demoed: [reason, e.g., requires external service]
   #
   # Demo Components:
   #   [component name] | [file path] | Demo-only | Remove after F0XX-[feature]
   #   [component name] | [file path] | Promotable | Extended by F0XX-[feature]
   #
   # Prerequisites: [What must be running/installed]
   set -euo pipefail

   CI_MODE=false
   [ "${1:-}" = "--ci" ] && CI_MODE=true

   # --- Cleanup handler ---
   cleanup() {
     echo ""
     echo "Shutting down demo..."
     [Commands to clean up — e.g., stop server, remove temp data]
   }
   trap cleanup EXIT

   echo "══════════════════════════════════════════════════"
   echo "  Demo: [Feature Name]"
   echo "══════════════════════════════════════════════════"
   echo ""

   # ─── Setup ──────────────────────────────────────────────────
   echo "Setting up..."
   [Commands to prepare: seed DB, build assets, etc.]

   # ─── Start the Feature ──────────────────────────────────────
   echo "Starting [Feature Name]..."
   [Commands to start the service — e.g., start server in background]

   # ─── Health Check ───────────────────────────────────────────
   echo ""
   echo "Running health check..."
   [Quick checks to verify the demo environment is alive]
   # e.g., curl -sf http://localhost:3000/health || { echo "❌ Health check failed"; exit 1; }
   echo "  ✅ [Service] is running on [port/URL]"

   # ─── CI Mode: exit after health check ───────────────────────
   if [ "$CI_MODE" = true ]; then
     echo ""
     echo "=== CI health check passed ==="
     exit 0
   fi

   # ─── Interactive: Show the user what to try ─────────────────
   echo ""
   echo "══════════════════════════════════════════════════"
   echo "  🎯 [Feature Name] is live! Try it:"
   echo "══════════════════════════════════════════════════"
   echo ""
   [Print concrete things the user can DO right now:]
   echo "  👉 Open in browser: http://localhost:3000/[page]"
   echo ""
   echo "  👉 Try the API:"
   echo "     curl http://localhost:3000/api/[endpoint]"
   echo ""
   echo "  👉 [Another thing to try]:"
   echo "     [Concrete command or URL]"
   echo ""
   echo "──────────────────────────────────────────────────"
   echo "  Press Ctrl+C to stop the demo."
   echo "──────────────────────────────────────────────────"
   echo ""

   # Keep the service running until the user stops it
   wait || true
   ```

   **Key requirements:**
   - **The demo shows the real, working Feature** — not just assertions. Running the script launches the Feature so the user can experience it firsthand
   - The script must be executable (`chmod +x`) and self-contained
   - **Default = interactive**: The script launches the Feature and keeps it running. The user interacts with it via browser, curl, CLI, etc.
   - **`--ci` flag**: For `verify` Phase 3 automation — runs setup + health check, then exits. No user interaction needed
   - **Coverage header REQUIRED**: Map each FR-###/SC-### from spec.md to what the user can see/try in the demo. Use ⬜ for items that can't be demoed
   - **Concrete "Try it" instructions**: Print at least 2-3 things the user can actually DO — real URLs, real curl commands, real CLI invocations. NOT prose descriptions
   - **What the demo IMPLEMENTS** (by Feature type):
     - Has UI → Demo starts the server with demo data, opens the real UI. User sees and interacts with actual pages
     - Backend/API → Demo starts the server with demo data, prints curl commands for real endpoints
     - CLI/Library → Demo provides a pre-configured sandbox and sample commands to run
     - Data layer / Store → Demo provides a seeded database with CRUD command examples
     - Pipeline / Engine → Demo runs the pipeline with sample input and shows real output, then lets the user try with their own input
   - **Demo artifacts**: During `implement`, create the surfaces users will interact with (demo routes, demo pages, demo data fixtures, demo CLI wrappers, etc.) — these are what make the demo real, not just test stubs
   - **Demo code separation**: Same as before — `// @demo-only` and `// @demo-scaffold` markers

5. **Update `demos/README.md`** (Demo Hub — index of all Feature demos):
   - Create if it doesn't exist (first Feature with demo)
   - Add the Feature with its demo command and a brief description of what the user will experience:
     - `./demos/F00N-name.sh` — launches [brief description of what the user can try]

## Injected Content

- Automatically executes `speckit-implement` based on tasks.md
- Static resource copy instructions from pre-context.md (if applicable)
- Naming remapping context from pre-context.md (if applicable) — displays old → new identifier mapping before execution
- If Demo-Ready Delivery is active: demo surface implementation + executable demo script creation (`demos/F00N-name.sh`)

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

## Post-Step Update Rules

1. Change the Status of the Feature in `BASE_PATH/roadmap.md` to `completed`
2. Subsequent Feature impact analysis:
   - Find the list of Features that depend on the current Feature from the Dependency Graph in `roadmap.md`
   - Inspect the `pre-context.md` of each subsequent Feature
   - If the entity/API drafts in the "For /speckit.plan" section differ from the actual implementation, update them
   - Report the changes to the user
