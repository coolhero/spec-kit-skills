---
name: speckit-diff
description: Analyzes spec-kit version differences and identifies required updates to spec-kit-skills (smart-sdd + reverse-spec). Auto-clones latest spec-kit from GitHub and compares against baseline. Read-only analysis producing a compatibility verdict and impact report.
argument-hint: "[--output path] [--local path]"
allowed-tools: [Read, Grep, Glob, Bash, Write]
---

# speckit-diff: Spec-Kit Version Compatibility Analyzer

Compares the latest spec-kit version against a stored baseline to determine whether spec-kit-skills (smart-sdd + reverse-spec) are still compatible. Produces a clear **COMPATIBLE / NOT COMPATIBLE** verdict followed by a detailed impact report.

**This skill works independently** — no dependency on reverse-spec, smart-sdd, or any active project. It can be run from any Claude Code session.

---

## Usage

```
/speckit-diff                          # Auto-clone latest spec-kit from GitHub and compare
/speckit-diff --local ./spec-kit-repo  # Compare against local spec-kit repo
/speckit-diff --output report.md       # Write report to file instead of displaying
```

---

## Argument Parsing

```
$ARGUMENTS parsing rules:

  --output <path>  → Write report to file at <path> (default: display in conversation)
  --local <path>   → Use local spec-kit repo instead of GitHub clone
                     Path must contain templates/commands/*.md (raw spec-kit repo structure)

Any other arguments → ERROR: "Unknown argument. Usage: /speckit-diff [--output path] [--local path]"
```

---

## Workflow

After parsing arguments, read `commands/diff.md` for the complete workflow (5 phases: Source Acquisition → Scanning → Impact Mapping → Report Generation → Cleanup).

---

## CRITICAL Rules

1. **Non-destructive analysis**: This skill NEVER modifies existing spec-kit-skills files. It only reads and reports (optionally writing a new report file via `--output`).
2. **No project dependency**: This skill does NOT require reverse-spec, smart-sdd, or any project to be active. It only needs:
   - Access to the spec-kit source (cloned or local)
   - The baseline file (bundled with this skill)
3. **Structural comparison only**: Compare section headers, format patterns, script flags, and JSON fields. Do NOT attempt semantic understanding of skill instructions.
4. **Conservative classification**: When unsure if a change is P1 or P2, classify as P1. False positives (warning when not needed) are better than false negatives (missing a breaking change).
5. **Complete coverage**: Every change MUST be mapped to at least one impacted spec-kit-skills file. If a change has no impact, explicitly note it as "No impact on spec-kit-skills".
