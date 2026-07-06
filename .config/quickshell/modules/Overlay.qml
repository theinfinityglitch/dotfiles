import QtQuick
import QtQuick.Controls
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
        onTriggered: OverlayPages.reset()
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
        onActivated: {
            if (OverlayPages.currentIndex !== 0)
                OverlayPages.goToIndex(0);
            else
                root.closeMenu();
        }
    }

    Shortcut {
        sequence: "Left"
        onActivated: OverlayPages.previous()
    }

    Shortcut {
        sequence: "Right"
        onActivated: OverlayPages.next()
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
            onWheel: (wheel) => {
                const isPreciseScroll = wheel.pixelDelta.x !== 0 || wheel.pixelDelta.y !== 0;
                if (isPreciseScroll)
                    return;

                if (wheel.angleDelta.y > 0)
                    OverlayPages.previous();
                else if (wheel.angleDelta.y < 0)
                    OverlayPages.next();
            }
        }

        SwipeView {
            id: pager

            anchors.fill: parent
            anchors.bottomMargin: OverlayPages.count > 1 ? 32 : 0
            interactive: true
            background: Item {
            }

            onCurrentIndexChanged: OverlayPages.goToIndex(currentIndex)

            Connections {
                function onCurrentChanged() {
                    if (pager.currentIndex !== OverlayPages.currentIndex)
                        pager.currentIndex = OverlayPages.currentIndex;

                }

                target: OverlayPages
            }

            Item {
                id: homePage

                Item {
                    id: trayHost

                    anchors.horizontalCenter: parent.horizontalCenter
                    implicitWidth: tray.implicitWidth
                    implicitHeight: tray.implicitHeight

                    y: {
                        const clusterBottom = (homePage.height / 2) + (clockCluster.implicitHeight / 2);
                        const midpoint = (clusterBottom + homePage.height) / 2;
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
                    implicitWidth: mediaColumn.implicitWidth
                    implicitHeight: mediaColumn.implicitHeight

                    anchors {
                        bottom: parent.bottom
                        left: parent.left
                        margins: 10
                    }

                    Column {
                        id: mediaColumn

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

            Item {
                id: systemPage

                Column {
                    anchors.centerIn: parent
                    spacing: 10

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "󰍛"
                        color: Colors.foreground
                        opacity: 0.7

                        font {
                            pixelSize: 48
                            family: "CaskaydiaCove Nerd Font"
                        }

                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "System page - coming soon"
                        color: Colors.foreground
                        opacity: 0.6

                        font {
                            pixelSize: 14
                            family: "CaskaydiaCove Nerd Font"
                        }

                    }

                }

            }

        }

        Row {
            id: pageDots

            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                bottomMargin: 16
            }
            spacing: 8
            visible: OverlayPages.count > 1

            Repeater {
                model: OverlayPages.count

                delegate: Rectangle {
                    id: dot

                    required property int index

                    width: index === pager.currentIndex ? 22 : 8
                    height: 8
                    radius: 4
                    color: index === pager.currentIndex ? Colors.foreground : Colors.backgroundLight

                    Behavior on width {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutCubic
                        }

                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                        }

                    }

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -6
                        cursorShape: Qt.PointingHandCursor
                        onClicked: OverlayPages.goToIndex(dot.index)
                    }

                }

            }

        }

    }

}
