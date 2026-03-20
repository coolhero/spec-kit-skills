# Synthesis — Trace Aggregation and Spec Handoff

> Reference: Read after `/code-explore synthesis` is invoked.

## Purpose

Aggregate all accumulated traces into a synthesis document: consolidated entity/API maps, identified patterns, Feature candidates, and handoff preparation for reverse-spec or smart-sdd.

---

## Prerequisites

- At least 1 trace must exist in `specs/explore/traces/`. If not:
  ```
  ⚠️ No traces found. Run /code-explore trace "topic" to explore
  the codebase before synthesizing.
  ```

## Cross-Directory Handoff

If explore artifacts are in a **different directory** from where the user wants to build (e.g., traces in `/other/project/specs/explore/` but building in `~/my-project/`):

1. Generate `synthesis.md` in the explore directory (alongside traces)
2. **Copy synthesis.md to CWD**: `cp /other/project/specs/explore/synthesis.md ~/my-project/specs/explore/synthesis.md`
3. **Cleanup offer** (HARD STOP):
   ```
   📋 Synthesis complete. Explore artifacts are in /other/project/specs/explore/.

   Cleanup options:
   ```
   AskUserQuestion:
   - **"Keep explore branch"** → Leave `explore-study` branch for future reference
   - **"Delete explore branch"** → `git checkout main && git branch -D explore-study` in target repo
   - **"Keep as-is"** → No cleanup

---

## Synthesis Process

### Step 1 — Read All Traces

Read every `specs/explore/traces/*.md` file and extract structured data:
- All Flow tables → aggregated call map
- All Entities Observed → consolidated entity list
- All APIs Observed → consolidated API list
- All Business Rules → consolidated rule list
- All Observations → categorized by icon (💡 ❓ ⚠️ 🔧)

### Step 2 — Entity Consolidation

Merge entities observed across multiple traces:
- Same entity name in different traces → merge fields (union)
- Different traces may reveal different fields of the same entity
- Flag conflicts: if same entity has contradictory field types across traces

```markdown
## Consolidated Entity Map

| Entity | First Seen | Traces | Fields (merged) | Candidate Owner |
|--------|-----------|--------|-----------------|-----------------|
| User | Trace 001 | 001, 003, 005 | id, name, email, role, avatar | C001-auth |
| Session | Trace 001 | 001, 004 | id, userId, token, expiresAt, refreshToken | C001-auth |
| Order | Trace 003 | 003, 006 | id, items, status, userId, total, createdAt | C003-orders |
```

### Step 3 — API Consolidation

Merge APIs observed across traces:

```markdown
## Consolidated API Map

| Method | Path | Traces | Provider Module | Consumers |
|--------|------|--------|-----------------|-----------|
| POST | /api/login | 001, 004 | auth/ | ui/, cli/ |
| GET | /api/orders | 003, 006 | orders/ | ui/ |
```

### Step 4 — Observation Aggregation

Group observations by icon type:

```markdown
## Accumulated Insights

### Patterns to Adopt (💡)
| Insight | Source Trace | Applicability |
|---------|-------------|---------------|
| Token count caching | Trace 001 | Apply to context engine |
| Sandbox tool execution | Trace 003 | Enhance with Docker isolation |

### Design Improvements (🔧)
| Improvement | Source Trace | Priority |
|-------------|-------------|----------|
| Make maxTokens configurable | Trace 001 | High |
| Granular error handling | Trace 003 | Medium |

### Unresolved Questions (❓)
| Question | Source Trace | Impact |
|----------|-------------|--------|
| Semantic similarity for relevance? | Trace 002 | Affects context quality |

### Risks and Concerns (⚠️)
| Concern | Source Trace | Mitigation |
|---------|-------------|------------|
| catch-all error handling | Trace 003 | Need specific error types |
```

### Step 5 — Target Domain Profile Derivation (5 axes + Scale)

Derive the **user's target project Domain Profile** by combining the source project's Detected Domain Profile (from orientation.md) with differentiation decisions accumulated across traces.

1. **Read source profile**: Extract the full Detected Domain Profile (5 axes + Scale) from `orientation.md`
2. **Analyze differentiation signals**: Scan all traces' Observations for domain-relevant changes:
   - 🔧 "Change from TUI to Web" → Axis 1 Interface change
   - 🔧 "Add streaming support" → Axis 2 Concern addition (`realtime`)
   - 💡 "Keep provider abstraction" → Axis 3 Archetype confirmation
   - 🔧 "TypeScript + React" → Axis 4 Foundation change
   - (Axis 5 Scenario is not inherited — it's determined by the user's project mode)
   - 🔧 "This should be production-grade" → Scale modifier change
