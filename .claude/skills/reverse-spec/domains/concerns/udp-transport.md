# Concern: udp-transport (reverse-spec)

> UDP networking detection. Identifies datagram handling, reliability layers, and multicast patterns.

## R1. Detection Signals

> See [`shared/domains/concerns/udp-transport.md`](../../../shared/domains/concerns/udp-transport.md) § Code Patterns

## R3. Analysis Depth Modifiers

When detected, include in analysis:
- Transport type (raw UDP, QUIC, reliable UDP libraries)
- Reliability mechanism (ACK-based, sequence numbering, none)
- MTU handling (discovery, fragmentation, fixed assumption)
- Multicast usage (IGMP, group management, TTL)
- Flow control and congestion handling
- NAT traversal strategy (keepalive, STUN, hole punching)
