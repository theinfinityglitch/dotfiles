import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    required property Overlay overlay

    WlrLayershell.namespace: "quickshell:slim_bar"
    implicitWidth: 18
    color: "transparent"

    anchors {
        left: true
        top: true
        bottom: true
    }

    SlimBarContents {
        anchors.fill: parent
        hidden: root.overlay.menuOpen
    }
}
