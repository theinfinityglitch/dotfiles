import QtQuick
import Quickshell
import Quickshell.Hyprland

Rectangle {
    id: root

    implicitWidth: row.implicitWidth
    implicitHeight: parent.height
    color: "transparent"

    Row {
        id: row

        anchors.centerIn: parent
        spacing: 6

        Repeater {
            model: 10

            delegate: Rectangle {
                id: segment

                required property int modelData
                readonly property int wsId: modelData + 1
                readonly property bool isFocused: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === wsId
                readonly property var wsRef: Hyprland.workspaces.values.find((w) => {
                    return w.id === wsId;
                })

                width: isFocused ? 52 : 26
                height: 10
                radius: 5
                color: isFocused ? Colors.workspaceFocussedColor : wsRef ? (wsRef.urgent ? Colors.workspaceUrgentColor : Colors.workspaceColor) : Colors.workspaceEmptyColor

                MouseArea {
                    id: mouse

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Hyprland.dispatch("hl.dsp.focus({ workspace = " + wsId + " })")
                }

                CustomTooltip {
                    visible: mouse.containsMouse
                    anchorParent: segment
                    text: "Workspace " + wsId
                }

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

            }

        }

    }

}
