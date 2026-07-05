import QtQuick
import Quickshell

PopupWindow {
    id: root

    required property string text
    required property var anchorParent

    anchor.item: anchorParent
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    anchor.margins.top: 16
    implicitWidth: labelText.implicitWidth + 24
    implicitHeight: labelText.implicitHeight + 16
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        radius: 10
        color: Colors.background
        border.width: 1
        border.color: Colors.backgroundLight

        Text {
            id: labelText

            anchors.centerIn: parent
            text: root.text
            color: Colors.foreground

            font {
                pixelSize: 14
                family: "CaskaydiaCove Nerd Font"
            }

        }

    }

}
