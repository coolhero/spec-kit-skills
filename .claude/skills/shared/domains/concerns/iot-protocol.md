# Concern: iot-protocol

> MQTT broker patterns, CoAP resources, LwM2M device management, device provisioning, telemetry ingestion, command/control.

---

## Signal Keywords

### Semantic (S0 — for init inference)

**Primary**: MQTT, CoAP, IoT, device management, telemetry, LwM2M, device provisioning, sensor data, IoT gateway, device twin

**Secondary**: QoS levels, retained message, last will, topic hierarchy, device shadow, OTA update, command/control, device registry, edge computing, telemetry ingestion, DTLS, device certificate, fleet management

### Code Patterns (R1 — for source analysis)

- MQTT: `mqtt`, `mosquitto`, `emqx`, `hivemq`, `aedes`, `paho-mqtt`, `rumqtt`
- CoAP: `coap`, `californium`, `libcoap`, `aiocoap`
- Cloud IoT: `aws-iot-device-sdk`, `azure-iot-device`, `@google-cloud/iot`, `ThingsBoard`
- Patterns: `client.subscribe(topic)`, `client.publish(topic, payload)`, `QoS.AT_LEAST_ONCE`, `deviceTwin`, `desiredState`, `reportedState`

---

## Module Metadata

- **Axis**: Concern
- **Common pairings**: wire-protocol, embedded
- **Profiles**: —
