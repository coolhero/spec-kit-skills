# Import Mappings Reference

> Maps document types to module sections. Used by `/domain-extend import` to auto-detect
> document types and route content to the correct module sections.

---

## Document Type Detection

| Type | Detection Signals | Confidence |
|------|------------------|-----------|
| ADR | "Status:", "## Decision", "## Context", "## Consequences" | HIGH if 3+ signals |
| Style Guide | "## Naming", "## Formatting", lint/prettier config references | HIGH if 2+ signals |
| Postmortem | "## Root Cause", "## Timeline", "## Impact", "## Action Items" | HIGH if 3+ signals |
| API Standard | HTTP methods, status codes, "## Endpoints", "## Error Format" | HIGH if 2+ signals |
| Code-Explore | "## Architecture Overview", "## Feature Candidates", "## Accumulated Insights" | HIGH (exact match) |
| Compliance | "GDPR", "SOC2", "PCI-DSS", "## Requirements", "## Controls" | MEDIUM (keyword) |
| PR Checklist | "- [ ]", "## Must", "## Should", "## Review" | MEDIUM |
| Tech Radar | "Adopt", "Trial", "Assess", "Hold", quadrant terminology | MEDIUM |
| RFC | "## Motivation", "## Detailed Design", "## Alternatives", "## Unresolved" | MEDIUM if 3+ |
| Runbook | "## Playbook", "## Steps", "## Escalation", "## Recovery" | MEDIUM if 2+ |
| Generic | No specific signals detected | LOW -- ask user |

### Confidence Handling

- **HIGH**: Auto-detect and proceed. Show detected type in confirmation.
- **MEDIUM**: Show detected type + ask user to confirm before extraction.
- **LOW (Generic)**: Ask user what type of document this is and which module sections to target.

---

## Content Extraction Mappings

### ADR -> Module Sections

| ADR Section | Target Module Type | Target Section | Notes |
|------------|-------------------|---------------|-------|
| ## Context / ## Problem | Concern | S5 (Elaboration Probe context) | Converts problem statement into probe questions |
| ## Decision | Foundation F2 (if framework choice) | F2 Decision Item | Only if decision is about framework/toolchain |
| ## Decision | Concern S1 (if pattern rule) | S1 Required SC Pattern | Only if decision establishes a coding pattern |
| ## Consequences (positive) | Foundation F7 | Philosophy Principle | Generalizable positive outcomes become principles |
| ## Consequences (negative) | Concern S7 | Bug Prevention row | Negative outcomes become detection/prevention rules |
| ## Status | — | Metadata only | Used to filter (only "accepted"/"adopted" ADRs are imported) |

### Style Guide -> Module Sections

| Style Guide Section | Target Module Type | Target Section | Notes |
|--------------------|-------------------|---------------|-------|
| ## Naming conventions | Org Convention | Custom Rules | scope: all commands |
| ## Code formatting | Org Convention | Custom Rules | scope: implement, verify |
| ## API conventions | Org Convention | API Standards | Route naming, response shapes |
| ## Error handling | Concern (relevant) | S1 SC Pattern | Converts to SC requirement |
| ## Testing standards | Org Convention | Testing Requirements | Thresholds, required test types |
| ## Commit conventions | Org Convention | Custom Rules | scope: verify |

### Postmortem -> Module Sections

| Postmortem Section | Target Module Type | Target Section | Notes |
|-------------------|-------------------|---------------|-------|
| ## Root Cause | Concern (matching) | S7 Pattern name + Detection | Root cause becomes a named anti-pattern |
| ## What Went Wrong | Concern (matching) | S7 Detection column | Symptoms become detection signals |
| ## Fix / Action Items | Concern (matching) | S7 Prevention column | Fix becomes prevention rule |
| ## Lessons Learned | Foundation F7 | Philosophy Principle | Only if generalizable beyond single incident |
| ## Impact | — | Metadata only | Used to determine severity (higher impact = higher priority rule) |

### Code-Explore -> Module Sections

