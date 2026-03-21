# Concern: speech-processing

<!-- Format defined in smart-sdd/domains/_schema.md § Concern Section Schema. -->

> Speech-to-text, text-to-speech, audio codec handling, VAD (voice activity detection), speaker diarization, streaming recognition.
> Module type: concern

---

## S0. Signal Keywords

> See [`shared/domains/concerns/speech-processing.md`](../../../shared/domains/concerns/speech-processing.md) § Signal Keywords

---

## S1. SC Generation Rules

### Required SC Patterns
- Speech-to-text: audio input captured → audio chunked/streamed → sent to recognition engine → interim results returned in real-time → final transcript returned on utterance end → confidence score included → transcript delivered to application
- Text-to-speech: text/SSML input provided → voice and language selected → synthesis request sent → audio generated → audio streamed or returned as file → playback initiated → completion callback fired
- Voice activity detection: audio stream monitored → VAD detects speech onset → recording/processing started → VAD detects speech end → segment finalized → silence periods ignored → reduces processing cost and latency
- Speaker diarization: audio with multiple speakers processed → speaker segments identified → each segment labeled with speaker ID → speaker timeline generated → speaker count estimated → segments grouped by speaker

### SC Anti-Patterns (reject if seen)
- "Speech is recognized" — must specify engine (cloud/local), language support, streaming vs batch, and how interim results are used
- "TTS works" — must specify voice selection, SSML support, audio format, and latency requirements
- "Audio is processed" — must specify codec, sample rate, channel count, and VAD configuration

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| **Engine** | Cloud (Google, AWS, Azure, OpenAI Whisper)? On-device (Vosk, DeepSpeech)? Hybrid? |
| **Streaming** | Real-time streaming recognition? Batch transcription? Interim results needed? |
| **Languages** | Which languages? Multi-language in same session? Language detection? |
| **Audio** | Sample rate (8kHz, 16kHz, 44.1kHz)? Codec (PCM, Opus, MP3)? Noise conditions? |
| **Privacy** | Audio stored or discarded after processing? User consent for recording? Data residency? |

---

## S7. Bug Prevention

| ID | Pattern | Detection | Prevention |
|----|---------|-----------|------------|
| SPE-001 | Wrong sample rate | Audio captured at 44.1kHz but model expects 16kHz → degraded recognition accuracy → garbled transcripts | Validate sample rate before sending to engine; resample if needed; document expected format per engine |
| SPE-002 | VAD too aggressive | VAD threshold too high → clips beginning of utterances → first word lost → incomplete transcripts | Tune VAD with pre-speech buffer (200-300ms padding); test with various speaking styles; make threshold configurable |
| SPE-003 | Audio buffer overflow | Recognition engine slower than audio input → buffer grows → memory exhaustion or audio dropped → gaps in transcript | Implement backpressure on audio capture; drop or downsample when buffer exceeds limit; monitor buffer fill level |
| SPE-004 | TTS blocking main thread | Synchronous TTS synthesis on UI thread → UI frozen during generation → poor user experience | Run TTS in background thread/worker; stream audio chunks as generated; show loading indicator during synthesis |
| SPE-005 | No microphone permission handling | App assumes microphone access → crashes or silent failure when permission denied → user sees blank screen | Check permission before accessing microphone; handle denial gracefully with explanation; provide retry path |
