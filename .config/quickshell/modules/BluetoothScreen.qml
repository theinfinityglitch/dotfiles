import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth

SettingsScreen {
    id: root

    title: "Bluetooth"

    Item {
        anchors.fill: parent

        ColumnLayout {
            anchors.fill: parent
            spacing: 14

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Rectangle {
                    id: btToggle

                    width: 46
                    height: 26
                    radius: 13
                    color: BluetoothInfo.enabled ? Colors.bluetoothColor : Colors.backgroundLight

                    Rectangle {
                        width: 20
                        height: 20
                        radius: 10
                        color: Colors.foreground
                        anchors.verticalCenter: parent.verticalCenter
                        x: BluetoothInfo.enabled ? parent.width - width - 3 : 3

                        Behavior on x {
                            NumberAnimation {
                                duration: 150
                                easing.type: Easing.OutCubic
                            }

                        }

                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: BluetoothInfo.toggleAdapter()
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }

                    }

                }

                Text {
                    text: BluetoothInfo.enabled ? "Bluetooth on" : "Bluetooth off"
                    color: Colors.foreground

                    font {
                        pixelSize: 14
                        family: "CaskaydiaCove Nerd Font"
                    }

                }

                Item {
                    Layout.fillWidth: true
                }

                Rectangle {
                    width: 110
                    height: 30
                    radius: 8
                    enabled: BluetoothInfo.enabled
                    opacity: enabled ? 1 : 0.4
                    color: scanMouse.containsMouse ? Colors.backgroundLight : "transparent"
                    border.width: 1
                    border.color: Colors.backgroundLight

                    Text {
                        anchors.centerIn: parent
                        text: BluetoothInfo.discovering ? "Stop scan" : "Scan"
                        color: Colors.foreground

                        font {
                            pixelSize: 13
                            family: "CaskaydiaCove Nerd Font"
                        }

                    }

                    MouseArea {
                        id: scanMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: BluetoothInfo.toggleDiscovery()
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 120
                        }

                    }

                }

            }

            Flickable {
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentHeight: listColumn.implicitHeight
                clip: true

                Column {
                    id: listColumn

                    width: parent.width
                    spacing: 8

                    Text {
                        text: "Paired devices"
                        color: Colors.foreground
                        opacity: 0.6

                        font {
                            pixelSize: 12
                            bold: true
                            family: "CaskaydiaCove Nerd Font"
                        }

                    }

                    Repeater {
                        model: BluetoothInfo.available ? BluetoothInfo.adapter.devices : null

                        delegate: Rectangle {
                            id: pairedRow

                            required property BluetoothDevice modelData

                            visible: pairedRow.modelData.paired || pairedRow.modelData.bonded
                            width: listColumn.width
                            height: 48
                            radius: 8
                            color: pairedMouse.containsMouse ? Colors.backgroundLight : "transparent"

                            MouseArea {
                                id: pairedMouse

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: pairedRow.modelData.connected = !pairedRow.modelData.connected
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 14
                                spacing: 10

                                Text {
                                    text: pairedRow.modelData.connected ? "󰂱" : "󰂲"
                                    color: pairedRow.modelData.connected ? Colors.bluetoothColor : Colors.foreground

                                    font {
                                        pixelSize: 16
                                        family: "CaskaydiaCove Nerd Font"
                                    }

                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: pairedRow.modelData.name
                                    color: Colors.foreground
                                    elide: Text.ElideRight

                                    font {
                                        pixelSize: 13
                                        family: "CaskaydiaCove Nerd Font"
                                    }

                                }

                                Text {
                                    visible: pairedRow.modelData.batteryAvailable
                                    text: Math.round(pairedRow.modelData.battery * 100) + "%"
                                    color: BluetoothInfo.batteryColor(pairedRow.modelData.battery)

                                    font {
                                        pixelSize: 12
                                        family: "CaskaydiaCove Nerd Font"
                                    }

                                }

                                Text {
                                    visible: pairedRow.modelData.connected
                                    text: "Connected"
                                    color: Colors.bluetoothColor

                                    font {
                                        pixelSize: 12
                                        family: "CaskaydiaCove Nerd Font"
                                    }

                                }

                                Text {
                                    text: "󰆴"
                                    color: forgetMouse.containsMouse ? Colors.red : Colors.backgroundLight

                                    font {
                                        pixelSize: 13
                                        family: "CaskaydiaCove Nerd Font"
                                    }

                                    MouseArea {
                                        id: forgetMouse

                                        anchors.fill: parent
                                        anchors.margins: -8
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: pairedRow.modelData.forget()
                                    }

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 120
                                        }

                                    }

                                }

                            }

                            Behavior on color {
                                ColorAnimation {
                                    duration: 120
                                }

                            }

                        }

                    }

                    Text {
                        topPadding: 10
                        text: "Available devices"
                        color: Colors.foreground
                        opacity: 0.6

                        font {
                            pixelSize: 12
                            bold: true
                            family: "CaskaydiaCove Nerd Font"
                        }

                    }

                    Repeater {
                        model: BluetoothInfo.available ? BluetoothInfo.adapter.devices : null

                        delegate: Rectangle {
                            id: availRow

                            required property BluetoothDevice modelData

                            visible: !(availRow.modelData.paired || availRow.modelData.bonded)
                            width: listColumn.width
                            height: 44
                            radius: 8
                            color: availMouse.containsMouse ? Colors.backgroundLight : "transparent"

                            MouseArea {
                                id: availMouse

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (!availRow.modelData.pairing)
                                        availRow.modelData.pair();

                                }
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 14
                                spacing: 10

                                Text {
                                    text: "󰂯"
                                    color: Colors.foreground
                                    opacity: 0.7

                                    font {
                                        pixelSize: 16
                                        family: "CaskaydiaCove Nerd Font"
                                    }

                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: availRow.modelData.name !== "" ? availRow.modelData.name : availRow.modelData.address
                                    color: Colors.foreground
                                    elide: Text.ElideRight

                                    font {
                                        pixelSize: 13
                                        family: "CaskaydiaCove Nerd Font"
                                    }

                                }

                                Text {
                                    text: availRow.modelData.pairing ? "Pairing…" : "Pair"
                                    color: Colors.bluetoothColor

                                    font {
                                        pixelSize: 12
                                        family: "CaskaydiaCove Nerd Font"
                                    }

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

    }

}
