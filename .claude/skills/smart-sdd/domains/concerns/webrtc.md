# Concern: webrtc

> WebRTC protocol suite — ICE connectivity, SDP negotiation, media tracks, and data channels.
> Module type: concern

---

## S0. Signal Keywords

> See [`shared/domains/concerns/webrtc.md`](../../../shared/domains/concerns/webrtc.md) § Signal Keywords

---

## S1. SC Generation Rules

### Required SC Patterns
- ICE connectivity: STUN binding → candidate gathering (host/srflx/relay) → connectivity check → selected pair → consent refresh
- SDP offer/answer: createOffer → setLocalDescription → signal to remote → setRemoteDescription → createAnswer → setLocalDescription(answer) → signal answer back
- Media track lifecycle: addTrack → renegotiation triggered → ontrack fires on remote → replaceTrack or removeTrack → renegotiation
- Data channel: createDataChannel → open event → send/receive messages → bufferedAmount check → close → cleanup

### SC Anti-Patterns (reject)
- "WebRTC connection works" — must specify ICE server configuration, candidate types gathered, fallback to TURN, and connectivity check timeout
- "Video call is established" — must specify SDP negotiation sequence, codec preferences, simulcast layers if any, and renegotiation handling
- "Data is sent peer-to-peer" — must specify data channel reliability (ordered/unordered, maxRetransmits), flow control, and max message size

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| **ICE** | STUN/TURN servers configured? Candidate types (host, srflx, prflx, relay)? Trickle ICE or full? ICE restart on failure? |
| **Signaling** | Signaling transport (WebSocket, HTTP, custom)? SDP format (unified-plan, plan-b)? Renegotiation strategy? |
| **Media** | Audio/video codecs (VP8/VP9/H.264/AV1, Opus)? Simulcast? SVC? Bandwidth estimation? |
| **Data channels** | Ordered or unordered? Reliable or unreliable (maxRetransmits/maxPacketLifeTime)? Max message size? |
| **Security** | DTLS-SRTP mandatory? Certificate fingerprint verification? SRTP key derivation? |

---

## S7. Bug Prevention — WebRTC-Specific

| ID | Pattern | Detection | Prevention |
|----|---------|-----------|------------|
| RTC-001 | ICE failure without fallback | All STUN candidates fail → no connectivity check succeeds → call never connects, no error shown to user | Configure TURN relay as fallback; detect ICE failure state → show user-facing error; implement ICE restart |
| RTC-002 | SDP renegotiation race | Both peers call createOffer simultaneously → glare condition → SDP state machine corrupted | Implement offer/answer collision detection (polite/impolite peer pattern per RFC 8829); rollback conflicting offers |
| RTC-003 | Media track leak on disconnect | Peer disconnects abruptly → remote MediaStreamTrack not stopped → camera/mic LED stays on, memory leak | Listen for connectionstatechange → on "disconnected"/"failed", stop all remote tracks; cleanup on onremovetrack |
| RTC-004 | TURN allocation exhaustion | High-concurrency scenario → TURN server runs out of relay allocations → new users cannot connect | Monitor TURN allocation count; implement allocation limits per user; graceful degradation to direct P2P when possible |
| RTC-005 | Data channel message overflow | Send large message exceeding SCTP max → silent failure or connection reset | Check bufferedAmount before send; chunk large messages; respect maxMessageSize from SDP |
