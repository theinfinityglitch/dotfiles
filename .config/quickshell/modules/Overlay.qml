import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Mpris
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

    Workspaces {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        implicitHeight: 5

    }

    Item {
        id: cluster
        anchors.centerIn: parent
        width: 1
        height: 1

        ClockCluster {
            anchors.centerIn: parent
        }

    }

    Item {
        id: mediaCenter
        implicitWidth: column.implicitWidth
        implicitHeight: column.implicitHeight
        anchors.margins: 10

        anchors {
            bottom: parent.bottom
            left: parent.left
        }

        Column {
            id: column

            spacing: 4

            Repeater {
                model: MediaInfo.players

                delegate: MediaCard {
                    required property MprisPlayer modelData

                    player: modelData
                }

            }

        }
    }

}
