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

### Confidence Level Assignment Rules (per dimension)

Quantitative criteria for assigning Confidence 0-3 to each dimension. These rules ensure reproducible CI scores across sessions and agents.

| Dimension | 0 (None) | 1 (Vague) | 2 (Partial) | 3 (Full) |
|-----------|----------|-----------|-------------|----------|
| **Core Purpose** | No discernible purpose | Domain noun only ("chat app") | Domain noun + verb ("real-time chat with file sharing") | Specific problem + solution approach ("real-time team chat replacing Slack, with E2E encryption and offline sync") |
| **Key Capabilities** | No features mentioned | 1-2 features implied | 3-5 features explicitly listed | 6+ features OR User Stories included OR priority ordering |
| **Project Type** | Unknown | Generic ("app", "server") | Interface axis identified ("REST API", "desktop app") | Interface + archetype identified ("REST API microservice gateway") |
| **Tech Stack** | Not mentioned | Language only ("TypeScript") | Language + framework ("TypeScript + NestJS") | Language + framework + DB + infra ("TypeScript + NestJS + PostgreSQL + Redis + Docker") |
| **Target Users** | Not mentioned | Generic ("users") | 1-2 roles identified ("admin, member") | 3+ roles OR permission model described OR user personas |
| **Scale & Scope** | Not mentioned | Qualitative ("small", "large") | One quantitative signal (deployment model OR user count) | Deployment + user count + growth strategy OR maturity level explicit |
| **Constraints** | Not mentioned | Qualitative ("fast", "secure") | 1-2 specific constraints ("GDPR compliant", "<100ms latency") | 3+ specific constraints OR compliance framework named OR SLA defined |

### Scoring Formula

```
Per-dimension score = Confidence × Weight
Total CI = (Σ per-dimension scores / max possible) × 100%

Weights (from § 1 table):
  Core Purpose: ×3, Key Capabilities: ×3, Project Type: ×2,
  Tech Stack: ×1, Target Users: ×1, Scale & Scope: ×1, Constraints: ×1

Max possible = (3×3) + (3×3) + (3×2) + (3×1) + (3×1) + (3×1) + (3×1) = 36
CI% = (total / 36) × 100

Example:
  Core Purpose: 3×3=9, Capabilities: 3×3=9, Project Type: 3×2=6,
  Tech Stack: 3×1=3, Users: 2×1=2, Scale: 3×1=3, Constraints: 3×1=3
  = 35/36 = 97%
```

### Transparency Requirement

When displaying CI Score in the Proposal, show the per-dimension breakdown:

```
📊 Clarity Index: 97% (35/36)

| Dimension | Confidence | Weight | Score | Signal |
|-----------|-----------|--------|-------|--------|
| Core Purpose | 3/3 | ×3 | 9 | "Enterprise AI gateway with multi-tenant budget management" |
| Key Capabilities | 3/3 | ×3 | 9 | 7 features listed (LLM proxy, auth, budget, logging, guard, dashboard, knowledge) |
| Project Type | 3/3 | ×2 | 6 | "http-api + microservice archetype" detected |
| Tech Stack | 3/3 | ×1 | 3 | "TypeScript + NestJS + PostgreSQL + Redis + Next.js" |
| Target Users | 2/3 | ×1 | 2 | "admin, member, viewer" (3 roles but no personas) |
| Scale & Scope | 3/3 | ×1 | 3 | "production × small-team, multi-tenant SaaS" |
| Constraints | 3/3 | ×1 | 3 | "PII masking, prompt injection defense, OWASP LLM Top 10" |
```

This ensures the user can challenge any dimension: "I think Target Users should be 3 — we have detailed personas in the PRD."

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

1. **Load vocabulary**: Read S0 keywords from `shared/domains/interfaces/*.md` and `shared/domains/concerns/*.md`, plus A0 keywords from `shared/domains/archetypes/*.md` (see `domains/_resolver.md` § S0/A0 Aggregation). This is a one-time scan cached for the session.
2. **Parse input** → extract keyword signals (nouns, technologies, patterns)
3. **Match signals** against S0/A0 keyword vocabulary using the Matching Algorithm (see below)
4. **Score each CI dimension** based on matched signals (see Dimension-Signal Mapping below)
5. **Map signals to 3-Axis** → infer Interface, Concern, Scenario axes (see § 4)
6. **Infer Archetype** from A0 matches (see § 4b)

### Matching Algorithm

Defines how user input tokens are compared against S0/A0 keyword vocabulary.

**Tokenization**:
1. Split input text at whitespace and punctuation boundaries (preserve hyphens within compound terms like `real-time`)
2. Before single-token matching, attempt **compound keyword matching**: scan for multi-word S0/A0 keywords (e.g., `Chrome extension`, `web app`, `state management`) by checking consecutive token sequences in the input
3. Matched compound keywords are consumed — their individual tokens are NOT re-matched against single-token keywords (prevents `Chrome` from matching `cli` module if `Chrome extension` already matched `gui`)

