# Scenario Catalog — spec-kit-skills

> Find your situation, follow the flow. For Korean version, see [SCENARIO-CATALOG.ko.md](SCENARIO-CATALOG.ko.md).
> Used as a verification checklist during full-file reviews (see CLAUDE.md § Review Protocol, Check 13).

---

## A. Understand Code

> 💡 "I want to understand how this codebase works"

| ID | When you want to... | Do this | You get |
|----|-------------------|---------|---------|
| SA01 | Understand the full architecture of an unfamiliar project | Run `code-explore [path]`, then `trace` the flows you're curious about, then `synthesis` when ready | Architecture map + flow documentation |
| SA02 | Focus on a specific area (e.g., auth module, a buggy component) | Add `--scope src/auth` to limit analysis. Works for learning, debugging, or mid-pipeline investigation. Add `--no-branch` if you're already on a feature branch | Focused analysis of that area |
| SA03 | Compare two projects' architectures | Run `code-explore A` then `code-explore B` — synthesis auto-activates comparison mode | Side-by-side comparison table |
| SA04 | Go deeper after adopt or pipeline (with existing SDD docs) | Just run `code-explore .` — Context-Aware mode activates automatically when SDD artifacts exist, cross-referencing your specs and registries | Analysis enriched by existing SDD context |
| SA05 | Audit code for security or performance concerns | Run `code-explore .` and trace auth/crypto/performance flows — use 🔒📊 observation icons | Observation catalog by concern |
| SA06 | Learn/onboard an existing project without generating Feature candidates | Run `code-explore [path] --learn` — read-only mode, no Feature candidates, outputs to `specs/explore/learn/` | Architecture summary + existing Feature understanding map |

## B. Start a New Project

> 💡 "I have an idea or requirements, and want to build from scratch"

| ID | When you want to... | Do this | You get |
|----|-------------------|---------|---------|
| SB01 | Start from just an idea | `init "build a chat app"` — one line is enough. `add` and `pipeline` chain automatically | Fully implemented project with Features |
| SB02 | Build something inspired by an existing project | `code-explore A` first to study it, then `init B --from-explore` → add → pipeline | New project informed by A's architecture |
| SB03 | Start from a requirements doc or spec file | `init spec.md` or `add requirements.md "add auth"` — pass files and text in any combination. YAML, JSON, PDF also accepted | Features extracted from your documents |
| SB04 | Build only specific Features or just the MVP | `pipeline F003` (one Feature) or `pipeline --tier 1` (core Features only) | Only what you selected gets built |
| SB05 | Resume an interrupted pipeline or start over | `pipeline --continue` (resume) or delete specs/ → `init` (fresh start) | Continuation or clean slate |

## C. Apply SDD to Existing Code

> 💡 "I have working code and want to wrap it with SDD documentation"

| ID | When you want to... | Do this | You get |
|----|-------------------|---------|---------|
| SC01 | Document existing code with SDD | `adopt --lang ko` — reverse-spec runs automatically first. Your code is not modified | All Features documented (adopted status) |
| SC02 | Add new features after documenting | `adopt` → `add "new feature"` → `pipeline` — optionally use `code-explore` in between for deeper understanding | Existing code preserved + new Feature built |
| SC03 | Fix bugs or design issues systematically | `adopt` → `pipeline` | Existing Features' issues fixed through SDD process |
| SC04 | Document only one service in a monorepo | `adopt --scope services/api` — repeat per service as needed | Per-service independent SDD docs |
| SC05 | Modernize legacy code | `adopt` → identify migration targets → `pipeline --migration` | Modernization plan + step-by-step execution |

## D. Rewrite from Scratch

> 💡 "I want to analyze existing code and rewrite it completely"

| ID | When you want to... | Do this | You get |
|----|-------------------|---------|---------|
| SD01 | Rewrite (same or different tech stack) | `reverse-spec .` → `init --from-reverse-spec` (with review) or `pipeline` (direct) — to change stacks, add `init --stack new` in between | Cleanly rewritten code |
| SD02 | Study the code deeply before rewriting | `code-explore` first → `reverse-spec --from-explore` → `pipeline` | Informed rewrite based on deep understanding |
| SD03 | Rewrite only core Features, or into a separate directory | `reverse-spec` → `pipeline --tier 1` (core only) or run `reverse-spec A` from directory B (separate project) | Selective rewrite |

