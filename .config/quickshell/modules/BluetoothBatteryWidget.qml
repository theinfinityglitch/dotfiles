import QtQuick
import QtQuick.Layouts

Row {
    id: root

    spacing: 8
    visible: BluetoothInfo.devicesWithBattery.length > 0

    Repeater {
        model: BluetoothInfo.devicesWithBattery

        delegate: Rectangle {
            id: chip

            required property var modelData

            implicitWidth: chipRow.implicitWidth + 20
            implicitHeight: 36
            radius: 18
            color: Colors.background
            border.width: 1
            border.color: Colors.backgroundLight

            RowLayout {
                id: chipRow

                anchors.centerIn: parent
                spacing: 6

                Text {
                    text: "󰂯"
                    color: Colors.bluetoothColor

                    font {
                        pixelSize: 14
                        family: "CaskaydiaCove Nerd Font"
                    }

                }

                Text {
                    Layout.maximumWidth: 90
                    text: chip.modelData.name
                    color: Colors.foreground
                    elide: Text.ElideRight

                    font {
                        pixelSize: 12
                        family: "CaskaydiaCove Nerd Font"
                    }

                }

                Text {
                    text: Math.round(chip.modelData.battery * 100) + "%"
                    color: BluetoothInfo.batteryColor(chip.modelData.battery)

                    font {
                        pixelSize: 12
                        bold: true
                        family: "CaskaydiaCove Nerd Font"
                    }

                }

            }

        }

    }

}
