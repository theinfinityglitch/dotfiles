import QtQuick
import Quickshell.Io

Item {
    id: root

    property int diameter: 230
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
        anchors.fill: parent
        anchors.margins: 6
        radius: width / 2
        color: Colors.background
        border.width: 2
        border.color: Colors.blue

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
                visible: BatteryInfo.isPresent
                text: (BatteryInfo.isCharging ? "󰂄 " : "󰁹 ") + BatteryInfo.percent + "%"
                color: {
                    if (BatteryInfo.isCharging)
                        return Colors.green;

                    if (BatteryInfo.percent <= 15)
                        return Colors.red;

                    if (BatteryInfo.percent <= 40)
                        return Colors.orange;

                    return Colors.green;
                }

                font {
                    pixelSize: 13
                    family: "CaskaydiaCove Nerd Font"
                }

            }

        }

    }

}
