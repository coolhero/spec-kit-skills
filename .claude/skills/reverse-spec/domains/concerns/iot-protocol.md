# Concern: iot-protocol (reverse-spec)

> IoT protocol detection. Identifies MQTT/CoAP broker patterns, device management, and telemetry ingestion.

## R1. Detection Signals

> See [`shared/domains/concerns/iot-protocol.md`](../../../shared/domains/concerns/iot-protocol.md) § Code Patterns

## R3. Analysis Depth Modifiers

When detected, include in analysis:
- IoT protocol used (MQTT v3.1.1/v5, CoAP, LwM2M) and broker implementation
- QoS levels configured per topic and their rationale
- Device provisioning and authentication flow (certificates, pre-shared keys)
- Topic hierarchy design and ACL enforcement
- Device twin/shadow implementation and state synchronization
- Telemetry ingestion pipeline and time-series storage
