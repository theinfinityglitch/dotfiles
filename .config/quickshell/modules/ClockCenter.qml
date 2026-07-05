import QtQuick
import Quickshell.Io

Item {
    id: root

    property int diameter: 230
    property bool open: false
    property string timeText: "--:--"
    property string dateText: ""

    width: diameter
    height: diameter

    Process {
        id: dateProc

        command: ["date", "+%H:%M|%A, %d %B"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                const parts = this.text.trim().split("|");
                if (parts.length === 2) {
                    root.timeText = parts[0];
                    root.dateText = parts[1];
                }
            }
        }

    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: dateProc.running = true
    }

    Rectangle {
        id: face

        anchors.fill: parent
        anchors.margins: 6
        radius: width / 2
        color: Colors.background
        border.width: 2
        border.color: Colors.clockColor
        scale: 0
        transformOrigin: Item.Center
        state: root.open ? "open" : "closed"

        states: [
            State {
                name: "closed"

                PropertyChanges {
                    target: face
                    scale: 0
                }

            },
            State {
                name: "open"

                PropertyChanges {
                    target: face
                    scale: 1
                }

            }
        ]

        transitions: [
            Transition {
                from: "closed"
                to: "open"

                NumberAnimation {
                    property: "scale"
                    duration: 200
                    easing.type: Easing.OutBack
                    easing.overshoot: 1.4
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

        Column {
            anchors.centerIn: parent
            spacing: 6

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.timeText
                color: Colors.foreground

                font {
                    pixelSize: 46
                    bold: true
                    family: "CaskaydiaCove Nerd Font"
                }

            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.dateText
                color: Colors.cyan
                font.pixelSize: 13
                horizontalAlignment: Text.AlignHCenter
                width: root.diameter - 40
                wrapMode: Text.WordWrap
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                visible: false // BatteryInfo.isPresent
                text: (BatteryInfo.isCharging ? "󰂄 " : "󰁹 ") + BatteryInfo.percent + "%"
                color: BatteryInfo.statusColor

                font {
                    pixelSize: 13
                    family: "CaskaydiaCove Nerd Font"
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 400
                    }

                }

            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                visible: false // BatteryInfo.isPresent && BatteryInfo.isCharging
                text: "Charging"
                color: Colors.batteryChargingColor

                font {
                    pixelSize: 13
                    family: "CaskaydiaCove Nerd Font"
                }

            }

        }

    }

}
