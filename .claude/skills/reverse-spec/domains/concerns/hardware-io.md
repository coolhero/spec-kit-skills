# Concern: Hardware I/O (reverse-spec)

> Hardware I/O pattern detection

## R1. Detection Signals

> See [`shared/domains/concerns/hardware-io.md`](../../../shared/domains/concerns/hardware-io.md) § Code Patterns

## R3. Analysis Depth Modifiers

When detected, include in analysis:
- Device access patterns (open/close lifecycle, exclusive locking, permission handling)
- Memory-mapped I/O (mmap regions, volatile access, cache coherency, barrier instructions)
- ioctl/sysfs usage (control commands, attribute read/write, udev rules, device enumeration)
- Serial/USB communication (baud rate configuration, USB descriptor parsing, bulk/interrupt transfers, hotplug handling)
- GPIO/sensor access (pin configuration, interrupt-driven input, ADC/DAC conversion, polling vs event-driven)
- Kernel module interaction (character device interface, netlink sockets, procfs/debugfs exposure, module parameters)
