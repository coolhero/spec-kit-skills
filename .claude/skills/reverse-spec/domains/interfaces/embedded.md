# Interface: embedded (reverse-spec)

> Embedded system/firmware detection. Identifies bare-metal, RTOS, and HAL patterns.

## R1. Detection Signals

> See [`shared/domains/interfaces/embedded.md`](../../../shared/domains/interfaces/embedded.md) § Code Patterns

## R3. Analysis Depth Modifiers

When detected, include in analysis:
- Target MCU/SoC family and specifications (RAM, Flash, clock)
- RTOS or bare-metal approach
- Peripheral usage (GPIO, UART, SPI, I2C, ADC, PWM, USB)
- Interrupt handling architecture and priority scheme
- Memory layout (linker script, stack/heap sizing)
- Communication protocols (Wi-Fi, BLE, LoRa, Ethernet)
- Power management strategy (sleep modes, wake sources)
- Build toolchain and flash/debug workflow
