# Concern: media-streaming

> HLS/DASH adaptive streaming, RTMP ingest, transcoding pipelines, media segment packaging, CDN origin.

---

## Signal Keywords

### Semantic (S0 — for init inference)

**Primary**: HLS, DASH, adaptive bitrate, transcoding, media streaming, RTMP, video encoding, media segments, ABR, live streaming

**Secondary**: manifest, playlist, m3u8, mpd, ffmpeg, segment duration, CDN origin, bitrate ladder, keyframe interval, GOP, muxer, demuxer, DRM, media pipeline, chunk transfer

### Code Patterns (R1 — for source analysis)

- Video: `ffmpeg`, `libav`, `gstreamer`, `MediaSource API`, `hls.js`, `dash.js`, `shaka-player`, `video.js`
- Transcoding: `fluent-ffmpeg`, `handbrake`, `x264`, `x265`, `libvpx`, `av1`, `nvenc`
- Streaming: `@videojs/http-streaming`, `ExoPlayer`, `AVPlayer`, `MediaPlayer`, RTMP libraries (`node-media-server`, `nginx-rtmp-module`)
- Patterns: `.m3u8`, `.mpd`, `#EXTINF`, `SegmentTimeline`, `AdaptationSet`, `Representation`

---

## Module Metadata

- **Axis**: Concern
- **Common pairings**: realtime, gpu-compute
- **Profiles**: —
