# Concern: udp-transport

> UDP-based networking: datagram-oriented protocols, DNS, QUIC, game networking, media streaming over UDP.
> Distinct from wire-protocol (which assumes connection-oriented): UDP is connectionless, unreliable, unordered.

---

## Signal Keywords

### Semantic (S0 — for init inference)

**Primary**: UDP, datagram, QUIC, DNS, unreliable transport, connectionless, packet loss, MTU, multicast

**Secondary**: UDP socket, recvfrom, sendto, DTLS, RTP, unreliable ordered, packet fragmentation, hole punching, NAT traversal, congestion control

### Code Patterns (R1 — for source analysis)

- Go: `net.ListenPacket`, `net.UDPConn`, `quic-go`, `miekg/dns`
- Rust: `tokio::net::UdpSocket`, `quinn` (QUIC), `trust-dns`, `socket2`
- C: `SOCK_DGRAM`, `recvfrom()`, `sendto()`, `setsockopt(SO_REUSEPORT)`
- Node.js: `dgram`, `@libp2p/udp`, `dns2`
- QUIC: `quiche`, `msquic`, `ngtcp2`, `HTTP/3`
- Patterns: `PacketHandler`, `DatagramCodec`, `UdpFramed`, `PacketBuffer`

---

## Module Metadata

- **Axis**: Concern
- **Common pairings**: wire-protocol, network-server (archetype), cryptography
- **Profiles**: —
