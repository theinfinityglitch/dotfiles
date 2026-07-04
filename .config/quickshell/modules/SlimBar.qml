import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    required property Overlay overlay

    WlrLayershell.namespace: "quickshell:slim_bar"
    implicitHeight: 18
    color: "transparent"

    anchors {
        top: true
        left: true
        right: true
    }

    SlimBarContents {
        anchors.fill: parent
        visible: !root.overlay.visible
        overlay: root.overlay
    }

}
