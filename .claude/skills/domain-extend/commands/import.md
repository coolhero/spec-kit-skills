# Import — Convert Documents to Domain Modules

> Reference: Read after `/domain-extend import` is invoked.

## Purpose

Parse existing documents (ADRs, style guides, postmortems, coding standards, code-explore artifacts) and convert their content into structured domain modules.

---

## Arguments

```
/domain-extend import <source> [flags]

  <source>       File path or directory to import from

  --org          Output as org-convention.md instead of individual modules
  --type <t>     Force document type (adr | style-guide | postmortem | api-standard | explore)
  --target <m>   Force target module name (skip auto-mapping)
  --from-explore Import from code-explore synthesis artifacts
  --skill        Install to skill directory (~/.claude/skills/) instead of project directory.
                 Use only when contributing built-in modules to spec-kit-skills itself.
```

---

## Workflow

### Step 0 — Parse Source + Flags

1. Resolve `<source>` to absolute path
2. If directory: prepare for multi-file discovery (Step 1)
3. If single file: skip discovery, proceed to type detection (Step 2)
4. If `--from-explore`: verify `specs/explore/` exists, set source to synthesis artifacts
5. Validate flags: `--org` and `--target` are mutually exclusive

### Step 1 — Document Discovery

Scan the source directory for importable documents:

1. **File detection**: Find `.md`, `.txt`, `.adoc`, `.rst` files
2. **Grouping**: Identify related files (e.g., `ADR-001` through `ADR-009`)
3. **Size check**: Warn if any file exceeds 500 lines (may need splitting)
4. Display:
   ```
   📂 Document Discovery: {source}
     Files found: [N]
     Types detected: [ADR x5, Style Guide x1, Postmortem x2]
     Total size: ~[N] lines
   ```

### Step 2 — Document Type Detection

For each file, detect document type from content signals:

| Signal | Detected Type |
|--------|---------------|
| "Status: Accepted/Deprecated", "Context:", "Decision:" | ADR |
| "Style", "Convention", "Naming", linting rules | Style Guide |
| "Incident", "Root cause", "Timeline", "Mitigation" | Postmortem |
| "Endpoint", "Request/Response", "Status codes", OpenAPI | API Standard |
| "Orientation", "Trace", "Module Map", "Domain Profile" | Code-explore artifact |
| "Coding standard", "Review checklist", "Definition of Done" | Coding Standard |

If `--type` is specified, skip auto-detection and use the forced type.

If auto-detection is ambiguous, present HARD STOP:
```
⚠️ Cannot determine document type for: {filename}
  Signals: "Context:" (ADR?), "naming convention" (Style Guide?)
```
AskUserQuestion:
- **"ADR"** / **"Style Guide"** / **"Postmortem"** / **"API Standard"** / **"Skip this file"**

**If response is empty → re-ask** (per MANDATORY RULE 1)

### Step 3 — Content Extraction

Map document sections to module sections based on detected type:

**ADR → Foundation + Concern:**
- "Context" section → Foundation F2 (best practices context)
- "Decision" section → Concern S1 (structural rules)
- "Consequences" section → Concern S7 (failure modes / known limitations)
- "Status: Deprecated" → Foundation F7 (anti-patterns — what NOT to do)

**Style Guide → Concern + Foundation:**
- Naming conventions → Concern S7 (naming anti-patterns) + Foundation F8 (style)
- Code structure rules → Concern S1 (structural patterns)
- Linting rules → Foundation F2 (tool configuration)

**Postmortem → Concern:**
- "Root cause" → Concern S7 (failure modes with incident IDs)
- "What went wrong" → Concern S1 (rules to prevent recurrence)
- "Action items" → Concern S3 (verification approach)

**API Standard → Interface + Concern:**
- Endpoint patterns → Interface S1 (structural rules)
- Error handling standards → Concern S1 (error patterns)
- Authentication requirements → Concern S7 (auth failure modes)
- Versioning rules → Interface S7 (breaking change patterns)

**Code-explore artifacts → New modules from uncovered patterns:**
- `synthesis.md` insights → module candidates
- Trace patterns not covered by existing modules → new concern/interface candidates
- Detected Domain Profile gaps → foundation candidates

For each extraction, record:
```
{source_file} § {section_name} → {target_module} {section_id} ({action})

  action = EXTEND (add to existing) | NEW (create new module)
  location = project-local (specs/domains/) | skill-level (--skill flag)
```

