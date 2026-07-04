import QtQuick
import Quickshell
pragma Singleton

Singleton {
    // Module-specific colors

    id: root

    readonly property color background: "#282828"
    readonly property color backgroundLight: "#3c3836"
    readonly property color foreground: "#ebdbb2"
    readonly property color black: "#32302f"
    readonly property color red: "#cc241d"
    readonly property color green: "#98971a"
    readonly property color yellow: "#d79921"
    readonly property color blue: "#458588"
    readonly property color magenta: "#b16286"
    readonly property color cyan: "#689d6a"
    readonly property color white: "#ebdbb2"
    readonly property color orange: "#d65d0e"
    // Workspaces
    readonly property color workspaceColor: foreground
    readonly property color workspaceUrgentColor: red
    readonly property color workspaceFocussedColor: cyan
    readonly property color workspaceEmptyColor: backgroundLight
    // Media player
    readonly property color mediaPlayerIndicatorPlayingColor: cyan
    readonly property color mediaPlayerIndicatorPausedColor: orange
    // Overlay
    readonly property color backdrop: Qt.rgba(0.03, 0.03, 0.03, 0.6)
}
