# Concern: udp-transport

> UDP networking — datagram send/receive, packet loss handling, MTU compliance, and multicast.
> Module type: concern

---

## S0. Signal Keywords

> See [`shared/domains/concerns/udp-transport.md`](../../../shared/domains/concerns/udp-transport.md) § Signal Keywords

---

## S1. SC Generation Rules

### Required SC Patterns
- Datagram send/receive: bind socket → send datagram → receive datagram (may be lost, duplicated, or reordered) → application-level acknowledgment if needed
- Packet loss handling: detect loss (sequence number gap or timeout) → retransmit (reliable UDP) or tolerate (real-time media) → specify which strategy per message type
- MTU compliance: message size ≤ path MTU → send as single datagram; message > MTU → application-level fragmentation/reassembly or reject with error
- Multicast: join multicast group (IGMP) → receive group datagrams → leave group → verify no lingering subscriptions

### SC Anti-Patterns (reject)
- "UDP messages are sent" — must specify delivery guarantees (none/application-level ACK), ordering requirements, and behavior on packet loss
- "Data is transmitted efficiently" — must specify max datagram size, MTU discovery strategy, and fragmentation handling
- "Multicast works" — must specify multicast group management, TTL/hop limit, and source filtering (SSM vs ASM)

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| **Transport** | Raw UDP? QUIC? Custom reliable UDP (KCP, ENet)? DTLS for security? |
| **Reliability** | Fire-and-forget? Application-level ACK? Selective retransmission? Sequence numbering? |
| **MTU** | Path MTU discovery? Fixed MTU assumption? Application-level fragmentation? PMTUD blackhole handling? |
| **Multicast** | IGMPv2/v3? Source-specific multicast? Multicast DNS? Multicast rate limiting? |
| **Flow control** | Rate limiting on sender? Congestion control (TFRC, custom)? Receiver buffer sizing? |

---

## S7. Bug Prevention — UDP-Specific

| ID | Pattern | Detection | Prevention |
|----|---------|-----------|------------|
| UDP-001 | Assumed delivery | Application treats UDP send as guaranteed delivery → no retry or acknowledgment → silent data loss | Explicitly document delivery guarantee per message type; implement application-level ACK for critical messages; monitor delivery rate |
| UDP-002 | Buffer overflow on large datagrams | Receive buffer too small for incoming datagram → truncation without error (platform-dependent) → corrupted data processed | Set receive buffer size to max expected datagram; validate datagram length before processing; reject oversized datagrams |
| UDP-003 | No rate limiting | Sender floods receiver with datagrams → receiver cannot process fast enough → packet drop at OS level → degraded service | Implement sender-side rate limiting; monitor receiver drop rate; use congestion control algorithm for sustained transfers |
| UDP-004 | NAT timeout | UDP flow idle too long → NAT mapping expires → subsequent packets dropped → connection broken without error | Send periodic keepalive datagrams; detect NAT timeout via missing responses; re-establish mapping on timeout |
| UDP-005 | Multicast group leak | Application joins multicast group but fails to leave on shutdown → continues receiving traffic → resource waste and potential info leak | Leave multicast group in cleanup/shutdown handler; track joined groups; verify leave on graceful and abnormal termination |
