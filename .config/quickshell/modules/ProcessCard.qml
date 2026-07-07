import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    implicitWidth: 640
    implicitHeight: contentColumn.implicitHeight + 36
    radius: 12
    color: Colors.background
    border.width: 1
    border.color: Colors.backgroundLight

    ColumnLayout {
        id: contentColumn

        spacing: 10

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 18
        }

        Text {
            text: "Top processes"
            color: Colors.foreground
            opacity: 0.6

            font {
                pixelSize: 13
                bold: true
                family: "CaskaydiaCove Nerd Font"
            }

        }

        Repeater {
            model: SystemInfo.processes.length

            delegate: RowLayout {
                id: procRow

                required property int index
                readonly property var proc: SystemInfo.processes[index]

                Layout.fillWidth: true
                spacing: 10

                Text {
                    Layout.fillWidth: true
                    text: procRow.proc ? procRow.proc.name : ""
                    color: Colors.foreground
                    elide: Text.ElideRight

                    font {
                        pixelSize: 13
                        family: "CaskaydiaCove Nerd Font"
                    }

                }

                Text {
                    Layout.preferredWidth: 80
                    horizontalAlignment: Text.AlignRight
                    text: (procRow.proc ? procRow.proc.cpu.toFixed(1) : "0.0") + "% cpu"
                    color: Colors.foreground
                    opacity: 0.7

                    font {
                        pixelSize: 13
                        family: "CaskaydiaCove Nerd Font"
                    }

                }

                Text {
                    Layout.preferredWidth: 80
                    horizontalAlignment: Text.AlignRight
                    text: (procRow.proc ? procRow.proc.mem.toFixed(1) : "0.0") + "% mem"
                    color: Colors.foreground
                    opacity: 0.7

                    font {
                        pixelSize: 13
                        family: "CaskaydiaCove Nerd Font"
                    }

                }

                Text {
                    id: killButton

                    text: "󰅖"
                    color: killMouse.containsMouse ? Colors.red : Colors.backgroundLight

                    font {
                        pixelSize: 13
                        family: "CaskaydiaCove Nerd Font"
                    }

                    MouseArea {
                        id: killMouse

                        anchors.fill: parent
                        anchors.margins: -6
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (procRow.proc)
                                SystemInfo.killProcess(procRow.proc.pid);

                        }
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 120
                        }

                    }

                }

            }

        }

    }

}
