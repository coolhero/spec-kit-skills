# Foundation: Qt (C++)

> **Status**: Detection stub. Full F1-F8 sections TODO.

## F0: Detection Signals
- `Q_OBJECT` macro in C++ headers
- OR `qt_add_qml_module` / `find_package(Qt6)` in CMakeLists.txt
- `.ui` files (Qt Designer) or `.qml` files (QML)

## Architecture Notes (for SBI extraction)
- **Meta-object system**: MOC (Meta-Object Compiler), signals & slots
- **UI**: Qt Widgets (C++), QML/Qt Quick (declarative), Qt Design Studio
- **Build**: qmake (legacy), CMake with Qt modules (modern)
- **Version**: Qt 5 vs Qt 6 (significant API changes)
- **Modules**: QtCore, QtGui, QtWidgets, QtQml, QtQuick, QtNetwork, etc.
- **Testing**: QTest framework
- **Philosophy**: Signal-Slot Decoupling, Model-View Separation, Property System
