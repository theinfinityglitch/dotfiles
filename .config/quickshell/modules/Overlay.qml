import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Mpris
import Quickshell.Io

PanelWindow {
    id: root

    property bool menuOpen: false
    property int fadeDuration: 200

    visible: menuOpen || hideTimer.running
    color: root.menuOpen ? Colors.backdrop : "transparent"

    Behavior on color {
        ColorAnimation {
            duration: root.fadeDuration
        }

    }

    Timer {
        id: hideTimer

        interval: root.fadeDuration
    }

    onMenuOpenChanged: {
        if (!menuOpen)
            hideTimer.restart();

    }

    function toggleMenu() {
        menuOpen = !menuOpen;
    }

    function openMenu() {
        menuOpen = true;
    }

    function closeMenu() {
        menuOpen = false;
    }

    Shortcut {
        sequence: "Escape"
        onActivated: root.closeMenu()
    }

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

    Item {
        id: content

        anchors.fill: parent
        opacity: root.menuOpen ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: root.fadeDuration
                easing.type: Easing.OutCubic
            }

        }

        MouseArea {
            id: mouse

            anchors.fill: parent
            onClicked: root.closeMenu()
        }

        Item {
            id: trayHost

            anchors.horizontalCenter: parent.horizontalCenter
            implicitWidth: tray.implicitWidth
            implicitHeight: tray.implicitHeight

            y: {
                const clusterBottom = (content.height / 2) + (clockCluster.implicitHeight / 2);
                const midpoint = (clusterBottom + content.height) / 2;
                return midpoint - (implicitHeight / 2);
            }

            Tray {
                id: tray

                parentWindow: root
            }

        }

        Item {
            id: cluster
            anchors.centerIn: parent
            width: 1
            height: 1

            ClockCluster {
                id: clockCluster

                anchors.centerIn: parent
                open: root.menuOpen
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

                spacing: 10

                Repeater {
                    model: MediaInfo.players

                    delegate: MediaCard {
                        required property MprisPlayer modelData

                        player: modelData
                    }

                }

            }
        }

        Item {
            id: notificationCenterHost

            anchors {
                bottom: parent.bottom
                right: parent.right
                margins: 10
            }
            implicitWidth: notificationCenter.implicitWidth
            implicitHeight: notificationCenter.implicitHeight

            NotificationCenter {
                id: notificationCenter
            }

        }

    }

}
