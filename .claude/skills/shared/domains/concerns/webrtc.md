# Concern: webrtc

> WebRTC protocol suite: ICE connectivity, DTLS-SRTP, SDP negotiation, media tracks, data channels.

---

## Signal Keywords

### Semantic (S0 — for init inference)

**Primary**: WebRTC, SDP, ICE, STUN, TURN, DTLS, SRTP, media track, peer connection, data channel, SFU, MCU

**Secondary**: ICE candidate, offer/answer, renegotiation, simulcast, bandwidth estimation, RTCP, SCTP, media recorder, getUserMedia, RTCPeerConnection

### Code Patterns (R1 — for source analysis)

- Browser: `RTCPeerConnection`, `RTCSessionDescription`, `RTCIceCandidate`, `getUserMedia`, `addTrack`
- Server (Go): `pion/webrtc`, `pion/ion-sfu`, `pion/turn`
- Server (Rust): `webrtc-rs`, `str0m`
- Server (Node): `mediasoup`, `simple-peer`, `wrtc`
- Server (C++): `libwebrtc`, `janus-gateway`
- Signaling: `socket.io` + SDP exchange, gRPC signaling, REST signaling
- Protocols: `a]candidate:`, `a=ice-ufrag`, `a=fingerprint`, `m=audio`, `m=video`, `a=sendrecv`

---

## Module Metadata

- **Axis**: Concern
- **Common pairings**: realtime, wire-protocol, auth
- **Profiles**: —
