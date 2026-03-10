# Domain Profile: app (Backward Compatibility Shim)

> **This file is a backward-compatibility shim.** When `--domain app` is used or `**Domain**: app` is found in sdd-state.md, the resolver automatically expands to the `fullstack-web` profile.
>
> For the actual domain modules, see:
> - `_core.md` — Universal rules (always loaded)
> - `interfaces/` — Interface-specific modules (http-api, gui, cli, data-io)
> - `concerns/` — Concern-specific modules (async-state, ipc, external-sdk, i18n, realtime, auth)
> - `scenarios/` — Scenario-specific modules (greenfield, rebuild, incremental, adoption)
> - `profiles/` — Preset compositions (web-api, desktop-app, fullstack-web, cli-tool)

## Expansion

`--domain app` expands to:

```
**Domain Profile**: fullstack-web
**Interfaces**: http-api, gui
**Concerns**: async-state, auth, i18n
```

This is equivalent to `--profile fullstack-web`.

## Migration

When `sdd-state.md` contains the old format:
```
**Domain**: app
```

The resolver (`_resolver.md`) automatically:
1. Reads this shim to determine the default expansion
2. Writes the expanded Domain Profile fields to sdd-state.md (one-time migration)
3. Proceeds with normal module loading

After migration, the expanded fields look like:
```
**Domain Profile**: fullstack-web
**Interfaces**: http-api, gui
**Concerns**: async-state, auth, i18n
**Scenario**: <determined by Origin field>
**Custom**: none
```
