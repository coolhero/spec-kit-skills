# Concern: wire-protocol

> Wire protocol implementations — MQTT, AMQP, RESP, WebRTC, RTP, and custom binary protocols.
> Module type: concern

---

## S0. Signal Keywords

> See [`shared/domains/concerns/wire-protocol.md`](../../../shared/domains/concerns/wire-protocol.md) § Signal Keywords

---

## S1. SC Generation Rules

### Required SC Patterns
- Connection lifecycle: handshake → capability negotiation → authenticated session → operation → graceful close (with drain)
- Frame parsing: raw bytes → frame boundary detection → header decode → payload extract → checksum/CRC verify → typed message
- State machine: explicit connection states → valid transitions defined → invalid transitions rejected with error → state persisted across frames
- Error handling: malformed frame → protocol error response → connection state preserved or reset → no crash on fuzz input

### SC Anti-Patterns (reject)
- "Protocol is implemented" — must specify which protocol version, which commands/operations, conformance test coverage
- "Messages are parsed" — must specify framing (length-prefix, delimiter, fixed), endianness, max sizes, and malformed input handling
- "Connection is established" — must specify handshake sequence, version negotiation, auth steps, and timeout per step

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| **Protocol** | Standard (MQTT/AMQP/RESP/WebRTC) or custom? Which version(s)? |
| **Framing** | Length-prefixed? Delimiter-based? Fixed-size? Variable-length with type headers? |
| **Encoding** | Binary? Text (like RESP)? Protobuf? MessagePack? Mixed (text header + binary payload)? |
| **State machine** | How many connection states? What triggers transitions? Reconnection behavior? |
| **Security** | TLS/mTLS? SASL? Token-based auth? Encryption at protocol level vs transport level? |
| **Conformance** | Official test suite? Interoperability testing with reference implementations? Fuzz testing? |

---

## S7. Bug Prevention — Wire Protocol-Specific

| ID | Pattern | Detection | Prevention |
|----|---------|-----------|------------|
| WP-001 | Buffer overflow on oversized frame | Unbounded read into memory → OOM or buffer overflow | Max frame size enforced before allocation; reject frames exceeding configured limit |
| WP-002 | State machine violation | Message valid in state A arrives in state B → undefined behavior | Explicit state checks before processing; reject with protocol error on invalid state |
| WP-003 | Partial frame blocking | Incomplete frame received → parser blocks waiting for remaining bytes → connection stalls | Timeout on incomplete frames; non-blocking incremental parsing; close on frame timeout |
| WP-004 | Version mismatch | Client and server negotiate different protocol versions → subtle incompatibilities | Version negotiation in handshake; reject unsupported versions immediately; no silent fallback |
| WP-005 | Endian/encoding mismatch | Sender uses big-endian, receiver assumes little-endian → corrupted field values | Protocol spec defines byte order; explicit conversion in serializer/deserializer |
