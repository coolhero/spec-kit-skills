# Foundation: Spring Boot
<!-- Format: _foundation-core.md | ID prefix: SB (see § F4) -->

> Server framework Foundation for Java/Kotlin projects using Spring Boot.
> Convention-over-configuration framework with auto-configuration, starters, and production-ready features (Actuator).

---

## F0. Detection Signals

| Signal | Confidence |
|--------|-----------|
| `spring-boot-starter-*` in `pom.xml` or `build.gradle`/`build.gradle.kts` dependencies | HIGH |
| `@SpringBootApplication` annotation in main class | HIGH |
| `application.properties` or `application.yml` in `src/main/resources/` | HIGH |
| `mvnw` / `gradlew` wrapper + Spring dependency | MEDIUM |

---

## F1. Categories

| Code | Category | Description |
|------|----------|-------------|
| BST | App Bootstrap | Auto-configuration, component scanning, profiles, starters |
| SEC | Security | Spring Security, OAuth2, method security, CORS, CSRF |
| MID | Middleware | Filters, interceptors, AOP aspects, HandlerInterceptor |
| API | API Design | REST controllers, versioning, OpenAPI/SpringDoc, validation |
| DBS | Database | Spring Data JPA/R2DBC, HikariCP connection pool, Flyway/Liquibase migrations |
| PRC | Process Management | Actuator, graceful shutdown, thread pool executor, profiles |
| HLT | Health Check | Actuator health, custom health indicators, readiness/liveness probes |
| ERR | Error Handling | @ControllerAdvice, ProblemDetail RFC 7807, exception resolvers |
| LOG | Logging | SLF4J + Logback, structured logging, MDC propagation |
| TST | Testing | @SpringBootTest, @WebMvcTest, Testcontainers, MockMvc, @DataJpaTest |
| BLD | Build & Deploy | Maven/Gradle, Docker, GraalVM native image, layered JARs |
| ENV | Environment Config | application.yml, @ConfigurationProperties, Spring Cloud Config, profiles, active Spring Profiles |
| DXP | Developer Experience | DevTools, LiveReload, Lombok, MapStruct |

---

## F2. Decision Items

### BST — App Bootstrap
| ID | Item | Priority | Question |
|----|------|----------|----------|
| SB-BST-01 | Build tool | Critical | Maven or Gradle? Wrapper (`mvnw`/`gradlew`) included? |
| SB-BST-02 | Java version | Critical | Java 17/21? Language level? |
| SB-BST-03 | Starters | Critical | Which spring-boot-starters? (web, data-jpa, security, actuator, etc.) |
| SB-BST-04 | Component scanning | Important | Default `@SpringBootApplication` scan or custom `@ComponentScan`? |
| SB-BST-05 | Configuration binding | Important | `@Value` injection or `@ConfigurationProperties` typed binding? |
| SB-BST-06 | Programming model | Critical | Servlet (blocking MVC, JPA, Tomcat) or Reactive (WebFlux, R2DBC, Netty)? Detection: `spring-boot-starter-webflux` = reactive, `spring-boot-starter-web` = servlet. Both present = mixed. |

### SEC — Security
| ID | Item | Priority | Question |
|----|------|----------|----------|
| SB-SEC-01 | Auth strategy | Critical | Spring Security filter chain? JWT stateless? Session-based? OAuth2 resource server? |
| SB-SEC-02 | Method security | Important | `@PreAuthorize`/`@Secured` method-level authorization? |
| SB-SEC-03 | CORS config | Important | `CorsConfiguration` or `@CrossOrigin`? Allowed origins? |
| SB-SEC-04 | CSRF | Important | Disabled for stateless API? Custom CSRF token repository? |

### MID — Middleware
| ID | Item | Priority | Question |
|----|------|----------|----------|
| SB-MID-01 | Filter chain | Critical | Which `OncePerRequestFilter` implementations? Registration order? |
| SB-MID-02 | Interceptors | Important | `HandlerInterceptor` for logging, auth, metrics? |
| SB-MID-03 | AOP | Optional | `@Aspect` for cross-cutting concerns (logging, auditing, caching)? |

### API — API Design
| ID | Item | Priority | Question |
|----|------|----------|----------|
| SB-API-01 | Controller style | Critical | `@RestController` with `@RequestMapping`? Versioning strategy (URL/header)? |
| SB-API-02 | Validation | Critical | `@Valid` + `@NotNull`/`@Size` (Jakarta Validation)? Custom validators? |
| SB-API-03 | Serialization | Important | Jackson config? Custom serializers/deserializers? Date format? |
| SB-API-04 | API documentation | Important | SpringDoc OpenAPI? Swagger annotations? |
| SB-API-05 | Pagination | Important | `Pageable` parameter? Custom page response wrapper? |

### DBS — Database
| ID | Item | Priority | Question |
|----|------|----------|----------|
| SB-DBS-01 | ORM choice | Critical | Spring Data JPA? MyBatis? jOOQ? JDBC Template? |
| SB-DBS-02 | Connection pool | Critical | HikariCP (default)? Pool size config? |
| SB-DBS-03 | Migration tool | Critical | Flyway or Liquibase? Migration naming convention? |
| SB-DBS-04 | Multi-datasource | Optional | Multiple `DataSource` beans? Read/write separation? |

