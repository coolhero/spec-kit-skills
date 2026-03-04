# Domain Profile Schema

> Every domain profile MUST define all sections below. The agent reads the active profile during execution and adapts each Phase accordingly.

---

## Required Sections

### 1. Detection Signals
File/directory patterns that indicate a project belongs to this domain. Used for auto-detection if `--domain` is not specified.

### 2. Project Type Classification
Project type categories for Phase 1-3 classification. Each type has a name and description.

### 3. Analysis Axes
Phase 2 Deep Analysis extraction targets. Each axis defines:
- **Name**: Short identifier
- **Description**: What this axis captures
- **Extraction Targets**: File patterns, code patterns, and frameworks to scan

### 4. Registries
Registry files to generate during Phase 4. Each registry defines:
- **File name**: Output filename (e.g., `entity-registry.md`)
- **Purpose**: What cross-Feature information it tracks
- **Template**: Reference to template file in `templates/`

### 5. Feature Boundary Heuristics
Criteria for identifying Feature boundaries in Phase 3-1. Domain-specific signals that indicate where one Feature ends and another begins.

### 6. Tier Classification Axes
Importance analysis criteria for Phase 3-3 (core scope only). Each axis evaluates Features from a different perspective to determine Tier placement.

### 7. Demo Pattern (used by smart-sdd)
How a completed Feature should be demonstrated. Defines:
- **Type**: Execution model (server-based, script-based, notebook-based, etc.)
- **Default mode**: Interactive behavior
- **CI mode**: Automated health check behavior
- **Script location**: Demo script naming convention

### 8. Parity Dimensions (used by smart-sdd)
Dimensions for source parity comparison. Each dimension defines what structural and logic elements to compare between original and rebuilt systems.

### 9. Verify Steps (used by smart-sdd)
Verification steps to execute after Feature implementation. Each step defines:
- **Name**: Step identifier
- **Required**: Whether failure blocks the pipeline
- **Description**: What to check
