# Concern: webrtc (reverse-spec)

> WebRTC protocol suite detection. Identifies ICE, SDP, media track, and data channel patterns.

## R1. Detection Signals

> See [`shared/domains/concerns/webrtc.md`](../../../shared/domains/concerns/webrtc.md) § Code Patterns

## R3. Analysis Depth Modifiers

When detected, include in analysis:
- ICE configuration (STUN/TURN servers, candidate types, trickle vs full)
- SDP negotiation flow (offer/answer, renegotiation, codec preferences)
- Media track management (addTrack, removeTrack, replaceTrack patterns)
- Data channel usage (reliability mode, message types, flow control)
- Signaling transport (WebSocket, HTTP polling, custom)
- Error handling (ICE failure, negotiation failure, disconnection recovery)
