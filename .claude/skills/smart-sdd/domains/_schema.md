# Domain Profile Schema (smart-sdd)

> Every domain profile used by smart-sdd MUST define the sections below.
> For reverse-spec-specific sections (Detection Signals, Analysis Axes, etc.), see `../reverse-spec/domains/_schema.md`.

---

## Required Sections

### 1. Demo Pattern

Defines how a completed Feature should be demonstrated during the verify step.

| Field | Description |
|-------|-------------|
| **Type** | Execution model: `server-based`, `script-based`, `notebook-based`, etc. |
| **Default mode** | Interactive behavior when user runs the demo |
| **CI mode** | Automated health check behavior (for `--ci` flag) |
| **Script location** | Demo script naming convention (e.g., `demos/F00N-name.sh`) |
| **"Try it" instructions** | What to show the user (URLs, commands, output examples) |

### 2. Parity Dimensions

Dimensions for source parity comparison in the `parity` command.

| Field | Description |
|-------|-------------|
| **Structural dimensions** | What structural elements to compare (endpoints, entities, schemas, etc.) |
| **Logic dimensions** | What behavioral/logic elements to compare (rules, transitions, etc.) |

### 3. Verify Steps

Verification steps to execute during the `verify` command.

| Field | Description |
|-------|-------------|
| **Step name** | Identifier (e.g., `test`, `build`, `lint`) |
| **Required** | Whether failure blocks the pipeline (`BLOCKING` or `optional`) |
| **Detection** | How to find/run the relevant tool |
| **Description** | What this step checks |

### 4. Adoption-Specific Behavior

Behavior differences when wrapping existing code with SDD docs (adoption mode).

| Field | Description |
|-------|-------------|
| **Verify treatment** | How test/build/lint failures are treated in adoption (non-blocking vs blocking) |
| **Demo pattern** | How to demo existing code vs newly built code |
| **Injection framing** | How spec-kit command prompts differ: "extract what exists" vs "define what to build" |
| **Feature status** | Post-adoption status value and its implications for incremental mode |

### 5. Feature Elaboration Probes (optional)

Domain-specific questions asked during the `add` command's consultation phase to elicit Feature-specific technical details.

| Field | Description |
|-------|-------------|
| **Probe category** | What aspect is being probed (e.g., UI patterns, data flow, state management) |
| **Questions** | Domain-specific elaboration questions for the `add` Step 2 consultation |
| **When to ask** | Conditions or triggers for each probe (e.g., "if Feature has UI components") |

### 6. UI Testing Integration (optional)

Guidance for automated UI verification during verify Phase 3.

| Field | Description |
|-------|-------------|
| **MCP tools mapping** | Which MCP tools map to which verification actions (e.g., `browser_click` → SC interaction) |
| **SC verification flow** | How to translate Scenario Coverage items into automated test steps |
| **Platform constraints** | Platform-specific limitations or considerations (e.g., WebView CSS differences) |
