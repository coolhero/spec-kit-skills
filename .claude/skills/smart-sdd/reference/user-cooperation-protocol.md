# User Cooperation Protocol

> Standardized pattern for detecting when user assistance is needed, requesting it,
> verifying the result, and proceeding.
> This file defines the canonical taxonomy and flow. It does NOT replace inline HARD STOP text
> (per CLAUDE.md Rule 1 — "If response is empty → re-ask" must stay inlined at every call site).
> Referenced by: `commands/verify-phases.md`, `injection/implement.md`, `commands/pipeline.md`, `domains/scenarios/rebuild.md`.

---

## 1. Cooperation Categories

| Category | When Needed | Examples | Detection Method |
|----------|-------------|----------|------------------|
| **Environment Setup** | Missing tools, dependencies, or build prerequisites | Playwright CLI not installed, MCP not configured, native deps missing | Version check (`npx ... --version`), file existence |
| **Runtime Dependencies** | External services needed at runtime for verification | AI model server, database, message broker, third-party API | Network probe (`curl` with timeout), process check |
| **Manual Verification** | Automation cannot evaluate the criterion | Visual quality, UX judgment, subjective criteria, accessibility feel | SC classified as `manual` |
| **Configuration** | One-time setup that persists across sessions | CDP endpoint config, MCP plugin config, source path in sdd-state.md | State file check, config file scan |
| **External Services** | Third-party credentials or tokens needed | API keys in `.env`, OAuth tokens, webhook endpoints | `.env` presence check, endpoint probe |
| **Source App Access** | Original app needed for comparison (rebuild mode) | Side-by-side layout comparison, behavioral parity check | Source Path in sdd-state.md + runtime probe |

---

## 2. Canonical Flow

Every user cooperation point across the pipeline follows this 6-step procedure:

```
PROCEDURE UserCooperation(category, context):

  Step 1 — DETECT:
    Run automated probe/check to identify the need.
    Examples: version check, file existence, network probe, env scan.

  Step 2 — CLASSIFY:
    Match the need to a cooperation category (table above).
    This determines the urgency and options to present.

  Step 3 — DIAGNOSE:
    Provide actionable information to the user:
    - WHAT is missing/needed (specific tool, service, credential)
    - WHY it's needed (which pipeline step, which Feature, which SC)
    - HOW to fix it (specific commands, not vague instructions)
    Display the diagnostic before requesting action.

  Step 4 — REQUEST:
    Use AskUserQuestion with options:
    - Action option: "I've done it" / "Install now" / "Environment ready"
    - Skip option: "Skip — proceed without" / "Continue with limitation"
    - Alternative option (if applicable): "Use CLI instead of MCP" / "Use mock data"
    **If response is empty → re-ask** (per MANDATORY RULE 1)

  Step 5 — VERIFY:
    After user confirms the action option:
    - Re-run the detection probe from Step 1
    - If STILL not ready → inform user what's still missing, loop back to Step 4
    - If ready → proceed to Step 6
    Maximum 3 retry loops — after 3 failures, offer skip option.

  Step 6 — RECORD:
    Write the result to the appropriate state file:
    - sdd-state.md: RUNTIME_BACKEND, toolchain status, user choices
    - Feature Detail Log: per-Feature cooperation results
    Record: what was needed, what the user chose, timestamp.
    Downstream steps read this record — do NOT re-detect or re-ask.
```

---

## 3. `user-assisted` SC Category

### Definition

A Success Criterion that CAN be automatically verified, but ONLY after the user provides a dependency that the agent cannot obtain on its own.

| Distinction | `user-assisted` | `external-dep` |
|------------|----------------|-----------------|
| **Can user provide locally?** | YES — API key in .env, local model start, manual service start | NO — production-only API, specific hardware, rate-limited external service |
| **Verification after preparation** | Automated (same as `cdp-auto`/`api-auto`/`cli-auto`) | Skipped entirely |
| **User interaction** | One-time preparation request, then automated | No automated verification possible |

### Detection Criteria

Classify an SC as `user-assisted` (not `external-dep`) when:
- The dependency is an API key that the user likely has (OpenAI, Anthropic, Stripe test keys)
- The dependency is a local service the user can start (database, model server, dev server)
- The dependency is a configuration the user can provide (webhook URL, test account)

Classify as `external-dep` when:
- The dependency requires a production environment (live payment processor, production database)
- The dependency requires specific hardware (GPU, IoT device, specific OS)
- The dependency is rate-limited and testing would consume quota

