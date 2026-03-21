# Interface: grpc

> gRPC / RPC services using Protocol Buffers. Supports unary, server-streaming, client-streaming, bidirectional-streaming RPCs.
> Module type: interface

---

## S0. Signal Keywords

> See [`shared/domains/interfaces/grpc.md`](../../../shared/domains/interfaces/grpc.md) § Signal Keywords

---

## S1. SC Generation Rules

### Required SC Patterns
- Unary RPC: specify request message → response message → gRPC status code (OK=0, NOT_FOUND=5, INVALID_ARGUMENT=3, etc.). NOT HTTP status codes
- Server streaming RPC: specify stream initiation → message sequence → stream termination (normal end vs error). Verify client receives all messages in order
- Client streaming RPC: specify message sequence → final response. Verify server processes all messages and returns aggregate result
- Bidirectional streaming: specify message interleaving pattern → termination. Verify both sides can send/receive concurrently
- Error handling: gRPC status codes (0-16) with details message. NOT HTTP 4xx/5xx. Use `google.rpc.Status` with details for rich errors
- Metadata: specify required metadata (auth token, trace ID, deadline) and how it propagates through interceptor chain
- Deadlines: every RPC has a deadline. Specify default deadline and behavior when deadline exceeded (DEADLINE_EXCEEDED=4)

### SC Anti-Patterns (reject if seen)
- "API returns 200/400/500" — gRPC uses status codes 0-16, not HTTP status codes
- "POST /api/users" — gRPC uses `service.Method()`, not HTTP verbs + paths
- "JSON response body" — gRPC uses Protobuf binary encoding by default (JSON only via grpc-gateway)
- "REST endpoint" — if the interface is gRPC, SCs must use RPC terminology

### SC Measurability Criteria
- RPC latency per method (p50, p95, p99)
- Message throughput for streaming RPCs (messages/second)
- Protobuf message size constraints

---

## S1. Demo Pattern (override)

- **Type**: gRPC client script (grpcurl or language-specific client)
- **Default mode**: Call key RPCs with sample Protobuf messages → verify responses → exercise streaming
- **CI mode**: `grpc-health-probe` → verify health → run gRPC test client
- **"Try it" instructions**: `grpcurl -plaintext localhost:50051 list` → `grpcurl ... package.Service/Method`

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| **Service design** | Which services and methods? Unary or streaming? Request/response message shapes? |
| **Schema evolution** | Protobuf field numbering strategy? `buf breaking` enforced? Reserved fields for removed fields? |
| **Streaming** | Server-streaming fan-out? Client-streaming aggregation? Bidirectional chat-like or request-response? Backpressure? |
| **Interceptors** | Auth interceptor? Logging interceptor? Tracing interceptor? Rate limiting? |
| **Gateway** | gRPC-Gateway or Connect for browser clients? Transcoding rules? |

---

## S9. Brief Completion Criteria

| Required Element | Completion Signal |
|-----------------|-------------------|
| Service definition | At least one gRPC service with methods identified |
| RPC types | Unary vs streaming per method specified |
| Schema management | Protobuf repo structure and evolution strategy stated |

---

## S8. Runtime Verification Strategy

| Field | Value |
|-------|-------|
| **Start method** | Start gRPC server process (language-specific: `go run`, `cargo run`, `python -m`) |
| **Verify method** | `grpc-health-probe -addr=localhost:PORT` for health → `grpcurl -plaintext localhost:PORT package.Service/Method -d '{...}'` for functional SCs. Backend: gRPC client (grpcurl or language SDK) |
| **Stop method** | Send SIGTERM → verify graceful drain of in-flight RPCs |
| **SC classification extensions** | `grpc-auto` — unary RPC SCs verifiable via grpcurl; `grpc-stream` — streaming SCs verifiable via gRPC test client with message sequence assertion |

**gRPC-specific verification**:
- Health check: `grpc.health.v1.Health/Check` returns SERVING
- Unary SC: call method → assert response message fields + status code
- Streaming SC: initiate stream → send/receive message sequence → verify ordering + completion
- Error SC: call with invalid input → assert gRPC status code (NOT_FOUND, INVALID_ARGUMENT, etc.)
- Reflection: `grpcurl -plaintext localhost:PORT list` → verify service discovery