### ERR — Error Handling
| ID | Item | Priority | Question |
|----|------|----------|----------|
| SB-ERR-01 | Global handler | Critical | `@ControllerAdvice` with `@ExceptionHandler`? Error response format? |
| SB-ERR-02 | ProblemDetail | Important | RFC 7807 `ProblemDetail` response? Custom error attributes? |

### LOG — Logging
| ID | Item | Priority | Question |
|----|------|----------|----------|
| SB-LOG-01 | Framework | Important | Logback (default) or Log4j2? Structured JSON logging? |
| SB-LOG-02 | MDC | Important | MDC for request tracing (correlation ID, user ID)? |

### TST — Testing
| ID | Item | Priority | Question |
|----|------|----------|----------|
| SB-TST-01 | Test framework | Critical | JUnit 5 + Spring Test? Mockito? Testcontainers for integration? |
| SB-TST-02 | Slice tests | Important | `@WebMvcTest`, `@DataJpaTest`, `@WebFluxTest` for isolated testing? |

### BLD — Build & Deploy
| ID | Item | Priority | Question |
|----|------|----------|----------|
| SB-BLD-01 | Packaging | Critical | Fat JAR (default)? Layered JAR for Docker? WAR? |
| SB-BLD-02 | Docker | Important | Dockerfile multi-stage? Spring Boot Buildpacks (`bootBuildImage`)? |
| SB-BLD-03 | Native image | Optional | GraalVM native-image compilation? |

### PRC — Process Management
| ID | Item | Priority | Question |
|----|------|----------|----------|
| SB-PRC-01 | Graceful shutdown | Important | `server.shutdown=graceful`? Shutdown timeout? |
| SB-PRC-02 | Actuator endpoints | Important | Which actuator endpoints exposed? (`health`, `info`, `metrics`, `env`) |

### ENV — Environment Config
| ID | Item | Priority | Question |
|----|------|----------|----------|
| SB-ENV-01 | Config strategy | Important | `application.yml` or `application.properties`? `@ConfigurationProperties` typed binding? Spring Cloud Config? |
| SB-ENV-02 | Active Spring Profiles | Important | What profiles are defined (`application-{profile}.yml`) and what do they control? Detection: glob `application-*.yml` / `application-*.properties`. |

---

## F7. Philosophy

| Principle | Description | Impact |
|-----------|-------------|--------|
| **Convention over Configuration** | Starters and auto-configuration reduce boilerplate; sensible defaults for everything | Don't fight auto-config — override only when necessary; use `@ConditionalOn*` for custom auto-config |
| **Opinionated Defaults** | Spring Boot makes choices so developers don't have to (HikariCP, Logback, Jackson) | Accept defaults unless project has specific requirements; document overrides |
| **Production-Ready** | Actuator provides health, metrics, info endpoints out of the box | Always include `spring-boot-starter-actuator`; configure health indicators for all external dependencies |
| **Layered Architecture** | Controller → Service → Repository is the expected pattern | Keep layers separate; don't inject repositories into controllers directly |

---

## F8. Toolchain Commands

| Field | Command |
|-------|---------|
| `build` | `./mvnw package -DskipTests` or `./gradlew build -x test` |
| `test` | `./mvnw test` or `./gradlew test` |
| `lint` | See S3b Java/Kotlin section in `smart-sdd/domains/_core.md` |
| `package_manager` | `mvn` or `gradle` |

---

## F9. Scan Targets

#### Data Model
| Pattern | Description |
|---------|-------------|
| `@Entity` classes in `**/model/` or `**/entity/` | JPA entity definitions |
| `@Table(name = "...")` annotations | Explicit table naming |
| `JpaRepository<T, ID>` interfaces | Repository declarations reveal entity types |
| Flyway/Liquibase migration files | Schema evolution history |

#### API Endpoints
| Pattern | Description |
|---------|-------------|
| `@RestController` + `@RequestMapping` / `@GetMapping` / `@PostMapping` / `@PutMapping` / `@DeleteMapping` | REST endpoint definitions |
| `@PathVariable`, `@RequestParam`, `@RequestBody` | Request parameter extraction |
| SpringDoc `@Operation`, `@ApiResponse` annotations | API documentation metadata |

#### Reactive Patterns
| Pattern | Description |
|---------|-------------|
| `RouterFunction` definitions | WebFlux functional routing |
| `Mono<T>` / `Flux<T>` return types | Reactive stream return types |
| `ReactiveRepository` / `ReactiveCrudRepository` interfaces | Reactive data access |
| `@EnableWebFlux` | WebFlux activation |

#### Spring Cloud Patterns
| Pattern | Description |
|---------|-------------|
| `@FeignClient` | Declarative HTTP client |
| `@EnableEurekaClient` / `@EnableDiscoveryClient` | Service discovery |
| `@EnableConfigServer` | Centralized configuration server |
| Spring Cloud Gateway route definitions (`RouteLocator`, `route().path()`) | API gateway routing |
| `@CircuitBreaker` | Circuit breaker resilience pattern |

#### AOP Annotation Patterns
| Pattern | Description |
|---------|-------------|
| `@Transactional` | Transaction boundaries |
| `@Cacheable` / `@CacheEvict` | Cache management |
| `@Async` | Asynchronous execution |
| `@Scheduled` | Scheduled task execution |
| `@PreAuthorize` / `@Secured` | Method-level security |

#### Profile Patterns
| Pattern | Description |
|---------|-------------|
| `application-*.yml` / `application-*.properties` | Profile-specific configuration files |
| `@Profile("...")` | Profile-conditional bean activation |
