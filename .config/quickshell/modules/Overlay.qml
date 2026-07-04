import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

PanelWindow {
    id: root

    property bool menuOpen: false

    visible: menuOpen

    function toggleMenu() {
        menuOpen = !menuOpen;
    }

    function openMenu() {
        menuOpen = true;
    }

    function closeMenu() {
        menuOpen = false;
    }

    color: Colors.backdrop
    WlrLayershell.namespace: "quickshell:slim_bar"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: root.menuOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    exclusiveZone: -1

    IpcHandler {
        target: "overlay"
        function toggle(): void { root.toggleMenu(); }
        function open(): void { root.openMenu(); }
        function close(): void { root.closeMenu(); }
    }

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    SlimBarContents {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        overlay: root
        expandPanels: true
    }

}
