# Concern: gpu-compute

> GPU/accelerator programming: CUDA kernels, GPU memory management, inference batching, compute shaders.

---

## Signal Keywords

### Semantic (S0 — for init inference)

**Primary**: CUDA, GPU, tensor, kernel launch, GPU memory, device memory, compute shader, inference, batch processing, accelerator

**Secondary**: VRAM, host-device transfer, memory pool, PagedAttention, quantization, NCCL, multi-GPU, model parallelism, tensor parallelism, KV cache, prefill, decode

### Code Patterns (R1 — for source analysis)

- CUDA: `__global__`, `__device__`, `cudaMalloc`, `cudaMemcpy`, `torch.cuda`, `.to('cuda')`, `.cuda()`
- PyTorch: `torch.nn.Module`, `@torch.compile`, `torch.distributed`, `torch.autograd`
- Triton: `@triton.jit`, `tl.load`, `tl.store`, `tl.program_id`
- Vulkan Compute: `VkComputePipeline`, `vkCmdDispatch`, `wgpu::ComputePipeline`
- OpenCL: `clCreateKernel`, `clEnqueueNDRangeKernel`
- Memory: `torch.cuda.memory_allocated`, `torch.cuda.max_memory_allocated`, `CUDAGraph`
- ML Inference: `vllm`, `triton-inference-server`, `onnxruntime`, `tensorrt`, `llama_cpp`
- Go/Rust: `cudarc`, `wgpu`, `vulkano`

---

## Module Metadata

- **Axis**: Concern
- **Common pairings**: data-io, network-server, task-worker
- **Profiles**: ml-platform, ai-assistant (inference-level)
