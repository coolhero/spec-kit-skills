# speckit-diff Workflow

Complete workflow for comparing spec-kit versions against the stored baseline.

---

## Phase 0: Source Acquisition

### 0-1. Resolve spec-kit source

**If `--local` provided**:
1. Verify `<path>/templates/commands/` directory exists
2. If not found → ERROR: "Not a valid spec-kit repo. Expected templates/commands/ directory at <path>"
3. Use this path as `SPECKIT_SOURCE`

**If no `--local`** (default — GitHub auto-clone):
1. Create temp directory: `/tmp/speckit-diff-$(date +%s)`
2. Clone spec-kit:
   ```bash
   git clone --depth 1 https://github.com/github/spec-kit.git /tmp/speckit-diff-{timestamp}
   ```
3. If clone fails → ERROR: "Failed to clone spec-kit from GitHub. Check network or use --local."
4. Extract commit info:
   ```bash
   git -C /tmp/speckit-diff-{timestamp} log -1 --format="%H %ai"
   ```
5. Use this path as `SPECKIT_SOURCE`
6. Register cleanup: remove temp dir after Phase 4 completes

### 0-2. Locate baseline

Read the baseline file at the **skill's own reference directory**:
```
{speckit-diff skill directory}/reference/integration-surface.md
```

The skill directory is wherever this SKILL.md resides (follows the symlink if applicable).

If baseline not found → ERROR: "integration-surface.md not found. The speckit-diff skill installation may be incomplete."

---

## Phase 1: Scanning

Scan the spec-kit source and extract structural signatures. Compare against the baseline.

### 1-1. Skill Files Scan

**Source path**: `{SPECKIT_SOURCE}/templates/commands/*.md`

For each `.md` file found:
1. Extract frontmatter: `name`, `description`, `metadata.source`
2. Extract all section headers (`##` and `###` level)
3. Extract script invocations: grep for `.sh` patterns and their flags
4. Extract output artifact references: grep for file paths like `spec.md`, `plan.md`, `tasks.md`, `contracts/`, `checklists/`

**Compare against**: baseline `## Known Skills` table
- `ADDED`: Skill name in source but not in baseline
- `REMOVED`: Skill name in baseline but not in source
- `MODIFIED`: Same name but different section headers OR different scripts invoked OR different output artifacts
- `RENAMED`: Same `metadata.source` but different `name`

### 1-2. Template Files Scan

**Source path**: `{SPECKIT_SOURCE}/templates/*.md` (excluding `commands/` subdirectory)

For each template:
1. Extract all section headers (`#`, `##`, `###`, `####`)
2. Extract format patterns: grep for `FR-`, `SC-`, `Given`, `When`, `Then`, `P1`/`P2`/`P3`, `CHK`, `T###`
3. Extract placeholder tokens: grep for `\[ALL_CAPS\]` patterns (e.g., `[FEATURE NAME]`, `[DATE]`)
4. Extract structural markers: `*(mandatory)*`, `[REMOVE IF UNUSED]`, `[NEEDS CLARIFICATION]`

**Compare against**: baseline `## Known Templates` sections
- `ADDED`: Template file in source but not in baseline
- `REMOVED`: Template file in baseline but not in source
- `SECTION_ADDED`: New section header not in baseline
- `SECTION_REMOVED`: Section header in baseline but not in source
- `PATTERN_CHANGED`: Format pattern differs (e.g., `FR-###` changed to `REQ-###`)
- `TOKEN_CHANGED`: Placeholder token added/removed/renamed

### 1-3. Script Files Scan

**Source path**: `{SPECKIT_SOURCE}/scripts/bash/*.sh`

For each script:
1. Extract CLI flags: grep for `--[a-z]` patterns
2. Extract JSON output fields: grep for field name patterns in echo/printf statements
3. Extract function names: grep for `^[a-z_]*()` patterns

**Compare against**: baseline `## Known Scripts` sections
- `ADDED`: Script file in source but not in baseline
- `REMOVED`: Script file in baseline but not in source
- `FLAG_ADDED`/`FLAG_REMOVED`: CLI flag changes
- `FIELD_ADDED`/`FIELD_REMOVED`: JSON output field changes
- `FUNCTION_ADDED`/`FUNCTION_REMOVED`: Function signature changes

### 1-4. CLI Scan

