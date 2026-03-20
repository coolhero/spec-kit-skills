# Foundation: Go (Standalone)

> **Status**: Detection stub. Full F1-F8 sections TODO.
> For Go HTTP servers using Chi/Gin, see `go-chi.md` instead.

## F0: Detection Signals
- `go.mod` present in root
- No `go-chi/chi` or `gin-gonic/gin` in dependencies (those use `go-chi.md`)
- `.go` source files present

## Architecture Notes (for SBI extraction)
- **Project structure**: `cmd/` (entrypoints), `internal/` (private), `pkg/` (public)
- **Error handling**: `fmt.Errorf("%w", err)` wrapping, sentinel errors, multi-error
- **Concurrency**: goroutines, `context.Context` propagation, `signal.Notify` shutdown
- **CLI frameworks**: cobra (`github.com/spf13/cobra`), urfave/cli — detect from go.mod
- **Logging**: slog (stdlib 1.21+), zap, zerolog
- **Testing**: `go test`, table-driven tests, testify, gomock
- **Build**: `go build`, CGO_ENABLED, cross-compilation via `-ldflags`
