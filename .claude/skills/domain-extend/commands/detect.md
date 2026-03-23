# Detect — Domain Gap Analysis

> Reference: Read after `/domain-extend detect` is invoked.

## Purpose

Analyze code, explore artifacts, or current Domain Profile to identify patterns not covered by existing modules. Produces a structured gap report with actionable suggestions.

---

## Detection Modes

### Mode 1: Profile Gap Analysis (no arguments)

**Trigger**: `/domain-extend detect`

**Steps**:

1. Read `specs/_global/sdd-state.md`
   - If not found → display: `No sdd-state.md found. Run /smart-sdd init first.` → exit
2. Extract Domain Profile → list active modules per axis
3. For each active module, verify the file exists in `shared/domains/{axis}/`
   - Missing file → report as **MISSING** (module referenced but file absent)
4. Check cross-concern integration:
   - For each pair of active modules, check `_taxonomy.md` Common Pairings
   - If a common pairing exists but the paired module is NOT in the active profile → report as **UNCOVERED PAIRING**
5. Check for axis gaps:
   - No Interface module → **CRITICAL GAP** (every project needs at least one)
   - No Archetype module → **WARNING** (optional but recommended)
   - No Concern modules → **INFO** (simple projects may not need them)
6. Display gap report (see § Gap Report Format below)
7. Ask via AskUserQuestion:
   - **"Fix gaps"** → suggest commands for each gap
   - **"Ignore — profile is intentional"** → exit
   - **"Browse missing modules"** → chain to `/domain-extend browse`

**If response is empty → re-ask** (per MANDATORY RULE 1)

**Manual alternative**: Open `sdd-state.md`, check each listed module file exists, review `_taxonomy.md` pairings.

---

### Mode 2: Code Scan (detect /path/to/code)

**Trigger**: `/domain-extend detect /path/to/code` or `/domain-extend detect .`

**Steps**:

1. Scan the target directory for domain signals:
   - **S0 keywords**: Read all module files → collect S0 Primary + Secondary keywords → grep codebase for matches
   - **R1 code patterns**: Read all module files → collect R1 patterns → grep codebase for matches
   - **Dependency files**: Read `package.json`, `go.mod`, `Cargo.toml`, `pyproject.toml`, etc. → match against module keywords
2. Build a coverage matrix:

   For each module with at least one match:
   - Count S0 keyword hits
   - Count R1 pattern hits
   - Calculate similarity score: `(S0_hits * 2 + R1_hits) / (total_S0_keywords * 2 + total_R1_patterns) * 100`

3. Classify each module match:
   - **Covered** (similarity >= 60%): Module exists and strongly matches codebase patterns
   - **Partially covered** (20% <= similarity < 60%): Some patterns match but module may be incomplete
   - **Uncovered** (similarity < 20% but > 0 hits): Faint signal — worth investigating
4. Identify **unmatched patterns**:
   - Codebase patterns that don't match ANY module's S0/R1 keywords
   - Group by category (framework-specific, domain-specific, infrastructure)
5. If `sdd-state.md` exists, compare scan results against active profile:
   - Active module with no code matches → **OVER-SPECIFIED** (module loaded but no code uses it)
   - Code patterns with no active module → **UNDER-SPECIFIED** (code exists but no module loaded)
6. Display gap report (see § Gap Report Format below)
7. Ask via AskUserQuestion:
   - **"Create module for [gap]"** → chain to `/domain-extend extend {axis}/{name}`
   - **"Add [module] to profile"** → suggest sdd-state.md edit
   - **"Scan a different path"** → re-run with new target
   - **"Done"** → exit

**If response is empty → re-ask** (per MANDATORY RULE 1)

**Manual alternative**: `grep -rl "keyword" /path/to/code` for each module's S0 keywords, then compare manually.

---

### Mode 3: Explore-Informed (detect --from-explore <path>)

**Trigger**: `/domain-extend detect --from-explore specs/explore` or `/domain-extend detect --from-explore .`

**Steps**:

1. Read explore artifacts:
   - `specs/explore/orientation.md` → extract Detected Domain Profile (5 axes), Module Map, Concurrency Model
   - `specs/explore/synthesis.md` (if exists) → extract Feature Candidates, Recommended Domain Profile
   - `specs/explore/traces/*.md` → extract observation icons and patterns
2. For each detected axis value in the explore profile:
   - Check if a matching module exists in `shared/domains/`
   - If no exact match → compute similarity against all modules in that axis (by S0 keywords)
3. Extract unmatched patterns from traces:
   - Collect all observation lines from traces
   - Cross-reference against module S0/R1 keywords
   - Patterns not covered by any module → report as **EXPLORE GAP**
4. Compare explore's Recommended Domain Profile against available modules:
   - Each recommended module should exist as a file
   - Missing modules → actionable gaps
5. Display gap report (see § Gap Report Format below)
6. Ask via AskUserQuestion:
   - **"Create module for [gap]"** → chain to `/domain-extend extend`
   - **"Import from explore traces"** → chain to `/domain-extend import` with trace excerpts
   - **"Done"** → exit

**If response is empty → re-ask** (per MANDATORY RULE 1)

**Manual alternative**: Open `orientation.md` § Detected Domain Profile, then check each value against `ls shared/domains/{axis}/`.

---

## Gap Report Format

All detection modes produce a report with the same structure:

```
Domain Gap Analysis Report
Source: {mode description}
Date: {timestamp}

## Coverage Summary

| Status | Count |
|--------|-------|
| Covered | {N} modules fully match |
| Partially Covered | {N} modules partially match |
| Uncovered Gaps | {N} patterns with no module |
| Over-specified | {N} loaded modules with no code match |

## Covered Modules

| Module | Axis | Similarity | Evidence |
|--------|------|-----------|----------|
| auth | Concern | 85% | JWT middleware, OAuth config, session store |
| gui | Interface | 72% | React components, CSS modules, router |

## Partially Covered

| Module | Axis | Similarity | Matched | Missing |
|--------|------|-----------|---------|---------|
| realtime | Concern | 35% | WebSocket setup | SSE, live-query patterns |

## Uncovered Gaps

| # | Pattern | Source Evidence | Closest Module | Similarity | Suggested Action |
|---|---------|---------------|----------------|-----------|-----------------|
| 1 | Rate limiting middleware | src/middleware/rate-limit.ts | resilience | 15% | /domain-extend extend concerns/rate-limiting |
| 2 | PDF generation pipeline | src/services/pdf/ | (none) | 0% | /domain-extend extend concerns/document-generation |

## Over-specified (if applicable)

| Module | Axis | Loaded In Profile | Code Evidence |
|--------|------|-------------------|---------------|
| i18n | Concern | Yes | No i18n files found |

## Suggested Commands

1. `/domain-extend extend concerns/rate-limiting` — New module for rate limiting patterns
2. `/domain-extend browse resilience` — Review closest existing module before creating new
3. Edit sdd-state.md → remove i18n from active profile (no code evidence)
```

---

## Similarity Matching

Similarity between a codebase pattern and a module is calculated as:

1. **S0 keyword match** (weight: 2x): How many of the module's S0 Primary/Secondary keywords appear in the codebase
2. **R1 code pattern match** (weight: 1x): How many of the module's R1 patterns appear in the codebase
3. **Formula**: `(matched_S0 * 2 + matched_R1) / (total_S0 * 2 + total_R1) * 100`

This is a heuristic, not a precise metric. Always present results as guidance, not as definitive classification. The user decides whether a gap needs filling.
