# Concern: protocol-integration (reverse-spec)

> Bidirectional protocol detection (LSP, MCP, Language Server Protocol, Model Context Protocol).
> Identifies stateful protocol implementations beyond simple request-response APIs.

## R1. Detection Signals
- LSP: `vscode-languageserver`, `vscode-jsonrpc`, `@lsp/types`, `pylsp`, `gopls` patterns
- MCP: `@modelcontextprotocol/sdk`, MCP server/client setup, tool/resource registration
- Protocol lifecycle: `initialize` → `initialized` → operations → `shutdown` patterns
- Transport layer: stdio pipe setup, SSE server configuration, WebSocket protocol upgrade
- Capability negotiation: `capabilities` objects with feature flags
