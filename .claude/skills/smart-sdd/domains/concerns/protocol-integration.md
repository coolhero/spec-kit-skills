# Concern: protocol-integration

> Bidirectional stateful protocols (LSP, MCP, custom protocols).
> Applies when the project implements or consumes protocol servers/clients with lifecycle management.
> Module type: concern

---

## S0. Signal Keywords

> See [`shared/domains/concerns/protocol-integration.md`](../../../shared/domains/concerns/protocol-integration.md) § Signal Keywords

---

## S1. SC Generation Rules

### Required SC Patterns
- Protocol lifecycle: initialize → capabilities → normal operation → shutdown (full lifecycle SC)
- Capability negotiation: server declares supported features → client adapts behavior
- Transport layer: at least one transport tested (stdio / SSE / HTTP)
- Error handling: protocol-level errors (invalid request, method not found) → proper JSON-RPC error response
- Graceful shutdown: server handles shutdown request → cleans up resources → exits

### SC Anti-Patterns (reject)
- "Protocol works" — must specify lifecycle phases and capability verification
- "Server responds" — must specify request method, expected response shape, and error cases
- "Tools are available" — must specify tool registration, parameter schema, and invocation flow

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| **Protocol type** | LSP? MCP? Custom JSON-RPC? gRPC bidirectional? |
| **Transport** | stdio? SSE? WebSocket? HTTP? Multiple transports? |
| **Lifecycle** | Explicit init/shutdown? Capability negotiation? Hot reload? |
| **Discovery** | Dynamic tool/resource registration? Schema generation? |
| **Auth** | OAuth2 for protocol connections? API key? Token refresh? |

---

## S7. Bug Prevention — Protocol-Specific

| ID | Pattern | Detection | Prevention |
|----|---------|-----------|------------|
| PROTO-001 | Lifecycle state violation | Operation sent before initialize completes | State machine guard — track protocol phase, reject premature operations |
| PROTO-002 | Transport mismatch | Server expects stdio but client sends HTTP | Transport type validation at connection setup |
| PROTO-003 | Capability drift | Client assumes capability that server didn't declare | Always check capabilities response before using optional features |
| PROTO-004 | Shutdown leak | Server process orphaned on client disconnect | Register disconnect handler + process cleanup timeout |
| PROTO-005 | Schema version mismatch | Tool parameter schema changes without client update | Version field in capability declaration + schema hash comparison |