**Source path**: `{SPECKIT_SOURCE}/pyproject.toml` or main entry point

1. Extract available commands
2. Extract flags for `init` command

**Compare against**: baseline `## Known CLI`

### 1-5. Directory Structure Scan

1. Glob `{SPECKIT_SOURCE}/templates/` structure
2. Glob `{SPECKIT_SOURCE}/scripts/` structure
3. Check for new top-level directories

**Compare against**: baseline `## Known Directory Structure`

---

## Phase 2: Impact Mapping

For each change detected in Phase 1, map to the specific spec-kit-skills files that need updating.

### Impact Mapping Table

This is the core of the analysis. Each change type maps to specific files in spec-kit-skills:

```
SKILL CHANGES:
  Any skill added →
    .claude/skills/smart-sdd/SKILL.md                    (pipeline sequence, new step)
    .claude/skills/smart-sdd/reference/context-injection-rules.md  (new per-command section)
    .claude/skills/smart-sdd/reference/state-schema.md    (Feature Progress column if tracked)
    .claude/skills/reverse-spec/reference/speckit-compatibility.md (new mapping row)
    README.md + README.ko.md                              (workflow documentation)

  Any skill removed →
    .claude/skills/smart-sdd/SKILL.md                    (remove pipeline step)
    .claude/skills/smart-sdd/reference/context-injection-rules.md  (remove section)
    .claude/skills/reverse-spec/reference/speckit-compatibility.md (remove mapping)
    README.md + README.ko.md

  Any skill modified →
    .claude/skills/smart-sdd/reference/context-injection-rules.md  (update injection/review rules)
    Specific impact depends on what changed (see sub-rules below)

  speckit-specify modified →
    + .claude/skills/smart-sdd/SKILL.md        (create-new-feature.sh invocation)
    + .claude/skills/reverse-spec/templates/pre-context-template.md  (FR-###/SC-### draft format)

  speckit-plan modified →
    + .claude/skills/reverse-spec/templates/entity-registry-template.md  (data-model.md mapping)
    + .claude/skills/reverse-spec/templates/api-registry-template.md     (contracts/ mapping)

  speckit-constitution modified →
    + .claude/skills/reverse-spec/templates/constitution-seed-template.md (format alignment)

  speckit-implement modified →
    + .claude/skills/smart-sdd/reference/injection/implement.md (Implement injection/review rules)

  speckit-analyze modified →
    + .claude/skills/smart-sdd/reference/injection/analyze.md (Analyze injection/review rules)

  speckit-tasks modified →
    + .claude/skills/smart-sdd/reference/injection/tasks.md (Tasks injection/review rules)

  speckit-clarify modified →
    + .claude/skills/smart-sdd/reference/injection/specify.md (Clarify feeds back into specify)

  speckit-checklist modified →
    + .claude/skills/smart-sdd/reference/injection/verify.md (Checklist used in verify Phase 1)

TEMPLATE CHANGES:
  spec-template.md changed →
    .claude/skills/smart-sdd/reference/injection/specify.md (Specify Review)
    .claude/skills/reverse-spec/templates/pre-context-template.md
    .claude/skills/reverse-spec/reference/speckit-compatibility.md (Business Logic Map → spec.md)

  plan-template.md changed →
    .claude/skills/smart-sdd/reference/injection/plan.md (Plan Review)
    .claude/skills/reverse-spec/templates/entity-registry-template.md
    .claude/skills/reverse-spec/templates/api-registry-template.md
    .claude/skills/reverse-spec/reference/speckit-compatibility.md (Entity Registry → data-model.md)

  tasks-template.md changed →
    .claude/skills/smart-sdd/reference/injection/tasks.md (Tasks Review)

  constitution-template.md changed →
    .claude/skills/smart-sdd/reference/injection/constitution.md (Constitution Review)
    .claude/skills/reverse-spec/templates/constitution-seed-template.md

  checklist-template.md changed →
    .claude/skills/smart-sdd/reference/context-injection-rules.md (shared patterns)

  agent-file-template.md changed →
    (No direct impact — spec-kit-skills does not generate agent files)

SCRIPT CHANGES:
  create-new-feature.sh changed →
    .claude/skills/smart-sdd/SKILL.md (specify step, branch creation)

  check-prerequisites.sh changed →
    .claude/skills/smart-sdd/SKILL.md (prerequisite validation references)

  setup-plan.sh changed →
    .claude/skills/smart-sdd/SKILL.md (plan step setup)

  update-agent-context.sh changed →
    (No direct impact — spec-kit-skills does not invoke this script directly)

  common.sh changed →
    (No direct impact unless JSON output field names change)

  New script added →
    .claude/skills/smart-sdd/SKILL.md (if invoked by any skill in the pipeline)

CLI CHANGES:
  init flags changed →
    .claude/skills/smart-sdd/SKILL.md (init command in Phase 0)

  New commands added →
    .claude/skills/smart-sdd/SKILL.md (potential pipeline integration)

DIRECTORY CHANGES:
  New spec-kit directories →
    .claude/skills/smart-sdd/SKILL.md (path assumptions)
    README.md + README.ko.md (artifact structure documentation)
```

