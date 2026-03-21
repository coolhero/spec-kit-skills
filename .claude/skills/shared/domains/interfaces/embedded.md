# Interface: embedded

> Embedded systems, firmware, IoT devices, RTOS applications. Hardware abstraction layers and bare-metal programming.
> The "interface" is GPIO pins, UART, SPI/I2C buses, interrupt handlers — not HTTP or CLI.

---

## Signal Keywords

### Semantic (S0 — for init inference)

**Primary**: embedded, firmware, microcontroller, RTOS, bare-metal, no_std, HAL, GPIO, UART, SPI, I2C, interrupt handler

**Secondary**: register, DMA, watchdog, power management, bootloader, flash, linker script, ISR, timer, ADC, DAC, PWM, memory-mapped I/O

### Code Patterns (R1 — for source analysis)

- Rust embedded: `#![no_std]`, `#![no_main]`, `cortex-m-rt`, `embassy`, `embedded-hal`, `defmt`, `probe-rs`
- C embedded: `#include <stm32f4xx.h>`, `volatile`, `__interrupt`, `ISR()`, `GPIO_Init`, `HAL_Init`
- Zephyr: `CONFIG_*` in `prj.conf`, `device_get_binding`, `k_thread_create`, `sys_init`
- Arduino: `setup()`, `loop()`, `digitalWrite`, `analogRead`, `Serial.begin`
- ESP-IDF: `esp_err_t`, `gpio_config`, `esp_wifi_init`, `nvs_flash_init`, `app_main`
- Build: `memory.x`, `link.x`, `.ld` linker scripts, `CMakeLists.txt` with `target_link_libraries`
- RTOS: `xTaskCreate`, `vTaskDelay`, `xSemaphoreTake`, `osThreadNew`, `tx_thread_create`

---

## Module Metadata

- **Axis**: Interface
- **Common pairings**: hardware-io, wire-protocol
- **Profiles**: embedded-system
