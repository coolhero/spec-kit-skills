# Foundation Module Template

> Create a new Foundation module as a single file in `reverse-spec/domains/foundations/`.
> Replace all `{placeholders}` with actual values.
> Foundations are framework-specific. Use the 2-3 letter prefix from `_foundation-core.md` § F4
> or assign a new unique prefix.
>
> Two format variants:
> - **Full format**: 40+ decision items, includes F3 (Extraction Rules) and F4 (T0 Grouping)
> - **Compact format**: Key decision items only, omits F3/F4
> Choose based on framework complexity. Start compact; expand to full if needed.

---

## File: `reverse-spec/domains/foundations/{name}.md`

```markdown
# {Framework Name} Foundation
<!-- Format: _foundation-core.md | ID prefix: {FW} (see § F4) -->

## F0. Detection Signals

| Signal | Confidence |
|--------|-----------|
| `{package-name}` in `{config-file}` (e.g., package.json dependencies) | HIGH |
| `{entry-point-pattern}` in source (e.g., app factory call) | HIGH |
| `{secondary-signal}` (e.g., framework-specific directory structure) | MEDIUM |

---

## F1. Foundation Categories

| Category Code | Category Name | Item Count | Description |
|--------------|---------------|------------|-------------|
| BST | App Bootstrap | {N} | {How the app starts, entry point pattern} |
| SEC | Security | {N} | {Auth, authorization, CORS, headers} |
| API | API Design | {N} | {Routing, versioning, validation} |
| DBS | Database | {N} | {ORM, connection, migration} |
| ERR | Error Handling | {N} | {Error strategy, response format} |
| TST | Testing | {N} | {Test framework, coverage} |
| BLD | Build & Deploy | {N} | {Build tools, deployment} |
| ENV | Environment Config | {N} | {Env management, configuration} |

<!-- Add/remove categories as appropriate for the framework. -->
<!-- Common optional categories: MID (Middleware), PRC (Process), HLT (Health), LOG (Logging), DXP (Developer Experience) -->

---

## F2. Decision Items

### BST — App Bootstrap

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| {FW}-BST-01 | {Item name} | {What decision is being made} | {choice (...) | binary | config} | {Critical | Important} |

### SEC — Security

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| {FW}-SEC-01 | {Item name} | {Description} | {type} | {priority} |

<!-- Repeat for each category in F1. -->
<!-- Decision Type values: -->
<!--   choice (option1 / option2 / ...) — pick from known alternatives -->
<!--   binary — yes or no -->
<!--   config — freeform configuration value -->

---

## F3. Extraction Rules (reverse-spec)

> Optional. Include for full-format foundations.

| Category | Extraction Method |
|----------|------------------|
| BST | {How to detect bootstrap pattern from source code} |
| SEC | {How to detect security configuration} |

---

## F4. T0 Feature Grouping

> Optional. Include for full-format foundations.
> Groups foundation items into T0 features for the roadmap.

| T0 Feature | Foundation Categories | Items |
|------------|----------------------|-------|
| F000-{group-name} | {CAT1} + {CAT2} | {count} |

---

## F7. Framework Philosophy

| Principle | Description | Implication |
|-----------|-------------|-------------|
| **{Principle Name}** | {What this principle means for the framework} | {How it affects architecture decisions and SC generation} |

---

## F8. Toolchain Commands

| Field | Command |
|-------|---------|
| `build` | `{build command}` |
| `test` | `{test command}` |
| `lint` | `{lint command}` |
| `package_manager` | `{npm | yarn | pnpm | pip | cargo | go | ...}` |
| `install` | `{install command}` |

---

## F9. Scan Targets

> Optional. Helps reverse-spec locate framework-specific patterns.

#### Data Model
| Pattern | Description |
|---------|-------------|
| `{ORM/model pattern}` in `{file path glob}` | {What this captures} |

#### API Endpoints
| Pattern | Description |
|---------|-------------|
| `{route definition pattern}` in `{file path glob}` | {What this captures} |
```

---

## Checklist After Creation

- [ ] ID prefix ({FW}) is unique — check `_foundation-core.md` § F4 for existing prefixes
- [ ] F0 detection signals have confidence levels (HIGH/MEDIUM)
- [ ] F1 category codes are 3 uppercase letters
- [ ] F2 item IDs follow `{FW}-{CAT}-{NN}` format
- [ ] F7 has at least 2-3 philosophy principles
- [ ] F8 toolchain commands are accurate for the framework
- [ ] Register the new prefix in `_foundation-core.md` § F4
