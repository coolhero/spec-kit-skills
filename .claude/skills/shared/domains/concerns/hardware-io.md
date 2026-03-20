# Concern: Hardware I/O

> **Status**: Detection stub. Full S0-S4 sections TODO.

## S0: Detection Signals
- Keywords: `ioctl`, `mmap`, `serial`, `usb`, `gpio`, `spi`, `i2c`, `/dev/`, `KVM`, `virtio`
- Libraries: `pyserial`, `libusb`, `hidapi`, `kvm-ioctls`, `vmm-sys-util`
- Patterns: device file access, interrupt handlers, DMA buffers, hardware abstraction layers

## Architecture Notes (for SBI extraction)
- Device initialization/teardown sequences → P1 behaviors (resource lifecycle)
- Error recovery and retry logic → P1 behaviors (reliability-critical)
- Hardware abstraction layer methods → P1 behaviors (portability boundary)
- Raw register/memory access → P2 behaviors (implementation detail)
- Diagnostic/debug interfaces → P3 behaviors
