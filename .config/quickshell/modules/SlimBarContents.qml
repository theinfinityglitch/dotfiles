import QtQuick
import Quickshell

Rectangle {
    id: root

    required property Overlay overlay

    color: Colors.backdrop
    implicitHeight: 5

    MouseArea {
        id: mouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.overlay.toggleMenu()
    }

    Workspaces {
        anchors.centerIn: parent
    }

}