### Step 4 — Module Mapping

For each extracted content block, decide: **extend existing module** vs **create new module**.

**Extend existing** if:
- Target module already exists in `_taxonomy.md`
- Content adds new rules/patterns without contradicting existing ones
- Action: merge into existing section (append, don't overwrite)

**Create new** if:
- No existing module covers this domain
- Content is substantial enough (3+ rules or patterns)
- Action: generate new module via `extend` flow (Step 4 of extend.md)

**If `--org` flag**: all content goes to `org-convention.md` sections instead.

### Step 5 — HARD STOP: Import Plan

> **This is a HARD STOP.** You MUST display the plan and wait for approval.

Display the Import Plan:

```
📋 Import Plan from {source} ({N} files detected)

  {file1} → Concern: {name} (EXTEND S1 +{N} rules, S7 +{N} patterns)
  {file2} → Foundation: {name} (EXTEND F2 +{N} items)
  {file3} → NEW Concern: {name} ({N} files to create)
  {file4} → Org Convention: {section} (NEW)
  {file5} → Foundation: {name} (EXTEND F7 +{N} principles)

  Summary:
    Modules to extend: [N]
    New modules to create: [N]
    Org convention additions: [N]
    Files skipped (no extractable content): [N]

📁 Manual alternative:
  Read each document → identify S1/S7/F2 content → edit module files directly
  Schema reference: _schema.md
  Taxonomy: _taxonomy.md
```

AskUserQuestion:
- **"Approve all"** → proceed with full import
- **"Select items"** → let user pick which imports to apply
- **"Edit mapping"** → user corrects target modules
- **"Cancel"** → abort import

**If response is empty → re-ask** (per MANDATORY RULE 1)

### Step 6 — Generate / Merge Files

**Output location**: Same as `extend` command — default is project-local (`specs/domains/`), use `--skill` for skill directory. See `extend.md` Step 4 for details.

**For EXTEND actions:**
1. Read existing module file (check project-local first, then skill-level)
2. Locate target section (e.g., S1, S7)
3. Append new content with source attribution:
   ```markdown
   <!-- Imported from: {source_file} ({date}) -->
   - {new rule or pattern}
   ```
4. Preserve existing content — never overwrite

**For NEW actions:**
1. Generate module files using `extend` workflow (Steps 4-6 of extend.md)
2. Pre-fill sections from extracted content
3. Mark sections that need user elaboration:
   ```markdown
   <!-- TODO: Elaborate — imported from {source}, needs domain expert review -->
   ```

**For `--org` actions:**
1. Read or create `org-convention.md`
2. Add/update relevant sections
3. Update `sdd-state.md` `**Org Convention**` field if creating new

### Step 7 — Post-Import Validation

1. Verify all target files are syntactically valid
2. Check section numbering consistency
3. Verify `_taxonomy.md` is updated for new modules
4. Check for S0 keyword conflicts introduced by import
5. Display:
   ```
   ✅ Import complete from {source}

     Extended: [N] modules ({list})
     Created: [N] new modules ({list})
     Org convention: [updated/created/unchanged]
     Skipped: [N] files (no extractable content)

     ⚠️ Items needing review:
       - {module} S7: imported failure mode needs severity classification
       - {module} S1: rule may overlap with existing rule in {other_module}
   ```

---

## `--from-explore` Special Flow

When `--from-explore` is specified:

1. Read `specs/explore/synthesis.md` (if exists) for Feature candidates and insights
2. Read `specs/explore/orientation.md` for Domain Profile and Module Map
3. Read `specs/explore/traces/*.md` for pattern discoveries
4. For each trace insight not covered by existing modules:
   - Propose as new module candidate
   - Extract S0 keywords from trace content
   - Extract S1 patterns from trace flow analysis
   - Extract S7 failure modes from trace annotations
5. Present candidates in Import Plan (Step 5) with trace references

---

## `--org` Special Flow

When `--org` is specified:

1. All extracted content targets `org-convention.md` instead of individual modules
2. Content is organized by org-convention sections:
   - Coding rules → `## Coding Standards`
   - API standards → `## API Conventions`
   - Security requirements → `## Security Requirements`
   - Testing minimums → `## Testing Standards`
3. If `org-convention.md` already exists: merge (append to existing sections)
4. Update `sdd-state.md` `**Org Convention**` path
