# Concern: protocol-integration

> Bidirectional protocols — LSP, MCP, JSON-RPC, custom stateful protocols.

---

## Signal Keywords

### Semantic (S0 — for init inference)

**Primary**: LSP, Language Server Protocol, MCP, Model Context Protocol, JSON-RPC, protocol server, protocol client, language server

**Secondary**: capabilities negotiation, initialize/shutdown lifecycle, stdio transport, tool registration, resource provider, protocol handler

### Code Patterns (R1 — for source analysis)

- LSP: `vscode-languageserver`, `vscode-jsonrpc`, `@lsp/types`, `pylsp`, `gopls` patterns
- MCP: `@modelcontextprotocol/sdk`, MCP server/client setup, tool/resource registration
- Protocol lifecycle: `initialize` → `initialized` → operations → `shutdown` patterns
- Transport layer: stdio pipe setup, SSE server configuration, WebSocket protocol upgrade
- Capability negotiation: `capabilities` objects with feature flags

---

## Module Metadata

- **Axis**: Concern
- **Common pairings**: —
- **Profiles**: —