## E. Revise and Iterate

> 💡 "I want to fix, improve, or add to what I've already built"

| ID | When you want to... | Do this | You get |
|----|-------------------|---------|---------|
| SE01 | Go back to an earlier pipeline step | At any HARD STOP, choose "Reject" or "back to ..." — you can go back from any step to any earlier step | Revised result incorporating your feedback |
| SE02 | Re-verify after fixing a bug | Fix the bug → `pipeline F001 --start verify` | Bug fixed + verify passes |
| SE03 | Reopen a completed Feature for improvement | `pipeline F001 --step specify` — reopens from that step | Feature reopened for rework |
| SE04 | Add new requirements to an existing Feature | `add --to F001 "add OAuth"` or `add --to F001 requirements.md` — text and files both work, can be mixed. Then `pipeline F001` to re-specify | Existing SCs preserved + new SCs added |
| SE05 | Split a Feature that's too big, or merge overlapping Features | Split: decide during `add`. Merge: `pipeline merge F003 F004` | Right-sized Features |
| SE06 | Generate only specs/plans without implementation | `pipeline F001 --step specify,plan` — pick the steps you want | spec.md + plan.md (no code) |

## F. Manage Multiple Features

> 💡 "I need to coordinate ordering and dependencies across Features"

| ID | When you want to... | Do this | You get |
|----|-------------------|---------|---------|
| SF01 | Handle Feature dependencies (F002 needs F001) | `pipeline F001` first → then `pipeline F002` — if independent, order doesn't matter | Correct dependency ordering |
| SF02 | Revisit an earlier Feature after completing later ones | `pipeline F001 --step specify` — creates a fresh branch from main for rework | Previous Feature reopened |

## G. Check Status

> 💡 "I want to see where things stand"

| ID | When you want to... | Do this | You get |
|----|-------------------|---------|---------|
| SG01 | See overall progress | `status` (pipeline) or `code-explore status` (exploration) | Progress dashboard |
| SG02 | Check spec-code alignment or coverage | `parity` (spec vs code) or `coverage` (SBI coverage) | Alignment/coverage report |

## H. Advanced & Customization

> 💡 "I have a special project type, need custom domain rules, or want org-wide conventions"

| ID | When you want to... | Do this | You get |
|----|-------------------|---------|---------|
| SH01 | Build a plugin or extension | `init --profile sdk-library` → add → pipeline | Plugin with extension points |
| SH02 | Modernize legacy code | `adopt` → `pipeline --migration` | Modernized codebase |
| SH03 | Generate all artifacts in a specific language | `init --lang ko` or `adopt --lang ja` | All artifacts in your language |
| SH04 | Apply SDD per service in a monorepo | `adopt --scope services/api` per service | Per-service SDD docs |
| SH05 | See what domain modules are available | `domain-extend browse` or `domain-extend browse concerns` | Full module inventory with file paths |
| SH06 | My project uses a pattern no module covers | `domain-extend detect` → `domain-extend extend concern "video-encoding"` | New concern module in `specs/domains/` (project-local by default) |
| SH07 | Import team ADRs/style guides as domain rules | `domain-extend import ./docs/adr/` | ADRs converted to S1/S7 rules in modules |
| SH08 | Set org-wide coding conventions | `domain-extend customize org` | org-convention.md applied to all projects |
| SH09 | code-explore found uncovered patterns | `domain-extend detect --from-explore ./specs/explore/` → `extend` | New modules from exploration gaps |
| SH10 | Validate custom modules before using in pipeline | `domain-extend validate` | Validation report: schema compliance, taxonomy sync, cross-concern rules |

---

## Summary

| Category | Count |
|----------|-------|
| A: Understand Code | 6 |
| B: Start New Project | 5 |
| C: Apply SDD to Existing Code | 5 |
| D: Rewrite from Scratch | 3 |
| E: Revise and Iterate | 6 |
| F: Manage Multiple Features | 2 |
| G: Check Status | 2 |
| H: Advanced & Customization | 10 |
| **Total** | **39** |

---

## Changelog

| Date | Change |
|------|--------|
| 2026-03-22 | Initial creation |
| 2026-03-22 | Consolidated similar scenarios (59 → 32), user-friendly descriptions |
