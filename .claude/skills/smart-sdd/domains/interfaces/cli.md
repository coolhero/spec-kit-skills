# Interface: cli

> Command-line interface tools. Applies when the project exposes CLI commands.
> Module type: interface

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
