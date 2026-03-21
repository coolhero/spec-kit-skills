# Archetype: media-server

> Media processing servers: SFU/MCU, transcoding, room management, adaptive bitrate streaming.
> WebRTC media servers, HLS/DASH origin servers, recording/playback systems.

---

## Signal Keywords

### Semantic (A0 — for init inference)

**Primary**: SFU, MCU, media server, transcoding, simulcast, media room, WebRTC server, HLS, DASH, streaming server, live streaming

**Secondary**: media track, codec, H.264, VP8, VP9, AV1, Opus, adaptive bitrate, ABR, RTMP ingest, RTP, RTCP, recording, playback, bandwidth estimation, jitter buffer

### Code Patterns (R1 — for source analysis)

- Go: `pion/webrtc`, `pion/ion-sfu`, `livego`
- Rust: `webrtc-rs`, `str0m`
- C/C++: `janus-gateway`, `mediasoup-worker`, `libwebrtc`, `ffmpeg` (transcoding)
- Node.js: `mediasoup`, `livekit-server`
- Patterns: `Router`, `Transport`, `Producer`, `Consumer`, `Room`, `Participant`, `Track`

---

## Module Metadata

- **Axis**: Archetype
- **Common interfaces**: http-api (signaling), grpc (control plane)
- **Common concerns**: webrtc, realtime, graceful-lifecycle, observability
- **Profiles**: —
