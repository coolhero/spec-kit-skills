# Concern: gpu-compute

<!-- Format defined in smart-sdd/domains/_schema.md § Concern Section Schema. -->
<!-- This file provides S0/S1/S5/S7 for smart-sdd pipeline execution. -->
<!-- The corresponding reverse-spec file (reverse-spec/domains/concerns/gpu-compute.md) provides R1 detection. -->

> GPU/accelerator programming: CUDA kernels, GPU memory management, inference batching, compute shaders.

---

## S0. Signal Keywords

> See [`shared/domains/concerns/gpu-compute.md`](../../../shared/domains/concerns/gpu-compute.md) § Signal Keywords

---

## S1. SC Generation Rules

### Required SC Patterns
When this concern is active, every Feature that involves GPU operations MUST include SCs for:

| Pattern | SC Requirement |
|---------|---------------|
| **Memory Management** | Specify GPU memory allocation strategy (pre-allocated pool vs dynamic), peak VRAM usage, and OOM handling behavior. Verify no GPU memory leak after N inference cycles |
| **Host-Device Transfer** | Specify what data moves between CPU and GPU, transfer direction, and whether transfers are synchronous or async (pinned memory, CUDA streams). Minimize unnecessary transfers |
| **Batch Processing** | Specify batch size range (min/max/dynamic), batching strategy (static vs continuous/dynamic), and latency-throughput tradeoff. Verify throughput scales with batch size |
| **Error Handling** | GPU errors (OOM, kernel failure, device lost) must be caught and reported with actionable context. Process must not crash silently on GPU errors; fallback behavior specified (retry, degrade to CPU, reject request) |
| **Multi-Device** | If multiple GPUs: specify placement strategy (data parallel, tensor parallel, pipeline parallel), inter-device communication (NCCL, NVLink), and single-GPU fallback behavior |

### SC Anti-Patterns (reject if seen)
- "GPU inference works" — must specify model loading, memory footprint, batch handling, and error recovery
- "Supports multiple GPUs" — must specify parallelism strategy, communication protocol, and what happens when one GPU fails
- "Memory is managed" — must specify allocation strategy, peak usage, and OOM behavior

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|-----------------|
| **Memory** | Pre-allocated pool or dynamic allocation? Peak VRAM per model? KV cache size management? |
| **Batching** | Static batch size or continuous/dynamic batching? Max batch size? Timeout for incomplete batches? |
| **Quantization** | FP16/BF16/INT8/INT4? Quantization applied at load time or pre-quantized weights? Accuracy impact? |
| **Multi-GPU** | Data parallel, tensor parallel, or pipeline parallel? NCCL for inter-GPU? Single-GPU fallback? |
| **Compute Framework** | CUDA directly? PyTorch? Triton (OpenAI)? Vulkan compute? What GPU generations supported? |
| **Streaming** | Token-by-token streaming for LLM? Partial result emission? Cancellation mid-inference? |

---

## S7. Bug Prevention

| ID | Pattern | Detection | Prevention |
|----|---------|-----------|------------|
| GC-001 | GPU memory leak | VRAM usage grows monotonically across requests → eventual OOM crash | Track allocated/freed per request; implement periodic garbage collection; verify memory returns to baseline after request completion |
| GC-002 | Synchronous host-device transfer bottleneck | CPU blocks waiting for GPU copy → throughput drops to fraction of GPU capability | Use async transfers with CUDA streams or pinned memory; overlap compute with data transfer |
| GC-003 | Silent kernel failure | CUDA kernel returns error code but host code ignores it → silent corruption in results | Check kernel launch return code and cudaGetLastError() after every kernel; propagate errors to request response |
| GC-004 | OOM on batch size spike | Sudden large batch exhausts VRAM → process crash, all in-flight requests lost | Implement batch size cap based on available VRAM; reject or queue requests that would exceed memory budget |
| GC-005 | Model loading blocks serving | New model version loads on same GPU → inference pauses for minutes → timeouts | Load new model on separate GPU or CPU first; swap atomically; or use model versioning with traffic shifting |
