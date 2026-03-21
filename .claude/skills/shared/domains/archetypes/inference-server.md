# Archetype: inference-server

> ML model inference servers: continuous batching, KV cache management, token streaming, model lifecycle.
> Distinct from ai-assistant (consumer-side) and gpu-compute (low-level). This is the serving infrastructure.

---

## Signal Keywords

### Semantic (A0 — for init inference)

**Primary**: inference server, model serving, continuous batching, KV cache, token streaming, model loading, vLLM, Triton, TGI, Ollama, llama.cpp server

**Secondary**: PagedAttention, prefix caching, speculative decoding, tensor parallelism, pipeline parallelism, model hot-swap, request scheduling, SLA latency, TTFT, TPS, throughput

### Code Patterns (R1 — for source analysis)

- vLLM: `vllm`, `LLMEngine`, `AsyncLLMEngine`, `SamplingParams`, `PagedAttention`
- Triton: `tritonserver`, `model_repository`, `config.pbtxt`, `TritonInferenceServer`
- TGI: `text-generation-inference`, `generate`, `generate_stream`
- Ollama: `ollama`, `model`, `chat`, `generate`, `Modelfile`
- llama.cpp: `llama_context`, `llama_batch`, `server`, `--ctx-size`, `--n-gpu-layers`
- General: `ModelRunner`, `BatchScheduler`, `KVCache`, `TokenStreamer`, `ModelLoader`

---

## Module Metadata

- **Axis**: Archetype
- **Common interfaces**: http-api (REST inference API), grpc (model serving protocol)
- **Common concerns**: gpu-compute, graceful-lifecycle, observability, connection-pool, resilience
- **Profiles**: inference-server
