# Domain Profile Schema

> Every domain profile MUST define sections 1-6. Sections 7-9 are optional (defined in smart-sdd domain profiles). The agent reads the active profile during execution and adapts each Phase accordingly.

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

### 7. Demo Pattern — Optional (defined in smart-sdd domain profile if applicable)
How a completed Feature should be demonstrated.

### 8. Parity Dimensions — Optional (defined in smart-sdd domain profile if applicable)
Dimensions for source parity comparison.

### 9. Verify Steps — Optional (defined in smart-sdd domain profile if applicable)
Verification steps to execute after Feature implementation.