3. **Build target profile**:
   - Start from source profile axes 1-4 (Scenario is always user-determined)
   - Apply differentiation: additions, removals, modifications
   - Flag uncertain items (where the user hasn't explicitly decided)
4. **Check Cross-Concern Integration**: Using the target profile's active modules, look up `_resolver.md` § Step 3.5. If any combination triggers, note the activated integration patterns.
5. **Derive Scale**: If the user expressed scale preferences in Observations, use them. Otherwise, flag as unresolved.

```markdown
## Recommended Domain Profile (target project)

> Derived from source analysis + your differentiation decisions.
> This profile will be passed to `/smart-sdd init --from-explore` to seed project setup.

| # | Axis | Source | Target | Change | Evidence |
|---|------|--------|--------|--------|----------|
| 1 | **Interfaces** | gui (TUI) | gui (Web) | Changed | 🔧 Trace 004: "Web-based UI instead of TUI" |
| 2 | **Concerns** | async-state, ipc | async-state, ipc, realtime | Added | 🔧 Trace 001: "Add streaming for LLM responses" |
| 3 | **Archetype** | ai-assistant | ai-assistant | Kept | 💡 Trace 002: "Provider abstraction pattern is solid" |
| 4 | **Foundation** | Go stdlib | — (TBD) | Changed | 🔧 Trace 004: "TypeScript + React instead of Go" |
| 5 | **Scenario** | — | greenfield | User-determined | (new project inspired by source) |

| Modifier | Source | Target | Evidence |
|----------|--------|--------|----------|
| **Project Maturity** | production | mvp | 🔧 Trace 005: "Start as MVP, scale later" |
| **Team Context** | small-team | solo | (user's current context) |

### Activated Cross-Concern Integration Rules
- `gui` + `realtime` → Real-time UI sync (S1: optimistic update + reconnection UI)
- `ai-assistant` + `realtime` → Streaming AI responses (S1: stream interruption + partial display)

### Scale Implications
- mvp + solo: Tests for critical paths only, no PR process, skip observability

### Unresolved Domain Decisions
- [ ] Foundation framework not yet chosen (React? Next.js? Electron?)
- [ ] `multi-tenancy` concern — will this be multi-user?
```

### Step 6 — Feature Candidate Derivation

Analyze the consolidated entities, APIs, module coverage, and target Domain Profile to derive Feature candidates:

1. **Module clustering**: Group related modules that frequently appear together in traces
2. **Entity ownership**: Assign entities to the Feature candidate that primarily manages them
3. **API mapping**: Map APIs to the Feature candidate that provides them
4. **Gap identification**: Note areas that haven't been explored but seem important

```markdown
## Feature Candidates

| ID | Name | Based On | Key Modules | Owned Entities | APIs | Traces |
|----|------|----------|-------------|----------------|------|--------|
| C001 | auth | Traces 001, 004 | auth/, session/ | User, Session | /api/login, /api/refresh | 001, 004 |
| C002 | context-engine | Traces 001, 002 | context/, token/ | ContextItem | — | 001, 002 |
| C003 | orders | Traces 003, 006 | orders/, payment/ | Order, Payment | /api/orders, /api/payments | 003, 006 |

### What I'd Do Differently

| Candidate | Pattern from Source | My Design |
|-----------|-------------------|-----------|
| C001 | File-based session storage | Database-backed with Redis cache |
| C002 | Hardcoded token limits | Configurable per-provider |
| C003 | No payment rollback | Saga pattern for distributed tx |
```

### Step 7 — Handoff Readiness Check

Evaluate whether the exploration is sufficient for handoff:

```markdown
## Handoff Readiness

| Criterion | Status | Detail |
|-----------|--------|--------|
| Core modules explored | ✅/⚠️ | [X]% coverage, [N] unexplored core modules |
| Entity map complete | ✅/⚠️ | [N] entities identified, [M] with incomplete fields |
| API map complete | ✅/⚠️ | [N] APIs documented |
| Domain Profile resolved | ✅/⚠️ | [N] unresolved domain decisions |
| Critical questions resolved | ✅/⚠️ | [N] unresolved ❓ items |
| Feature candidates defined | ✅/⚠️ | [N] candidates covering [X]% of traced modules |

### Recommended Next Steps
- [ ] Explore [unexplored module] — likely contains [X]
- [ ] Resolve [domain decision] before project setup
- [ ] Resolve [critical question] before defining Features
- [ ] Trace [missing flow] for complete coverage

### Ready for Handoff

**Primary flow** (recommended for building a new project inspired by source):
→ /smart-sdd init --from-explore specs/explore/
  (sets up project identity + Domain Profile, then auto-chains to add)

**Alternative flows**:
→ /smart-sdd add --from-explore specs/explore/   (skip init, add Features to existing project)
→ /reverse-spec --from-explore specs/explore/     (enhance reverse-spec with human insights)
→ /smart-sdd adopt --from-explore specs/explore/  (adopt existing code with pre-understanding)
```

### Step 8 — Write synthesis.md

Write `specs/explore/synthesis.md` with all sections from Steps 2-7.

### Step 9 — HARD STOP

Present the synthesis summary via AskUserQuestion:

- **"Ready — start project setup"** → Execute `/smart-sdd init --from-explore specs/explore/` (primary flow)
- **"Need more exploration"** → Show recommended next steps from Step 7
- **"Edit candidates"** → User adjusts Feature candidates (rename, split, merge, remove). Agent updates synthesis.md.
- **"Choose different handoff"** → Display alternative flow options

**If response is empty → re-ask** (per MANDATORY RULE).
