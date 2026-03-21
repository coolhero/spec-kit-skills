# Archetype: media-server

<!-- Format defined in smart-sdd/domains/_schema.md § Archetype Section Schema. -->

> Media servers for real-time audio/video — SFU, MCU, transcoding, and recording.
> Distinct from network-server: media-aware routing, codec negotiation, and adaptive bitrate are first-class concerns.

---

## A0. Signal Keywords

> See [`shared/domains/archetypes/media-server.md`](../../../shared/domains/archetypes/media-server.md) § Signal Keywords

---

## A1. Domain Philosophy

| Principle | Description |
|-----------|-------------|
| **SFU-First Scalability** | Selective Forwarding Units scale linearly — forward media without decoding. MCU mixing is a deliberate trade-off for bandwidth reduction at the cost of server CPU. Architecture choice (SFU vs MCU vs hybrid) is the foundational decision |
| **Room-Centric Lifecycle** | Rooms are the primary abstraction. Participants join/leave rooms. Room lifecycle (create → populate → active → drain → destroy) governs resource allocation. Zombie rooms (no participants, resources held) are a critical failure mode |
| **Codec Negotiation** | Server and clients must agree on codecs via SDP. Codec choice affects quality, latency, and CPU. Transcoding bridges codec mismatches but adds latency and server cost. Simulcast/SVC provide quality layers without transcoding |
| **Bandwidth Adaptation** | Network conditions change continuously. Bandwidth estimation (REMB, Transport-CC) drives quality decisions. Adaptive bitrate selects simulcast layers or adjusts encoding parameters. Graceful degradation over hard failures |
| **Recording as Side-Effect** | Recording captures the media pipeline output without disrupting live flow. Recording storage, format conversion, and playback are asynchronous concerns that must not impact real-time performance |

---

## A2. SC Extensions

| Domain | SC Extension |
|--------|-------------|
| **Room lifecycle** | SC must specify: room creation trigger, max participants, what happens when last participant leaves. Verify: create room → join → leave all → verify room destroyed and resources freed |
| **Media routing** | SC must specify: SFU forwarding rules (which tracks to which participants), simulcast layer selection criteria. Verify: 3+ participants → verify each receives correct subset of tracks |
| **Transcoding** | SC must specify: when transcoding is triggered (codec mismatch, recording format), resource limits. Verify: participant with incompatible codec joins → transcoding activates → quality acceptable |
| **Recording** | SC must specify: recording trigger (auto/manual), storage destination, format. Verify: start recording → participants talk → stop → verify playable output file with correct duration |

---

## A3. Probes

| Area | Probe Questions |
|------|----------------|
| **Architecture** | SFU, MCU, or hybrid? Which SFU framework (mediasoup, Janus, Pion, LiveKit)? |
| **Room model** | Max participants per room? Room persistence? Breakout rooms? Lobby/waiting room? |
| **Media** | Audio/video codecs supported? Simulcast? SVC? Screen sharing as separate track? |
| **Quality** | Bandwidth estimation method (REMB, Transport-CC)? Adaptive bitrate? Jitter buffer tuning? |
| **Recording** | Server-side or client-side? Composite (mixed) or individual tracks? Format (WebM, MP4, MKV)? |
| **Scaling** | Single-node or clustered? Cascaded SFU? Geographic distribution? Session migration? |

---

## A4. Constitution Injection

- **Real-time latency budget**: Every feature must evaluate impact on end-to-end media latency. Adding processing steps (transcoding, effects, recording) must stay within latency budget (typically <200ms glass-to-glass)
- **Resource proportionality**: CPU and bandwidth consumption must scale proportionally with participants. O(n^2) patterns (full mesh, MCU mixing) require explicit participant limits
- **Graceful degradation over hard failure**: When bandwidth drops, reduce quality (lower simulcast layer, audio-only fallback) rather than disconnect. User experience degrades smoothly
- **Room cleanup is mandatory**: Every room must have a reaper/timeout mechanism. Resources (ports, memory, TURN allocations) tied to rooms must be freed when the room is empty

---

## A5. Bug Prevention Extensions

| ID | Pattern | Detection | Prevention |
|----|---------|-----------|------------|
| MS-001 | Media track leak on disconnect | Participant disconnects abruptly → server continues forwarding/processing their tracks → CPU waste, ghost audio/video | Detect disconnection (ICE failed, heartbeat timeout) → immediately stop and remove all tracks for that participant |
| MS-002 | Bandwidth spiral | Congestion → packet loss → retransmits → more congestion → cascading quality collapse for all participants | Per-participant bandwidth estimation; proactive quality reduction before congestion; isolate per-participant congestion |
| MS-003 | Room zombie | All participants left but room resources (ports, TURN allocations, transcoding pipelines) not freed → resource exhaustion over time | Room reaper with configurable timeout; force-destroy rooms with no participants after grace period; monitor active room count |
| MS-004 | Simulcast layer mismatch | Server forwards high-quality layer to bandwidth-constrained participant → packet loss → unwatchable video | Respect receiver bandwidth estimate; default to lowest layer, upgrade only when bandwidth confirmed; layer switch hysteresis |
| MS-005 | Recording storage exhaustion | Long recording sessions fill disk → write failures → recording lost and potentially crashes media pipeline | Monitor disk usage; cap recording duration; stream to object storage (S3); separate recording I/O from media forwarding path |
