# Domain Profile: app (Backward Compatibility Shim)

> **This file is a backward-compatibility shim.** When `--domain app` is used, the resolver automatically expands to the `fullstack-web` profile equivalent.
>
> For the actual domain modules, see:
> - `_core.md` — Universal analysis framework (always loaded)
> - `interfaces/` — Interface-specific extraction axes (http-api, gui, cli, data-io)
> - `concerns/` — Concern-specific detection signals (async-state, ipc, external-sdk, i18n, realtime, auth)

## Expansion

`--domain app` expands to loading:

1. `_core.md` — All universal analysis axes (R1-R6)
2. `interfaces/http-api.md` — API Endpoint Extraction (Phase 2-2)
3. `interfaces/gui.md` — UI Component Feature Extraction (Phase 2-7)
4. `concerns/` — All concerns loaded for detection signal scanning

This provides equivalent coverage to the original monolithic `app.md`.
