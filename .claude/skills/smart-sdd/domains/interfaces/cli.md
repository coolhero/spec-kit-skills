# Interface: cli

> Command-line interface tools. Applies when the project exposes CLI commands.
> Module type: interface

---

## S0. Signal Keywords

> Keywords that indicate this module should be activated. Used by Clarity Index signal extraction.

**Primary**: CLI, command line, terminal tool, shell script, flags, arguments, Commander, yargs, clap, Click, Cobra, subcommands
**Secondary**: interactive prompt, progress bar, piping, stdin, stdout, REPL

---

## S1. SC Generation Rules

### Required SC Patterns
- Every command: exit code (0 for success, non-zero for error) + stdout content verification
- Error scenarios: specific exit code + stderr message format
- Help/usage: `--help` flag produces usage text with command list

### SC Anti-Patterns (reject)
- "Command succeeds" — must specify exit code + output content
- "Error is reported" — must specify exit code + error message pattern

### SC Measurability Criteria
- Execution time threshold (if specified in requirements)
- Output format compliance (JSON, table, plain text)

---

## S1. Demo Pattern (override)

- **Type**: Script-based (not server-based)
- **Default mode**: Run key commands with sample data -> print output -> exit
- **CI mode**: Run health check command -> verify exit 0
- **"Try it" instructions**: CLI commands to run with example arguments

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| **Command structure** | Subcommands? Global flags? Argument validation? |
| **Output format** | JSON? Table? Plain text? Machine-readable option? |
| **Configuration** | Config file? Environment variables? Defaults? |

---

## S8. Runtime Verification Strategy

> Cross-references [reference/runtime-verification.md](../../reference/runtime-verification.md) § 6c.

| Field | Value |
|-------|-------|
| **Start method** | N/A — CLI tools are per-invocation (no persistent process) |
| **Verify method** | Execute CLI commands with test arguments → verify stdout/stderr content + exit codes. Backend: Process runner (shell execution) |
| **Stop method** | N/A — each invocation terminates naturally |
| **SC classification extensions** | `cli-auto` — CLI command SCs verifiable via process execution without external dependencies |

**CLI-specific verification**:
- Step 3d Interactive Runtime Verification: group `cli-auto` SCs by command → execute with test args → verify stdout/stderr/exit code
- `--help` flag verification: every registered command produces usage text
- Error scenario verification: invalid args → non-zero exit code + descriptive stderr
