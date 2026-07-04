import QtQuick
import Quickshell

Rectangle {
    id: root

    required property Overlay overlay

    implicitHeight: 5
    color: Colors.background

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
