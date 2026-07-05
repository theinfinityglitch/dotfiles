import QtQuick
import Quickshell
import Quickshell.Services.SystemTray

Row {
    id: root

    required property var parentWindow

    spacing: 10

    Repeater {
        model: SystemTray.items

        delegate: Rectangle {
            id: trayItem

            required property SystemTrayItem modelData
            readonly property string label: modelData.tooltipTitle || modelData.title || modelData.id

            radius: 48
            color: Colors.background
            width: 32
            height: 32
            scale: mouse.containsMouse ? 1.15 : 1
            transformOrigin: Item.Center

            Image {
                anchors.fill: parent
                anchors.margins: 6
                source: trayItem.modelData.icon
                sourceSize.width: 20
                sourceSize.height: 20
                smooth: true
                asynchronous: true
            }

            MouseArea {
                id: mouse

                anchors.fill: parent
                anchors.margins: -6
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: (mouseEvt) => {
                    if (mouseEvt.button === Qt.RightButton) {
                        if (trayItem.modelData.hasMenu)
                            menuLoader.active = !menuLoader.active;
                        else
                            trayItem.modelData.secondaryActivate();
                    } else {
                        if (trayItem.modelData.onlyMenu && trayItem.modelData.hasMenu)
                            menuLoader.active = !menuLoader.active;
                        else
                            trayItem.modelData.activate();
                    }
                }
            }

            CustomTooltip {
                visible: mouse.containsMouse && !menuLoader.active && trayItem.label !== ""
                anchorParent: trayItem
                anchor.margins.top: 42
                text: trayItem.label
            }

            Loader {
                id: menuLoader

                active: false

                sourceComponent: TrayMenu {
                    anchorItem: trayItem
                    menuHandle: trayItem.modelData.menu
                    visible: true
                    onCloseRequested: menuLoader.active = false
                }

            }

            Behavior on scale {
                NumberAnimation {
                    duration: 120
                    easing.type: Easing.OutCubic
                }

            }

        }

    }

}
