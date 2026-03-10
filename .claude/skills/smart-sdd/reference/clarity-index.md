# Clarity Index (CI) — Idea Concreteness Scoring

> Quantifies how concrete a user's project idea is. Drives agent behavior across the SDD pipeline.
> Referenced by: `commands/init.md` (Proposal Mode), `commands/pipeline.md` (CI propagation), `domains/_resolver.md` (Greenfield Inference)

---

## 1. CI Scoring Model

### 7 Dimensions × Confidence Levels × Weights

| # | Dimension | Weight | What It Measures | Max Points |
|---|-----------|--------|-----------------|------------|
| 1 | Core Purpose | ×3 | What the project does and why | 9 |
| 2 | Key Capabilities | ×3 | Main features / user stories | 9 |
| 3 | Project Type | ×2 | Interface axes (web app, CLI, desktop, API) | 6 |
| 4 | Tech Stack | ×1 | Language, framework, DB, libraries | 3 |
| 5 | Target Users | ×1 | Who uses it, how they interact | 3 |
| 6 | Scale & Scope | ×1 | Size expectations, deployment model | 3 |
| 7 | Constraints | ×1 | Performance, compliance, integration limits | 3 |

**Max total**: 36 points → CI = (score / 36) × 100%

### Confidence Levels (per dimension)

| Level | Score | Meaning | Signal Examples |
|-------|-------|---------|----------------|
| 0 | 0 | No signal | Dimension not mentioned at all |
| 1 | 1 | Vague hint | "something for managing tasks" (purpose hinted but unclear) |
| 2 | 2 | Partial clarity | "task management web app with Kanban boards" (partial specifics) |
| 3 | 3 | Fully specified | "React + Node.js Kanban board with drag-drop, user auth, team workspaces" (detailed) |

---

## 2. CI Tiers — Agent Behavior

| Tier | CI Range | Agent Strategy | HARD STOPs |
|------|----------|---------------|------------|
| **Rich** | ≥ 70% | Generate Proposal directly. Infer missing details, confirm once | 1 (Proposal approval) |
| **Medium** | 40–69% | Infer what's possible, ask 2–3 targeted questions, then Proposal | 1–2 (brief clarification + Proposal) |
| **Vague** | 15–39% | Ask a seed question to unlock the lowest-confidence dimension, re-score, then route to Medium/Rich | 2–3 (seed question + clarification + Proposal) |
| **Empty** | < 15% | Request core purpose ("What are you building and why?") | 3+ (core purpose + follow-ups + Proposal) |

### Tier Routing Logic

```
1. Score initial CI from user input (idea string / PRD / conversation)
2. Route by tier:
   - Rich:  → Generate Proposal (skip clarification)
   - Medium: → Infer + targeted questions → Re-score → Generate Proposal
   - Vague:  → Seed question for lowest-confidence dimension → Re-score → Route again
   - Empty:  → "What are you building and why?" → Re-score → Route again
3. Each re-score may promote to a higher tier
4. Generate Proposal when CI ≥ 40% (or user says "just go with it")
```

---

## 3. Signal Extraction — Input to CI

### Signal Sources

| Source | Available When | Example |
|--------|---------------|---------|
| **Idea string** | `init "Build a Chrome extension for..."` | Natural language argument |
| **PRD document** | `init --prd design.md` | Structured document |
| **Conversation** | `init` (no args) | Interactive Q&A |
| **Existing code** | Project has `package.json`, `src/`, etc. | File system scan |

### Extraction Procedure

1. **Parse input** → extract keyword signals (nouns, technologies, patterns)
2. **Match signals against S0 Signal Keywords** in domain modules (see § 5)
3. **Score each CI dimension** based on matched signals
4. **Map signals to 3-Axis** → infer Interface, Concern, Scenario axes

### Dimension-Signal Mapping

| Dimension | What to look for in input |
|-----------|--------------------------|
| Core Purpose | Verbs + domain nouns ("manage tasks", "track inventory", "chat with AI") |
| Key Capabilities | Feature mentions ("drag-drop", "search", "notifications", "export CSV") |
| Project Type | Platform keywords ("web app", "CLI", "mobile", "desktop", "Chrome extension", "API") |
| Tech Stack | Technology names ("React", "Python", "PostgreSQL", "Electron") |
| Target Users | User role mentions ("admin", "developers", "customers", "team members") |
| Scale & Scope | Scale indicators ("enterprise", "personal tool", "SaaS", "microservices") |
| Constraints | Limit mentions ("HIPAA", "offline", "real-time", "< 100ms latency") |

---

## 4. Signal-to-Axis Mapping — 3-Axis Integration

Signal keywords extracted from user input map to the 3-axis domain composition.

### Interface Inference

| Signal Pattern | Inferred Interface |
|---------------|-------------------|
| "web app", "dashboard", "UI", "frontend", "pages", "React", "Vue", "Svelte" | `gui` |
| "API", "REST", "GraphQL", "endpoints", "backend", "server", "Express", "FastAPI" | `http-api` |
| "CLI", "command line", "terminal", "script", "flags", "arguments" | `cli` |
| "pipeline", "ETL", "data processing", "batch", "stream", "transform" | `data-io` |
| "Chrome extension", "browser extension" | `gui` |
| "desktop app", "Electron", "Tauri" | `gui` |
| "full-stack", "web application" | `gui` + `http-api` |

### Concern Inference

| Signal Pattern | Inferred Concern |
|---------------|-----------------|
| "Zustand", "Redux", "MobX", "Pinia", "state management", "reactive" | `async-state` |
| "Electron", "main process", "renderer", "IPC", "Web Workers" | `ipc` |
| "OpenAI", "Stripe", "AWS SDK", "third-party API", "AI SDK" | `external-sdk` |
| "i18n", "internationalization", "localization", "multi-language", "translation" | `i18n` |
| "WebSocket", "SSE", "real-time", "live updates", "Socket.io", "streaming" | `realtime` |
| "auth", "login", "JWT", "OAuth", "session", "role-based", "permissions" | `auth` |

