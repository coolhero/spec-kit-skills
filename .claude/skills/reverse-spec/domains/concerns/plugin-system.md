# Concern: plugin-system (reverse-spec)

> Plugin architecture detection. Identifies dynamic loading, extension points, and plugin isolation patterns.

## R1. Detection Signals
- Plugin loading: dynamic `import()`, `require()` with variable paths, `dlopen`, plugin registries
- Extension points: hook systems, event emitters for extensibility, middleware chains accepting external handlers
- Plugin configuration: plugin manifest files, plugin directories, plugin discovery patterns
- Plugin lifecycle: load → initialize → activate → deactivate → unload patterns
- Isolation: worker threads for plugins, sandboxed execution, permission scoping per plugin
