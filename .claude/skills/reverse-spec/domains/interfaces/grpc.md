# Interface: grpc (reverse-spec)

> gRPC/RPC service detection. Identifies Protobuf services, streaming patterns, interceptors.

## R1. Detection Signals

> See [`shared/domains/interfaces/grpc.md`](../../../shared/domains/interfaces/grpc.md) § Code Patterns

## R3. Analysis Depth Modifiers

When detected, include in analysis:
- Proto file structure and service definitions
- RPC types per method (unary, server-streaming, client-streaming, bidi)
- Interceptor/middleware chain (auth, logging, tracing)
- Schema evolution strategy (buf breaking, reserved fields)
- gRPC-Gateway or Connect usage for browser/REST clients
- Health check implementation (grpc.health.v1)
