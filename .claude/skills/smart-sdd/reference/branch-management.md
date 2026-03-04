# Git Branch Management

> Reference: Read when performing git branch operations during pipeline execution.
> For per-step workflow details, see `commands/pipeline.md`.

Branch management details (Branch Lifecycle, Pre-Flight Check, During Feature Development, Post-Feature Merge with Verify-Success Gate, Step Mode Branch Handling) are included in `commands/pipeline.md` under the "Git Branch Management" section.

This file documents the Non-Git Projects policy, which applies to all commands (not just pipeline).

---

## Non-Git Projects

If the project directory is not a git repository:
- Skip all branch management (pre-flight, validation, merge)
- Display a one-time notice: "No git repository detected. Branch management is disabled."
- All other smart-sdd functionality works normally