**Comparison rules**:
- **Case-insensitive**: `react` matches `React`, `GRAPHQL` matches `GraphQL`
- **Dot/separator-insensitive for technology names**: `nextjs` matches `Next.js`, `socketio` matches `Socket.io` (strip dots and compare)
- **Whole-token only**: `graph` does NOT match `GraphQL`, `web` does NOT match `WebSocket`. Only complete token or compound matches count
- **No stemming or lemmatization**: `streaming` ≠ `stream` unless both are listed as separate S0 keywords

**Match classification**:
- **Primary match** (≥ 1 Primary keyword hit) → **activate** the module
- **Secondary match only** (≥ 1 Secondary keyword hit, 0 Primary) → **flag** for user confirmation at the Proposal HARD STOP
- **No match** → module not loaded

**Disambiguation**: A token may match keywords in multiple modules (e.g., `streaming` may appear in both `realtime` S0 and `ai-assistant` A0). All matches are recorded — disambiguation happens at the Proposal level where the user sees all activated/flagged modules and can adjust.

**Scoring integration**: Each matched keyword contributes to CI dimensions based on its nature:

| Keyword Nature | CI Dimension Affected |
|---------------|----------------------|
| Technology names (React, PostgreSQL, Hono) | Tech Stack |
| Platform keywords (web app, CLI, desktop) | Project Type |
| Feature-indicating keywords (drag-drop, search, export) | Key Capabilities |
| Domain nouns (task management, e-commerce, chat) | Core Purpose |
| User role keywords (admin, developer, customer) | Target Users |
| Scale indicators (enterprise, SaaS, personal) | Scale & Scope |
| Constraint keywords (HIPAA, offline, real-time) | Constraints |

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

### Archetype Inference (A0)

A0 keywords from `shared/domains/archetypes/*.md` are matched in the same pass as S0:

| Signal Pattern | Inferred Archetype |
|---------------|-------------------|
| "LLM", "OpenAI", "Claude", "langchain", "AI agent", "chatbot", "prompt" | `ai-assistant` |
| "OpenAPI", "rate-limit", "API key", "developer portal", "API versioning" | `public-api` |
| "gRPC", "docker-compose", "service mesh", "Kubernetes", "distributed" | `microservice` |

Archetype inference is **orthogonal to CI scoring** — it does not affect the 7 CI dimensions. Matched archetypes load A1 philosophy principles and A2 SC extensions during the pipeline.

If no A0 keywords match → Archetype is `"none"` (no archetype-specific rules loaded).

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

## 5. S0/A0 Signal Keywords — Distributed Vocabulary

Each domain module declares its own signal keywords in the shared directory (`shared/domains/`). This creates a distributed vocabulary — when a new module is added, its signals are automatically available for extraction.

### Signal Keyword Format

```
shared/domains/interfaces/{name}.md   → § Signal Keywords → Semantic (S0)
shared/domains/concerns/{name}.md     → § Signal Keywords → Semantic (S0)
shared/domains/archetypes/{name}.md   → § Signal Keywords → Semantic (A0)
```

Each section contains:
- **Primary**: High-confidence keywords — ≥ 1 match activates the module
- **Secondary**: Medium-confidence keywords — ≥ 1 match flags for user confirmation

> Module registry: `shared/domains/_taxonomy.md` lists all available modules.

### S0 Aggregation Rule

During Signal Extraction (init Proposal Mode):
1. Read `_core.md` (no S0 — core is always loaded)
2. Read each `shared/domains/interfaces/*.md` S0 section → build Interface signal map
3. Read each `shared/domains/concerns/*.md` S0 section → build Concern signal map
4. Match user input against all signal maps using the Matching Algorithm (§ 3)
5. Activate modules whose Primary keywords have ≥ 1 match
6. Flag modules whose Secondary keywords have ≥ 1 match (ask for confirmation)

### A0 Aggregation Rule

Runs **in parallel with S0** during the same vocabulary scan:
1. Read each `shared/domains/archetypes/*.md` A0 section → build Archetype signal map
2. Match user input against archetype signal maps using the same Matching Algorithm (§ 3)
3. Activate archetypes whose Primary keywords have ≥ 1 match
4. Flag archetypes whose Secondary keywords have ≥ 1 match (ask for confirmation)
5. Result → Proposal's "Inferred Archetype" field (or `"none"` if no A0 matches)

**A0 does NOT affect CI score** — archetypes are orthogonal to the 7 CI dimensions. However, matched archetypes determine which A1 philosophy principles and A2 SC extensions are loaded for the pipeline.

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
**Archetype**: {matched archetype(s) from A0 keywords, or "none"}
**Context Mode**: greenfield

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
