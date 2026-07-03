import QtQuick
import Quickshell

PopupWindow {
    id: root

    required property string text
    required property var anchorParent

    anchor.item: anchorParent
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    anchor.margins.top: 6
    implicitWidth: labelText.implicitWidth + 12
    implicitHeight: labelText.implicitHeight + 6
    color: Colors.background

    Text {
        id: labelText

        anchors.centerIn: parent
        text: root.text
        color: Colors.foreground
        font.pixelSize: 11
    }

}
