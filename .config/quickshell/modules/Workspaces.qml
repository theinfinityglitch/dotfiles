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
        height: parent.height
        spacing: 4

        Repeater {
            model: 10

            delegate: Rectangle {
                id: segment

                required property int modelData
                readonly property bool isFocused: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === modelData + 1
                readonly property var wsRef: Hyprland.workspaces.values.find((w) => {
                    return w.id === modelData + 1;
                })

                width: 50
                height: parent.height
                color: isFocused ? Colors.workspaceFocussedColor : wsRef ? (wsRef.urgent ? Colors.workspaceUrgentColor : Colors.workspaceColor) : Colors.workspaceEmptyColor

                MouseArea {
                    id: mouse

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Hyprland.dispatch("hl.dsp.focus({ workspace = " + segment.modelData + " })")
                }

                CustomTooltip {
                    visible: mouse.containsMouse
                    anchorParent: segment
                    text: "Workspace " + (segment.modelData + 1)
                }

            }

        }

    }

}
