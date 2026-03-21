# Archetype: inference-server (reverse-spec)

> ML inference server detection. Identifies model serving, batching, KV cache, and streaming patterns.

## R1. Detection Signals

> See [`shared/domains/archetypes/inference-server.md`](../../../shared/domains/archetypes/inference-server.md) § Code Patterns

## R2. Classification Guide

When detected, classify the sub-type:
- **LLM serving**: Autoregressive text generation (vLLM, TGI, TensorRT-LLM)
- **General inference**: Classification, detection, embedding (Triton, TorchServe, ONNX Runtime)
- **Multi-modal**: Vision + language models (LLaVA serving, multi-modal pipelines)
- **Embedding service**: Vector embedding generation (sentence-transformers serving)

## R3. Analysis Depth Modifiers

When detected, include in analysis:
- Serving framework and model formats supported
- Batching strategy (static, continuous/iteration-level)
- KV cache management (paged attention, prefix caching, eviction)
- Token streaming implementation (SSE, WebSocket, gRPC)
- Multi-model routing and version management
- Hardware utilization (GPU memory management, multi-GPU parallelism)
