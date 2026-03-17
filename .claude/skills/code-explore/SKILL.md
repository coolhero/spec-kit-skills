# code-explore

> Interactive source code exploration skill that produces documented understanding — traces, entity maps, and flow diagrams — feeding directly into spec-kit SDD workflows.

## When to Use

- User wants to **understand** an existing codebase before building something
- User wants to study an open-source project to learn patterns
- User needs source-level flow tracing with persistent documentation
- User wants to transition from "understanding code" to "defining specs"

## Commands

| Command | Purpose |
|---------|---------|
| `/code-explore [path]` | Scan a codebase and generate an orientation map |
| `/code-explore trace "topic"` | Trace a specific flow end-to-end with source-level detail |
| `/code-explore synthesis` | Aggregate traces into Feature candidates for spec-kit handoff |
| `/code-explore status` | Show exploration coverage and trace index |

## Command Routing

```
/code-explore [path]         → Read commands/orient.md
/code-explore trace "..."    → Read commands/trace.md
/code-explore synthesis      → Read commands/synthesis.md
/code-explore status         → Read commands/status.md
```

## Artifact Output Path

All artifacts are written to `specs/explore/` relative to CWD:

```
specs/explore/
├── orientation.md           # Project architecture map + exploration coverage
├── traces/
│   ├── 001-context-assembly.md
│   ├── 002-priority-scoring.md
│   └── ...                  # One file per traced flow
└── synthesis.md             # Feature candidates + handoff preparation
```

## Connection to Other Skills

```
code-explore (understand)
    │
    ├──→ /reverse-spec --from-explore   (structured extraction)
    ├──→ /smart-sdd add --from-explore  (Feature definition)
    └──→ /smart-sdd adopt --from-explore (adoption with pre-understanding)
```

Traces produce structured observations (entities, APIs, business rules) in formats compatible with reverse-spec and smart-sdd artifacts. The synthesis command aggregates these into Feature candidates ready for handoff.

## Status

🚧 **Under Development** — Skill structure created. Command implementations pending.
