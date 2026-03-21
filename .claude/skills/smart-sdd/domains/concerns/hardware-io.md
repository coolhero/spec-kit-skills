# Concern: hardware-io

> Hardware I/O — device communication, drivers, GPIO, serial, USB, and hardware abstraction layers.
> Module type: concern

---

## S0. Signal Keywords

> See [`shared/domains/concerns/hardware-io.md`](../../../shared/domains/concerns/hardware-io.md) § S0: Detection Signals

---

## S1. SC Generation Rules

### Required SC Patterns
- Device lifecycle: discover/probe → initialize/configure → operate → error recovery → shutdown/release
- Error handling: device error/timeout → retry with backoff → fallback or graceful degradation → resource cleanup guaranteed
- Resource management: exclusive device access acquired → operations performed → access released (even on error/panic)
- Data transfer: transfer direction (read/write/bidirectional) → buffer management → completion/error signaling

### SC Anti-Patterns (reject)
- "Device communicates" — must specify protocol (serial/USB/SPI/I2C/GPIO), data format, timing constraints, and error handling
- "Hardware is initialized" — must specify init sequence, configuration parameters, failure behavior, and cleanup on shutdown
- "Data is read from device" — must specify polling vs interrupt-driven, buffer size, timeout, and partial read handling

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| **Interface** | Serial (UART)? USB? SPI? I2C? GPIO? Memory-mapped I/O? Custom bus? |
| **Abstraction** | HAL layer? Platform-specific drivers? Cross-platform portability needed? |
| **Timing** | Real-time constraints? Polling vs interrupt-driven? Maximum latency tolerance? |
| **Error recovery** | Device hot-plug/unplug? Communication timeout handling? Retry strategy? |
| **Concurrency** | Multiple threads accessing same device? Mutex/lock strategy? DMA considerations? |
| **Testing** | Hardware-in-the-loop? Mock/stub devices? Simulation environment? |

---

## S7. Bug Prevention — Hardware I/O-Specific

| ID | Pattern | Detection | Prevention |
|----|---------|-----------|------------|
| HW-001 | Resource leak on error | Device handle opened → error during operation → handle not closed → resource exhaustion | RAII/defer/finally pattern; resource cleanup in all error paths |
| HW-002 | Race condition on shared device | Multiple threads send commands to same device concurrently → corrupted communication | Mutex-protected device access; single-owner pattern with message passing |
| HW-003 | Blocking I/O stalls system | Synchronous device read with no timeout → thread blocked indefinitely | Timeout on all I/O operations; async I/O or dedicated I/O thread |
| HW-004 | Endianness mismatch | Host byte order assumed for device protocol → garbled data on different architectures | Explicit byte order conversion; protocol-defined endianness for all multi-byte fields |
| HW-005 | Unhandled device disconnect | Hot-unplug during operation → crash or undefined behavior | Device presence monitoring; graceful handling of unexpected disconnection |
