import QtQuick
import Quickshell
import Quickshell.Hyprland

Rectangle {
    id: root

    property var workspaceNumbers: {
        const nums = new Set([1, 2, 3, 4, 5]);
        Hyprland.workspaces.values.forEach((w) => {
            if (w.id > 0)
                nums.add(w.id);

        });
        return Array.from(nums).sort((a, b) => {
            return a - b;
        });
    }

    implicitWidth: row.implicitWidth
    implicitHeight: parent.height
    color: "transparent"

    Row {
        id: row

        anchors.centerIn: parent
        height: parent.height
        spacing: 4

        Repeater {
            model: root.workspaceNumbers

            delegate: Rectangle {
                id: segment

                required property int modelData
                readonly property bool isFocused: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === modelData
                readonly property var wsRef: Hyprland.workspaces.values.find((w) => {
                    return w.id === modelData;
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
                    text: "Workspace " + segment.modelData
                }

            }

        }

    }

}
