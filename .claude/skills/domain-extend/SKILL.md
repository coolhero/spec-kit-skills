---
name: domain-extend
description: "Explore, extend, and customize the domain module system. Browse existing modules, detect gaps from code or explore artifacts, create new modules, import from internal docs, and manage org/project conventions. Use when the pipeline needs domain knowledge that existing modules don't cover."
argument-hint: "<command> [target] [--from-explore path] [--org] [--active] [--full]  # commands: browse|detect|extend|import|customize|validate"
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash, Agent, AskUserQuestion, TodoWrite]
---

# domain-extend: Domain Module DevTool

> **MANDATORY RULE — READ FIRST**
>
> **Empty Response Enforcement**
> Every AskUserQuestion in this skill MUST be checked after returning:
> 1. **CHECK the response** — is it empty, blank, or missing a selection?
> 2. **If empty → call AskUserQuestion AGAIN.** Do NOT proceed. Do NOT assume a default.
> 3. **Only proceed when the user has explicitly selected an option.**

Interactive toolkit for exploring, extending, and customizing the 5-axis domain module system. Use this skill when:
- You want to understand what domain modules exist and how they work
- The pipeline encounters patterns not covered by existing modules
- You have internal documentation (style guides, architecture docs) to codify as modules
- You need org-wide or project-specific conventions layered on top of standard modules

**Output paths** (three-tier module resolution):
- **Project-level (default)**: `specs/domains/{axis}/` in project CWD — committed to project git, per-project
- **Skill-level (`--skill` flag)**: `~/.claude/skills/{shared,reverse-spec,smart-sdd}/domains/{axis}/` — built-in, read-only for projects
- **Org-convention**: Path configured in `sdd-state.md` → `**Org Convention Path**:` field (e.g., `specs/_global/org-convention.md`)

> The resolver loads skill-level modules first, then project-level modules override/extend via append semantics. See `smart-sdd/domains/_resolver.md` Step 6b.

---

## Usage

```
/domain-extend browse                          → System overview: all axes, module counts
/domain-extend browse concerns                 → List all Concern modules with descriptions
/domain-extend browse "realtime"               → Keyword search across all modules
/domain-extend browse profile ai-assistant     → Show what loading a profile activates
/domain-extend browse rules gui+async-state    → Cross-concern integration rules
/domain-extend browse --active                 → Show current project's loaded modules

/domain-extend detect                          → Profile gap analysis (from sdd-state.md)
/domain-extend detect /path/to/code            → Scan codebase for uncovered patterns
/domain-extend detect --from-explore ./specs   → Cross-reference explore artifacts vs modules

/domain-extend extend concerns/rate-limiting   → Create new Concern module from scratch
/domain-extend extend context-modifier compliance → Create Context Modifier (single file)
/domain-extend import /docs/style-guide.md     → Import internal doc as module sections
/domain-extend customize auth --org            → Create org-level auth convention overlay
/domain-extend validate                        → Check all modules for schema compliance
```

---

## Argument Parsing

```
$ARGUMENTS parsing rules:
  Positional[0] (command)     → browse | detect | extend | import | customize | validate
  Positional[1] (target)      → varies by command (see Command Routing)
  --from-explore <path>       → path to specs/explore/ artifacts (for detect)
  --org                       → target org-convention layer (for customize)
  --active                    → show only active modules from sdd-state.md (for browse)
  --full                      → show full module content instead of summary (for browse)
  --skill                     → install to skill directory (~/.claude/skills/) instead of project directory (specs/domains/).
                                Use only when contributing built-in modules to spec-kit-skills itself.
  --dry-run                   → preview changes without writing files (for extend/import)
```

---

## Command Routing

| Input Pattern | Command File |
|---------------|-------------|
| `/domain-extend browse [target]` | Read `commands/browse.md` |
| `/domain-extend detect [target]` | Read `commands/detect.md` |
| `/domain-extend extend <axis/name>` | Read `commands/extend.md` |
| `/domain-extend import <path>` | Read `commands/import.md` |
| `/domain-extend customize <module> [--org]` | Read `commands/customize.md` |
| `/domain-extend validate` | Read `commands/validate.md` |

---

## Manual Path Philosophy

Every command in domain-extend shows the **manual alternative** alongside automated actions. The domain module system is designed to be human-editable — files are plain Markdown following `_TEMPLATE.md`. Automation accelerates, but users always know how to do it by hand:

```
Automated:  /domain-extend extend concerns/rate-limiting
Manual:     cp _TEMPLATE.md concerns/rate-limiting.md → edit → update _taxonomy.md
```

This ensures users are never locked into the skill and can maintain modules independently.

---

## Gotchas

Accumulated edge cases from real usage. Check this list when hitting unexpected behavior.

| # | Gotcha | What Goes Wrong | Fix |
|---|--------|----------------|-----|
| G1 | Creating module in wrong directory | Module placed in skill directory instead of project directory → affects all projects sharing the skill | Default output is `specs/domains/{axis}/` (project-local). Use `--skill` only when contributing built-in modules to spec-kit-skills |
| G2 | Forgetting to update `_taxonomy.md` | New module exists but resolver cannot find it → module never loads | After manual module creation, always add entry to `_taxonomy.md` in the correct axis table |
| G3 | Duplicate S0 keywords across modules | Resolver activates wrong module when keywords overlap (e.g., "cache" in both `cache-server` and `connection-pool`) | Use `validate` command to detect keyword collisions; make Primary keywords unique per module |
| G4 | Using `extend` when `import` is better | User has existing docs (style guide, architecture decisions) → `extend` starts from blank template | Use `import /path/to/doc.md` to extract relevant sections into module format |
| G5 | Creating org-convention without state path | Convention file written but `sdd-state.md` has no `Org Convention Path` → pipeline ignores it | Use `customize --org` which auto-sets the path, or manually add to `sdd-state.md` |

---

## Composability

domain-extend integrates with the other spec-kit skills:

```
code-explore → /domain-extend detect --from-explore  (find uncovered patterns)
/domain-extend browse → manual module editing          (understand before changing)
/domain-extend extend → /smart-sdd init/add            (new module available for pipeline)
/domain-extend detect → /domain-extend extend          (gap found → fill it)
/domain-extend import → /domain-extend validate        (imported module → check compliance)
/domain-extend customize --org → /smart-sdd pipeline   (org rules applied to all Features)
```

### Key Integration Points

| Skill | How domain-extend Connects |
|-------|---------------------------|
| **code-explore** | `detect --from-explore` reads orientation.md + traces to find domain patterns |
| **smart-sdd** | `browse --active` reads `sdd-state.md` Domain Profile; new modules become available in pipeline |
| **reverse-spec** | `detect` scans pre-context artifacts for uncovered patterns |
| **shared/domains/** | All commands read/write the shared module directory and `_taxonomy.md` |

> All module changes take effect on the **next** pipeline command invocation. No restart or cache clear needed — the resolver reads files fresh each time.
