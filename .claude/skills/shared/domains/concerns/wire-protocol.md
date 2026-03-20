# Concern: wire-protocol

> Wire protocol implementations — MQTT, AMQP, RESP, WebRTC, RTP, and custom binary protocols.

---

## Signal Keywords

### Semantic (S0 — for init inference)

**Primary**: MQTT, AMQP, RESP, STUN, TURN, WebRTC, SDP, ICE, codec, RTMP, HLS, RTP, protocol handler, packet parser, wire protocol

**Secondary**: frame, handshake, keepalive, QoS, session, connection state, binary protocol, serialization, deserialization, message framing, flow control, protocol version, capability negotiation

### Code Patterns (R1 — for source analysis)

- **Protocol state machine**: connection states (connecting, connected, closing, closed), state transition functions, invalid transition handling
- **Packet/frame parsing**: binary readers, byte buffer manipulation, length-prefix framing, delimiter-based framing, codec implementations
- **Handshake**: connection establishment sequences, capability exchange, authentication steps, version negotiation
- **Libraries**: `tokio-codec`, `nom` (Rust parsers), `netty` codec pipeline (Java), `asyncio.Protocol` (Python), `bufio` (Go)
- **Testing**: protocol conformance tests, fuzzing, malformed packet handling, round-trip serialization tests

---

## Module Metadata

- **Axis**: Concern
- **Common pairings**: message-broker (archetype), network-server (archetype), database-engine (archetype)
- **Profiles**: —
