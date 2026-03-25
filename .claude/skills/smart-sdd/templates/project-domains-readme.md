# Project Domain Modules

Custom domain modules for this project. Created by `/domain-extend extend` or `/domain-extend import`.

## Structure
- `concerns/` — Project-specific concern modules
- `archetypes/` — Project-specific archetype modules
- `interfaces/` — Project-specific interface modules
- `foundations/` — Project-specific foundation modules
- `contexts/modifiers/` — Project-specific context modifiers
- `profiles/` — Project-specific profile presets
- `domain-custom.md` — Project-level rule overrides

## How it works
The resolver loads built-in modules first, then merges project-local modules on top.
A project module with the same name as a built-in module extends it (append semantics).
A project module with a new name is loaded as a new module.

## Created by
`/domain-extend extend`, `/domain-extend import`, or manual creation following `_schema.md`.
