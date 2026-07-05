import QtQuick
import QtQuick.Shapes

Item {
    id: root

    property real diameter: 58
    property real ringThickness: 5
    property string icon: "?"
    property color accent: Colors.foreground
    property string mode: "progress" // "progress" or "toggle"
    property real value: 0 // 0-100, used when mode is "progress"
    property bool active: false // used when mode is "toggle"
    property bool muted: false // collapses the arc regardless of mode
    property string label: ""
    readonly property real sweepAngle: root.muted ? 0 : (root.mode === "progress" ? (root.value / 100) * 360 : (root.active ? 360 : 0))
    readonly property color ringColor: root.muted ? Colors.backgroundLight : root.accent
    readonly property bool dimmed: root.muted || (root.mode === "toggle" && !root.active)

    signal activated()
    signal scrolledUp()
    signal scrolledDown()

    implicitWidth: diameter
    implicitHeight: diameter

    Item {
        id: visual

        anchors.fill: parent
        scale: mouse.containsMouse ? 1.12 : 1
        transformOrigin: Item.Center

        Shape {
            anchors.fill: parent
            layer.enabled: true
            layer.samples: 4

            ShapePath {
                strokeWidth: root.ringThickness
                strokeColor: Colors.backgroundLight
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap

                PathAngleArc {
                    centerX: root.diameter / 2
                    centerY: root.diameter / 2
                    radiusX: (root.diameter - root.ringThickness) / 2
                    radiusY: (root.diameter - root.ringThickness) / 2
                    startAngle: 0
                    sweepAngle: 360
                }

            }

        }

        Shape {
            anchors.fill: parent
            layer.enabled: true
            layer.samples: 4

            ShapePath {
                strokeWidth: root.ringThickness
                strokeColor: root.ringColor
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap

                PathAngleArc {
                    centerX: root.diameter / 2
                    centerY: root.diameter / 2
                    radiusX: (root.diameter - root.ringThickness) / 2
                    radiusY: (root.diameter - root.ringThickness) / 2
                    startAngle: -90
                    sweepAngle: root.sweepAngle

                    Behavior on sweepAngle {
                        NumberAnimation {
                            duration: 250
                            easing.type: Easing.OutCubic
                        }

                    }

                }

                Behavior on strokeColor {
                    ColorAnimation {
                        duration: 200
                    }

                }

            }

        }

        Rectangle {
            id: button

            anchors.centerIn: parent
            width: root.diameter - root.ringThickness * 3
            height: width
            radius: width / 2
            color: Colors.background
            border.width: 1
            border.color: Colors.backgroundLight
            opacity: root.dimmed ? 0.6 : 1

            Text {
                anchors.centerIn: parent
                text: root.icon
                color: root.accent

                font {
                    pixelSize: 18
                    family: "CaskaydiaCove Nerd Font"
                }

            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                }

            }

        }

        Behavior on scale {
            NumberAnimation {
                duration: 120
                easing.type: Easing.OutCubic
            }

        }

    }

    MouseArea {
        id: mouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
        onEntered: HoverLabel.show(root)
        onExited: HoverLabel.hide(root)
        onWheel: (wheelEvt) => {
            if (wheelEvt.angleDelta.y > 0)
                root.scrolledUp();
            else if (wheelEvt.angleDelta.y < 0)
                root.scrolledDown();
        }
    }

}
