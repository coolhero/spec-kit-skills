# Concern: gpu-compute (reverse-spec)

> GPU/accelerator usage detection. Identifies CUDA kernels, GPU memory management, and inference patterns.

## R1. Detection Signals

> See [`shared/domains/concerns/gpu-compute.md`](../../../shared/domains/concerns/gpu-compute.md) § Code Patterns

## R3. Analysis Depth Modifiers

When detected, include in analysis:
- GPU framework (CUDA, PyTorch, Triton, Vulkan compute, WGPU)
- Memory management strategy (pre-allocated pool, dynamic, unified memory)
- Batch processing implementation (static batch, continuous/dynamic batching)
- Multi-GPU strategy (data parallel, tensor parallel, pipeline parallel)
- Host-device data transfer patterns and synchronization points
- Model loading and versioning lifecycle
- Quantization level and supported precision formats
