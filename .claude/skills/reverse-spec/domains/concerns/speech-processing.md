# Concern: speech-processing (reverse-spec)

> Speech processing detection. Identifies STT/TTS engines, audio capture, and voice activity detection patterns.

## R1. Detection Signals

> See [`shared/domains/concerns/speech-processing.md`](../../../shared/domains/concerns/speech-processing.md) § Code Patterns

## R3. Analysis Depth Modifiers

When detected, include in analysis:
- STT/TTS engine (cloud provider, on-device model, hybrid)
- Audio codec and sample rate configuration
- Streaming vs batch recognition mode
- VAD implementation and sensitivity settings
- Speaker diarization capabilities
- Language support and multi-language handling
