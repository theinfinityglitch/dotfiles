import QtQuick

Item {
    id: root

    implicitWidth: label.implicitWidth + 28
    implicitHeight: label.implicitHeight + 16
    opacity: HoverLabel.visible ? 1 : 0
    scale: HoverLabel.visible ? 1 : 0.94
    transformOrigin: Item.Top

    Rectangle {
        anchors.fill: parent
        radius: 10
        color: Colors.background
        border.width: 1
        border.color: Colors.backgroundLight

        Text {
            id: label

            anchors.centerIn: parent
            text: HoverLabel.text
            color: Colors.foreground

            font {
                pixelSize: 14
                family: "CaskaydiaCove Nerd Font"
            }

        }

    }

    Behavior on opacity {
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutCubic
        }

    }

    Behavior on scale {
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutCubic
        }

    }

}
