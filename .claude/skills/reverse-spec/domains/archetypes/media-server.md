# Archetype: media-server (reverse-spec)

> Media server detection. Identifies SFU/MCU architectures, room management, transcoding, and recording patterns.

## R1. Detection Signals

> See [`shared/domains/archetypes/media-server.md`](../../../shared/domains/archetypes/media-server.md) § Code Patterns

## R2. Classification Guide

When detected, classify the sub-type:
- **SFU**: Selective forwarding without decoding (mediasoup, Janus, Pion, LiveKit)
- **MCU**: Media mixing/compositing (Kurento, FreeSWITCH)
- **Hybrid**: SFU with selective MCU mixing (e.g., active speaker composite)
- **Recording-focused**: Media capture and storage (no live routing)

## R3. Analysis Depth Modifiers

When detected, include in analysis:
- Architecture type (SFU, MCU, hybrid) and framework used
- Room/session model (creation, lifecycle, participant limits)
- Codec negotiation and transcoding pipeline
- Bandwidth estimation and adaptive bitrate strategy
- Recording mechanism (server-side composite, individual tracks)
- Scaling topology (single-node, cascaded, geographic distribution)
