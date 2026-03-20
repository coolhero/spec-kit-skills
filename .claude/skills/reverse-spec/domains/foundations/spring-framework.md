# Foundation: Spring Framework (non-Boot)

> **Status**: Detection stub. Full F1-F8 sections TODO.

## F0: Detection Signals
- `spring-context` or `spring-web` in `pom.xml`/`build.gradle` WITHOUT `spring-boot-starter-*`
- `applicationContext.xml` or `*-context.xml` files (XML bean configuration)
- `@Configuration` classes with explicit `@Bean` methods (no auto-configuration)
- `web.xml` with `DispatcherServlet` or `ContextLoaderListener`
- `@ImportResource` annotations referencing XML configs

## Architecture Notes (for SBI extraction)
- **No Auto-Configuration**: Unlike Spring Boot, all beans must be explicitly declared (XML or `@Configuration`)
- **XML Config**: `<bean>`, `<import>`, `<context:component-scan>` — treat each XML config file as an infrastructure module
- **Manual Wiring**: `PropertyPlaceholderConfigurer` instead of `@ConfigurationProperties`; `@Value` may reference XML-defined properties
- **War Deployment**: Often deployed as WAR to external servlet container (Tomcat, Jetty, JBoss) — no embedded server
- **Deep ORM Hierarchy**: Common pattern: abstract mapped superclass → concrete entities with Hibernate inheritance strategies (SINGLE_TABLE, JOINED, TABLE_PER_CLASS)
