import QtQuick
import Quickshell

Rectangle {
    id: root

    implicitWidth: parent.width
    implicitHeight: column.implicitHeight
    color: "transparent"

    Column {
        id: column

        anchors.centerIn: parent
        spacing: 6

        Repeater {
            model: WorkspaceInfo.workspaceIds

            delegate: Rectangle {
                id: segment

                required property var modelData

                readonly property int wsId: modelData
                readonly property bool focused: WorkspaceInfo.isFocused(wsId)

                width: 10
                height: focused ? 52 : 26
                radius: 5
                color: focused ? Colors.workspaceFocussedColor : Colors.workspaceColor

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
                    text: WorkspaceInfo.label(segment.wsId)
                    edge: "right"
                }

                Behavior on height {
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
