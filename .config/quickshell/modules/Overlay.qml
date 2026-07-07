import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
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
        onTriggered: {
            OverlayPages.reset();
            OverlaySettings.close();
        }
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
            if (OverlaySettings.open)
                OverlaySettings.close();
            else if (OverlayPages.currentIndex !== 0)
                OverlayPages.goToIndex(0);
            else
                root.closeMenu();
        }
    }

    Shortcut {
        sequence: "Left"
        onActivated: {
            if (!OverlaySettings.open)
                OverlayPages.previous();

        }
    }

    Shortcut {
        sequence: "Right"
        onActivated: {
            if (!OverlaySettings.open)
                OverlayPages.next();

        }
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
                if (OverlaySettings.open)
                    return;

                if (wheel.buttons !== 0)
                    return;

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
            interactive: !OverlaySettings.open
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

                readonly property var resourceEntries: {
                    const list = [
                        {
                            "icon": "󰻠",
                            "label": "CPU",
                            "accent": Colors.systemCpuColor,
                            "percent": SystemInfo.cpuPercent,
                            "valueText": "",
                            "history": SystemInfo.cpuHistory
                        },
                        {
                            "icon": "󰍛",
                            "label": "Memory",
                            "accent": Colors.systemMemColor,
                            "percent": SystemInfo.memPercent,
                            "valueText": SystemInfo.memUsedGiB.toFixed(1) + " / " + SystemInfo.memTotalGiB.toFixed(1) + " GiB",
                            "history": SystemInfo.memHistory
                        }
                    ];
                    if (SystemInfo.swapPresent)
                        list.push({
                            "icon": "󰓡",
                            "label": "Swap",
                            "accent": Colors.systemSwapColor,
                            "percent": SystemInfo.swapPercent,
                            "valueText": "",
                            "history": SystemInfo.swapHistory
                        });

                    list.push({
                        "icon": "󰋊",
                        "label": "Disk",
                        "accent": Colors.systemDiskColor,
                        "percent": SystemInfo.diskPercent,
                        "valueText": SystemInfo.diskUsedGiB.toFixed(0) + " / " + SystemInfo.diskTotalGiB.toFixed(0) + " GiB",
                        "history": SystemInfo.diskHistory
                    });
                    if (SystemInfo.gpuAvailable)
                        list.push({
                            "icon": "󰻠",
                            "label": "GPU",
                            "accent": Colors.systemGpuColor,
                            "percent": SystemInfo.gpuPercent,
                            "valueText": SystemInfo.gpuMemTotalGiB > 0 ? SystemInfo.gpuMemUsedGiB.toFixed(1) + " / " + SystemInfo.gpuMemTotalGiB.toFixed(1) + " GiB" : "",
                            "history": SystemInfo.gpuHistory
                        });

                    return list;
                }

                RowLayout {
                    id: pageLayout

                    anchors.fill: parent
                    anchors.margins: 40
                    anchors.topMargin: 32
                    spacing: 24

                    ColumnLayout {
                        id: widgetStack

                        Layout.fillHeight: true
                        Layout.preferredWidth: 300
                        spacing: 20

                        Repeater {
                            model: systemPage.resourceEntries

                            delegate: ResourceWidget {
                                id: tile

                                required property var modelData

                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                icon: tile.modelData.icon
                                label: tile.modelData.label
                                accent: tile.modelData.accent
                                percent: tile.modelData.percent
                                valueText: tile.modelData.valueText
                                history: tile.modelData.history
                            }

                        }

                    }

                    ProcessCard {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
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
            visible: OverlayPages.count > 1 && !OverlaySettings.open

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

        Item {
            id: settingsHost

            anchors.fill: parent
            visible: scrim.opacity > 0

            Rectangle {
                id: scrim

                anchors.fill: parent
                color: Colors.backdrop
                opacity: OverlaySettings.open ? 1 : 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 180
                        easing.type: Easing.OutCubic
                    }

                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: OverlaySettings.close()
                }

            }

            Rectangle {
                id: settingsCard

                width: 960
                height: 540
                anchors.centerIn: parent
                radius: 16
                color: Colors.background
                border.width: 1
                border.color: Colors.backgroundLight
                opacity: OverlaySettings.open ? 1 : 0
                visible: opacity > 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 180
                        easing.type: Easing.OutCubic
                    }

                }

                transform: Scale {
                    id: growTransform

                    origin.x: OverlaySettings.originX - settingsCard.x
                    origin.y: OverlaySettings.originY - settingsCard.y
                    xScale: OverlaySettings.open ? 1 : 0.05
                    yScale: OverlaySettings.open ? 1 : 0.05

                    Behavior on xScale {
                        NumberAnimation {
                            duration: 220
                            easing.type: Easing.OutCubic
                        }

                    }

                    Behavior on yScale {
                        NumberAnimation {
                            duration: 220
                            easing.type: Easing.OutCubic
                        }

                    }

                }

                MouseArea {
                    anchors.fill: parent
                }

                Loader {
                    anchors.fill: parent
                    active: OverlaySettings.current !== ""
                    sourceComponent: OverlaySettings.current === "network" ? networkScreenComponent : null
                }

            }

        }

    }

    Component {
        id: networkScreenComponent

        SettingsScreen {
            title: "Network"

            Column {
                anchors.fill: parent
                spacing: 10

                Text {
                    text: "Network settings - coming soon"
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

}
