# Concern: wire-protocol (reverse-spec)

> Extends shared S0/R1 signals with reverse-spec-specific analysis rules.

## R1: Detection Signals
See `shared/domains/concerns/wire-protocol.md` for S0 keywords and code patterns.

## R3: Feature Boundary Impact
When wire protocol is detected:
- **Protocol codec** (parser + serializer) = Foundation-level infrastructure
- Each **protocol command/message type** = P1 behavior in SBI
- **Connection handshake** = separate Feature if complex (auth, capability negotiation)
- **Protocol version handling** = Foundation-level

## R4: Data Flow Extraction
- Trace: Raw Bytes → Frame Decode → Message Parse → Handler Dispatch → Response Encode → Write
- Record protocol state machine transitions in pre-context.md § Data Lifecycle Patterns
- Note protocol versions supported and backward compatibility strategy
