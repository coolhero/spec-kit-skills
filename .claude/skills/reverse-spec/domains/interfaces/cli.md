# Interface: cli (reverse-spec)

> CLI tool analysis axes. Loaded when project exposes command-line interfaces.
> Module type: interface (reverse-spec analysis)

---

## R1. Detection Signals

> See [`shared/domains/interfaces/cli.md`](../../../shared/domains/interfaces/cli.md) § Code Patterns

## R3. Analysis Axes — CLI Command Extraction

For each CLI command/subcommand, extract:
- Command name, aliases
- Arguments (positional) and flags (named)
- Help text / description
- Exit codes and their meanings
- Output format (stdout, stderr, file)

Detection patterns by tech stack:

| Technology | Search Targets |
|------------|----------------|
| Node.js (Commander/yargs) | `program.command()`, `.option()`, `.action()` |
| Python (click/argparse) | `@click.command()`, `add_argument()`, `add_subparser()` |
| Go (cobra) | `&cobra.Command{}`, `AddCommand()` |
| Rust (clap) | `#[derive(Parser)]`, `#[command()]`, `#[arg()]` |