| Explore Artifact | Target Module Type | Target Section | Notes |
|-----------------|-------------------|---------------|-------|
| orientation.md § Detected libraries | Any matching module | S0 Keywords | Extend keyword list with discovered libraries |
| traces/*.md § Error branches | Concern (matching) | S7 Bug Prevention | Error patterns become prevention rules |
| traces/*.md § Normal flow | Concern (matching) | S1 SC Patterns | Normal flow patterns become SC requirements |
| synthesis.md § Accumulated Insights | Concern (matching) | S5 Probes | Insights become elaboration questions |
| synthesis.md § Unresolved | Any matching module | S5 Probes | Unresolved questions become probes |
| orientation.md § Architecture | Foundation F7 | Philosophy Principle | Detected principles become Foundation philosophy |

### RFC -> Module Sections

| RFC Section | Target Module Type | Target Section | Notes |
|------------|-------------------|---------------|-------|
| ## Motivation | Concern | S5 Probes | Converts "why" into elaboration questions |
| ## Detailed Design | Concern S1 / Foundation F2 | SC Pattern / Decision Item | Design decisions become rules |
| ## Alternatives | — | Metadata only | Recorded as rejected alternatives for context |
| ## Unresolved | Any matching | S5 Probes | Open questions become probes |

### Runbook -> Module Sections

| Runbook Section | Target Module Type | Target Section | Notes |
|----------------|-------------------|---------------|-------|
| ## Steps / ## Playbook | Concern | S7 Prevention | Operational steps become prevention rules |
| ## Escalation | — | Metadata only | Not mappable to module sections |
| ## Recovery | Concern | S7 Prevention | Recovery procedures inform prevention |

### Compliance -> Module Sections

| Compliance Section | Target Module Type | Target Section | Notes |
|-------------------|-------------------|---------------|-------|
| ## Requirements / ## Controls | Concern (compliance) | S1 SC Rules | Mandatory requirements become SC patterns |
| ## Audit Trail | Concern (audit-logging) | S1 SC Rules | Audit requirements become logging SCs |
| ## Data Retention / ## Privacy | Concern (compliance) | S5 Probes | Retention rules become elaboration questions |
| ## Encryption / ## Access Control | Concern (cryptography or auth) | S7 Prevention | Security requirements become prevention rules |

### PR Checklist -> Module Sections

| Checklist Section | Target Module Type | Target Section | Notes |
|------------------|-------------------|---------------|-------|
| ## Must / Required items | Concern | S1 SC Rules | Must-have items become mandatory SC patterns |
| ## Should / Recommended items | Concern | S5 Probes | Should-have items become elaboration questions |
| ## Never / Forbidden items | Concern | S7 Prevention | Forbidden patterns become bug prevention |
| ## Test / Coverage items | Foundation | F2 Decision Items | Test requirements become Foundation decisions |

### Tech Radar -> Module Sections

| Radar Section | Target Module Type | Target Section | Notes |
|--------------|-------------------|---------------|-------|
| Adopt entries | Foundation | F0 Detection (high confidence) | Adopted tech strengthens detection signals |
| Trial entries | Foundation | F0 Detection (low confidence) | Trial tech added as secondary signals |
| Hold entries | Concern | S7 Prevention | Held tech becomes "avoid using" prevention rule |
| Rationale / Tradeoffs | Foundation | F7 Philosophy | Technology rationale becomes framework principles |

---

## Merge vs Create Decision

### When import content maps to an EXISTING module:

**MERGE** — Add new rows to existing S1/S5/S7 tables.

Rules:
1. Deduplicate by semantic similarity (if an S7 pattern already covers the same bug, skip)
2. Append `[imported: {source-file}, {date}]` comment on each new row
3. Preserve existing row order; new rows go at the end of each table
4. If a new S1 pattern contradicts an existing one, flag as conflict and ask user

### When import content maps to NO existing module:

**CREATE** — Generate new module using templates from `templates/`.

Rules:
1. 3-file set for Concern/Interface/Archetype (shared + reverse-spec + smart-sdd)
2. Single file for Foundation (reverse-spec only)
3. Single file for Org Convention (project path)
4. After creation, update `_resolver.md` § Step 3.5 if the new module interacts with existing ones
5. Assign a unique ID prefix (check existing prefixes first)

### Ambiguous Mapping

When a piece of content could map to multiple module types or sections:
1. Prefer the more specific module (Concern over Foundation, S7 over S1)
2. If truly ambiguous, present both options to the user with rationale
3. Never silently pick one -- explicit routing prevents misplaced rules
