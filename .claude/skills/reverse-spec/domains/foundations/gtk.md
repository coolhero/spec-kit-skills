# Foundation: GTK

> **Status**: Detection stub. Full F1-F8 sections TODO.

## F0: Detection Signals
- `gtk_init` or `GtkApplication` in C source
- OR `Gtk` import in Python (PyGObject)
- `.glade` or `.ui` files (GtkBuilder XML)
- `meson.build` with `gtk4` or `gtk+-3.0` dependency

## Architecture Notes (for SBI extraction)
- **Type system**: GObject (C-based OOP), G_DEFINE_TYPE macro, GSignal
- **UI**: GtkBuilder XML (`.ui`/`.glade` files), CSS-based theming
- **Build**: Meson (modern), Autotools (legacy)
- **Version**: GTK 3 vs GTK 4 (significant rendering changes)
- **Language bindings**: C (native), Python (PyGObject), Rust (gtk-rs), Vala
- **Testing**: GLib testing framework
- **Philosophy**: GObject Type System, Signal-Based Events, Declarative UI, CSS Theming