### Verification Flow

```
1. During SC classification (verify Phase 3 Step 0):
   - Identify SCs with dependencies that match `user-assisted` criteria
   - Mark as `user-assisted` in SC Verification Matrix with specific preparation needed

2. During Interactive Runtime Verification (verify Phase 3 Step 3d):
   - BATCH all user-assisted SCs into a single cooperation request:

     📋 User-Assisted Verification for [FID]:
       SC-023: Requires OPENAI_API_KEY in .env
       SC-031: Requires MCP server running on localhost:3001
       SC-045: Requires test Stripe key in .env

     Please prepare these dependencies, then confirm.

   - AskUserQuestion:
     - "Dependencies ready — proceed with verification"
     - "Skip user-assisted SCs"
   **If response is empty → re-ask** (per MANDATORY RULE 1)

3. If "Dependencies ready":
   - Re-verify each dependency (probe API key presence, service endpoint, etc.)
   - For verified dependencies → run automated verification (same as cdp-auto/api-auto)
   - For still-missing dependencies → report as skipped with reason

4. If "Skip":
   - Record all user-assisted SCs as `⚠️ user-assisted — skipped (user chose to skip)`
```

---

## 4. Cross-Reference: Cooperation Points Across Pipeline

All existing and new cooperation points, organized by pipeline stage. Each follows the Canonical Flow (§2).

### Pipeline Initialization

| Point | File | Category | Detection |
|-------|------|----------|-----------|
| Source Path Verification | `commands/pipeline.md` Step 2 | Configuration | sdd-state.md Source Path field |
| Foundation Gate checks | `commands/pipeline.md` Step 3b | Environment Setup | CSS/state/IPC/layout smoke test |
| Per-Feature env vars | `commands/pipeline.md` Per-Feature | External Services | `.env` scan for required variables |

### Implement

| Point | File | Category | Detection |
|-------|------|----------|-----------|
| Package dependency | `injection/implement.md` § Deps | Environment Setup | `npm ls` / import check |
| UI component library | `injection/implement.md` § UI | Environment Setup | Component existence check |
| Runtime degradation | `injection/implement.md` § MCP | Environment Setup | `RUNTIME_BACKEND` check (see `runtime-verification.md`) |
| Runtime Error Zero Gate | `injection/implement.md` § Error | Runtime Dependencies | Auto-fix loop → user fallback |

### Verify

| Point | File | Category | Detection |
|-------|------|----------|-----------|
| Runtime Backend Pre-flight | `commands/verify-phases.md` Pre-flight | Environment Setup | Multi-backend detection (see `runtime-verification.md` §3) |
| CDP not configured (Case A) | `commands/verify-phases.md` Phase 3 Step 3 | Configuration | `browser_snapshot` returns default page |
| Lint tool not found | `commands/verify-phases.md` Phase 1 Step 3b | Environment Setup | Lint command not found error |
| User-assisted SCs | `commands/verify-phases.md` Phase 3 Step 3d | External Services | SC classified as `user-assisted` |
| User-assisted SC gate | `commands/verify-phases.md` Phase 3 Step 3f | External Services | Unresolved `user-assisted` SCs before Step 4 (BLOCKING gate) |
| Source app needed | `commands/verify-phases.md` Phase 3 Step 3e | Source App Access | Rebuild mode + `source_available: running` |
| Runtime degradation recovery | `commands/verify-phases.md` Phase 3 Step 3 | Configuration | `⚠️ RUNTIME-DEGRADED` marker |

### Reverse-Spec

| Point | File | Category | Detection |
|-------|------|----------|-----------|
| MCP availability | `reverse-spec/commands/analyze.md` Phase 1.5 | Environment Setup | Playwright MCP probe |
| Environment readiness | `reverse-spec/commands/analyze.md` Phase 1.5 | Runtime Dependencies | Infrastructure services check |
| App initial setup | `reverse-spec/commands/analyze.md` Phase 1.5 | Configuration | First-run setup steps |
| Crash recovery | `reverse-spec/commands/analyze.md` Phase 1.5 | Runtime Dependencies | App process crash detection |

### Parity

| Point | File | Category | Detection |
|-------|------|----------|-----------|
| Gap remediation | `commands/parity.md` Phase 4 | Manual Verification | Per-gap-group decision |
| Source path resolution | `commands/parity.md` § Source | Configuration | sdd-state.md Source Path |
