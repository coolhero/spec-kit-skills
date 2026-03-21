# Concern: speech-processing

> Speech-to-text, text-to-speech, audio codec handling, VAD (voice activity detection), speaker diarization, streaming recognition.

---

## Signal Keywords

### Semantic (S0 — for init inference)

**Primary**: speech-to-text, text-to-speech, STT, TTS, voice recognition, ASR, speech synthesis, voice activity detection, speaker diarization

**Secondary**: audio codec, WAV, PCM, Opus, WebM, transcription, streaming recognition, wake word, hotword, speech model, language model, acoustic model, prosody, SSML, phoneme, utterance

### Code Patterns (R1 — for source analysis)

- Cloud: `@google-cloud/speech`, `@google-cloud/text-to-speech`, `aws-sdk` (Transcribe/Polly), `azure-cognitiveservices-speech`, `openai` (Whisper)
- Libraries: `whisper`, `vosk`, `deepspeech`, `pyttsx3`, `espeak`, `coqui-tts`, `silero-vad`
- Web: `SpeechRecognition` API, `SpeechSynthesis` API, `MediaRecorder`, `AudioContext`, `AudioWorklet`
- Patterns: `recognizer.start()`, `synthesizer.speak()`, `onresult`, `onaudioprocess`, `VADIterator`, `diarize()`

---

## Module Metadata

- **Axis**: Concern
- **Common pairings**: gpu-compute, external-sdk
- **Profiles**: —