### Scenario Inference (for init — always greenfield)

For `init`, scenario is always `greenfield`. Other scenarios are determined by origin:
- `/reverse-spec` → `rebuild` or `adoption`
- `/smart-sdd add` on existing project → `incremental`

### Per-Axis Confidence

Each axis gets a confidence score (0–3) based on signal strength:

| Confidence | Interface Axis | Concern Axis |
|-----------|---------------|--------------|
| 0 | No platform mentioned | No cross-cutting patterns mentioned |
| 1 | Vague ("it's a web thing") | Implicit ("users log in" → auth hinted) |
| 2 | Partial ("React frontend") | Partial ("uses OpenAI API" → external-sdk) |
| 3 | Specific ("Next.js 14 App Router + Express backend") | Multiple specific ("Zustand + i18next + Stripe SDK") |

Per-axis confidence feeds into CI Dimension #3 (Project Type) scoring.

---

## 5. S0 Signal Keywords — Distributed Vocabulary

Each domain module (interface, concern) declares its own signal keywords in an optional **S0** section. This creates a distributed vocabulary — when a new module is added, its signals are automatically available for extraction.

### S0 Section Format

```markdown
## S0. Signal Keywords

> Keywords that indicate this module should be activated. Used by Clarity Index signal extraction.

**Primary**: [high-confidence keywords — strong indicator]
**Secondary**: [medium-confidence keywords — needs confirmation]
```

### Aggregation Rule

During Signal Extraction (init Proposal Mode):
1. Read `_core.md` (no S0 — core is always loaded)
2. Read each `interfaces/*.md` S0 section → build Interface signal map
3. Read each `concerns/*.md` S0 section → build Concern signal map
4. Match user input against all signal maps
5. Activate modules whose Primary keywords have ≥ 1 match
6. Flag modules whose Secondary keywords have ≥ 1 match (ask for confirmation)

---

## 6. CI in sdd-state.md

### Header Fields

```markdown
**Clarity Index**: [XX%]
**CI Dimensions**: [Core:N, Cap:N, Type:N, Stack:N, Users:N, Scale:N, Constraints:N]
**CI Low-confidence**: [comma-separated dimension names with score ≤ 1, or "none"]
```

### Update Rules

| Event | CI Update |
|-------|----------|
| `init` Proposal Mode — initial scoring | Write initial CI to sdd-state.md |
| `init` Proposal Mode — after clarification | Update CI with improved scores |
| `add` — Features defined | Update Key Capabilities dimension based on Feature count and specificity |
| `specify` — spec.md generated | Partial update: constraints/capabilities refined from spec details |
| CI never decreases | Only dimensions that improve are updated; scores never drop |

### CI Propagation — Pipeline Verification Intensity

Lower initial CI → more verification gates in the pipeline:

| CI at Pipeline Start | specify Behavior | plan Behavior | verify Behavior |
|---------------------|-----------------|--------------|----------------|
| ≥ 70% | Standard spec generation | Standard plan | Standard verify |
| 40–69% | Extra SC completeness check (are all CI dimensions covered?) | Plan Review emphasizes low-CI dimensions | Verify Phase 2 adds dimension-gap checks |
| < 40% | Mandatory clarify sub-step regardless of spec quality | Plan Review has explicit HARD STOP for low-CI gap discussion | Verify Phase 3b adds empty-state checks for each low-CI area |

### Per-Dimension Low-Confidence Propagation

When a specific dimension has confidence ≤ 1 at pipeline start:

| Low-Confidence Dimension | Pipeline Impact |
|--------------------------|----------------|
| Core Purpose | specify: HARD STOP — "Purpose unclear, clarify before proceeding" |
| Key Capabilities | specify: SC generation adds "completeness gap" warnings |
| Project Type | plan: Architecture Decision Records (ADRs) emphasize interface choice rationale |
| Tech Stack | plan: Add "tech stack rationale" section to plan output |
| Target Users | specify: Add "user role identification" prompt |
| Scale & Scope | plan: Default to minimal architecture (no premature optimization) |
| Constraints | verify: No additional checks (constraints clarify during implementation) |

---

## 7. Proposal Format

When CI scoring is complete and Proposal is generated (CI ≥ 40%):

```markdown
# Project Proposal: {Project Name}

## Overview
{1–2 sentence summary based on extracted signals}

## Clarity Index: {XX%}
| Dimension | Confidence | Details |
|-----------|-----------|---------|
| Core Purpose | ★★★ | {extracted purpose} |
| Key Capabilities | ★★☆ | {extracted features} |
| ... | ... | ... |

## Inferred Domain Profile
**Interfaces**: {list with rationale}
**Concerns**: {list with rationale}
**Scenario**: greenfield

## Proposed Features
| # | Feature | Source Signal | Priority |
|---|---------|-------------|----------|
| 1 | {name} | "{keyword from input}" | Must-have |
| 2 | {name} | inferred from {reason} | Should-have |

## Quality Rules Activated
{List of S1 rules, S7 bug prevention rules from active modules}

## Open Questions
{Any CI dimensions with confidence ≤ 1 — presented as questions, not blockers}

## Next Steps
- Approve this Proposal → auto-chain to constitution + add
- Modify → adjust specific sections
- Start over → new idea string
```

This Proposal is displayed at the HARD STOP. User approval chains into Phase 2 (Constitution) + Phase 4 (Feature Definition via `add`).
