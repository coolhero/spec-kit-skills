# Validate — Module Format and Consistency Check

> Reference: Read after `/domain-extend validate` is invoked.

## Purpose

Verify that domain modules follow the correct format, sections are properly numbered, cross-references are valid, and no duplicates exist. Catches structural problems before they cause pipeline failures.

---

## Arguments

```
/domain-extend validate [flags]

  --full       Validate ALL modules (not just custom ones), check content non-empty
  --fix        Auto-fix simple formatting issues (missing section numbers, whitespace)
  --module <n> Validate a single module by name
```

---

## Validation Checks

### Step 1 — Section Numbering

Verify each module has correct section prefixes for its type:

| Module Type | Expected Sections | Prefix |
|-------------|-------------------|--------|
| Concern | S0 (detection), S1 (structure), S3 (verification), S7 (failures), ... | `S0`-`S9` |
| Interface | S0 (detection), S1 (structure), S3 (verification), S7 (failures), ... | `S0`-`S9` |
| Archetype | A0 (detection), A1 (patterns), A2 (components), A3 (evolution), ... | `A0`-`A5` |
| Foundation | F0 (detection), F2 (best practices), F7 (anti-patterns), F8 (style), ... | `F0`-`F9` |

For each module file:
1. Extract all section headers matching `## S\d`, `## A\d`, `## F\d`
2. Verify prefix matches module type
3. Verify no gaps in required sections (S0, S1, S7 are mandatory for concerns)
4. Report missing or misnumbered sections

### Step 2 — ID Prefix Uniqueness

1. Collect all module names from `_taxonomy.md` entries
2. Verify no two modules share the same name across different types
3. Check that module filenames match their taxonomy entries

### Step 3 — 3-File Consistency

For concerns, interfaces, and archetypes that require 3 files:

1. Check `shared/domains/{type}s/{name}.md` exists
2. Check `reverse-spec/domains/{type}s/{name}.md` exists
3. Check `smart-sdd/domains/{type}s/{name}.md` exists
4. Verify S0/A0 keywords are consistent across all 3 files
5. Report any missing files:
   ```
   ⚠️ concern/signaling-protocol: missing reverse-spec file
     Expected: reverse-spec/domains/concerns/signaling-protocol.md
   ```

### Step 4 — _taxonomy.md Completeness

1. Scan all module directories for `.md` files (excluding `_taxonomy.md`, `_schema.md`, `_resolver.md`)
2. Compare against `_taxonomy.md` entries
3. Report:
   - Modules in filesystem but not in taxonomy (unlisted)
   - Modules in taxonomy but not in filesystem (dangling references)

### Step 5 — Cross-Concern Rule Validity

1. Read `_resolver.md` Step 3.5 cross-concern rules table
2. For each rule, verify both referenced modules exist in `_taxonomy.md`
3. Report invalid references:
   ```
   ⚠️ Cross-concern rule: "auth + nonexistent-module" — module "nonexistent-module" not found
   ```

### Step 6 — S0 Keyword Uniqueness

1. Extract all S0/A0/F0 keywords from every module
2. Build a keyword-to-module map
3. Report duplicates:
   ```
   ⚠️ S0 keyword "realtime" appears in both:
     - concerns/realtime.md
     - concerns/webrtc.md
     Consider: Is this intended overlap? If not, differentiate keywords.
   ```

### Step 7 — Org Convention Format Check

If `org-convention.md` exists (path from `sdd-state.md`):
1. Verify it has expected section headers (`## Coding Standards`, etc.)
2. Check sections are non-empty
3. Verify no raw template placeholders remain (`{...}`, `TODO`, `FIXME`)

---

## `--full` Extended Checks

When `--full` is specified, additionally:

1. **Content non-empty**: Every declared section must have at least one bullet point or paragraph
2. **File size check**: Warn if any module exceeds 300 lines (may need splitting)
3. **All modules validated**: Include built-in modules, not just custom ones
4. **Schema compliance**: Verify each section matches `_schema.md` expected structure
5. **Foundation version check**: Flag foundations referencing outdated framework versions

---

## `--fix` Auto-Fix

When `--fix` is specified:

1. **Section renumbering**: Fix `## Detection` → `## S0 — Detection`
2. **Whitespace normalization**: Trim trailing whitespace, ensure blank line before headers
3. **Taxonomy sync**: Add unlisted modules to `_taxonomy.md`
4. **NEVER auto-fix**: Content changes, keyword conflicts, missing files (these require user judgment)

Display all fixes before applying:
```
🔧 Auto-fix preview:
  1. concerns/message-queue.md: "## Detection" → "## S0 — Detection"
  2. _taxonomy.md: +1 entry (concerns/message-queue)

Apply fixes?
```
AskUserQuestion:
- **"Apply"** → write fixes
- **"Cancel"** → abort

**If response is empty → re-ask** (per MANDATORY RULE 1)

---

## Report Format

```
📊 Domain Module Validation Report

✅ Section numbering: {N} concerns OK, {N} interfaces OK, {N} archetypes OK
✅ ID prefixes: all unique
⚠️ 3-file consistency: {module} missing {skill} file
✅ _taxonomy.md: {N} modules listed, {N} found
✅ Cross-concern rules: all {N} rules reference existing modules
⚠️ S0 keywords: "{keyword}" appears in both {module1} and {module2}
✅ Org convention: valid format

{N} warnings, {N} errors
```

**Exit codes:**
- Errors (missing required sections, dangling taxonomy refs) → report as errors
- Warnings (keyword overlap, missing optional files) → report as warnings
- Informational (file sizes, suggestion for improvement) → report only with `--full`

```
📁 Manual alternative:
  Review _schema.md for expected section format.
  Check _taxonomy.md against filesystem with: ls domains/concerns/*.md
  Grep for keyword conflicts: search S0 sections across all module files.
```
