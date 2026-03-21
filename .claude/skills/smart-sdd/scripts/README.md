# Helper Scripts

> Bash utilities used internally by smart-sdd commands. Can also be invoked manually for diagnostics.

| Script | Purpose | Usage |
|--------|---------|-------|
| `validate.sh` | Validate sdd-state.md format and required fields | `bash scripts/validate.sh specs/_global/sdd-state.md` |
| `sbi-coverage.sh` | Calculate SBI → FR coverage per Feature | `bash scripts/sbi-coverage.sh specs/` |
| `pipeline-status.sh` | Display pipeline progress (all Features) | `bash scripts/pipeline-status.sh specs/_global/sdd-state.md` |
| `demo-status.sh` | Check demo scripts exist and are executable | `bash scripts/demo-status.sh demos/` |
| `context-summary.sh` | Print context window usage summary | `bash scripts/context-summary.sh` |
| `semantic-stub-check.sh` | Detect placeholder code (Math.random, TODO, lorem ipsum) | `bash scripts/semantic-stub-check.sh src/` |
| `wiring-check.sh` | Verify IPC/API wiring integrity (all declared channels have implementations) | `bash scripts/wiring-check.sh src/` |

## Internal Usage

These scripts are invoked by smart-sdd commands:
- `validate.sh` → `commands/pipeline.md` (Pipeline Initialization)
- `sbi-coverage.sh` → `commands/coverage.md`
- `pipeline-status.sh` → `commands/status.md`
- `demo-status.sh` → `commands/verify-phases.md` (Phase 4)
- `semantic-stub-check.sh` → `commands/verify-phases.md` (Phase 2)
- `wiring-check.sh` → `reference/injection/implement.md` (App Lifecycle Wiring Check)
