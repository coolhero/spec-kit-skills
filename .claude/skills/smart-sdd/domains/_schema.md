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
