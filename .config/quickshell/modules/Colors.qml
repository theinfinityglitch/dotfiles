import QtQuick
import Quickshell
pragma Singleton

Singleton {
    id: root

    // Colors
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
    readonly property color mediaTitleColor: cyan
    readonly property color mediaArtistColor: magenta
    readonly property color mediaPlayerIndicatorPlayingColor: cyan
    readonly property color mediaPlayerIndicatorPausedColor: orange
    // Clock
    readonly property color clockColor: blue
    // Battery
    readonly property color batteryColor: cyan
    readonly property color batteryChargingColor: green
    readonly property color batteryWarningColor: yellow
    readonly property color batteryCriticalColor: red
    // Power profiles
    readonly property color powerSaverColor: green
    readonly property color powerBalancedColor: yellow
    readonly property color powerPerformanceColor: red
    // Network
    readonly property color networkColor: blue
    readonly property color networkDisconnectedColor: red
    // Audio
    readonly property color audioColor: orange
    readonly property color audioMutedColor: red
    // Idle inhibitor
    readonly property color idleInhibitorActivatedColor: cyan
    readonly property color idleInhibitorDeactivatedColor: orange
    // Backlight
    readonly property color backlightColor: yellow
    // Updates
    readonly property color updatesColor: green
    // Notifications
    readonly property color notificationColor: blue
    readonly property color notificationLowColor: backgroundLight
    readonly property color notificationCriticalColor: red
    // System monitor
    readonly property color systemCpuColor: blue
    readonly property color systemMemColor: magenta
    readonly property color systemDiskColor: yellow
    readonly property color systemSwapColor: orange
    readonly property color systemGpuColor: green
    // Shell chrome
    readonly property color backdrop: Qt.rgba(0.03, 0.03, 0.03, 0.6)
}
