# Concern: media-streaming

<!-- Format defined in smart-sdd/domains/_schema.md § Concern Section Schema. -->

> HLS/DASH adaptive streaming, RTMP ingest, transcoding pipelines, media segment packaging, CDN origin.
> Module type: concern

---

## S0. Signal Keywords

> See [`shared/domains/concerns/media-streaming.md`](../../../shared/domains/concerns/media-streaming.md) § Signal Keywords

---

## S1. SC Generation Rules

### Required SC Patterns
- Adaptive streaming: client requests manifest → server returns playlist with available qualities → client selects quality based on bandwidth estimation → server delivers segments → client switches quality on bandwidth change
- Transcoding pipeline: source media ingested → transcoding job queued → media transcoded to target bitrate ladder → segments packaged (HLS/DASH) → manifest generated → segments uploaded to origin/CDN
- Live ingest: encoder pushes RTMP/SRT stream → ingest server receives → transcoder produces ABR variants → packager creates segments → manifest updated in real-time → CDN edge serves segments
- DRM integration: content key generated → key stored in license server → segments encrypted → manifest includes DRM signaling → player requests license → license server validates entitlement → key delivered → player decrypts and plays

### SC Anti-Patterns (reject if seen)
- "Video streaming works" — must specify protocol (HLS/DASH), segment duration, bitrate ladder, and ABR algorithm
- "Transcoding is handled" — must specify input/output codecs, quality presets, and whether synchronous or queued
- "Live streaming is supported" — must specify ingest protocol, latency target (normal/low/ultra-low), and segment duration

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| **Protocol** | HLS? DASH? Both? CMAF for unified segments? Low-latency variant (LL-HLS, LL-DASH)? |
| **Transcoding** | Codec (H.264, H.265, VP9, AV1)? Hardware acceleration (NVENC, QSV)? Bitrate ladder (how many variants)? |
| **Packaging** | Segment duration? Keyframe alignment? CMAF chunks? Manifest format (m3u8, mpd)? |
| **CDN** | Origin shield? Multi-CDN? Cache invalidation strategy? Token-based auth for segments? |
| **DRM** | Widevine? FairPlay? PlayReady? Multi-DRM? License server integration? |

---

## S7. Bug Prevention

| ID | Pattern | Detection | Prevention |
|----|---------|-----------|------------|
| MS-001 | Keyframe misalignment | Segments start at non-IDR frames → decoder artifacts, seek failures, quality switch glitches | Force keyframe interval = segment duration; validate GOP structure before packaging |
| MS-002 | Manifest staleness (live) | Live manifest not updated in time → player stalls waiting for new segments → buffering | Update manifest atomically before segments are available; use low-latency signaling (blocking playlist reload) |
| MS-003 | Bitrate ladder gaps | Too few variants or large bitrate jumps → ABR oscillation, frequent quality switches → poor UX | Define minimum 3-4 variants with max 2x bitrate ratio between adjacent rungs; test on constrained networks |
| MS-004 | Audio/video sync drift | Audio and video tracks drift over long playback → lip sync issues → unwatchable content | Use presentation timestamps (PTS) consistently; align audio/video at segment boundaries; monitor drift metrics |
| MS-005 | Segment duration mismatch | Actual segment duration differs from manifest-declared duration → player buffer calculation errors → stalls | Validate segment duration matches manifest within tolerance; alert on drift > 10% of target duration |
