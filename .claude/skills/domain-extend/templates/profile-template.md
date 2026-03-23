# Profile Template

> Profiles are pure manifests (~5-10 lines) that compose interfaces + concerns
> into a reusable preset. Use via `/smart-sdd init --profile {name}`.
>
> Profiles do NOT set Scenario (determined by `sdd-state.md` Origin field)
> or Archetype (set explicitly in `sdd-state.md`).

---

## File: `smart-sdd/domains/profiles/{name}.md`

```markdown
# Profile: {name}

> {One-line description of the project type this profile represents.}

interfaces: [{interface1}, {interface2}]
concerns: [{concern1}, {concern2}, {concern3}]
```

---

## Examples

```markdown
# Profile: desktop-app

> Desktop application with GUI (Electron, Tauri, Qt, etc.).

interfaces: [gui]
concerns: [async-state, ipc]
```

```markdown
# Profile: fullstack-web

> Full-stack web application with frontend GUI and backend API.

interfaces: [gui, http-api]
concerns: [async-state, auth]
```

---

## Checklist After Creation

- [ ] All listed interfaces exist in `smart-sdd/domains/interfaces/`
- [ ] All listed concerns exist in `smart-sdd/domains/concerns/`
- [ ] Profile name is kebab-case
- [ ] Description clearly identifies the project type
- [ ] No Archetype or Scenario fields (those are set in sdd-state.md)
