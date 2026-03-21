# Concern: iot-protocol

<!-- Format defined in smart-sdd/domains/_schema.md § Concern Section Schema. -->

> MQTT broker patterns, CoAP resources, LwM2M device management, device provisioning, telemetry ingestion, command/control.
> Module type: concern

---

## S0. Signal Keywords

> See [`shared/domains/concerns/iot-protocol.md`](../../../shared/domains/concerns/iot-protocol.md) § Signal Keywords

---

## S1. SC Generation Rules

### Required SC Patterns
- Telemetry ingestion: device publishes telemetry to topic (MQTT QoS 1+) → broker receives → message routed to processing pipeline → data validated and normalized → stored in time-series database → device acknowledged
- Command/control: server publishes command to device topic → device receives command → device executes action → device publishes result/ack → server updates device state → timeout triggers retry or alert if no response
- Device provisioning: new device connects → device presents credentials (certificate, pre-shared key, or provisioning token) → server validates identity → device registered in device registry → device receives configuration → device begins normal operation
- Device twin/shadow: desired state set by server → desired state published to device → device applies changes → device reports actual state → server compares desired vs reported → discrepancy triggers reconciliation

### SC Anti-Patterns (reject if seen)
- "Devices send data" — must specify protocol (MQTT/CoAP), QoS level, payload format, and ingestion pipeline
- "Devices are managed" — must specify provisioning flow, authentication method, and firmware update mechanism
- "Commands are sent to devices" — must specify delivery guarantee, timeout handling, and acknowledgment mechanism

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| **Protocol** | MQTT v3.1.1 or v5? CoAP? LwM2M? Custom binary? Why this protocol? |
| **QoS** | QoS 0 (fire-and-forget)? QoS 1 (at-least-once)? QoS 2 (exactly-once)? Per-topic QoS? |
| **Security** | mTLS? Pre-shared keys? Device certificates? Certificate rotation? |
| **Scale** | How many devices? Messages per second? Topic hierarchy design? Broker clustering? |
| **Edge** | Edge processing before cloud? Local decision making? Store-and-forward on connectivity loss? |

---

## S7. Bug Prevention

| ID | Pattern | Detection | Prevention |
|----|---------|-----------|------------|
| IOT-001 | Topic wildcard subscription leak | Device subscribes to `#` or broad wildcard → receives messages for other devices → data leakage → privacy violation | Enforce topic ACLs per device; restrict wildcard subscriptions; validate topic permissions at broker level |
| IOT-002 | Last Will not configured | Device disconnects ungracefully without Last Will → server unaware device is offline → stale device status → incorrect fleet dashboard | Configure Last Will and Testament on every device connection; set appropriate Will topic and payload; monitor device connectivity |
| IOT-003 | Telemetry timestamp missing | Device sends data without timestamp → server uses receive time → network delay conflated with event time → incorrect time-series analysis | Require device-side timestamp in every telemetry message; validate timestamp freshness; reject messages with clock skew > threshold |
| IOT-004 | Command replay attack | Old command message replayed → device executes outdated action → unintended behavior (e.g., re-opening a lock) | Include monotonic command ID or timestamp; device rejects commands older than last processed; use MQTT v5 message expiry |
| IOT-005 | Certificate expiry unmonitored | Device certificates expire → device cannot connect → silent fleet dropout → functionality loss | Track certificate expiry dates in device registry; alert N days before expiry; automate certificate rotation; monitor connection failure rate |
