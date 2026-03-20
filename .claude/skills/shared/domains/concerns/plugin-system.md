# Concern: plugin-system

> Dynamic loading, extension points, plugin isolation.

---

## Signal Keywords

### Semantic (S0 — for init inference)

**Primary**: plugin, extension, addon, module loader, dynamic loading, plugin API, extension point, hook system

**Secondary**: plugin manifest, plugin registry, hot reload, plugin isolation, plugin SDK, extension marketplace

### Code Patterns (R1 — for source analysis)

- Plugin loading: dynamic `import()`, `require()` with variable paths, `dlopen`, plugin registries
- Extension points: hook systems, event emitters for extensibility, middleware chains accepting external handlers
- Plugin configuration: plugin manifest files, plugin directories, plugin discovery patterns
- Plugin lifecycle: load → initialize → activate → deactivate → unload patterns
- Isolation: worker threads for plugins, sandboxed execution, permission scoping per plugin

### Java SPI (Service Provider Interface)
- `META-INF/services/` directory with interface-named files listing implementations
- `java.util.ServiceLoader.load()` calls
- `@AutoService` annotation (Google auto-service processor)
- Spring's `META-INF/spring.factories` or `META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports`
- Abstract factory patterns with `ServiceLoader` discovery

---

## Module Metadata

- **Axis**: Concern
- **Common pairings**: —
- **Profiles**: —
