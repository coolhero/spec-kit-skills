# Concern: media-streaming (reverse-spec)

> Media streaming stack detection. Identifies HLS/DASH, transcoding, and CDN origin patterns.

## R1. Detection Signals

> See [`shared/domains/concerns/media-streaming.md`](../../../shared/domains/concerns/media-streaming.md) § Code Patterns

## R3. Analysis Depth Modifiers

When detected, include in analysis:
- Streaming protocol (HLS, DASH, CMAF) and manifest format
- Transcoding pipeline (codecs, bitrate ladder, hardware acceleration)
- Segment duration and keyframe alignment strategy
- CDN integration and cache configuration
- DRM system (Widevine, FairPlay, PlayReady) if present
- Live vs VOD architecture differences
