# Foundation: Erlang/OTP

> **Status**: Detection stub. Full F1-F8 sections TODO.

## F0: Detection Signals
- `rebar.config` in root (rebar3 build tool)
- OR `.app.src` files + `-behaviour(application)` declarations
- `.erl` source files present
- No Mix/Elixir files (those use `phoenix.md` or future `elixir.md`)

## Architecture Notes (for SBI extraction)
- **Build tool**: rebar3 (`rebar.config`), erlang.mk
- **OTP patterns**: supervision trees, gen_server, gen_statem, gen_event, application
- **Distribution**: Erlang distribution, Mnesia, ETS/DETS
- **Hot code upgrade**: appup/relup files
- **Testing**: Common Test, EUnit, PropEr
- **Release**: relx, rebar3 release
- **Philosophy**: Let It Crash, Process Isolation, Share Nothing, Location Transparency
