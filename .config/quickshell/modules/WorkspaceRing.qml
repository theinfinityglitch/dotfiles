import QtQuick
import Quickshell
import Quickshell.Hyprland

Item {
    id: root

    property real diameter: 300
    property real thickness: 8
    property int count: 10

    implicitWidth: diameter
    implicitHeight: diameter

    Repeater {
        model: root.count

        delegate: Item {
            id: wrapper

            required property int modelData
            readonly property int wsId: modelData + 1
            readonly property bool isFocused: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === wsId
            readonly property var wsRef: Hyprland.workspaces.values.find((w) => {
                return w.id === wsId;
            })

            anchors.centerIn: parent
            width: root.diameter - root.thickness
            height: root.diameter - root.thickness
            rotation: (360 / root.count) * modelData

            Rectangle {
                id: segment

                width: isFocused ? 52 : 26 // root.pillLength
                height: root.thickness
                radius: height / 2
                anchors.horizontalCenter: parent.horizontalCenter
                y: -height / 2
                color: wrapper.isFocused ? Colors.workspaceFocussedColor : wrapper.wsRef ? (wrapper.wsRef.urgent ? Colors.workspaceUrgentColor : Colors.workspaceColor) : Colors.workspaceEmptyColor

                MouseArea {
                    id: mouse

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Hyprland.dispatch("hl.dsp.focus({ workspace = " + (wrapper.modelData + 1) + " })")
                }

                CustomTooltip {
                    visible: mouse.containsMouse
                    anchorParent: segment
                    text: "Workspace " + wrapper.wsId
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
