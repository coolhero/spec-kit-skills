# Archetype: inference-server

<!-- Format defined in smart-sdd/domains/_schema.md § Archetype Section Schema. -->

> ML inference servers — model serving, continuous batching, KV cache management, and token streaming.
> Distinct from public-api: model lifecycle, GPU memory management, and batching are first-class concerns.

---

## A0. Signal Keywords

> See [`shared/domains/archetypes/inference-server.md`](../../../shared/domains/archetypes/inference-server.md) § Signal Keywords

---

## A1. Domain Philosophy

| Principle | Description |
|-----------|-------------|
| **Model Lifecycle as Infrastructure** | Models are deployed artifacts with lifecycle stages: load → warm up (prefill dummy input) → serve → hot-swap (load new version alongside old) → unload. Each stage has resource implications. Failed loads must not crash the server |
| **Continuous Batching** | Requests arrive asynchronously but GPUs are efficient with batches. Continuous batching (iteration-level scheduling) forms batches dynamically — new requests join mid-generation. Batch size vs latency is the fundamental trade-off |
| **KV Cache is the Bottleneck** | Autoregressive generation stores key-value tensors per token per layer. KV cache size determines max concurrent sequences. Memory management (paged attention, prefix caching, eviction) is the primary scaling constraint |
| **Token Streaming** | Users expect token-by-token output. Each generated token must be emitted immediately via SSE/WebSocket/gRPC stream. Streaming cancellation must free resources (KV cache, batch slot) without corrupting other sequences |
| **Multi-Model Routing** | Production servers host multiple models. Routing decisions (by model name, version, A/B test group) determine which model handles each request. Model-specific resource limits prevent one model from starving others |

---

## A2. SC Extensions

| Domain | SC Extension |
|--------|-------------|
| **Model loading** | SC must specify: model format (GGUF, SafeTensors, ONNX), quantization level, GPU memory requirement. Verify: load model → warm up → serve first request → verify output matches reference |
| **Batching** | SC must specify: max batch size, max wait time for batch formation, behavior when batch is full. Verify: send N concurrent requests → verify batched execution → response latency within SLO |
| **KV cache** | SC must specify: max sequence length, max concurrent sequences, eviction policy when memory exhausted. Verify: fill KV cache to capacity → new request arrives → verify graceful handling (queue, reject, or evict) |
| **Streaming** | SC must specify: streaming protocol (SSE, WebSocket, gRPC), token emit granularity, cancellation behavior. Verify: start generation → cancel mid-stream → verify resources freed, no orphaned generation |

---

## A3. Probes

| Area | Probe Questions |
|------|----------------|
| **Framework** | vLLM? TGI? Triton? TensorRT-LLM? Custom? ONNX Runtime? |
| **Models** | LLM (decoder-only)? Encoder-decoder? Vision? Multi-modal? Embedding models? |
| **Hardware** | GPU (CUDA, ROCm)? CPU-only? Multi-GPU (tensor parallel, pipeline parallel)? NPU/TPU? |
| **Batching** | Static batching? Continuous batching? Max batch size? Prefill/decode separation? |
| **Memory** | KV cache strategy (paged attention, chunked prefill)? Quantization (GPTQ, AWQ, FP8)? Memory pool? |
| **API** | OpenAI-compatible? Custom API? gRPC? Embeddings endpoint? Function calling support? |

---

## A4. Constitution Injection

- **GPU memory is finite and shared**: Every feature must account for GPU memory impact. KV cache, model weights, activations, and CUDA kernels all compete for GPU memory. OOM on GPU crashes the process — there is no graceful fallback
- **Latency has two phases**: Time-to-first-token (TTFT) measures prefill latency, time-per-output-token (TPOT) measures decode speed. Features affecting prefill vs decode must be measured separately. Users perceive TTFT directly
- **Batch efficiency over individual latency**: Continuous batching optimizes throughput (tokens/second across all users) at the cost of individual request latency. This is the correct trade-off for serving — optimize for fleet, not individual
- **Cancellation must free resources immediately**: When a client disconnects or cancels, the KV cache slots and batch positions must be freed within one iteration. Leaked resources degrade all subsequent requests

---

## A5. Bug Prevention Extensions

| ID | Pattern | Detection | Prevention |
|----|---------|-----------|------------|
| IS-001 | Model OOM on load | Model weights + KV cache reservation exceed GPU memory → CUDA OOM → server crash | Pre-calculate memory requirement before loading (weights + KV cache + overhead); reject load if insufficient; support CPU offloading |
| IS-002 | Batch timeout starvation | Low-priority requests wait for batch formation → high-priority requests keep filling batches → low-priority requests timeout | Priority-aware scheduling; max wait time per request; separate queues for priority levels; shed load before starvation |
| IS-003 | KV cache fragmentation | Sequences of varying lengths allocate/free KV cache pages → fragmentation → usable memory less than total free memory → premature rejections | Paged attention with fixed-size pages; defragmentation pass during low load; monitor fragmentation ratio |
| IS-004 | Streaming cancel leak | Client cancels SSE/WebSocket stream → server-side generation continues → KV cache and batch slot held until generation completes → resource waste | Detect client disconnect per-iteration; free KV cache and batch slot immediately on cancel; heartbeat-based liveness check |
| IS-005 | Hot-swap model inconsistency | New model version loaded while old version serves requests → routing table updated mid-request → response mixes old/new model outputs | Atomic routing table swap; drain in-flight requests for old version before unloading; version pinning per request at routing time |
