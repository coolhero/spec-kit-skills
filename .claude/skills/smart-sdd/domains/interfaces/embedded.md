# Interface: embedded

> Embedded systems, firmware, IoT devices, RTOS applications. Bare-metal and HAL programming.
> Module type: interface

---

## S0. Signal Keywords

> See [`shared/domains/interfaces/embedded.md`](../../../shared/domains/interfaces/embedded.md) § Signal Keywords

---

## S1. SC Generation Rules

### Required SC Patterns
- Peripheral initialization: specify GPIO/UART/SPI/I2C configuration → verify peripheral responds correctly after init. Include pin assignments, clock configuration, and mode (input/output/alternate function)
- Interrupt handling: specify ISR trigger condition, handler execution time budget (< N µs), and shared state access (volatile, atomic, critical section). Verify no priority inversion
- Power management: specify sleep/wake transitions, wake sources (interrupt, timer, external signal), and state preservation across sleep cycles
- Error handling: specify behavior on hardware errors (bus fault, watchdog timeout, peripheral failure). No silent failure — errors must be logged or signaled (LED, serial output, error register)
- Memory constraints: specify stack size, heap usage (if any), and flash/RAM budget. Verify no stack overflow, no heap fragmentation (if dynamic allocation used)

### SC Anti-Patterns (reject)
- "Hardware works" — must specify peripheral configuration, initialization sequence, and verification method
- "Interrupt is handled" — must specify trigger, handler time budget, and shared state protection
- "Low power mode supported" — must specify sleep depth, wake sources, and state preservation

### SC Measurability Criteria
- ISR execution time (< N µs)
- Boot-to-ready time
- Power consumption in each mode (active, sleep, deep sleep)
- Flash/RAM usage vs budget

---

## S1. Demo Pattern (override)

- **Type**: Hardware-in-the-loop or simulation-based
- **Default mode**: Flash firmware → verify boot sequence via serial output → exercise peripheral → verify response
- **CI mode**: Build firmware → verify compilation and linking → flash to emulator/simulator → run hardware-in-the-loop tests
- **"Try it" instructions**: Build + flash commands for target board

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| **Target** | Which MCU/SoC? RAM/Flash size? Clock speed? |
| **RTOS** | Bare-metal or RTOS? Which RTOS (FreeRTOS, Zephyr, Embassy)? Task priorities? |
| **Peripherals** | Which peripherals used (GPIO, UART, SPI, I2C, ADC, PWM, USB)? |
| **Communication** | Wi-Fi? BLE? LoRa? Ethernet? Protocol for cloud connectivity? |
| **Power** | Battery-powered? Sleep modes? Wake sources? Power budget? |
| **Safety** | Safety-critical? Watchdog? Fail-safe behavior? |

---

## S9. Brief Completion Criteria

| Required Element | Completion Signal |
|-----------------|-------------------|
| Target hardware | MCU/SoC family and key specs (RAM, Flash, clock) identified |
| Peripheral usage | Which peripherals the firmware interacts with stated |
| Build toolchain | Compiler, linker, flash tool identified |

---

## S8. Runtime Verification Strategy

| Field | Value |
|-------|-------|
| **Start method** | Flash firmware to target board or emulator (QEMU, Renode, Wokwi). Delegate physical board setup to user |
| **Verify method** | Serial output monitoring + GPIO state verification (via test harness or user observation). Emulator: automated assertions on register state |
| **Stop method** | Reset or power-cycle target |
| **SC classification extensions** | `embedded-sim` — SCs verifiable via emulator/simulator; `embedded-hw` — SCs requiring physical hardware → delegate to user via AskUserQuestion |

**Embedded-specific verification**:
- Peripheral SCs: emulator-based verification where possible (QEMU, Renode); physical hardware SCs delegate to user
- Timing SCs: verify ISR execution time via logic analyzer or emulator cycle count
- Power SCs: delegate to user (measure with multimeter or power profiler)
- Safety SCs: verify watchdog triggers on stuck loop; verify fail-safe activation on sensor error
