import QtQuick
import QtQuick.Shapes

Item {
    id: root

    property real diameter: 260
    property real thickness: 6
    readonly property int percent: BatteryInfo.percent
    readonly property bool charging: BatteryInfo.isCharging
    readonly property color fillColor: {
        if (charging)
            return Colors.green;

        if (root.percent <= 15)
            return Colors.red;

        if (root.percent <= 40)
            return Colors.orange;

        return Colors.green;
    }

    visible: BatteryInfo.isPresent
    implicitWidth: diameter
    implicitHeight: diameter

    SequentialAnimation {
        running: root.charging
        loops: Animation.Infinite
        onStopped: fill.opacity = 1

        NumberAnimation {
            target: fill
            property: "opacity"
            from: 1
            to: 0.45
            duration: 900
            easing.type: Easing.InOutSine
        }

        NumberAnimation {
            target: fill
            property: "opacity"
            from: 0.45
            to: 1
            duration: 900
            easing.type: Easing.InOutSine
        }

    }

    Shape {
        anchors.fill: parent
        layer.enabled: true
        layer.samples: 4

        ShapePath {
            strokeWidth: root.thickness
            strokeColor: Colors.backgroundLight
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: root.diameter / 2
                centerY: root.diameter / 2
                radiusX: (root.diameter - root.thickness) / 2
                radiusY: (root.diameter - root.thickness) / 2
                startAngle: 0
                sweepAngle: 360
            }

        }

    }

    Shape {
        id: fill

        anchors.fill: parent
        layer.enabled: true
        layer.samples: 4

        ShapePath {
            strokeWidth: root.thickness
            strokeColor: root.fillColor
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: root.diameter / 2
                centerY: root.diameter / 2
                radiusX: (root.diameter - root.thickness) / 2
                radiusY: (root.diameter - root.thickness) / 2
                startAngle: -90
                sweepAngle: root.percent / 100 * 360

                Behavior on sweepAngle {
                    NumberAnimation {
                        duration: 500
                        easing.type: Easing.OutCubic
                    }

                }

            }

            Behavior on strokeColor {
                ColorAnimation {
                    duration: 400
                }

            }

        }

    }

}
