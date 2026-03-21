---
name: case-study
description: "[DEPRECATED] Use Auto-Report instead — reports are now generated automatically at pipeline completion. This skill is retained for backward compatibility only. See shared/reference/completion-report.md for the replacement."
argument-hint: "[target-directory] [--lang en|ko]"
allowed-tools: [Read, Grep, Glob, Write, Bash]
---

# Case Study: SDD Workflow Report Generator

> **⚠️ DEPRECATED**: This skill has been superseded by the **Auto-Report** system.
>
> Reports are now generated **automatically** at the end of each pipeline stage:
> - `/reverse-spec` Phase 4-5 → `specs/_global/completion-report.md`
> - `/smart-sdd adopt` pipeline end → `specs/_global/adoption-report.md`
> - `/smart-sdd pipeline` end → `specs/_global/pipeline-report.md`
>
> The Auto-Report template (`shared/reference/completion-report.md`) provides a superset
> of the case-study report: 10 sections (vs 8), 3 generation modes, architecture philosophy
> analysis (§5.2-§5.3), and no dependency on `case-study-log.md`.
>
> **Migration**: No action needed. If you previously used `/case-study`, the same data
> is now captured automatically. The `case-study-log.md` file is no longer required —
> all qualitative data is recorded in `history.md` per-Feature Implementation Decisions.
>
> This skill file is retained for backward compatibility. Running `/case-study` still works
> but internally delegates to the same artifact-reading logic as the Auto-Report.

---

## Legacy Usage (still functional)

```
/case-study                                # English → case-study-YYYYMMDD-HHMM.md
/case-study --lang ko                      # Korean → case-study-YYYYMMDD-HHMM.md
/case-study ./my-project --lang ko         # Specific project directory
```

> `case-study-log.md` is no longer required. If present, qualitative observations are
> included; if absent, the report generates fully from pipeline artifacts (history.md,
> sdd-state.md, registries, constitution-seed.md, per-Feature specs).

---

## Argument Parsing

```
$ARGUMENTS parsing rules:
  First token       → target-directory (optional, defaults to CWD). If it looks like a path.
  --lang <en|ko>    → Output language (default: "en")
```

After parsing arguments, read `commands/generate.md` and execute its workflow.

---

## Case Study Agenda

The report follows an 8-section structure (see `commands/generate.md` for details). Sections with no available data are omitted or show "Data not available".

---

## CRITICAL Rules

1. **Read-only**: This skill NEVER modifies project files. It only reads artifacts and writes a new report file.
2. **Graceful degradation**: Only `roadmap.md` and `sdd-state.md` are required. All other artifacts are optional — the report adapts to available data.
3. **No project dependency**: This skill does not require reverse-spec or smart-sdd to be installed. It only reads their output artifacts.
4. **Language consistency**: When `--lang ko`, ALL section headers and descriptive text must be in Korean. Artifact names (file names, Feature IDs) remain in English.
