# Verify Report — [FID]-[Feature Name]

> Generated at verify completion. This report is the evidence that the Feature meets its Spec contract.
> Status: [PASS | FAIL | PARTIAL]

---

## Summary

| Metric | Result |
|--------|--------|
| Feature | [FID]-[name] |
| Spec SCs | [total] defined |
| SCs Verified | [passed]/[total] |
| Build | [PASS/FAIL] |
| Tests | [passed]/[total] tests |
| Lint | [PASS/FAIL] |
| Runtime Verified | [Yes/No] |
| Demo Executed | [Yes/No] |
| Cross-Feature | [PASS/FAIL/N/A] |
| **Overall** | **[PASS/FAIL/PARTIAL]** |

---

## Phase 1: Build + Test + Lint

| Check | Result | Details |
|-------|--------|---------|
| Build | | `npm run build` output |
| TypeScript | | `npx tsc --noEmit` output |
| Lint | | `npm run lint` output |
| Unit Tests | | [N]/[N] passed |

---

## Phase 2: Cross-Feature Integration

| Check | Result | Details |
|-------|--------|---------|
| Entity Registry Consistency | | All entities match registry definitions |
| API Contract Compatibility | | Consumer Features' expectations met |
| Dependency Stubs Resolved | | All stubs from preceding Features replaced |

---

## Phase 3: SC Runtime Verification

> Application started on [host:port]. Database: [status]. Redis: [status].

> **Method column**: MUST be one of: `runtime` (with specific command/action) or `RUNTIME_BLOCKED (reason)`. "Unit test" is NOT a valid Phase 3 method — unit tests belong to Phase 1.

| SC | Description | Method | Expected | Actual | Result |
|----|-------------|--------|----------|--------|--------|
| SC-001 | Login | runtime: curl POST /auth/login | 200 + session | 200 + session | ✅ |
| SC-002 | Data list | runtime: GET /api/items | 200 + array | 200 + array | ✅ |
| SC-007 | Cross-tenant | RUNTIME_BLOCKED: single org in seed | 403 | — | ⚠️ manual |

### Failed SCs (if any)

| SC | Failure Reason | Severity | Action |
|----|---------------|----------|--------|
| | | Minor/Major-Implement/Major-Plan/Major-Spec | |

---

## Phase 4: Demo Execution

| Demo | Command | Exit Code | Result |
|------|---------|-----------|--------|
| CI mode | `demos/F00N-name.sh --ci` | | ✅/❌ |
| Interactive | `demos/F00N-name.sh` | | ✅/❌ |

---

## Evidence Log

> Key evidence captured during verification (screenshots, curl outputs, log excerpts).

---

## Decision

- [ ] **READY FOR MERGE** — All SCs verified, demo passes, no blocking issues
- [ ] **NEEDS FIX** — [N] SCs failed, returning to [implement/plan/specify]
- [ ] **BLOCKED** — Cannot verify due to [infrastructure/dependency/other]

---

*Generated: [timestamp]*
*Verified by: Claude Code (automated) + [user] (approved)*
