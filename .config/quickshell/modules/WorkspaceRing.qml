import QtQuick

Item {
    id: root

    property real diameter: 300
    property real thickness: 8
    property bool open: false
    property int staggerStep: 18
    property int growDuration: 200

    implicitWidth: diameter
    implicitHeight: diameter

    Repeater {
        model: WorkspaceInfo.count

        delegate: Item {
            id: wrapper

            required property int index
            readonly property int wsId: index + 1
            readonly property bool focused: WorkspaceInfo.isFocused(wsId)
            readonly property bool urgent: WorkspaceInfo.isUrgent(wsId)
            readonly property bool occupied: WorkspaceInfo.isOccupied(wsId)
            readonly property string label: "Workspace " + wrapper.wsId

            anchors.centerIn: parent
            width: root.diameter - root.thickness
            height: root.diameter - root.thickness
            rotation: (360 / WorkspaceInfo.count) * index

            Rectangle {
                id: segment

                width: 26
                height: root.thickness
                radius: height / 2
                anchors.horizontalCenter: parent.horizontalCenter
                y: -height / 2
                scale: 0
                transformOrigin: Item.Center
                color: wrapper.focused ? Colors.workspaceFocussedColor : wrapper.urgent ? Colors.workspaceUrgentColor : wrapper.occupied ? Colors.workspaceColor : Colors.workspaceEmptyColor
                state: root.open ? "open" : "closed"
                states: [
                    State {
                        name: "closed"

                        PropertyChanges {
                            target: segment
                            scale: 0
                        }

                    },
                    State {
                        name: "open"

                        PropertyChanges {
                            target: segment
                            scale: 1
                        }

                    }
                ]
                transitions: [
                    Transition {
                        from: "closed"
                        to: "open"

                        SequentialAnimation {
                            PauseAnimation {
                                duration: wrapper.index * root.staggerStep
                            }

                            NumberAnimation {
                                property: "scale"
                                duration: root.growDuration
                                easing.type: Easing.OutBack
                                easing.overshoot: 1.7
                            }

                        }

                    },
                    Transition {
                        from: "open"
                        to: "closed"

                        NumberAnimation {
                            property: "scale"
                            duration: 120
                            easing.type: Easing.InCubic
                        }

                    }
                ]

                MouseArea {
                    id: mouse

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: WorkspaceInfo.focus(wrapper.wsId)
                    onEntered: HoverLabel.show(wrapper)
                    onExited: HoverLabel.hide(wrapper)
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
