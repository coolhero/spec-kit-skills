# Concern: schema-registry

> Schema evolution and registry management: Protobuf, Avro, JSON Schema versioning and compatibility enforcement.

---

## Signal Keywords

### Semantic (S0 — for init inference)

**Primary**: schema registry, schema evolution, Protobuf versioning, Avro, JSON Schema, backward compatibility, forward compatibility, schema validation

**Secondary**: schema migration, breaking change, field numbering, reserved fields, buf breaking, compatibility mode, schema ID, schema subject, serializer, deserializer

### Code Patterns (R1 — for source analysis)

- Confluent: `schema-registry`, `io.confluent.kafka.serializers`, `KafkaAvroSerializer`, `ProtobufSerializer`
- Buf: `buf.yaml`, `buf.lock`, `buf breaking`, `buf lint`, `buf.build`
- Protobuf: `reserved`, `option deprecated`, field number management, `oneof`
- Avro: `avsc` files, `SchemaRegistry`, `AvroSerializer`, `GenericRecord`, schema fingerprint
- JSON Schema: `$schema`, `$ref`, `additionalProperties`, `ajv`, `json-schema-validator`
- API: `AsyncAPI`, `OpenAPI`, schema drift detection

---

## Module Metadata

- **Axis**: Concern
- **Common pairings**: message-queue, grpc, http-api, codegen
- **Profiles**: —
