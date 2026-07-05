import QtQuick
import Quickshell

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
            model: WorkspaceInfo.count

            delegate: Rectangle {
                id: segment

                required property int index

                readonly property int wsId: index + 1
                readonly property bool focused: WorkspaceInfo.isFocused(wsId)
                readonly property bool urgent: WorkspaceInfo.isUrgent(wsId)
                readonly property bool occupied: WorkspaceInfo.isOccupied(wsId)

                width: focused ? 52 : 26
                height: 10
                radius: 5
                color: focused ? Colors.workspaceFocussedColor : urgent ? Colors.workspaceUrgentColor : occupied ? Colors.workspaceColor : Colors.workspaceEmptyColor

                MouseArea {
                    id: mouse

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: WorkspaceInfo.focus(segment.wsId)
                }

                CustomTooltip {
                    visible: mouse.containsMouse
                    anchorParent: segment
                    text: "Workspace " + segment.wsId
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
