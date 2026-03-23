# Customize — Org Convention, Project Custom, and Profiles

> Reference: Read after `/domain-extend customize` is invoked.

## Purpose

Create or edit organization-level conventions, project-specific customizations, and reusable profiles that influence how the SDD pipeline generates and validates artifacts.

---

## Arguments

```
/domain-extend customize <scope> [name] [flags]

  <scope>    org | project | profile
  [name]     Required for profile scope (profile name in kebab-case)
```

---

## Scope 1: Org Convention (`customize org`)

### Step O1 — Check Existing

1. Read `sdd-state.md` for `**Org Convention**` field
2. If path exists: read the file, display current sections summary
3. If no path or file missing: proceed to guided creation

**If existing convention found:**

```
📋 Current Org Convention: {path}

  Sections:
    ## Coding Standards — {N} rules
    ## API Conventions — {N} rules
    ## Security Requirements — {N} rules
    ## Testing Standards — {N} rules
```

AskUserQuestion:
- **"Edit existing"** → show full content, accept section-level edits
- **"Replace entirely"** → proceed to guided creation (overwrites)
- **"Done"** → exit

**If response is empty → re-ask** (per MANDATORY RULE 1)

### Step O2 — Guided Creation (HARD STOP per question)

Ask questions via AskUserQuestion to build org-convention.md:

**Q1 — Non-negotiable coding rules** (→ S1/S7 extensions):
```
What coding rules does your organization enforce universally?
(e.g., "No any types in TypeScript", "All functions must have JSDoc",
 "Maximum cyclomatic complexity: 10")

Enter rules, one per line. Type "skip" if none.
```
**If response is empty → re-ask** (per MANDATORY RULE 1)

**Q2 — API standards** (→ Interface extensions):
```
What API conventions does your organization follow?
(e.g., "REST with JSON:API format", "gRPC for internal services",
 "All endpoints require OpenAPI spec", "Pagination via cursor, not offset")

Enter standards, one per line. Type "skip" if none.
```
**If response is empty → re-ask** (per MANDATORY RULE 1)

**Q3 — Security requirements** (→ Concern extensions):
```
What security requirements are mandatory?
(e.g., "All user input must be sanitized", "Secrets via env vars only",
 "OWASP Top 10 compliance", "No credentials in source code")

Enter requirements, one per line. Type "skip" if none.
```
**If response is empty → re-ask** (per MANDATORY RULE 1)

**Q4 — Testing minimums** (→ Foundation F2):
```
What are your organization's testing standards?
(e.g., "80% line coverage minimum", "Integration tests for all API endpoints",
 "E2E tests for critical user flows", "No mocking of database in integration tests")

Enter standards, one per line. Type "skip" if none.
```
**If response is empty → re-ask** (per MANDATORY RULE 1)

### Step O3 — Generate + Review (HARD STOP)

Generate `org-convention.md` from answers:

```markdown
# Organization Convention

> Generated: {timestamp}
> Organization: {org name or "Custom"}

## Coding Standards
{rules from Q1}

## API Conventions
{rules from Q2}

## Security Requirements
{rules from Q3}

## Testing Standards
{rules from Q4}
```

Display preview and ask:

```
📄 Generated: org-convention.md

📁 Manual alternative:
  Create org-convention.md manually using the template above.
  Place it anywhere in your project and set the path in sdd-state.md.
```

AskUserQuestion:
- **"Approve and save"** → write file, update sdd-state.md
- **"Edit"** → accept corrections, regenerate
- **"Cancel"** → abort

**If response is empty → re-ask** (per MANDATORY RULE 1)

### Step O4 — Install

1. Write `org-convention.md` to project root or `specs/` directory
2. Update `sdd-state.md` `**Org Convention**` field with the file path
3. Display:
   ```
   ✅ Org convention installed: {path}
     sdd-state.md updated.
     Pipeline will inject these rules during specify/plan/implement.
   ```

---

## Scope 2: Project Custom (`customize project`)

### Step P1 — Check Existing

1. Check for `domain-custom.md` in project (path from `sdd-state.md` or default locations)
2. If exists: display current, offer edit
3. If new: proceed to guided creation

### Step P2 — Guided Creation (HARD STOP per question)

Similar to org convention but focused on project-specific overrides:

**Q1 — Project-specific coding rules:**
```
What rules apply ONLY to this project (not org-wide)?
(e.g., "Use Zustand for state management", "All components in /features/ directory",
 "No direct database access from route handlers")
```
**If response is empty → re-ask** (per MANDATORY RULE 1)

**Q2 — Technology constraints:**
```
What technology choices are locked for this project?
(e.g., "PostgreSQL only — no other databases", "Must support Node 18+",
 "Deploy to AWS Lambda — max 15min execution")
```
**If response is empty → re-ask** (per MANDATORY RULE 1)

**Q3 — Override org rules (if org-convention exists):**
```
Any org-level rules that this project explicitly overrides?
(e.g., "Coverage minimum is 60% instead of 80% for this prototype",
 "REST instead of gRPC for this public-facing API")

Type "none" if no overrides.
```
**If response is empty → re-ask** (per MANDATORY RULE 1)

### Step P3 — Generate + Review (HARD STOP)

Generate `domain-custom.md`, display preview, ask for approval.

```
📁 Manual alternative:
  Create domain-custom.md manually.
  Schema reference: state-schema.md § Domain Custom
```

AskUserQuestion:
- **"Approve and save"** → write file
- **"Edit"** → accept corrections
- **"Cancel"** → abort

**If response is empty → re-ask** (per MANDATORY RULE 1)

### Step P4 — Install

1. Write `domain-custom.md`
2. Update `sdd-state.md` if needed
3. Display confirmation

---

## Scope 3: Profile (`customize profile "name"`)

### Step PR1 — Define Axis Combinations

AskUserQuestion:
```
Define the profile "{name}" — which modules should it activate?

Axes (enter module names or "any" to leave flexible):
  1. Interface: [e.g., gui, http-api, cli]
  2. Concerns: [e.g., auth, async-state, i18n]
  3. Archetype: [e.g., ai-assistant, sdk-framework]
  4. Foundation: [e.g., nextjs, express, django]
  5. Scenario: [e.g., greenfield, brownfield-incremental]

Scale modifier:
  - Project Maturity: [prototype | mvp | production]
  - Team Context: [solo | small-team | large-team]
```
**If response is empty → re-ask** (per MANDATORY RULE 1)

### Step PR2 — Preview Module Activation

Based on the axis selections, show what modules would be activated:

```
📋 Profile "{name}" would activate:

  Interfaces: gui → {N} sections loaded
  Concerns: auth, async-state → {N} sections loaded
  Archetype: ai-assistant → {N} patterns loaded
  Foundation: nextjs → {N} best practices loaded
  Cross-concern rules: auth+async-state → {N} rules

  Total injection weight: ~{N} sections across pipeline stages
```

AskUserQuestion:
- **"Save profile"** → write to `smart-sdd/domains/profiles/{name}.md`
- **"Adjust"** → go back to Step PR1
- **"Cancel"** → abort

**If response is empty → re-ask** (per MANDATORY RULE 1)

### Step PR3 — Install

1. Write profile file to `smart-sdd/domains/profiles/{name}.md`
2. Display:
   ```
   ✅ Profile "{name}" saved.
     Path: smart-sdd/domains/profiles/{name}.md
     Usage: Set Domain Profile to "{name}" in sdd-state.md
            or pass --profile {name} during init/add.
   ```
