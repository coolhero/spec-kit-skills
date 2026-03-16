# Concern: plugin-system

> Plugin/extension architecture. Applies when the project supports dynamic loading of third-party or user-created plugins.
> Module type: concern

---

## S0. Signal Keywords

**Primary**: plugin, extension, addon, module loader, dynamic loading, plugin API, extension point, hook system
**Secondary**: plugin manifest, plugin registry, hot reload, plugin isolation, plugin SDK, extension marketplace

---

## S1. SC Generation Rules

### Required SC Patterns
- Plugin lifecycle: discover → load → initialize → activate → deactivate → unload
- Plugin isolation: plugin crash does NOT crash host application
- Plugin API contract: plugins receive typed API surface → no access to host internals
- Plugin error: malformed plugin → graceful rejection with error message (not crash)

### SC Anti-Patterns (reject)
- "Plugins work" — must specify lifecycle phases and isolation guarantees
- "Plugin loads" — must specify what happens on load failure, version mismatch, and permission denial

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| **Discovery** | File system scan? Registry? Remote? Manifest file format? |
| **Isolation** | Same process? Worker thread? Subprocess? Permission model? |
| **API surface** | What can plugins access? Read-only vs read-write? Hooks vs events? |
| **Lifecycle** | Hot reload? Enable/disable without restart? Dependencies between plugins? |
| **Versioning** | Plugin API version compatibility? Breaking change detection? |

---

## S7. Bug Prevention — Plugin-Specific

| ID | Pattern | Detection | Prevention |
|----|---------|-----------|------------|
| PLG-001 | Plugin crash propagation | Unhandled error in plugin crashes host | Wrap plugin execution in try/catch boundary + error event emission |
| PLG-002 | Plugin memory leak | Plugin holds references after deactivation | Force cleanup on deactivate — nullify plugin references, remove event listeners |
| PLG-003 | Plugin permission escalation | Plugin accesses host internals not in API contract | Proxy-based API surface — only expose declared methods |
| PLG-004 | Load order dependency | Plugin A depends on Plugin B but loads first | Dependency declaration in manifest + topological sort of load order |
| PLG-005 | Hot reload state loss | Plugin reload drops user state | Plugin state serialization before unload → deserialization after reload |