### Priority Assignment

For each mapped change, assign priority:

- **P1 (Breaking)**: Skills removed, scripts removed, JSON output fields removed/renamed, artifact format structure changed (section headers renamed/removed), CLI init flags removed
- **P2 (Compatibility)**: Skills modified (section changes), new template sections, script flags changed, JSON output fields added, new scripts invoked by existing skills
- **P3 (Enhancement)**: New skills added, new templates, new directory conventions, agent-file-template changes, optional script function additions

---

## Phase 3: Report Generation

Generate the compatibility report in the following format.

### Report Structure

```markdown
# spec-kit Compatibility Report

## {VERDICT_EMOJI} {VERDICT} — {VERDICT_DESCRIPTION}

**Generated**: {ISO 8601 timestamp}
**Baseline**: {baseline date from integration-surface.md}
**Compared Against**: {GitHub commit hash + date, or local path}

### Verdict Rationale
- {1-3 sentence explanation}
- P1 breaking changes: {N} | P2 compatibility issues: {N} | P3 enhancements: {N}

---

## Change Summary

| Dimension | Changes | Impact |
|-----------|---------|--------|
| Skills    | {N} new, {M} modified, {K} removed | {HIGH/MED/LOW/NONE} |
| Templates | {N} sections changed | {level} |
| Scripts   | {N} flags/fields changed | {level} |
| Workflow  | {N} steps changed | {level} |
| Directory | {N} path changes | {level} |

---

## Detailed Changes

### 1. Skill Changes
{For each changed skill: what changed + impacted spec-kit-skills files}

### 2. Template Format Changes
{For each changed template: section/pattern diffs + impacted files}

### 3. Script Interface Changes
{For each changed script: flag/field diffs + impacted files}

### 4. Workflow Sequence Changes
{Ordering changes, new/removed steps}

### 5. Directory Structure Changes
{Tree diffs + path impact}

---

## Action Items

### P1 — Breaking (must fix before using new spec-kit)
- [ ] `{file}:{section}` — {specific change needed} — {reason}

### P2 — Compatibility (should fix for correct behavior)
- [ ] `{file}:{section}` — {specific change needed} — {reason}

### P3 — Enhancement (optional, improves integration)
- [ ] `{file}:{section}` — {specific change needed} — {reason}

---

## Baseline Update Checklist
After applying all changes, update `speckit-diff/reference/integration-surface.md`:
- [ ] Known Skills table
- [ ] Known Templates sections
- [ ] Known Scripts section
- [ ] Known CLI section
- [ ] Known Directory Structure
- [ ] Baseline date + commit hash
```

### Verdict Logic

```
IF any P1 changes exist:
  VERDICT = "❌ NOT COMPATIBLE"
  DESCRIPTION = "spec-kit-skills requires updates before use with this spec-kit version"

ELSE IF any P2 changes exist:
  VERDICT = "⚠️ MINOR UPDATES NEEDED"
  DESCRIPTION = "spec-kit-skills works but some features may not integrate fully"

ELSE:
  VERDICT = "✅ COMPATIBLE"
  DESCRIPTION = "spec-kit-skills can be used as-is with this spec-kit version"
```

### Output Handling

- **Default** (no `--output`): Display the full report in the conversation
- **With `--output <path>`**: Write the report to the specified file path using the Write tool, then display a summary (verdict + change summary table) in the conversation

---

## Phase 4: Cleanup

1. If temp directory was created (GitHub auto-clone), remove it:
   ```bash
   rm -rf /tmp/speckit-diff-{timestamp}
   ```
2. Report generation is complete
