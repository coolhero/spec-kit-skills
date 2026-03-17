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

### Step 5 — Feature Candidate Derivation

Analyze the consolidated entities, APIs, and module coverage to derive Feature candidates:

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

### Step 6 — Handoff Readiness Check

Evaluate whether the exploration is sufficient for handoff:

```markdown
## Handoff Readiness

| Criterion | Status | Detail |
|-----------|--------|--------|
| Core modules explored | ✅/⚠️ | [X]% coverage, [N] unexplored core modules |
| Entity map complete | ✅/⚠️ | [N] entities identified, [M] with incomplete fields |
| API map complete | ✅/⚠️ | [N] APIs documented |
| Critical questions resolved | ✅/⚠️ | [N] unresolved ❓ items |
| Feature candidates defined | ✅/⚠️ | [N] candidates covering [X]% of traced modules |

### Recommended Next Steps
- [ ] Explore [unexplored module] — likely contains [X]
- [ ] Resolve [critical question] before defining Features
- [ ] Trace [missing flow] for complete coverage

### Ready for Handoff
→ /reverse-spec --from-explore     (entities + APIs seed registries)
→ /smart-sdd add --from-explore    (candidates → Brief input)
→ /smart-sdd adopt --from-explore  (candidates + traces → adoption)
```

### Step 7 — Write synthesis.md

Write `specs/explore/synthesis.md` with all sections from Steps 2-6.

### Step 8 — HARD STOP

Present the synthesis summary via AskUserQuestion:

- **"Ready for handoff"** → Display the three handoff options and let user choose
- **"Need more exploration"** → Show recommended next steps from Step 6
- **"Edit candidates"** → User adjusts Feature candidates (rename, split, merge, remove). Agent updates synthesis.md.

**If response is empty → re-ask** (per MANDATORY RULE).
