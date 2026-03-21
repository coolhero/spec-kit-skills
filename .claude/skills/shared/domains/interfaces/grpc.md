# Interface: grpc

> gRPC / RPC services using Protocol Buffers, Connect, Twirp, or similar RPC frameworks.
> Distinct from HTTP-API: uses Protobuf IDL, gRPC status codes (0-16), and supports 4 streaming modes.

---

## Signal Keywords

### Semantic (S0 — for init inference)

**Primary**: gRPC, Protobuf, Protocol Buffers, RPC, tonic, Connect-Go, Twirp, grpc-go, grpc-web, buf

**Secondary**: unary RPC, server streaming, client streaming, bidirectional streaming, service definition, proto file, grpc-gateway, reflection, grpc-health, interceptor, metadata

### Code Patterns (R1 — for source analysis)

- Proto files: `*.proto`, `syntax = "proto3"`, `service`, `rpc`, `message`, `enum`, `oneof`
- Go: `google.golang.org/grpc`, `protoc-gen-go-grpc`, `connectrpc.com/connect`, `github.com/twitchtv/twirp`
- Rust: `tonic`, `prost`, `tonic::Request`, `tonic::Response`, `#[tonic::async_trait]`
- Python: `grpcio`, `grpc.aio`, `betterproto`, `grpclib`
- Java: `io.grpc`, `@GrpcService`, `StreamObserver`, `ManagedChannel`
- Node.js: `@grpc/grpc-js`, `@grpc/proto-loader`, `nice-grpc`, `connect-es`
- Build: `buf.yaml`, `buf.gen.yaml`, `protoc`, `buf lint`, `buf breaking`
- Health: `grpc.health.v1.Health`, `grpc-health-probe`

---

## Module Metadata

- **Axis**: Interface
- **Common pairings**: auth, resilience, observability, graceful-lifecycle
- **Archetypes**: microservice, public-api
- **Profiles**: grpc-service
